require 'uri'
require 'net/http'
require 'nokogiri'
require 'pry'
require 'csv'
require_relative 'models/doc_delta_doctor'
require_relative 'models/doc_info_org_doctor'

class Controller

	attr_accessor :doc_delta_doctors

	def initialize
		@doc_delta_doctors = doc_delta_doctors || []
		self.create_doc_delta_instances
	end

	def create_doc_delta_instances

		input_doctors = []
		input_data_file = ARGV[0]
	
		CSV.foreach(input_data_file, headers:true, header_converters: :symbol, encoding:'iso-8859-1:utf-8') do |row|

			npi = row[0]
			first_name = row[1]
			last_name = row[2]
			gender = row[3]
			specialties = []
			specialties << row[4].strip.downcase

			states =  {
		 	'AL' => 'Alabama',
		    'AK' => 'Alaska',
		    'AS' => 'America Samoa',
		    'AZ' => 'Arizona',
		    'AR' => 'Arkansas',
		    'CA' => 'California',
		    'CO' => 'Colorado',
		    'CT' => 'Connecticut',
		    'DE' => 'Delaware',
		    'DC' => 'District Of Columbia',
		    'FM' => 'Federated States Of Micronesia',
		    'FL' => 'Florida',
		    'GA' => 'Georgia',
		    'GU' => 'Guam',
		    'HI' => 'Hawaii',
		    'ID' => 'Idaho',
		    'IL' => 'Illinois',
		    'IN' => 'Indiana',
		    'IA' => 'Iowa',
		    'KS' => 'Kansas',
		    'KY' => 'Kentucky',
		    'LA' => 'Louisiana',
		    'ME' => 'Maine',
		    'MH' => 'Marshall Islands',
		    'MD' => 'Maryland',
		    'MA' => 'Massachusetts',
		    'MI' => 'Michigan',
		    'MN' => 'Minnesota',
		    'MS' => 'Mississippi',
		    'MO' => 'Missouri',
		    'MT' => 'Montana',
		    'NE' => 'Nebraska',
		    'NV' => 'Nevada',
		    'NH' => 'New Hampshire',
		    'NJ' => 'New Jersey',
		    'NM' => 'New Mexico',
		    'NY' => 'New York',
		    'NC' => 'North Carolina',
		    'ND' => 'North Dakota',
		    'OH' => 'Ohio',
		    'OK' => 'Oklahoma',
		    'OR' => 'Oregon',
		    'PW' => 'Palau',
		    'PA' => 'Pennsylvania',
		    'PR' => 'Puerto Rico',
		    'RI' => 'Rhode Island',
		    'SC' => 'South Carolina',
		    'SD' => 'South Dakota',
		    'TN' => 'Tennessee',
		    'TX' => 'Texas',
		    'UT' => 'Utah',
		    'VT' => 'Vermont',
		    'VI' => 'Virgin Island',
		    'VA' => 'Virginia',
		    'WA' => 'Washington',
		    'WV' => 'West Virginia',
		    'WI' => 'Wisconsin',
		    'WY' => 'Wyoming',
		    'NULL' => nil.to_s
		}

		state = states[row[5]]
		
		input_doctors << DocDeltaDoctor.new({npi: npi, first_name: first_name, last_name: last_name, gender: gender, specialties: specialties, state: state})
		end

		self.configure_route_to_docInfo_server(input_doctors)
	end

	def configure_route_to_docInfo_server(input_doctors)
		input_doctors.each_with_index do |input_doctor, index|
			route = 'http://www.docinfo.org/Home/Search?doctorname=' + input_doctor.first_name + '%20' + input_doctor.last_name
			if input_doctor.state && input_doctor.state != nil.to_s
				route = route + '&usstate='
				input_doctor.state.split(" ").each_with_index do |word, slot|
					if input_doctor.state.split(" ")[slot + 1]
						route = route + word + '%20'
					else 
						route = route + word + '&from=0'
					end
				end
			else
				route = route + '&from=0'
			end 
			input_doctor.set_route_to_docInfo_server(route) 
		end

		self.make_request_to_docInfoOrg_server(input_doctors)
	end 


	def make_request_to_docInfoOrg_server(input_doctors)

		input_doctors.each do |input_doctor|
			uri = URI(input_doctor.route_to_server)
			https = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			docInfoOrg_search_results = https.request(request).body
			docInfoOrg_search_results =  docInfoOrg_search_results.gsub(/null/, 'nil')
			docInfoOrg_search_results = eval(docInfoOrg_search_results)
			input_doctor.set_docInfo_search_results(docInfoOrg_search_results)
		end

		self.parse_docInfoOrg_Results_into_XMLDoc(input_doctors)
	end

	def parse_docInfoOrg_Results_into_XMLDoc(input_doctors)
		input_doctors.each do |input_doctor|
			docInfoOrg_doctors_XML = input_doctor.docInfo_search_results[:hits][:hits].each_with_object([]) do |docInfoOrg_doctor, array|
			array << Nokogiri::XML(docInfoOrg_doctor[:_source][:message])
			end
			input_doctor.parsedXML_docInfo_results(docInfoOrg_doctors_XML)
		end
		self.parse_docInfo_doctor_attributes(input_doctors)
	end

	def parse_docInfo_doctor_attributes(input_doctors)
		input_doctors.each do |input_doctor|
			docInfoOrg_doctor_instances = []
			input_doctor.parsed_docInfo_results.each do |docInfo_doctor|
				first_name = docInfo_doctor.css("FirstName").text.strip
				last_name = docInfo_doctor.css("LastName").text.strip
				full_name = docInfo_doctor.css("FullName").text.strip
				gender = docInfo_doctor.css("Gender").text.strip
				specialties = 
					docInfo_doctor.css("Certifications Certification BoardName").each_with_object([]) do |node, array|
						array << node.text.delete("*").strip.downcase
					end
				reported_states = 
					docInfo_doctor.css("Locations Location State").each_with_object([]) do |node, array|
						array << node.text.strip.downcase
					end
				medical_school = docInfo_doctor.css("MedicalSchoolName").text.strip
				graduation_year = docInfo_doctor.css("GraduationYear").text.strip
				active_licenses_in_these_states = 
					docInfo_doctor.css("Licensures Licensure State").each_with_object([]) do |node, array|
						array << node.text.strip
					end
				punitive_board_actions_in_these_states = 
					docInfo_doctor.css("BoardActions BoardAction State").each_with_object([]) do |node, array|
						# docInfo_doctor.css("BoardActions BoardAction StateURL").each do |url|
						array << node
							# array <<  '<a href="' + url + '">' + node.text.strip + '</a>'
						# end
					end
				docInfoOrg_doctor_instances << DocInfoOrgDoctor.new({first_name: first_name, last_name: last_name, full_name: full_name, gender: gender, specialties: specialties, reported_states: reported_states, medical_school: medical_school, graduation_year: graduation_year, active_licenses_in_these_states: active_licenses_in_these_states, punitive_board_actions_in_these_states: punitive_board_actions_in_these_states})
			end	

			input_doctor.set_docInfoOrg_doctor_instances(docInfoOrg_doctor_instances)

		end
		self.compare_docInfoDoc_to_docDeltaDoc(input_doctors)

	end

	def compare_docInfoDoc_to_docDeltaDoc(input_doctors)

		updated_input_doctors = []
		input_doctors.each do |input_doctor|
			input_doctor.docInfoOrg_doctor_instances.each do |docInfoOrg_doctor|
				first_name_check = input_doctor.first_name.downcase == docInfoOrg_doctor.first_name.downcase
				last_name_check = input_doctor.last_name.downcase == docInfoOrg_doctor.last_name.downcase
				gender_check = input_doctor.gender.downcase == docInfoOrg_doctor.gender.downcase
				specialties_check = false
				input_doctor.specialties.each do |specialty|
					specialties_check = true if docInfoOrg_doctor.specialties.include?(specialty.downcase) 
				end
				state_check = docInfoOrg_doctor.reported_states.include?(input_doctor.state.downcase)  
			
				if first_name_check && last_name_check && gender_check && specialties_check && state_check 
					input_doctor.full_name = docInfoOrg_doctor.full_name
					input_doctor.specialties = docInfoOrg_doctor.specialties
					input_doctor.medical_school = docInfoOrg_doctor.medical_school
					input_doctor.graduation_year = docInfoOrg_doctor.graduation_year
					input_doctor.active_licenses_in_these_states = docInfoOrg_doctor.active_licenses_in_these_states
					input_doctor.punitive_board_actions_in_these_states = docInfoOrg_doctor.punitive_board_actions_in_these_states

					updated_input_doctors << input_doctor
				end 
			end
		end
		self.generate_output_CSV(input_doctors, updated_input_doctors)
	end

	
	def generate_output_CSV(input_doctors, updated_input_doctors)
			CSV.open('output_data_all_doctors.csv', 'a+', write_headers: true, headers: ["NPI", "First Name", "Last Name", "Gender", "Specialties" , "State", "Full Name" ,"Medical School","Graduation Year", "Active Licenses", "Board Actions"]) do |row|
				input_doctors.each do |input_doctor|
					row << [input_doctor.npi, input_doctor.first_name, input_doctor.last_name, input_doctor.gender, input_doctor.specialties.flatten.join(", "), input_doctor.state, input_doctor.full_name, input_doctor.medical_school, input_doctor.graduation_year, input_doctor.active_licenses_in_these_states.flatten.join(", "), input_doctor.punitive_board_actions_in_these_states.flatten.join(", ")]
				end
			end
			self.generate_CSV_with_updated_doctors_only(updated_input_doctors)
	end

	def generate_CSV_with_updated_doctors_only(updated_input_doctors)

		CSV.open('output_data_updated_doctors_only.csv', 'a+', write_headers: true, headers: ["NPI", "First Name", "Last Name", "Gender", "Specialties" , "State", "Full Name" ,"Medical School","Graduation Year", "Active Licenses", "Board Actions"]) do |row|
			updated_input_doctors.each do |updated_doctor|
				row << [updated_doctor.npi, updated_doctor.first_name, updated_doctor.last_name, updated_doctor.gender, updated_doctor.specialties.flatten.join(", "), updated_doctor.state, updated_doctor.full_name, updated_doctor.medical_school, updated_doctor.graduation_year, updated_doctor.active_licenses_in_these_states.flatten.join(", "), updated_doctor.punitive_board_actions_in_these_states.flatten.join(", ")]
			end
		end
	end


end
controller = Controller.new

