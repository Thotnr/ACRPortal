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

<div class="page-title">SubDivision Master</div>

<button class="btn btn-primary btn-sm" onclick="openSubDivisionModal()">
<i class="fa fa-plus"></i> Add SubDivision
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
<select id="divisionFilter" class="form-control" onchange="loadSubDivisions()">
<option value="">All Divisions</option>
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

<th onclick="sortTable('SubDivisionId')">SubDivision ID</th>
<th onclick="sortTable('ZoneId')">Zone</th>
<th onclick="sortTable('CircleId')">Circle</th>
<th onclick="sortTable('DivisionId')">Division</th>
<th onclick="sortTable('SubDivision')">SubDivision</th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="subDivisionTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>



<!-- MODAL -->

<div class="modal fade" id="subDivisionModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add SubDivision</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="subDivisionForm">

<div class="form-group">
<label>Zone</label>
<select id="zoneId" class="form-control" required onchange="loadCirclesForForm()"></select>
</div>

<div class="form-group">
<label>Circle</label>
<select id="circleId" class="form-control" required onchange="loadDivisionsForForm()"></select>
</div>

<div class="form-group">
<label>Division</label>
<select id="divisionId" class="form-control" required></select>
</div>

<div class="form-group">
<label>SubDivision ID</label>
<input type="number" id="subDivisionId" class="form-control" required>
</div>

<div class="form-group">
<label>SubDivision Name</label>
<input type="text" id="subDivisionName" class="form-control" required>
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

var subDivisions=[];
var filteredSubDivisions=[];

var zones=[];
var circles=[];
var divisions=[];

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
loadSubDivisions();
    $("#divisionFilter").change(function(){
        loadSubDivisions();
    });
});


function loadZones(){

$.ajax({

url:"/api/admin/masters/zones",
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

zones=res.Data.Zones;

zones.forEach(function(z){

$("#zoneFilter").append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);
$("#zoneId").append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);

});

}

}

});

}

function loadCircles(){

var zoneId=$("#zoneFilter").val();

$("#circleFilter").html(`<option value="">All Circles</option>`);
$("#divisionFilter").html(`<option value="">All Divisions</option>`);

if(!zoneId){
loadSubDivisions();
return;
}

$.ajax({

url:"/api/admin/masters/circles?zoneId="+zoneId,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

circles=res.Data.Circles;

circles.forEach(function(c){

$("#circleFilter").append(`<option value="${c.CircleId}">${c.Circle}</option>`);

});

}

loadSubDivisions();   // refresh list

}

});

}

function loadDivisions(){

var circleId=$("#circleFilter").val();
var zoneId=$("#zoneFilter").val();

$("#divisionFilter").html(`<option value="">All Divisions</option>`);

if(!circleId){
loadSubDivisions();
return;
}

$.ajax({

url:"/api/admin/masters/divisions?circleId="+circleId+"&zoneId="+zoneId,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

divisions=res.Data.Divisions;

divisions.forEach(function(d){

$("#divisionFilter").append(`<option value="${d.DivisionId}">${d.Division}</option>`);

});

}

loadSubDivisions();   // refresh list

}

});

}

function loadCirclesForForm(){

var zoneId=$("#zoneId").val();

$("#circleId").html(`<option value="">Select Circle</option>`);
$("#divisionId").html(`<option value="">Select Division</option>`);

if(!zoneId) return;

$.ajax({

url:"/api/admin/masters/circles?zoneId="+zoneId,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Circles.forEach(function(c){

$("#circleId").append(`<option value="${c.CircleId}">${c.Circle}</option>`);

});

}

}

});

}


function loadDivisionsForForm(){

var circleId=$("#circleId").val();

$("#divisionId").html(`<option value="">Select Division</option>`);

if(!circleId) return;

$.ajax({

url:"/api/admin/masters/divisions?circleId="+circleId,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

res.Data.Divisions.forEach(function(d){

$("#divisionId").append(`<option value="${d.DivisionId}">${d.Division}</option>`);

});

}

}

});

}

function loadSubDivisions(){

var zoneId=$("#zoneFilter").val();
var circleId=$("#circleFilter").val();
var divisionId=$("#divisionFilter").val();

var url="/api/admin/masters/subdivisions";

var params=[];

if(zoneId) params.push("zoneId="+encodeURIComponent(zoneId));
if(circleId) params.push("circleId="+encodeURIComponent(circleId));
if(divisionId) params.push("divisionId="+encodeURIComponent(divisionId));

if(params.length>0){
url+="?"+params.join("&");
}

$.ajax({

url:url,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

subDivisions=res.Data.SubDivisions || [];
filteredSubDivisions=[...subDivisions];

currentPage=1;

renderTable();

}

}

});

}


