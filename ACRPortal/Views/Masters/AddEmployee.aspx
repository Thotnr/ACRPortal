<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>

.required-star{
color:red;
margin-left:3px;
font-weight:bold;
}

.page-card{
background:#fff;
border-radius:10px;
padding:20px;
box-shadow:0 2px 10px rgba(0,0,0,0.06);
}

.page-title{
font-weight:600;
font-size:22px;
}

.table thead th{
background:#f8f9fa;
cursor:pointer;
}

.table-hover tbody tr:hover{
background:#f6f9ff;
}

.action-btn{
border:none;
background:none;
color:#007bff;
cursor:pointer;
}

</style>

<div class="container-fluid">

<div class="page-card">

<div class="d-flex justify-content-between mb-3">

<div class="page-title">Employee Management</div>

<button class="btn btn-primary btn-sm" onclick="openEmployeeModal()">
<i class="fa fa-plus"></i> Add Employee
</button>

</div>

<div class="row mb-3">

<div class="col-md-4">
<input type="text" class="form-control" placeholder="Search Employee" onkeyup="searchTable(this.value)">
</div>

</div>

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

<th onclick="sortTable('DisplayName')">Name</th>
<th onclick="sortTable('LoginId')">Login ID</th>
<th>Email</th>
<th>Phone</th>
<th onclick="sortTable('Dsg')">Designation</th>
<th>Status</th>
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
<label>Login ID <span class="required-star">*</span></label>
<input type="text" id="loginId" class="form-control" required>
</div>

<!-- <div class="col-md-6 mt-2">
<label>Password</label>
<input type="password" id="password" class="form-control">
</div> -->

<div class="col-md-6 mt-2">
<label>Email</label>
<input type="email" id="email" class="form-control">
</div>

<div class="col-md-6 mt-2">
<label>Phone</label>
<input type="text" id="phone" class="form-control">
</div>

<div class="col-md-6 mt-2">
<label>Designation</label>
<select id="dsgId" class="form-control"></select>
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

var employees=[];
var filteredEmployees=[];

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
window.location="/Login/UserAuth";
return;
}

loadEmployees();
loadDesignations();
loadStates();

});


/* LOAD EMPLOYEES (example endpoint assumed) */

function loadEmployees(){

$.ajax({

url:"/api/admin/users",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

employees=res.Data.Users || [];
filteredEmployees=[...employees];

currentPage=1;

renderTable();

}

}

});

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

body.append(`

<tr>
<td>${e.DisplayName}</td>
<td>${e.LoginId}</td>
<td>${e.Email || ""}</td>
<td>${e.Phone || ""}</td>
<td>${e.Dsg || ""}</td>
<td>${e.UserStatus}</td>

<td class="text-center">
<button class="action-btn"
onclick="editEmployee('${e.UserId}')">
<i class="fa fa-pen"></i>
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
$("#modalTitle").text("Add Employee");

$("#employeeForm")[0].reset();

$("#employeeModal").modal("show");

}

function closeModal(){
$("#employeeModal").modal("hide");
}


/* DESIGNATION DROPDOWN */
function loadDesignations(){

$("#dsgId").html('<option value="">Select Designation</option>');

$.ajax({

url:"/api/admin/masters/designations?activeOnly=true",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Designations.forEach(function(d){

$("#dsgId").append(
`<option value="${d.DsgId}">${d.DsgDesc}</option>`
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
SystemRole:"EMPLOYEE",
Email:$("#email").val(),
Phone:$("#phone").val(),
DsgId:$("#dsgId").val(),
StateId:$("#stateId").val(),
ZoneId:$("#zoneId").val(),
CircleId:$("#circleId").val(),
DivisionId:$("#divisionId").val(),
SubDivisionId:$("#subDivisionId").val()

};


if(!isEditMode){

$.ajax({

url:"/api/user/createuser",
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

url:"/api/admin/users/"+editUserId,
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

url:"/api/admin/masters/states",
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

if(!stateId) return;

$.ajax({

url:"/api/admin/masters/zones?stateId="+stateId,
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

if(!zoneId) return;

$.ajax({

url:"/api/admin/masters/circles?zoneId="+zoneId,
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

if(!circleId) return;

$.ajax({

url:"/api/admin/masters/divisions?circleId="+circleId,
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

url:"/api/admin/masters/subdivisions?divisionId="+divisionId,
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

</script>

</asp:Content>