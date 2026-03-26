<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<script src="<%= Url.Content("~/assets/js/shared/constant.js") %>"></script>
<link href="<%= Url.Content("~/assets/js/lib/bootstrap.min.css") %>" rel="stylesheet">
<link href="<%= Url.Content("~/assets/js/lib/bootstrap-icons.css") %>" rel="stylesheet">
<script src="<%= Url.Content("~/assets/js/lib/bootstrap.bundle.min.js") %>"></script>
<script src="<%= Url.Content("~/assets/js/lib/jquery-3.7.1.min.js") %>"></script>

<style>
    .page-title {
        color: #0d6efd;
        font-weight: 700;
    }

    .page-block {
        background: #fff;
        border: 1px solid #e9ecef;
        border-radius: 12px;
    }

    .section-card {
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        padding: 16px;
        background: #fff;
    }

    .rating-card {
        border: 1px solid #e9ecef;
        border-radius: 10px;
        background: #fff;
        padding: 14px;
        height: 100%;
    }

    .rating-card h5 {
        color: #0d6efd;
        font-size: 16px;
        margin-bottom: 14px;
        font-weight: 600;
    }

    #reviewingTable th {
        white-space: nowrap;
        user-select: none;
        cursor: pointer;
    }

    #reviewingTable td {
        vertical-align: middle;
    }

    .modal-content {
        border: 0;
        border-radius: 12px;
        overflow: hidden;
    }

    .modal-header.bg-primary {
        background: linear-gradient(90deg, #0d6efd, #0b5ed7) !important;
    }

    .nav-tabs .nav-link {
        font-weight: 600;
    }

    .nav-tabs .nav-link.active {
        color: #0d6efd;
        border-color: #dee2e6 #dee2e6 #fff;
    }

    #reviewPagination .page-link {
        cursor: pointer;
    }
</style>

