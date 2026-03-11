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

<div class="page-title">Circle Master</div>

<button class="btn btn-primary btn-sm" onclick="openCircleModal()">
<i class="fa fa-plus"></i> Add Circle
</button>

</div>

<div class="row mb-3">

<div class="col-md-3">
<select id="zoneFilter" class="form-control" onchange="loadCircles()">
<option value="">All Zones</option>
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
<th onclick="sortTable('CircleId')">Circle ID</th>
<th onclick="sortTable('ZoneId')">Zone ID</th>
<th onclick="sortTable('Circle')">Circle</th>
<th width="80">Action</th>
</tr>

</thead>

<tbody id="circleTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>

<!-- Modal -->

<div class="modal fade" id="circleModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Circle</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="circleForm">

<div class="form-group">
<label>Zone</label>
<select id="zoneId" class="form-control" required></select>
</div>

<div class="form-group">
<label>Circle ID</label>
<input type="number" id="circleId" class="form-control" required>
</div>

<div class="form-group">
<label>Circle Name</label>
<input type="text" id="circleName" class="form-control" required>
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

var circles=[];
var filteredCircles=[];
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
loadCircles();

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

var url="/api/admin/masters/circles";

if(zoneId) url+="?zoneId="+zoneId;

$.ajax({

url:url,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

circles=res.Data.Circles;
filteredCircles=[...circles];
currentPage=1;

renderTable();

}

}

});

}

function renderTable(){

var body=$("#circleTableBody");
body.empty();

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredCircles.slice(start,end);

pageData.forEach(function(c){

body.append(`
<tr>
<td>${c.CircleId}</td>
<td>${c.ZoneId}</td>
<td>${c.Circle}</td>

<td class="text-center">
<button class="action-btn"
onclick="editCircle(${c.CircleId},${c.ZoneId},'${c.Circle}')">
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

var total=filteredCircles.length;

if(total==0){
$("#tableInfo").text("No entries found");
return;
}

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}

function renderPagination(){

var totalPages=Math.ceil(filteredCircles.length/pageSize);

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

var totalPages=Math.ceil(filteredCircles.length/pageSize);

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

filteredCircles=circles.filter(function(c){

return (
c.Circle.toLowerCase().includes(val) ||
String(c.CircleId).includes(val) ||
String(c.ZoneId).includes(val)
);

});

currentPage=1;
renderTable();

}

function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;
currentSortColumn = col;

filteredCircles.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;
return 0;

});

renderTable();

}

function openCircleModal(){

isEditMode=false;

$("#modalTitle").text("Add Circle");

$("#circleId").prop("disabled",false).val("");
$("#circleName").val("");

$("#circleModal").modal("show");

}

function editCircle(id,zoneId,name){

isEditMode=true;

$("#modalTitle").text("Update Circle");

$("#circleId").val(id).prop("disabled",true);
$("#circleName").val(name);
$("#zoneId").val(zoneId);

$("#circleModal").modal("show");

}

function closeModal(){
$("#circleModal").modal("hide");
}

$("#circleForm").submit(function(e){

e.preventDefault();

var circleId=$("#circleId").val();
var zoneId=$("#zoneId").val();
var circleName=$("#circleName").val().trim();

if(!circleName){
alert("Circle name required");
return;
}

var payload={};
var url="";
var method="";

if(isEditMode){

payload={ Circle:circleName };

url="/api/admin/masters/circles/"+circleId;
method="PATCH";

}else{

payload={
ZoneId:parseInt(zoneId),
CircleId:parseInt(circleId),
Circle:circleName
};

url="/api/admin/masters/circles";
method="POST";

}

$.ajax({

url:url,
method:method,

headers:{ "Authorization":"Bearer "+token },

contentType:"application/json",
data:JSON.stringify(payload),

success:function(res){

if(res.Success){

alert(res.Message);

closeModal();
loadCircles();

}

}

});

});

</script>

</asp:Content>