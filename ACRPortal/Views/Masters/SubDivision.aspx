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
<span class="master-kicker"><i class="fa fa-th"></i> Masters</span>
<h2 class="master-title">Manage sub-divisions from a cleaner hierarchy-aware admin screen.</h2>
<p class="master-subtitle">Filter down through zone, circle, and division levels, then maintain sub-division records in the same refreshed experience.</p>
</div>
<div class="col-lg-4">
<div class="master-panel">
<div class="master-panel-label">Master Module</div>
<div class="master-panel-value">SubDivision</div>
<p class="master-panel-copy">This page now matches the updated portal UI while all your filtering and save behavior remains intact.</p>
</div>
</div>
</div>
</div>

<div class="page-card">

<div class="d-flex justify-content-between align-items-center mb-3">

<div>
<div class="page-title">SubDivision Master</div>
<div class="page-subtitle">Maintain sub-division records mapped across the full location hierarchy.</div>
</div>

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
var editingId = null


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

function editSubDivision(id, zoneId, circleId, divisionId, name){

    isEditMode = true
    editingId = id

    $("#modalTitle").text("Edit SubDivision")

    $("#subDivisionId").val(id).prop("disabled", true)
    $("#subDivisionName").val(name)

    $("#zoneId").val(zoneId)

    // Load dependent dropdowns
    loadCirclesByZone(zoneId)

    // Wait thoda for async (simple fix)
    setTimeout(function(){

        $("#circleId").val(circleId)

        loadDivisionsByCircle(zoneId, circleId)

        setTimeout(function(){
            $("#divisionId").val(divisionId)
        }, 300)

    }, 300)

    $("#subDivisionModal").modal("show")
}

$("#subDivisionForm").submit(function(e){

    e.preventDefault()

    var payload = {
        ZoneId: $("#zoneId").val(),
        CircleId: $("#circleId").val(),
        DivisionId: $("#divisionId").val(),
        SubDivisionId: parseInt($("#subDivisionId").val()),
        SubDivision: $("#subDivisionName").val()
    }

    // Validation
    if(!payload.ZoneId || !payload.CircleId || !payload.DivisionId || !payload.SubDivision){
        alert("All fields are required")
        return
    }

    var url = BASE_URL + "api/admin/masters/subdivisions"
    var method = "POST"

    // 👉 UPDATE CASE
    if(isEditMode){
        url += "/" + editingId   // assuming REST pattern
        method = "PATCH"
    }

    $.ajax({

        url: url,
        method: method,
        contentType: "application/json",
        headers: { "Authorization": "Bearer " + token },

        data: JSON.stringify(payload),

        success: function(res){

            if(res.Success){

                alert(isEditMode ? "Updated Successfully" : "Created Successfully")

                closeModal()
                loadSubDivisions()

            } else {
                alert(res.Message || "Error")
            }
        },

        error: function(err){

            if(err.status === 400){
                alert("Invalid Data (Zone/Circle/Division issue)")
            }
            else if(err.status === 401){
                alert("Session Expired")
            }
            else{
                alert("Server Error")
            }
        }

    })

})

</script>

</asp:Content>
