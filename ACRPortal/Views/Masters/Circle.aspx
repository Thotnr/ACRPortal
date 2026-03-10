<%@ Page Language="C#"
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>

#circleTable{
font-size:14px;
}

#circleTable th{
cursor:pointer;
font-weight:600;
}

.modal-body{
max-height:80vh;
overflow-y:auto;
}

.modal-dialog{
margin-top:30px;
}

</style>

<div class="container-fluid">

<!-- HEADER -->

<div class="d-flex justify-content-between align-items-center mb-4">

<h3>Circle Master</h3>

<button class="btn btn-primary" onclick="openCircleModal()">
Add Circle
</button>

</div>

<!-- FILTER -->

<div class="row mb-3">

<div class="col-md-3">

<select class="form-control" id="zoneFilter" onchange="filterCircles()">
<option value="">All Zones</option>
</select>

</div>

<div class="col-md-3">

<input type="text"
class="form-control"
placeholder="Search circle..."
onkeyup="searchTable(this.value)">

</div>

</div>

<!-- TABLE -->

<div class="table-responsive">

<table class="table table-bordered table-hover" id="circleTable">

<thead class="thead-dark">

<tr>

<th onclick="sortTable(0)">Circle ID</th>
<th onclick="sortTable(1)">Zone</th>
<th onclick="sortTable(2)">Circle</th>
<th>Action</th>

</tr>

</thead>

<tbody id="circleTableBody"></tbody>

</table>

</div>

</div>

<!-- MODAL -->

<div class="modal fade" id="circleModal" tabindex="-1">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Circle</h5>

<button type="button" class="close" onclick="closeModal()">
<span>&times;</span>
</button>

</div>

<div class="modal-body">

<form id="circleForm">

<input type="hidden" id="circleId">

<div class="form-group">

<label>Zone</label>

<select class="form-control" id="zoneDropdown" required></select>

</div>

<div class="form-group">

<label>Circle Name</label>

<input type="text"
class="form-control"
id="circleName"
required>

</div>

<div class="text-center mt-3">

<button type="submit" class="btn btn-success">
Save
</button>

</div>

</form>

</div>

</div>

</div>

</div>

<script>

var circles=[];
var zones=[];
var token=null;

$(document).ready(function(){

token = localStorage.getItem("token");

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

headers:{
"Authorization":"Bearer "+token
},

success:function(res){

if(res.Success){

zones=res.Data.Zones;

populateZoneDropdown();
populateZoneFilter();

}

}

});

}

function populateZoneDropdown(){

var dropdown=document.getElementById("zoneDropdown");

dropdown.innerHTML="";

zones.forEach(function(z){

dropdown.innerHTML+=`<option value="${z.ZoneId}">${z.ZoneName}</option>`;

});

}

function populateZoneFilter(){

var filter=document.getElementById("zoneFilter");

zones.forEach(function(z){

filter.innerHTML+=`<option value="${z.ZoneId}">${z.ZoneName}</option>`;

});

}

function loadCircles(zoneId){

var url="/api/admin/masters/circles";

if(zoneId){
url+="?zoneId="+zoneId;
}

$.ajax({

url:url,
method:"GET",

headers:{
"Authorization":"Bearer "+token
},

success:function(res){

if(res.Success){

circles=res.Data.Circles;

renderTable();

}

}

});

}

function renderTable(){

var body=document.getElementById("circleTableBody");

body.innerHTML="";

circles.forEach(function(c){

var zoneName = zones.find(z=>z.ZoneId==c.ZoneId)?.ZoneName || "";

var row=`
<tr>

<td>${c.CircleId}</td>
<td>${zoneName}</td>
<td>${c.Circle}</td>

<td>

<button class="btn btn-sm btn-info"
onclick="editCircle(${c.CircleId},${c.ZoneId},'${c.Circle}')">

Edit

</button>

</td>

</tr>
`;

body.innerHTML+=row;

});

}

function filterCircles(){

var zoneId=document.getElementById("zoneFilter").value;

loadCircles(zoneId);

}

function openCircleModal(){

document.getElementById("modalTitle").innerText="Add Circle";

document.getElementById("circleId").value="";
document.getElementById("circleName").value="";

$('#circleModal').modal('show');

}

function editCircle(id,zoneId,name){

document.getElementById("modalTitle").innerText="Update Circle";

document.getElementById("circleId").value=id;
document.getElementById("zoneDropdown").value=zoneId;
document.getElementById("circleName").value=name;

$('#circleModal').modal('show');

}

function closeModal(){

$('#circleModal').modal('hide');

}

document.getElementById("circleForm")
.addEventListener("submit",function(e){

e.preventDefault();

var circleId=document.getElementById("circleId").value;

var payload={

ZoneId:parseInt(document.getElementById("zoneDropdown").value),
Circle:document.getElementById("circleName").value

};

var url="/api/admin/masters/circles";
var method="POST";

if(circleId){
url="/api/admin/masters/circles/"+circleId;
method="PUT";
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

alert("Saved successfully");

closeModal();

loadCircles();

}

},

error:function(){

alert("Failed to save circle");

}

});

});

function searchTable(value){

value=value.toLowerCase();

var rows=document.querySelectorAll("#circleTable tbody tr");

rows.forEach(function(row){

var text=row.innerText.toLowerCase();

row.style.display=text.includes(value)?"":"none";

});

}

function sortTable(col){

var table=document.getElementById("circleTable");
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

</script>

</asp:Content>