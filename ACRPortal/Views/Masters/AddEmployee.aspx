<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet"/>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style>

.required-star{
color:red;
margin-left:3px;
font-weight:bold;
}

.master-page{
--master-ink:#172033;
--master-muted:#667085;
--master-line:rgba(15,23,42,0.08);
--master-card:rgba(255,255,255,0.94);
--master-shadow:0 24px 50px rgba(16,37,66,0.12);
position:relative;
padding:8px 0 24px;
color:var(--master-ink);
}

.master-page:before,
.master-page:after{
content:"";
position:absolute;
border-radius:50%;
filter:blur(12px);
opacity:.55;
pointer-events:none;
}

.master-page:before{
width:220px;
height:220px;
top:-10px;
right:8%;
background:rgba(6,182,212,0.16);
}

.master-page:after{
width:240px;
height:240px;
left:2%;
bottom:5%;
background:rgba(29,78,216,0.12);
}

.master-hero{
position:relative;
overflow:hidden;
background:radial-gradient(circle at top right, rgba(255,255,255,0.18), transparent 32%),radial-gradient(circle at bottom left, rgba(6,182,212,0.2), transparent 28%),linear-gradient(135deg, #102542 0%, #1d4ed8 55%, #06b6d4 100%);
border-radius:28px;
padding:30px 32px;
margin-bottom:22px;
box-shadow:0 28px 50px rgba(29,78,216,0.2);
color:#fff;
}

.master-kicker{
display:inline-flex;
align-items:center;
gap:8px;
padding:8px 14px;
border-radius:999px;
background:rgba(255,255,255,0.12);
font-size:12px;
font-weight:700;
letter-spacing:.08em;
text-transform:uppercase;
}

.master-title{
margin:18px 0 10px;
font-size:34px;
font-weight:700;
line-height:1.15;
}

.master-subtitle{
max-width:720px;
margin:0;
font-size:15px;
line-height:1.7;
color:rgba(255,255,255,0.84);
}

.master-panel{
height:100%;
padding:22px;
border-radius:22px;
background:rgba(8,15,31,0.22);
backdrop-filter:blur(10px);
border:1px solid rgba(255,255,255,0.16);
color:#fff;
}

.master-panel-label{
font-size:12px;
font-weight:700;
letter-spacing:.08em;
text-transform:uppercase;
color:rgba(255,255,255,0.72);
}

.master-panel-value{
margin:10px 0 8px;
font-size:34px;
font-weight:700;
}

.master-panel-copy{
margin:0;
font-size:14px;
line-height:1.6;
color:rgba(255,255,255,0.82);
}

.page-card{
background:var(--master-card);
border:1px solid rgba(255,255,255,0.76);
border-radius:24px;
padding:22px;
box-shadow:var(--master-shadow);
}

.page-title{
font-weight:700;
font-size:22px;
margin:0;
}

.page-subtitle{
margin:6px 0 0;
font-size:14px;
color:var(--master-muted);
}

.table thead th{
background:linear-gradient(135deg, #15314b, #2346a8);
color:#fff;
cursor:pointer;
font-size:12px;
font-weight:700;
letter-spacing:.05em;
text-transform:uppercase;
border-top:0;
border-bottom:0;
}

.table-hover tbody tr:hover{
background:#f6f9ff;
}

.table td{
vertical-align:middle;
padding:16px 14px;
border-color:rgba(15,23,42,0.06);
}

.action-btn{
border:none;
background:rgba(37,99,235,0.08);
color:#1d4ed8;
cursor:pointer;
width:38px;
height:38px;
border-radius:12px;
}

.select2-container--default .select2-selection--single .select2-selection__rendered{
line-height: 24px;
}

.d-flex.justify-content-between.align-items-center.mb-2{
gap:12px;
flex-wrap:wrap;
}

.form-control,
select,
.select2-container .select2-selection--single{
min-height:46px;
border-radius:14px !important;
border:1px solid var(--master-line) !important;
background:#fff !important;
}

.form-control:focus,
select:focus{
border-color:#93c5fd;
box-shadow:0 0 0 .2rem rgba(37,99,235,.12);
}

.pagination .page-link{
border-radius:10px;
margin:0 2px;
border:1px solid rgba(15,23,42,0.08);
color:#1d4ed8;
}

.pagination .page-item.active .page-link{
background:linear-gradient(135deg, #2563eb, #0ea5e9);
border-color:transparent;
}

.modal-content{
border:0;
border-radius:24px;
overflow:hidden;
box-shadow:0 28px 60px rgba(15,23,42,0.18);
}

.modal-header{
background:linear-gradient(135deg, #15314b, #2563eb);
color:#fff;
border-bottom:0;
padding:18px 24px;
}

.modal-body{
padding:24px;
background:#f8fbff;
}

.btn{
border-radius:14px;
font-weight:700;
padding:10px 16px;
}

</style>

<div class="container-fluid master-page">

<div class="master-hero">
<div class="row align-items-center">
<div class="col-lg-8">
<span class="master-kicker"><i class="fa fa-user-plus"></i> Masters</span>
<h2 class="master-title">Manage employee records from a cleaner and more structured admin workspace.</h2>
<p class="master-subtitle">Filter employees across the full location hierarchy, review records faster, and keep employee creation or updates in a polished form flow.</p>
</div>
<div class="col-lg-4">
<div class="master-panel">
<div class="master-panel-label">Master Module</div>
<div class="master-panel-value">Employee</div>
<p class="master-panel-copy">Select2, cascading location filters, and employee save behavior remain intact while the UI now matches the refreshed portal pattern.</p>
</div>
</div>
</div>
</div>

<div class="page-card">

<div class="d-flex justify-content-between mb-3">

<div>
<div class="page-title">Employee Management</div>
<div class="page-subtitle">Maintain employee master records, reporting managers, and role mappings in one place.</div>
</div>

<button class="btn btn-primary btn-sm" onclick="openEmployeeModal()">
<i class="fa fa-plus"></i> Add Employee
</button>

</div>

<div class="row mb-3">

<div class="col-md-2 pr-0">
<select id="filterDesignation" class="form-control" onchange="applyFilters()">
<option value="">Designation</option>
</select>
</div>

<div class="col-md-2 pr-0">
<select id="filterZone" class="form-control" onchange="onFilterZoneChange()">
<option value="">Zone</option>
</select>
</div>

<div class="col-md-2 pr-0">
<select id="filterCircle" class="form-control" onchange="onFilterCircleChange()">
<option value="">Circle</option>
</select>
</div>

<div class="col-md-2 pr-0">
<select id="filterDivision" class="form-control" onchange="onFilterDivisionChange()">
<option value="">Division</option>
</select>
</div>

<div class="col-md-2 pr-0">
<select id="filterSubDivision" class="form-control" onchange="applyFilters()">
<option value="">SubDivision</option>
</select>
</div>

<div class="col-md-2">
<input type="text" class="form-control" placeholder="Search Employee" onkeyup="searchTable(this.value)">
</div>

</div>

<!-- <div class="row mb-3">

<div class="col-md-4">
<input type="text" class="form-control" placeholder="Search Employee" onkeyup="searchTable(this.value)">
</div>

</div> -->

<div class="table-responsive">

<div class="d-flex justify-content-between align-items-center mb-2">

<div>
Show
<select id="pageSizeSelect"
class="form-control form-control-sm d-inline-block"
style="width:80px;"
onchange="changePageSize()">

<option value="5">5</option>
<option value="10" selected>10</option>
<option value="25">25</option>
<option value="50">50</option>

</select>
entries
</div>

<div id="tableInfo"></div>

</div>

<table class="table table-bordered table-hover">

<thead>

<tr>

<!-- <th onclick="sortTable('DisplayName')">Name</th> -->
<th onclick="sortTable('LoginId')">Login ID (HRMS)</th>
<th>Email</th>
<th>Phone</th>
<th onclick="sortTable('Dsg')">Designation</th>
<th>Reporting Manager</th>
<th width="90">Action</th>

</tr>

</thead>

<tbody id="employeeTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>


<!-- EMPLOYEE MODAL -->

<div class="modal fade" id="employeeModal">

<div class="modal-dialog modal-lg">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Employee</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<p style="font-size:12px;color:#666;">
Fields marked with <span class="required-star">*</span> are required
</p>
<form id="employeeForm">

<h6 class="mb-2"><b>Basic Details</b></h6>

<div class="row">

<div class="col-md-6">
<label>Name <span class="required-star">*</span></label>
<input type="text" id="displayName" class="form-control" required>
</div>

<div class="col-md-6">
<label>Login ID (HRMS) <span class="required-star">*</span></label>
<input type="text" id="loginId" class="form-control" required>
</div>

<!-- <div class="col-md-6 mt-2">
<label>Password</label>
<input type="password" id="password" class="form-control">
</div> -->

<div class="col-md-6 mt-2">
<label>Email <span class="required-star">*</span></label>
<input type="email" id="email" class="form-control" required>
</div>

<div class="col-md-6 mt-2">
<label>Phone <span class="required-star">*</span></label>
<input type="text" id="phone" class="form-control" required>
</div>

<div class="col-md-6 mt-2">
<label>Designation <span class="required-star">*</span></label>
<select id="dsgId" class="form-control" required></select>
</div>

<div class="col-md-6 mt-2">
<label>Type <span class="required-star">*</span></label>
<select id="systemRole" class="form-control" required>
    <option value="">Select Type</option>
    <option value="EMPLOYEE">EMPLOYEE</option>
    <option value="CCA">CCA</option>
</select>
</div>

<div class="col-md-6 mt-2">
<label>Reporting Manager</label>
<select id="reportingManagerId" class="form-control"></select>
</div>

</div>

<hr>

<h6 class="mb-2"><b>Location Details</b></h6>

<div class="row">

<div class="col-md-4">
<label>State</label>
<select id="stateId" class="form-control" onchange="loadZones()"></select>
</div>

<div class="col-md-4">
<label>Zone</label>
<select id="zoneId" class="form-control" onchange="loadCircles()"></select>
</div>

<div class="col-md-4">
<label>Circle</label>
<select id="circleId" class="form-control" onchange="loadDivisions()"></select>
</div>

<div class="col-md-6 mt-2">
<label>Division</label>
<select id="divisionId" class="form-control" onchange="loadSubDivisions()"></select>
</div>

<div class="col-md-6 mt-2">
<label>SubDivision</label>
<select id="subDivisionId" class="form-control"></select>
</div>

</div>

<div class="text-center mt-3">
<button type="submit" class="btn btn-success btn-sm">Save</button>
</div>

</form>

</div>

</div>

</div>

</div>



<script>
var BASE_URL = '<%= Url.Content("~/") %>';
var employees=[];
var filteredEmployees=[];
var designations=[];
var token=null;

var pageSize=10;
var currentPage=1;

var sortAsc=true;
var currentSortColumn="";

var isEditMode=false;
var editUserId=null;

$(document).ready(function(){

token=localStorage.getItem("token");

if(!token){
window.location = BASE_URL + "Login/UserAuth";
return;
}

// loadEmployees();
// loadDesignations();
loadDesignations();
setTimeout(loadEmployees,200);
loadStates();

loadFilterZones();
loadFilterDesignations();

initDropdowns();

});

function initDropdowns(){

$("#dsgId").select2({width:'100%'});
$("#stateId").select2({width:'100%'});
$("#zoneId").select2({width:'100%'});
$("#circleId").select2({width:'100%'});
$("#divisionId").select2({width:'100%'});
$("#subDivisionId").select2({width:'100%'});
$("#reportingManagerId").select2({width:'100%'});

}

function loadReportingManagers(excludeLoginId){

$("#reportingManagerId").html('<option value="">Select Reporting Manager</option>');

employees.forEach(function(e){

if(excludeLoginId && e.LoginId === excludeLoginId) return;

$("#reportingManagerId").append(
`<option value="${e.LoginId}">${e.DisplayName} (${e.LoginId})</option>`
);

});

}

function loadFilterZones(){

$("#filterZone").html('<option value="">Zone</option>');

$.ajax({

url: BASE_URL + "api/admin/masters/zones",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Zones.forEach(function(z){

$("#filterZone").append(
`<option value="${z.ZoneId}">${z.ZoneName}</option>`
);

});

}

}

});

}

function loadFilterDesignations(){

$("#filterDesignation").html('<option value="">Designation</option>');

$.ajax({

url: BASE_URL + "api/admin/masters/designations?activeOnly=true",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Designations.forEach(function(d){

$("#filterDesignation").append(
`<option value="${d.DsgId}">${d.DsgDesc}</option>`
);

});

}

}

});

}

