<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<script src="<%= Url.Content("~/assets/js/shared/constant.js") %>"></script>
<link href="<%= Url.Content("~/assets/js/lib/select2.min.css") %>" rel="stylesheet" />
<script src="<%= Url.Content("~/assets/js/lib/select2.min.js") %>"></script>

<style>
    .cca-page {
        --cca-navy: #15314b;
        --cca-blue: #2563eb;
        --cca-cyan: #06b6d4;
        --cca-green: #10b981;
        --cca-amber: #f59e0b;
        --cca-surface: rgba(255, 255, 255, 0.95);
        --cca-line: rgba(15, 23, 42, 0.08);
        --cca-muted: #64748b;
        --cca-ink: #1e293b;
        --cca-shadow: 0 24px 45px rgba(15, 23, 42, 0.08);
        position: relative;
        padding: 6px 0 18px;
        color: var(--cca-ink);
    }

    .cca-page:before,
    .cca-page:after {
        content: "";
        position: absolute;
        border-radius: 50%;
        filter: blur(12px);
        opacity: 0.55;
        pointer-events: none;
    }

    .cca-page:before {
        width: 210px;
        height: 210px;
        top: 0;
        right: 8%;
        background: rgba(37, 99, 235, 0.12);
    }

    .cca-page:after {
        width: 180px;
        height: 180px;
        left: 3%;
        bottom: 6%;
        background: rgba(6, 182, 212, 0.1);
    }

    .cca-hero {
        position: relative;
        overflow: hidden;
        border-radius: 28px;
        padding: 28px 30px;
        margin-bottom: 22px;
        background:
            radial-gradient(circle at top right, rgba(255,255,255,0.15), transparent 30%),
            linear-gradient(135deg, #15314b 0%, #2346a8 50%, #0ea5e9 100%);
        box-shadow: 0 28px 50px rgba(37, 99, 235, 0.2);
        color: #fff;
    }

    .cca-hero:after {
        content: "";
        position: absolute;
        width: 260px;
        height: 260px;
        top: -120px;
        right: -70px;
        border-radius: 50%;
        border: 1px solid rgba(255,255,255,0.14);
        background: rgba(255,255,255,0.05);
    }

    .cca-kicker {
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

    .cca-title {
        margin: 16px 0 10px;
        font-size: 34px;
        font-weight: 700;
        line-height: 1.15;
    }

    .cca-subtitle {
        max-width: 720px;
        margin: 0;
        font-size: 15px;
        line-height: 1.7;
        color: rgba(255,255,255,0.84);
    }

    .cca-hero-actions {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        height: 100%;
    }

    .btn-raise-appraisal {
        position: relative;
        z-index: 1;
        border: 0;
        border-radius: 16px;
        padding: 12px 18px;
        font-weight: 700;
        background: linear-gradient(135deg, #ffffff, #dbeafe);
        color: #15314b;
        box-shadow: 0 20px 35px rgba(15, 23, 42, 0.18);
    }

    .btn-raise-appraisal:hover,
    .btn-raise-appraisal:focus {
        background: linear-gradient(135deg, #ffffff, #eff6ff);
        color: #15314b;
    }

    .btn-raise-appraisal:disabled,
    .btn-raise-appraisal.disabled {
        opacity: 0.65;
        cursor: not-allowed;
        box-shadow: none;
        background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
        color: #64748b;
    }

    .btn-export-cca {
        border: 1px solid rgba(255,255,255,0.28);
        border-radius: 16px;
        padding: 12px 18px;
        font-weight: 700;
        background: rgba(255,255,255,0.12);
        color: #fff;
        margin-right: 12px;
        backdrop-filter: blur(8px);
    }

    .btn-export-cca:hover,
    .btn-export-cca:focus {
        background: rgba(255,255,255,0.2);
        color: #fff;
    }

    .cca-shell-card {
        background: var(--cca-surface);
        border: 1px solid rgba(255,255,255,0.75);
        border-radius: 24px;
        box-shadow: var(--cca-shadow);
    }

    .cca-toolbar {
        padding: 22px;
        margin-bottom: 18px;
    }

    .cca-toolbar-title {
        margin: 0 0 6px;
        font-size: 18px;
        font-weight: 700;
    }

    .cca-toolbar-copy {
        margin: 0;
        font-size: 14px;
        color: var(--cca-muted);
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

    .search-input {
        height: 48px;
        padding-left: 42px;
        border-radius: 14px;
        border: 1px solid var(--cca-line);
        background: #f8fbff;
    }

    .cca-table-card {
        overflow: hidden;
    }

#ccaTable { font-size:14px; }
#ccaTable {
    margin-bottom: 0;
}
#ccaTable th {
    cursor:pointer;
    font-weight:700;
    font-size: 12px;
    letter-spacing: .05em;
    text-transform: uppercase;
    border-top: 0;
    border-bottom: 0;
}
#ccaTable thead.thead-dark th {
    background: linear-gradient(135deg, #15314b, #2346a8);
    color: #fff;
}
#ccaTable td {
    vertical-align: middle;
    padding: 16px 14px;
    border-color: rgba(15, 23, 42, 0.06);
}
#ccaTable tbody tr:hover {
    background: rgba(37, 99, 235, 0.04);
}

.status-badge {
    display: inline-flex;
    align-items: center;
    padding:6px 11px;
    border-radius:999px;
    font-size:12px;
    font-weight: 700;
}
.status-draft { background:#e2e3e5; color:#41464b; }
.status-pending { background:#fff3cd; color:#856404; }
.status-progress { background:#cfe2ff; color:#084298; }
.status-completed { background:#d1e7dd; color:#0f5132; }
.status-rejected { background:#f8d7da; color:#842029; }

.modal-body {
    max-height:80vh;
    overflow-y:auto;
    background:
        radial-gradient(circle at top right, rgba(37,99,235,0.05), transparent 24%),
        #f8fbff;
}
.modal-dialog { margin-top:30px; }

.modal-header {
    background: linear-gradient(135deg, #15314b, #2563eb);
    color: #fff;
    border-bottom: 0;
    padding: 18px 24px;
}
.modal-header .close {
    color: #fff;
    opacity: 1;
    text-shadow: none;
}

.modal-content {
    border-radius: 24px;
    overflow: hidden;
    border: 0;
    box-shadow: 0 28px 60px rgba(15, 23, 42, 0.18);
}

.ccaFormClass h5 {
    font-size: 12px;
    font-weight: 700;
    margin-bottom: 18px;
    color: #2563eb;
    letter-spacing: .08em;
    text-transform: uppercase;
}

.form-group label {
    font-weight: 500;
    font-size: 13px;
    margin-bottom: 6px;
    color: #3b3f44;
}

.form-control,
.select2-container .select2-selection--single {
    border-radius: 12px !important;
}

.form-control {
    min-height: 44px;
    border-color: rgba(15, 23, 42, 0.12);
    background: #fff;
}

.form-control:focus {
    border-color: #93c5fd;
    box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.12);
}

.select2-container .select2-selection--single {
    height: 44px !important;
    border: 1px solid rgba(15, 23, 42, 0.12) !important;
    background: #fff !important;
}

.select2-container--default .select2-selection--single .select2-selection__rendered {
    line-height: 42px !important;
    padding-left: 12px !important;
}

.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 42px !important;
}

.auto-filled {
    background-color: #eef7ff !important;
    border-color: #9ec5fe !important;
}

.helper-text {
    font-size: 12px;
    color: #6c757d;
    margin-top: 4px;
}

.ccaFormClass {
    padding: 4px 10px 8px;
}

.select2-container .select2-selection--single {
    height: 44px !important;
    padding: 8px 10px;
}
.select2-container--default .select2-selection--single .select2-selection__rendered {
    line-height: 28px;
}
.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 42px;
}

.text-required { color:#dc3545; }
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

.cca-form-section {
    background: rgba(255,255,255,0.88);
    border: 1px solid rgba(219, 234, 254, 0.9);
    border-radius: 20px;
    padding: 20px 20px 6px;
    margin-bottom: 18px;
    box-shadow: 0 16px 30px rgba(15, 23, 42, 0.05);
}

.cca-actions {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-top: 28px;
}

.cca-actions .btn {
    min-width: 160px;
    border-radius: 14px;
    font-weight: 700;
    padding: 11px 18px;
}

.cca-table-meta {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 18px 22px 22px;
    flex-wrap: wrap;
}

.authority-status {
    margin-top: 8px;
    font-size: 12px;
    color: var(--cca-muted);
}

@media (max-width: 991.98px) {
    .cca-hero-actions {
        justify-content: flex-start;
        margin-top: 18px;
    }
}

@media (max-width: 767.98px) {
    .cca-title {
        font-size: 28px;
    }

    .cca-hero {
        padding: 24px 22px;
        border-radius: 24px;
    }

    .cca-toolbar,
    .cca-table-meta {
        padding-left: 16px;
        padding-right: 16px;
    }

    .cca-form-section {
        padding-left: 16px;
        padding-right: 16px;
    }

    .cca-actions .btn {
        width: 100%;
        min-width: 0;
    }
}
</style>

<div class="container-fluid cca-page">
    <div class="cca-hero">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="cca-kicker">
                    <i class="fas fa-clipboard-check"></i>
                    CCA Workflow
                </span>
                <h3 class="cca-title">Manage officer appraisals in one cleaner workspace.</h3>
                <p class="cca-subtitle">Review records faster, open appraisal details with less friction, and keep the submission flow easier to scan for day-to-day operations.</p>
            </div>
            <div class="col-lg-4">
                <div class="cca-hero-actions">
                    <button class="btn btn-export-cca" type="button" onclick="exportAcrToXlsx()">
                        <i class="fas fa-file-excel mr-2"></i>Export
                    </button>
                    <button class="btn btn-raise-appraisal" id="btnRaiseAppraisal" type="button" onclick="openAppraisalModal()">
                        <i class="fas fa-plus mr-2"></i>Raise Appraisal
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="cca-shell-card cca-toolbar">
        <div class="row align-items-center">
            <div class="col-lg-7 mb-3 mb-lg-0">
                <h4 class="cca-toolbar-title">Appraisal records</h4>
                <p class="cca-toolbar-copy">Search, sort, and open CCA records from a more readable table layout.</p>
            </div>
            <div class="col-lg-5">
                <div class="d-flex gap-2 flex-wrap justify-content-lg-end">
                    <div class="search-wrap flex-grow-1" style="min-width:240px;">
                        <i class="fas fa-search"></i>
                        <input type="text" id="ccaSearchBox" class="form-control search-input" placeholder="Search officer name...">
                    </div>
                    <select id="statusFilter" class="form-control" style="width:210px;">
                        <option value="">All Status</option>
                        <option value="DRAFT">DRAFT</option>
                        <option value="PENDING_OFFICER">PENDING_OFFICER</option>
                        <option value="PENDING_REPORTING">PENDING_REPORTING</option>
                        <option value="PENDING_REVIEWING">PENDING_REVIEWING</option>
                        <option value="PENDING_ACCEPTING">PENDING_ACCEPTING</option>
                        <option value="APPROVED">APPROVED</option>
                        <option value="REJECTED">REJECTED</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="cca-shell-card cca-table-card">
        <div class="table-responsive">
            <table class="table table-hover" id="ccaTable">
                <thead class="thead-dark">
                    <tr>
                        <th onclick="sortTable(0)">Officer Name</th>
                        <th onclick="sortTable(1)">Designation</th>
                        <th onclick="sortTable(2)">Posting</th>
                        <th onclick="sortTable(3)">From</th>
                        <th onclick="sortTable(4)">To</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ccaTableBody">
                    <tr>
                        <td>--</td>
                        <td>--</td>
                        <td>--</td>
                        <td>--</td>
                        <td>--</td>
                        <td><span class="status-badge status-pending">--</span></td>
                        <td><button class="btn btn-sm btn-info" onclick="openAppraisalModal()">View</button></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="cca-table-meta">
            <div class="d-flex align-items-center gap-2">
                <label class="mb-0">Rows per page:</label>
                <select id="pageSize" class="form-control form-control-sm" style="width:90px;">
                    <option value="5">5</option>
                    <option value="10" selected>10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
            </div>

            <div id="paginationInfo" class="small text-muted"></div>

            <nav>
                <ul class="pagination pagination-sm mb-0" id="paginationContainer"></ul>
            </nav>
        </div>
    </div>
</div>

<div class="modal fade" id="appraisalModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><span id="formTitle">CCA Officer Appraisal</span></h5>
                <button type="button" class="close" onclick="closeModal()"><span>&times;</span></button>
            </div>

            <div class="modal-body">
                <form id="ccaForm" class="ccaFormClass">
                    <div class="cca-form-section">
                        <h5>Period Details</h5>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>From <span class="text-required">*</span></label>
                                <input type="date" class="form-control" id="periodFrom">
                            </div>
                            <div class="form-group col-md-6">
                                <label>To <span class="text-required">*</span></label>
                                <input type="date" class="form-control" id="periodTo">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Place / Office of Posting <span class="text-required">*</span></label>
                            <select class="form-control" id="placePosting"></select>
                        </div>
                    </div>

                    <div class="cca-form-section">
                        <h5>Basic Information</h5>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>Name of the Officer <span class="text-required">*</span></label>
                                <select class="form-control" id="officerName"></select>
                            </div>

                            <div class="form-group col-md-6">
                                <label>Designation <span class="text-required">*</span></label>
                                <select class="form-control" id="designation" onchange="onDesignationChange()">
                                    <option value="">Loading...</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>Date of Birth <span class="text-required">*</span></label>
                                <input type="date" class="form-control" id="dob">
                            </div>
                            <div class="form-group col-md-6">
                                <label>Date of Joining in the Nigam</label>
                                <input type="date" class="form-control" id="joiningNigam">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>Academic Qualification</label>
                                <input type="text" class="form-control" id="academicQualification" maxlength="500">
                            </div>
                            <div class="form-group col-md-6" id="technicalDiv">
                                <label>Technical Qualification</label>
                                <input type="text" class="form-control" id="technicalQualification" maxlength="500">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>Date of Joining to Present Rank</label>
                                <input type="date" class="form-control" id="joiningRank">
                            </div>
                            <div class="form-group col-md-6">
                                <label>Date of Joining to Present Station</label>
                                <input type="date" class="form-control" id="joiningStation">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Departmental Exam Passed</label>
                            <input type="text" class="form-control" id="deptExam" maxlength="500">
                        </div>
                    </div>

                    <div class="cca-form-section">
                        <h5>Authorities</h5>

                        <div class="form-row" id="authorityRow">
                            <div class="form-group col-md-4">
                                <label>Reporting Authority <span class="text-required">*</span></label>
                                <select class="form-control authority-ddl" id="reportingAuthority"></select>
                            </div>

                            <div class="form-group col-md-4">
                                <label>Review Authority <span class="text-required">*</span></label>
                                <select class="form-control authority-ddl" id="reviewAuthority"></select>
                            </div>

                            <div class="form-group col-md-4">
                                <label>Accepting Authority <span class="text-required">*</span></label>
                                <select class="form-control authority-ddl" id="acceptingAuthority"></select>
                            </div>
                        </div>
                        <div id="authoritySuggestionStatus" class="authority-status"></div>
                    </div>

                    <div class="cca-form-section">
                        <h5>Other Information</h5>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label>Property Return Date</label>
                                <input type="date" class="form-control" id="propertyReturnDate">
                            </div>
                            <div class="form-group col-md-6">
                                <label>Medical Exam Date</label>
                                <input type="date" class="form-control" id="medicalExamDate">
                            </div>
                        </div>
                    </div>

                    <div class="cca-actions">
                        <button type="button" class="btn btn-secondary mr-2" id="btnSaveDraft">Save as Draft</button>
                        <button type="submit" class="btn btn-success" id="btnSubmit">Submit</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
var BASE_URL = '<%= Url.Content("~/") %>';
var formType = "";
var designationsList = [];
var employeesList = [];
var subDivisionList = [];

var isDraft = false;
var currentAcrId = null;
var isEditMode = false;
var isSubmitting = false;
var hasSavedDraft = false;
var isFormDirty = false;
var isBindingForm = false;
var isFormReadonly = false;
var currentUserRole = (localStorage.getItem("role") || "").toUpperCase();

var acrListData = [];
var filteredAcrListData = [];
var currentPage = 1;
var pageSize = 10;
var totalCount = 0;
var totalPages = 0;
var currentSortColumn = -1;
var currentSortDirection = "desc";
var currentSearchTerm = "";
var currentStatusFilter = "";
var ccaSearchDebounceTimer = null;

$(document).ready(function () {
    var token = localStorage.getItem("token");
    if (!token) {
        window.location = BASE_URL + "Login/UserAuth";
        return;
    }

    applyTodayMaxToDates();

    syncAdminUiState();
    loadCurrentUser(token);

    loadDesignations()
        .then(function () { return loadSubDivisionsForDropdown(); })
        .then(function () { return loadEmployees(); })
        .then(function () { return loadOfficers(); })
        .then(function () { return loadAcrList(); });

    $("#ccaSearchBox").on("input", function () {
        currentSearchTerm = ($(this).val() || "").trim();
        currentPage = 1;
        scheduleCcaListReload();
    });

    $("#statusFilter").on("change", function () {
        currentStatusFilter = ($(this).val() || "").trim();
        currentPage = 1;
        loadAcrList();
    });

    $("#pageSize").on("change", function () {
        pageSize = parseInt($(this).val(), 10) || 10;
        currentPage = 1;
        loadAcrList();
    });
});

function applyTodayMaxToDates() {
    var today = new Date().toISOString().split('T')[0];
    $("input[type='date']").each(function () {
        $(this).attr("max", today);
    });
}

$("#periodFrom").on("change", function () {
    var from = $(this).val();
    var today = new Date().toISOString().split('T')[0];

    $("#periodTo").attr("max", today);

    if (!from) {
        $("#periodTo").removeAttr("min");
        return;
    }

    $("#periodTo").attr("min", from);

    var currentTo = $("#periodTo").val();
    if (currentTo && currentTo < from) {
        $("#periodTo").val("");
    }
});

function getToken() {
    return localStorage.getItem("token") || "";
}

function apiErrorMessage(xhr, fallback) {
    fallback = fallback || "Something went wrong.";
    if (xhr && xhr.responseJSON) {
        return xhr.responseJSON.Message || xhr.responseJSON.message || fallback;
    }
    return fallback;
}

function loadCurrentUser(token) {
    $.ajax({
        url: BASE_URL + "api/auth/me",
        method: "GET",
        headers: { "Authorization": "Bearer " + token },
        success: function (res) {
            if (!res.Success) {
                window.location = BASE_URL + "Login/UserAuth";
                return;
            }

            var user = res.Data || {};
            currentUserRole = (user.SystemRole || user.Role || currentUserRole || "").toUpperCase();
            if (currentUserRole) {
                localStorage.setItem("role", currentUserRole);
            }
            syncAdminUiState();
        },
        error: function () {
            window.location = BASE_URL + "Login/UserAuth";
        }
    });
}

function getAcrListApiUrl() {
    var endpoint = currentUserRole === "ADMIN" ? "api/admin/acr" : "api/cca/acr";
    var url = BASE_URL + endpoint + "?pageNumber=" + currentPage + "&pageSize=" + pageSize;

    if (currentStatusFilter) {
        url += "&Status=" + encodeURIComponent(currentStatusFilter);
    }

    if (currentSearchTerm) {
        url += "&Officer_name=" + encodeURIComponent(currentSearchTerm);
    }

    return url;
}

function isAdminUser() {
    return currentUserRole === "ADMIN";
}

function syncAdminUiState() {
    $("#btnRaiseAppraisal").prop("disabled", isAdminUser());
}

function loadDesignations() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/admin/masters/designations?activeOnly=true",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    designationsList = res.Data.Designations || [];
                    bindDesignationDropdown();
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function bindDesignationDropdown() {
    var ddl = $("#designation");
    ddl.empty();
    ddl.append('<option value="">Select</option>');

    designationsList.forEach(function (d) {
        ddl.append(
            '<option value="' + d.DsgId + '" data-formtype="' + (d.FormType || '') + '" data-dsg="' + (d.Dsg || '') + '">' +
            (d.Dsg || '') + ' - ' + (d.DsgDesc || '') +
            '</option>'
        );
    });
}

function setDesignationValue(data) {
    var ddl = $("#designation");
    var dsgId = data && data.DsgId ? data.DsgId.toString() : "";
    var dsgCode = data && data.Dsg ? data.Dsg.toString().trim().toLowerCase() : "";

    if (dsgId) {
        ddl.val(dsgId).trigger("change");
        if (ddl.val()) return;
    }

    if (!dsgCode) {
        ddl.val("").trigger("change");
        return;
    }

    var matchedValue = "";
    ddl.find("option").each(function () {
        var option = $(this);
        var optionDsg = (option.data("dsg") || "").toString().trim().toLowerCase();
        if (optionDsg === dsgCode) {
            matchedValue = option.val();
            return false;
        }
    });

    ddl.val(matchedValue).trigger("change");
}

function onDesignationChange() {
    var selected = $("#designation option:selected");
    var newFormType = selected.data("formtype");

    if (!newFormType) {
        formType = "";
        $("#formTitle").text("CCA Officer Appraisal");
        return;
    }

    formType = newFormType;
    $("#formTitle").text(getFormTitle(formType));
    applyFormRules();
}

function applyFormRules() {
    $("#reportingAuthority2Row").remove();
    $("#technicalDiv").show();

    if (formType === "A1b") {
        if (!$("#reportingAuthority2").length) {
            $("#authorityRow").after(
                '<div class="form-row" id="reportingAuthority2Row">' +
                    '<div class="form-group col-md-4">' +
                        '<label>Second Reporting Authority <span class="text-required">*</span></label>' +
                        '<select class="form-control authority-ddl" id="reportingAuthority2"></select>' +
                        '<div class="helper-text">Must be different from Reporting Authority.</div>' +
                    '</div>' +
                '</div>'
            );
        }
    }
    if (formType === "A2") {
        $("#technicalDiv").hide();
        $("#technicalQualification").val("");
    }
    bindAuthorityDropdowns();
}

function getFormTitle(type) {
    if (type === "A1a") return "Senior Engineering Officers (SE & Above)";
    if (type === "A1b") return "Engineering Officers (AE to XEN)";
    if (type === "A2") return "General & Accounts Officers";
    return "CCA Officer Appraisal";
}

function openAppraisalModal() {
    applyTodayMaxToDates();

    $("#ccaForm")[0].reset();
    $("#officerName, #designation, #placePosting").val(null).trigger("change");

    formType = "";
    isDraft = false;
    currentAcrId = null;
    isEditMode = false;
    isSubmitting = false;
    hasSavedDraft = false;
    isFormDirty = false;
    isBindingForm = false;

    $("#formTitle").text("CCA Officer Appraisal");
    $("#btnSubmit").show();
    $("#btnSaveDraft").show();

    $("#reportingAuthority2Row").remove();
    bindAuthorityDropdowns();
    $("#authoritySuggestionStatus").html("");
    setFormReadonly(false);
    updateActionButtonsState();

    $('#appraisalModal').modal('show');
}

function closeModal() {
    $('#appraisalModal').modal('hide');
}

function scheduleCcaListReload() {
    clearTimeout(ccaSearchDebounceTimer);
    ccaSearchDebounceTimer = setTimeout(function () {
        loadAcrList();
    }, 1500);
}

function searchTable(value) {
    currentSearchTerm = (value || "").trim();
    applySorting();
    renderAcrTable();
}

// function sortTable(col) {
//     var table = document.getElementById("ccaTable"), switching = true;
//     while (switching) {
//         switching = false;
//         var rows = table.rows;
//         for (var i = 1; i < rows.length - 1; i++) {
//             var x = rows[i].getElementsByTagName("TD")[col];
//             var y = rows[i + 1].getElementsByTagName("TD")[col];
//             if (x && y && x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
//                 rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
//                 switching = true;
//                 break;
//             }
//         }
//     }
// }
function sortTable(col) {
    if (currentSortColumn === col) {
        currentSortDirection = currentSortDirection === "asc" ? "desc" : "asc";
    } else {
        currentSortColumn = col;
        currentSortDirection = "asc";
    }

    applySorting();
    renderAcrTable();
}

function applySorting() {
    filteredAcrListData.sort(function (a, b) {
        var valA = getSortValue(a, currentSortColumn);
        var valB = getSortValue(b, currentSortColumn);

        if (currentSortColumn === -1) {
            valA = new Date(valA || 0).getTime();
            valB = new Date(valB || 0).getTime();
        } else {
            valA = (valA || "").toString().toLowerCase();
            valB = (valB || "").toString().toLowerCase();
        }

        if (valA < valB) return currentSortDirection === "asc" ? -1 : 1;
        if (valA > valB) return currentSortDirection === "asc" ? 1 : -1;
        return 0;
    });
}

function getSortValue(item, col) {
    switch (col) {
        case 0: return item.OfficerName || "";
        case 1: return item.Dsg || "";
        case 2: return item.Location || "";
        case 3: return item.PostingFrom || "";
        case 4: return item.PostingTo || "";
        default: return item.CreatedAt || "";
    }
}

function renderAcrTable() {
    var tbody = $("#ccaTableBody");
    tbody.empty();

    if (!filteredAcrListData.length) {
        tbody.html('<tr><td colspan="7" class="text-center text-muted">No records found</td></tr>');
        renderPagination();
        $("#paginationInfo").text(totalCount ? "Showing 0 records on page " + currentPage + " of " + totalPages + " (" + totalCount + " total entries)" : "Showing 0 to 0 of 0 entries");
        return;
    }

    $.each(filteredAcrListData, function (i, a) {
        tbody.append(
            '<tr>' +
                '<td>' + (a.OfficerName || '--') + '</td>' +
                '<td>' + (a.Dsg || '--') + '</td>' +
                '<td>' + (a.Location || '--') + '</td>' +
                '<td>' + (a.PostingFrom || '--') + '</td>' +
                '<td>' + (a.PostingTo || '--') + '</td>' +
                '<td>' + getStatusBadge(a.Status) + '</td>' +
                '<td><button class="btn btn-sm btn-info" onclick="viewAcr(\'' + a.AcrId + '\')">View</button></td>' +
            '</tr>'
        );
    });

    var startIndex = totalCount ? ((currentPage - 1) * pageSize) + 1 : 0;
    var endIndex = totalCount ? Math.min(((currentPage - 1) * pageSize) + acrListData.length, totalCount) : filteredAcrListData.length;
    var infoText = "Showing " + startIndex + " to " + endIndex + " of " + totalCount + " entries";

    if (currentSearchTerm || currentStatusFilter) {
        infoText += " | Filtered on current page: " + filteredAcrListData.length;
    }

    $("#paginationInfo").text(infoText);
    renderPagination();
}

function renderPagination() {
    var container = $("#paginationContainer");
    container.empty();

    if (totalPages <= 1) return;

    var isPrevDisabled = currentPage === 1;
    var isNextDisabled = currentPage === totalPages || acrListData.length < pageSize;
    var prevDisabled = isPrevDisabled ? "disabled" : "";
    container.append(
        '<li class="page-item ' + prevDisabled + '">' +
            '<a class="page-link" href="javascript:void(0)"' + (isPrevDisabled ? ' aria-disabled="true"' : ' onclick="goToPage(' + (currentPage - 1) + ')"') + '>Previous</a>' +
        '</li>'
    );

    var nextDisabled = isNextDisabled ? "disabled" : "";
    container.append(
        '<li class="page-item ' + nextDisabled + '">' +
            '<a class="page-link" href="javascript:void(0)"' + (isNextDisabled ? ' aria-disabled="true"' : ' onclick="goToPage(' + (currentPage + 1) + ')"') + '>Next</a>' +
        '</li>'
    );
}

function goToPage(page) {
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    loadAcrList();
}

function exportAcrToXlsx() {
    if (!filteredAcrListData.length) {
        alert("No records available to export.");
        return;
    }

    var headers = [
        "Officer Name",
        "Officer Login Id",
        "Designation",
        "Form Type",
        "Department",
        "Location",
        "Posting From",
        "Posting To",
        "ACR Year",
        "Status",
        "Created At"
    ];

    var rows = filteredAcrListData.map(function (item) {
        return [
            item.OfficerName || "",
            item.OfficerLoginId || "",
            item.Dsg || "",
            item.FormType || "",
            item.Department || "",
            item.Location || "",
            item.PostingFrom || "",
            item.PostingTo || "",
            item.AcrYear || "",
            item.Status || "",
            item.CreatedAt || ""
        ];
    });

    downloadXlsxFile("CCA_Appraisal_Records_Page_" + currentPage + ".xlsx", "CCA Records", headers, rows);
}

function downloadXlsxFile(fileName, sheetName, headers, rows) {
    var encoder = new TextEncoder();
    var workbookFiles = [
        { name: "[Content_Types].xml", data: encoder.encode(buildContentTypesXml()) },
        { name: "_rels/.rels", data: encoder.encode(buildRootRelsXml()) },
        { name: "xl/workbook.xml", data: encoder.encode(buildWorkbookXml(sheetName)) },
        { name: "xl/_rels/workbook.xml.rels", data: encoder.encode(buildWorkbookRelsXml()) },
        { name: "xl/worksheets/sheet1.xml", data: encoder.encode(buildWorksheetXml(headers, rows)) },
        { name: "xl/styles.xml", data: encoder.encode(buildStylesXml()) }
    ];

    var blob = createZipBlob(workbookFiles);
    var url = URL.createObjectURL(blob);
    var link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
}

function buildContentTypesXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
            '<Default Extension="xml" ContentType="application/xml"/>' +
            '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>' +
            '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' +
            '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>' +
        '</Types>';
}

function buildRootRelsXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' +
        '</Relationships>';
}

function buildWorkbookXml(sheetName) {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
            '<sheets>' +
                '<sheet name="' + escapeXml(sheetName) + '" sheetId="1" r:id="rId1"/>' +
            '</sheets>' +
        '</workbook>';
}

function buildWorkbookRelsXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>' +
            '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' +
        '</Relationships>';
}

function buildStylesXml() {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' +
            '<fonts count="2">' +
                '<font><sz val="11"/><name val="Calibri"/></font>' +
                '<font><b/><sz val="11"/><name val="Calibri"/></font>' +
            '</fonts>' +
            '<fills count="2">' +
                '<fill><patternFill patternType="none"/></fill>' +
                '<fill><patternFill patternType="gray125"/></fill>' +
            '</fills>' +
            '<borders count="1">' +
                '<border><left/><right/><top/><bottom/><diagonal/></border>' +
            '</borders>' +
            '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>' +
            '<cellXfs count="2">' +
                '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' +
                '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>' +
            '</cellXfs>' +
            '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>' +
        '</styleSheet>';
}

function buildWorksheetXml(headers, rows) {
    var allRows = [headers].concat(rows);
    var rowXml = allRows.map(function (columns, rowIndex) {
        var cellXml = columns.map(function (value, columnIndex) {
            var cellRef = getExcelColumnName(columnIndex + 1) + (rowIndex + 1);
            var styleId = rowIndex === 0 ? ' s="1"' : "";
            return '<c r="' + cellRef + '" t="inlineStr"' + styleId + '><is><t>' + escapeXml(value == null ? "" : value.toString()) + '</t></is></c>';
        }).join("");

        return '<row r="' + (rowIndex + 1) + '">' + cellXml + '</row>';
    }).join("");

    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' +
            '<sheetData>' + rowXml + '</sheetData>' +
        '</worksheet>';
}

function getExcelColumnName(columnNumber) {
    var columnName = "";
    while (columnNumber > 0) {
        var remainder = (columnNumber - 1) % 26;
        columnName = String.fromCharCode(65 + remainder) + columnName;
        columnNumber = Math.floor((columnNumber - 1) / 26);
    }
    return columnName;
}

function escapeXml(value) {
    return (value || "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\"/g, "&quot;")
        .replace(/'/g, "&apos;");
}

function createZipBlob(files) {
    var localParts = [];
    var centralParts = [];
    var offset = 0;

    files.forEach(function (file) {
        var nameBytes = new TextEncoder().encode(file.name);
        var crc = crc32(file.data);
        var localHeader = createZipHeader(0x04034b50, nameBytes, crc, file.data.length, offset, false);
        localParts.push(localHeader.header, nameBytes, file.data);

        var centralHeader = createZipHeader(0x02014b50, nameBytes, crc, file.data.length, offset, true);
        centralParts.push(centralHeader.header, nameBytes);

        offset += localHeader.header.length + nameBytes.length + file.data.length;
    });

    var centralSize = centralParts.reduce(function (sum, part) { return sum + part.length; }, 0);
    var endRecord = createZipEndRecord(files.length, centralSize, offset);

    return new Blob(localParts.concat(centralParts, [endRecord]), {
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    });
}

function createZipHeader(signature, nameBytes, crc, size, offset, isCentral) {
    var header = new Uint8Array(isCentral ? 46 : 30);
    var view = new DataView(header.buffer);
    var now = new Date();
    var dosTime = ((now.getHours() & 31) << 11) | ((now.getMinutes() & 63) << 5) | Math.floor((now.getSeconds() || 0) / 2);
    var dosDate = ((((now.getFullYear() - 1980) & 127) << 9) | (((now.getMonth() + 1) & 15) << 5) | (now.getDate() & 31));

    view.setUint32(0, signature, true);

    if (isCentral) {
        view.setUint16(4, 20, true);
        view.setUint16(6, 20, true);
        view.setUint16(8, 0, true);
        view.setUint16(10, 0, true);
        view.setUint16(12, dosTime, true);
        view.setUint16(14, dosDate, true);
        view.setUint32(16, crc, true);
        view.setUint32(20, size, true);
        view.setUint32(24, size, true);
        view.setUint16(28, nameBytes.length, true);
        view.setUint16(30, 0, true);
        view.setUint16(32, 0, true);
        view.setUint16(34, 0, true);
        view.setUint16(36, 0, true);
        view.setUint32(38, 0, true);
        view.setUint32(42, offset, true);
    } else {
        view.setUint16(4, 20, true);
        view.setUint16(6, 0, true);
        view.setUint16(8, 0, true);
        view.setUint16(10, dosTime, true);
        view.setUint16(12, dosDate, true);
        view.setUint32(14, crc, true);
        view.setUint32(18, size, true);
        view.setUint32(22, size, true);
        view.setUint16(26, nameBytes.length, true);
        view.setUint16(28, 0, true);
    }

    return { header: header };
}

function createZipEndRecord(fileCount, centralSize, centralOffset) {
    var endRecord = new Uint8Array(22);
    var view = new DataView(endRecord.buffer);

    view.setUint32(0, 0x06054b50, true);
    view.setUint16(4, 0, true);
    view.setUint16(6, 0, true);
    view.setUint16(8, fileCount, true);
    view.setUint16(10, fileCount, true);
    view.setUint32(12, centralSize, true);
    view.setUint32(16, centralOffset, true);
    view.setUint16(20, 0, true);

    return endRecord;
}

var crcTable = null;

function crc32(data) {
    if (!crcTable) {
        crcTable = [];
        for (var n = 0; n < 256; n++) {
            var c = n;
            for (var k = 0; k < 8; k++) {
                c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
            }
            crcTable[n] = c >>> 0;
        }
    }

    var crc = 0 ^ (-1);
    for (var i = 0; i < data.length; i++) {
        crc = (crc >>> 8) ^ crcTable[(crc ^ data[i]) & 0xff];
    }
    return (crc ^ (-1)) >>> 0;
}

function loadEmployees() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/cca/employees",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    employeesList = res.Data.Employees || [];
                    bindEmployeeDropdown("#reportingAuthority", employeesList);
                    bindEmployeeDropdown("#reviewAuthority", employeesList);
                    bindEmployeeDropdown("#acceptingAuthority", employeesList);
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function bindAuthorityDropdowns(preservedValues) {
    preservedValues = preservedValues || {};

    var selectedOfficer = $("#officerName").val();

    $(".authority-ddl").each(function () {
        var ddl = $(this);
        var ddlId = ddl.attr("id");
        var selectedValue = preservedValues[ddlId] || null;

        if (ddl.hasClass("select2-hidden-accessible")) {
            ddl.select2("destroy");
        }

        ddl.empty();
        ddl.append('<option value="">Select</option>');

        employeesList.forEach(function (emp) {
            if (emp.UserId === selectedOfficer) return;

            ddl.append(
                '<option value="' + emp.UserId + '">' +
                (emp.DisplayName || '') + ' (' + (emp.LoginId || '') + ')' +
                '</option>'
            );
        });

        ddl.select2({
            width: '100%',
            placeholder: "Search employee",
            allowClear: true,
            dropdownParent: $('#appraisalModal')
        });

        if (selectedValue) {
            ddl.val(selectedValue).trigger("change");
        }
    });

    preventAuthorityDuplicates();
}

function preventAuthorityDuplicates() {
     $("#reportingAuthority, #reportingAuthority2")
        .off("change.authority")
        .on("change.authority", function () {
            var ra1 = $("#reportingAuthority").val() || "";
            var ra2 = $("#reportingAuthority2").length ? ($("#reportingAuthority2").val() || "") : "";

            if (ra1 && ra2 && ra1 === ra2) {
                alert("Reporting Authority and Second Reporting Authority cannot be the same user.");
                $(this).val(null).trigger("change");
            }
        });
}

function bindEmployeeDropdown(id, list) {
    var ddl = $(id);

    if (ddl.hasClass("select2-hidden-accessible")) {
        ddl.select2("destroy");
    }

    ddl.empty();
    ddl.append('<option value="">Select</option>');

    $.each(list, function (i, e) {
        ddl.append(
            '<option value="' + e.UserId + '">' +
            (e.DisplayName || '') + ' (' + (e.DsgDesc || 'No Designation') + ')' +
            '</option>'
        );
    });

    ddl.select2({
        width: '100%',
        placeholder: "Search employee",
        allowClear: true,
        dropdownParent: $('#appraisalModal')
    });
}

function loadSubDivisionsForDropdown() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/admin/masters/subdivisions",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    subDivisionList = res.Data.SubDivisions || [];
                    bindSubDivisionDropdown();
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function bindSubDivisionDropdown() {
    var ddl = $("#placePosting");

    if (ddl.hasClass("select2-hidden-accessible")) {
        ddl.select2("destroy");
    }

    ddl.empty();
    ddl.append('<option value="">Select SubDivision</option>');

    subDivisionList.forEach(function (s) {
        ddl.append(
            '<option value="' + s.SubDivisionId + '">' +
            (s.SubDivision || '') +
            '</option>'
        );
    });

    ddl.select2({
        width: '100%',
        placeholder: "Search SubDivision",
        allowClear: true,
        dropdownParent: $('#appraisalModal')
    });
}

function formatDate(dateValue) {
    if (!dateValue) return null;

    if (/^\d{4}-\d{2}-\d{2}$/.test(dateValue)) {
        return dateValue;
    }

    var d = new Date(dateValue);
    if (isNaN(d)) return null;

    var month = (d.getMonth() + 1).toString().padStart(2, '0');
    var day = d.getDate().toString().padStart(2, '0');

    return d.getFullYear() + "-" + month + "-" + day;
}

function buildPayload(saveAsDraft) {
    var postingData = $("#placePosting").select2('data') || [];
    var location = "";

    if (postingData.length) {
        location = (postingData[0].text || "").trim().replace(/\s*\(.*?\)/, '');
    }

    return {
        PostingFrom: formatDate($("#periodFrom").val()),
        PostingTo: formatDate($("#periodTo").val()),
        DateOfBirth: formatDate($("#dob").val()),
        DateJoiningNigam: formatDate($("#joiningNigam").val()),
        DateJoiningPresentRank: formatDate($("#joiningRank").val()),
        DateJoiningPresentStation: formatDate($("#joiningStation").val()),
        PropertyReturnDate: formatDate($("#propertyReturnDate").val()),
        LastMedicalExamDate: formatDate($("#medicalExamDate").val()),
        OfficerUserId: $("#officerName").val() || null,
        DesignationId: $("#designation").val() ? parseInt($("#designation").val(), 10) : null,
        SaveAsDraft: !!saveAsDraft,
        Department: "--",
        Location: location,
        AcademicQualification: ($("#academicQualification").val() || "").trim(),
        TechnicalQualification: formType === "A2" ? null : ($("#technicalQualification").val() || "").trim(),
        DepartmentalExamPassed: ($("#deptExam").val() || "").trim(),
        ReportingUserId: $("#reportingAuthority").val() || null,
        ReportingUserId2: $("#reportingAuthority2").length ? ($("#reportingAuthority2").val() || null) : null,
        ReviewingUserId: $("#reviewAuthority").val() || null,
        AcceptingUserId: $("#acceptingAuthority").val() || null,
        CareerPostingSummary: ""
    };
}

function getCreatePayload(payload) {
    return $.extend({}, payload);
}

function getPatchPayload(payload) {
    var patchPayload = $.extend({}, payload);
    delete patchPayload.SaveAsDraft;
    return patchPayload;
}

function validatePayload(payload, saveAsDraft) {
    if (saveAsDraft) {
        if (!payload.OfficerUserId) return "Officer is required to save draft.";
        return "";
    }

    if (!payload.PostingFrom || !payload.PostingTo) return "Posting period required.";
    if (!payload.OfficerUserId) return "Officer is required.";
    if (!payload.DesignationId) return "Designation is required.";
    if (!payload.Location) return "Place of Posting is required.";
    if (!payload.DateOfBirth) return "Date of Birth is required.";
    if (!payload.ReportingUserId) return "Reporting Authority is required.";
    if (!payload.ReviewingUserId) return "Review Authority is required.";
    if (!payload.AcceptingUserId) return "Accepting Authority is required.";

    var fromDate = new Date(payload.PostingFrom);
    var toDate = new Date(payload.PostingTo);
    var todayDate = new Date();

    if (fromDate > todayDate || toDate > todayDate) return "Future dates are not allowed.";
    if (toDate <= fromDate) return "Posting To must be greater than Posting From.";

    var diffDays = Math.floor((toDate - fromDate) / (1000 * 60 * 60 * 24));
    if (diffDays < 90) return "Posting period gap must be at least 90 days.";

    if (payload.DateJoiningNigam && new Date(payload.DateJoiningNigam) > todayDate) return "Date of Joining in Nigam cannot be future.";
    if (payload.DateJoiningPresentRank && new Date(payload.DateJoiningPresentRank) > todayDate) return "Date of Joining to Present Rank cannot be future.";
    if (payload.DateJoiningPresentStation && new Date(payload.DateJoiningPresentStation) > todayDate) return "Date of Joining to Present Station cannot be future.";
    if (payload.PropertyReturnDate && new Date(payload.PropertyReturnDate) > todayDate) return "Property Return Date cannot be future.";
    if (payload.LastMedicalExamDate && new Date(payload.LastMedicalExamDate) > todayDate) return "Medical Exam Date cannot be future.";

    if (formType === "A1b" && !payload.ReportingUserId2) return "Second Reporting Authority is required for A1b.";
    if ((formType === "A1a" || formType === "A2") && payload.ReportingUserId2) return "Second Reporting Authority is not allowed for this form.";
    if (payload.OfficerUserId) {
    if (payload.ReportingUserId && payload.ReportingUserId === payload.OfficerUserId) {
        return "Officer and Reporting Authority cannot be same.";
    }
    if (payload.ReportingUserId2 && payload.ReportingUserId2 === payload.OfficerUserId) {
        return "Officer and Second Reporting Authority cannot be same.";
    }
    if (payload.ReviewingUserId && payload.ReviewingUserId === payload.OfficerUserId) {
        return "Officer and Review Authority cannot be same.";
    }
    if (payload.AcceptingUserId && payload.AcceptingUserId === payload.OfficerUserId) {
        return "Officer and Accepting Authority cannot be same.";
    }
}
    // var authorityValues = [
    //     payload.ReportingUserId,
    //     payload.ReportingUserId2,
    //     payload.ReviewingUserId,
    //     payload.AcceptingUserId
    // ].filter(function (x) { return !!x; });

    // if (authorityValues.length !== new Set(authorityValues).size) {
    //     return "Authority users cannot be same.";
    // }
    if (payload.ReportingUserId && payload.ReportingUserId2 && payload.ReportingUserId === payload.ReportingUserId2) {
        return "Reporting Authority and Second Reporting Authority cannot be same.";
    }

    return "";
}

$("#ccaForm").off("submit").on("submit", function (e) {
    e.preventDefault();

    if (isSubmitting) return;

    if (!currentAcrId || !hasSavedDraft) {
        alert("Please save draft first.");
        updateActionButtonsState();
        return;
    }

    if (isFormDirty) {
        alert("Please save draft again before submitting the updated form.");
        updateActionButtonsState();
        return;
    }

    var payload = buildPayload(false);
    var validationMessage = validatePayload(payload, false);

    if (validationMessage) {
        alert(validationMessage);
        return;
    }

    isDraft = false;
    isSubmitting = true;
    toggleActionButtons(true);

    submitDraftAcr(currentAcrId);
});

$("#btnSaveDraft").off("click").on("click", function () {
    if (isSubmitting) return;

    var payload = buildPayload(true);
    var validationMessage = validatePayload(payload, true);
    if (validationMessage) {
        alert(validationMessage);
        return;
    }

    isDraft = true;
    isSubmitting = true;
    toggleActionButtons(true);

    submitAppraisal(payload, null);
});

function toggleActionButtons(disabled) {
    if (disabled) {
        $("#btnSaveDraft, #btnSubmit").prop("disabled", true);
        return;
    }

    updateActionButtonsState();
}

function unlockSubmission() {
    isSubmitting = false;
    toggleActionButtons(false);
}

function beginFormBinding() {
    isBindingForm = true;
}

function endFormBinding() {
    isBindingForm = false;
    updateActionButtonsState();
}

function hasValidSubmitPayload() {
    return !validatePayload(buildPayload(false), false);
}

function markFormDirty() {
    if (isBindingForm || isFormReadonly) return;

    isFormDirty = true;
    updateActionButtonsState();
}

function updateActionButtonsState() {
    var canSaveDraft = !isFormReadonly && !isSubmitting && !isAdminUser();
    var canSubmit = canSaveDraft && hasSavedDraft && !isFormDirty && !!currentAcrId && hasValidSubmitPayload();

    $("#btnSaveDraft").prop("disabled", !canSaveDraft);
    $("#btnSubmit").prop("disabled", !canSubmit);
}

function submitDraftAcr(acrId) {
    $.ajax({
        url: BASE_URL + "api/cca/acr/" + acrId + "/submit",
        method: "POST",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (res.Success) {
                afterSuccess("Draft submitted successfully");
            } else {
                alert(res.Message || "Submit failed");
                unlockSubmission();
            }
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Submit failed"));
            unlockSubmission();
        }
    });
}

function setFormReadonly(flag) {
    isFormReadonly = !!flag;
    $("#ccaForm :input").prop("disabled", flag);
    updateActionButtonsState();
}

function submitAppraisal(payload) {
    if (!payload || !payload.OfficerUserId) {
        alert("Invalid payload");
        unlockSubmission();
        return;
    }

    if (isEditMode) {
        if (!currentAcrId) {
            alert("Missing ACR ID");
            unlockSubmission();
            return;
        }

        $.ajax({
            url: BASE_URL + "api/cca/acr/" + currentAcrId,
            method: "PATCH",
            headers: {
                "Authorization": "Bearer " + getToken(),
                "Content-Type": "application/json"
            },
            data: JSON.stringify(getPatchPayload(payload)),
            success: function (res) {
                if (!res.Success) {
                    alert(res.Message || "Error");
                    unlockSubmission();
                    return;
                }

                if (isDraft) {
                    hasSavedDraft = true;
                    isFormDirty = false;
                    isEditMode = true;
                    alert("Draft saved successfully");
                    loadAcrList();
                    unlockSubmission();
                    return;
                }

                submitDraftAcr(currentAcrId);
            },
            error: function (xhr) {
                alert(apiErrorMessage(xhr, "Draft save failed"));
                unlockSubmission();
            }
        });

        return;
    }

    $.ajax({
        url: BASE_URL + "api/cca/acr",
        method: "POST",
        headers: {
            "Authorization": "Bearer " + getToken(),
            "Content-Type": "application/json"
        },
        data: JSON.stringify(getCreatePayload(payload)),
        success: function (res) {
            if (!res.Success) {
                alert(res.Message || "Error");
                unlockSubmission();
                return;
            }

            var acrId = res.Data && res.Data.AcrId ? res.Data.AcrId : null;
            if (!acrId) {
                alert("AcrId not received from create API.");
                unlockSubmission();
                return;
            }

            currentAcrId = acrId;

            if (isDraft) {
                hasSavedDraft = true;
                isFormDirty = false;
                isEditMode = true;
                alert("Draft saved successfully");
                loadAcrList();
                unlockSubmission();
                return;
            }

            submitDraftAcr(acrId);
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Create failed"));
            unlockSubmission();
        }
    });
}

function afterSuccess(msg) {
    alert(msg || "ACR Submitted Successfully");
    closeModal();
    loadAcrList();
    unlockSubmission();
}

function loadOfficers() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/cca/officers",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    var list = res.Data.Officers || [];
                    var ddl = $("#officerName");
                    ddl.empty();
                    ddl.append('<option value="">-- Select Officer --</option>');

                    $.each(list, function (i, o) {
                        if (!o.DsgId) return;

                        ddl.append(
                            '<option value="' + o.UserId + '" data-formtype="' + (o.FormType || '') + '" data-dsgid="' + o.DsgId + '">' +
                            (o.DisplayName || '') + ' (' + (o.DsgDesc || '') + ')' +
                            '</option>'
                        );
                    });

                    $("#officerName").select2({
                        width: '100%',
                        placeholder: "Search Officer",
                        allowClear: true,
                        dropdownParent: $('#appraisalModal')
                    });
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

$("#officerName").off("change").on("change", function () {
    var selected = $(this).find(":selected");
    var officerUserId = $(this).val() || "";
    var dsgId = selected.data("dsgid");

    $("#designation").val(dsgId || "").trigger("change");

    // clear old auto-fill styles
    $("#reportingAuthority, #reviewAuthority, #acceptingAuthority, #reportingAuthority2").each(function () {
        $(this).next(".select2-container").find(".select2-selection").removeClass("auto-filled");
    });

    // reset existing authority selections when officer changes
    var preservedValues = {};
    bindAuthorityDropdowns(preservedValues);

    $("#reportingAuthority").val(null).trigger("change");
    $("#reviewAuthority").val(null).trigger("change");
    $("#acceptingAuthority").val(null).trigger("change");

    if ($("#reportingAuthority2").length) {
        $("#reportingAuthority2").val(null).trigger("change");
    }

    if (officerUserId && !isAdminUser()) {
        suggestAuthorityChain(officerUserId);
    }
});

$("#ccaForm").off("input.draftState change.draftState").on("input.draftState change.draftState", "input, select, textarea", function () {
    if ($(this).is(":button, [type='submit'], [type='button'], [type='reset']")) return;
    markFormDirty();
});

// Using getCommonStatusBadge from constant.js with CCA specific styling
function getStatusBadge(status) {
    var s = (status || "").toUpperCase();
    
    if (s === "DRAFT") return '<span class="status-badge status-draft">DRAFT</span>';
    if (s === "APPROVED") return '<span class="status-badge status-completed">APPROVED</span>';
    if (s === "REJECTED") return '<span class="status-badge status-rejected">REJECTED</span>';
    if (s.indexOf("PENDING") === 0) return '<span class="status-badge status-progress">' + s + '</span>';

    return '<span class="status-badge status-pending">' + (status || '--') + '</span>';
}

function loadAcrList() {
    $.ajax({
        url: getAcrListApiUrl(),
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                acrListData = [];
                filteredAcrListData = [];
                totalCount = 0;
                totalPages = 0;
                $("#ccaTableBody").html('<tr><td colspan="7" class="text-center text-danger">' + (res.Message || 'Failed to load records') + '</td></tr>');
                $("#paginationContainer").empty();
                $("#paginationInfo").text("");
                return;
            }

            acrListData = (res.Data && res.Data.Items) ? res.Data.Items : [];
            totalCount = (res.Data && typeof res.Data.TotalCount === "number") ? res.Data.TotalCount : acrListData.length;
            totalPages = (res.Data && typeof res.Data.TotalPages === "number") ? res.Data.TotalPages : (totalCount ? Math.ceil(totalCount / pageSize) : 0);
            currentPage = (res.Data && typeof res.Data.PageNumber === "number") ? res.Data.PageNumber : currentPage;
            pageSize = (res.Data && typeof res.Data.PageSize === "number") ? res.Data.PageSize : pageSize;
            $("#pageSize").val(pageSize.toString());
            $("#statusFilter").val(currentStatusFilter);

            filteredAcrListData = acrListData.slice();

            applySorting();
            renderAcrTable();
        },
        error: function () {
            acrListData = [];
            filteredAcrListData = [];
            $("#ccaTableBody").html('<tr><td colspan="7" class="text-center text-danger">Failed to load records</td></tr>');
            $("#paginationContainer").empty();
            $("#paginationInfo").text("");
            totalCount = 0;
            totalPages = 0;
        }
    });
}

function setSelect2ByText(selector, text) {
    var ddl = $(selector);
    ddl.find("option").each(function () {
        if ($(this).text().trim() === text) {
            ddl.val($(this).val()).trigger("change");
        }
    });
}

function bindAcrDetail(data) {
    $("#periodFrom").val(formatDate(data.PostingFrom));
    $("#periodTo").val(formatDate(data.PostingTo));

    $("#dob").val(formatDate(data.DateOfBirth));
    $("#joiningNigam").val(formatDate(data.DateJoiningNigam));
    $("#joiningRank").val(formatDate(data.DateJoiningPresentRank));
    $("#joiningStation").val(formatDate(data.DateJoiningPresentStation));

    $("#academicQualification").val(data.AcademicQualification || "");
    $("#technicalQualification").val(data.TechnicalQualification || "");
    $("#deptExam").val(data.DepartmentalExamPassed || "");
    $("#propertyReturnDate").val(formatDate(data.PropertyReturnDate));
    $("#medicalExamDate").val(formatDate(data.LastMedicalExamDate));

    $("#officerName").val(data.OfficerUserId || "").trigger("change");
    setDesignationValue(data);
    setSelect2ByText("#placePosting", data.Location || "");

    setTimeout(function () {
        $("#reportingAuthority").val(data.ReportingAuthorityUserId || "").trigger("change");

        if ($("#reportingAuthority2").length) {
            $("#reportingAuthority2").val(data.ReportingAuthority2UserId || "").trigger("change");
        }

        $("#reviewAuthority").val(data.ReviewingAuthorityUserId || "").trigger("change");
        $("#acceptingAuthority").val(data.AcceptingAuthorityUserId || "").trigger("change");
        endFormBinding();
    }, 300);
}

function viewAcr(acrId) {
    $.ajax({
        url: BASE_URL + "api/cca/acr/" + acrId,
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                alert(res.Message || "Error");
                return;
            }

            var data = res.Data;
            openAppraisalModal();

            currentAcrId = data.AcrId || acrId;
            isEditMode = ((data.Status || "").toUpperCase() === "DRAFT");
            formType = data.FormType || "";

            $("#formTitle").text(getFormTitle(formType));
            applyFormRules();
            beginFormBinding();
            bindAcrDetail(data);

            var statusUpper = (data.Status || "").toUpperCase();
            var canEditForm = statusUpper === "DRAFT" && !isAdminUser();
            var canSubmitDraft = statusUpper === "DRAFT" && !isAdminUser();
            hasSavedDraft = canSubmitDraft;
            isFormDirty = false;

            $("#btnSubmit").show();
            $("#btnSaveDraft").show();
            setFormReadonly(!canEditForm);
            updateActionButtonsState();
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Failed to load ACR detail"));
        }
    });
}

