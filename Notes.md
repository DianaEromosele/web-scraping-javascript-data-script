doc Delta:

firstName
lastName
gender
state
specialty


doc Info: 

firstName: FirstName
lastName: LastName
gender: Gender
Medical School: MedicalSchoolName
Graduation Year: GraduationYear
Reported City: Locations Location City
Reported State: Locations Location State
Active Licenses (should be an array): Licensures Licensure State 
Specialty: Certifications Certification BoardName
Actions taken Against Them: BoardActions BoardAction State 
Actions taken Against Them URL: BoardActions BoardAction StateURL





As XML:  <Document><Physician><FID>269EA954-4905-41B5-86F4-05648AD5C83A</FID><FullName>Graham Stephens Milam </FullName><FirstName>Graham</FirstName><MiddleName>Stephens</MiddleName><LastName>Milam</LastName><DegreeCode>MD</DegreeCode><Gender>M</Gender><GraduationYear>2008</GraduationYear><MedicalSchoolName>Emory University School of Medicine</MedicalSchoolName></Physician><Locations><Location><City>Anchorage</City><State>Alaska</State></Location></Locations><Licensures><Licensure><State>Alaska</State></Licensure><Licensure><State>Texas</State></Licensure></Licensures></Document>



As XML:  <Document><Physician><FID>5F2DD655-E6C7-48DB-99F9-8955FA3BBA1C</FID><FullName>Graham Timothy Chelius </FullName><FirstName>Graham</FirstName><MiddleName>Timothy</MiddleName><LastName>Chelius</LastName><DegreeCode>MD</DegreeCode><Gender>M</Gender><GraduationYear>2001</GraduationYear><MedicalSchoolName>University of Wisconsin Medical School</MedicalSchoolName></Physician><Locations><Location><City>Waimea</City><State>Hawaii</State></Location></Locations><Licensures><Licensure><State>Alaska</State></Licensure><Licensure><State>Hawaii</State></Licensure></Licensures><Certifications><Certification><BoardName>Family Medicine *</BoardName></Certification></Certifications></Document>


//                 // console.log("DegreeCode: ", $alifHTML.find("DegreeCode").text());
//                 // console.log("Gender: ", $alifHTML.find("Gender").text());
//                 // console.log("Graduation Year: ", $alifHTML.find("GraduationYear").text());
//                 // console.log("Medical School: ", $alifHTML.find("MedicalSchoolName").text());
//                 // console.log("Reported City: ", $alifHTML.find("Locations Location City").text());
//                 // console.log("Reported State: ", $alifHTML.find("Licensures Licensure State").text());
//                 // console.log("Reported Location: ", $alifHTML.find("Locations Location City").text(), $alifHTML.find("Locations Location State").text());
//                 // console.log("Licensed In: ", $alifHTML.find("Licensures Licensure State").text());
//                 // console.log("BoardActions: ", $alifHTML.find("BoardActions").text());
//                 // console.log("BoardAction: ", $alifHTML.find("BoardAction").text());


 
// };



I would keep an array of cells (array of array) in the memory of the JavaScript app and continuously print this array with a formatting function to the CSV file. It is much easier to overwrite the file with your current in-memory data, than editing CSV files. By the way, ActiveX won't work in browsers other than IE. – ssc-hrep3


----- EXTENSION TO USE

The easy way is to just add the extension in google chrome to allow access using CORS.

https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi?hl=en-US

Just enable this extension whenever you want allow access to no 'access-control-allow-origin' header request.


AJAX

asynchorjavascript XML
XMLHttpRequest - native browswer object. sending a request to a server from a client. 
my domain -- my computer/local host
im making a client-side request

twitter.
i was sending it server side to twitters API/server

If I understood it right you are doing an XMLHttpRequest to a different domain than your page is on. So the browser is blocking it as it usually allows a request in the same origin for security reasons. You need to do something different when you want to do a cross-domain request. A tutorial about how to achieve that is Using CORS.

Regular web pages can use the XMLHttpRequest object to send and receive data from remote servers, but they're limited by the same origin policy. Extensions aren't so limited. An extension can talk to remote servers outside of its origin, as long as it first requests cross-origin permissions.

----- 


      


