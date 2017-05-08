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


	def configure_route_to_docInfo_server
		route = 'http://www.docinfo.org/Home/Search?doctorname=' + self.first_name + '%20' + self.last_name
			if self.state && self.state != nil.to_s
				route = route + '&usstate='
				self.state.split(" ").each_with_index do |word, slot|
					if self.state.split(" ")[slot + 1]
						route = route + word + '%20'
					else 
						route = route + word + '&from=0'
					end
				end
			else
				route = route + '&from=0'
			end 
			self.set_route_to_docInfo_server(route)
	end

end

	


