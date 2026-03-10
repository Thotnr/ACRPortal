<%@ Page Language="C#"
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>

#zoneTable{
font-size:14px;
}

#zoneTable th{
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

<h3>Zone Master</h3>

<button class="btn btn-primary" onclick="openZoneModal()">
Add Zone
</button>

</div>

<!-- SEARCH -->

<div class="row mb-3">

<div class="col-md-4">

<input type="text"
class="form-control"
placeholder="Search zone..."
onkeyup="searchTable(this.value)">

</div>

</div>

<!-- TABLE -->

<div class="table-responsive">

<table class="table table-bordered table-hover" id="zoneTable">

<thead class="thead-dark">

<tr>

<th onclick="sortTable(0)">Zone ID</th>
<th onclick="sortTable(1)">Zone Name</th>
<th>Action</th>

</tr>

</thead>

<tbody id="zoneTableBody"></tbody>

</table>

</div>

</div>

<!-- MODAL -->

<div class="modal fade" id="zoneModal" tabindex="-1">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Zone</h5>

<button type="button" class="close" onclick="closeModal()">
<span>&times;</span>
</button>

</div>

<div class="modal-body">

<form id="zoneForm">

<input type="hidden" id="zoneId">

<div class="form-group">

<label>Zone Name</label>

<input type="text"
class="form-control"
id="zoneName"
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

var zones=[];
var token=null;

$(document).ready(function(){

token = localStorage.getItem("token");

if(!token){
window.location="/Login/UserAuth";
return;
}

loadZones();

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

renderTable();

}

},

error:function(){

alert("Failed to load zones");

}

});

}

function renderTable(){

var body=document.getElementById("zoneTableBody");
body.innerHTML="";

zones.forEach(function(z){

var row=`
<tr>

<td>${z.ZoneId}</td>
<td>${z.ZoneName}</td>

<td>

<button class="btn btn-sm btn-info"
onclick="editZone(${z.ZoneId},'${z.ZoneName}')">

Edit

</button>

</td>

</tr>
`;

body.innerHTML+=row;

});

}

function openZoneModal(){

document.getElementById("modalTitle").innerText="Add Zone";

document.getElementById("zoneId").value="";
document.getElementById("zoneName").value="";

$('#zoneModal').modal('show');

}

function editZone(id,name){

document.getElementById("modalTitle").innerText="Update Zone";

document.getElementById("zoneId").value=id;
document.getElementById("zoneName").value=name;

$('#zoneModal').modal('show');

}

function closeModal(){

$('#zoneModal').modal('hide');

}

document.getElementById("zoneForm")
.addEventListener("submit",function(e){

e.preventDefault();

var zoneId=document.getElementById("zoneId").value;

var payload={
ZoneName:document.getElementById("zoneName").value
};

var url="/api/admin/masters/zones";
var method="POST";

if(zoneId){
url="/api/admin/masters/zones/"+zoneId;
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

loadZones();

}

},

error:function(){

alert("Failed to save zone");

}

});

});

function searchTable(value){

value=value.toLowerCase();

var rows=document.querySelectorAll("#zoneTable tbody tr");

rows.forEach(function(row){

var text=row.innerText.toLowerCase();

row.style.display=text.includes(value)?"":"none";

});

}

function sortTable(col){

var table=document.getElementById("zoneTable");
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