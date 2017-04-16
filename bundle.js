(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
$(function() {

 if(isAPIAvailable()) {
    $('#doc-delta-spreadsheet').bind('change', handleFileSelect);
  }
});

function isAPIAvailable() {
  // Check for the various File API support.
  if (window.File && window.FileReader && window.FileList && window.Blob) {
    // Great success! All the File APIs are supported.
    return true;
  } else {
    // source: File API availability - http://caniuse.com/#feat=fileapi
    // source: <output> availability - http://html5doctor.com/the-output-element/
    document.writeln('The HTML5 APIsZ used in this form are only available in the following browsers:<br />');
    // 6.0 File API & 13.0 <output>
    document.writeln(' - Google Chrome: 13.0 or later<br />');
    // 3.6 File API & 6.0 <output>
    document.writeln(' - Mozilla Firefox: 6.0 or later<br />');
    // 10.0 File API & 10.0 <output>
    document.writeln(' - Internet Explorer: Not supported (partial support expected in 10.0)<br />');
    // ? File API & 5.1 <output>
    document.writeln(' - Safari: Not supported<br />');
    // ? File API & 9.2 <output>
    document.writeln(' - Opera: Not supported');
    return false;
  }
}

function handleFileSelect(event) {
  let files = event.target.files; // array of files
  let file = files[0] // select a single file

  getNameFromDocDeltaData(file);

}

// NPI, Firstname, Lastname, Gender, Specialty, 

function getNameFromDocDeltaData(file) {
  let reader = new FileReader();
  reader.readAsText(file);

  reader.onload = function(event) {
    let csv = event.target.result;
    let docDelta_data = $.csv.toObjects(csv);

    // console.log(docDelta_data[0])

    docDelta_data.forEach(function(docDeltaDoctor){
      let firstName = docDeltaDoctor["Firstname"];
      let lastName = docDeltaDoctor["Lastname"];

     var statesNames = require('./states.js');
   
      let state = statesNames[docDeltaDoctor["State"]];

      return searchDocInfoData(firstName, lastName, state, docDeltaDoctor);
    });
  };
};

function searchDocInfoData(firstName, lastName, state, docDeltaDoctor) {

  let root = state.split(" ").length == 2 ? 'http://www.docinfo.org/Home/Search?doctorname=' + firstName + '%20' + lastName + '&usstate=' + state.split(" ")[0] + '%20' + state.split(" ")[1] + '&from=0' : 'http://www.docinfo.org/Home/Search?doctorname=' + firstName + '%20' + lastName + '&usstate=' + state + '&from=0' 

  $.ajax({
    url: root,
    type: "POST"    
  }).then(function(docInfoSearchResults) {
    // console.log("DocInfo Search Results: ", docInfoSearchResults);
      let docInfoSearchResultsObject = JSON.parse(docInfoSearchResults);
    console.log("Doctor Objects: ", docInfoSearchResultsObject );
      return docInfoSearchResultsObject;
  }).then(function(docInfoSearchResultsObject) {
    // console.log("hello")
    let eachDoctorInResults = [];
    for (let index = 0; index < docInfoSearchResultsObject["hits"]["hits"].length; index++) {
      let singleDoctorInResults = docInfoSearchResultsObject["hits"]["hits"][index]["_source"]["message"];
      // debugger;
      console.log("Specific Doctor in Results: ", singleDoctorInResults);

      eachDoctorInResults.push(singleDoctorInResults);
    }
    return Promise.all(eachDoctorInResults);
  }).then(function(eachDoctorInResults){
    eachDoctorInResults.forEach(function(doctor, index){
      let doctorXML = $.parseXML(doctor);
      let $doctorXML = $(doctorXML);
      console.log("--------------------------------------------")
      console.log("First Name: ", $doctorXML.find("FirstName").text());
      console.log("Last Name: ", $doctorXML.find("LastName").text());
      console.log("Full Name: ", $doctorXML.find("FullName").text());
    });

  });
};
        
      




















//   $.ajax({
//     url: root,
//     type: "POST"    
//   }).done(function(doctors_data) {
//     // console.log("Doctors Data From DocInfo: ", doctors_data);
//       let doctors = JSON.parse(doctors_data);
//       console.log("Doctors: ", doctors)

//       for (let index = 0; index < doctors.length; index++) {
//         // console.log("hello")
//         let doctor = doctors["hits"]["hits"][index]["_source"]["message"];
//         console.log("Doctor: ", doctor);

//         let doctorXML = $.parseXML(doctor);
//         let $doctorXML = $(doctorXML);
//         // console.log("--------------------------------------------")
//         // console.log("First Name: ", $doctorXML.find("FirstName").text());
//         // console.log("Last Name: ", $doctorXML.find("LastName").text());
//         // console.log("Full Name: ", $doctorXML.find("FullName").text());
//       }
//     });
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




},{"./states.js":2}],2:[function(require,module,exports){
let StateNames = 
{
    "AL": "Alabama",
    "AK": "Alaska",
    "AS": "American Samoa",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "DC": "District Of Columbia",
    "FM": "Federated States Of Micronesia",
    "FL": "Florida",
    "GA": "Georgia",
    "GU": "Guam",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MH": "Marshall Islands",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "MP": "Northern Mariana Islands",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PW": "Palau",
    "PA": "Pennsylvania",
    "PR": "Puerto Rico",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VI": "Virgin Islands",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming"
}

module.exports = StateNames



},{}]},{},[1]);