function renderTable(){

var body=$("#subDivisionTableBody");
body.empty();

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredSubDivisions.slice(start,end);

pageData.forEach(function(s){

body.append(`
<tr>

<td>${s.SubDivisionId}</td>
<td>${s.ZoneId}</td>
<td>${s.CircleId}</td>
<td>${s.DivisionId}</td>
<td>${s.SubDivision}</td>

<td class="text-center">

<button class="action-btn"
onclick="editSubDivision(${s.SubDivisionId},${s.ZoneId},${s.CircleId},${s.DivisionId},'${s.SubDivision}')">

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

var total=filteredSubDivisions.length;

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}

function renderPagination(){

var totalPages=Math.ceil(filteredSubDivisions.length/pageSize);

var html="";

html+=`<li class="page-item ${currentPage==1?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage-1})">Prev</a>
</li>`;

for(var i=1;i<=totalPages;i++){

html+=`<li class="page-item ${i==currentPage?'active':''}">
<a class="page-link" onclick="gotoPage(${i})">${i}</a>
</li>`;

}

html+=`<li class="page-item ${currentPage==totalPages?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage+1})">Next</a>
</li>`;

$("#pagination").html(html);

}

function gotoPage(p){

var totalPages=Math.ceil(filteredSubDivisions.length/pageSize);

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

filteredSubDivisions=subDivisions.filter(function(s){

return (
(s.SubDivision || "").toLowerCase().includes(val) ||
String(s.SubDivisionId || "").includes(val)
);

});

currentPage=1;

renderTable();

}


function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;

currentSortColumn = col;

filteredSubDivisions.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;

return 0;

});

renderTable();

}



function openSubDivisionModal(){

isEditMode=false;

$("#modalTitle").text("Add SubDivision");

$("#subDivisionId").prop("disabled",false).val("");
$("#subDivisionName").val("");

$("#zoneId").val("");
$("#circleId").html(`<option value="">Select Circle</option>`);
$("#divisionId").html(`<option value="">Select Division</option>`);

$("#subDivisionModal").modal("show");

}


function editSubDivision(id,zoneId,circleId,divisionId,name){

isEditMode=true;

$("#modalTitle").text("Update SubDivision");

$("#subDivisionId").val(id).prop("disabled",true);
$("#subDivisionName").val(name);

$("#zoneId").val(zoneId);

loadCirclesForForm();

setTimeout(function(){

$("#circleId").val(circleId);

loadDivisionsForForm();

setTimeout(function(){

$("#divisionId").val(divisionId);

},200);

},200);

$("#subDivisionModal").modal("show");

}

$("#subDivisionForm").submit(function(e){

e.preventDefault();

var zoneId=$("#zoneId").val();
var circleId=$("#circleId").val();
var divisionId=$("#divisionId").val();
var subDivisionId=$("#subDivisionId").val().trim();
var subDivisionName=$("#subDivisionName").val().trim();

if(!zoneId){ alert("Please select Zone"); return; }
if(!circleId){ alert("Please select Circle"); return; }
if(!divisionId){ alert("Please select Division"); return; }
if(!subDivisionId){ alert("Enter SubDivision ID"); return; }
if(!subDivisionName){ alert("Enter SubDivision Name"); return; }


/* =========================
CREATE SUBDIVISION
========================= */

if(!isEditMode){

$.ajax({

url:"/api/admin/masters/subdivisions",
method:"POST",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({

ZoneId:parseInt(zoneId),
CircleId:parseInt(circleId),
DivisionId:parseInt(divisionId),
SubDivisionId:parseInt(subDivisionId),
SubDivision:subDivisionName

}),

success:function(res){

if(res.Success){

alert("SubDivision created successfully");

closeModal();
loadSubDivisions();

}else{

alert(res.Message || "Error creating SubDivision");

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
UPDATE SUBDIVISION
========================= */

else{

$.ajax({

url:"/api/admin/masters/subdivisions/"+subDivisionId,
method:"PATCH",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({

SubDivision:subDivisionName

}),

success:function(res){

if(res.Success){

alert("SubDivision updated successfully");

closeModal();
loadSubDivisions();

}else{

alert(res.Message || "Error updating SubDivision");

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

function closeModal(){
$("#subDivisionModal").modal("hide");
}

</script>

</asp:Content>