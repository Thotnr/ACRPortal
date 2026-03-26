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

    #reportingQueueTable th {
        white-space: nowrap;
        user-select: none;
        cursor: pointer;
    }

    #reportingQueueTable td {
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

    .form-label.fw-bold {
        color: #344054;
    }

    .section-card {
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        padding: 16px;
        background: #fff;
    }

    #reportingPagination .page-link,
    #paginationContainer .page-link {
        cursor: pointer;
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

    .page-block {
        background: #fff;
        border: 1px solid #e9ecef;
        border-radius: 12px;
    }
</style>

<div class="container-fluid px-0" id="employeeReportingDiv" style="display:none;">
    <h2 class="mb-4 page-title">Reporting Authority Dashboard</h2>

    <div class="card shadow-sm border-0 page-block">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h5 class="mb-0 text-primary">
                    <i class="bi bi-table"></i> Reporting Queue
                </h5>
                <div class="d-flex gap-2 flex-wrap">
                    <!-- <input type="text" id="reportSearch" class="form-control" placeholder="Search ACR..." style="width:260px;"> -->
                    <input type="text" id="acrSearchBox" class="form-control" placeholder="Search ACR..." style="width:260px;">
                    <select id="reportPageSizeSelect" class="form-select" style="width:110px;">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0" id="reportingQueueTable">
                    <thead class="table-primary">
                        <tr>
                            <th onclick="sortReportingTable('FormType')">Form Type</th>
                            <th onclick="sortReportingTable('OfficerName')">Officer</th>
                            <th onclick="sortReportingTable('Location')">Location</th>
                            <th onclick="sortReportingTable('Dsg')">Designation</th>
                            <th onclick="sortReportingTable('PostingFrom')">Posting From</th>
                            <th onclick="sortReportingTable('PostingTo')">Posting To</th>
                            <th onclick="sortReportingTable('Status')">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="reportingQueueBody"></tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
        <div id="reportTableInfo" class="small text-muted"></div>
        <nav>
            <ul class="pagination pagination-sm mb-0" id="reportingPagination"></ul>
        </nav>
    </div>

    <!-- Reporting Modal -->
    <div class="modal fade" id="reportingModal" tabindex="-1" aria-labelledby="reportingLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="reportingLabel"><i class="bi bi-file-earmark-text"></i> Reporting Assessment</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <!-- Tabs -->
                    <ul class="nav nav-tabs" id="reportTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#infoTab" type="button" role="tab">ACR Info</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="assessment-tab" data-bs-toggle="tab" data-bs-target="#assessmentTab" type="button" role="tab">Reporting Assessment</button>
                        </li>
                        <!-- <li class="nav-item" role="presentation">
                            <button class="nav-link" id="documents-tab" data-bs-toggle="tab" data-bs-target="#documentsTab" type="button" role="tab">Documents</button>
                        </li> -->
                    </ul>

                    <div class="tab-content mt-3">
                        <!-- Info Tab -->
                        <div class="tab-pane fade show active" id="infoTab" role="tabpanel">
                            <div class="section-card">
                                <div class="row g-3">
    
                                    <div class="col-6"><label class="form-label fw-bold">Form Type</label><input type="text" id="infoFormType" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Status</label><input type="text" id="infoStatus" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Officer Name</label><input type="text" id="infoOfficerName" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Location</label><input type="text" id="infoLocation" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Designation</label><input type="text" id="infoDesignation" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Posting From</label><input type="text" id="infoPostingFrom" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Posting To</label><input type="text" id="infoPostingTo" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">ACR Year</label><input type="text" id="infoAcrYear" class="form-control" readonly></div>
    
                                    <!-- NEW FIELDS (same as Officer) -->
                                    <!-- <div class="col-6"><label class="form-label fw-bold">Department</label><input type="text" id="infoDepartment" class="form-control" readonly></div> -->
                                    <div class="col-6"><label class="form-label fw-bold">Date Of Birth</label><input type="text" id="infoDOB" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Date Joining Nigam</label><input type="text" id="infoJoinNigam" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Joining Present Rank</label><input type="text" id="infoJoinRank" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Joining Present Station</label><input type="text" id="infoJoinStation" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Academic Qualification</label><input type="text" id="infoAcademic" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Technical Qualification</label><input type="text" id="infoTechnical" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Dept Exam Passed</label><input type="text" id="infoDeptExam" class="form-control" readonly></div>
    
                                    <div class="col-6"><label class="form-label fw-bold">Property Return Date</label><input type="text" id="infoPropertyReturn" class="form-control" readonly></div>
                                    <div class="col-6"><label class="form-label fw-bold">Last Medical Exam</label><input type="text" id="infoMedicalExam" class="form-control" readonly></div>
                                    <div class="col-12"><label class="form-label fw-bold">Career Posting Summary</label><textarea id="infoCareerSummary" class="form-control" readonly></textarea></div>
                                </div>
                            </div>
                        </div>

                        <!-- Assessment Tab -->
                        <div class="tab-pane fade" id="assessmentTab" role="tabpanel">
                            <div class="row g-3 mt-2">
                                <div class="col-md-4"><label class="form-label">
                                        Agree With Self-Appraisal <span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select" id="agreeWithSelf">
                                        <option value="">Select</option>
                                        <option value="true">Yes</option>
                                        <option value="false">No</option>
                                    </select>
                                </div>
                                <div class="col-md-8"><label class="form-label">Disagree Details</label><textarea class="form-control" id="disagreeDetails" rows="2"></textarea></div>
                                <div class="col-md-12"><label class="form-label">Integrity Comments <span class="text-danger">*</span></label><textarea class="form-control" id="integrityComments" rows="2"></textarea></div>
                                <div class="col-md-12"><label class="form-label">Remarks</label><textarea class="form-control" id="remarks" rows="2"></textarea></div>
                            </div>

                            <!-- Rating Section (Work / Attributes / Competence) -->
                            <div class="alert alert-info mt-3">
                                Note: All ratings must be between <b>1 to 10</b>. Overall grade is auto-calculated.
                            </div>
                            <div class="row mt-3">
                                <div class="col-12">
                                    <div class="rating-card">
                                        <h5>Work Performance</h5>
                                        <div class="row g-3">
                                            <div class="col-md-3"><label>Targets</label><input type="number" min="1" max="10" class="form-control rating-field" id="workTargets"></div>
                                            <div class="col-md-3"><label>Quality</label><input type="number" min="1" max="10" class="form-control rating-field" id="workQuality"></div>
                                            <div class="col-md-3"><label>Exceptional</label><input type="number" min="1" max="10" class="form-control rating-field" id="workExceptional"></div>
                                            <div class="col-md-3"><label>Overall</label><input type="number" step="0.01" class="form-control" id="workOverall" readonly></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-3">
                                <div class="col-12">
                                    <div class="rating-card">
                                        <h5>Attributes</h5>
                                        <div class="row g-3">
                                            <div class="col-md-3"><label>Attitude</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrAttitude"></div>
                                            <div class="col-md-3"><label>Responsibility</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrResponsibility"></div>
                                            <div class="col-md-3"><label>Stability</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrStability"></div>
                                            <div class="col-md-3"><label>Communication</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrCommunication"></div>
                                            <div class="col-md-3"><label>Moral Courage</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrMoralCourage"></div>
                                            <div class="col-md-3"><label>Leadership</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrLeadership"></div>
                                            <div class="col-md-3"><label>Timeliness</label><input type="number" min="1" max="10" class="form-control rating-field" id="attrTimeliness"></div>
                                            <div class="col-md-3"><label>Overall</label><input type="number" step="0.01" class="form-control" id="attrOverall" readonly></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-3">
                                <div class="col-12">
                                    <div class="rating-card">
                                        <h5>Competence</h5>
                                        <div class="row g-3">
                                            <div class="col-md-3"><label>Knowledge</label><input type="number" min="1" max="10" class="form-control rating-field" id="compKnowledge"></div>
                                            <div class="col-md-3"><label>Planning</label><input type="number" min="1" max="10" class="form-control rating-field" id="compPlanning"></div>
                                            <div class="col-md-3"><label>Decision</label><input type="number" min="1" max="10" class="form-control rating-field" id="compDecision"></div>
                                            <div class="col-md-3"><label>Initiative</label><input type="number" min="1" max="10" class="form-control rating-field" id="compInitiative"></div>
                                            <div class="col-md-3"><label>Teamwork</label><input type="number" min="1" max="10" class="form-control rating-field" id="compTeamwork"></div>
                                            <div class="col-md-3"><label>Overall</label><input type="number" step="0.01" class="form-control" id="compOverall" readonly></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-3">
                                <div class="col-md-3"><label>Overall Grade</label><input type="number" step="0.01" class="form-control" id="overallGrade" readonly></div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <button class="btn btn-primary" id="saveDraftBtn"><i class="bi bi-save"></i> Save Draft</button>
                                <button class="btn btn-success" id="submitBtn"><i class="bi bi-send"></i> Submit Assessment</button>
                            </div>
                        </div>

                        <!-- Documents Tab -->
                        <!-- <div class="tab-pane fade" id="documentsTab" role="tabpanel">
                            <div class="row g-3 mt-2">
                                <div class="col-md-6">
                                    <input type="file" id="docFile" class="form-control">
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="docType">
                                        <option value="SUPPORTING_DOC">Supporting Doc</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-primary" id="uploadDocBtn"><i class="bi bi-upload"></i> Upload</button>
                                </div>
                            </div>
                            <ul class="list-group mt-3" id="docList"></ul>
                        </div> -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>

    let reportingData = [];
    let filteredReporting = [];
    let reportPageSize = 10;
    let reportCurrentPage = 1;
    let reportSortColumn = "";
    let reportSortAsc = true;