function suggestAuthorityChain(officerUserId) {
    if (!officerUserId || isAdminUser()) {
        $("#authoritySuggestionStatus").html("");
        return;
    }

    $("#authoritySuggestionStatus").html('<span class="text-muted">Fetching authority suggestions...</span>');

    $.ajax({
        url: BASE_URL + "api/cca/officers/" + officerUserId + "/authorities/suggestions",
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            $("#authoritySuggestionStatus").html("");

            if (!res || !res.Success || !res.Data) {
                if (res && res.Message) {
                    $("#authoritySuggestionStatus").html('<span class="text-warning">' + res.Message + '</span>');
                }
                return;
            }

            var data = res.Data;

            if (data.ReportingUserId) {
                $("#reportingAuthority").val(data.ReportingUserId).trigger("change");
                $("#reportingAuthority").next(".select2-container").find(".select2-selection").addClass("auto-filled");
            }

            if (data.ReviewingUserId) {
                $("#reviewAuthority").val(data.ReviewingUserId).trigger("change");
                $("#reviewAuthority").next(".select2-container").find(".select2-selection").addClass("auto-filled");
            }
        },
        error: function (xhr) {
            var msg = apiErrorMessage(xhr, "Authority suggestion not available.");
            $("#authoritySuggestionStatus").html('<span class="text-warning">' + msg + '</span>');
        }
    });
}
</script>
</asp:Content>
