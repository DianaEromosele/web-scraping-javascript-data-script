require 'uri'
require 'net/http'
require 'nokogiri'
require 'pry'
require 'csv'
require_relative 'doc_delta_doctor'
require_relative 'doc_info_org_doctor'

class Controller

	attr_accessor :doc_delta_doctors

	def initialize
		@doc_delta_doctors = doc_delta_doctors || []
		self.create_doc_delta_instances
	end

	def create_doc_delta_instances

		# CSV.open()
		CSV.foreach('doc_delta_spreadsheet.csv', headers:true, header_converters: :symbol, encoding:'iso-8859-1:utf-8') do |row|

			npi = row[0]
			first_name = row[1]
			last_name = row[2]
			gender = row[3]
			specialties = []
			specialties << row[4]
			medical_school = row[6]
			graduation_year = row[7]
			active_licenses_in_these_states = row[8]
			punitive_board_actions_in_these_states = row[9]

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
		    'WY' => 'Wyoming'
		}

		state = states[row[5]]
		
		@doc_delta_doctors << DocDeltaDoctor.new({npi: npi, first_name: first_name, last_name: last_name, gender: gender, specialties: specialties, state: state, medical_school: medical_school, graduation_year: graduation_year, active_licenses_in_these_states: active_licenses_in_these_states, punitive_board_actions_in_these_states: punitive_board_actions_in_these_states})
		end

		self.configure_root_path
	end

	def configure_root_path
		@doc_delta_doctors.each do |doc_delta_doctor|
			root = 'http://www.docinfo.org/Home/Search?doctorname=' + doc_delta_doctor.first_name + '%20' + doc_delta_doctor.last_name
			if doc_delta_doctor.state 
				root = root + '&usstate='
				doc_delta_doctor.state.split(" ").each_with_index do |word, index|
					if doc_delta_doctor.state.split(" ")[index + 1]
						root = root + word + '%20'
					else 
						root = root + word + '&from=0'
					end
				end
			else
				root = root + '&from=0'
			end 
			self.make_request_to_docInfoOrg_server(root, doc_delta_doctor)
		end
	end 


	def make_request_to_docInfoOrg_server(root, doc_delta_doctor)
			uri = URI(root)
			https = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			docInfoOrg_search_results = https.request(request).body
			docInfoOrg_search_results =  docInfoOrg_search_results.gsub(/null/, 'nil')
			# turn to Hash
			docInfoOrg_search_results = eval(docInfoOrg_search_results)
			self.parse_docInfoOrg_Results_into_XMLDoc(docInfoOrg_search_results, doc_delta_doctor )
	end

	def parse_docInfoOrg_Results_into_XMLDoc(docInfoOrg_search_results, doc_delta_doctor)
		docInfoOrg_doctors_XML = docInfoOrg_search_results[:hits][:hits].each_with_object([]) do |docInfoOrg_doctor, array|
			array << Nokogiri::XML(docInfoOrg_doctor[:_source][:message])
		end
		self.parse_docInfo_doctor_attributes(docInfoOrg_doctors_XML, doc_delta_doctor)
	end

	def parse_docInfo_doctor_attributes(docInfoOrg_doctors_XML, doc_delta_doctor)
		# puts "Doc Delta Doctor: " + doc_delta_doctor.first_name + " " + doc_delta_doctor.last_name

		docInfoOrg_doctors_XML.each do |doctor|
			first_name = doctor.css("FirstName").text
			last_name = doctor.css("LastName").text
			full_name = doctor.css("FullName").text
			gender = doctor.css("Gender").text
			specialties = doctor.css("Certifications Certification BoardName").each_with_object([]) do |node, array|
				array << node.text.delete("*").downcase
			end
			reported_states = doctor.css("Locations Location State").each_with_object([]) do |node, array|
				array << node.text.downcase
			end
			medical_school = doctor.css("MedicalSchoolName").text
			graduation_year = doctor.css("GraduationYear").text
			active_licenses_in_these_states = doctor.css("Licensures Licensure State").each_with_object([]) do |node, array|
				array << node.text
			end
			punitive_board_actions_in_these_states = doctor.css("BoardActions BoardAction State").each_with_object([]) do |node, array|
				doctor.css("BoardActions BoardAction StateURL").each do |url|
					array <<  '<a href="' + url + '">' + node.text + '</a>'
				end
			end
			docInfoOrg_doctor = DocInfoOrgDoctor.new({first_name: first_name, last_name: last_name, full_name: full_name, gender: gender, specialties: specialties, reported_states: reported_states, medical_school: medical_school, graduation_year: graduation_year, active_licenses_in_these_states: active_licenses_in_these_states, punitive_board_actions_in_these_states: punitive_board_actions_in_these_states})
			self.compare_docInfoDoc_to_docDeltaDoc(doc_delta_doctor, docInfoOrg_doctor, )
		end	

	end

	def compare_docInfoDoc_to_docDeltaDoc(doc_delta_doctor, docInfoOrg_doctor)

		puts "Before Check"
		puts doc_delta_doctor.first_name + " " + doc_delta_doctor.last_name
		puts "Specialties"
		puts doc_delta_doctor.specialties

		first_name_check = doc_delta_doctor.first_name.downcase == docInfoOrg_doctor.first_name.downcase
		last_name_check = doc_delta_doctor.last_name.downcase == docInfoOrg_doctor.last_name.downcase
		gender_check = doc_delta_doctor.gender.downcase == docInfoOrg_doctor.gender.downcase
		specialties_check = true
			doc_delta_doctor.specialties.each do |specialty|
				specialties_check = docInfoOrg_doctor.specialties.include?(specialty.downcase) 
			end
		state_check = docInfoOrg_doctor.reported_states.include?(doc_delta_doctor.state)   

		if first_name_check && last_name_check && gender_check && specialties_check && state_check 
			doc_delta_doctor.specialties = docInfoOrg_doctor.specialties
			doc_delta_doctor.medical_school = docInfoOrg_doctor.medical_school
			doc_delta_doctor.graduation_year = docInfoOrg_doctor.graduation_year
			doc_delta_doctor.active_licenses_in_these_states = docInfoOrg_doctor.active_licenses_in_these_states
			doc_delta_doctor.punitive_board_actions_in_these_states = docInfoOrg_doctor.punitive_board_actions_in_these_states
		end 

		puts "First name check: ", first_name_checkc

		puts "---------"
		puts "After Check"

		puts doc_delta_doctor.first_name + " " + doc_delta_doctor.last_name
		puts "Specialties"
		puts doc_delta_doctor.specialties
		puts doc_delta_doctor.medical_school
		puts doc_delta_doctor.graduation_year
		puts doc_delta_doctor.active_licenses_in_these_states
		puts doc_delta_doctor.punitive_board_actions_in_these_states

	end



end
controller = Controller.new