$(document).ready(function(){
    const role = localStorage.getItem('role');
    if (role !== "EMPLOYEE") {
        alert("Access denied. Only EMPLOYEE can access this page.");
        window.location.href = BASE_URL + "Home/Dashboard";
        return;
    }

    $("#employeeReportingDiv").show();

    $("#acrSearchBox").on("input", function () {
        searchReportingQueue($(this).val());
    });

    $("#reportPageSizeSelect").on("change", function () {
        changeReportingPageSize();
    });

    loadReportingQueue();
});

let selectedAcrId = null;
let draftSaved = false;

function loadReportingQueue(){
    $.ajax({
        url: BASE_URL + "api/acr/reporting/my",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success: function(res){
            if(res.Success){
                reportingData = res.Data.AcrCycles;
                filteredReporting = [...reportingData];
                reportCurrentPage = 1;
                reportSortColumn = "OfficerName";
                reportSortAsc = true;
                filteredReporting.sort((a, b) => ((a.OfficerName || "").localeCompare(b.OfficerName || "")));
                renderReportingTable();
            } else alert(res.Message);
        }
    });
}

$("#agreeWithSelf").change(function(){
    if($(this).val() === "false"){
        $("#disagreeDetails").prop("disabled", false);
    } else {
        $("#disagreeDetails").prop("disabled", true).val('');
    }
});

