<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<div class="container-fluid px-0" id="acceptingDiv" style="display:none;">
    <h2 class="mb-4">Accepting Authority Dashboard</h2>

    <!-- TOP BAR -->
    <div class="row mb-3">
        <div class="col-md-3">
            <input type="text" id="searchBox" class="form-control" placeholder="Search ACR..." onkeyup="searchTable(this.value)">
        </div>
        <div class="col-md-3">
            Show 
            <select id="pageSize" class="form-select d-inline-block" style="width:80px;" onchange="changePageSize()">
                <option value="5">5</option>
                <option value="10" selected>10</option>
                <option value="30">30</option>
            </select>
            entries
        </div>
        <div class="col-md-6 text-end" id="tableInfo"></div>
    </div>

    <!-- TABLE -->
    <div class="table-responsive">
        <table class="table table-striped table-hover table-bordered">
            <thead class="table-primary">
                <tr>
                    <th>Officer</th>
                    <th>Location</th>
                    <th>From</th>
                    <th>To</th>
                    <th>Year</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="acrTableBody"></tbody>
        </table>
    </div>

    <nav>
        <ul class="pagination justify-content-center" id="pagination"></ul>
    </nav>
</div>

<!-- MODAL -->
<div class="modal fade" id="acrModal">
<div class="modal-dialog modal-xl modal-dialog-scrollable">
<div class="modal-content">

<div class="modal-header bg-primary text-white">
<h5 class="modal-title"><i class="bi bi-check2-square"></i> Accepting Assessment</h5>
<button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
</div>

<div class="modal-body">

<ul class="nav nav-tabs" role="tablist">
    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#infoTab">ACR Info</button></li>
    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#reportingTab">Reporting</button></li>
    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#reviewingTab">Reviewing</button></li>
    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#acceptingTab">Accepting</button></li>
</ul>

<div class="tab-content mt-3">

<!-- INFO -->
<div class="tab-pane fade show active" id="infoTab">
<div class="row g-3">
<div class="col-md-6"><label class="form-label fw-bold">Officer</label><input id="infoOfficer" class="form-control" readonly></div>
<div class="col-md-6"><label class="form-label fw-bold">Year</label><input id="infoYear" class="form-control" readonly></div>
<div class="col-md-4">
<label class="form-label fw-bold">Location</label>
<input id="infoLocation" class="form-control" readonly>
</div>

<div class="col-md-4">
<label class="form-label fw-bold">Posting From</label>
<input id="infoFrom" class="form-control" readonly>
</div>

<div class="col-md-4">
<label class="form-label fw-bold">Posting To</label>
<input id="infoTo" class="form-control" readonly>
</div>
<div class="col-md-6"><label class="form-label fw-bold">Status</label><input id="infoStatus" class="form-control" readonly></div>
</div>
</div>

<!-- REPORTING -->
<div class="tab-pane fade" id="reportingTab">
    <h5>RA1 Assessment</h5>
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <label class="form-label fw-bold">Work Targets</label>
            <input id="ra1Targets" class="form-control" readonly>
        </div>
        <div class="col-md-4">
            <label class="form-label fw-bold">Work Quality</label>
            <input id="ra1Quality" class="form-control" readonly>
        </div>
        <div class="col-md-4">
            <label class="form-label fw-bold">Overall</label>
            <input id="ra1Overall" class="form-control" readonly>
        </div>
    </div>
    <div class="mb-4">
        <label class="form-label fw-bold">Remarks</label>
        <textarea id="ra1Remarks" class="form-control" rows="3" readonly></textarea>
    </div>

    <!-- RA2 Section -->
    <div id="ra2Section" style="display:none;">
        <hr/>
        <h6 class="text-secondary mb-3">Second Reporting Officer (RA2)</h6>
        <div class="row g-3">
            <div class="col-md-4">
                <label class="form-label fw-bold">Work Targets</label>
                <input id="ra2Targets" class="form-control" readonly>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-bold">Work Quality</label>
                <input id="ra2Quality" class="form-control" readonly>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-bold">Overall</label>
                <input id="ra2Overall" class="form-control" readonly>
            </div>
        </div>
        <div class="mt-3">
            <label class="form-label fw-bold">Remarks</label>
            <textarea id="ra2Remarks" class="form-control" rows="3" readonly></textarea>
        </div>
    </div>
</div>

