require 'uri'
require 'net/http'
require 'json'
require_relative 'doc_delta_doctor'

class Controller

	attr_accessor :doc_delta_doctors

	def initialize
		@doc_delta_doctors = doc_delta_doctors || []

		self.create_doc_delta_instances
	end

	def create_doc_delta_instances

		# CSV.open()
		CSV.foreach('docDelta_mock_sheet.csv', headers:true, header_converters: :symbol, encoding:'iso-8859-1:utf-8') do |row|

			npi = row[0]
			first_name = row[1]
			last_name = row[2]
			gender = row[3]
			specialty = row[4]
			medical_school = row[6]
			graduation_year = row[7]
			active_licenses = row[8]
			punitive_actions = row[9]

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
		    'DC' => 'District of Columbia',
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
		
		@doc_delta_doctors << DocDeltaDoctor.new(npi, first_name, last_name, gender, specialty, state, medical_school, graduation_year, active_licenses, punitive_actions)
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
						root = root + word + '&max=30&from=0'
					end
				end
			else
				root = root + '&max=30&from=0'
			end 

			self.make_request_to_docInfoOrg_server(root, doc_delta_doctor)

		end
	end 


	def make_request_to_docInfoOrg_server(root, doc_delta_doctor)

			uri = URI(root)
			https = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)

			docInfoOrg_search_results = https.request(request).body

			# turn to Hash
			docInfoOrg_search_results = eval(docInfoOrg_search_results)


			self.parse_docInfoOrg_Results(docInfoOrg_search_results, doc_delta_doctor )
	end

	def parse_docInfoOrg_Results(docInfoOrg_search_results, doc_delta_doctor)

		docInfoOrg_doctors  = [];

		docInfoOrg_search_results[:hits][:hits].each_with_index do |docInfoOrg_doctor, index|
			puts docInfoOrg_doctor[:_source][:message]
			docInfoOrg_doctors << docInfoOrg_doctor[:_source][:message]
		end

	end




end


controller = Controller.new

