class DocDeltaDoctor 
	attr_accessor :specialties, :medical_school, :graduation_year, :active_licenses_in_these_states, :punitive_board_actions_in_these_states, :full_name
	attr_reader :npi, :first_name, :last_name, :gender, :state
	
	def initialize(args)
		@npi = args[:npi]
		@first_name = args[:first_name]
		@last_name = args[:last_name]
		@full_name = args[:full_name]
		@gender = args[:gender]
		@specialties = args[:specialties] || []
		@state = args[:state]
		@medical_school = args[:medical_school]
		@graduation_year = args[:graduation_year]
		@active_licenses_in_these_states = args[:active_licenses_in_these_states] || []
		@punitive_board_actions_in_these_states = args[:punitive_board_actions_in_these_states] || []
	end 
end

	


