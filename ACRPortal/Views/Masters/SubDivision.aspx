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

<div class="page-title">SubDivision Master</div>

<button class="btn btn-primary btn-sm" onclick="openSubDivisionModal()">
<i class="fa fa-plus"></i> Add SubDivision
</button>

</div>


<div class="row mb-3">

<div class="col-md-3">
<select id="zoneFilter" class="form-control">
<option value="">All Zones</option>
</select>
</div>

<div class="col-md-3">
<select id="circleFilter" class="form-control">
<option value="">All Circles</option>
</select>
</div>

<div class="col-md-3">
<select id="divisionFilter" class="form-control">
<option value="">All Divisions</option>
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
<select id="pageSizeSelect" class="form-control form-control-sm d-inline-block" style="width:80px;">
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
<th onclick="sortTable('DivisionId')">Division</th>
<th onclick="sortTable('SubDivisionId')">SubDivision ID</th>
<th onclick="sortTable('SubDivision')">SubDivision</th>
<th width="80">Action</th>

</tr>

</thead>

<tbody id="subDivisionTableBody"></tbody>

</table>

</div>

<nav>
<ul class="pagination justify-content-center" id="pagination"></ul>
</nav>

</div>

</div>



<!-- MODAL -->

<div class="modal fade" id="subDivisionModal">

<div class="modal-dialog">

<div class="modal-content">

<div class="modal-header">

<h5 class="modal-title" id="modalTitle">Add SubDivision</h5>

<button type="button" class="close" onclick="closeModal()">&times;</button>

</div>

<div class="modal-body">

<form id="subDivisionForm">

<div class="form-group">
<label>Zone</label>
<select id="zoneId" class="form-control" required></select>
</div>

<div class="form-group">
<label>Circle</label>
<select id="circleId" class="form-control" required></select>
</div>

<div class="form-group">
<label>Division</label>
<select id="divisionId" class="form-control" required></select>
</div>

<div class="form-group">
<label>SubDivision ID</label>
<input type="number" id="subDivisionId" class="form-control" required>
</div>

<div class="form-group">
<label>SubDivision Name</label>
<input type="text" id="subDivisionName" class="form-control" required>
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
var subDivisions=[]
var filteredSubDivisions=[]

var zones=[]
var circles=[]
var divisions=[]

var token=null
var isEditMode=false

var pageSize=10
var currentPage=1

var currentSortColumn=""
var sortAsc=true



$(document).ready(function(){

token=localStorage.getItem("token")

if(!token){
window.location = BASE_URL + "Login/UserAuth";
return
}

loadZones()
loadCircles()
loadDivisions()
loadSubDivisions()


$("#zoneFilter").change(function(){
loadCircles()
$("#divisionFilter").html(`<option value="">All Divisions</option>`)
})

$("#circleFilter").change(function(){
loadDivisions()
})

$("#divisionFilter").change(function(){
loadSubDivisions()
})

$("#pageSizeSelect").change(function(){
pageSize=parseInt($(this).val())
currentPage=1
renderTable()
})

$("#zoneId").change(function(){
    var zoneId = $(this).val()
    loadCirclesByZone(zoneId)
})

// Modal Circle Change
$("#circleId").change(function(){
    var zoneId = $("#zoneId").val()
    var circleId = $(this).val()
    loadDivisionsByCircle(zoneId, circleId)
})

})