function validateReportingForm() {

    let isValid = true;

    function setError(id, message) {
        const el = $("#" + id);
        el.addClass("is-invalid");
        if (el.next(".invalid-feedback").length === 0) {
            el.after(`<div class="invalid-feedback">${message}</div>`);
        }
        isValid = false;
    }

    function clearErrors() {
        $(".form-control, .form-select").removeClass("is-invalid");
        $(".invalid-feedback").remove();
    }

    clearErrors();

    // ✅ Agree With Self (Required)
    const agree = $("#agreeWithSelf").val();
    if (!agree) {
        setError("agreeWithSelf", "Required");
    }

    // ✅ If NO → Disagree Details Required
    if (agree === "false" && !$("#disagreeDetails").val().trim()) {
        setError("disagreeDetails", "Required when disagreeing");
    }

    // ✅ Integrity (Required)
    if (!$("#integrityComments").val().trim()) {
        setError("integrityComments", "Required");
    }

    // ❌ Remarks → optional (because “if any”)

    // ✅ Ratings Validation (1–10 required)
    $(".rating-field").each(function () {
        const val = $(this).val();
        if (!val || val < 1 || val > 10) {
            $(this).addClass("is-invalid");
            isValid = false;
        }
    });

    return isValid;
}

function renderReportingTable(){
    const tbody = $("#reportingQueueBody");
    tbody.empty();

    const start = (reportCurrentPage-1) * reportPageSize;
    const end = start + reportPageSize;
    const pageData = filteredReporting.slice(start, end);

    if(pageData.length === 0){
        // Show "No entries found" inside table body
        tbody.append(`<tr><td colspan="8" class="text-center text-muted">No entries found</td></tr>`);
    } else {
        pageData.forEach(a => {
            tbody.append(`<tr>
                <td>${a.FormType || ''}</td>
                <td>${a.OfficerName || ''}</td>
                <td>${a.Location || ''}</td>
                <td>${a.Dsg || ''}</td>
                <td>${a.PostingFrom || ''}</td>
                <td>${a.PostingTo || ''}</td>
                <td>${getReportingStatusBadge(a.Status)}</td>
                <td><button class="btn btn-sm btn-info" onclick="viewReportingAcr('${a.AcrId}')"><i class="bi bi-eye"></i> View</button></td>
            </tr>`);
        });
    }

    updateReportingInfo(start, end);
    renderReportingPagination();
}

