<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<!-- <!DOCTYPE html>
<html>
<head>
    <title>CCA Page</title>
</head>
<body style="font-family: Arial;">
    <div class="text-center">
    <h2>Welcome to the CCA</h2>
    <p class="lead">Cadre Controlling Authority page.</p>
</div>

</body>
</html> -->
<!DOCTYPE html>
<html>
<head>
    <title>CCA Form</title>

    <!-- Bootstrap 4 (works well with .NET 4.5 projects) -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <style>
        body{
            background:#f5f7fa;
        }
        .form-container{
            background:#fff;
            padding:30px;
            border-radius:8px;
            box-shadow:0 3px 10px rgba(0,0,0,0.1);
            margin-top:30px;
        }
        h5{
            margin-top:20px;
            font-weight:600;
        }
    </style>
</head>

<body>

<div class="container">
<div class="form-container">

<h3 class="mb-4 text-center">CCA Officer Information</h3>

<form id="ccaForm">

<!-- Period -->
<div class="form-row">
<div class="form-group col-md-6">
<label>From</label>
<input type="date" class="form-control" id="periodFrom">
</div>

<div class="form-group col-md-6">
<label>To</label>
<input type="date" class="form-control" id="periodTo">
</div>
</div>

<div class="form-group">
<label>Place / Office of Posting</label>
<input type="text" class="form-control" id="placePosting">
</div>


<h5>Basic Information</h5>

<div class="form-row">

<div class="form-group col-md-6">
<label>Name of the Officer</label>
<input type="text" class="form-control" id="officerName">
</div>

<div class="form-group col-md-6">
<label>Designation</label>
<select class="form-control" id="designation">
<option value="">Select</option>
<option>Manager</option>
<option>Assistant Manager</option>
<option>Officer</option>
<option>Senior Officer</option>
</select>
</div>

</div>


<div class="form-row">

<div class="form-group col-md-6">
<label>Date of Birth</label>
<input type="date" class="form-control" id="dob">
</div>

<div class="form-group col-md-6">
<label>Date of Joining in the Nigam</label>
<input type="date" class="form-control" id="joiningNigam">
</div>

</div>


<div class="form-row">

<div class="form-group col-md-6">
<label>Academic Qualification</label>
<input type="text" class="form-control" id="academicQualification">
</div>

<div class="form-group col-md-6">
<label>Technical Qualification</label>
<input type="text" class="form-control" id="technicalQualification">
</div>

</div>


<div class="form-row">

<div class="form-group col-md-6">
<label>Date of Joining to Present Rank / Post</label>
<input type="date" class="form-control" id="joiningRank">
</div>

<div class="form-group col-md-6">
<label>Date of Joining to Present Station / Office</label>
<input type="date" class="form-control" id="joiningStation">
</div>

</div>


<div class="form-group">
<label>Departmental Exam Passed</label>
<input type="text" class="form-control" id="deptExam">
</div>


<h5>Authorities</h5>

<div class="form-row">

<div class="form-group col-md-4">
<label>Reporting Authority</label>
<input type="text" class="form-control" id="reportingAuthority">
</div>

<div class="form-group col-md-4">
<label>Review Authority</label>
<input type="text" class="form-control" id="reviewAuthority">
</div>

<div class="form-group col-md-4">
<label>Accepting Authority</label>
<input type="text" class="form-control" id="acceptingAuthority">
</div>

</div>


<h5>Other Information</h5>

<div class="form-row">

<div class="form-group col-md-6">
<label>Date of filing property return (Previous Year)</label>
<input type="date" class="form-control" id="propertyReturnDate">
</div>

<div class="form-group col-md-6">
<label>Date of last prescribed medical examination</label>
<input type="date" class="form-control" id="medicalExamDate">
</div>

</div>

<div class="form-group">
<label>Attach Medical Report (Annexure - A)</label>
<input type="file" class="form-control">
</div>


<div class="text-center mt-4">
<button type="submit" class="btn btn-primary btn-lg">
Submit
</button>
</div>

</form>

</div>
</div>


<script>

document.getElementById("ccaForm").addEventListener("submit", function(e){

e.preventDefault();

var formData = {

period:{
from: document.getElementById("periodFrom").value,
to: document.getElementById("periodTo").value
},

placePosting: document.getElementById("placePosting").value,

basicInformation:{
officerName: document.getElementById("officerName").value,
designation: document.getElementById("designation").value,
dob: document.getElementById("dob").value,
academicQualification: document.getElementById("academicQualification").value,
technicalQualification: document.getElementById("technicalQualification").value,
joiningNigam: document.getElementById("joiningNigam").value,
joiningRank: document.getElementById("joiningRank").value,
joiningStation: document.getElementById("joiningStation").value,
deptExam: document.getElementById("deptExam").value
},

authorities:{
reportingAuthority: document.getElementById("reportingAuthority").value,
reviewAuthority: document.getElementById("reviewAuthority").value,
acceptingAuthority: document.getElementById("acceptingAuthority").value
},

other:{
propertyReturnDate: document.getElementById("propertyReturnDate").value,
medicalExamDate: document.getElementById("medicalExamDate").value
}

};

console.log("CCA FORM DATA", formData);

/*
API ready hone par use kar sakte ho

fetch("/api/cca/save", {
method:"POST",
headers:{
"Content-Type":"application/json"
},
body: JSON.stringify(formData)
})

*/

alert("Form Submitted Successfully");

});

</script>


</body>
</html>
```
