require 'uri'
require 'net/http'
require 'csv'
require 'nokogiri'
require_relative 'models/doc_delta_doctor'
require_relative 'models/doc_info_org_doctor'

class Controller
	attr_accessor :docDeltaDoctors

	def initialize
		@docDeltaDoctors ||= []
		self.create_docDeltaDoctor_objects
	end

	def create_docDeltaDoctor_objects
		docDeltaDoctors = []
		input_CSV_file_containing_docDeltaDoctors_data = ARGV[0]
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

		CSV.foreach(input_CSV_file_containing_docDeltaDoctors_data, headers:true, header_converters: :symbol, encoding:'iso-8859-1:utf-8') do |row|

			npi = row[0]
			first_name = row[1]
			last_name = row[2]
			gender = row[3]
			specialties = []
			specialties << row[4].strip.downcase
			state = states[row[5]]
			@docDeltaDoctors << DocDeltaDoctor.new({npi: npi, first_name: first_name, last_name: last_name, gender: gender, specialties: specialties, state: state})
		end
		self.create_HTTP_route_to_docInfo_server
	end

	def create_HTTP_route_to_docInfo_server
		@docDeltaDoctors.each do |docDeltaDoctor|
			docDeltaDoctor.create_HTTP_route_to_docInfo_server
		end
		self.make_HTTP_request_to_docInfoOrg_server
	end

	def make_HTTP_request_to_docInfoOrg_server
		@docDeltaDoctors.each do |docDeltaDoctor|
			uri = URI(docDeltaDoctor.route_to_server)
			https = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			docInfoOrg_search_results = https.request(request).body
			docInfoOrg_search_results =  docInfoOrg_search_results.gsub(/null/, 'nil')
			docInfoOrg_search_results = eval(docInfoOrg_search_results)
			docDeltaDoctor.docInfoOrg_search_results = docInfoOrg_search_results
		end

		self.convert_docInfoOrg_search_results_into_XML
	end

	def convert_docInfoOrg_search_results_into_XML
		@docDeltaDoctors.each do |docDeltaDoctor|
			docInfoOrg_doctors_XML = docDeltaDoctor.docInfoOrg_search_results[:hits][:hits].each_with_object([]) do |docInfoOrg_doctor, array|
			array << Nokogiri::XML(docInfoOrg_doctor[:_source][:message])
			end
			docDeltaDoctor.docInfoOrg_results_as_XML = docInfoOrg_doctors_XML
		end
		self.parse_XML_to_retrive_docInfoOrg_doctor_attributes
	end

	def parse_XML_to_retrive_docInfoOrg_doctor_attributes
		@docDeltaDoctors.each do |docDeltaDoctor|
			docInfoOrg_doctor_objects = []
			docDeltaDoctor.docInfoOrg_results_as_XML.each do |docInfo_doctor|
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
						array << node
					end
				docInfoOrg_doctor_objects << DocInfoOrgDoctor.new({first_name: first_name, last_name: last_name, full_name: full_name, gender: gender, specialties: specialties, reported_states: reported_states, medical_school: medical_school, graduation_year: graduation_year, active_licenses_in_these_states: active_licenses_in_these_states, punitive_board_actions_in_these_states: punitive_board_actions_in_these_states})
			end
			docDeltaDoctor.docInfoOrg_doctor_objects = docInfoOrg_doctor_objects
		end
		self.compare_docInfoOrgDoctor_to_docDeltaDoctor
	end

	def compare_docInfoOrgDoctor_to_docDeltaDoctor
		updated_docDeltaDoctors = @docDeltaDoctors.each_with_object([]) do |docDeltaDoctor, array|
			docDeltaDoctor.docInfoOrg_doctor_objects.each do |docInfoOrg_doctor|
				first_name_check = docDeltaDoctor.first_name.downcase == docInfoOrg_doctor.first_name.downcase
				last_name_check = docDeltaDoctor.last_name.downcase == docInfoOrg_doctor.last_name.downcase
				gender_check = docDeltaDoctor.gender.downcase == docInfoOrg_doctor.gender.downcase
				specialties_check = false
				docDeltaDoctor.specialties.each do |specialty|
					specialties_check = true if docInfoOrg_doctor.specialties.include?(specialty.downcase)
				end
				state_check = docInfoOrg_doctor.reported_states.include?(docDeltaDoctor.state.downcase)

				if first_name_check && last_name_check && gender_check && specialties_check && state_check
					docDeltaDoctor.full_name = docInfoOrg_doctor.full_name
					docDeltaDoctor.specialties = docInfoOrg_doctor.specialties
					docDeltaDoctor.medical_school = docInfoOrg_doctor.medical_school
					docDeltaDoctor.graduation_year = docInfoOrg_doctor.graduation_year
					docDeltaDoctor.active_licenses_in_these_states = docInfoOrg_doctor.active_licenses_in_these_states
					docDeltaDoctor.punitive_board_actions_in_these_states = docInfoOrg_doctor.punitive_board_actions_in_these_states
					array << docDeltaDoctor
				end
			end
		end
		self.generate_CSV_with_data_for_all_doctors
		self.generate_CSV_with_updated_doctors_only(updated_docDeltaDoctors)
	end


	def generate_CSV_with_data_for_all_doctors
		CSV.open('output_data_all_doctors.csv', 'a+', write_headers: true, headers: ["NPI", "First Name", "Last Name", "Gender", "Specialties" , "State", "Full Name" ,"Medical School","Graduation Year", "Active Licenses", "Board Actions"]) do |row|
			@docDeltaDoctors.each do |docDeltaDoctor|
				row << [docDeltaDoctor.npi, docDeltaDoctor.first_name, docDeltaDoctor.last_name, docDeltaDoctor.gender, docDeltaDoctor.specialties.flatten.join(", "), docDeltaDoctor.state, docDeltaDoctor.full_name, docDeltaDoctor.medical_school, docDeltaDoctor.graduation_year, docDeltaDoctor.active_licenses_in_these_states.flatten.join(", "), docDeltaDoctor.punitive_board_actions_in_these_states.flatten.join(", ")]
			end
		end
	end

	def generate_CSV_with_updated_doctors_only(updated_docDeltaDoctors)
		CSV.open('output_data_updated_doctors_only.csv', 'a+', write_headers: true, headers: ["NPI", "First Name", "Last Name", "Gender", "Specialties" , "State", "Full Name" ,"Medical School","Graduation Year", "Active Licenses", "Board Actions"]) do |row|
			updated_docDeltaDoctors.each do |updated_doctor|
				row << [updated_doctor.npi, updated_doctor.first_name, updated_doctor.last_name, updated_doctor.gender, updated_doctor.specialties.flatten.join(", "), updated_doctor.state, updated_doctor.full_name, updated_doctor.medical_school, updated_doctor.graduation_year, updated_doctor.active_licenses_in_these_states.flatten.join(", "), updated_doctor.punitive_board_actions_in_these_states.flatten.join(", ")]
			end
		end
	end


end
controller = Controller.new