function loadZones(){

$.ajax({

url: BASE_URL + "api/admin/masters/zones",
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

zones=res.Data.Zones

$("#zoneFilter").html(`<option value="">All Zones</option>`)
$("#zoneId").html(`<option value="">Select Zone</option>`)

zones.forEach(function(z){

$("#zoneFilter").append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`)
$("#zoneId").append(`<option value="${z.ZoneId}">${z.ZoneName}</option>`)

})

}

}

})

}



function loadCircles(){

var zoneId=$("#zoneFilter").val()

$("#circleFilter").html(`<option value="">All Circles</option>`)
$("#divisionFilter").html(`<option value="">All Divisions</option>`)

var url= BASE_URL + "api/admin/masters/circles"
if(zoneId) url+="?zoneId="+zoneId

$.ajax({

url:url,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

circles=res.Data.Circles || []

circles.forEach(function(c){
$("#circleFilter").append(`<option value="${c.CircleId}">${c.Circle || c.CircleName}</option>`)
})

}

// loadSubDivisions()

}

})

}



function loadDivisions(){

var zoneId=$("#zoneFilter").val()
var circleId=$("#circleFilter").val()

$("#divisionFilter").html(`<option value="">All Divisions</option>`)

var url= BASE_URL + "api/admin/masters/divisions"

var params=[]
if(zoneId) params.push("zoneId="+zoneId)
if(circleId) params.push("circleId="+circleId)

if(params.length) url+="?"+params.join("&")

$.ajax({

url:url,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

divisions=res.Data.Divisions || []

divisions.forEach(function(d){
$("#divisionFilter").append(`<option value="${d.DivisionId}">${d.Division}</option>`)
})

}

// loadSubDivisions()

}

})

}



function loadSubDivisions(){

var zoneId=$("#zoneFilter").val()
var circleId=$("#circleFilter").val()
var divisionId=$("#divisionFilter").val()

var url= BASE_URL + "api/admin/masters/subdivisions"

var params=[]
if(zoneId) params.push("zoneId="+zoneId)
if(circleId) params.push("circleId="+circleId)
if(divisionId) params.push("divisionId="+divisionId)

if(params.length) url+="?"+params.join("&")

$.ajax({

url:url,
method:"GET",
headers:{ "Authorization":"Bearer "+token },

success:function(res){

if(res.Success){

subDivisions=res.Data.SubDivisions || []
filteredSubDivisions=[...subDivisions]

currentPage=1

renderTable()

}

}

})

}



function getZoneName(id){
var z=zones.find(x=>x.ZoneId==id)
return z?z.ZoneName:""
}

function getCircleName(id){
var c=circles.find(x=>x.CircleId==id)
return c?(c.Circle||c.CircleName):""
}

function getDivisionName(id){
var d=divisions.find(x=>x.DivisionId==id)
return d?d.Division:""
}



function renderTable(){

var body=$("#subDivisionTableBody")
body.empty()

var start=(currentPage-1)*pageSize
var end=start+pageSize

var pageData=filteredSubDivisions.slice(start,end)

pageData.forEach(function(s){

body.append(`

<tr>

<td>${s.ZoneId} | ${getZoneName(s.ZoneId)}</td>
<td>${s.CircleId} | ${getCircleName(s.CircleId)}</td>
<td>${s.DivisionId} | ${getDivisionName(s.DivisionId)}</td>
<td>${s.SubDivisionId}</td>
<td>${s.SubDivision}</td>

<td class="text-center">

<button class="action-btn"
onclick="editSubDivision(${s.SubDivisionId},${s.ZoneId},${s.CircleId},${s.DivisionId},'${s.SubDivision}')">

<i class="fa fa-pen"></i>

</button>

</td>

</tr>

`)

})

updateTableInfo(start,end)
renderPagination()

}



function updateTableInfo(start,end){

var total=filteredSubDivisions.length

$("#tableInfo").text(
"Showing "+(start+1)+" to "+Math.min(end,total)+" of "+total+" entries"
)

}



function renderPagination(){

var totalPages=Math.ceil(filteredSubDivisions.length/pageSize)

var html=""

html+=`<li class="page-item ${currentPage==1?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage-1})">Prev</a>
</li>`

for(var i=1;i<=totalPages;i++){

html+=`<li class="page-item ${i==currentPage?'active':''}">
<a class="page-link" onclick="gotoPage(${i})">${i}</a>
</li>`

}

html+=`<li class="page-item ${currentPage==totalPages?'disabled':''}">
<a class="page-link" onclick="gotoPage(${currentPage+1})">Next</a>
</li>`

$("#pagination").html(html)

}



function gotoPage(p){

var totalPages=Math.ceil(filteredSubDivisions.length/pageSize)
if(p<1 || p>totalPages) return

currentPage=p
renderTable()

}



function searchTable(val){

val=val.toLowerCase()

filteredSubDivisions=subDivisions.filter(function(s){

return (
(s.SubDivision||"").toLowerCase().includes(val) ||
String(s.SubDivisionId||"").includes(val)
)

})

currentPage=1
renderTable()

}



function sortTable(col){

sortAsc = currentSortColumn === col ? !sortAsc : true
currentSortColumn = col

filteredSubDivisions.sort(function(a,b){

var x=a[col]
var y=b[col]

if(x>y) return sortAsc?1:-1
if(x<y) return sortAsc?-1:1

return 0

})

renderTable()

}



function openSubDivisionModal(){

    isEditMode=false

    $("#modalTitle").text("Add SubDivision")

    $("#subDivisionId").prop("disabled",false).val("")
    $("#subDivisionName").val("")

    $("#zoneId").val("")
    $("#circleId").html(`<option value="">Select Circle</option>`)
    $("#divisionId").html(`<option value="">Select Division</option>`)

    $("#subDivisionModal").modal("show")

}



function closeModal(){
$("#subDivisionModal").modal("hide")
}

function loadCirclesByZone(zoneId){

    $("#circleId").html(`<option value="">Select Circle</option>`)
    $("#divisionId").html(`<option value="">Select Division</option>`)

    var url = BASE_URL + "api/admin/masters/circles"
    if(zoneId) url += "?zoneId=" + zoneId

    $.ajax({
        url: url,
        method: "GET",
        headers: { "Authorization": "Bearer " + token },

        success: function(res){

            if(res.Success){

                var list = res.Data.Circles || []

                list.forEach(function(c){
                    $("#circleId").append(
                        `<option value="${c.CircleId}">${c.Circle || c.CircleName}</option>`
                    )
                })
            }
        }
    })
}

function loadDivisionsByCircle(zoneId, circleId){

    $("#divisionId").html(`<option value="">Select Division</option>`)

    var url = BASE_URL + "api/admin/masters/divisions"

    var params = []
    if(zoneId) params.push("zoneId=" + zoneId)
    if(circleId) params.push("circleId=" + circleId)

    if(params.length) url += "?" + params.join("&")

    $.ajax({
        url: url,
        method: "GET",
        headers: { "Authorization": "Bearer " + token },

        success: function(res){

            if(res.Success){

                var list = res.Data.Divisions || []

                list.forEach(function(d){
                    $("#divisionId").append(
                        `<option value="${d.DivisionId}">${d.Division}</option>`
                    )
                })
            }
        }
    })
}

</script>

</asp:Content>