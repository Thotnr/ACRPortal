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

<div class="page-title">State Master</div>

<button class="btn btn-primary btn-sm" onclick="openStateModal()">
<i class="fa fa-plus"></i> Add State
</button>

</div>

<div class="mb-3">

<input type="text"
class="form-control search-box"
placeholder="Search state..."
onkeyup="searchTable(this.value)">

</div>

<div class="table-responsive">

<table class="table table-hover table-bordered" id="stateTable">

<thead>

<tr>

<th onclick="sortTable(0)">State ID <i class="fa fa-sort"></i></th>
<th onclick="sortTable(1)">State Name <i class="fa fa-sort"></i></th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="stateTableBody"></tbody>

</table>

</div>

</div>

</div>


<!-- MODAL -->

<div class="modal fade" id="stateModal" tabindex="-1">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add State</h5>

<button type="button" class="close" onclick="closeModal()">
<span>&times;</span>
</button>

</div>

<div class="modal-body">

<form id="stateForm">

<div class="form-group">

<label>State ID</label>

<input type="number"
class="form-control"
id="stateId"
required>

</div>

<div class="form-group">

<label>State Name</label>

<input type="text"
class="form-control"
id="stateName"
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

var states=[];
var token=null;
var isEditMode=false;
var sortDirection=[true,true];

$(document).ready(function(){

token = localStorage.getItem("token");

if(!token){
window.location="/Login/UserAuth";
return;
}

loadStates();

});


function loadStates(){

$.ajax({

url:"/api/admin/masters/states",
method:"GET",

headers:{
"Authorization":"Bearer "+token
},

success:function(res){

if(res.Success){
states=res.Data.States;
renderTable();
}

},

error:function(){
alert("Failed to load states");
}

});

}



function renderTable(){

var body=$("#stateTableBody");
body.empty();

states.forEach(function(s){

var row=`
<tr>

<td>${s.StateId}</td>
<td>${s.StateName}</td>

<td class="text-center">

<button class="action-btn"
title="Edit"
onclick="editState(${s.StateId},'${s.StateName}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>
`;

body.append(row);

});

}



function openStateModal(){

isEditMode=false;

$("#modalTitle").text("Add State");

$("#stateId").val("").prop("disabled",false);
$("#stateName").val("");

$("#stateModal").modal("show");

}



function editState(id,name){

isEditMode=true;

$("#modalTitle").text("Update State");

$("#stateId").val(id).prop("disabled",true);
$("#stateName").val(name);

$("#stateModal").modal("show");

}



function closeModal(){
$("#stateModal").modal("hide");
}



$("#stateForm").submit(function(e){

e.preventDefault();

var stateId=$("#stateId").val().trim();
var stateName=$("#stateName").val().trim();

if(!stateName){
alert("State Name is required");
return;
}

var payload={};
var url="";
var method="";

if(isEditMode){

payload={
StateName:stateName
};

url="/api/admin/masters/states/"+stateId;
method="PATCH";

}
else{

payload={
StateId:parseInt(stateId),
StateName:stateName
};

url="/api/admin/masters/states";
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
loadStates();

}

},

error:function(xhr){

if(xhr.responseJSON){

var err=xhr.responseJSON;

switch(err.ErrorCode){

case "DUPLICATE_ID":
alert("State ID already exists");
break;

case "DUPLICATE_NAME":
alert("State name already exists");
break;

case "NOT_FOUND":
alert("State not found");
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

$("#stateTableBody tr").filter(function(){

$(this).toggle($(this).text().toLowerCase().indexOf(value)>-1);

});

}



function sortTable(col){

sortDirection[col]=!sortDirection[col];

states.sort(function(a,b){

var valA=col===0 ? a.StateId : a.StateName.toLowerCase();
var valB=col===0 ? b.StateId : b.StateName.toLowerCase();

if(valA<valB) return sortDirection[col]?-1:1;
if(valA>valB) return sortDirection[col]?1:-1;

return 0;

});

renderTable();

}

</script>

</asp:Content>