function loadFilterCircles(zoneId){

$("#filterCircle").html('<option value="">Circle</option>');

if(!zoneId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/circles?zoneId="+zoneId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Circles.forEach(function(c){

$("#filterCircle").append(
`<option value="${c.CircleId}">${c.Circle}</option>`
);

});

}

}

});

}

/* LOAD EMPLOYEES (example endpoint assumed) */

function loadEmployees(){

var zoneId=$("#filterZone").val();
var dsgId=$("#filterDesignation").val();
var divisionId=$("#filterDivision").val();

var url= BASE_URL + "api/admin/users";

if(zoneId) url+="&zoneId="+zoneId;
if(dsgId) url+="&dsgId="+dsgId;
if(divisionId) url+="&divisionId="+divisionId;

$.ajax({

url:url,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){
debugger
employees=res.Data.Users || [];
filteredEmployees=[...employees];

currentPage=1;
renderTable();

}

}

});

}

function getDesignationName(dsgId){

var d=designations.find(x=>x.DsgId==dsgId);

return d ? d.Dsg : dsgId;

}

/* TABLE */

function renderTable(){

var body=$("#employeeTableBody");
body.empty();

var total=filteredEmployees.length;

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredEmployees.slice(start,end);

pageData.forEach(function(e){
// var statusIcon = e.UserStatus === "ACTIVE"
// ? '<i class="fa-solid fa-toggle-on text-success"></i>'
// : '<i class="fa-solid fa-toggle-off text-danger"></i>';
var dsgName=getDesignationName(e.DsgId);

body.append(`

<tr>
<td>${e.LoginId}</td>
<td>${e.Email || ""}</td>
<td>${e.Phone || ""}</td>
<td>${dsgName}</td>
<td>${e.ManagerId || "-"}</td>

<td class="text-center">

<button class="action-btn"
onclick="editEmployee('${e.UserId}')">
<i class="fa fa-pen"></i>
</button>

<button class="action-btn"
onclick="confirmStatusChange('${e.UserId}','${e.UserStatus}')">

${e.UserStatus==="ACTIVE"
? '<i class="fa-solid fa-toggle-on text-success"></i>'
: '<i class="fa-solid fa-toggle-off text-danger"></i>'}

</button>

</td>

</tr>

`);

});

updateTableInfo(start,end,total);
renderPagination();

}

