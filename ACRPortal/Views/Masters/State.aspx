<%@ Page Language="C#"
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>

#stateTable{
font-size:14px;
}

#stateTable th{
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

<h3>State Master</h3>

<button class="btn btn-primary" onclick="openStateModal()">
Add State
</button>

</div>

<!-- SEARCH -->

<div class="row mb-3">

<div class="col-md-4">

<input type="text"
class="form-control"
placeholder="Search state..."
onkeyup="searchTable(this.value)">

</div>

</div>

<!-- TABLE -->

<div class="table-responsive">

<table class="table table-bordered table-hover" id="stateTable">

<thead class="thead-dark">

<tr>

<th onclick="sortTable(0)">State ID</th>
<th onclick="sortTable(1)">State Name</th>
<th>Action</th>

</tr>

</thead>

<tbody id="stateTableBody"></tbody>

</table>

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

<input type="hidden" id="stateId">

<div class="form-group">

<label>State Name</label>

<input type="text"
class="form-control"
id="stateName"
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

var states=[];
var token=null;

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

var body=document.getElementById("stateTableBody");
body.innerHTML="";

states.forEach(function(s){

var row=`
<tr>

<td>${s.StateId}</td>
<td>${s.StateName}</td>

<td>

<button class="btn btn-sm btn-info"
onclick="editState(${s.StateId},'${s.StateName}')">

Edit

</button>

</td>

</tr>
`;

body.innerHTML+=row;

});

}

function openStateModal(){

document.getElementById("modalTitle").innerText="Add State";

document.getElementById("stateId").value="";
document.getElementById("stateName").value="";

$('#stateModal').modal('show');

}

function editState(id,name){

document.getElementById("modalTitle").innerText="Update State";

document.getElementById("stateId").value=id;
document.getElementById("stateName").value=name;

$('#stateModal').modal('show');

}

function closeModal(){

$('#stateModal').modal('hide');

}

document.getElementById("stateForm")
.addEventListener("submit",function(e){

e.preventDefault();

var stateId=document.getElementById("stateId").value;

var payload={
StateName:document.getElementById("stateName").value
};

var url="/api/admin/masters/states";
var method="POST";

if(stateId){
url="/api/admin/masters/states/"+stateId;
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

loadStates();

}

},

error:function(xhr){

alert("Failed to save state");

}

});

});

function searchTable(value){

value=value.toLowerCase();

var rows=document.querySelectorAll("#stateTable tbody tr");

rows.forEach(function(row){

var text=row.innerText.toLowerCase();

row.style.display=text.includes(value)?"":"none";

});

}

function sortTable(col){

var table=document.getElementById("stateTable");
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