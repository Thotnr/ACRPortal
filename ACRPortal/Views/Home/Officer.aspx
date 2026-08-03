<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="<%= Url.Content("~/assets/js/shared/constant.js") %>"></script>
    <link href="<%= Url.Content("~/assets/js/lib/bootstrap.min.css") %>" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="<%= Url.Content("~/assets/js/lib/bootstrap-icons.css") %>" rel="stylesheet">
    <!-- Bootstrap JS (bundle includes Popper, required for modal & tabs) -->
    <script src="<%= Url.Content("~/assets/js/lib/bootstrap.bundle.min.js") %>"></script>
    <!-- jQuery (optional, if using your AJAX scripts) -->
    <script src="<%= Url.Content("~/assets/js/lib/jquery-3.7.1.min.js") %>"></script>
    
<style>
    .page-title {
        color: #0d6efd;
        font-weight: 700;
    }

    #acrListTable th {
        white-space: nowrap;
        user-select: none;
    }

    #acrListTable td {
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

    #documentUploadSection {
        border: 1px dashed #cbd5e1 !important;
        background: #f8fafc !important;
    }

    #trainingTable th, #trainingTable td {
        vertical-align: middle;
    }

    #paginationContainer .page-link {
        cursor: pointer;
    }

    .section-card {
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        padding: 16px;
        background: #fff;
    }

    .officer-page {
        --officer-navy: #102542;
        --officer-blue: #1d4ed8;
        --officer-cyan: #06b6d4;
        --officer-ink: #172033;
        --officer-muted: #667085;
        --officer-line: rgba(15, 23, 42, 0.08);
        --officer-card: rgba(255, 255, 255, 0.94);
        --officer-shadow: 0 24px 50px rgba(16, 37, 66, 0.12);
        position: relative;
        padding: 8px 0 24px;
        color: var(--officer-ink);
    }

    .officer-page:before,
    .officer-page:after {
        content: "";
        position: absolute;
        border-radius: 50%;
        filter: blur(12px);
        opacity: 0.55;
        pointer-events: none;
    }

    .officer-page:before {
        width: 220px;
        height: 220px;
        top: -10px;
        right: 8%;
        background: rgba(6, 182, 212, 0.16);
    }

    .officer-page:after {
        width: 240px;
        height: 240px;
        left: 2%;
        bottom: 5%;
        background: rgba(29, 78, 216, 0.12);
    }

    .officer-hero {
        position: relative;
        overflow: hidden;
        background:
            radial-gradient(circle at top right, rgba(255,255,255,0.18), transparent 32%),
            radial-gradient(circle at bottom left, rgba(6,182,212,0.2), transparent 28%),
            linear-gradient(135deg, #102542 0%, #1d4ed8 55%, #06b6d4 100%);
        border-radius: 28px;
        padding: 30px 32px;
        margin-bottom: 22px;
        box-shadow: 0 28px 50px rgba(29, 78, 216, 0.2);
        color: #fff;
    }

    .officer-hero:after {
        content: "";
        position: absolute;
        width: 250px;
        height: 250px;
        top: -90px;
        right: -60px;
        border-radius: 50%;
        border: 1px solid rgba(255,255,255,0.16);
        background: rgba(255,255,255,0.05);
    }

    .officer-kicker {
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

    .officer-title {
        margin: 18px 0 10px;
        font-size: 34px;
        font-weight: 700;
        line-height: 1.15;
        color: #fff;
    }

    .officer-subtitle {
        max-width: 680px;
        margin: 0;
        font-size: 15px;
        line-height: 1.7;
        color: rgba(255, 255, 255, 0.84);
    }

    .hero-panel {
        position: relative;
        z-index: 1;
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
        color: rgba(255, 255, 255, 0.72);
    }

    .hero-panel-value {
        margin: 10px 0 8px;
        font-size: 36px;
        font-weight: 700;
        line-height: 1;
    }

    .hero-panel-copy {
        margin: 0;
        font-size: 14px;
        line-height: 1.6;
        color: rgba(255, 255, 255, 0.82);
    }

    .officer-shell-card {
        background: var(--officer-card);
        border: 1px solid rgba(255, 255, 255, 0.76);
        border-radius: 24px;
        box-shadow: var(--officer-shadow);
    }

    .officer-toolbar {
        padding: 22px;
        margin-bottom: 18px;
    }

    .officer-toolbar-title {
        margin: 0 0 6px;
        font-size: 19px;
        font-weight: 700;
    }

    .officer-toolbar-copy {
        margin: 0;
        font-size: 14px;
        color: var(--officer-muted);
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
    .officer-select,
    .modal .form-control {
        min-height: 46px;
        border-radius: 14px;
        border: 1px solid var(--officer-line);
        background: #fff;
    }

    .search-input {
        padding-left: 15px;
        background: #f8fbff;
    }

    .search-input:focus,
    .officer-select:focus,
    .modal .form-control:focus {
        border-color: #93c5fd;
        box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.12);
    }

    .officer-select {
        background-color: #f8fbff;
    }

    #pageSize {
        appearance: auto;
        -webkit-appearance: menulist;
        -moz-appearance: menulist;
        padding-right: 28px;
        cursor: pointer;
    }

    .officer-toolbar-controls {
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-end;
        align-items: center;
        gap: 12px;
    }

    .officer-toolbar-controls > * {
        margin: 0 !important;
    }

    .officer-toolbar-controls .search-wrap {
        flex: 1 1 280px;
        min-width: 280px !important;
    }

    .officer-toolbar-controls .status-filter {
        flex: 0 0 210px;
    }

    .officer-toolbar-controls .reset-filter {
        flex: 0 0 auto;
    }

    .officer-toolbar-controls .page-size-filter {
        flex: 0 0 110px;
    }

    .officer-table-card {
        overflow: hidden;
    }

    #acrListTable {
        margin-bottom: 0;
    }

    #acrListTable th {
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

    #acrListTable th:last-child {
        cursor: default;
    }

    #acrListTable td {
        padding: 16px 14px;
        border-color: rgba(15, 23, 42, 0.06);
    }

    #acrListTable tbody tr:hover {
        background: rgba(37, 99, 235, 0.04);
    }

    .officer-table-meta {
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

    #paginationContainer .page-link {
        cursor: pointer;
        border-radius: 10px;
        margin: 0 2px;
        border: 1px solid rgba(15, 23, 42, 0.08);
        color: #1d4ed8;
    }

    #paginationContainer .page-item.disabled .page-link {
        cursor: not-allowed;
        pointer-events: none;
        color: #94a3b8;
        background: #f8fafc;
        border-color: rgba(148, 163, 184, 0.25);
        box-shadow: none;
        opacity: 1;
    }

    #paginationContainer .page-item.active .page-link {
        background: linear-gradient(135deg, #2563eb, #0ea5e9);
        border-color: transparent;
    }

    .upload-badge {
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
        border-radius: 24px;
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

    .officer-modal-intro {
        margin-bottom: 20px;
    }

    .officer-modal-title {
        margin: 0 0 6px;
        font-size: 22px;
        font-weight: 700;
        color: var(--officer-ink);
    }

    .officer-modal-copy {
        margin: 0;
        font-size: 14px;
        color: var(--officer-muted);
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
        color: var(--officer-muted);
        background: rgba(226, 232, 240, 0.65);
    }

    .nav-tabs .nav-link.active {
        color: #fff;
        background: linear-gradient(135deg, #15314b, #2563eb);
        box-shadow: 0 14px 28px rgba(37, 99, 235, 0.18);
    }

    .officer-form-section {
        background: rgba(255,255,255,0.9);
        border: 1px solid rgba(219, 234, 254, 0.95);
        border-radius: 20px;
        padding: 20px;
        margin-bottom: 18px;
        box-shadow: 0 16px 30px rgba(15, 23, 42, 0.05);
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
        color: var(--officer-ink);
    }

    .section-heading p {
        margin: 0;
        font-size: 13px;
        color: var(--officer-muted);
    }

    .compliance-card {
        height: 100%;
        border: 1px solid rgba(148, 163, 184, 0.2);
        border-radius: 18px;
        padding: 16px;
        background: linear-gradient(180deg, rgba(255,255,255,0.98), rgba(248,250,252,0.98));
    }

    .help-text {
        margin: 8px 0 0;
        font-size: 12px;
        color: var(--officer-muted);
        line-height: 1.5;
    }

    #documentUploadSection {
        border: 1px dashed #bfdbfe !important;
        background: linear-gradient(180deg, #f8fbff, #eef6ff) !important;
        border-radius: 18px !important;
        padding: 18px !important;
    }

    .officer-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 24px;
        flex-wrap: wrap;
    }

    .officer-actions .btn {
        min-width: 180px;
        border-radius: 14px;
        font-weight: 700;
        padding: 11px 18px;
    }

    @media (max-width: 991.98px) {
        .officer-hero {
            padding: 26px 24px;
        }

        .officer-title {
            font-size: 28px;
        }

        .hero-panel {
            margin-top: 18px;
        }
    }

    @media (max-width: 767.98px) {
        .officer-page {
            padding-top: 2px;
        }

        .officer-hero,
        .officer-shell-card,
        .modal-content {
            border-radius: 22px;
        }

        .officer-toolbar,
        .officer-table-meta,
        .modal-body {
            padding-left: 16px;
            padding-right: 16px;
        }

        .officer-form-section {
            padding: 16px;
        }

        .officer-actions .btn {
            width: 100%;
            min-width: 0;
        }
    }
</style>
<div class="container-fluid officer-page" id="employeeACRDiv" style="display:none;">
    <div class="officer-hero">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="officer-kicker">
                    <i class="bi bi-person-badge"></i>
                    Officer Self Appraisal
                </span>
                <h2 class="officer-title">Track your ACR records and complete pending self-appraisals from one place.</h2>
                <p class="officer-subtitle">View your appraisal periods, check current status, open record details, and submit self-appraisal information for pending cycles.</p>
            </div>
            <div class="col-lg-4">
                <div class="hero-panel">
                    <div class="hero-panel-label">My Workspace</div>
                    <div class="hero-panel-value">ACR</div>
                    <p class="hero-panel-copy">Use this screen to review your ACR list, inspect each record, and complete draft or pending self-appraisal steps.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="officer-shell-card officer-toolbar">
        <div class="row align-items-center">
            <div class="col-xl-6 col-lg-12 mb-3 mb-xl-0">
                <h4 class="officer-toolbar-title">My ACR records</h4>
                <p class="officer-toolbar-copy">Browse, search, and open your appraisal records from a more readable table layout.</p>
            </div>
            <div class="col-xl-6 col-lg-12">
                <div class="officer-toolbar-controls">
                    <div class="search-wrap">
                        <i class="bi bi-search"></i>
                        <input type="text" id="acrSearchBox" class="form-control search-input" placeholder="Search form type, location, designation, posting, status...">
                    </div>
                    <select id="statusFilter" class="form-select officer-select status-filter">
                        <option value="">All Status</option>
                        <option value="DRAFT">DRAFT</option>
                        <option value="PENDING_OFFICER">PENDING_OFFICER</option>
                        <option value="PENDING_REPORTING">PENDING_REPORTING</option>
                        <option value="PENDING_REVIEWING">PENDING_REVIEWING</option>
                        <option value="PENDING_ACCEPTING">PENDING_ACCEPTING</option>
                        <option value="APPROVED">APPROVED</option>
                        <option value="REJECTED">REJECTED</option>
                    </select>
                    <button type="button" id="resetFiltersBtn" class="btn btn-outline-secondary officer-select reset-filter" title="Reset filters" style="min-width:72px; padding:0 12px;">Reset</button>
                    <select id="pageSize" class="form-select officer-select page-size-filter">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="officer-shell-card officer-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle" id="acrListTable">
                    <thead>
                        <tr>
                            <th onclick="sortTable(0)">Form Type</th>
                            <th onclick="sortTable(1)">Location</th>
                            <th onclick="sortTable(2)">Designation</th>
                            <th onclick="sortTable(3)">Posting From</th>
                            <th onclick="sortTable(4)">Posting To</th>
                            <th onclick="sortTable(5)">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="acrListBody"></tbody>
                </table>
        </div>

        <div class="officer-table-meta">
            <div class="table-meta-left">
                <span class="small text-muted">Records per page</span>
                <span class="upload-badge"><i class="bi bi-layout-text-window-reverse"></i> Active list</span>
            </div>
            <div id="paginationInfo" class="small text-muted"></div>
            <nav>
                <ul class="pagination pagination-sm mb-0" id="paginationContainer"></ul>
            </nav>
        </div>
    </div>

    <!-- ACR Detail Modal -->
    <div class="modal fade" id="acrDetailModal" tabindex="-1" aria-labelledby="acrDetailLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-scrollable">
            <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="acrDetailLabel"><i class="bi bi-person-lines-fill"></i> ACR Details</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <div class="officer-modal-intro">
                    <h4 class="officer-modal-title">Officer ACR details</h4>
                    <p class="officer-modal-copy">Start with the ACR Info tab to review the selected cycle, then switch to Self-Appraisal to fill, save draft, and submit when the record is pending at officer level. Existing validation and workflow behavior remain unchanged.</p>
                </div>

                <ul class="nav nav-tabs" id="acrTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="view-tab" data-bs-toggle="tab" data-bs-target="#viewTab" type="button" role="tab">ACR Info</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="self-tab" data-bs-toggle="tab" data-bs-target="#selfTab" type="button" role="tab">Self-Appraisal</button>
                </li>
                </ul>

                <div class="tab-content mt-3">
                <!-- View-Only Tab -->
                <div class="tab-pane fade show active" id="viewTab" role="tabpanel">
                    <div class="officer-form-section">
                        <div class="section-heading">
                            <i class="bi bi-file-earmark-text"></i>
                            <div>
                                <h6>Cycle overview</h6>
                                <p>Core ACR details for the selected posting period.</p>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-6"><label class="form-label fw-bold">Form Type</label><input type="text" id="viewFormType" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Status</label><input type="text" id="viewStatus" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Location</label><input type="text" id="viewLocation" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Designation</label><input type="text" id="viewDesignation" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Posting From</label><input type="text" id="viewPostingFrom" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Posting To</label><input type="text" id="viewPostingTo" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">ACR Year</label><input type="text" id="viewAcrYear" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Date Of Birth</label><input type="text" id="viewDOB" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Date Joining Nigam</label><input type="text" id="viewJoinNigam" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Joining Present Rank</label><input type="text" id="viewJoinRank" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Joining Present Station</label><input type="text" id="viewJoinStation" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Academic Qualification</label><input type="text" id="viewAcademic" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Technical Qualification</label><input type="text" id="viewTechnical" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Dept Exam Passed</label><input type="text" id="viewDeptExam" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Property Return Date</label><input type="text" id="viewPropertyReturn" class="form-control" readonly></div>
                            <div class="col-6"><label class="form-label fw-bold">Last Medical Exam</label><input type="text" id="viewMedicalExam" class="form-control" readonly></div>
                            <div class="col-12"><label class="form-label fw-bold">Career Posting Summary</label><textarea id="viewCareerSummary" class="form-control" readonly></textarea></div>
                        </div>
                    </div>
                </div>

                <!-- Self-Appraisal Tab -->
                <div class="tab-pane fade" id="selfTab" role="tabpanel">
                    <div class="officer-form-section">
                        <div class="section-heading">
                            <i class="bi bi-journal-check"></i>
                            <div>
                                <h6>Self-appraisal details</h6>
                                <p>Capture summary points, training history, and your core performance narrative.</p>
                            </div>
                        </div>
                    <div class="row g-3">
                    <div class="col-md-6"><label for="leaveDetails" class="form-label">Leave Details</label><textarea id="leaveDetails" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="membershipBodies" class="form-label">Membership Bodies</label><textarea id="membershipBodies" class="form-control" rows="2"></textarea></div>
                    <div class="col-12">
                        <div id="passportPhotoUploadSection" class="border rounded p-3 bg-light h-100">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                <div>
                                    <label class="form-label fw-bold mb-1">Passport Size Photo <span class="text-danger">*</span></label>
                                    <div class="small text-muted">Passport Size Photo is required. Accepted formats: JPG, JPEG, PNG. Maximum size: 5 MB.</div>
                                </div>
                                <span class="upload-badge"><i class="bi bi-person-bounding-box"></i> Officer photo</span>
                            </div>

                            <div id="passportPhotoUploadBox">
                                <input type="file" id="fuPassportPhotoUpload" class="form-control"
                                    data-document-type="PASSPORT_PHOTO"
                                    accept=".jpg,.jpeg,.png"
                                    onchange="uploadFile(this)" />
                                <div class="form-text">Upload starts automatically after you choose a file.</div>
                            </div>

                            <div id="passportPhotoUploadedBox" class="d-none">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <div class="fw-semibold text-success">
                                            <i class="bi bi-file-earmark-check"></i>
                                            Uploaded File
                                        </div>
                                        <div id="passportPhotoUploadedFileName" class="small"></div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a id="passportPhotoUploadedFileLink" href="javascript:void(0)" target="_blank" class="btn btn-sm btn-outline-primary d-none">
                                            <i class="bi bi-eye"></i> View
                                        </a>
                                        <button type="button" id="deletePassportPhotoBtn" class="btn btn-sm btn-outline-danger" onclick="deleteCurrentDocument('PASSPORT_PHOTO')">
                                            <i class="bi bi-trash"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <input type="hidden" id="hdnPassportPhotoUploadedFilePath" />
                            <input type="hidden" id="hdnPassportPhotoUploadedFileName" />
                            <input type="hidden" id="hdnPassportPhotoUploadedDocumentId" />
                            <div id="passportPhotoUploadStatus" class="mt-2 small"></div>
                        </div>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-bold">Training Details</label>
                        <table class="table table-bordered" id="trainingTable" style="width:100%;">
                            <thead class="table-light">
                                <tr>
                                    <th style="width:15%;">Date From</th>
                                    <th style="width:15%;">Date To</th>
                                    <th style="width:35%;">Institute</th>
                                    <th style="width:35%;">Subject</th>
                                    <th style="width:5%;"></th>
                                </tr>
                            </thead>
                            <tbody id="trainingTableBody">
                                <!-- Rows will be dynamically added here -->
                            </tbody>
                        </table>
                        <button type="button" class="btn btn-sm btn-outline-success mb-2" id="addTrainingRow">
                            <i class="bi bi-plus-circle"></i> Add Training
                        </button>
                    </div>
                    <div class="col-md-6"><label for="awardsHonours" class="form-label">Awards / Honours</label><textarea id="awardsHonours" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="dutiesDescription" class="form-label">Duties Description <span class="text-danger">*</span></label><textarea id="dutiesDescription" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="targetsSet" class="form-label">Targets Set <span class="text-danger">*</span></label><textarea id="targetsSet" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="targetsAchieved" class="form-label">Targets Achieved <span class="text-danger">*</span></label><textarea id="targetsAchieved" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="shortfallReasons" class="form-label">Shortfall Reasons</label><textarea id="shortfallReasons" class="form-control" rows="2"></textarea></div>
                    <div class="col-md-6"><label for="majorAchievements" class="form-label">Major Achievements</label><textarea id="majorAchievements" class="form-control" rows="2"></textarea></div>
                    </div>
                    </div>

                    <!-- Compliance -->
                    <div class="officer-form-section">
                        <div class="section-heading">
                            <i class="bi bi-shield-check"></i>
                            <div>
                                <h6>Compliance checks</h6>
                                <p>Record declaration and medical compliance items with supporting dates where needed.</p>
                            </div>
                        </div>
                    <div class="row mt-3">
                        <div class="col-md-4">
                            <div class="compliance-card">
                                <div class="form-check"><input type="checkbox" class="form-check-input" id="auditorCompliance"><label class="form-check-label" for="auditorCompliance">Auditor Compliance</label></div>
                                <p class="help-text">Mark this when audit observations and related compliance are up to date.</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="compliance-card">
                                <label class="form-label" for="propertyDeclared">Property Declared</label>
                                <select class="form-select" id="propertyDeclared">
                                    <option value="NA" selected disabled>NA</option>
                                    <option value="Yes">Yes</option>
                                    <option value="No">No</option>
                                </select>
                                <p class="help-text">If declared, provide the declaration date below.</p>
                                <div id="propertyDeclaredDateDiv" class="mt-3" style="display:none;">
                                    <label for="propertyDeclaredDate" class="form-label">Property Declared Date</label>
                                    <input type="date" class="form-control" id="propertyDeclaredDate">
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="compliance-card">
                                <label class="form-label" for="medicalCompliance">Medical Compliance</label>
                                <select class="form-select" id="medicalCompliance">
                                    <option value="NA" selected disabled>NA</option>
                                    <option value="Yes">Yes</option>
                                    <option value="No">No</option>
                                </select>
                                <p class="help-text">If completed, capture the medical compliance date for the record.</p>
                                <div id="medicalComplianceDateDiv" class="mt-3" style="display:none;">
                                    <label for="medicalComplianceDate" class="form-label">Medical Compliance Date</label>
                                    <input type="date" class="form-control" id="medicalComplianceDate">
                                </div>
                            </div>
                        </div>
                    </div>
                    </div>

                    <!-- Document upload -->
                     <div class="officer-form-section">
                        <div class="section-heading">
                            <i class="bi bi-cloud-arrow-up"></i>
                            <div>
                                <h6>Medical report upload</h6>
                                <p>Attach the supporting document when required for the current officer age and compliance rules.</p>
                            </div>
                        </div>
                        <label class="form-label fw-bold">
                            Medical Report
                            <span id="docMandatoryMsg" class="text-danger" style="display:none;">* Required for age 40+</span>
                        </label>

                        <div id="documentUploadSection" class="border rounded p-3 bg-light">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                <div>
                                    <div class="fw-semibold">Supporting document</div>
                                    <div class="small text-muted">Accepted formats: PDF, JPG, JPEG, PNG. Maximum size: 5 MB.</div>
                                </div>
                                <span class="upload-badge"><i class="bi bi-file-earmark-medical"></i> Verification file</span>
                            </div>
                            <!-- Upload state -->
                            <div id="docUploadBox">
                                <input type="file" id="fuAutoUpload" class="form-control"
                                    data-document-type="MEDICAL_REPORT"
                                    accept=".pdf,.jpg,.jpeg,.png"
                                    onchange="uploadFile(this)" />
                                <div class="form-text">Upload starts automatically after you choose a file.</div>
                            </div>

                            <!-- Uploaded state -->
                            <div id="docUploadedBox" class="d-none">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <div class="fw-semibold text-success">
                                            <i class="bi bi-file-earmark-check"></i>
                                            Uploaded File
                                        </div>
                                        <div id="uploadedFileName" class="small"></div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a id="uploadedFileLink" href="javascript:void(0)" target="_blank" class="btn btn-sm btn-outline-primary d-none">
                                            <i class="bi bi-eye"></i> View
                                        </a>
                                        <button type="button" id="deleteDocumentBtn" class="btn btn-sm btn-outline-danger" onclick="deleteCurrentDocument('MEDICAL_REPORT')">
                                            <i class="bi bi-trash"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <input type="hidden" id="hdnUploadedFilePath" />
                            <input type="hidden" id="hdnUploadedFileName" />
                            <input type="hidden" id="hdnUploadedDocumentId" />
                            <div id="uploadStatus" class="mt-2 small"></div>
                        </div>
                    </div>

                    <div class="officer-form-section">
                        <div class="section-heading">
                            <i class="bi bi-cloud-arrow-up"></i>
                            <div>
                                <h6>Upload Self ACR report</h6>
                                <p>Attach the self ACR report using the same upload flow for this record.</p>
                            </div>
                        </div>
                        <label class="form-label fw-bold">Self ACR Report</label>

                        <div id="selfAcrUploadSection" class="border rounded p-3 bg-light">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                <div>
                                    <div class="fw-semibold">Supporting document</div>
                                    <div class="small text-muted">Accepted formats: PDF, JPG, JPEG, PNG. Maximum size: 5 MB.</div>
                                </div>
                                <span class="upload-badge"><i class="bi bi-file-earmark-medical"></i> Verification file</span>
                            </div>
                            <div id="selfAcrUploadBox">
                                <input type="file" id="fuSelfAcrUpload" class="form-control"
                                    data-document-type="SELF_ACR_REPORT"
                                    accept=".pdf,.jpg,.jpeg,.png"
                                    onchange="uploadFile(this)" />
                                <div class="form-text">Upload starts automatically after you choose a file.</div>
                            </div>

                            <div id="selfAcrUploadedBox" class="d-none">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <div class="fw-semibold text-success">
                                            <i class="bi bi-file-earmark-check"></i>
                                            Uploaded File
                                        </div>
                                        <div id="selfAcrUploadedFileName" class="small"></div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a id="selfAcrUploadedFileLink" href="javascript:void(0)" target="_blank" class="btn btn-sm btn-outline-primary d-none">
                                            <i class="bi bi-eye"></i> View
                                        </a>
                                        <button type="button" id="deleteSelfAcrDocumentBtn" class="btn btn-sm btn-outline-danger" onclick="deleteCurrentDocument('SELF_ACR_REPORT')">
                                            <i class="bi bi-trash"></i> Delete
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <input type="hidden" id="hdnSelfAcrUploadedFilePath" />
                            <input type="hidden" id="hdnSelfAcrUploadedFileName" />
                            <input type="hidden" id="hdnSelfAcrUploadedDocumentId" />
                            <div id="selfAcrUploadStatus" class="mt-2 small"></div>
                        </div>
                    </div>
                    <!-- Document upload -->

                    <div class="officer-actions">
                        <button class="btn btn-primary" id="saveDraftBtn"><i class="bi bi-save"></i> Save Draft</button>
                        <button class="btn btn-success d-none" id="submitBtn"><i class="bi bi-send"></i> Submit Self-Appraisal</button>
                    </div>
                </div>
                </div>
            </div>

            <!-- <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i class="bi bi-x-circle"></i> Close</button>
            </div> -->
            </div>
        </div>
    </div>
</div>
<script>

    let draftSaved = false;
    let isFormChanged = false;
    let currentUploadedDocuments = {
        MEDICAL_REPORT: null,
        SELF_ACR_REPORT: null,
        PASSPORT_PHOTO: null
    };
    const MEDICAL_DOCUMENT_TYPE = "MEDICAL_REPORT";
    const SELF_ACR_REPORT_DOCUMENT_TYPE = "SELF_ACR_REPORT";
    const PASSPORT_PHOTO_DOCUMENT_TYPE = "PASSPORT_PHOTO";

    let acrListData = [];
    let filteredAcrListData = [];
    let currentPage = 1;
    let pageSize = 10;
    let totalCount = 0;
    let totalPages = 0;
    let currentSortColumn = -1;
    let currentSortDirection = 'asc';
    let currentSearchTerm = '';
    let currentStatusFilter = '';

    // Check Role from localStorage
    $(document).ready(function () {
        const role = localStorage.getItem('role');
        if(role !== "EMPLOYEE"){
            alert("Access denied. Only EMPLOYEE can access this page.");
            window.location.href = BASE_URL + "Home/Dashboard";
            return;
        }

        $("#employeeACRDiv").show();

        $("#acrSearchBox").on("input", function () {
            searchTable($(this).val());
        });

        $("#statusFilter").on("change", function () {
            currentStatusFilter = ($(this).val() || '').trim();
            currentPage = 1;
            loadAcrList();
        });

        $("#resetFiltersBtn").on("click", function () {
            resetAcrFilters();
        });

        $("#pageSize").on("change", function () {
            pageSize = parseInt($(this).val(), 10) || 10;
            currentPage = 1;
            loadAcrList();
        });
        loadAcrList();
    });

    $(document).on('input change', '#selfTab input, #selfTab textarea, #selfTab select', function () {
        isFormChanged = true;
        draftSaved = false;
        $('#submitBtn').addClass('d-none'); // hide submit again
    });

    function validateForm() {
        if (!$('#dutiesDescription').val().trim()) {
            alert('Duties Description is required');
            $('#dutiesDescription').focus();
            return false;
        }

        if (!$('#targetsSet').val().trim()) {
            alert('Targets Set is required');
            $('#targetsSet').focus();
            return false;
        }

        if (!$('#targetsAchieved').val().trim()) {
            alert('Targets Achieved is required');
            $('#targetsAchieved').focus();
            return false;
        }

        if ($('#propertyDeclared').val() === 'Yes' && !$('#propertyDeclaredDate').val()) {
            alert('Property Declared Date is required');
            $('#propertyDeclaredDate').focus();
            return false;
        }

        if ($('#medicalCompliance').val() === 'Yes' && !$('#medicalComplianceDate').val()) {
            alert('Medical Compliance Date is required');
            $('#medicalComplianceDate').focus();
            return false;
        }

        if (!currentUploadedDocuments[PASSPORT_PHOTO_DOCUMENT_TYPE]) {
            alert('Passport Size Photo is required');
            $('#fuPassportPhotoUpload').focus();
            return false;
        }

        return true;
    }
    let selectedAcrId = null;

    function getAcrListUrl() {
        let url = BASE_URL + 'api/acr/my?pageNumber=' + currentPage + '&pageSize=' + pageSize;

        if (currentStatusFilter) {
            url += '&Status=' + encodeURIComponent(currentStatusFilter);
        }

        return url;
    }

    function resetAcrFilters() {
        currentSearchTerm = '';
        currentStatusFilter = '';
        currentPage = 1;
        $('#acrSearchBox').val('');
        $('#statusFilter').val('');
        loadAcrList();
    }

    function loadAcrList() {
        $.ajax({
            url: getAcrListUrl(),
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (res.Success) {
                    acrListData = (res.Data && res.Data.Items) ? res.Data.Items : [];
                    totalCount = (res.Data && typeof res.Data.TotalCount === 'number') ? res.Data.TotalCount : acrListData.length;
                    totalPages = (res.Data && typeof res.Data.TotalPages === 'number') ? res.Data.TotalPages : (totalCount ? Math.ceil(totalCount / pageSize) : 0);
                    currentPage = (res.Data && typeof res.Data.PageNumber === 'number') ? res.Data.PageNumber : currentPage;
                    pageSize = (res.Data && typeof res.Data.PageSize === 'number') ? res.Data.PageSize : pageSize;
                    $('#pageSize').val(pageSize.toString());
                    $('#statusFilter').val(currentStatusFilter);
                    filteredAcrListData = acrListData.slice();

                    if (currentSearchTerm) {
                        searchTable(currentSearchTerm);
                        return;
                    }

                    applySorting();
                    renderAcrTable();
                } else {
                    alert(res.Message);
                }
            },
            error: function () {
                totalCount = 0;
                totalPages = 0;
                $('#acrListBody').html('<tr><td colspan="7" class="text-center text-danger">Failed to load ACR list</td></tr>');
            }
        });
    }

    function formatDate(d){
        if(!d) return '';
        return new Date(d).toLocaleDateString('en-GB');
    }

    function getFriendlyAcrErrorMessage(xhr, res) {
        const genericMessage = 'There is some error. Please try again after some time later';
        const statusCode = xhr && xhr.status;
        const errorCode = res && res.ErrorCode ? res.ErrorCode.toString().toUpperCase() : '';

        if (statusCode === 500 || errorCode === 'INTERNAL_ERROR') {
            return genericMessage;
        }

        return (res && res.Message) || genericMessage;
    }

    let acrModal = new bootstrap.Modal(document.getElementById('acrDetailModal'));

    function viewAcr(acrId){
        selectedAcrId = acrId;
        $.ajax({
            url: BASE_URL + `api/acr/${acrId}`,
            headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
            success: function(res){
                if(res.Success){
                    const data = res.Data;
                    const isPendingOfficer = data.Status && data.Status.toUpperCase() === 'PENDING_OFFICER';
                    let age = calculateAge(data.DateOfBirth);
                    // Global flag
                    window.isDocMandatory = age >= 40;
                    if (window.isDocMandatory) {
                        $('#docMandatoryMsg').show();
                    } else {
                        $('#docMandatoryMsg').hide();
                    }
                    if (isPendingOfficer) {
                        $('#saveDraftBtn').show();
                        $('#addTrainingRow').show();
                        $(".removeTrainingRow").show();
                        $('#submitBtn').removeClass('d-none');
                        $('#fuAutoUpload').prop('disabled', false);
                        $('#deleteDocumentBtn').prop('disabled', false);
                        $('#fuSelfAcrUpload').prop('disabled', false);
                        $('#deleteSelfAcrDocumentBtn').prop('disabled', false);
                        $('#fuPassportPhotoUpload').prop('disabled', false);
                        $('#deletePassportPhotoBtn').prop('disabled', false);
                    } else {
                        $('#saveDraftBtn').hide();
                        $('#addTrainingRow').hide();
                        $(".removeTrainingRow").hide();
                        $('#submitBtn').addClass('d-none');
                        $('#fuAutoUpload').prop('disabled', true);
                        $('#deleteDocumentBtn').prop('disabled', true);
                        $('#fuSelfAcrUpload').prop('disabled', true);
                        $('#deleteSelfAcrDocumentBtn').prop('disabled', true);
                        $('#fuPassportPhotoUpload').prop('disabled', true);
                        $('#deletePassportPhotoBtn').prop('disabled', true);
                    }
                    // --- Populate ACR Info tab ---
                    $('#viewFormType').val(data.FormType || '');
                    $('#viewStatus').val(data.Status || '');
                    $('#viewLocation').val(data.Location || '');
                    $('#viewDesignation').val(data.Dsg || '');
                    $('#viewPostingFrom').val(data.PostingFrom || '');
                    $('#viewPostingTo').val(data.PostingTo || '');
                    $('#viewAcrYear').val(data.AcrYear || '');
                    $('#viewDepartment').val(data.Department || '');
                    $('#viewDOB').val(formatDate(data.DateOfBirth) || '');
                    $('#viewAcademic').val(data.AcademicQualification || '');
                    $('#viewTechnical').val(data.TechnicalQualification || '');
                    $('#viewDeptExam').val(data.DepartmentalExamPassed || '');
                    $('#viewCareerSummary').val(data.CareerPostingSummary || '');

                    $('#viewJoinNigam').val(formatDate(data.DateJoiningNigam) || '');
                    $('#viewJoinRank').val(formatDate(data.DateJoiningPresentRank) || '');
                    $('#viewJoinStation').val(formatDate(data.DateJoiningPresentStation) || '');
                    $('#viewPropertyReturn').val(formatDate(data.PropertyReturnDate) || '');
                    $('#viewMedicalExam').val(formatDate(data.LastMedicalExamDate) || '');

                    // --- Populate Self-Appraisal tab if data exists, else keep default empty ---
                    const s = data.SelfAppraisal || {};
                    $('#leaveDetails').val(s.LeaveDetails || '');
                    $('#membershipBodies').val(s.MembershipBodies || '');
                    loadTrainingFromJSON(s.TrainingDetails || '[]');
                    $('#awardsHonours').val(s.AwardsHonours || '');
                    $('#dutiesDescription').val(s.DutiesDescription || '');
                    $('#targetsSet').val(s.TargetsSet || '');
                    $('#targetsAchieved').val(s.TargetsAchieved || '');
                    $('#shortfallReasons').val(s.ShortfallReasons || '');
                    $('#majorAchievements').val(s.MajorAchievements || '');
                    $('#auditorCompliance').prop('checked', s.AuditorCompliance || false);
                    $('#propertyDeclared').val(getComplianceSelectValue(s, 'PropertyDeclared'));
                    $('#propertyDeclaredDate').val(s.PropertyDeclaredDate || '');
                    $('#medicalCompliance').val(getComplianceSelectValue(s, 'MedicalCompliance'));
                    $('#medicalComplianceDate').val(s.MedicalComplianceDate || '');

                    if (s && s.Exists) {
                        draftSaved = true;
                        if(data.Status && data.Status.toUpperCase() === 'PENDING_OFFICER'){
                            $('#submitBtn').removeClass('d-none');
                        }
                    } else {
                        draftSaved = false;
                        if(data.Status && data.Status.toUpperCase() === 'PENDING_OFFICER'){
                            $('#submitBtn').addClass('d-none');
                        }
                    }
                    isFormChanged = false;
                    // Show/hide dates
                    togglePropertyDeclaredDate(s);
                    toggleMedicalComplianceDate(s);

                    resetDocumentSection();
                    loadDocuments(isPendingOfficer);
                    // --- Always activate the first tab (ACR Info) ---
                    const firstTab = new bootstrap.Tab(document.querySelector('#view-tab'));
                    firstTab.show();

                    acrModal.show();
                } else {
                    alert(getFriendlyAcrErrorMessage(null, res));
                }
            },
            error: function(xhr) {
                alert(getFriendlyAcrErrorMessage(xhr, xhr.responseJSON));
            }
        });
    }

    $('#backBtn').click(function () {
        // $('#acrDetailDiv').hide();
        // $('#acrListDiv').show();
        acrModal.hide(); // Hide the modal after submission
        loadAcrList();
    });

    $('#saveDraftBtn').click(function (e) {
        e.preventDefault();
        const draft = {
            LeaveDetails: $('#leaveDetails').val(),
            MembershipBodies: $('#membershipBodies').val(),
            TrainingDetails: getTrainingJSON(),
            AwardsHonours: $('#awardsHonours').val(),
            DutiesDescription: $('#dutiesDescription').val(),
            TargetsSet: $('#targetsSet').val(),
            TargetsAchieved: $('#targetsAchieved').val(),
            ShortfallReasons: $('#shortfallReasons').val(),
            MajorAchievements: $('#majorAchievements').val(),
            AuditorCompliance: $('#auditorCompliance').is(':checked'),
            PropertyDeclared: $('#propertyDeclared').val() || 'NA',
            PropertyDeclaredDate: $('#propertyDeclaredDate').val(),
            MedicalCompliance: $('#medicalCompliance').val() || 'NA',
            MedicalComplianceDate: $('#medicalComplianceDate').val()
        };

        $.ajax({
            url: BASE_URL + `api/acr/${selectedAcrId}/self-appraisal/draft`,
            type: 'PATCH',
            contentType: 'application/json',
            data: JSON.stringify(draft),
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                alert(res.Message);
                draftSaved = true;
                isFormChanged = false;
                $('#submitBtn').removeClass('d-none');
            },
            error: function() {
                alert('Error saving draft. Please try again.');
                draftSaved = false;
            }
        });
    });

    $('#submitBtn').click(function (e) {
        e.preventDefault();

        if (isFormChanged) {
            alert("Please save draft before submitting updated data.");
            return;
        }

        if (!draftSaved) {
            alert("Please save draft first.");
            return;
        }

        if (!validateForm()) return;

        if (window.isDocMandatory) {
            let hasDoc = !!currentUploadedDocuments[MEDICAL_DOCUMENT_TYPE];
            if (!hasDoc) {
                alert("Medical document is mandatory for age 40+");
                return;
            }
        }

        $.ajax({
            url: BASE_URL + `api/acr/${selectedAcrId}/self-appraisal/submit`,
            type: 'POST',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                alert(res.Message);
                draftSaved = false;
                isFormChanged = false;
                acrModal.hide();
                loadAcrList();
            },
            error: function(xhr) {
                let msg = 'Submission failed';
                if (xhr.responseJSON && xhr.responseJSON.Message) {
                    msg = xhr.responseJSON.Message;
                }
                alert(msg);
            }
        });
    });

    function callDocsApi(fileData, documentType) {
        var payload = {
                FileUrl: fileData.FileUrl,
                FileName: fileData.FileName,
                DocumentType: documentType
            };

            $.ajax({
                url: BASE_URL + `api/acr/${selectedAcrId}/docs`,
                type: 'POST',
                headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
                contentType: 'application/json',
                data: JSON.stringify(payload),
                success: function (res) {
                    if (res.Success) {
                        setUploadStatus(documentType, '<span class="text-success">Document uploaded successfully</span>');
                        loadDocuments();
                        $(getDocumentElements(documentType).fileInput).val('');
                    } else {
                        setUploadStatus(documentType, '<span class="text-danger">' + (res.Message || 'Document API failed') + '</span>');
                    }
                },
                error: function (xhr) {
                    let msg = 'API Error';
                    if (xhr.responseJSON && xhr.responseJSON.Message) {
                        msg = xhr.responseJSON.Message;
                    }
                    setUploadStatus(documentType, '<span class="text-danger">' + msg + '</span>');
                }
            });
    }
    // ---------------- Document ----------------
    function loadDocuments(keepVisibleWithoutDoc) {
        if (!selectedAcrId) return;
        $.ajax({
            url: BASE_URL + `api/acr/${selectedAcrId}/docs`,
            type: 'GET',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (!res.Success) {
                    resetDocumentSection();
                    toggleDocumentSections(keepVisibleWithoutDoc);
                    return;
                }

                bindDocumentFromResponse(res, MEDICAL_DOCUMENT_TYPE);
                bindDocumentFromResponse(res, SELF_ACR_REPORT_DOCUMENT_TYPE);
                bindDocumentFromResponse(res, PASSPORT_PHOTO_DOCUMENT_TYPE);
                toggleDocumentSections(keepVisibleWithoutDoc);
            },
            error: function () {
                resetDocumentSection();
                toggleDocumentSections(keepVisibleWithoutDoc);
            }
        });
    }

    function getDocumentsFromDocsResponse(res) {
        const data = res && res.Data ? res.Data : {};
        let docs = [];

        if (Array.isArray(data)) {
            docs = data;
        } else if (Array.isArray(data.Documents)) {
            docs = data.Documents;
        } else if (Array.isArray(data.RoleDocuments)) {
            docs = data.RoleDocuments;
        } else if (Array.isArray(data.Items)) {
            docs = data.Items;
        }

        return docs;
    }

    function getDocumentFromDocsResponse(res, documentType) {
        const docs = getDocumentsFromDocsResponse(res);

        return docs.find(d =>
            d &&
            d.DocumentType === documentType &&
            (!d.Section || d.Section === 'OFFICER')
        ) || null;
    }

    function normalizeComplianceValue(value) {
        if (value === true) return 'Yes';
        if (value === false) return 'No';

        const normalized = (value || 'NA').toString().trim().toUpperCase();
        if (normalized === 'YES' || normalized === 'TRUE' || normalized === '1') return 'Yes';
        if (normalized === 'NO' || normalized === 'FALSE' || normalized === '0') return 'No';
        return 'NA';
    }

    function getComplianceSelectValue(selfAppraisal, fieldName) {
        if (!selfAppraisal || !selfAppraisal.Exists || selfAppraisal[fieldName] === null || selfAppraisal[fieldName] === undefined || selfAppraisal[fieldName] === '') {
            return 'NA';
        }

        return normalizeComplianceValue(selfAppraisal[fieldName]);
    }

    function isComplianceYes(value) {
        return normalizeComplianceValue(value) === 'Yes';
    }

    // Show/Hide Property Declared date
    $('#propertyDeclared').change(function() {
        if($(this).val() === 'Yes'){
            $('#propertyDeclaredDateDiv').show();
        } else {
            $('#propertyDeclaredDateDiv').hide();
            $('#propertyDeclaredDate').val(''); // optional: clear date
        }
    });

    // Optional: On modal open, set initial state
    function togglePropertyDeclaredDate(s) {
        const propertyDeclaredValue = getComplianceSelectValue(s, 'PropertyDeclared');
        if(propertyDeclaredValue === 'Yes'){
            $('#propertyDeclared').val('Yes');
            $('#propertyDeclaredDateDiv').show();
        } else {
            $('#propertyDeclared').val(propertyDeclaredValue);
            $('#propertyDeclaredDateDiv').hide();
        }
    }

    $('#medicalCompliance').change(function() {
        if($(this).val() === 'Yes'){
            $('#medicalComplianceDateDiv').show();
        } else {
            $('#medicalComplianceDateDiv').hide();
            $('#medicalComplianceDate').val(''); // clear date when unchecked
        }
    });

    // Optional: Set initial state when loading data
    function toggleMedicalComplianceDate(s) {
        const medicalComplianceValue = getComplianceSelectValue(s, 'MedicalCompliance');
        if(medicalComplianceValue === 'Yes'){
            $('#medicalCompliance').val('Yes');
            $('#medicalComplianceDateDiv').show();
        } else {
            $('#medicalCompliance').val(medicalComplianceValue);
            $('#medicalComplianceDateDiv').hide();
        }
    }

    $('#addTrainingRow').click(function() {
        let row = `<tr>
            <td><input type="date" class="form-control trainingDateFrom"></td>
            <td><input type="date" class="form-control trainingDateTo"></td>
            <td><input type="text" class="form-control trainingInstitute"></td>
            <td><input type="text" class="form-control trainingSubject"></td>
            <td><button type="button" class="btn btn-sm btn-danger removeTrainingRow"><i class="bi bi-trash"></i></button></td>
        </tr>`;
        $('#trainingTableBody').append(row);
    });

    // Remove row
    $(document).on('click', '.removeTrainingRow', function() {
        $(this).closest('tr').remove();
    });

    // Save Training Details as JSON string
    function getTrainingJSON() {
        let trainingList = [];
        $('#trainingTableBody tr').each(function() {
            let row = $(this);
            let obj = {
                DateFrom: row.find('.trainingDateFrom').val(),
                DateTo: row.find('.trainingDateTo').val(),
                Institute: row.find('.trainingInstitute').val(),
                Subject: row.find('.trainingSubject').val()
            };
            // Only push if at least one field is filled
            if(obj.DateFrom || obj.DateTo || obj.Institute || obj.Subject){
                trainingList.push(obj);
            }
        });
        return JSON.stringify(trainingList);
    }

    // Load JSON and populate table
    function loadTrainingFromJSON(jsonStr) {
        $('#trainingTableBody').empty();
        if(!jsonStr) return;
        let data = [];
        try { data = JSON.parse(jsonStr); } catch(e){ console.error(e); return; }

        data.forEach(t => {
            let row = `<tr>
                <td><input type="date" class="form-control trainingDateFrom" value="${t.DateFrom || ''}"></td>
                <td><input type="date" class="form-control trainingDateTo" value="${t.DateTo || ''}"></td>
                <td><input type="text" class="form-control trainingInstitute" value="${t.Institute || ''}"></td>
                <td><input type="text" class="form-control trainingSubject" value="${t.Subject || ''}"></td>
                <td><button type="button" class="btn btn-sm btn-danger removeTrainingRow"><i class="bi bi-trash"></i></button></td>
            </tr>`;
            $('#trainingTableBody').append(row);
        });
    }

    function calculateAge(dob) {
        if (!dob) return 0;
        let birthDate = new Date(dob);
        let today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        let m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }

    function uploadFile(input) {
        if (!input.files || input.files.length === 0) return;

        const documentType = input.getAttribute('data-document-type') || MEDICAL_DOCUMENT_TYPE;
        const file = input.files[0];
        const maxSize = 5 * 1024 * 1024;

        if (file.size > maxSize) {
            alert("File size cannot exceed 5MB");
            input.value = "";
            return;
        }

        var allowedTypes = documentType === PASSPORT_PHOTO_DOCUMENT_TYPE
            ? ["image/png", "image/jpeg"]
            : ["application/pdf", "image/png", "image/jpeg"];
        if (!allowedTypes.includes(file.type)) {
            alert(documentType === PASSPORT_PHOTO_DOCUMENT_TYPE
                ? "Invalid file type! Only JPG, JPEG, PNG allowed."
                : "Invalid file type! Only PDF, JPG, JPEG, PNG allowed.");
            input.value = "";
            return;
        }

        setUploadStatus(documentType, '<span class="text-muted">Uploading file...</span>');

        var formData = new FormData();
        formData.append("file", file);

        var xhr = new XMLHttpRequest();
        xhr.open("POST", BASE_URL + "Web/Shared/FileUploadHandler", true);

        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) {
                var percent = (e.loaded / e.total) * 100;
                setUploadStatus(documentType, '<span class="text-muted">Uploading... ' + percent.toFixed(0) + '%</span>');
            }
        };

        xhr.onload = function () {
            if (xhr.status === 200) {
                var res = JSON.parse(xhr.responseText);

                if (res.success) {
                    const elements = getDocumentElements(documentType);
                    $(elements.filePath).val(res.filePath || '');
                    $(elements.fileName).val(res.fileName || '');

                    callDocsApi({
                        FileUrl: res.filePath,
                        FileName: res.fileName
                    }, documentType);
                } else {
                    setUploadStatus(documentType, '<span class="text-danger">Upload failed: ' + (res.message || 'Unknown error') + '</span>');
                    input.value = "";
                }
            } else {
                setUploadStatus(documentType, '<span class="text-danger">Upload error!</span>');
                input.value = "";
            }
        };

        xhr.onerror = function () {
            setUploadStatus(documentType, '<span class="text-danger">Upload error!</span>');
            input.value = "";
        };

        xhr.send(formData);
    }

    function resetDocumentSection() {
        resetDocumentState(MEDICAL_DOCUMENT_TYPE);
        resetDocumentState(SELF_ACR_REPORT_DOCUMENT_TYPE);
        resetDocumentState(PASSPORT_PHOTO_DOCUMENT_TYPE);
    }

    function showUploadState(documentType) {
        const elements = getDocumentElements(documentType);
        $(elements.uploadBox).removeClass('d-none');
        $(elements.uploadedBox).addClass('d-none');
        $(elements.uploadedFileName).text('');
        $(elements.uploadedFileLink).attr('href', 'javascript:void(0)').addClass('d-none');
        $(elements.documentId).val('');
    }

    function showUploadedState(doc, documentType) {
        const elements = getDocumentElements(documentType);
        $(elements.uploadBox).addClass('d-none');
        $(elements.uploadedBox).removeClass('d-none');

        $(elements.uploadedFileName).text(doc.FileName || '');
        $(elements.documentId).val(doc.DocumentId || '');
        $(elements.filePath).val(doc.FileUrl || '');
        $(elements.fileName).val(doc.FileName || '');

        if (doc.FileUrl) {
            $(elements.uploadedFileLink).attr('href', doc.FileUrl).removeClass('d-none');
        } else {
            $(elements.uploadedFileLink).attr('href', 'javascript:void(0)').addClass('d-none');
        }
    }

    function deleteCurrentDocument(documentType) {
        const doc = currentUploadedDocuments[documentType];
        const elements = getDocumentElements(documentType);

        if (!selectedAcrId || !doc || !doc.DocumentId) {
            alert('No document found to delete.');
            return;
        }

        if (!confirm('Are you sure you want to delete this document?')) {
            return;
        }

        $(elements.deleteButton).prop('disabled', true);

        $.ajax({
            url: BASE_URL + `api/acr/${selectedAcrId}/docs/${doc.DocumentId}`,
            type: 'DELETE',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (res.Success) {
                    setUploadStatus(documentType, '<span class="text-success">Document deleted successfully</span>');
                    resetDocumentState(documentType, true);
                } else {
                    setUploadStatus(documentType, '<span class="text-danger">' + (res.Message || 'Delete failed') + '</span>');
                }
            },
            error: function (xhr) {
                let msg = 'Delete failed';
                if (xhr.responseJSON && xhr.responseJSON.Message) {
                    msg = xhr.responseJSON.Message;
                }
                setUploadStatus(documentType, '<span class="text-danger">' + msg + '</span>');
            },
            complete: function () {
                $(elements.deleteButton).prop('disabled', false);
            }
        });
    }

    function getDocumentElements(documentType) {
        if (documentType === PASSPORT_PHOTO_DOCUMENT_TYPE) {
            return {
                section: '#passportPhotoUploadSection',
                uploadBox: '#passportPhotoUploadBox',
                uploadedBox: '#passportPhotoUploadedBox',
                uploadedFileName: '#passportPhotoUploadedFileName',
                uploadedFileLink: '#passportPhotoUploadedFileLink',
                deleteButton: '#deletePassportPhotoBtn',
                fileInput: '#fuPassportPhotoUpload',
                filePath: '#hdnPassportPhotoUploadedFilePath',
                fileName: '#hdnPassportPhotoUploadedFileName',
                documentId: '#hdnPassportPhotoUploadedDocumentId',
                status: '#passportPhotoUploadStatus'
            };
        }

        if (documentType === SELF_ACR_REPORT_DOCUMENT_TYPE) {
            return {
                section: '#selfAcrUploadSection',
                uploadBox: '#selfAcrUploadBox',
                uploadedBox: '#selfAcrUploadedBox',
                uploadedFileName: '#selfAcrUploadedFileName',
                uploadedFileLink: '#selfAcrUploadedFileLink',
                deleteButton: '#deleteSelfAcrDocumentBtn',
                fileInput: '#fuSelfAcrUpload',
                filePath: '#hdnSelfAcrUploadedFilePath',
                fileName: '#hdnSelfAcrUploadedFileName',
                documentId: '#hdnSelfAcrUploadedDocumentId',
                status: '#selfAcrUploadStatus'
            };
        }

        return {
            section: '#documentUploadSection',
            uploadBox: '#docUploadBox',
            uploadedBox: '#docUploadedBox',
            uploadedFileName: '#uploadedFileName',
            uploadedFileLink: '#uploadedFileLink',
            deleteButton: '#deleteDocumentBtn',
            fileInput: '#fuAutoUpload',
            filePath: '#hdnUploadedFilePath',
            fileName: '#hdnUploadedFileName',
            documentId: '#hdnUploadedDocumentId',
            status: '#uploadStatus'
        };
    }

    function setUploadStatus(documentType, html) {
        $(getDocumentElements(documentType).status).html(html || '');
    }

    function resetDocumentState(documentType, keepStatus) {
        const elements = getDocumentElements(documentType);
        currentUploadedDocuments[documentType] = null;
        $(elements.documentId).val('');
        $(elements.filePath).val('');
        $(elements.fileName).val('');
        $(elements.fileInput).val('');
        if (!keepStatus) {
            $(elements.status).html('');
        }
        showUploadState(documentType);
    }

    function bindDocumentFromResponse(res, documentType) {
        const doc = getDocumentFromDocsResponse(res, documentType);
        currentUploadedDocuments[documentType] = doc;

        if (doc) {
            showUploadedState(doc, documentType);
        } else {
            showUploadState(documentType);
        }
    }

    function toggleDocumentSections(keepVisibleWithoutDoc) {
        const hasMedicalDoc = !!currentUploadedDocuments[MEDICAL_DOCUMENT_TYPE];
        const medicalSectionVisible = !!keepVisibleWithoutDoc || hasMedicalDoc;
        $(getDocumentElements(MEDICAL_DOCUMENT_TYPE).section)[medicalSectionVisible ? 'show' : 'hide']();
        $(getDocumentElements(SELF_ACR_REPORT_DOCUMENT_TYPE).section).show();
        $(getDocumentElements(PASSPORT_PHOTO_DOCUMENT_TYPE).section).show();
    }