<div class="container-fluid px-0" id="reviewingDiv" style="display:none;">
    <h2 class="mb-4 page-title">Reviewing Authority Dashboard</h2>

    <div class="card shadow-sm border-0 page-block">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h5 class="mb-0 text-primary">
                    <i class="bi bi-table"></i> Reviewing Queue
                </h5>
                <div class="d-flex gap-2 flex-wrap">
                    <input type="text" id="reviewSearch" class="form-control" placeholder="Search ACR..." style="width:260px;">
                    <select id="reviewPageSizeSelect" class="form-select" style="width:110px;">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0" id="reviewingTable">
                    <thead class="table-primary">
                        <tr>
                            <th onclick="sortReviewingTable('FormType')">Form Type</th>
                            <th onclick="sortReviewingTable('OfficerName')">Officer</th>
                            <th onclick="sortReviewingTable('Location')">Location</th>
                            <th onclick="sortReviewingTable('Status')">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="reviewingBody"></tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
                <div id="reviewTableInfo" class="small text-muted"></div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="reviewPagination"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div class="modal fade" id="reviewingModal">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Reviewing Assessment</h5>
                <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">

                <!-- TABS -->
                <ul class="nav nav-tabs">
                    <li class="nav-item">
                        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#infoTab">ACR Info</button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#raTab">
                            Reporting Details
                        </button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#reviewTab">Reviewing</button>
                    </li>
                </ul>

                <div class="tab-content mt-3">

                    <!-- INFO TAB -->
                    <div class="tab-pane fade show active" id="infoTab">
                        <div class="section-card">
                            <div class="row g-3">
    
                                <div class="col-md-6"><label class="form-label fw-bold">Form Type</label><input class="form-control" id="infoFormType" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Status</label><input class="form-control" id="infoStatus" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Officer</label><input class="form-control" id="infoOfficer" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Location</label><input class="form-control" id="infoLocation" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Designation</label><input class="form-control" id="infoDesignation" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Posting From</label><input class="form-control" id="infoPostingFrom" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Posting To</label><input class="form-control" id="infoPostingTo" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">ACR Year</label><input class="form-control" id="infoAcrYear" readonly></div>
    
                                <!-- SAME AS OFFICER -->
                                <!-- <div class="col-md-6"><label class="form-label fw-bold">Department</label><input class="form-control" id="infoDepartment" readonly></div> -->
                                <div class="col-md-6"><label class="form-label fw-bold">Date Of Birth</label><input class="form-control" id="infoDOB" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Date Joining Nigam</label><input class="form-control" id="infoJoinNigam" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Joining Present Rank</label><input class="form-control" id="infoJoinRank" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Joining Present Station</label><input class="form-control" id="infoJoinStation" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Academic Qualification</label><input class="form-control" id="infoAcademic" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Technical Qualification</label><input class="form-control" id="infoTechnical" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Dept Exam Passed</label><input class="form-control" id="infoDeptExam" readonly></div>
    
                                <div class="col-md-6"><label class="form-label fw-bold">Property Return Date</label><input class="form-control" id="infoPropertyReturn" readonly></div>
                                <div class="col-md-6"><label class="form-label fw-bold">Last Medical Exam</label><input class="form-control" id="infoMedicalExam" readonly></div>
    
                                <div class="col-md-12"><label class="form-label fw-bold">Career Posting Summary</label><textarea class="form-control" id="infoCareerSummary" readonly></textarea></div>
    
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="raTab">
                        <div class="rating-card">
                            <h5>RA1 Assessment</h5>
                            <div class="row g-3">
                                <div class="col-md-4"><label>Targets</label><input id="ra1Targets" class="form-control" readonly></div>
                                <div class="col-md-4"><label>Quality</label><input id="ra1Quality" class="form-control" readonly></div>
                                <div class="col-md-4"><label>Overall</label><input id="ra1Overall" class="form-control" readonly></div>
                            </div>
                            <div class="mt-3">
                                <label>Remarks</label>
                                <textarea id="ra1Remarks" class="form-control" readonly></textarea>
                            </div>
                        </div>

                        <div id="ra2Section" style="display:none;" class="mt-3">
                            <div class="rating-card">
                                <h5>Second Reporting Officer (RA2)</h5>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label>Targets</label>
                                        <input id="ra2Targets" class="form-control" readonly>
                                    </div>
                                    <div class="col-md-4">
                                        <label>Quality</label>
                                        <input id="ra2Quality" class="form-control" readonly>
                                    </div>
                                    <div class="col-md-4">
                                        <label>Overall</label>
                                        <input id="ra2Overall" class="form-control" readonly>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <label>Remarks</label>
                                    <textarea id="ra2Remarks" class="form-control" readonly></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- REVIEW TAB -->
                    <div class="tab-pane fade" id="reviewTab">
                        <div class="section-card">
                            <div class="alert alert-info mt-2" id="readonlyMsg" style="display:none;">
                                This ACR is under accepting authority. You cannot edit now.
                            </div>
                            <!-- Q1 -->
                            <div class="mb-3">
                                <label class="form-label">
                                    1. Do you agree with the assessment... <span class="text-danger">*</span>
                                </label>
    
                                <div>
                                    <input type="radio" name="agree" value="true"> Yes
                                    <input type="radio" name="agree" value="false" class="ms-3"> No
                                </div>
    
                                <small class="text-muted">
                                    If not agree, update values in respective section.
                                </small>
                            </div>
    
                            <!-- Q2 -->
                            <div class="mb-3">
                                <label class="form-label">
                                    2. Difference of opinion (Reason) <span class="text-danger">*</span>
                                </label>
                                <textarea id="txtReason" class="form-control"></textarea>
                            </div>
    
                            <!-- Q3 -->
                            <div class="mb-3">
                                <label class="form-label">
                                    3. Comments of Reviewing Authority
                                </label>
                                <textarea id="txtComments" class="form-control"></textarea>
                            </div>
    
                            <!-- Q4 -->
                            <div class="mb-3">
                                <label class="form-label">
                                    4. Overall Grade (1-10) <span class="text-danger">*</span>
                                </label>
                                <input type="number" id="txtGrade" class="form-control" min="1" max="10">
                            </div>
    
                            <!-- BUTTONS -->
                            <div class="text-end">
                                <button class="btn btn-secondary" id="saveDraft">Save Draft</button>
                                <button class="btn btn-success" id="submitReview">Submit</button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script>

