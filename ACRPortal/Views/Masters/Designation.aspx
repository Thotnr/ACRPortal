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

<div class="page-title">Designation Master</div>

<button class="btn btn-primary btn-sm" onclick="openDesignationModal()">
<i class="fa fa-plus"></i> Add Designation
</button>

</div>


<div class="row mb-3">

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
<select id="pageSizeSelect"
class="form-control form-control-sm d-inline-block"
style="width:80px;"
onchange="changePageSize()">

<option value="5">5</option>
<option value="10" selected>10</option>
<option value="30">30</option>
<option value="50">50</option>

</select>
entries

</div>

<div id="tableInfo"></div>

</div>


<table class="table table-bordered table-hover">

<thead>

<tr>

<th onclick="sortTable('DsgId')">ID</th>
<th onclick="sortTable('Dsg')">Designation</th>
<th onclick="sortTable('DsgDesc')">Description</th>
<th onclick="sortTable('FormType')">Form Type</th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="designationTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>



<!-- MODAL -->

<div class="modal fade" id="designationModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add Designation</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="designationForm">

<div class="form-group">
<label>Designation</label>
<input type="text" id="dsg" class="form-control" required>
</div>

<div class="form-group">
<label>Description</label>
<input type="text" id="dsgDesc" class="form-control">
</div>

<div class="form-group">
<label>Form Type</label>
<select id="formType" class="form-control" required>
<option value="" selected disabled>Select Form Type</option>
<option value="A1a">A1a - SE and above</option>
<option value="A1b">A1b - AE upto XEN</option>
<option value="A2">A2 - General and Accounts Wing</option>
</select>
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
var designations=[];
var filteredDesignations=[];
var token=null;

var isEditMode=false;
var editId=null;

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

loadDesignations();

});


/* =========================
LOAD LIST
========================= */

function loadDesignations(){

var activeOnly=$("#activeFilter").val();

$.ajax({

url: BASE_URL + "api/admin/masters/designations?activeOnly="+activeOnly,
method:"GET",

headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

designations=res.Data.Designations || [];
designations.sort(function(a,b){
return a.DsgId - b.DsgId;
});
filteredDesignations=[...designations];
currentSortColumn = "DsgId";
sortAsc = true;

currentPage=1;
renderTable();

}else{

alert(res.Message || "Failed to load designations");

}

},

error:function(xhr){

alert("Error loading designations");

}

});

}



/* =========================
TABLE
========================= */

