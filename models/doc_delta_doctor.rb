class DocDeltaDoctor
	attr_accessor :specialties, :medical_school, :graduation_year, :active_licenses_in_these_states, :punitive_board_actions_in_these_states, :full_name, :route_to_server, :docInfoOrg_search_results, :docInfoOrg_results_as_XML, :docInfoOrg_doctor_objects
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
		@docInfoOrg_search_results ||= []
		@docInfoOrg_results_as_XML ||= []
		@docInfoOrg_doctor_objects ||= []

	end

	def create_HTTP_route_to_docInfo_server
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
		@route_to_server = route
	end
end