let selectedAcrId = null;
let draftSaved = false;
let reviewingData = [];
let filteredReviewing = [];
let reviewPageSize = 10;
let reviewCurrentPage = 1;
let isDirty = false;

let reviewSortColumn = "";
let reviewSortAsc = true;

$(document).ready(function(){
    $("#reviewingDiv").show();
    $("#reviewSearch").on("input", function () {
        searchReviewingQueue($(this).val());
    });
    $("#reviewPageSizeSelect").on("change", function () {
        changeReviewPageSize();
    });
    loadReviewingQueue();
});


function changeReviewPageSize(){
    reviewPageSize = parseInt($("#reviewPageSizeSelect").val());
    reviewCurrentPage = 1;
    renderReviewingTable();
}

function updateReviewInfo(start, end){
    const total = filteredReviewing.length;

    if(total === 0){
        $("#reviewTableInfo").text("");
        return;
    }

    $("#reviewTableInfo").text(
        `Showing ${start+1} to ${Math.min(end,total)} of ${total} entries`
    );
}

function searchReviewingQueue(value){
    value = (value || "").toLowerCase().trim();
    if (!value) {
        filteredReviewing = [...reviewingData];
    } else {
        filteredReviewing = reviewingData.filter(a => {
            return (
                (a.FormType || "").toLowerCase().includes(value) ||
                (a.OfficerName || "").toLowerCase().includes(value) ||
                (a.Location || "").toLowerCase().includes(value) ||
                (a.Status || "").toLowerCase().includes(value)
            );
        });
    }
    reviewCurrentPage = 1;
    renderReviewingTable();
}

function gotoReviewPage(p){
    const totalPages = Math.ceil(filteredReviewing.length / reviewPageSize);

    if(p < 1 || p > totalPages) return;

    reviewCurrentPage = p;
    renderReviewingTable();
}

function renderReviewPagination() {
    const totalPages = Math.ceil(filteredReviewing.length / reviewPageSize);
    const container = $("#reviewPagination");
    container.empty();

    if (totalPages <= 1) return;

    const prevDisabled = reviewCurrentPage === 1 ? "disabled" : "";
    container.append(`
        <li class="page-item ${prevDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="gotoReviewPage(${reviewCurrentPage - 1})">Previous</a>
        </li>
    `);

    const startPage = Math.max(1, reviewCurrentPage - 2);
    const endPage = Math.min(totalPages, reviewCurrentPage + 2);

    if (startPage > 1) {
        container.append(`<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="gotoReviewPage(1)">1</a></li>`);
        if (startPage > 2) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
    }

    for (let i = startPage; i <= endPage; i++) {
        const active = i === reviewCurrentPage ? "active" : "";
        container.append(`
            <li class="page-item ${active}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoReviewPage(${i})">${i}</a>
            </li>
        `);
    }

    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
        container.append(`
            <li class="page-item">
                <a class="page-link" href="javascript:void(0)" onclick="gotoReviewPage(${totalPages})">${totalPages}</a>
            </li>
        `);
    }

    const nextDisabled = reviewCurrentPage === totalPages ? "disabled" : "";
    container.append(`
        <li class="page-item ${nextDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="gotoReviewPage(${reviewCurrentPage + 1})">Next</a>
        </li>
    `);
}

// Using getCommonStatusBadge from constant.js
var getReviewStatusBadge = getCommonStatusBadge;

function renderReviewingTable() {
    const tbody = $("#reviewingBody");
    tbody.empty();

    const start = (reviewCurrentPage - 1) * reviewPageSize;
    const end = start + reviewPageSize;
    const pageData = filteredReviewing.slice(start, end);

    if (pageData.length === 0) {
        tbody.append(`<tr><td colspan="5" class="text-center">No entries found</td></tr>`);
    } else {
        pageData.forEach(a => {
            tbody.append(`<tr>
                <td>${a.FormType || ''}</td>
                <td>${a.OfficerName || ''}</td>
                <td>${a.Location || ''}</td>
                <td>${getReviewStatusBadge(a.Status)}</td>
                <td><button class="btn btn-info btn-sm" onclick="openReview('${a.AcrId}')">View</button></td>
            </tr>`);
        });
    }

    updateReviewInfo(start, end);
    renderReviewPagination();
}

