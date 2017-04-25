This is an object-oriented Ruby script, built by Diana Ozemebhoya Eromosele, a software developer-in-residence at Newark Venture Funds, and commissioned by DocDelta -- a database powerhouse that allows heathcare providers to find top talent with ease. 

The script takes in an input CSV file provided by DocDelta that contains data about individual doctors in their database.

The script makes informal requests to the 'www.docinfo.org' server, to find an individual doctor's record in their online database. If the record is found, the script pulls down additional data about the doctor, including the doctor's full name, medical school, graduation year, states that the doctor has an active medical license in, and states in which a medical board action was taken against the doctor. 

The script generates two output CSV files: 1) output_data_all_doctors.csv will list **all** of the doctors found in the intial CSV file, with any updated data from www.docInfo.org included; 2) output_data_updated_doctors_only.csv will list only those doctors from the initial CSV file whose data was updated and enhanced by data from www.docInfo.org

The developers at DocDelta can then take either of the two CSV files generated and funnel the data back into their databases. 

Instructions to Run the Script:

1) In your command line, type:
ruby controller.rb name-of-csv-file.csv

2) The 2 CSV files that will be generated are named:

**a)** output_data_all_doctors.csv
**b)** output_data_updated_doctors_only.csv

Keep in Mind: 

1) Finding a doctor's record in the www.docinfo.org database would be a lot easier if the database contained the doctor's NPI (a National Provider Identifier). It's the non-changing identifier given to all healthcare practitioners for the length of their careers. 

The input CSV file provided by DocDelta has each doctor's NPI, however the www.docinfo.org database does not. The script currently searches for doctors and confirms a match by comparing the following data: first name, last name, gender and specialties. The comparison is not default-proof. An NPI comparison would be ideal and nearly perfect. Modifying the script to make a comparison using a doctor's NPI is simple and easy to do.

2) Pulling data from www.docinfo.org is not exactly within the terms of use of their site, as stated below in an excerpt pulled from the site's "Terms of Use":

"You will not use any robot, spider, site search/retrieval application, or other manual or automatic device or process to retrieve, index, “data mine”, or in any way reproduce or circumvent the navigational structure or presentation of the Service or its contents."


