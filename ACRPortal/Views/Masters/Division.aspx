<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<style>

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

.pagination{
margin-top:15px;
}

.table-info-bar{
display:flex;
justify-content:space-between;
align-items:center;
margin-bottom:10px;
}

</style>

<div class="container-fluid">

<div class="page-card">

<div class="d-flex justify-content-between align-items-center mb-3">

<div class="page-title">Division Master</div>

<button class="btn btn-primary btn-sm" onclick="openDivisionModal()">
<i class="fa fa-plus"></i> Add Division
</button>

</div>

<div class="row mb-3">

<div class="col-md-3">

<select id="zoneFilter" class="form-control" onchange="loadCircles()">
<option value="">All Zones</option>
</select>

</div>

<div class="col-md-3">

<select id="circleFilter" class="form-control" onchange="loadDivisions()">
<option value="">All Circles</option>
</select>

</div>

<div class="col-md-3">

<input type="text"
class="form-control"
placeholder="Search..."
onkeyup="searchTable(this.value)">

</div>

</div>

<div class="table-responsive">

<div class="table-info-bar">

<div>
Show
<select id="pageSizeSelect" class="form-control form-control-sm d-inline-block" style="width:80px;" onchange="changePageSize()">
<option value="5">5</option>
<option value="10" selected>10</option>
<option value="30">30</option>
<option value="50">50</option>
<option value="100">100</option>
</select>
entries
</div>

<div id="tableInfo"></div>

</div>

<table class="table table-bordered table-hover">

<thead>

<tr>
<th onclick="sortTable('DivisionId')">Division ID</th>
<th onclick="sortTable('ZoneId')">Zone ID</th>
<th onclick="sortTable('CircleId')">Circle ID</th>
<th onclick="sortTable('Division')">Division</th>
<th width="80">Action</th>
</tr>

</thead>

<tbody id="divisionTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>


<!-- MODAL -->

<div class="modal fade" id="divisionModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Division</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="divisionForm">

<div class="form-group">

<label>Zone</label>

<select id="zoneId" class="form-control" required onchange="loadCirclesForForm()">
<option value="" disabled selected>Select Zone</option>
</select>

</div>

<div class="form-group">

<label>Circle</label>

<select id="circleId" class="form-control" required>
<option value="" disabled selected>Select Circle</option>
</select>

</div>

<div class="form-group">

<label>Division ID</label>
<input type="number" id="divisionId" class="form-control" required>

</div>

<div class="form-group">

<label>Division Name</label>
<input type="text" id="divisionName" class="form-control" required>

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

var divisions=[];
var filteredDivisions=[];
var zones=[];
var token=null;
var isEditMode=false;

var pageSize=10;
var currentPage=1;

var currentSortColumn="";
var sortAsc=true;

$(document).ready(function(){

token=localStorage.getItem("token");

if(!token){
window.location="/Login/UserAuth";
return;
}

loadZones();
loadDivisions();

});


function loadZones(){

$.ajax({

url:"/api/admin/masters/zones",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

zones=res.Data.Zones;

var filter=$("#zoneFilter");
var form=$("#zoneId");

filter.html(`<option value="">All Zones</option>`);
form.html(`<option value="" disabled selected>Select Zone</option>`);

zones.forEach(function(z){

filter.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);
form.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);

});

}

}

});

}


function loadCircles(){

var zoneId=$("#zoneFilter").val();

$("#circleFilter").html(`<option value="">All Circles</option>`);

if(!zoneId){
loadDivisions();
return;
}

$.ajax({

url:"/api/admin/masters/circles?zoneId="+zoneId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Circles.forEach(function(c){

$("#circleFilter").append(`<option value="${c.CircleId}">${c.Circle}</option>`);

});

}

}

});

loadDivisions();

}


function loadCirclesForForm(){

var zoneId=$("#zoneId").val();

var circleDropdown=$("#circleId");

circleDropdown.html(`<option value="" disabled selected>Select Circle</option>`);

if(!zoneId) return;

$.ajax({

url:"/api/admin/masters/circles?zoneId="+zoneId,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Circles.forEach(function(c){

circleDropdown.append(
`<option value="${c.CircleId}">${c.Circle}</option>`
);

});

}

}

});

}


function loadDivisions(){

var zoneId=$("#zoneFilter").val();
var circleId=$("#circleFilter").val();

var url="/api/admin/masters/divisions";

var params=[];

if(zoneId) params.push("zoneId="+zoneId);
if(circleId) params.push("circleId="+circleId);

if(params.length) url+="?"+params.join("&");

$.ajax({

url:url,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

divisions=res.Data.Divisions;
filteredDivisions=[...divisions];

currentPage=1;

renderTable();

}

}

});

}


