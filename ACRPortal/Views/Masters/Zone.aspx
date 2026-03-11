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
font-weight:600;
cursor:pointer;
}

.table-hover tbody tr:hover{
background:#f6f9ff;
}

.action-btn{
border:none;
background:none;
color:#007bff;
font-size:16px;
cursor:pointer;
}

.action-btn:hover{
color:#0056b3;
}

.search-box{
max-width:300px;
}

.modal-body{
max-height:75vh;
overflow-y:auto;
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

<div class="mb-3">

<input type="text"
class="form-control search-box"
placeholder="Search zone..."
onkeyup="searchTable(this.value)">

</div>

<div class="table-responsive">

<table class="table table-hover table-bordered" id="zoneTable">

<thead>

<tr>

<th onclick="sortTable(0)">Zone ID <i class="fa fa-sort"></i></th>
<th onclick="sortTable(1)">Zone Name <i class="fa fa-sort"></i></th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="zoneTableBody"></tbody>

</table>

</div>

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

var zones=[];
var token=null;
var isEditMode=false;
var sortDirection=[true,true];

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

var body=$("#zoneTableBody");
body.empty();

zones.forEach(function(z){

var row=`
<tr>

<td>${z.ZoneId}</td>
<td>${z.ZoneName}</td>

<td class="text-center">

<button class="action-btn"
title="Edit"
onclick="editZone(${z.ZoneId},'${z.ZoneName}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`;

body.append(row);

});

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

if(!isEditMode && !zoneId){

alert("Zone ID is required");
return;

}

var payload={};
var url="";
var method="";

if(isEditMode){

payload={
ZoneName:zoneName
};

url="/api/admin/masters/zones/"+zoneId;
method="PATCH";

}
else{

payload={
ZoneId:parseInt(zoneId),
ZoneName:zoneName
};

url="/api/admin/masters/zones";
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

},

error:function(xhr){

if(xhr.responseJSON){

var err=xhr.responseJSON;

switch(err.ErrorCode){

case "DUPLICATE_ID":
alert("Zone ID already exists");
break;

case "DUPLICATE_NAME":
alert("Zone name already exists");
break;

case "NOT_FOUND":
alert("Zone not found");
break;

case "BAD_REQUEST":
alert("Invalid request");
break;

default:
alert(err.Message || "Error occurred");

}

}
else{

alert("Server error");

}

}

});

});



function searchTable(value){

value=value.toLowerCase();

$("#zoneTableBody tr").filter(function(){

$(this).toggle($(this).text().toLowerCase().indexOf(value)>-1);

});

}



function sortTable(col){

sortDirection[col]=!sortDirection[col];

zones.sort(function(a,b){

var valA=col===0 ? a.ZoneId : a.ZoneName.toLowerCase();
var valB=col===0 ? b.ZoneId : b.ZoneName.toLowerCase();

if(valA<valB) return sortDirection[col]?-1:1;
if(valA>valB) return sortDirection[col]?1:-1;

return 0;

});

renderTable();

}

</script>

</asp:Content>