<!-- REVIEWING -->
<div class="tab-pane fade" id="reviewingTab">
    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label fw-bold">Agree with RA</label>
            <input id="reviewAgree" class="form-control" readonly>
        </div>
        <div class="col-md-6">
            <label class="form-label fw-bold">Overall Grade</label>
            <input id="reviewGrade" class="form-control" readonly>
        </div>
    </div>
    
    <div class="mb-4">
        <label class="form-label fw-bold">Disagree Details</label>
        <textarea id="reviewDisagree" class="form-control" rows="3" readonly></textarea>
    </div>
    
    <div class="mb-4">
        <label class="form-label fw-bold">Comments</label>
        <textarea id="reviewComments" class="form-control" rows="3" readonly></textarea>
    </div>
    
    <div class="alert alert-info">
        <strong>Submitted:</strong> <span id="reviewSubmittedAt">-</span>
    </div>
</div>

<!-- ACCEPTING -->
<div class="tab-pane fade" id="acceptingTab">

<div class="alert alert-warning" id="readonlyMsg" style="display:none;">
<i class="bi bi-lock"></i> Final submitted — read only
</div>

<div class="row g-3 mt-2">

<div class="col-md-4">
<label class="form-label fw-bold">Agree with RA/Reviewing *</label>
<select id="aaAgree" class="form-select">
<option value="">Select</option>
<option value="true">Yes</option>
<option value="false">No</option>
</select>
</div>

<div class="col-md-8">
<label class="form-label">Disagree Details</label>
<textarea id="aaDisagree" class="form-control"></textarea>
</div>

<div class="col-md-12">
<label class="form-label fw-bold">Comments *</label>
<textarea id="aaRemarks" class="form-control"></textarea>
</div>

<div class="col-md-4">
<label class="form-label fw-bold">4. Overall Grade (1-10) *</label>
<input type="number" id="aaGrade" min="1" max="10" class="form-control">
</div>

<div class="col-md-8">
<label class="form-label fw-bold">Decision *</label>
<select id="aaDecision" class="form-select">
<option value="">Select</option>
<option value="true">Approve</option>
<option value="false">Reject</option>
</select>
</div>

</div>

<div class="d-flex justify-content-end mt-4">
<button class="btn btn-success" id="submitAA">
<i class="bi bi-send"></i> Submit Assessment
</button>
</div>

</div>

</div>
</div>
</div>
</div>
</div>

<script>

let dataList=[], filtered=[], pageSize=10, currentPage=1;
let currentAcrId=null;
let modal=new bootstrap.Modal(document.getElementById('acrModal'));

$(document).ready(function(){

    const role = localStorage.getItem("role");

    if(role && role !== "EMPLOYEE"){
        alert("Access denied");
        return;
    }

    $("#acceptingDiv").show();
    loadTable();
});

function loadTable(){
    $.ajax({
        url: "/api/acr/accepting/my",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')}, // ✅ cookie auth fix
        success: function(res){
            console.log(res);
            dataList=res.Data.AcrCycles || [];
            filtered=[...dataList];
            renderTable();
        },
        error: function(err){
            console.error(err);
            alert("Failed to load data (check auth)");
        }
    });
}

function formatDate(dateStr){
    if(!dateStr) return '-';
    let d = new Date(dateStr);
    return d.toLocaleDateString('en-GB'); // dd/mm/yyyy
}

function renderTable(){
    let start=(currentPage-1)*pageSize;
    let pageData=filtered.slice(start,start+pageSize);
    let html="";

    if(pageData.length===0){
        html=`<tr><td colspan="5" class="text-center text-muted">No entries found</td></tr>`;
    }else{
        pageData.forEach(x=>{
            html+=`<tr>
            <td>${x.OfficerName}</td>
            <td>${x.Location || '-'}</td>
            <td>${formatDate(x.PostingFrom)}</td>
            <td>${formatDate(x.PostingTo)}</td>
            <td>${x.AcrYear}</td>
            <td><span class="badge ${x.Status==='PENDING_ACCEPTING'?'bg-warning':'bg-success'}">${x.Status}</span></td>
            <td>
            <button class="btn btn-sm btn-info" onclick="openAcr('${x.AcrId}')">
            <i class="bi bi-eye"></i> View
            </button>
            </td>
            </tr>`;
        });
    }

    $("#acrTableBody").html(html);
    if(filtered.length === 0){
        $("#tableInfo").text("");
    } else {
        $("#tableInfo").text(
            `Showing ${start+1} to ${Math.min(start+pageSize,filtered.length)} of ${filtered.length} entries`
        );
    }
    renderPagination();
}

