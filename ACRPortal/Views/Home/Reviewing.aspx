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
    .reviewing-page {
        --brand-ink: #172033;
        --brand-muted: #667085;
        --brand-line: rgba(15, 23, 42, 0.08);
        --brand-card: rgba(255, 255, 255, 0.94);
        --brand-shadow: 0 24px 50px rgba(16, 37, 66, 0.12);
        position: relative;
        padding: 8px 0 24px;
        color: var(--brand-ink);
    }

    .reviewing-page:before,
    .reviewing-page:after {
        content: "";
        position: absolute;
        border-radius: 50%;
        filter: blur(12px);
        opacity: 0.55;
        pointer-events: none;
    }

    .reviewing-page:before {
        width: 220px;
        height: 220px;
        top: -10px;
        right: 8%;
        background: rgba(6, 182, 212, 0.16);
    }

    .reviewing-page:after {
        width: 240px;
        height: 240px;
        left: 2%;
        bottom: 5%;
        background: rgba(29, 78, 216, 0.12);
    }

    .authority-hero,
    .authority-shell-card,
    .form-section,
    .rating-card {
        border-radius: 24px;
    }

    .authority-hero {
        position: relative;
        overflow: hidden;
        background:
            radial-gradient(circle at top right, rgba(255,255,255,0.18), transparent 32%),
            radial-gradient(circle at bottom left, rgba(6,182,212,0.2), transparent 28%),
            linear-gradient(135deg, #102542 0%, #1d4ed8 55%, #06b6d4 100%);
        padding: 30px 32px;
        margin-bottom: 22px;
        box-shadow: 0 28px 50px rgba(29, 78, 216, 0.2);
        color: #fff;
    }

    .authority-kicker {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        border-radius: 999px;
        background: rgba(255,255,255,0.12);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .authority-title {
        margin: 18px 0 10px;
        font-size: 34px;
        font-weight: 700;
        line-height: 1.15;
    }

    .authority-subtitle {
        max-width: 680px;
        margin: 0;
        font-size: 15px;
        line-height: 1.7;
        color: rgba(255, 255, 255, 0.84);
    }

    .hero-panel {
        height: 100%;
        padding: 22px;
        border-radius: 22px;
        background: rgba(8, 15, 31, 0.22);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.16);
        color: #fff;
    }

    .hero-panel-label {
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: rgba(255,255,255,0.72);
    }

    .hero-panel-value {
        margin: 10px 0 8px;
        font-size: 34px;
        font-weight: 700;
    }

    .hero-panel-copy {
        margin: 0;
        font-size: 14px;
        line-height: 1.6;
        color: rgba(255,255,255,0.82);
    }

    .authority-shell-card {
        background: var(--brand-card);
        border: 1px solid rgba(255, 255, 255, 0.76);
        box-shadow: var(--brand-shadow);
    }

    .authority-toolbar {
        padding: 22px;
        margin-bottom: 18px;
    }

    .authority-toolbar-title {
        margin: 0 0 6px;
        font-size: 19px;
        font-weight: 700;
    }

    .authority-toolbar-copy {
        margin: 0;
        font-size: 14px;
        color: var(--brand-muted);
    }

    .search-wrap {
        position: relative;
    }

    .search-wrap i {
        position: absolute;
        left: 16px;
        top: 50%;
        transform: translateY(-50%);
        color: #94a3b8;
    }

    .search-input,
    .table-select,
    .modal .form-control,
    .modal .form-select {
        min-height: 46px;
        border-radius: 14px;
        border: 1px solid var(--brand-line);
        background: #fff;
    }

    .search-input {
        padding-left: 42px;
        background: #f8fbff;
    }

    .table-select {
        background: #f8fbff;
    }

    .section-card,
    .form-section,
    .rating-card {
        border: 1px solid rgba(219, 234, 254, 0.95);
        background: rgba(255,255,255,0.92);
        padding: 20px;
        box-shadow: 0 16px 30px rgba(15, 23, 42, 0.05);
    }

    .rating-card h5 {
        color: #1d4ed8;
        font-size: 16px;
        margin-bottom: 14px;
        font-weight: 700;
    }

    #reviewingTable th {
        white-space: nowrap;
        user-select: none;
        cursor: pointer;
        font-weight: 700;
        font-size: 12px;
        letter-spacing: 0.05em;
        text-transform: uppercase;
        border-top: 0;
        border-bottom: 0;
        background: linear-gradient(135deg, #15314b, #2346a8);
        color: #fff;
    }

    #reviewingTable th:last-child {
        cursor: default;
    }

    #reviewingTable td {
        vertical-align: middle;
        padding: 16px 14px;
        border-color: rgba(15, 23, 42, 0.06);
    }

    #reviewingTable tbody tr:hover {
        background: rgba(37, 99, 235, 0.04);
    }

    .table-meta {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 18px 22px 22px;
        flex-wrap: wrap;
    }

    .table-meta-left {
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
    }

    .pill-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 12px;
        border-radius: 999px;
        background: rgba(37, 99, 235, 0.08);
        color: #1d4ed8;
        font-size: 12px;
        font-weight: 700;
    }

    .modal-dialog {
        margin-top: 30px;
    }

    .modal-content {
        border: 0;
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 28px 60px rgba(15, 23, 42, 0.18);
    }

    .modal-header.bg-primary {
        background: linear-gradient(135deg, #15314b, #2563eb) !important;
        padding: 18px 24px;
        border-bottom: 0;
    }

    .modal-body {
        max-height: 80vh;
        overflow-y: auto;
        background:
            radial-gradient(circle at top right, rgba(37,99,235,0.05), transparent 24%),
            #f8fbff;
        padding: 24px;
    }

    .modal-intro {
        margin-bottom: 20px;
    }

    .modal-title-lg {
        margin: 0 0 6px;
        font-size: 22px;
        font-weight: 700;
        color: var(--brand-ink);
    }

    .modal-copy {
        margin: 0;
        font-size: 14px;
        color: var(--brand-muted);
        line-height: 1.6;
    }

    .nav-tabs {
        gap: 10px;
        border-bottom: 0;
    }

    .nav-tabs .nav-link {
        border: 0;
        border-radius: 999px;
        padding: 11px 18px;
        font-weight: 700;
        color: var(--brand-muted);
        background: rgba(226, 232, 240, 0.65);
    }

    .nav-tabs .nav-link.active {
        color: #fff;
        background: linear-gradient(135deg, #15314b, #2563eb);
        box-shadow: 0 14px 28px rgba(37, 99, 235, 0.18);
    }

    .section-heading {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 18px;
    }

    .section-heading i {
        width: 38px;
        height: 38px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 14px;
        background: linear-gradient(135deg, #dbeafe, #e0f2fe);
        color: #1d4ed8;
        font-size: 18px;
    }

    .section-heading h6 {
        margin: 0 0 3px;
        font-size: 16px;
        font-weight: 700;
    }

    .section-heading p {
        margin: 0;
        font-size: 13px;
        color: var(--brand-muted);
    }

    #reviewPagination .page-link {
        cursor: pointer;
        border-radius: 10px;
        margin: 0 2px;
        border: 1px solid rgba(15, 23, 42, 0.08);
        color: #1d4ed8;
    }

    #reviewPagination .page-item.active .page-link {
        background: linear-gradient(135deg, #2563eb, #0ea5e9);
        border-color: transparent;
    }

    .authority-action-btn {
        border-radius: 12px;
        font-weight: 600;
        padding: 8px 14px;
    }

    .readonly-check-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 14px;
    }

    .readonly-check-card {
        border: 1px solid rgba(219, 234, 254, 0.95);
        border-radius: 16px;
        background: rgba(248, 251, 255, 0.92);
        padding: 14px 16px;
    }

    .readonly-check-label {
        display: block;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .05em;
        text-transform: uppercase;
        color: var(--brand-muted);
        margin-bottom: 6px;
    }

    .readonly-check-value {
        font-size: 15px;
        font-weight: 700;
        color: var(--brand-ink);
    }
</style>

<div class="container-fluid reviewing-page" id="reviewingDiv" style="display:none;">
    <div class="authority-hero">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="authority-kicker">
                    <i class="bi bi-search-heart"></i>
                    Reviewing Authority
                </span>
                <h2 class="authority-title">A more readable workspace for cross-checking reporting assessments.</h2>
                <p class="authority-subtitle">Open reviewing cases faster, compare reporting details more comfortably, and complete the reviewing step in the same polished authority layout.</p>
            </div>
            <div class="col-lg-4">
                <div class="hero-panel">
                    <div class="hero-panel-label">Reviewing Workspace</div>
                    <div class="hero-panel-value">Review</div>
                    <p class="hero-panel-copy">The queue and modal are redesigned for clarity while keeping your current reviewing behavior exactly the same.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="authority-shell-card authority-toolbar">
        <div class="row align-items-center">
            <div class="col-lg-7 mb-3 mb-lg-0">
                <h4 class="authority-toolbar-title">Reviewing queue</h4>
                <p class="authority-toolbar-copy">Search pending cases and open the review flow from a lighter, more structured table view.</p>
            </div>
            <div class="col-lg-5">
                <div class="d-flex gap-2 flex-wrap justify-content-lg-end">
                    <div class="search-wrap flex-grow-1" style="min-width:240px;">
                        <i class="bi bi-search"></i>
                        <input type="text" id="reviewSearch" class="form-control search-input" placeholder="Search form type, officer, location...">
                    </div>
                    <select id="reviewPageSizeSelect" class="form-select table-select" style="width:110px;">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="authority-shell-card">
        <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="reviewingTable">
                    <thead>
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
        <div class="table-meta">
            <div class="table-meta-left">
                <span class="small text-muted">Records per page</span>
                <span class="pill-badge"><i class="bi bi-arrow-left-right"></i> RA cross-check</span>
            </div>
            <div id="reviewTableInfo" class="small text-muted"></div>
            <nav>
                <ul class="pagination pagination-sm mb-0" id="reviewPagination"></ul>
            </nav>
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
                <div class="modal-intro">
                    <h4 class="modal-title-lg">Reviewing assessment details</h4>
                    <p class="modal-copy">Move through cycle information, reporting inputs, and the reviewing form from one cleaner modal layout that keeps the existing workflow unchanged.</p>
                </div>

                <!-- TABS -->
                <ul class="nav nav-tabs">
                    <li class="nav-item">
                        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#infoTab">ACR Info</button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#officerInfoTab">Officer Info</button>
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
                        <div class="form-section">
                            <div class="section-heading">
                                <i class="bi bi-file-earmark-text"></i>
                                <div>
                                    <h6>Cycle overview</h6>
                                    <p>Reference officer and posting details before reviewing the submitted assessments.</p>
                                </div>
                            </div>
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

                    <div class="tab-pane fade" id="officerInfoTab">
                        <div class="form-section">
                            <div class="section-heading">
                                <i class="bi bi-person-vcard"></i>
                                <div>
                                    <h6>Officer self-appraisal</h6>
                                    <p>Read-only self-appraisal details submitted by the officer for this ACR cycle.</p>
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Submitted</label>
                                    <input class="form-control" id="selfSubmitted" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Submitted At</label>
                                    <input class="form-control" id="selfSubmittedAt" readonly>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Leave Details</label>
                                    <textarea class="form-control" id="selfLeaveDetails" rows="2" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Membership Bodies</label>
                                    <textarea class="form-control" id="selfMembershipBodies" rows="2" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Awards / Honours</label>
                                    <textarea class="form-control" id="selfAwardsHonours" rows="2" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Duties Description</label>
                                    <textarea class="form-control" id="selfDutiesDescription" rows="3" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Targets Set</label>
                                    <textarea class="form-control" id="selfTargetsSet" rows="3" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Targets Achieved</label>
                                    <textarea class="form-control" id="selfTargetsAchieved" rows="3" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Shortfall Reasons</label>
                                    <textarea class="form-control" id="selfShortfallReasons" rows="3" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Major Achievements</label>
                                    <textarea class="form-control" id="selfMajorAchievements" rows="3" readonly></textarea>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold">Training Details</label>
                                    <div class="table-responsive">
                                        <table class="table table-sm table-bordered bg-white mb-0">
                                            <thead>
                                                <tr>
                                                    <th>Date From</th>
                                                    <th>Date To</th>
                                                    <th>Institute</th>
                                                    <th>Subject</th>
                                                </tr>
                                            </thead>
                                            <tbody id="selfTrainingBody">
                                                <tr><td colspan="4" class="text-center text-muted">No training details</td></tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="readonly-check-grid mt-3">
                                <div class="readonly-check-card">
                                    <span class="readonly-check-label">Auditor Compliance</span>
                                    <div class="readonly-check-value" id="selfAuditorCompliance">No</div>
                                </div>
                                <div class="readonly-check-card">
                                    <span class="readonly-check-label">Property Declared</span>
                                    <div class="readonly-check-value" id="selfPropertyDeclared">No</div>
                                </div>
                                <div class="readonly-check-card">
                                    <span class="readonly-check-label">Property Declared Date</span>
                                    <div class="readonly-check-value" id="selfPropertyDeclaredDate">-</div>
                                </div>
                                <div class="readonly-check-card">
                                    <span class="readonly-check-label">Medical Compliance</span>
                                    <div class="readonly-check-value" id="selfMedicalCompliance">No</div>
                                </div>
                                <div class="readonly-check-card">
                                    <span class="readonly-check-label">Medical Compliance Date</span>
                                    <div class="readonly-check-value" id="selfMedicalComplianceDate">-</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="raTab">
                        <div class="section-heading mb-3">
                            <i class="bi bi-diagram-3"></i>
                            <div>
                                <h6>Reporting details</h6>
                                <p>Compare the reporting authority inputs before finalizing your review.</p>
                            </div>
                        </div>
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
                        <div class="form-section">
                            <div class="section-heading">
                                <i class="bi bi-pencil-square"></i>
                                <div>
                                    <h6>Reviewing decision</h6>
                                    <p>Record agreement, comments, and overall grade for the reviewing stage.</p>
                                </div>
                            </div>
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
                <td><button class="btn btn-info btn-sm authority-action-btn" onclick="openReview('${a.AcrId}')">View</button></td>
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

function formatDateTime(d) {
    if (!d) return '-';
    return new Date(d).toLocaleString('en-GB');
}

function safeText(val) {
    return val || '';
}

function boolText(val) {
    return val === true ? 'Yes' : val === false ? 'No' : '-';
}

function parseTrainingDetails(trainingDetails) {
    if (!trainingDetails) return [];

    if (Array.isArray(trainingDetails)) return trainingDetails;

    try {
        var parsed = JSON.parse(trainingDetails);
        return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
        return [];
    }
}

function bindOfficerInfo(selfAppraisal) {
    var self = selfAppraisal || {};
    var trainingList = parseTrainingDetails(self.TrainingDetails);
    var trainingBody = $("#selfTrainingBody");

    $("#selfSubmitted").val(self.Exists ? (self.IsSubmitted ? "Yes" : "No") : "Not Available");
    $("#selfSubmittedAt").val(formatDateTime(self.SubmittedAt));
    $("#selfLeaveDetails").val(safeText(self.LeaveDetails));
    $("#selfMembershipBodies").val(safeText(self.MembershipBodies));
    $("#selfAwardsHonours").val(safeText(self.AwardsHonours));
    $("#selfDutiesDescription").val(safeText(self.DutiesDescription));
    $("#selfTargetsSet").val(safeText(self.TargetsSet));
    $("#selfTargetsAchieved").val(safeText(self.TargetsAchieved));
    $("#selfShortfallReasons").val(safeText(self.ShortfallReasons));
    $("#selfMajorAchievements").val(safeText(self.MajorAchievements));
    $("#selfAuditorCompliance").text(boolText(self.AuditorCompliance));
    $("#selfPropertyDeclared").text(boolText(self.PropertyDeclared));
    $("#selfPropertyDeclaredDate").text(formatDate(self.PropertyDeclaredDate) || '-');
    $("#selfMedicalCompliance").text(boolText(self.MedicalCompliance));
    $("#selfMedicalComplianceDate").text(formatDate(self.MedicalComplianceDate) || '-');

    trainingBody.empty();

    if (!trainingList.length) {
        trainingBody.html('<tr><td colspan="4" class="text-center text-muted">No training details</td></tr>');
        return;
    }

    trainingList.forEach(function (item) {
        trainingBody.append(
            '<tr>' +
                '<td>' + safeText(formatDate(item.DateFrom)) + '</td>' +
                '<td>' + safeText(formatDate(item.DateTo)) + '</td>' +
                '<td>' + safeText(item.Institute) + '</td>' +
                '<td>' + safeText(item.Subject) + '</td>' +
            '</tr>'
        );
    });
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
            $("#infoDesignation").val(d.Dsg || d.Designation || '');
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
            bindOfficerInfo(d.SelfAppraisal);
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