function loadReviewingQueue() {
    $.ajax({
        url: BASE_URL + "api/acr/reviewing/my",
        headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
        success: function (res) {
            if (res.Success) {
                reviewingData = (res.Data && res.Data.AcrCycles) ? res.Data.AcrCycles : [];
                filteredReviewing = [...reviewingData];
                reviewCurrentPage = 1;
                reviewSortColumn = "OfficerName";
                reviewSortAsc = true;
                sortReviewingTable("OfficerName");
            }
        }
    });
}

function formatDate(d){
    if(!d) return '';
    return new Date(d).toLocaleDateString('en-GB');
}

let reviewingModal = new bootstrap.Modal(document.getElementById('reviewingModal'));

function openReview(id){
    selectedAcrId = id;
    draftSaved = false;
    isDirty = false;
    
    $("#txtReason, #txtComments, #txtGrade").val('');
    $("input[name='agree']").prop("checked", false);
    $("#txtReason").prop("disabled", false);

    $("#ra1Targets, #ra1Quality, #ra1Overall, #ra1Remarks").val('');
    $("#ra2Targets, #ra2Quality, #ra2Overall, #ra2Remarks").val('');
    $("#ra2Section").hide();

    $.ajax({
        url: BASE_URL + "api/acr/"+id+"/reviewing",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            const d = res.Data;

            const ra1 = d.Ra1Assessment || {};
            // $("#ra1Targets").val(ra1.WorkTargets);
            $("#ra1Targets").val(safeRating(ra1.WorkTargets));
            $("#ra1Quality").val(safeRating(ra1.WorkQuality));
            $("#ra1Overall").val(safeRating(ra1.OverallGrade));
            $("#ra1Remarks").val(ra1.Remarks);

            const ra2 = d.Ra2Assessment || {};
            if(ra2.Exists){
                $("#ra2Section").show();

                $("#ra2Targets").val(safeRating(ra2.WorkTargets));
                $("#ra2Quality").val(safeRating(ra2.WorkQuality));
                $("#ra2Overall").val(safeRating(ra2.OverallGrade));
                $("#ra2Remarks").val(ra2.Remarks);
            } else {
                $("#ra2Section").hide();
            }

            $("#infoOfficer").val(d.Officer.DisplayName);
            $("#infoStatus").val(d.Status);
            $("#infoFormType").val(d.FormType || '');
            $("#infoLocation").val(d.Location || '');
            $("#infoDesignation").val(d.Designation || '');
            $("#infoAcrYear").val(d.AcrYear || '');

            $("#infoPostingFrom").val(formatDate(d.PostingFrom));
            $("#infoPostingTo").val(formatDate(d.PostingTo));
            $("#infoJoinNigam").val(formatDate(d.DateJoiningNigam));
            $("#infoJoinRank").val(formatDate(d.DateJoiningPresentRank));
            $("#infoJoinStation").val(formatDate(d.DateJoiningPresentStation));
            $("#infoPropertyReturn").val(formatDate(d.PropertyReturnDate));
            $("#infoMedicalExam").val(formatDate(d.LastMedicalExamDate));

            $("#infoDOB").val(formatDate(d.DateOfBirth));
            $("#infoAcademic").val(d.AcademicQualification || '');
            $("#infoTechnical").val(d.TechnicalQualification || '');
            $("#infoDeptExam").val(d.DepartmentalExamPassed || '');
            $("#infoCareerSummary").val(d.CareerPostingSummary || '');
            if(d.Status === "PENDING_ACCEPTING"){
                setReviewReadOnly(true);
            } else {
                setReviewReadOnly(false);
            }

            const ra = d.ReviewingAssessment || {};
            $("input[name='agree']").prop("checked", false);

            if(ra.AgreeWithRa !== null && ra.AgreeWithRa !== undefined){
                $("input[name='agree'][value='"+String(ra.AgreeWithRa)+"']").prop("checked", true);
            }

            /* 🔥 YEH CODE YAHA ADD KARNA HAI */
            if(ra.AgreeWithRa === true){
                $("#txtReason").prop("disabled", true);
            } else {
                $("#txtReason").prop("disabled", false);
            }

            $("#txtReason").val(ra.DisagreeDetails);
            $("#txtComments").val(ra.Comments);
            $("#txtGrade").val(ra.OverallGrade);

            reviewingModal.show();
        }
    });
}