function updateReportingInfo(start, end){
    const total = filteredReporting.length;
    if(total==0){
        $("#reportTableInfo").text(""); // clear info when no data
        return;
    }
    $("#reportTableInfo").text(`Showing ${start+1} to ${Math.min(end,total)} of ${total} entries`);
}

function renderReportingPagination(){
    const totalPages = Math.ceil(filteredReporting.length / reportPageSize);
    const container = $("#reportingPagination");
    container.empty();

    if (totalPages <= 1) return;

    const prevDisabled = reportCurrentPage === 1 ? "disabled" : "";
    container.append(`
        <li class="page-item ${prevDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="gotoReportingPage(${reportCurrentPage - 1})">Previous</a>
        </li>
    `);

    const startPage = Math.max(1, reportCurrentPage - 2);
    const endPage = Math.min(totalPages, reportCurrentPage + 2);

    if (startPage > 1) {
        container.append(`<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="gotoReportingPage(1)">1</a></li>`);
        if (startPage > 2) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
    }

    for (let i = startPage; i <= endPage; i++) {
        const active = i === reportCurrentPage ? "active" : "";
        container.append(`
            <li class="page-item ${active}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoReportingPage(${i})">${i}</a>
            </li>
        `);
    }

    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
        container.append(`
            <li class="page-item">
                <a class="page-link" href="javascript:void(0)" onclick="gotoReportingPage(${totalPages})">${totalPages}</a>
            </li>
        `);
    }

    const nextDisabled = reportCurrentPage === totalPages ? "disabled" : "";
    container.append(`
        <li class="page-item ${nextDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="gotoReportingPage(${reportCurrentPage + 1})">Next</a>
        </li>
    `);
}

function gotoReportingPage(p){
    const totalPages = Math.ceil(filteredReporting.length / reportPageSize);
    if(p<1 || p>totalPages) return;
    reportCurrentPage = p;
    renderReportingTable();
}

function changeReportingPageSize(){
    reportPageSize = parseInt($("#reportPageSizeSelect").val());
    reportCurrentPage = 1;
    renderReportingTable();
}

function searchReportingQueue(value) {
    value = (value || "").toLowerCase().trim();

    if (!value) {
        filteredReporting = [...reportingData];
    } else {
        filteredReporting = reportingData.filter(a => {
            return (
                (a.FormType || "").toLowerCase().includes(value) ||
                (a.OfficerName || "").toLowerCase().includes(value) ||
                (a.Location || "").toLowerCase().includes(value) ||
                (a.Dsg || "").toLowerCase().includes(value) ||
                (a.PostingFrom || "").toLowerCase().includes(value) ||
                (a.PostingTo || "").toLowerCase().includes(value) ||
                (a.Status || "").toLowerCase().includes(value)
            );
        });
    }

    reportCurrentPage = 1;
    renderReportingTable();
}

function sortReportingTable(col) {
    reportSortAsc = (reportSortColumn === col) ? !reportSortAsc : true;
    reportSortColumn = col;

    filteredReporting.sort((a, b) => {
        let x = (a[col] || "").toString().toLowerCase();
        let y = (b[col] || "").toString().toLowerCase();

        if (x > y) return reportSortAsc ? 1 : -1;
        if (x < y) return reportSortAsc ? -1 : 1;
        return 0;
    });

    renderReportingTable();
}

function clearValidation(){
    $(".form-control, .form-select").removeClass("is-invalid");
    $(".invalid-feedback").remove();
}

