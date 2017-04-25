class DocDeltaDoctor 
	attr_accessor :specialties, :medical_school, :graduation_year, :active_licenses_in_these_states, :punitive_board_actions_in_these_states, :full_name, :route_to_server, :docInfo_search_results, :parsed_docInfo_results, :docInfoOrg_doctor_instances
	attr_reader :npi, :first_name, :last_name, :gender, :state
	
	def initialize(args)
		@npi = args[:npi]
		@first_name = args[:first_name]
		@last_name = args[:last_name]
		@full_name = args[:full_name]
		@gender = args[:gender]
		@specialties = args[:specialties] || []
		@state = args[:state]
		@medical_school = @medical_school
		@graduation_year = @graduation_year
		@active_licenses_in_these_states ||= []
		@punitive_board_actions_in_these_states ||= []
		@route_to_server = @route_to_server
		@docInfo_search_results ||= []
		@parsed_docInfo_results ||= []
		@docInfoOrg_doctor_instances ||= []
	
	end 

	def set_route_to_docInfo_server(route)
		@route_to_server = route
	end

	def set_docInfo_search_results(results)
		@docInfo_search_results = results
	end

	def parsedXML_docInfo_results(parsed_XML_results)
		@parsed_docInfo_results = parsed_XML_results
	end

	def set_docInfoOrg_doctor_instances(instances)
		@docInfoOrg_doctor_instances = instances
	end


end

	


