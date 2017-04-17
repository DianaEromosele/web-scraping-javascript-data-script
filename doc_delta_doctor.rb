require "csv"

class DocDeltaDoctor 
	attr_accessor :state, :specialty, :medical_school, :graduation_year, :active_licenses, :punitive_actions
	attr_reader :npi, :first_name, :last_name, :gender
	
	def initialize(npi, first_name, last_name, gender, specialty, state, medical_school, graduation_year, active_licenses, punitive_actions)
		@npi = npi
		@first_name = first_name
		@last_name = last_name
		@gender = gender
		@specialty = specialty
		@state = state
		@medical_school = medical_school
		@graduation_year = graduation_year
		@active_licenses = active_licenses
		@punitive_actions = punitive_actions
	end 

end

	


