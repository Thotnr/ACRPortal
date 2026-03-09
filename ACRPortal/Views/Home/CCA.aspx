<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>

#ccaTable{
font-size:14px;
}

#ccaTable th{
cursor:pointer;
font-weight:600;
}

.status-badge{
padding:4px 10px;
border-radius:15px;
font-size:12px;
}

.status-pending{
background:#fff3cd;
color:#856404;
}

.status-completed{
background:#d4edda;
color:#155724;
}

/* MODAL FIX */

.modal-body{
max-height:80vh;
overflow-y:auto;
}

.modal-dialog{
margin-top:30px;
}

.ccaFormClass{
padding:0 20px 20px 20px;
}

</style>

<div class="container-fluid">

<!-- HEADER -->

<div class="d-flex justify-content-between align-items-center mb-4">

<h3>CCA Officer Appraisal</h3>

<button class="btn btn-primary" onclick="openAppraisalModal()">
Raise Appraisal
</button>

</div>

<!-- SEARCH -->

<div class="row mb-3">

<div class="col-md-4">

<input type="text"
class="form-control"
placeholder="Search officer..."
onkeyup="searchTable(this.value)">

</div>

</div>

<!-- TABLE -->

<div class="table-responsive">

<table class="table table-bordered table-hover" id="ccaTable">

<thead class="thead-dark">

<tr>

<th onclick="sortTable(0)">Officer Name</th>
<th onclick="sortTable(1)">Designation</th>
<th onclick="sortTable(2)">Posting</th>
<th onclick="sortTable(3)">From</th>
<th onclick="sortTable(4)">To</th>
<th>Status</th>
<th>Action</th>

</tr>

</thead>

<tbody id="ccaTableBody">

<tr>

<td>Rahul Sharma</td>
<td>Manager</td>
<td>Gurgaon</td>
<td>01-04-2024</td>
<td>31-03-2025</td>

<td>
<span class="status-badge status-pending">
Pending
</span>
</td>

<td>
<button class="btn btn-sm btn-info" onclick="openAppraisalModal()">
View
</button>
</td>

</tr>

</tbody>

</table>

</div>

</div>

<!-- MODAL -->

<div class="modal fade" id="appraisalModal" tabindex="-1">

<div class="modal-dialog modal-xl">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title">
CCA Officer Information
</h5>

<button type="button" class="close" onclick="closeModal()">
<span>&times;</span>
</button>

</div>

<div class="modal-body">

<form id="ccaForm" class="ccaFormClass">

<h5>Period Details</h5>

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

<h5 class="mt-3">Basic Information</h5>

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

<label>Departmental Exam Passed (Specify)</label>

<input type="text" class="form-control" id="deptExam">

</div>

<h5 class="mt-3">Authorities</h5>

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

<h5 class="mt-3">Other Information</h5>

<div class="form-row">

<div class="form-group col-md-6">
<label>Date of filing the property return</label>
<input type="date" class="form-control" id="propertyReturnDate">
</div>

<div class="form-group col-md-6">
<label>Date of last medical examination</label>
<input type="date" class="form-control" id="medicalExamDate">
</div>

</div>

<div class="form-group">

<label>Attach Medical Report (Annexure A)</label>

<input type="file" class="form-control" id="medicalReport">

</div>

<div class="text-center mt-4">

<button type="submit" class="btn btn-success">
Submit Appraisal
</button>

</div>

</form>

</div>

</div>

</div>

</div>

<script>

$(document).ready(function(){
    var token = localStorage.getItem("token");
    if(!token){
        window.location="/Login/UserAuth";
    }else {
        loadCurrentUser(token);
    }
});

function loadCurrentUser(token){

    if(!token){
    window.location = "/Login/UserAuth";
    return;
    }

    $.ajax({

    url: "/api/auth/me",
    method: "GET",

    headers:{
    "Authorization":"Bearer " + token
    },

    success:function(res){

    if(res.Success){

    var user = res.Data;

    /* store user data */
    localStorage.setItem("displayName", user.DisplayName);
    localStorage.setItem("role", user.SystemRole);

    /* bind if element exists */
    if($("#displayName").length){
    $("#displayName").text(user.DisplayName);
    }

    if($("#userRole").length){
    $("#userRole").text(user.SystemRole);
    }

    }
    else{

    window.location="/Login/UserAuth";

    }

    },

    error:function(xhr){

    if(xhr.status === 401 || xhr.status === 404){

    localStorage.clear();
    window.location="/Login/UserAuth";

    }
    else{

    alert("Failed to load user session");

    }

    }

    });

    }

function openAppraisalModal(){
$('#appraisalModal').modal('show');
}

function closeModal(){
$('#appraisalModal').modal('hide');
}

function searchTable(value){

value=value.toLowerCase();

var rows=document.querySelectorAll("#ccaTable tbody tr");

rows.forEach(function(row){

var text=row.innerText.toLowerCase();

row.style.display=text.includes(value)?"":"none";

});

}

function sortTable(col){

var table=document.getElementById("ccaTable");
var switching=true;

while(switching){

switching=false;

var rows=table.rows;

for(var i=1;i<rows.length-1;i++){

var shouldSwitch=false;

var x=rows[i].getElementsByTagName("TD")[col];
var y=rows[i+1].getElementsByTagName("TD")[col];

if(x.innerHTML.toLowerCase()>y.innerHTML.toLowerCase()){

shouldSwitch=true;
break;

}

}

if(shouldSwitch){

rows[i].parentNode.insertBefore(rows[i+1],rows[i]);
switching=true;

}

}

}

document.getElementById("ccaForm")
.addEventListener("submit",function(e){

e.preventDefault();

var formData={

periodFrom:document.getElementById("periodFrom").value,
periodTo:document.getElementById("periodTo").value,
placePosting:document.getElementById("placePosting").value,

officerName:document.getElementById("officerName").value,
designation:document.getElementById("designation").value,
dob:document.getElementById("dob").value,

academicQualification:document.getElementById("academicQualification").value,
technicalQualification:document.getElementById("technicalQualification").value,

joiningNigam:document.getElementById("joiningNigam").value,
joiningRank:document.getElementById("joiningRank").value,
joiningStation:document.getElementById("joiningStation").value,

deptExam:document.getElementById("deptExam").value,

reportingAuthority:document.getElementById("reportingAuthority").value,
reviewAuthority:document.getElementById("reviewAuthority").value,
acceptingAuthority:document.getElementById("acceptingAuthority").value,

propertyReturnDate:document.getElementById("propertyReturnDate").value,
medicalExamDate:document.getElementById("medicalExamDate").value,

medicalReport:document.getElementById("medicalReport").files[0]

};

console.log("CCA Form Data:",formData);

alert("Appraisal Submitted");

$('#appraisalModal').modal('hide');

});

</script>

</asp:Content>