$('#reportingModal').on('hidden.bs.modal', function () {
    clearValidation();
});

function formatDate(d){
    if(!d) return '';
    return new Date(d).toLocaleDateString('en-GB');
}

let reportingModal = new bootstrap.Modal(document.getElementById('reportingModal'));

function viewReportingAcr(acrId){
    selectedAcrId = acrId;
    draftSaved = false;
    $.ajax({
        url: BASE_URL + "api/acr/"+acrId+"/reporting",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success: function(res){
            if(res.Success){
                clearValidation();
                const data=res.Data;
                // --- Populate Info ---
                $("#infoFormType").val(data.FormType);
                $("#infoStatus").val(data.Status);
                $("#infoOfficerName").val(data.Officer.DisplayName);
                $("#infoLocation").val(data.Location);
                $("#infoDesignation").val(data.Dsg);
                $("#infoPostingFrom").val(formatDate(data.PostingFrom));
                $("#infoPostingTo").val(formatDate(data.PostingTo));
                $("#infoAcrYear").val(data.AcrYear);
                $("#infoDOB").val(formatDate(data.DateOfBirth) || '');
                $("#infoJoinNigam").val(formatDate(data.DateJoiningNigam) || '');
                $("#infoJoinRank").val(formatDate(data.DateJoiningPresentRank) || '');
                $("#infoJoinStation").val(formatDate(data.DateJoiningPresentStation) || '');
                $("#infoAcademic").val(data.AcademicQualification || '');
                $("#infoTechnical").val(data.TechnicalQualification || '');
                $("#infoDeptExam").val(data.DepartmentalExamPassed || '');
                $("#infoPropertyReturn").val(formatDate(data.PropertyReturnDate) || '');
                $("#infoMedicalExam").val(formatDate(data.LastMedicalExamDate) || '');
                $("#infoCareerSummary").val(data.CareerPostingSummary || '');

                // --- Populate Assessment Draft ---
                const ra=data.ReportingAssessment || {};
                // $("#agreeWithSelf").val(ra.AgreeWithSelf);
                if(ra.AgreeWithSelf !== undefined && ra.AgreeWithSelf !== null){
                    $("#agreeWithSelf").val(String(ra.AgreeWithSelf));
                } else {
                    $("#agreeWithSelf").val("");
                }
                $("#disagreeDetails").val(ra.DisagreeDetails);
                $("#agreeWithSelf").trigger("change");
                $("#integrityComments").val(ra.IntegrityComments);
                $("#remarks").val(ra.Remarks);
                $("#workTargets").val(ra.WorkTargets);
                $("#workQuality").val(ra.WorkQuality);
                $("#workExceptional").val(ra.WorkExceptional);
                $("#workOverall").val(ra.WorkOverall);
                $("#attrAttitude").val(ra.AttrAttitude);
                $("#attrResponsibility").val(ra.AttrResponsibility);
                $("#attrStability").val(ra.AttrStability);
                $("#attrCommunication").val(ra.AttrCommunication);
                $("#attrMoralCourage").val(ra.AttrMoralCourage);
                $("#attrLeadership").val(ra.AttrLeadership);
                $("#attrTimeliness").val(ra.AttrTimeliness);
                $("#attrOverall").val(ra.AttrOverall);
                $("#compKnowledge").val(ra.CompKnowledge);
                $("#compPlanning").val(ra.CompPlanning);
                $("#compDecision").val(ra.CompDecision);
                $("#compInitiative").val(ra.CompInitiative);
                $("#compTeamwork").val(ra.CompTeamwork);
                $("#compOverall").val(ra.CompOverall);
                $("#overallGrade").val(ra.OverallGrade);

                // Activate first tab
                const firstTab=new bootstrap.Tab(document.querySelector('#info-tab'));
                firstTab.show();
                toggleViewOnly(data.Status === "PENDING_REVIEWING");
                reportingModal.show();
            } else alert(res.Message);
        }
    });
}

$("#uploadDocBtn").click(function(){
    // const file=$("#docFile")[0].files[0];
    // if(!file){ alert("Select a file"); return;}
    // // Upload to storage first, then POST /api/acr/{acrId}/docs
    // alert("File upload integration pending"); // Implement as per storage flow
});