function updateTableInfo(start,end,total){

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}

/* SEARCH */

function searchTable(val){

val=val.toLowerCase();

filteredEmployees=employees.filter(function(e){

return (
(e.DisplayName||"").toLowerCase().includes(val) ||
(e.LoginId||"").toLowerCase().includes(val)
);

});

currentPage=1;
renderTable();

}


/* SORT */

function sortTable(col){

sortAsc=currentSortColumn===col ? !sortAsc : true;
currentSortColumn=col;

filteredEmployees.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;
return 0;

});

renderTable();

}


/* PAGINATION */

function renderPagination(){

var totalPages=Math.ceil(filteredEmployees.length/pageSize);

if(totalPages===0){
$("#pagination").html("");
return;
}

var html="";

/* PREV */

html+=`<li class="page-item ${currentPage==1?'disabled':''}">
<a class="page-link" href="javascript:void(0)"
onclick="gotoPage(${currentPage-1})">Prev</a>
</li>`;

/* PAGE NUMBERS */

for(var i=1;i<=totalPages;i++){

html+=`<li class="page-item ${i==currentPage?'active':''}">
<a class="page-link" href="javascript:void(0)"
onclick="gotoPage(${i})">${i}</a>
</li>`;

}

/* NEXT */

html+=`<li class="page-item ${currentPage==totalPages?'disabled':''}">
<a class="page-link" href="javascript:void(0)"
onclick="gotoPage(${currentPage+1})">Next</a>
</li>`;

$("#pagination").html(html);

}

