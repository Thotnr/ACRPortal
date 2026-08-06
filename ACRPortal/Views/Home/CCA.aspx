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
        padding-left: 15px;
        border-radius: 14px;
        border: 1px solid var(--cca-line);
        background: #f8fbff;
    }

    #pageSize {
        appearance: auto;
        -webkit-appearance: menulist;
        -moz-appearance: menulist;
        padding-right: 28px;
        cursor: pointer;
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

.admin-acr-modal {
    width: 95vw;
    max-width: 1180px;
}

#adminAcrReportModal .modal-content {
    border-radius: 18px;
    background: #f4f7fb;
    overflow: hidden;
}

#adminAcrReportModal .modal-header {
    position: sticky;
    top: 0;
    z-index: 5;
    background: #173b63;
    color: #fff;
    border-bottom: 0;
}

#adminAcrReportModal .modal-title {
    font-size: 18px;
    font-weight: 800;
}

#adminAcrReportModal .modal-body {
    max-height: 72vh;
    overflow-y: auto;
    background: #f4f7fb;
    padding: 18px;
}

.admin-report-toolbar {
    position: sticky;
    top: 61px;
    z-index: 4;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    align-items: center;
    padding: 12px 16px;
    background: rgba(244, 247, 251, 0.96);
    border-bottom: 1px solid #d9e3ef;
    backdrop-filter: blur(6px);
}

.admin-report {
    color: #172033;
    font-size: 14px;
}

.admin-report-shell {
    display: grid;
    grid-template-columns: 190px minmax(0, 1fr);
    gap: 16px;
}

.admin-report-nav {
    position: sticky;
    top: 0;
    align-self: start;
    padding: 12px;
    border: 1px solid #d9e3ef;
    border-radius: 12px;
    background: #fff;
    box-shadow: 0 10px 26px rgba(23, 59, 99, 0.08);
}

.admin-report-nav-title {
    margin: 0 0 8px;
    font-size: 11px;
    font-weight: 800;
    color: #64748b;
    letter-spacing: .08em;
    text-transform: uppercase;
}

.admin-report-nav a {
    display: block;
    padding: 7px 8px;
    border-radius: 8px;
    color: #173b63;
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
}

.admin-report-nav a:hover {
    background: #eef6ff;
}

.admin-report-content {
    min-width: 0;
}

.admin-report-header {
    border: 1px solid #cfdced;
    border-radius: 14px;
    padding: 20px;
    margin-bottom: 16px;
    background: #fff;
    box-shadow: 0 14px 34px rgba(23, 59, 99, 0.08);
}

.admin-report-header-top {
    display: flex;
    justify-content: space-between;
    gap: 18px;
    align-items: flex-start;
}

.admin-report-title {
    margin: 0;
    font-size: 24px;
    line-height: 1.2;
    font-weight: 800;
    color: #173b63;
}

.admin-report-subtitle {
    margin: 5px 0 0;
    color: #475569;
    font-size: 15px;
    font-weight: 700;
}

.admin-report-note {
    margin: 8px 0 0;
    color: #64748b;
    font-size: 13px;
}

.admin-report-ref {
    margin-top: 10px;
    color: #64748b;
    font-size: 12px;
    overflow-wrap: anywhere;
}

.admin-report-header-meta {
    display: grid;
    grid-template-columns: repeat(2, minmax(145px, 1fr));
    gap: 10px;
    margin-top: 18px;
}

.admin-report-kpi {
    padding: 10px 12px;
    border: 1px solid #e1e9f3;
    border-radius: 10px;
    background: #f8fbff;
    min-width: 0;
}

.admin-report-label {
    display: block;
    margin-bottom: 3px;
    color: #64748b;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .04em;
    text-transform: uppercase;
}

.admin-report-value {
    white-space: pre-wrap;
    overflow-wrap: anywhere;
    font-size: 14px;
    line-height: 1.45;
    color: #172033;
}

.admin-report-na {
    color: #94a3b8;
    font-style: italic;
}

.admin-report-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 5px 10px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .03em;
    text-transform: uppercase;
    border: 1px solid transparent;
    white-space: nowrap;
}

.admin-report-badge.status-approved,
.admin-report-badge.status-completed {
    background: #dcfce7;
    color: #166534;
    border-color: #bbf7d0;
}

.admin-report-badge.status-progress,
.admin-report-badge.status-current,
.admin-report-badge.status-submitted {
    background: #dbeafe;
    color: #1d4ed8;
    border-color: #bfdbfe;
}

.admin-report-badge.status-pending {
    background: #fef3c7;
    color: #92400e;
    border-color: #fde68a;
}

.admin-report-badge.status-rejected {
    background: #fee2e2;
    color: #991b1b;
    border-color: #fecaca;
}

.admin-report-badge.status-na,
.admin-report-badge.status-skipped {
    background: #f1f5f9;
    color: #64748b;
    border-color: #e2e8f0;
}

.admin-report-section {
    border: 1px solid #d9e3ef;
    border-radius: 12px;
    background: #fff;
    margin-bottom: 16px;
    overflow: hidden;
    box-shadow: 0 10px 26px rgba(23, 59, 99, 0.06);
}

.admin-report-section-title {
    margin: 0;
    padding: 13px 16px;
    border-bottom: 1px solid #e5edf6;
    background: #f8fbff;
    color: #173b63;
    font-size: 14px;
    font-weight: 800;
    letter-spacing: .04em;
    text-transform: uppercase;
}

.admin-report-section-body {
    padding: 16px;
}

.admin-report-summary-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 12px;
}

.admin-report-summary-card {
    border: 1px solid #d9e3ef;
    border-radius: 10px;
    background: #fff;
    overflow: hidden;
}

.admin-report-summary-card h6,
.admin-report-subsection-title {
    margin: 0 0 10px;
    color: #173b63;
    font-size: 13px;
    font-weight: 800;
}

.admin-report-summary-card h6 {
    padding: 11px 12px 0;
}

.admin-report-facts {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 10px 18px;
}

.admin-report-summary-card .admin-report-facts {
    grid-template-columns: 1fr;
    padding: 0 12px 12px;
}

.admin-report-fact {
    min-width: 0;
}

.admin-report-table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 13px;
}

.admin-report-table th,
.admin-report-table td {
    padding: 9px 10px;
    border-bottom: 1px solid #e5edf6;
    vertical-align: top;
    overflow-wrap: anywhere;
}

.admin-report-table th {
    color: #173b63;
    background: #f8fbff;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .04em;
    text-transform: uppercase;
}

.admin-report-score-table td:nth-child(2),
.admin-report-score-table td:nth-child(4) {
    width: 14%;
    font-weight: 800;
    color: #173b63;
}

.admin-report-grade-panel,
.admin-report-empty {
    border: 1px solid #d9e3ef;
    border-radius: 10px;
    padding: 13px 14px;
    background: #f8fbff;
    overflow-wrap: anywhere;
}

.admin-report-grade-panel {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    align-items: center;
    margin-top: 12px;
}

.admin-report-grade {
    font-size: 22px;
    font-weight: 900;
    color: #173b63;
}

.admin-report-empty {
    color: #64748b;
    font-weight: 700;
}

.admin-report-subsection {
    margin-bottom: 16px;
}

.admin-report-subsection:last-child {
    margin-bottom: 0;
}

