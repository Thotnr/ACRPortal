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

<div class="page-title">State Master</div>

<button class="btn btn-primary btn-sm" onclick="openStateModal()">
<i class="fa fa-plus"></i> Add State
</button>

</div>

<div class="row mb-3">

<div class="col-md-3">

<input type="text"
class="form-control"
placeholder="Search state..."
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

<th onclick="sortTable('StateId')">State ID</th>
<th onclick="sortTable('StateName')">State Name</th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="stateTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>


<!-- MODAL -->

<div class="modal fade" id="stateModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add State</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

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
var filteredStates=[];

var token=null;
var isEditMode=false;

var pageSize=10;
var currentPage=1;

var currentSortColumn="";
var sortAsc=true;

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
filteredStates=[...states];

currentPage=1;

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

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredStates.slice(start,end);

pageData.forEach(function(s){

var row=`

<tr>

<td>${s.StateId}</td>
<td>${s.StateName}</td>

<td class="text-center">

<button class="action-btn"
onclick="editState(${s.StateId},'${s.StateName}')">

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

var total=filteredStates.length;

if(total==0){
$("#tableInfo").text("No entries found");
return;
}

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}


function renderPagination(){

var totalPages=Math.ceil(filteredStates.length/pageSize);

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

var totalPages=Math.ceil(filteredStates.length/pageSize);

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

filteredStates=states.filter(function(s){

return (
String(s.StateId).includes(value) ||
s.StateName.toLowerCase().includes(value)
);

});

currentPage=1;

renderTable();

}


function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;

currentSortColumn = col;

filteredStates.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;

return 0;

});

renderTable();

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

payload={ StateName:stateName };

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

}

});

});

</script>

</asp:Content>