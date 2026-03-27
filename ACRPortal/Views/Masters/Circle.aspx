<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

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
<span class="master-kicker"><i class="fa fa-ring"></i> Masters</span>
<h2 class="master-title">Manage circles with a cleaner hierarchy-focused workspace.</h2>
<p class="master-subtitle">Use filters, review mapped zones, and update circle records from the same refreshed UI language used across the admin module.</p>
</div>
<div class="col-lg-4">
<div class="master-panel">
<div class="master-panel-label">Master Module</div>
<div class="master-panel-value">Circle</div>
<p class="master-panel-copy">The circle page keeps its current logic while the layout is redesigned for better readability.</p>
</div>
</div>
</div>
</div>

<div class="page-card">

<div class="d-flex justify-content-between align-items-center mb-3">

<div>
<div class="page-title">Circle Master</div>
<div class="page-subtitle">Maintain circles and their zone mappings in a more structured table view.</div>
</div>

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
<th onclick="sortTable('ZoneId')">Zone</th>
<th onclick="sortTable('CircleId')">Circle ID</th>
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
var BASE_URL = '<%= Url.Content("~/") %>';
var circles=[];
var filteredCircles=[];
var zones=[];
var zoneMap={};

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

zones = res.Data.Zones || [];
zoneMap = {};

var filter=$("#zoneFilter");
var form=$("#zoneId");

filter.html(`<option value="">All Zones</option>`);
form.html("");

zones.forEach(function(z){

zoneMap[z.ZoneId] = z.ZoneName;

filter.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);
form.append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`);

});

loadCircles();

}

}

});

}

function loadCircles(){

var zoneId=$("#zoneFilter").val();

var url= BASE_URL + "api/admin/masters/circles";

if(zoneId) url+="?zoneId="+zoneId;

$.ajax({

url:url,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

circles = res.Data.Circles || [];
filteredCircles=[...circles];
currentPage=1;

renderTable();

}

}

});

}

function getZoneName(zoneId){

return zoneMap[zoneId] || "";

}

function renderTable(){

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredCircles.slice(start,end);

var rows="";

pageData.forEach(function(c){

rows+=`
<tr>

<td>${c.ZoneId} | ${getZoneName(c.ZoneId)}</td>

<td>${c.CircleId}</td>

<td>${c.Circle}</td>

<td class="text-center">

<button class="action-btn"
onclick="editCircle(${c.CircleId},${c.ZoneId},'${c.Circle}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`;

});

$("#circleTableBody").html(rows);

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

val = val.toLowerCase().trim();

if(!val){

filteredCircles=[...circles];

}else{

filteredCircles = circles.filter(function(c){

return (

(c.Circle && c.Circle.toLowerCase().includes(val)) ||

String(c.CircleId).includes(val) ||

String(c.ZoneId).includes(val) ||

getZoneName(c.ZoneId).toLowerCase().includes(val)

);

});

}

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

url= BASE_URL + "api/admin/masters/circles/"+circleId;
method="PATCH";

}else{

payload={
ZoneId:parseInt(zoneId),
CircleId:parseInt(circleId),
Circle:circleName
};

url= BASE_URL + "api/admin/masters/circles";
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