function renderTable(){

var body=$("#designationTableBody");

body.empty();

var start=(currentPage-1)*pageSize;
var end=start+pageSize;

var pageData=filteredDesignations.slice(start,end);

pageData.forEach(function(d){

body.append(`

<tr>

<td>${d.DsgId}</td>
<td>${d.Dsg}</td>
<td>${d.DsgDesc || ""}</td>
<td>${getFormTypeText(d.FormType || "")}</td>
<td class="text-center">

<button class="action-btn"
onclick="editDesignation(${d.DsgId},'${d.Dsg}','${d.DsgDesc || ""}','${d.FormType || ""}')">

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

var total=filteredDesignations.length;

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
);

}

function renderPagination(){

var totalPages=Math.ceil(filteredDesignations.length/pageSize);

if(totalPages===0){
$("#pagination").html("");
return;
}

var html="";

/* PREV BUTTON */

html+=`<li class="page-item ${currentPage==1?'disabled':''}">
<a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage-1})">
Prev
</a>
</li>`;


/* PAGE NUMBERS */

for(var i=1;i<=totalPages;i++){

html+=`<li class="page-item ${i==currentPage?'active':''}">
<a class="page-link" href="javascript:void(0)" onclick="gotoPage(${i})">
${i}
</a>
</li>`;

}


/* NEXT BUTTON */

html+=`<li class="page-item ${currentPage==totalPages?'disabled':''}">
<a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage+1})">
Next
</a>
</li>`;

$("#pagination").html(html);

}

function gotoPage(p){

var totalPages=Math.ceil(filteredDesignations.length/pageSize);

if(p<1 || p>totalPages){
return;
}

currentPage=p;

renderTable();

}

function changePageSize(){

pageSize=parseInt($("#pageSizeSelect").val());
currentPage=1;
renderTable();

}


/* =========================
SEARCH + SORT
========================= */

function searchTable(val){

val=val.toLowerCase();

filteredDesignations=designations.filter(function(d){

return (
(d.Dsg || "").toLowerCase().includes(val) ||
(d.DsgDesc || "").toLowerCase().includes(val)
);

});

currentPage=1;
renderTable();

}


function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true;
currentSortColumn = col;

filteredDesignations.sort(function(a,b){

var x=a[col];
var y=b[col];

if(x>y) return sortAsc?1:-1;
if(x<y) return sortAsc?-1:1;

return 0;

});

renderTable();

}



/* =========================
MODAL
========================= */

function openDesignationModal(){
isEditMode=false;
$("#modalTitle").text("Add Designation");
$("#dsg").val("");
$("#dsgDesc").val("");
// ✅ IMPORTANT FIX
$("#formType").val("");   // reset dropdown
$("#designationModal").modal("show");
}


function editDesignation(id,code,desc, formType){

isEditMode=true;
editId=id;

$("#modalTitle").text("Update Designation");

$("#dsg").val(code);
$("#dsgDesc").val(desc);
$("#formType").val(formType);

$("#designationModal").modal("show");


}


function closeModal(){
$("#designationModal").modal("hide");
}



/* =========================
SAVE
========================= */

$("#designationForm").submit(function(e){

e.preventDefault();

var dsg=$("#dsg").val().trim();
var dsgDesc=$("#dsgDesc").val().trim();
var formType=$("#formType").val();

if(!formType){
alert("Select Form Type");
return;
}

if(!dsg){
alert("Enter designation");
return;
}

/* CREATE */

if(!isEditMode){

$.ajax({

url: BASE_URL + "api/admin/masters/designations",
method:"POST",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify({
Dsg:dsg,
DsgDesc:dsgDesc,
DsgLevel:1,
FormType:formType
}),

success:function(res){

if(res.Success){

alert("Designation created successfully");

closeModal();
loadDesignations();

}else{

handleApiError(res);

}

},

error:function(xhr){

handleHttpError(xhr);

}

});

}


/* UPDATE */

else{

var body={
Dsg:dsg,
DsgDesc:dsgDesc,
DsgLevel:1,
FormType:formType
};

$.ajax({

url: BASE_URL + "api/admin/masters/designations/"+editId,
method:"PATCH",

headers:{
"Authorization":"Bearer "+token,
"Content-Type":"application/json"
},

data:JSON.stringify(body),

success:function(res){

if(res.Success){

alert("Designation updated successfully");

closeModal();
loadDesignations();

}else{

handleApiError(res);

}

},

error:function(xhr){

handleHttpError(xhr);

}

});

}

});



/* =========================
ERROR HANDLING
========================= */

function handleApiError(res){

switch(res.ErrorCode){

case "DUPLICATE_NAME":
alert("Designation already exists");
break;

case "BAD_REQUEST":
alert(res.Message || "Invalid request");
break;

case "NOT_FOUND":
alert("Designation not found");
break;

default:
alert(res.Message || "Operation failed");

}

}


function handleHttpError(xhr){

if(xhr.responseJSON && xhr.responseJSON.Message){
alert(xhr.responseJSON.Message);
}else{
alert("Server error occurred");
}

}
function getFormTypeText(val){

if(val==="A1a") return "SE and above";
if(val==="A1b") return "AE upto XEN";
if(val==="A2") return "General and Accounts Wing";

return val || "";
}

</script>

</asp:Content>