function searchTable(value) {
    currentSearchTerm = (value || '').trim();

    if (!currentSearchTerm) {
        filteredAcrListData = acrListData.slice();
    } else {
        const searchTerm = currentSearchTerm.toLowerCase();
        filteredAcrListData = acrListData.filter(function (a) {
            return (
                (a.FormType || '').toLowerCase().includes(searchTerm) ||
                (a.Location || '').toLowerCase().includes(searchTerm) ||
                (a.Dsg || '').toLowerCase().includes(searchTerm) ||
                (a.PostingFrom || '').toLowerCase().includes(searchTerm) ||
                (a.PostingTo || '').toLowerCase().includes(searchTerm) ||
                (a.Status || '').toLowerCase().includes(searchTerm)
            );
        });
    }

    applySorting();
    renderAcrTable();
}

function sortTable(col) {
    if (currentSortColumn === col) {
        currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
    } else {
        currentSortColumn = col;
        currentSortDirection = 'asc';
    }

    applySorting();
    renderAcrTable();
}

function applySorting() {
    if (currentSortColumn < 0) return;

    filteredAcrListData.sort(function (a, b) {
        let valA = getSortValue(a, currentSortColumn);
        let valB = getSortValue(b, currentSortColumn);

        valA = (valA || '').toString().toLowerCase();
        valB = (valB || '').toString().toLowerCase();

        if (valA < valB) return currentSortDirection === 'asc' ? -1 : 1;
        if (valA > valB) return currentSortDirection === 'asc' ? 1 : -1;
        return 0;
    });
}