$("#saveDraftBtn").click(function(e){
    e.preventDefault();

    const draft = {
        AgreeWithSelf: $("#agreeWithSelf").val() === 'true',
        DisagreeDetails: $("#disagreeDetails").val(),
        IntegrityComments: $("#integrityComments").val(),
        Remarks: $("#remarks").val(),
        WorkTargets: Number($("#workTargets").val() || 0),
        WorkQuality: Number($("#workQuality").val() || 0),
        WorkExceptional: Number($("#workExceptional").val() || 0),
        WorkOverall: Number($("#workOverall").val() || 0),
        AttrAttitude: Number($("#attrAttitude").val() || 0),
        AttrResponsibility: Number($("#attrResponsibility").val() || 0),
        AttrStability: Number($("#attrStability").val() || 0),
        AttrCommunication: Number($("#attrCommunication").val() || 0),
        AttrMoralCourage: Number($("#attrMoralCourage").val() || 0),
        AttrLeadership: Number($("#attrLeadership").val() || 0),
        AttrTimeliness: Number($("#attrTimeliness").val() || 0),
        AttrOverall: Number($("#attrOverall").val() || 0),
        CompKnowledge: Number($("#compKnowledge").val() || 0),
        CompPlanning: Number($("#compPlanning").val() || 0),
        CompDecision: Number($("#compDecision").val() || 0),
        CompInitiative: Number($("#compInitiative").val() || 0),
        CompTeamwork: Number($("#compTeamwork").val() || 0),
        CompOverall: Number($("#compOverall").val() || 0),
        OverallGrade: Number($("#overallGrade").val() || 0)
    };

    $.ajax({
        url: BASE_URL + "api/acr/" + selectedAcrId + "/reporting/draft",
        type: 'PATCH',
        contentType: 'application/json',
        data: JSON.stringify(draft),
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            alert(res.Message);
            draftSaved = true;
        }
    });
});

$("#submitBtn").click(function(e){
    e.preventDefault();
    if($("#submitBtn").is(":hidden")) return;
    // ✅ Must save draft first
    if(!draftSaved){ 
        alert("Save draft before submitting"); 
        return;
    }

    // ✅ Re-validate before submit
    if (!validateReportingForm()) return;
    $.ajax({
        url: BASE_URL+"api/acr/"+selectedAcrId+"/reporting/submit",
        type:'POST',
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            alert(res.Message);
            draftSaved=false;
            loadReportingQueue();
            reportingModal.hide();
        }
    });
});

function calculateOverall(){
    const workSum = ['workTargets','workQuality','workExceptional'].reduce((acc,id)=> acc + Number($('#'+id).val()||0),0);
    $('#workOverall').val((workSum/3).toFixed(2));

    const attrFields = ['attrAttitude','attrResponsibility','attrStability','attrCommunication','attrMoralCourage','attrLeadership','attrTimeliness'];
    const attrSum = attrFields.reduce((acc,id)=> acc + Number($('#'+id).val()||0),0);
    $('#attrOverall').val((attrSum/7).toFixed(2));

    const compSum = ['compKnowledge','compPlanning','compDecision','compInitiative','compTeamwork'].reduce((acc,id)=> acc + Number($('#'+id).val()||0),0);
    $('#compOverall').val((compSum/5).toFixed(2));

    const overallSum = workSum + attrSum + compSum;
    const overallCount = 3+7+5;
    $('#overallGrade').val((overallSum/overallCount).toFixed(2));
}

// Trigger calculation on rating change
$('#assessmentTab').on('input','.rating-field',calculateOverall);

function toggleViewOnly(isViewOnly){
    $("#assessmentTab input, #assessmentTab textarea, #assessmentTab select").prop("disabled", isViewOnly);

    if(isViewOnly){
        $("#saveDraftBtn").hide();
        $("#submitBtn").hide();
    } else {
        $("#saveDraftBtn").show();
        $("#submitBtn").show();
    }
}

$(document).on("input", ".rating-field", function(){

    let val = Number($(this).val());

    if(val < 1 || val > 10){
        alert("Rating must be between 1 and 10");
        $(this).val('');
    }
});

// Using getCommonStatusBadge from constant.js
var getReportingStatusBadge = getCommonStatusBadge;

</script>
</asp:Content>