function gotoPage(p){

var totalPages=Math.ceil(filteredEmployees.length/pageSize);

if(p<1 || p>totalPages) return;

currentPage=p;
renderTable();

}


/* MODAL */
function openEmployeeModal(){

isEditMode=false;
$("#loginId").prop("disabled", false);
$("#modalTitle").text("Add Employee");

$("#employeeForm")[0].reset();

$("#circleId").html('<option value="">Select Circle</option>');
$("#divisionId").html('<option value="">Select Division</option>');
$("#subDivisionId").html('<option value="">Select SubDivision</option>');

/* reset select2 dropdowns */

$("#dsgId").val("").trigger("change");
$("#stateId").val("").trigger("change");
$("#zoneId").val("").trigger("change");
$("#circleId").val("").trigger("change");
$("#divisionId").val("").trigger("change");
$("#subDivisionId").val("").trigger("change");
$("#systemRole").val("").trigger("change");

/* load managers */

loadReportingManagers();

/* reset manager dropdown */

$("#reportingManagerId").val("").trigger("change");

$("#employeeModal").modal("show");

}
function closeModal(){
$("#employeeModal").modal("hide");
}


/* DESIGNATION DROPDOWN */
function loadDesignations(){

$("#dsgId").html('<option value="">Select Designation</option>');

$.ajax({

url: BASE_URL + "api/admin/masters/designations?activeOnly=true",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

designations=res.Data.Designations || [];

designations.forEach(function(d){

$("#dsgId").append(
`<option value="${d.DsgId}">${d.Dsg}</option>`
);

});

}

}

});

}

