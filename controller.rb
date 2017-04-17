require_relative 'doc_delta_doctor'

class Controller

	attr_accessor :doc_delta_doctors

	def initialize
		@doc_delta_doctors = doc_delta_doctors || []
	end

	def create_doc_delta_instances()

		# CSV.open()
		CSV.foreach('doc_delta_spreadsheet.csv', headers:true, header_converters: :symbol, encoding:'iso-8859-1:utf-8') do |row|

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
		# puts @doc_delta_doctors[0].last_name
	end

	def make_request_to_docInfo_server

		@doc_delta_doctors.each do |doctor|
			root = 'http://www.docinfo.org/Home/Search?doctorname=' + doctor.first_name + '%20' + doctor.last_name
			uri = URI("")

		if doctor.state 
			


		end 

		


	end 


end


controller = Controller.new
controller.create_doc_delta_instances()
