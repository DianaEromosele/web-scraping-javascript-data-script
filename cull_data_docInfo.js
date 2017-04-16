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
  getDocInfoFromDocDeltaExcelSheet(file);
};


function getDocInfoFromDocDeltaExcelSheet(file) {
  let reader = new FileReader();
  reader.readAsText(file);

  reader.onload = function(event) {
    let csv = event.target.result;
    let docDelta_data = $.csv.toObjects(csv);

    docDelta_data.forEach(function(docDeltaDoctor){
      let firstName = docDeltaDoctor["Firstname"];
      let lastName = docDeltaDoctor["Lastname"];
      let state = getFullStateName(docDeltaDoctor["State"]);

      return configureRootPath(firstName, lastName, state, docDeltaDoctor);
    });
  };
};

function getFullStateName(state) {
  let states = 
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
          "WY": "Wyoming",
          "NULL": undefined
    }
  return states[state]
}

function configureRootPath(firstName, lastName, state, docDeltaDoctor) {
 let root = 'http://www.docinfo.org/Home/Search?doctorname=' + firstName + '%20' + lastName
  if (state) {
    root = root + '&usstate=';
    for (let index = 0; index < state.split(" ").length; index++) {
      if (state.split(" ")[index + 1]) {
        root = root + state.split(" ")[index] + '%20'
      } else {
        root = root + state.split(" ")[index] + '&max=30&from=0'
      }
    };
  } else {
    root = root + '&max=30&from=0';
  };

  return makeXMLHttpRequest(root, docDeltaDoctor)
}

function makeXMLHttpRequest(root, docDeltaDoctor) {
  $.ajax({
    url: root,
    type: "POST"    
  }).then(function(docInfoSearchResults) {
    return turnDocInfoResultsIntoObject(docInfoSearchResults, docDeltaDoctor);
  });
}

function turnDocInfoResultsIntoObject(docInfoSearchResults, docDeltaDoctor) {
  let docInfoSearchResultsObject = JSON.parse(docInfoSearchResults);
  return parseEachDoctorinResults(docInfoSearchResultsObject, docDeltaDoctor)
}

function parseEachDoctorinResults(docInfoSearchResultsObject, docDeltaDoctor) {
  let eachDoctorInResultsAsXML = [];
  for (let index = 0; index < docInfoSearchResultsObject["hits"]["hits"].length; index++) {
    let singleDoctorInResults = docInfoSearchResultsObject["hits"]["hits"][index]["_source"]["message"];
    eachDoctorInResultsAsXML.push(singleDoctorInResults);
  }
  return parseXMLDocData(eachDoctorInResultsAsXML, docDeltaDoctor);
}

function parseXMLDocData(eachDoctorInResultsAsXML, docDeltaDoctor) {
  console.log("DocDelta Doctor: ", docDeltaDoctor);
  eachDoctorInResultsAsXML.forEach(function(doctorInfoDoctor, index){
    let doctorInfoDoctorXML = $.parseXML(doctorInfoDoctor);
    let $doctorInfoDoctorXML = $(doctorInfoDoctorXML);
    console.log("--------------------------------------------");
    console.log("Full Name: ", $doctorInfoDoctorXML.find("FullName").text());
  });
};
     











   
      


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



