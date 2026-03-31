<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">


<style>
.master-page{--master-ink:#172033;--master-muted:#667085;--master-line:rgba(15,23,42,0.08);--master-card:rgba(255,255,255,0.94);--master-shadow:0 24px 50px rgba(16,37,66,0.12);position:relative;padding:8px 0 24px;color:var(--master-ink);}
.master-page:before,.master-page:after{content:"";position:absolute;border-radius:50%;filter:blur(12px);opacity:.55;pointer-events:none;}
.master-page:before{width:220px;height:220px;top:-10px;right:8%;background:rgba(6,182,212,0.16);}
.master-page:after{width:240px;height:240px;left:2%;bottom:5%;background:rgba(29,78,216,0.12);}
.master-hero{position:relative;overflow:hidden;background:radial-gradient(circle at top right, rgba(255,255,255,0.18), transparent 32%),radial-gradient(circle at bottom left, rgba(6,182,212,0.2), transparent 28%),linear-gradient(135deg, #102542 0%, #1d4ed8 55%, #06b6d4 100%);border-radius:28px;padding:30px 32px;margin-bottom:22px;box-shadow:0 28px 50px rgba(29,78,216,0.2);color:#fff;}
.master-kicker{display:inline-flex;align-items:center;gap:8px;padding:8px 14px;border-radius:999px;background:rgba(255,255,255,0.12);font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;}
.master-title{margin:18px 0 10px;font-size:34px;font-weight:700;line-height:1.15;}
.master-subtitle{max-width:720px;margin:0;font-size:15px;line-height:1.7;color:rgba(255,255,255,0.84);}
.master-panel{height:100%;padding:22px;border-radius:22px;background:rgba(8,15,31,0.22);backdrop-filter:blur(10px);border:1px solid rgba(255,255,255,0.16);color:#fff;}
.master-panel-label{font-size:12px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:rgba(255,255,255,0.72);}
.master-panel-value{margin:10px 0 8px;font-size:34px;font-weight:700;}
.master-panel-copy{margin:0;font-size:14px;line-height:1.6;color:rgba(255,255,255,0.82);}
.page-card{background:var(--master-card);border:1px solid rgba(255,255,255,0.76);border-radius:24px;padding:22px;box-shadow:var(--master-shadow);}
.page-title{font-weight:700;font-size:22px;margin:0;}
.page-subtitle{margin:6px 0 0;font-size:14px;color:var(--master-muted);}
.table thead th{background:linear-gradient(135deg, #15314b, #2346a8);color:#fff;cursor:pointer;font-size:12px;font-weight:700;letter-spacing:.05em;text-transform:uppercase;border-top:0;border-bottom:0;}
.table-hover tbody tr:hover{background:#f6f9ff;}
.table td{vertical-align:middle;padding:16px 14px;border-color:rgba(15,23,42,0.06);}
.action-btn{border:none;background:none;color:#1d4ed8;cursor:pointer;width:38px;height:38px;border-radius:12px;background:rgba(37,99,235,0.08);}
.pagination{margin-top:18px;}
.pagination .page-link{border-radius:10px;margin:0 2px;border:1px solid rgba(15,23,42,0.08);color:#1d4ed8;}
.pagination .page-item.active .page-link{background:linear-gradient(135deg, #2563eb, #0ea5e9);border-color:transparent;}
.table-info-bar{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;gap:12px;flex-wrap:wrap;}
.form-control,.form-control-sm,.custom-select,select{min-height:46px;border-radius:14px !important;border:1px solid var(--master-line);background:#fff;}
.form-control:focus,select:focus{border-color:#93c5fd;box-shadow:0 0 0 .2rem rgba(37,99,235,.12);}
.modal-content{border:0;border-radius:24px;overflow:hidden;box-shadow:0 28px 60px rgba(15,23,42,0.18);}
.modal-header{background:linear-gradient(135deg, #15314b, #2563eb);color:#fff;border-bottom:0;padding:18px 24px;}
.modal-body{padding:24px;background:#f8fbff;}
.btn{border-radius:14px;font-weight:700;padding:10px 16px;}

</style>

<div class="container-fluid master-page">

<div class="master-hero">
<div class="row align-items-center">
<div class="col-lg-8">
<span class="master-kicker"><i class="fa fa-th-large"></i> Masters</span>
<h2 class="master-title">Review and manage division records in a more structured hierarchy view.</h2>
<p class="master-subtitle">Filter by zone and circle, scan division data more easily, and keep master updates in the same refreshed portal pattern.</p>
</div>
<div class="col-lg-4">
<div class="master-panel">
<div class="master-panel-label">Master Module</div>
<div class="master-panel-value">Division</div>
<p class="master-panel-copy">The layout is redesigned here while the dependent filter and CRUD flow stays exactly the same.</p>
</div>
</div>
</div>
</div>

<div class="page-card">

<div class="d-flex justify-content-between align-items-center mb-3">

<div>
<div class="page-title">Division Master</div>
<div class="page-subtitle">Maintain divisions with their linked zone and circle hierarchy in a clearer table flow.</div>
</div>

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
<th onclick="sortTable('ZoneId')">Zone</th>
<th onclick="sortTable('CircleId')">Circle</th>
<th onclick="sortTable('DivisionId')">Division ID</th>
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
var BASE_URL = '<%= Url.Content("~/") %>';
var divisions=[];
var filteredDivisions=[];

var zones=[];
var circles=[];

var zoneMap={};
var circleMap={};

var token=null;
var isEditMode=false;

var pageSize=10;
var currentPage=1;

var currentSortColumn="";
var sortAsc=true;

$(document).ready(function(){

token=localStorage.getItem("token");

if(!token){
window.location = BASE_URL + "Login/UserAuth";
return;
}

loadZones();

});


function loadZones(){

$.ajax({

url: BASE_URL + "api/admin/masters/zones",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

zones=res.Data.Zones || [];

zoneMap={};

var filter=$("#zoneFilter");
var form=$("#zoneId");

filter.html(`<option value="">All Zones</option>`);
form.html(`<option value="" disabled selected>Select Zone</option>`);

zones.forEach(function(z){

zoneMap[z.ZoneId]=z.ZoneName;

filter.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);
form.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);

});

loadAllCircles();

}

}

});

}


function loadAllCircles(){

$.ajax({

url: BASE_URL + "api/admin/masters/circles",
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

circles=res.Data.Circles || [];

circleMap={};

circles.forEach(function(c){
circleMap[c.CircleId]=c.Circle || c.CircleName;
});

loadDivisions();

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

var filtered=circles.filter(c=>c.ZoneId==zoneId);

filtered.forEach(function(c){

$("#circleFilter").append(
`<option value="${c.CircleId}">${c.Circle}</option>`
);

});

loadDivisions();

}


function loadCirclesForForm(){

var zoneId=$("#zoneId").val();

var dropdown=$("#circleId");

dropdown.html(`<option value="" disabled selected>Select Circle</option>`);

var filtered=circles.filter(c=>c.ZoneId==zoneId);

filtered.forEach(function(c){

dropdown.append(
`<option value="${c.CircleId}">${c.Circle}</option>`
);

});

}


function loadDivisions(){

var zoneId=$("#zoneFilter").val();
var circleId=$("#circleFilter").val();

var url= BASE_URL + "api/admin/masters/divisions";

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

divisions=res.Data.Divisions || [];

filteredDivisions=[...divisions];

currentPage=1;

renderTable();

}

}

});

}


function getZoneName(id){
return zoneMap[id] || "";
}

function getCircleName(id){
return circleMap[id] || "";
}


function renderTable(){

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredDivisions.slice(start,end);

var rows="";

pageData.forEach(function(d){

rows+=`
<tr>

<td>${d.ZoneId} | ${getZoneName(d.ZoneId)}</td>

<td>${d.CircleId} | ${getCircleName(d.CircleId)}</td>

<td>${d.DivisionId}</td>

<td>${d.Division}</td>

<td class="text-center">

<button class="action-btn"
onclick="editDivision(${d.DivisionId},${d.ZoneId},${d.CircleId},'${d.Division}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`;

});

$("#divisionTableBody").html(rows);

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

if(totalPages<=1){
$("#pagination").html("");
return;
}

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

val=val.toLowerCase().trim();

if(!val){

filteredDivisions=[...divisions];

}else{

filteredDivisions=divisions.filter(function(d){

return(

(d.Division && d.Division.toLowerCase().includes(val)) ||

String(d.DivisionId).includes(val) ||

getZoneName(d.ZoneId).toLowerCase().includes(val) ||

getCircleName(d.CircleId).toLowerCase().includes(val)

);

});

}

currentPage=1;

renderTable();

}


function sortTable(col){

sortAsc=currentSortColumn===col?!sortAsc:true;

currentSortColumn=col;

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
},200);

$("#divisionModal").modal("show");

}


function closeModal(){
$("#divisionModal").modal("hide");
}


/* FORM SUBMIT */

$("#divisionForm").submit(function(e){

e.preventDefault();

var zoneId=$("#zoneId").val();
var circleId=$("#circleId").val();
var divisionId=$("#divisionId").val();
var divisionName=$("#divisionName").val().trim();

if(!zoneId){ alert("Select Zone"); return; }
if(!circleId){ alert("Select Circle"); return; }
if(!divisionId){ alert("Enter Division ID"); return; }
if(!divisionName){ alert("Enter Division Name"); return; }

if(!isEditMode){

$.ajax({

url: BASE_URL + "api/admin/masters/divisions",
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

}

}

});

}else{

$.ajax({

url: BASE_URL + "api/admin/masters/divisions/"+divisionId,
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

}

}

});

}

});

</script>

</asp:Content>
