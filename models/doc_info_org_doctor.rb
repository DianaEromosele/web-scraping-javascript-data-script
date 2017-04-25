class DocInfoOrgDoctor 
	attr_reader :first_name, :last_name, :full_name, :gender, :specialties, :reported_states, :medical_school, :graduation_year, :active_licenses_in_these_states, :punitive_board_actions_in_these_states

	def initialize(args)
		@first_name = args[:first_name]
		@last_name = args[:last_name]
		@full_name = args[:full_name]
		@gender = args[:gender]
		@specialties = args[:specialties] || []
		@reported_states = args[:reported_states] || []
		@medical_school = args[:medical_school]
		@graduation_year = args[:graduation_year]
		@active_licenses_in_these_states = args[:active_licenses_in_these_states] || []
		@punitive_board_actions_in_these_states = args[:punitive_board_actions_in_these_states] || []
	end 
end

	