function getSortValue(item, col) {
    switch (col) {
        case 0: return item.FormType;
        case 1: return item.Location;
        case 2: return item.Dsg;
        case 3: return item.PostingFrom;
        case 4: return item.PostingTo;
        case 5: return item.Status;
        default: return '';
    }
}

// Using getCommonStatusBadge from constant.js
var getStatusBadge = getCommonStatusBadge;

function renderAcrTable() {
    let tbody = $('#acrListBody');
    tbody.empty();

    if (!filteredAcrListData.length) {
        tbody.html('<tr><td colspan="7" class="text-center text-muted">No records found</td></tr>');
        renderPagination();
        $('#paginationInfo').text(totalCount ? ('Showing 0 records on page ' + currentPage + ' of ' + totalPages + ' (' + totalCount + ' total entries)') : 'Showing 0 to 0 of 0 entries');
        return;
    }

    let rows = '';
    filteredAcrListData.forEach(a => {
        rows += `<tr>
            <td>${a.FormType || ''}</td>
            <td>${a.Location || ''}</td>
            <td>${a.Dsg || ''}</td>
            <td>${a.PostingFrom || ''}</td>
            <td>${a.PostingTo || ''}</td>
            <td>${getStatusBadge(a.Status)}</td>
            <td>
                <button class="btn btn-sm btn-info officer-action-btn" onclick="viewAcr('${a.AcrId}')">
                    <i class="bi bi-eye"></i> View
                </button>
            </td>
        </tr>`;
    });

    tbody.html(rows);

    let startIndex = totalCount ? (((currentPage - 1) * pageSize) + 1) : 0;
    let endIndex = totalCount ? Math.min(((currentPage - 1) * pageSize) + acrListData.length, totalCount) : filteredAcrListData.length;
    let infoText = 'Showing ' + startIndex + ' to ' + endIndex + ' of ' + totalCount + ' entries';

    if (currentSearchTerm || currentStatusFilter) {
        infoText += ' | Filtered on current page: ' + filteredAcrListData.length;
    }

    $('#paginationInfo').text(infoText);

    renderPagination();
}

function renderPagination() {
    let container = $('#paginationContainer');
    container.empty();

    if (totalPages <= 1) return;

    let isPrevDisabled = currentPage === 1;
    let isNextDisabled = currentPage === totalPages || acrListData.length < pageSize;
    let prevDisabled = isPrevDisabled ? 'disabled' : '';
    container.append(
        `<li class="page-item ${prevDisabled}">
            <a class="page-link" href="javascript:void(0)" ${isPrevDisabled ? 'aria-disabled="true"' : `onclick="goToPage(${currentPage - 1})"`}>Previous</a>
        </li>`
    );

    let nextDisabled = isNextDisabled ? 'disabled' : '';
    container.append(
        `<li class="page-item ${nextDisabled}">
            <a class="page-link" href="javascript:void(0)" ${isNextDisabled ? 'aria-disabled="true"' : `onclick="goToPage(${currentPage + 1})"`}>Next</a>
        </li>`
    );
}

function goToPage(page) {
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    loadAcrList();
}
</script>
</asp:Content>