function validateForm(){
    let valid = true;

    const agree = $("input[name='agree']:checked").val();
    const reason = $("#txtReason").val().trim();
    const grade = Number($("#txtGrade").val());

    $("#txtReason, #txtGrade").removeClass("is-invalid");

    if (!agree) {
        alert("Please select Yes or No.");
        return false;
    }

    if (agree === "false" && !reason) {
        $("#txtReason").addClass("is-invalid");
        valid = false;
    }

    if (!grade || grade < 1 || grade > 10) {
        $("#txtGrade").addClass("is-invalid");
        valid = false;
    }
    return valid;
}

$("#saveDraft").click(function(e){
    e.preventDefault();
    if ($("#saveDraft").is(":hidden")) return;
    const agreeVal = $("input[name='agree']:checked").val();
    const payload = {
        AgreeWithRa: agreeVal ? (agreeVal === "true") : null,
        DisagreeDetails: $("#txtReason").val(),
        Comments: $("#txtComments").val(),
        OverallGrade: $("#txtGrade").val() ? Number($("#txtGrade").val()) : null
    };
    $.ajax({
        url: BASE_URL + "api/acr/" + selectedAcrId + "/reviewing/draft",
        type: 'PATCH',
        contentType: 'application/json',
        data: JSON.stringify(payload),
        headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
        success: function (res) {
            alert(res.Message);
            draftSaved = true;
            isDirty = false;
        }
    });
});

$("#submitReview").click(function(e){
    e.preventDefault();

    if($("#submitReview").is(":hidden")) return;
    if(isDirty && !draftSaved){
        alert("Save draft before submitting");
        return;
    }

    if(!validateForm()) return;

    $.ajax({
        url: BASE_URL+"api/acr/"+selectedAcrId+"/reviewing/submit",
        type:'POST',
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            alert(res.Message);
            reviewingModal.hide();
            loadReviewingQueue();
            draftSaved = false;
            isDirty = false;
        }
    });
});

function safeRating(val){
    if(val === null || val === undefined) return '';
    if(val > 10) return 10;
    if(val < 1) return 1;
    return val;
}

$("#txtGrade").on("input", function(){

    let val = Number($(this).val());

    if(val < 1 || val > 10){
        alert("Grade must be between 1 and 10");
        $(this).val('');
    }
});

$("#reviewTab input, #reviewTab textarea").on("input change", function(){
    if($(this).prop("disabled")) return;
    isDirty = true;
});

$("input[name='agree']").change(function(){
    if($(this).val() === "false"){
        $("#txtReason").prop("disabled", false);
        $("#txtReason").closest('.mb-3').find('span').show();
    } else {
        $("#txtReason").prop("disabled", true).val('');
        $("#txtReason").closest('.mb-3').find('span').hide();
    }
});

function setReviewReadOnly(isReadOnly){

    $("#reviewTab input, #reviewTab textarea").prop("disabled", isReadOnly);

    if(isReadOnly){
        $("#saveDraft").hide();
        $("#submitReview").hide();
        $("#readonlyMsg").show(); // ✅ ADD
    } else {
        $("#saveDraft").show();
        $("#submitReview").show();
        $("#readonlyMsg").hide(); // ✅ ADD
    }
}

function sortReviewingTable(col) {
    reviewSortAsc = (reviewSortColumn === col) ? !reviewSortAsc : true;
    reviewSortColumn = col;

    filteredReviewing.sort((a, b) => {
        let x = (a[col] || "").toString().toLowerCase();
        let y = (b[col] || "").toString().toLowerCase();

        if (x > y) return reviewSortAsc ? 1 : -1;
        if (x < y) return reviewSortAsc ? -1 : 1;
        return 0;
    });

    renderReviewingTable();
}
</script>

</asp:Content>