function renderTable(){

var body=$("#divisionTableBody");
body.empty();

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredDivisions.slice(start,end);

pageData.forEach(function(d){

body.append(`
<tr>

<td>${d.DivisionId}</td>
<td>${d.ZoneId}</td>
<td>${d.CircleId}</td>
<td>${d.Division}</td>

<td class="text-center">

<button class="action-btn"
onclick="editDivision(${d.DivisionId},${d.ZoneId},${d.CircleId},'${d.Division}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`);

});

updateTableInfo(start,end);
renderPagination();

}


function updateTableInfo(start,end){

var total=filteredDivisions.length;

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}

function renderPagination(){
var totalPages=Math.ceil(filteredDivisions.length/pageSize);
var html="";
/* PREVIOUS BUTTON */
html+=`<li class="page-item ${currentPage==1?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage-1})">Prev</a>
</li>`;
/* PAGE NUMBERS */
for(var i=1;i<=totalPages;i++){
html+=`<li class="page-item ${i==currentPage?'active':''}">
<a class="page-link" onclick="gotoPage(${i})">${i}</a>
</li>`;
}
/* NEXT BUTTON */
html+=`<li class="page-item ${currentPage==totalPages?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage+1})">Next</a>
</li>`;
$("#pagination").html(html);
}

function gotoPage(p){
var totalPages=Math.ceil(filteredDivisions.length/pageSize);
if(p<1 || p>totalPages) return;
currentPage=p;
renderTable();
}

function changePageSize(){

pageSize=parseInt($("#pageSizeSelect").val());
currentPage=1;
renderTable();

}


function searchTable(val){

val=val.toLowerCase();

filteredDivisions=divisions.filter(function(d){

return (
d.Division.toLowerCase().includes(val) ||
String(d.DivisionId).includes(val)
);

});

currentPage=1;
renderTable();

}


function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;

currentSortColumn = col;

filteredDivisions.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;

return 0;

});

renderTable();

}


function openDivisionModal(){

isEditMode=false;

$("#modalTitle").text("Add Division");

$("#divisionId").prop("disabled",false).val("");
$("#divisionName").val("");

$("#zoneId").val("");
$("#circleId").html(`<option value="" disabled selected>Select Circle</option>`);

$("#divisionModal").modal("show");

}


function editDivision(id,zoneId,circleId,name){

isEditMode=true;

$("#modalTitle").text("Update Division");

$("#divisionId").val(id).prop("disabled",true);
$("#divisionName").val(name);
$("#zoneId").val(zoneId);

loadCirclesForForm();

setTimeout(function(){
$("#circleId").val(circleId);
},300);

$("#divisionModal").modal("show");

}


function closeModal(){
$("#divisionModal").modal("hide");
}


/* FORM VALIDATION */

$("#divisionForm").submit(function(e){

e.preventDefault();

var zoneId=$("#zoneId").val();
var circleId=$("#circleId").val();
var divisionId=$("#divisionId").val().trim();
var divisionName=$("#divisionName").val().trim();

if(!zoneId){
alert("Please select Zone");
return;
}

if(!circleId){
alert("Please select Circle");
return;
}

if(!divisionId){
alert("Please enter Division ID");
return;
}

if(!divisionName){
alert("Please enter Division Name");
return;
}

/* =========================
CREATE DIVISION
========================= */

if(!isEditMode){

$.ajax({

url:"/api/admin/masters/divisions",
method:"POST",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({
ZoneId:parseInt(zoneId),
CircleId:parseInt(circleId),
DivisionId:parseInt(divisionId),
Division:divisionName
}),

success:function(res){

if(res.Success){

alert("Division created successfully");

closeModal();

loadDivisions();

}else{

alert(res.Message || "Error creating division");

}

},

error:function(xhr){

if(xhr.responseJSON){
alert(xhr.responseJSON.Message);
}else{
alert("Server error");
}

}

});

}

/* =========================
UPDATE DIVISION
========================= */

else{

$.ajax({

url:"/api/admin/masters/divisions/"+divisionId,
method:"PATCH",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({
Division:divisionName
}),

success:function(res){

if(res.Success){

alert("Division updated successfully");

closeModal();

loadDivisions();

}else{

alert(res.Message || "Error updating division");

}

},

error:function(xhr){

if(xhr.responseJSON){
alert(xhr.responseJSON.Message);
}else{
alert("Server error");
}

}

});

}

});

</script>

</asp:Content>