.admin-report-workflow {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.admin-report-step {
    flex: 1 1 135px;
    min-width: 130px;
    border: 1px solid #d9e3ef;
    border-radius: 10px;
    padding: 10px;
    background: #fff;
}

.admin-report-step-title {
    margin-bottom: 6px;
    color: #173b63;
    font-weight: 800;
    font-size: 13px;
}

.admin-report-final-panel {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 12px;
    border: 1px solid #bfdbfe;
    border-left: 5px solid #2563eb;
    border-radius: 12px;
    padding: 14px;
    background: #eff6ff;
}

.admin-report-final-panel .admin-report-final-remarks {
    grid-column: 1 / -1;
}

.admin-report-error,
.admin-report-loading {
    padding: 28px;
    text-align: center;
    border: 1px solid #d9e3ef;
    border-radius: 12px;
    background: #fff;
}

.admin-report-error {
    color: #b91c1c;
}

.admin-report-loading {
    color: #64748b;
}

body.admin-acr-modal-open {
    overflow: hidden;
}

@media (max-width: 992px) {
    .admin-report-shell { grid-template-columns: 1fr; }
    .admin-report-nav { display: none; }
    .admin-report-summary-grid,
    .admin-report-header-meta,
    .admin-report-final-panel { grid-template-columns: 1fr; }
}

@media (max-width: 768px) {
    #adminAcrReportModal .modal-body { padding: 12px; }
    .admin-report-header-top,
    .admin-report-grade-panel { flex-direction: column; align-items: flex-start; }
    .admin-report-facts { grid-template-columns: 1fr; }
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
                <div class="d-flex flex-wrap justify-content-lg-end align-items-center">
                    <div class="search-wrap flex-grow-1 mr-3 mb-2 mb-lg-0" style="min-width:240px;">
                        <i class="fas fa-search"></i>
                        <input type="text" id="ccaSearchBox" class="form-control search-input" placeholder="Search officer name...">
                    </div>
                    <select id="statusFilter" class="form-control mr-3 mb-2 mb-lg-0" style="width:210px;">
                        <option value="">All Status</option>
                        <option value="DRAFT">DRAFT</option>
                        <option value="PENDING_OFFICER">PENDING_OFFICER</option>
                        <option value="PENDING_REPORTING">PENDING_REPORTING</option>
                        <option value="PENDING_REVIEWING">PENDING_REVIEWING</option>
                        <option value="PENDING_ACCEPTING">PENDING_ACCEPTING</option>
                        <option value="APPROVED">APPROVED</option>
                        <option value="REJECTED">REJECTED</option>
                    </select>
                    <button type="button" id="resetFiltersBtn" class="btn btn-outline-secondary mb-2 mb-lg-0" title="Reset filters" style="min-width:72px; min-height:46px; padding:0 12px; border-radius:14px;">Reset</button>
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
                            <div class="form-group col-12">
                                <label>Place / Office of Posting <span class="text-required">*</span></label>
                                <select class="form-control" id="placePosting"></select>
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

<div class="modal fade" id="adminAcrReportModal" tabindex="-1" role="dialog" aria-labelledby="adminAcrReportTitle" aria-hidden="true">
    <div class="modal-dialog admin-acr-modal" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="adminAcrReportTitle">Complete ACR Lifecycle Report</h5>
                <button type="button" class="close" onclick="closeAdminAcrReportModal()" aria-label="Close ACR lifecycle report"><span aria-hidden="true">&times;</span></button>
            </div>
            <div class="admin-report-toolbar">
                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="closeAdminAcrReportModal()">Close</button>
                <button type="button" class="btn btn-primary btn-sm" id="adminAcrPdfBtn" onclick="printAdminAcrReport()">
                    <i class="fas fa-file-pdf mr-1"></i> <span id="adminAcrPdfBtnText">Download PDF</span>
                </button>
            </div>
            <div class="modal-body">
                <div id="adminAcrReportBody" class="admin-report">
                    <div class="admin-report-loading">Loading report...</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
var BASE_URL = '<%= Url.Content("~/") %>';
var formType = "";
var designationsList = [];
var employeesList = [];
var zoneList = [];
var circleList = [];
var divisionList = [];
var subDivisionList = [];
var placePostingMode = "";

var isDraft = false;
var currentAcrId = null;
var isEditMode = false;
var isSubmitting = false;
var hasSavedDraft = false;
var isFormDirty = false;
var isBindingForm = false;
var isFormReadonly = false;
var currentUserRole = (localStorage.getItem("role") || "").toUpperCase();
var selectedAdminAcrDetail = null;

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
    $("#adminAcrReportModal").on("hidden.bs.modal", function () {
        $("body").removeClass("admin-acr-modal-open");
    });

    var token = localStorage.getItem("token");
    if (!token) {
        window.location = BASE_URL + "Login/UserAuth";
        return;
    }

    applyTodayMaxToDates();

    syncAdminUiState();

    loadCurrentUser(token)
        .then(function () { return loadDesignations(); })
        .then(function () { return loadZonesForDropdown(); })
        .then(function () { return loadCirclesForDropdown(); })
        .then(function () { return loadDivisionsForDropdown(); })
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

    $("#resetFiltersBtn").on("click", function () {
        resetCcaFilters();
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
    if (xhr && xhr.responseText) {
        return xhr.responseText.length > 300 ? xhr.responseText.substring(0, 300) : xhr.responseText;
    }
    return fallback;
}

function loadCurrentUser(token) {
    return new Promise(function (resolve, reject) {
        $.ajax({
            url: BASE_URL + "api/auth/me",
            method: "GET",
            headers: { "Authorization": "Bearer " + token },
            success: function (res) {
                if (!res.Success) {
                    window.location = BASE_URL + "Login/UserAuth";
                    reject();
                    return;
                }

                var user = res.Data || {};
                currentUserRole = (user.SystemRole || user.Role || currentUserRole || "").toUpperCase();
                if (currentUserRole) {
                    localStorage.setItem("role", currentUserRole);
                }
                syncAdminUiState();
                resolve();
            },
            error: function () {
                window.location = BASE_URL + "Login/UserAuth";
                reject();
            }
        });
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
        if (!isAllowedPostingDesignation(d.Dsg)) return;

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
    bindPlacePostingDropdown(getPostingModeForDesignation(selected.data("dsg")));

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
    bindPlacePostingDropdown("");
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

function resetCcaFilters() {
    clearTimeout(ccaSearchDebounceTimer);
    currentSearchTerm = "";
    currentStatusFilter = "";
    currentPage = 1;
    $("#ccaSearchBox").val("");
    $("#statusFilter").val("");
    loadAcrList();
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
        var actionText = isAdminUser() ? "View Report" : "View";
        tbody.append(
            '<tr>' +
                '<td>' + (a.OfficerName || '--') + '</td>' +
                '<td>' + (a.Dsg || '--') + '</td>' +
                '<td>' + (a.Location || '--') + '</td>' +
                '<td>' + (a.PostingFrom || '--') + '</td>' +
                '<td>' + (a.PostingTo || '--') + '</td>' +
                '<td>' + getStatusBadge(a.Status) + '</td>' +
                '<td><button class="btn btn-sm btn-info" onclick="viewAcr(\'' + a.AcrId + '\')">' + actionText + '</button></td>' +
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

function isAllowedPostingDesignation(dsg) {
    var code = (dsg || "").toString().trim().toUpperCase();
    return code === "CE" ||
        code === "CFO" ||
        code === "XEN" ||
        code === "AO" ||
        code === "SE" ||
        code === "SDO" ||
        code === "AE";
}

function getPostingModeForDesignation(dsg) {
    var code = (dsg || "").toString().trim().toUpperCase();

    if (code === "CE" || code === "CFO") return "ZONE";
    if (code === "XEN" || code === "AO") return "DIVISION";
    if (code === "SE") return "CIRCLE";
    if (code === "SDO" || code === "AE") return "SUBDIVISION";

    return "";
}

function loadZonesForDropdown() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/admin/masters/zones",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    zoneList = res.Data.Zones || [];
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function loadCirclesForDropdown() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/admin/masters/circles",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    circleList = res.Data.Circles || [];
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function loadDivisionsForDropdown() {
    return new Promise(function (resolve) {
        $.ajax({
            url: BASE_URL + "api/admin/masters/divisions",
            method: "GET",
            headers: { "Authorization": "Bearer " + getToken() },
            success: function (res) {
                if (res.Success) {
                    divisionList = res.Data.Divisions || [];
                }
                resolve();
            },
            error: function () { resolve(); }
        });
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
                }
                resolve();
            },
            error: function () { resolve(); }
        });
    });
}

function bindPlacePostingDropdown(mode, preservedText) {
    var ddl = $("#placePosting");
    var previousMode = placePostingMode;
    var currentText = preservedText || "";

    if (!currentText && previousMode === mode && ddl.hasClass("select2-hidden-accessible")) {
        var selectedData = ddl.select2("data") || [];
        currentText = selectedData.length ? (selectedData[0].text || "") : "";
    }

    if (ddl.hasClass("select2-hidden-accessible")) {
        ddl.select2("destroy");
    }

    ddl.empty();
    placePostingMode = mode || "";

    var placeholder = "Select designation first";
    var list = [];

    if (placePostingMode === "ZONE") {
        placeholder = "Search Zone";
        list = zoneList.map(function (z) {
            return { value: z.ZoneId, text: z.ZoneName || "" };
        });
    } else if (placePostingMode === "CIRCLE") {
        placeholder = "Search Circle";
        list = circleList.map(function (c) {
            return { value: c.CircleId, text: c.Circle || "" };
        });
    } else if (placePostingMode === "DIVISION") {
        placeholder = "Search Division";
        list = divisionList.map(function (d) {
            return { value: d.DivisionId, text: d.Division || "" };
        });
    } else if (placePostingMode === "SUBDIVISION") {
        placeholder = "Search SubDivision";
        list = subDivisionList.map(function (s) {
            return { value: s.SubDivisionId, text: s.SubDivision || "" };
        });
    }

    ddl.append('<option value=""></option>');

    list.forEach(function (item) {
        ddl.append('<option value="' + item.value + '">' + item.text + '</option>');
    });

    ddl.select2({
        width: '100%',
        placeholder: placeholder,
        allowClear: true,
        dropdownParent: $('#appraisalModal')
    });

    ddl.prop("disabled", !placePostingMode);

    if (currentText) {
        setSelect2ByText("#placePosting", currentText);
    } else {
        ddl.val(null).trigger("change");
    }
}

function getDesignationById(dsgId) {
    var id = dsgId ? dsgId.toString() : "";
    for (var i = 0; i < designationsList.length; i++) {
        if ((designationsList[i].DsgId || "").toString() === id) {
            return designationsList[i];
        }
    }
    return null;
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
                        var officerDesignation = getDesignationById(o.DsgId);
                        if (!officerDesignation || !isAllowedPostingDesignation(officerDesignation.Dsg)) return;

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
    bindPlacePostingDropdown(placePostingMode, data.Location || "");
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

function closeAdminAcrReportModal() {
    $("#adminAcrReportModal").modal("hide");
    $("body").removeClass("admin-acr-modal-open");
}

function escapeHtml(value) {
    return (value === null || value === undefined ? "" : String(value))
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function hasReportValue(value) {
    return value !== null && value !== undefined && !(typeof value === "string" && value.trim() === "");
}

function splitPascalCase(value) {
    return (value || "")
        .replace(/_/g, " ")
        .replace(/([a-z])([A-Z])/g, "$1 $2")
        .replace(/\b\w/g, function (c) { return c.toUpperCase(); });
}

function parseJsonValue(value) {
    if (typeof value !== "string") return null;
    var trimmed = value.trim();
    if (!trimmed || (trimmed.charAt(0) !== "[" && trimmed.charAt(0) !== "{")) return null;

    try {
        return JSON.parse(trimmed);
    } catch (e) {
        return null;
    }
}

function normalizeStructuredCell(value) {
    if (!hasReportValue(value)) return '<span class="admin-report-na">NA</span>';
    if (typeof value === "boolean") return value ? "Yes" : "No";
    return escapeHtml(String(value));
}

function renderObjectTable(items) {
    if (!items || !items.length) return '<span class="admin-report-na">NA</span>';

    var keys = [];
    items.forEach(function (item) {
        if (!item || typeof item !== "object" || Array.isArray(item)) return;
        Object.keys(item).forEach(function (key) {
            if (keys.indexOf(key) === -1) keys.push(key);
        });
    });

    if (!keys.length) {
        return '<ol class="admin-report-list">' + items.map(function (item) {
            return '<li>' + normalizeStructuredCell(item) + '</li>';
        }).join("") + '</ol>';
    }

    return '<table class="admin-report-mini-table">' +
        '<thead><tr><th>#</th>' + keys.map(function (key) {
            return '<th>' + escapeHtml(splitPascalCase(key)) + '</th>';
        }).join("") + '</tr></thead>' +
        '<tbody>' + items.map(function (item, index) {
            return '<tr><td>' + (index + 1) + '</td>' + keys.map(function (key) {
                return '<td>' + normalizeStructuredCell(item ? item[key] : null) + '</td>';
            }).join("") + '</tr>';
        }).join("") + '</tbody>' +
    '</table>';
}

function renderStructuredValue(value) {
    var parsed = parseJsonValue(value);
    if (!parsed && value && typeof value === "object") {
        parsed = value;
    }
    if (!parsed) return null;

    if (Array.isArray(parsed)) {
        return renderObjectTable(parsed);
    }

    if (typeof parsed === "object") {
        return renderObjectTable([parsed]);
    }

    return null;
}

function adminValue(value) {
    if (!hasReportValue(value)) {
        return '<span class="admin-report-na">NA</span>';
    }
    if (typeof value === "boolean") {
        return value ? "Yes" : "No";
    }
    var structured = renderStructuredValue(value);
    if (structured) return structured;
    return escapeHtml(String(value));
}

function formatAdminDate(value) {
    if (!hasReportValue(value)) return "";
    var text = String(value);
    var dateOnly = /^(\d{4})-(\d{2})-(\d{2})$/.exec(text);
    var d = dateOnly
        ? new Date(Number(dateOnly[1]), Number(dateOnly[2]) - 1, Number(dateOnly[3]))
        : new Date(text);
    if (isNaN(d.getTime())) return text;
    return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
}

function formatAdminDateTime(value) {
    if (!hasReportValue(value)) return "";
    var d = new Date(value);
    if (isNaN(d.getTime())) return value;
    return d.toLocaleString("en-GB", {
        day: "2-digit",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: true
    });
}

function authorityDisplay(name, loginId, userId) {
    if (name || loginId) {
        return (name || "") + (loginId ? " (" + loginId + ")" : "");
    }

    var match = employeesList.find(function (e) { return e.UserId === userId; });
    if (match) {
        return (match.DisplayName || "") + (match.LoginId ? " (" + match.LoginId + ")" : "");
    }

    return userId || "";
}

function statusBadgeClass(status) {
    var s = (status || "").toString().toLowerCase();
    if (s.indexOf("reject") >= 0) return "status-rejected";
    if (s.indexOf("approve") >= 0 || s.indexOf("complete") >= 0) return "status-approved";
    if (s.indexOf("submit") >= 0 || s.indexOf("progress") >= 0 || s.indexOf("current") >= 0) return "status-progress";
    if (s.indexOf("pending") >= 0 || s.indexOf("draft") >= 0) return "status-pending";
    if (s.indexOf("skip") >= 0) return "status-skipped";
    return "status-na";
}

function renderStatusBadge(status) {
    var label = hasReportValue(status) ? String(status) : "Not Applicable";
    return '<span class="admin-report-badge ' + statusBadgeClass(label) + '">' + escapeHtml(label) + '</span>';
}

function renderFact(label, value, isHtml) {
    return '<div class="admin-report-fact"><span class="admin-report-label">' + escapeHtml(label) + '</span>' +
        '<div class="admin-report-value">' + (isHtml ? value : adminValue(value)) + '</div></div>';
}

function renderFacts(fields) {
    return '<div class="admin-report-facts">' + fields.map(function (field) {
        return renderFact(field[0], field[1], field[2]);
    }).join("") + '</div>';
}

function renderSection(id, title, bodyHtml) {
    return '<section class="admin-report-section" id="' + escapeHtml(id) + '">' +
        '<h6 class="admin-report-section-title">' + escapeHtml(title) + '</h6>' +
        '<div class="admin-report-section-body">' + bodyHtml + '</div>' +
    '</section>';
}

function renderSubsection(title, bodyHtml) {
    return '<div class="admin-report-subsection">' +
        '<h6 class="admin-report-subsection-title">' + escapeHtml(title) + '</h6>' +
        bodyHtml +
    '</div>';
}

function getFinalDecisionStatus(decision, fallbackStatus) {
    decision = decision || {};
    if (decision.IsApproved === true) return "Approved";
    if (decision.IsApproved === false) return "Rejected";
    if (decision.IsDecided) return "Submitted";
    return fallbackStatus || "Pending";
}

function getCurrentAuthorityStage(data) {
    data = data || {};
    var self = data.SelfAppraisal || {};
    var ra1 = data.Ra1Assessment || {};
    var ra2 = data.Ra2Assessment || {};
    var reviewing = data.ReviewingAssessment || {};
    var decision = data.Decision || {};
    var ra2Assigned = hasReportValue(data.ReportingAuthority2UserId) || hasReportValue(data.ReportingAuthority2Name) || hasReportValue(data.ReportingAuthority2LoginId);
    if (!self.IsSubmitted && !self.IsSkipped) return "Employee / Officer Self-Appraisal";
    if (!ra1.IsSubmitted && !ra1.IsSkipped) return "Reporting Authority - RA1";
    if (ra2Assigned && !ra2.IsSubmitted && !ra2.IsSkipped) return "Reporting Authority - RA2";
    if (!reviewing.IsSubmitted && !reviewing.IsSkipped) return "Reviewing Authority";
    if (!decision.IsDecided) return "Accepting Authority";
    return "Final Decision";
}

function buildWorkflowStages(data) {
    data = data || {};
    var self = data.SelfAppraisal || {};
    var ra1 = data.Ra1Assessment || {};
    var ra2 = data.Ra2Assessment || {};
    var reviewing = data.ReviewingAssessment || {};
    var decision = data.Decision || {};
    var ra2Assigned = hasReportValue(data.ReportingAuthority2UserId) || hasReportValue(data.ReportingAuthority2Name) || hasReportValue(data.ReportingAuthority2LoginId);
    var stages = [
        { title: "CCA Raised", status: hasReportValue(data.CreatedAt) ? "Completed" : "Pending" },
        { title: "Self-Appraisal", status: self.IsSkipped ? "Skipped" : self.IsSubmitted ? "Completed" : "Pending" },
        { title: "RA1", status: ra1.IsSkipped ? "Skipped" : ra1.IsSubmitted ? "Completed" : "Pending" },
        { title: "RA2", status: !ra2Assigned ? "Not Applicable" : ra2.IsSkipped ? "Skipped" : ra2.IsSubmitted ? "Completed" : "Pending" },
        { title: "Reviewing Authority", status: reviewing.IsSkipped ? "Skipped" : reviewing.IsSubmitted ? "Completed" : "Pending" },
        { title: "Accepting Authority", status: decision.IsDecided ? "Completed" : "Pending" },
        { title: "Final Decision", status: decision.IsDecided ? getFinalDecisionStatus(decision, data.Status) : "Pending" }
    ];
    for (var i = 0; i < stages.length; i++) {
        if (stages[i].status === "Pending") {
            stages[i].status = "Current";
            break;
        }
    }
    return stages;
}

function renderWorkflow(data) {
    return '<div class="admin-report-workflow">' + buildWorkflowStages(data).map(function (stage) {
        return '<div class="admin-report-step"><div class="admin-report-step-title">' + escapeHtml(stage.title) + '</div>' +
            renderStatusBadge(stage.status) + '</div>';
    }).join("") + '</div>';
}

function renderSummaryGroup(title, fields) {
    return '<div class="admin-report-summary-card"><h6>' + escapeHtml(title) + '</h6>' + renderFacts(fields) + '</div>';
}

function renderOverviewGroups(groups, forPrint) {
    if (!forPrint) {
        return '<div class="admin-report-summary-grid">' + groups.map(function (group) {
            return renderSummaryGroup(group.title, group.fields);
        }).join("") + '</div>';
    }
    var maxRows = Math.max.apply(null, groups.map(function (group) { return group.fields.length; }));
    var html = '<table class="admin-report-table admin-report-overview-table"><thead><tr>' +
        groups.map(function (group) { return '<th colspan="2">' + escapeHtml(group.title) + '</th>'; }).join("") +
        '</tr></thead><tbody>';
    for (var i = 0; i < maxRows; i++) {
        html += '<tr>' + groups.map(function (group) {
            var field = group.fields[i] || ["", ""];
            return '<td><strong>' + escapeHtml(field[0]) + '</strong></td><td>' + (field[2] ? field[1] : adminValue(field[1])) + '</td>';
        }).join("") + '</tr>';
    }
    return html + '</tbody></table>';
}

function scoreRows(a) {
    a = a || {};
    return [
        ["Work Targets", a.WorkTargets, "Work Quality", a.WorkQuality],
        ["Exceptional Work", a.WorkExceptional, "Attitude", a.AttrAttitude],
        ["Responsibility", a.AttrResponsibility, "Stability", a.AttrStability],
        ["Communication", a.AttrCommunication, "Moral Courage", a.AttrMoralCourage],
        ["Leadership", a.AttrLeadership, "Timeliness", a.AttrTimeliness],
        ["Knowledge", a.CompKnowledge, "Planning", a.CompPlanning],
        ["Decision Making", a.CompDecision, "Initiative", a.CompInitiative],
        ["Teamwork", a.CompTeamwork, "Attributes Overall", a.AttrOverall],
        ["Work Overall", a.WorkOverall, "Competency Overall", a.CompOverall]
    ];
}

function hasAssessmentScores(a) {
    return scoreRows(a).some(function (row) {
        return hasReportValue(row[1]) || hasReportValue(row[3]);
    });
}

function renderScoreTable(a) {
    return '<table class="admin-report-table admin-report-score-table"><thead><tr>' +
        '<th>Performance Area</th><th>Score</th><th>Performance Area</th><th>Score</th></tr></thead><tbody>' +
        scoreRows(a).map(function (row) {
            return '<tr><td>' + escapeHtml(row[0]) + '</td><td>' + adminValue(row[1]) + '</td>' +
                '<td>' + escapeHtml(row[2]) + '</td><td>' + adminValue(row[3]) + '</td></tr>';
        }).join("") + '</tbody></table>';
}

function renderGradePanel(label, grade) {
    return '<div class="admin-report-grade-panel"><div><span class="admin-report-label">' + escapeHtml(label) +
        '</span><div class="admin-report-value">Grade supplied by workflow</div></div><div class="admin-report-grade">' +
        adminValue(grade) + '</div></div>';
}

function renderAssessmentSection(id, title, filledBy, assessment, options) {
    assessment = assessment || {};
    options = options || {};
    if (options.notApplicable) {
        return renderSection(id, title, '<div class="admin-report-empty">' + escapeHtml(title) + ': Not Applicable' +
            (options.reason ? '<br><span class="admin-report-na">' + escapeHtml(options.reason) + '</span>' : '') + '</div>');
    }
    if (options.pending && !assessment.Exists && !assessment.IsSubmitted && !assessment.IsSkipped) {
        return renderSection(id, title, '<div class="admin-report-empty">' + escapeHtml(title) + ': Pending' +
            (filledBy ? '<br>Assigned to: ' + escapeHtml(filledBy) : '') + '</div>');
    }
    var submission = renderSubsection("Submission details", renderFacts([
        ["Filled by", filledBy],
        ["Exists", assessment.Exists],
        ["Skipped", assessment.IsSkipped],
        ["Submitted", assessment.IsSubmitted],
        ["Submitted at", formatAdminDateTime(assessment.SubmittedAt)],
        ["Agreement with self-appraisal", assessment.AgreeWithSelf],
        ["Disagreement details", assessment.DisagreeDetails],
        ["Integrity comments", assessment.IntegrityComments],
        ["Remarks", assessment.Remarks]
    ]));
    var performance = hasAssessmentScores(assessment)
        ? renderSubsection("Performance assessment", renderScoreTable(assessment) + renderGradePanel("Overall Grade", assessment.OverallGrade))
        : renderSubsection("Performance assessment", '<div class="admin-report-empty">No performance assessment scores available.</div>' + renderGradePanel("Overall Grade", assessment.OverallGrade));
    return renderSection(id, title, submission + performance);
}

function overrideRows(overrides) {
    overrides = overrides || {};
    return [
        ["Work Targets", overrides.WorkTargets, "Work Quality", overrides.WorkQuality],
        ["Exceptional Work", overrides.WorkExceptional, "Attitude", overrides.AttrAttitude],
        ["Responsibility", overrides.AttrResponsibility, "Stability", overrides.AttrStability],
        ["Communication", overrides.AttrCommunication, "Moral Courage", overrides.AttrMoralCourage],
        ["Leadership", overrides.AttrLeadership, "Timeliness", overrides.AttrTimeliness],
        ["Knowledge", overrides.CompKnowledge, "Planning", overrides.CompPlanning],
        ["Decision Making", overrides.CompDecision, "Initiative", overrides.CompInitiative],
        ["Teamwork", overrides.CompTeamwork, "", ""]
    ];
}

function renderOverrideTable(overrides) {
    var rows = overrideRows(overrides).filter(function (row) {
        return hasReportValue(row[1]) || hasReportValue(row[3]);
    });
    if (!rows.length) return '<div class="admin-report-empty">No score overrides were applied.</div>';
    return '<table class="admin-report-table admin-report-score-table"><thead><tr>' +
        '<th>Override Area</th><th>Score</th><th>Override Area</th><th>Score</th></tr></thead><tbody>' +
        rows.map(function (row) {
            return '<tr><td>' + escapeHtml(row[0]) + '</td><td>' + adminValue(row[1]) + '</td>' +
                '<td>' + escapeHtml(row[2]) + '</td><td>' + adminValue(row[3]) + '</td></tr>';
        }).join("") + '</tbody></table>';
}

function parseTrainingRecords(value) {
    var parsed = parseJsonValue(value);
    if (!parsed && Array.isArray(value)) parsed = value;
    if (!Array.isArray(parsed)) return [];
    return parsed.filter(function (item) { return item && typeof item === "object"; });
}

function renderTrainingTable(records) {
    if (!records.length) return '<div class="admin-report-empty">No training records available.</div>';
    return '<table class="admin-report-table admin-report-training-table"><thead><tr>' +
        '<th style="width:45px;">#</th><th>Date From</th><th>Date To</th><th>Institute</th><th>Subject</th></tr></thead><tbody>' +
        records.map(function (item, index) {
            return '<tr><td>' + (index + 1) + '</td><td>' + adminValue(formatAdminDate(item.DateFrom || item.dateFrom)) +
                '</td><td>' + adminValue(formatAdminDate(item.DateTo || item.dateTo)) + '</td><td>' +
                adminValue(item.Institute || item.institute) + '</td><td>' + adminValue(item.Subject || item.subject) + '</td></tr>';
        }).join("") + '</tbody></table>';
}

function renderDocuments(docs, forPrint) {
    docs = docs || [];
    if (!docs.length) return '<div class="admin-report-empty">No supporting documents uploaded.</div>';
    return '<table class="admin-report-table"><thead><tr>' +
        '<th style="width:45px;">#</th><th>Document Name</th><th>Document Type</th><th>Uploaded By</th><th>Uploaded On</th>' +
        (forPrint ? '' : '<th style="width:90px;">Action</th>') + '</tr></thead><tbody>' +
        docs.map(function (doc, index) {
            var name = doc.FileName || doc.DocumentType || "Document";
            var uploadedBy = doc.UploadedBy || doc.UploadedByName || doc.Section || "";
            var action = '';
            if (!forPrint) {
                action = '<td>' + (doc.FileUrl ? '<a class="btn btn-outline-primary btn-sm" href="' + escapeHtml(doc.FileUrl) + '" target="_blank">View</a>' : '<span class="admin-report-na">NA</span>') + '</td>';
            }
            return '<tr><td>' + (index + 1) + '</td><td>' + adminValue(name) + '</td><td>' + adminValue(doc.DocumentType) +
                '</td><td>' + adminValue(uploadedBy) + '</td><td>' + adminValue(formatAdminDateTime(doc.UploadedAt)) + '</td>' + action + '</tr>';
        }).join("") + '</tbody></table>';
}

function buildReportSections(data, forPrint) {
    data = data || {};
    var officer = data.OfficerName || (data.Officer && data.Officer.DisplayName);
    var officerLogin = data.OfficerLoginId || (data.Officer && data.Officer.LoginId);
    var self = data.SelfAppraisal || {};
    var reviewing = data.ReviewingAssessment || {};
    var overrides = data.RvaOverrideGrades || {};
    var decision = data.Decision || {};
    var docs = (data.Documents || []).concat(data.RoleDocuments || []);
    var officerText = officer ? officer + (officerLogin ? " (" + officerLogin + ")" : "") : "";
    var ra2Assigned = hasReportValue(data.ReportingAuthority2UserId) || hasReportValue(data.ReportingAuthority2Name) || hasReportValue(data.ReportingAuthority2LoginId);
    var sections = [];

    sections.push({
        id: "acr-overview",
        title: "ACR Overview",
        html: renderSection("acr-overview", "ACR Overview",
            renderOverviewGroups([
            { title: "Officer", fields: [
                ["Officer name", officer],
                ["Employee / user code", officerLogin],
                ["Designation", data.Dsg],
                ["Department", data.Department],
                ["Posting location", data.Location]
            ] },
            { title: "Appraisal", fields: [
                ["ACR year", data.AcrYear],
                ["Form type", data.FormType],
                ["Posting from", formatAdminDate(data.PostingFrom)],
                ["Posting to", formatAdminDate(data.PostingTo)],
                ["Created date", formatAdminDateTime(data.CreatedAt)],
                ["Last updated date", formatAdminDateTime(data.UpdatedAt)]
            ] },
            { title: "Final status", fields: [
                ["Workflow status", renderStatusBadge(data.Status), true],
                ["Current authority / stage", getCurrentAuthorityStage(data)],
                ["Final grade", decision.FinalGrade],
                ["Decision date", formatAdminDateTime(decision.DecidedAt)]
            ] }
            ], forPrint))
    });

    sections.push({ id: "workflow-progress", title: "Workflow Progress", html: renderSection("workflow-progress", "Workflow Progress", renderWorkflow(data)) });
    sections.push({ id: "officer-profile", title: "Officer Profile", html: renderSection("officer-profile", "Officer Profile", renderFacts([
        ["Date of birth", formatAdminDate(data.DateOfBirth)],
        ["Academic qualification", data.AcademicQualification],
        ["Technical qualification", data.TechnicalQualification],
        ["Departmental exam passed", data.DepartmentalExamPassed],
        ["Property return information", formatAdminDate(data.PropertyReturnDate)],
        ["Medical examination information", formatAdminDate(data.LastMedicalExamDate)],
        ["Career / posting summary", data.CareerPostingSummary]
    ])) });
    sections.push({ id: "posting-service", title: "Posting and Service Details", html: renderSection("posting-service", "Posting and Service Details", renderFacts([
        ["Joining Nigam", formatAdminDate(data.DateJoiningNigam)],
        ["Joining present rank", formatAdminDate(data.DateJoiningPresentRank)],
        ["Joining present station", formatAdminDate(data.DateJoiningPresentStation)],
        ["Posting from", formatAdminDate(data.PostingFrom)],
        ["Posting to", formatAdminDate(data.PostingTo)],
        ["Posting location", data.Location],
        ["Department", data.Department]
    ])) });
    sections.push({ id: "assigned-authorities", title: "Assigned Authorities", html: renderSection("assigned-authorities", "Assigned Authorities",
        '<table class="admin-report-table"><thead><tr><th>Role</th><th>Name</th><th>Status</th></tr></thead><tbody>' +
        [
            ["CCA / Raised By", authorityDisplay(data.CcaName, data.CcaLoginId, data.CcaUserId), hasReportValue(data.CcaUserId) || hasReportValue(data.CcaName) ? "Available" : "NA"],
            ["Reporting Authority - RA1", authorityDisplay(data.ReportingAuthorityName, data.ReportingAuthorityLoginId, data.ReportingAuthorityUserId), hasReportValue(data.ReportingAuthorityUserId) ? "Assigned" : "NA"],
            ["Reporting Authority - RA2", authorityDisplay(data.ReportingAuthority2Name, data.ReportingAuthority2LoginId, data.ReportingAuthority2UserId), ra2Assigned ? "Assigned" : "Not Applicable"],
            ["Reviewing Authority", authorityDisplay(data.ReviewingAuthorityName, data.ReviewingAuthorityLoginId, data.ReviewingAuthorityUserId), hasReportValue(data.ReviewingAuthorityUserId) ? "Assigned" : "NA"],
            ["Accepting Authority", authorityDisplay(data.AcceptingAuthorityName, data.AcceptingAuthorityLoginId, data.AcceptingAuthorityUserId), hasReportValue(data.AcceptingAuthorityUserId) ? "Assigned" : "NA"]
        ].map(function (row) {
            return '<tr><td>' + escapeHtml(row[0]) + '</td><td>' + adminValue(row[1]) + '</td><td>' + renderStatusBadge(row[2]) + '</td></tr>';
        }).join("") + '</tbody></table>') });

    sections.push({ id: "self-appraisal", title: "Employee / Officer Self-Appraisal", html: renderSection("self-appraisal", "Employee / Officer Self-Appraisal",
        renderSubsection("Submission information", renderFacts([
            ["Filled by", officerText],
            ["Exists", self.Exists],
            ["Skipped", self.IsSkipped],
            ["Submitted", self.IsSubmitted],
            ["Submitted at", formatAdminDateTime(self.SubmittedAt)]
        ])) +
        renderSubsection("Work and performance", renderFacts([
            ["Duties description", self.DutiesDescription],
            ["Targets set", self.TargetsSet],
            ["Targets achieved", self.TargetsAchieved],
            ["Shortfall reasons", self.ShortfallReasons]
        ])) +
        renderSubsection("Additional information", renderFacts([
            ["Leave details", self.LeaveDetails],
            ["Membership bodies", self.MembershipBodies],
            ["Auditor compliance", self.AuditorCompliance],
            ["Property declaration", self.PropertyDeclared],
            ["Property declared date", formatAdminDate(self.PropertyDeclaredDate)],
            ["Medical compliance", self.MedicalCompliance],
            ["Medical compliance date", formatAdminDate(self.MedicalComplianceDate)]
        ]))) });

    sections.push({ id: "training-achievements", title: "Training and Achievements", html: renderSection("training-achievements", "Training and Achievements",
        renderSubsection("Training records", renderTrainingTable(parseTrainingRecords(self.TrainingDetails))) +
        renderSubsection("Achievements and honours", renderFacts([
            ["Major achievements", self.MajorAchievements],
            ["Awards / honours", self.AwardsHonours]
        ]))) });

    sections.push({ id: "ra1", title: "Reporting Authority - RA1", html: renderAssessmentSection("ra1", "Reporting Authority - RA1", authorityDisplay(data.ReportingAuthorityName, data.ReportingAuthorityLoginId, data.ReportingAuthorityUserId), data.Ra1Assessment, { pending: hasReportValue(data.ReportingAuthorityUserId) }) });
    sections.push({ id: "ra2", title: "Reporting Authority - RA2", html: renderAssessmentSection("ra2", "Reporting Authority - RA2", authorityDisplay(data.ReportingAuthority2Name, data.ReportingAuthority2LoginId, data.ReportingAuthority2UserId), data.Ra2Assessment, { notApplicable: !ra2Assigned, pending: ra2Assigned, reason: "No second reporting authority is assigned for this ACR/form type." }) });

    sections.push({ id: "reviewing-authority", title: "Reviewing Authority", html: renderSection("reviewing-authority", "Reviewing Authority",
        renderSubsection("Review information", renderFacts([
            ["Filled by", authorityDisplay(data.ReviewingAuthorityName, data.ReviewingAuthorityLoginId, data.ReviewingAuthorityUserId)],
            ["Exists", reviewing.Exists],
            ["Skipped", reviewing.IsSkipped],
            ["Submitted", reviewing.IsSubmitted],
            ["Submitted at", formatAdminDateTime(reviewing.SubmittedAt)],
            ["Agreement with reporting authority", reviewing.AgreeWithRa],
            ["Disagreement details", reviewing.DisagreeDetails],
            ["Comments", reviewing.Comments],
            ["Overall grade", reviewing.OverallGrade]
        ])) +
        renderSubsection("Score overrides", renderOverrideTable(overrides))) });

    sections.push({ id: "uploaded-documents", title: "Uploaded Documents", html: renderSection("uploaded-documents", "Uploaded Documents", renderDocuments(docs, forPrint)) });

    var decisionStatus = getFinalDecisionStatus(decision, data.Status);
    sections.push({ id: "final-decision", title: "Final Decision", html: renderSection("final-decision", "Final Decision",
        '<div class="admin-report-final-panel">' +
            renderFact("Decision status", renderStatusBadge(decisionStatus), true) +
            renderFact("Final grade", decision.FinalGrade) +
            renderFact("Accepting authority", authorityDisplay(data.AcceptingAuthorityName, data.AcceptingAuthorityLoginId, data.AcceptingAuthorityUserId)) +
            renderFact("Decision date", formatAdminDateTime(decision.DecidedAt)) +
            '<div class="admin-report-final-remarks">' + renderFact("Final remarks", decision.FinalRemarks) + '</div>' +
        '</div>' +
        renderSubsection("Decision trail", renderFacts([
            ["RA1 decision and grade", data.Ra1Assessment && data.Ra1Assessment.IsSubmitted ? "Submitted, Grade: " + adminValue(data.Ra1Assessment.OverallGrade).replace(/<[^>]*>/g, "") : ""],
            ["RA1 remarks", data.Ra1Assessment && data.Ra1Assessment.Remarks],
            ["RA2 decision and grade", data.Ra2Assessment && data.Ra2Assessment.IsSubmitted ? "Submitted, Grade: " + adminValue(data.Ra2Assessment.OverallGrade).replace(/<[^>]*>/g, "") : (ra2Assigned ? "" : "Not Applicable")],
            ["RA2 remarks", data.Ra2Assessment && data.Ra2Assessment.Remarks],
            ["Reviewing decision and grade", reviewing.IsSubmitted ? "Submitted, Grade: " + adminValue(reviewing.OverallGrade).replace(/<[^>]*>/g, "") : ""],
            ["Reviewing comments", reviewing.Comments],
            ["Accepting decision exists", decision.Exists],
            ["Accepted / approved", decision.IsApproved],
            ["Rejection / disagreement reason", decision.IsApproved === false ? (decision.DisagreeDetails || decision.FinalRemarks) : decision.DisagreeDetails],
            ["Agreement with previous authorities", decision.AgreeWithPrevious],
            ["Conflict resolved", decision.ConflictResolved]
        ]))) });

    return sections;
}

function buildAdminReportHeader(data) {
    data = data || {};
    var officer = data.OfficerName || (data.Officer && data.Officer.DisplayName);
    var decision = data.Decision || {};
    var period = (formatAdminDate(data.PostingFrom) || "NA") + " to " + (formatAdminDate(data.PostingTo) || "NA");
    return '<div class="admin-report-header" id="report-header">' +
        '<div class="admin-report-header-top"><div>' +
            '<h4 class="admin-report-title">Annual Confidential Report (ACR)</h4>' +
            '<p class="admin-report-subtitle">Complete Lifecycle Report</p>' +
            '<p class="admin-report-note">Complete appraisal lifecycle showing submissions, reviews and final decision.</p>' +
            '<div class="admin-report-ref"><strong>Report Reference:</strong> ' + adminValue(data.AcrId) + '</div>' +
        '</div><div>' + renderStatusBadge(getFinalDecisionStatus(decision, data.Status)) + '</div></div>' +
        '<div class="admin-report-header-meta">' +
            renderFact("ACR year", data.AcrYear) +
            renderFact("Form type", data.FormType) +
            renderFact("Officer name", officer) +
            renderFact("Officer designation", data.Dsg) +
            renderFact("Posting period", period) +
            renderFact("Final grade", decision.FinalGrade) +
        '</div></div>';
}

function buildAdminReportHtml(data, forPrint) {
    var sections = buildReportSections(data, !!forPrint);
    var nav = forPrint ? '' : '<nav class="admin-report-nav"><p class="admin-report-nav-title">Sections</p>' +
        '<a href="#report-header">Report Header</a>' +
        sections.map(function (section) { return '<a href="#' + escapeHtml(section.id) + '">' + escapeHtml(section.title) + '</a>'; }).join("") +
        '</nav>';
    return '<div class="admin-report-shell">' + nav + '<div class="admin-report-content">' +
        buildAdminReportHeader(data) + sections.map(function (section) { return section.html; }).join("") +
        '</div></div>';
}

function openAdminAcrReport(acrId) {
    selectedAdminAcrDetail = null;
    $("#adminAcrPdfBtn").prop("disabled", true);
    $("#adminAcrPdfBtnText").text("Download PDF");
    $("#adminAcrReportBody").html('<div class="admin-report-loading">Loading report...</div>');
    $("#adminAcrReportModal").modal("show");
    $("body").addClass("admin-acr-modal-open");
    loadAdminAcrReportFromUrl(BASE_URL + "api/admin/acr/" + acrId, acrId, true);
}

function loadAdminAcrReportFromUrl(url, acrId, allowFallback) {
    $.ajax({
        url: url,
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                $("#adminAcrPdfBtn").prop("disabled", true);
                $("#adminAcrReportBody").html('<div class="admin-report-error">' + escapeHtml(res.Message || "Failed to load ACR report") + '</div>');
                return;
            }
            selectedAdminAcrDetail = res.Data || {};
            $("#adminAcrReportBody").html(buildAdminReportHtml(selectedAdminAcrDetail, false));
            $("#adminAcrPdfBtn").prop("disabled", false);
        },
        error: function (xhr) {
            if (allowFallback) {
                loadAdminAcrReportFromUrl(BASE_URL + "api/cca/acr/" + acrId, acrId, false);
                return;
            }
            $("#adminAcrPdfBtn").prop("disabled", true);
            $("#adminAcrReportBody").html('<div class="admin-report-error">' + escapeHtml(apiErrorMessage(xhr, "Failed to load ACR report")) + '</div>');
        }
    });
}

function getAdminReportPrintCss() {
    return [
        '@page{size:A4 portrait;margin:18mm 14mm 18mm;}',
        '@page{@top-center{content:"Annual Confidential Report";font-size:9pt;color:#173b63;}@bottom-left{content:"ACR Ref: " attr(data-acr-ref);font-size:8pt;color:#64748b;}@bottom-right{content:"Page " counter(page) " of " counter(pages);font-size:8pt;color:#64748b;}}',
        '*{box-sizing:border-box;}',
        'html,body{font-family:Arial,sans-serif;color:#172033;background:#fff;margin:0;font-size:10.5pt;line-height:1.42;}',
        'body{padding:0;}',
        '.admin-report-print-page{padding:11mm 0 8mm;}',
        '.admin-print-running-header,.admin-print-running-footer{position:fixed;left:0;right:0;display:flex;justify-content:space-between;gap:10px;color:#64748b;font-size:8pt;background:#fff;}',
        '.admin-print-running-header{top:0;border-bottom:1px solid #d9e3ef;padding-bottom:3px;}',
        '.admin-print-running-footer{bottom:0;border-top:1px solid #d9e3ef;padding-top:3px;}',
        '.admin-print-page-number:after{content:"Page " counter(page) " of " counter(pages);}',
        '.admin-report-shell{display:block;}',
        '.admin-report-nav{display:none;}',
        '.admin-report-header{border:1px solid #cfdced;border-left:5px solid #173b63;border-radius:0;padding:12px 14px;margin:0 0 10px;background:#f8fbff;box-shadow:none;break-inside:avoid;page-break-inside:avoid;}',
        '.admin-report-header-top{display:flex;justify-content:space-between;gap:12px;align-items:flex-start;}',
        '.admin-report-title{margin:0;color:#173b63;font-size:18pt;font-weight:800;line-height:1.15;}',
        '.admin-report-subtitle{margin:3px 0 0;color:#172033;font-size:11pt;font-weight:700;}',
        '.admin-report-note{margin:5px 0 0;color:#64748b;font-size:9pt;}',
        '.admin-report-ref{margin-top:6px;color:#64748b;font-size:8.5pt;overflow-wrap:anywhere;}',
        '.admin-report-header-meta{display:grid;grid-template-columns:repeat(3,1fr);gap:6px;margin-top:10px;}',
        '.admin-report-kpi,.admin-report-fact{min-width:0;}',
        '.admin-report-section{border:1px solid #cfdced;border-radius:0;background:#fff;margin:0 0 9px;overflow:visible;box-shadow:none;}',
        '.admin-report-section-title{margin:0;padding:7px 9px;border-bottom:1px solid #cfdced;background:#173b63;color:#fff;font-size:9pt;font-weight:800;letter-spacing:.04em;text-transform:uppercase;break-after:avoid;page-break-after:avoid;}',
        '.admin-report-section-body{padding:9px;}',
        '.admin-report-summary-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:7px;}',
        '.admin-report-summary-card{border:1px solid #d9e3ef;border-radius:0;background:#fff;break-inside:avoid;page-break-inside:avoid;}',
        '.admin-report-summary-card h6,.admin-report-subsection-title{margin:0 0 7px;color:#173b63;font-size:9pt;font-weight:800;}',
        '.admin-report-summary-card h6{padding:7px 8px 0;}',
        '.admin-report-summary-card .admin-report-facts{display:grid;grid-template-columns:1fr;gap:5px;padding:0 8px 8px;}',
        '.admin-report-facts{display:grid;grid-template-columns:repeat(2,1fr);gap:7px 14px;}',
        '.admin-report-label{display:block;margin-bottom:2px;color:#64748b;font-size:8pt;font-weight:800;letter-spacing:.03em;text-transform:uppercase;}',
        '.admin-report-value{white-space:pre-wrap;overflow-wrap:anywhere;font-size:9.5pt;line-height:1.38;color:#172033;}',
        '.admin-report-na{color:#8c98a8;font-style:italic;}',
        '.admin-report-badge{display:inline-block;padding:3px 7px;border-radius:99px;font-size:7.6pt;font-weight:800;border:1px solid #d9e3ef;text-transform:uppercase;}',
        '.status-approved,.status-completed{background:#dcfce7;color:#166534;border-color:#bbf7d0;}',
        '.status-progress,.status-current,.status-submitted{background:#dbeafe;color:#1d4ed8;border-color:#bfdbfe;}',
        '.status-pending{background:#fef3c7;color:#92400e;border-color:#fde68a;}',
        '.status-rejected{background:#fee2e2;color:#991b1b;border-color:#fecaca;}',
        '.status-na,.status-skipped{background:#f1f5f9;color:#64748b;border-color:#e2e8f0;}',
        '.admin-report-workflow{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;}',
        '.admin-report-step{border:1px solid #d9e3ef;border-radius:0;padding:7px;background:#fff;break-inside:avoid;}',
        '.admin-report-step-title{margin-bottom:4px;color:#173b63;font-weight:800;font-size:8.5pt;}',
        '.admin-report-table{width:100%;border-collapse:collapse;table-layout:fixed;font-size:8.8pt;}',
        '.admin-report-table thead{display:table-header-group;}',
        '.admin-report-table tr{break-inside:avoid;page-break-inside:avoid;}',
        '.admin-report-table th,.admin-report-table td{padding:5px 6px;border-bottom:1px solid #dce6f1;vertical-align:top;overflow-wrap:anywhere;}',
        '.admin-report-table th{background:#f1f6fc;color:#173b63;font-size:8pt;font-weight:800;text-transform:uppercase;}',
        '.admin-report-score-table td:nth-child(2),.admin-report-score-table td:nth-child(4){width:13%;font-weight:800;color:#173b63;}',
        '.admin-report-grade-panel,.admin-report-empty{border:1px solid #d9e3ef;border-radius:0;padding:7px 8px;background:#f8fbff;overflow-wrap:anywhere;break-inside:avoid;page-break-inside:avoid;}',
        '.admin-report-grade-panel{display:flex;justify-content:space-between;gap:10px;align-items:center;margin-top:8px;}',
        '.admin-report-grade{font-size:15pt;font-weight:900;color:#173b63;}',
        '.admin-report-subsection{margin-bottom:10px;}',
        '.admin-report-subsection:last-child{margin-bottom:0;}',
        '.admin-report-final-panel{display:grid;grid-template-columns:repeat(4,1fr);gap:7px;border:1px solid #bfdbfe;border-left:5px solid #2563eb;border-radius:0;padding:9px;background:#eff6ff;break-inside:avoid;page-break-inside:avoid;}',
        '.admin-report-final-panel .admin-report-final-remarks{grid-column:1/-1;}',
        'a{color:#172033;text-decoration:none;}',
        '@media print{.admin-report-section,.admin-report-summary-card,.admin-report-grade-panel,.admin-report-final-panel{print-color-adjust:exact;-webkit-print-color-adjust:exact;} .admin-report-section-title{break-after:avoid;page-break-after:avoid;}}'
    ].join('');
}

function printAdminAcrReport() {
    if (!selectedAdminAcrDetail) {
        alert("Report is still loading.");
        return;
    }

    $("#adminAcrPdfBtn").prop("disabled", true);
    $("#adminAcrPdfBtnText").text("Preparing PDF...");
    var reportHtml = buildAdminReportHtml(selectedAdminAcrDetail, true);
    var win = window.open("", "_blank");
    if (!win) {
        $("#adminAcrPdfBtn").prop("disabled", false);
        $("#adminAcrPdfBtnText").text("Download PDF");
        alert("Please allow pop-ups to download the PDF.");
        return;
    }

    var officer = selectedAdminAcrDetail.OfficerName || "";
    var acrYear = selectedAdminAcrDetail.AcrYear || "";
    var ref = selectedAdminAcrDetail.AcrId || "";
    var generatedAt = formatAdminDateTime(new Date().toISOString());
    win.document.open();
    win.document.write('<!doctype html><html><head><title>ACR Lifecycle Report</title>' +
        '<style>' + getAdminReportPrintCss() + '</style></head><body data-acr-ref="' + escapeHtml(ref) + '">' +
        '<div class="admin-print-running-header"><strong>Annual Confidential Report</strong><span>' + escapeHtml(officer) + ' | ACR Year ' + escapeHtml(acrYear) + '</span></div>' +
        '<div class="admin-print-running-footer"><span>ACR Ref: ' + escapeHtml(ref) + '</span><span>Generated: ' + escapeHtml(generatedAt) + '</span><span class="admin-print-page-number"></span></div>' +
        '<div class="admin-report-print-page" data-acr-ref="' + escapeHtml(ref) + '">' +
        '<div style="display:none;">Annual Confidential Report - ' + escapeHtml(officer) + ' - ' + escapeHtml(acrYear) + ' - Generated ' + escapeHtml(generatedAt) + '</div>' +
        reportHtml + '</div></body></html>');
    win.document.close();
    win.focus();
    win.onafterprint = function () {
        $("#adminAcrPdfBtn").prop("disabled", false);
        $("#adminAcrPdfBtnText").text("Download PDF");
    };
    setTimeout(function () {
        try {
            win.print();
        } catch (e) {
            alert("PDF generation failed. Please try again.");
        } finally {
            setTimeout(function () {
                $("#adminAcrPdfBtn").prop("disabled", false);
                $("#adminAcrPdfBtnText").text("Download PDF");
            }, 800);
        }
    }, 300);
}

function viewAcr(acrId) {
    if (isAdminUser()) {
        openAdminAcrReport(acrId);
        return;
    }

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