/* CREATE / UPDATE */

$("#employeeForm").submit(function(e){

e.preventDefault();

var body={

DisplayName:$("#displayName").val(),
LoginId:$("#loginId").val(),
// Password:$("#password").val(),
SystemRole: $("#systemRole").val(), // || "EMPLOYEE",
Email:$("#email").val(),
Phone:$("#phone").val(),
DsgId:$("#dsgId").val(),
StateId:$("#stateId").val(),
ZoneId:$("#zoneId").val(),
CircleId:$("#circleId").val(),
DivisionId:$("#divisionId").val(),
SubDivisionId:$("#subDivisionId").val(),
ManagerId:$("#reportingManagerId").val()
};

if(!body.SystemRole){
    alert("Type is required");
    return;
}

if(body.SystemRole !== "CCA" && body.SystemRole !== "EMPLOYEE"){
    alert("Invalid Type selected");
    return;
}

if(!isEditMode){

$.ajax({

url: BASE_URL + "api/user/createuser",
method:"POST",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify(body),

success:function(res){

if(res.Success){

alert("Employee created");
closeModal();
loadEmployees();

}else{

alert(res.Message);

}

},

error:function(xhr){

alert(xhr.responseJSON?.Message || "Error");

}

});

}


/* UPDATE */

else{

$.ajax({

url: BASE_URL + "api/admin/users/"+editUserId,
method:"PATCH",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify(body),

success:function(res){

if(res.Success){

alert("Employee updated");
closeModal();
loadEmployees();

}else{

alert(res.Message);

}

}

});

}

});

function loadStates(){

$.ajax({

url: BASE_URL + "api/admin/masters/states",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

$("#stateId").html('<option value="">Select State</option>');

res.Data.States.forEach(function(s){

$("#stateId").append(
`<option value="${s.StateId}">${s.StateName}</option>`
);

});

}

}

});

}

function loadZones(){

var stateId=$("#stateId").val();

$("#zoneId").html('<option value="">Select Zone</option>');
$("#circleId").html('<option value="">Select Circle</option>');
$("#divisionId").html('<option value="">Select Division</option>');
$("#subDivisionId").html('<option value="">Select SubDivision</option>');

if(!stateId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/zones?stateId="+stateId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Zones.forEach(function(z){

$("#zoneId").append(
`<option value="${z.ZoneId}">${z.ZoneName}</option>`
);

});

}

}

});

}

function loadCircles(){
var zoneId=$("#zoneId").val();

$("#circleId").html('<option value="">Select Circle</option>');
$("#divisionId").html('<option value="">Select Division</option>');
$("#subDivisionId").html('<option value="">Select SubDivision</option>');

if(!zoneId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/circles?zoneId="+zoneId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Circles.forEach(function(c){

$("#circleId").append(
`<option value="${c.CircleId}">${c.Circle}</option>`
);

});

}

}

});
}

function loadDivisions(){
var circleId=$("#circleId").val();

$("#divisionId").html('<option value="">Select Division</option>');
$("#subDivisionId").html('<option value="">Select SubDivision</option>');

if(!circleId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/divisions?circleId="+circleId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Divisions.forEach(function(d){

$("#divisionId").append(
`<option value="${d.DivisionId}">${d.Division}</option>`
);

});

}

}

});
}

