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

<div class="page-title">Zone Master</div>

<button class="btn btn-primary btn-sm" onclick="openZoneModal()">
<i class="fa fa-plus"></i> Add Zone
</button>

</div>

<div class="row mb-3">

<div class="col-md-3">

<input type="text"
class="form-control"
placeholder="Search zone..."
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

<table class="table table-hover table-bordered">

<thead>

<tr>

<th onclick="sortTable('ZoneId')">Zone ID</th>
<th onclick="sortTable('ZoneName')">Zone Name</th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="zoneTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>


<!-- MODAL -->

<div class="modal fade" id="zoneModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Zone</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="zoneForm">

<div class="form-group">

<label>Zone ID</label>

<input type="number"
class="form-control"
id="zoneId"
required>

</div>

<div class="form-group">

<label>Zone Name</label>

<input type="text"
class="form-control"
id="zoneName"
required>

</div>

<div class="text-center mt-3">

<button type="submit" class="btn btn-success btn-sm">
Save
</button>

</div>

</form>

</div>

</div>

</div>

</div>



<script>
var BASE_URL = '<%= Url.Content("~/") %>';
var zones=[];
var filteredZones=[];

var token=null;
var isEditMode=false;

var pageSize=10;
var currentPage=1;

var currentSortColumn="";
var sortAsc=true;

$(document).ready(function(){

token = localStorage.getItem("token");

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

headers:{
"Authorization":"Bearer "+token
},

success:function(res){

if(res.Success){

zones=res.Data.Zones;
filteredZones=[...zones];

currentPage=1;

renderTable();

}

},

error:function(){
alert("Failed to load zones");
}

});

}


function renderTable(){

var body=$("#zoneTableBody");
body.empty();

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredZones.slice(start,end);

pageData.forEach(function(z){

var row=`
<tr>

<td>${z.ZoneId}</td>
<td>${z.ZoneName}</td>

<td class="text-center">

<button class="action-btn"
onclick="editZone(${z.ZoneId},'${z.ZoneName}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`;

body.append(row);

});

updateTableInfo(start,end);
renderPagination();

}


function updateTableInfo(start,end){

var total=filteredZones.length;

if(total==0){
$("#tableInfo").text("No entries found");
return;
}

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}


function renderPagination(){

var totalPages=Math.ceil(filteredZones.length/pageSize);

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

var totalPages=Math.ceil(filteredZones.length/pageSize);

if(p<1 || p>totalPages) return;

currentPage=p;

renderTable();

}


function changePageSize(){

pageSize=parseInt($("#pageSizeSelect").val());

currentPage=1;

renderTable();

}


function searchTable(value){

value=value.toLowerCase();

filteredZones=zones.filter(function(z){

return (
String(z.ZoneId).includes(value) ||
z.ZoneName.toLowerCase().includes(value)
);

});

currentPage=1;

renderTable();

}


function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;

currentSortColumn = col;

filteredZones.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;

return 0;

});

renderTable();

}


function openZoneModal(){

isEditMode=false;

$("#modalTitle").text("Add Zone");

$("#zoneId").val("").prop("disabled",false);
$("#zoneName").val("");

$("#zoneModal").modal("show");

}


function editZone(id,name){

isEditMode=true;

$("#modalTitle").text("Update Zone");

$("#zoneId").val(id).prop("disabled",true);
$("#zoneName").val(name);

$("#zoneModal").modal("show");

}


function closeModal(){

$("#zoneModal").modal("hide");

}


$("#zoneForm").submit(function(e){

e.preventDefault();

var zoneId=$("#zoneId").val().trim();
var zoneName=$("#zoneName").val().trim();

if(!zoneName){
alert("Zone Name is required");
return;
}

var payload={};
var url="";
var method="";

if(isEditMode){

payload={ ZoneName:zoneName };

url= BASE_URL + "api/admin/masters/zones/"+zoneId;
method="PATCH";

}
else{

payload={
ZoneId:parseInt(zoneId),
ZoneName:zoneName
};

url= BASE_URL + "api/admin/masters/zones";
method="POST";

}

$.ajax({

url:url,
method:method,

headers:{
"Authorization":"Bearer "+token
},

contentType:"application/json",

data:JSON.stringify(payload),

success:function(res){

if(res.Success){

alert(res.Message);

closeModal();
loadZones();

}

}

});

});

</script>

</asp:Content>