function renderPagination(){
    const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
    let html = '';
    // PREV BUTTON
    html += `<li class="page-item ${currentPage==1?'disabled':''}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage-1})">
                    Prev
                </a>
             </li>`;
    // PAGE NUMBERS
    for(let i=1;i<=totalPages;i++){
        html += `<li class="page-item ${i==currentPage?'active':''}">
                    <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${i})">
                        ${i}
                    </a>
                 </li>`;
    }
    // NEXT BUTTON
    html += `<li class="page-item ${currentPage==totalPages?'disabled':''}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage+1})">
                    Next
                </a>
             </li>`;
    $("#pagination").html(html);
}

// function gotoPage(p){currentPage=p;renderTable();}
function gotoPage(p){

    const totalPages = Math.ceil(filtered.length / pageSize);

    if(p < 1 || p > totalPages) return;

    currentPage = p;
    renderTable();
}

function changePageSize(){pageSize=parseInt($("#pageSize").val());currentPage=1;renderTable();}

function searchTable(val){
    val=val.toLowerCase();
    filtered=dataList.filter(x=>x.OfficerName.toLowerCase().includes(val));
    currentPage=1;
    renderTable();
}

function openAcr(id){
    currentAcrId=id;

    $.ajax({
        url:`/api/acr/${id}/accepting`,
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            let d=res.Data;

            // Info Tab
            $("#infoOfficer").val(d.Officer.DisplayName);
            $("#infoYear").val(d.AcrYear);
            $("#infoStatus").val(d.Status);
            $("#infoLocation").val(d.Location);
            $("#infoFrom").val(formatDate(d.PostingFrom));
            $("#infoTo").val(formatDate(d.PostingTo));

            // REPORTING TAB - RA1 Data
            const ra1 = d.Ra1Assessment || {};
            $("#ra1Targets").val(safeRating(ra1.WorkTargets));
            $("#ra1Quality").val(safeRating(ra1.WorkQuality));
            $("#ra1Overall").val(safeRating(ra1.OverallGrade));
            $("#ra1Remarks").val(ra1.Remarks || '');

            // REPORTING TAB - RA2 Data
            const ra2 = d.Ra2Assessment || {};
            if(ra2.Exists){
                $("#ra2Section").show();
                $("#ra2Targets").val(safeRating(ra2.WorkTargets));
                $("#ra2Quality").val(safeRating(ra2.WorkQuality));
                $("#ra2Overall").val(safeRating(ra2.OverallGrade));
                $("#ra2Remarks").val(ra2.Remarks || '');
            } else {
                $("#ra2Section").hide();
            }

            // REVIEWING TAB Data
            const review = d.ReviewingAssessment || {};
            $("#reviewAgree").val(review.AgreeWithRa === true ? 'Yes' : review.AgreeWithRa === false ? 'No' : '-');
            $("#reviewGrade").val(safeRating(review.OverallGrade));
            $("#reviewDisagree").val(review.DisagreeDetails || '');
            $("#reviewComments").val(review.Comments || '');
            $("#reviewSubmittedAt").text(review.SubmittedAt ? new Date(review.SubmittedAt).toLocaleString() : 'Not Submitted');

            let readOnly=d.Status!=="PENDING_ACCEPTING";
            toggleViewOnly(readOnly);

            modal.show();
        },
        error:function(err){
            console.error(err);
            alert("Failed to load details");
        }
    });
}

function safeRating(val){
    if(val === null || val === undefined || val === '') return '-';
    if(val > 10) return 10;
    if(val < 1) return 1;
    return val;
}

function toggleViewOnly(flag){
    $("#acceptingTab input, #acceptingTab textarea, #acceptingTab select").prop("disabled",flag);
    if(flag){$("#submitAA").hide();$("#readonlyMsg").show();}
    else{$("#submitAA").show();$("#readonlyMsg").hide();}
}

$("#submitAA").click(function(){

    if(!confirm("Final submit? Cannot edit later")) return;

    let payload={
        AgreeWithPrevious: $("#aaAgree").val()==="true",
        DisagreeDetails: $("#aaDisagree").val(),
        ConflictResolved:false,
        FinalGrade:Number($("#aaGrade").val()),
        FinalRemarks:$("#aaRemarks").val(),
        IsApproved: $("#aaDecision").val()==="true"
    };

    $.ajax({
        url:`/api/acr/${currentAcrId}/accepting/submit`,
        type:"POST",
        contentType:"application/json",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        data:JSON.stringify(payload),
        success:function(){
            alert("Submitted successfully");
            location.reload();
        },
        error:function(err){
            console.error(err);
            alert("Submit failed");
        }
    });

});

</script>

</asp:Content>