function loadSubDivisions(){
var divisionId=$("#divisionId").val();

$("#subDivisionId").html('<option value="">Select SubDivision</option>');

if(!divisionId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/subdivisions?divisionId="+divisionId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.SubDivisions.forEach(function(s){

$("#subDivisionId").append(
`<option value="${s.SubDivisionId}">${s.SubDivision}</option>`
);

});

}

}

});
}

function changePageSize(){

pageSize=parseInt($("#pageSizeSelect").val());

currentPage=1;

renderTable();

}

function applyFilters(){

var zoneId=$("#filterZone").val();
var dsgId=$("#filterDesignation").val();
var circleId=$("#filterCircle").val();
var divisionId=$("#filterDivision").val();
var subDivisionId=$("#filterSubDivision").val();

filteredEmployees=employees.filter(function(e){

if(zoneId && e.ZoneId!=zoneId) return false;
if(dsgId && e.DsgId!=dsgId) return false;
if(circleId && e.CircleId!=circleId) return false;
if(divisionId && e.DivisionId!=divisionId) return false;
if(subDivisionId && e.SubDivisionId!=subDivisionId) return false;

return true;

});

currentPage=1;
renderTable();

}

function editEmployee(userId){

$.ajax({

url: BASE_URL + "api/admin/users/"+userId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

var u=res.Data;

isEditMode=true;
editUserId=userId;

$("#modalTitle").text("Edit Employee");
loadReportingManagers(u.LoginId);
$("#displayName").val(u.DisplayName);
$("#loginId").val(u.LoginId);
$("#loginId").prop("disabled", true);
$("#email").val(u.Email);
$("#phone").val(u.Phone);
$("#dsgId").val(u.DsgId).trigger("change");
$("#reportingManagerId").val(u.ManagerId).trigger("change");
$("#stateId").val(u.StateId).trigger("change");
$("#systemRole").val(u.SystemRole).trigger("change");

setTimeout(function(){
$("#zoneId").val(u.ZoneId).trigger("change");
},300);

setTimeout(function(){
$("#circleId").val(u.CircleId).trigger("change");
},600);

setTimeout(function(){
$("#divisionId").val(u.DivisionId).trigger("change");
},900);

setTimeout(function(){
$("#subDivisionId").val(u.SubDivisionId).trigger("change");
},1200);

$("#employeeModal").modal("show");

}

}

});

}

function confirmStatusChange(userId,currentStatus){

var newStatus=currentStatus==="ACTIVE"?"INACTIVE":"ACTIVE";

var msg="Are you sure you want to change status to "+newStatus+" ?";

if(confirm(msg)){
changeStatus(userId,currentStatus);
}

}

function changeStatus(userId,currentStatus){

var newStatus=currentStatus==="ACTIVE"?"INACTIVE":"ACTIVE";

$.ajax({

url: BASE_URL + "api/admin/users/"+userId+"/status",
method:"PATCH",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({
UserStatus:newStatus
}),

success:function(res){

if(res.Success){

alert("Status updated successfully");
loadEmployees();

}else{

alert(res.Message);

}

},

error:function(){
alert("Failed to update status");
}

});

}

function loadFilterDivisions(circleId){

$("#filterDivision").html('<option value="">Division</option>');

if(!circleId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/divisions?circleId="+circleId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Divisions.forEach(function(d){

$("#filterDivision").append(
`<option value="${d.DivisionId}">${d.Division}</option>`
);

});

}

}

});

}

function loadFilterSubDivisions(divisionId){

$("#filterSubDivision").html('<option value="">SubDivision</option>');

if(!divisionId) return;

$.ajax({

url: BASE_URL + "api/admin/masters/subdivisions?divisionId="+divisionId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.SubDivisions.forEach(function(s){

$("#filterSubDivision").append(
`<option value="${s.SubDivisionId}">${s.SubDivision}</option>`
);

});

}

}

});

}

function onFilterZoneChange(){

var zoneId=$("#filterZone").val();

$("#filterDivision").html('<option value="">Division</option>');
$("#filterSubDivision").html('<option value="">SubDivision</option>');

loadFilterCircles(zoneId);

applyFilters();

}

function onFilterCircleChange(){

var circleId=$("#filterCircle").val();
$("#filterSubDivision").html('<option value="">SubDivision</option>');
loadFilterDivisions(circleId);

applyFilters();

}

function onFilterDivisionChange(){

var divisionId=$("#filterDivision").val();

loadFilterSubDivisions(divisionId);

applyFilters();

}

</script>

</asp:Content>
