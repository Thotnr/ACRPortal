<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style>
#ccaTable { font-size:14px; }
#ccaTable th { cursor:pointer; font-weight:600; }

.status-badge { padding:4px 10px; border-radius:15px; font-size:12px; }
.status-draft { background:#e2e3e5; color:#41464b; }
.status-pending { background:#fff3cd; color:#856404; }
.status-progress { background:#cfe2ff; color:#084298; }
.status-completed { background:#d1e7dd; color:#0f5132; }
.status-rejected { background:#f8d7da; color:#842029; }

.modal-body { max-height:80vh; overflow-y:auto; }
.modal-dialog { margin-top:30px; }

.modal-header {
    background: #0d6efd;
    color: #fff;
    border-bottom: 0;
}
.modal-header .close {
    color: #fff;
    opacity: 1;
    text-shadow: none;
}

.modal-content {
    border-radius: 10px;
    overflow: hidden;
}

.ccaFormClass h5 {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 14px;
    color: #2f3a45;
}

.form-group label {
    font-weight: 500;
    font-size: 13px;
    margin-bottom: 6px;
    color: #3b3f44;
}

.form-control,
.select2-container .select2-selection--single {
    border-radius: 6px !important;
}

.select2-container .select2-selection--single {
    height: 38px !important;
    border: 1px solid #ced4da !important;
    background: #fff !important;
}

.select2-container--default .select2-selection--single .select2-selection__rendered {
    line-height: 36px !important;
    padding-left: 10px !important;
}

.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 36px !important;
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

.ccaFormClass { padding:0 20px 20px 20px; }

.select2-container .select2-selection--single {
    height: 38px !important;
    padding: 5px 10px;
}
.select2-container--default .select2-selection--single .select2-selection__rendered {
    line-height: 28px;
}
.select2-container--default .select2-selection--single .select2-selection__arrow {
    height: 36px;
}

.upload-box {
    border: 1px dashed #ced4da;
    border-radius: 8px;
    padding: 15px;
    background: #fafafa;
}
.file-pill {
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:10px;
    padding:10px 12px;
    border:1px solid #dee2e6;
    border-radius:8px;
    background:#fff;
}
.file-name-wrap {
    min-width:0;
}
.file-name-wrap .file-name {
    font-weight:600;
    word-break:break-word;
}
.file-name-wrap .file-meta {
    font-size:12px;
    color:#6c757d;
}
.readonly-mask {
    pointer-events:none;
    opacity:.8;
}
.text-required { color:#dc3545; }
#paginationContainer .page-link {
    cursor: pointer;
}
</style>

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>CCA Officer Appraisal</h3>
        <button class="btn btn-primary" onclick="openAppraisalModal()">Raise Appraisal</button>
    </div>

    <div class="row mb-3">
        <div class="col-md-4">
            <input type="text" class="form-control" placeholder="Search officer..." onkeyup="searchTable(this.value)">
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-hover" id="ccaTable">
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
    <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
        <div class="d-flex align-items-center gap-2">
            <label class="mb-0">Rows per page:</label>
            <select id="pageSize" class="form-control form-control-sm" style="width:90px;">
                <option value="5">5</option>
                <option value="10" selected>10</option>
                <option value="20">20</option>
                <option value="50">50</option>
            </select>
        </div>

        <div id="paginationInfo" class="small text-muted"></div>

        <nav>
            <ul class="pagination pagination-sm mb-0" id="paginationContainer"></ul>
        </nav>
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

                    <h5 class="mt-3">Basic Information</h5>

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

                    <h5 class="mt-3">Authorities</h5>

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

                    <h5 class="mt-3">Other Information</h5>

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

                    <div class="form-group">
                        <label>
                            Medical Report
                            <small class="text-muted">(PDF/JPG/JPEG/PNG, max 5MB)</small>
                        </label>

                        <div id="documentSection" class="upload-box">
                            <div id="docUploadState">
                                <input type="file" class="form-control" id="medicalReport" accept=".pdf,.jpg,.jpeg,.png">
                                <small class="form-text text-muted">Upload file first, then it will be attached to CCA docs section.</small>
                            </div>

                            <div id="docUploadedState" class="d-none">
                                <div class="file-pill">
                                    <div class="file-name-wrap">
                                        <div class="file-name" id="uploadedFileName">--</div>
                                        <div class="file-meta" id="uploadedFileMeta">--</div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a href="javascript:void(0)" id="btnViewUploadedDoc" target="_blank" class="btn btn-sm btn-outline-primary">View</a>
                                        <button type="button" class="btn btn-sm btn-outline-danger" id="btnDeleteUploadedDoc" onclick="deleteCurrentDocument()">Delete</button>
                                    </div>
                                </div>
                            </div>

                            <input type="hidden" id="hdnUploadedDocumentId" />
                            <input type="hidden" id="hdnUploadedFilePath" />
                            <input type="hidden" id="hdnUploadedFileName" />
                            <div id="uploadStatus" class="mt-2 small"></div>
                        </div>
                    </div>

                    <div class="text-center mt-4">
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
var currentUploadedDocument = null;

var DOCUMENT_TYPE = "MEDICAL_REPORT";
var FINAL_STATUSES = ["APPROVED", "REJECTED"];
var EDITABLE_DOC_STATUSES = ["DRAFT", "PENDING_OFFICER", "PENDING_REPORTING", "PENDING_REVIEWING", "PENDING_ACCEPTING"];

var acrListData = [];
var filteredAcrListData = [];
var currentPage = 1;
var pageSize = 10;
var currentSortColumn = -1;
var currentSortDirection = "asc";

$(document).ready(function () {
    var token = localStorage.getItem("token");
    if (!token) {
        window.location = BASE_URL + "Login/UserAuth";
        return;
    }

    applyTodayMaxToDates();

    loadCurrentUser(token);

    loadDesignations()
        .then(function () { return loadSubDivisionsForDropdown(); })
        .then(function () { return loadEmployees(); })
        .then(function () { return loadOfficers(); })
        .then(function () { return loadAcrList(); });

    $("#pageSize").on("change", function () {
        pageSize = parseInt($(this).val(), 10) || 10;
        currentPage = 1;
        renderAcrTable();
    });

    sortTable(0);
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
            }
        },
        error: function () {
            window.location = BASE_URL + "Login/UserAuth";
        }
    });
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
            '<option value="' + d.DsgId + '" data-formtype="' + (d.FormType || '') + '">' +
            (d.Dsg || '') + ' - ' + (d.DsgDesc || '') +
            '</option>'
        );
    });
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

    $("#formTitle").text("CCA Officer Appraisal");
    $("#btnSubmit").show();
    $("#btnSaveDraft").show();

    $("#reportingAuthority2Row").remove();
    bindAuthorityDropdowns();
    resetDocumentSection();
    setFormReadonly(false);

    $('#appraisalModal').modal('show');
}

function closeModal() {
    $('#appraisalModal').modal('hide');
}

function searchTable(value) {
    value = (value || "").toLowerCase().trim();

    if (!value) {
        filteredAcrListData = acrListData.slice();
    } else {
        filteredAcrListData = acrListData.filter(function (a) {
            return (
                (a.OfficerName || '').toLowerCase().includes(value) ||
                (a.DsgDesc || '').toLowerCase().includes(value) ||
                (a.Location || '').toLowerCase().includes(value) ||
                (a.PostingFrom || '').toLowerCase().includes(value) ||
                (a.PostingTo || '').toLowerCase().includes(value) ||
                (a.Status || '').toLowerCase().includes(value)
            );
        });
    }

    currentPage = 1;
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

        valA = (valA || "").toString().toLowerCase();
        valB = (valB || "").toString().toLowerCase();

        if (valA < valB) return currentSortDirection === "asc" ? -1 : 1;
        if (valA > valB) return currentSortDirection === "asc" ? 1 : -1;
        return 0;
    });
}

function getSortValue(item, col) {
    switch (col) {
        case 0: return item.OfficerName || "";
        case 1: return item.DsgDesc || "";
        case 2: return item.Location || "";
        case 3: return item.PostingFrom || "";
        case 4: return item.PostingTo || "";
        default: return "";
    }
}

function renderAcrTable() {
    var tbody = $("#ccaTableBody");
    tbody.empty();

    if (!filteredAcrListData.length) {
        tbody.html('<tr><td colspan="7" class="text-center text-muted">No records found</td></tr>');
        $("#paginationContainer").empty();
        $("#paginationInfo").text("Showing 0 to 0 of 0 entries");
        return;
    }

    var totalRecords = filteredAcrListData.length;
    var totalPages = Math.ceil(totalRecords / pageSize);

    if (currentPage > totalPages) {
        currentPage = totalPages;
    }

    var startIndex = (currentPage - 1) * pageSize;
    var endIndex = Math.min(startIndex + pageSize, totalRecords);
    var pageData = filteredAcrListData.slice(startIndex, endIndex);

    $.each(pageData, function (i, a) {
        tbody.append(
            '<tr>' +
                '<td>' + (a.OfficerName || '--') + '</td>' +
                '<td>' + (a.DsgDesc || '--') + '</td>' +
                '<td>' + (a.Location || '--') + '</td>' +
                '<td>' + (a.PostingFrom || '--') + '</td>' +
                '<td>' + (a.PostingTo || '--') + '</td>' +
                '<td>' + getStatusBadge(a.Status) + '</td>' +
                '<td><button class="btn btn-sm btn-info" onclick="viewAcr(\'' + a.AcrId + '\')">View</button></td>' +
            '</tr>'
        );
    });

    $("#paginationInfo").text(
        "Showing " + (startIndex + 1) + " to " + endIndex + " of " + totalRecords + " entries"
    );

    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    var container = $("#paginationContainer");
    container.empty();

    if (totalPages <= 1) return;

    var prevDisabled = currentPage === 1 ? "disabled" : "";
    container.append(
        '<li class="page-item ' + prevDisabled + '">' +
            '<a class="page-link" href="javascript:void(0)" onclick="goToPage(' + (currentPage - 1) + ')">Previous</a>' +
        '</li>'
    );

    var startPage = Math.max(1, currentPage - 2);
    var endPage = Math.min(totalPages, currentPage + 2);

    if (startPage > 1) {
        container.append('<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="goToPage(1)">1</a></li>');
        if (startPage > 2) {
            container.append('<li class="page-item disabled"><span class="page-link">...</span></li>');
        }
    }

    for (var i = startPage; i <= endPage; i++) {
        var active = currentPage === i ? "active" : "";
        container.append(
            '<li class="page-item ' + active + '">' +
                '<a class="page-link" href="javascript:void(0)" onclick="goToPage(' + i + ')">' + i + '</a>' +
            '</li>'
        );
    }

    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            container.append('<li class="page-item disabled"><span class="page-link">...</span></li>');
        }
        container.append(
            '<li class="page-item">' +
                '<a class="page-link" href="javascript:void(0)" onclick="goToPage(' + totalPages + ')">' + totalPages + '</a>' +
            '</li>'
        );
    }

    var nextDisabled = currentPage === totalPages ? "disabled" : "";
    container.append(
        '<li class="page-item ' + nextDisabled + '">' +
            '<a class="page-link" href="javascript:void(0)" onclick="goToPage(' + (currentPage + 1) + ')">Next</a>' +
        '</li>'
    );
}

function goToPage(page) {
    var totalPages = Math.ceil(filteredAcrListData.length / pageSize);
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    renderAcrTable();
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

function validateFile(file) {
    if (!file) return { valid: true };

    var allowedTypes = ["application/pdf", "image/png", "image/jpeg"];
    if (allowedTypes.indexOf(file.type) === -1) {
        return { valid: false, message: "Only PDF, PNG, JPG, JPEG allowed." };
    }

    if (file.size > 5 * 1024 * 1024) {
        return { valid: false, message: "Max file size is 5MB." };
    }

    return { valid: true };
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

    var file = $("#medicalReport")[0].files[0] || null;
    var fileValidation = validateFile(file);
    if (!fileValidation.valid) {
        alert(fileValidation.message);
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

    submitAppraisal(payload, file);
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
    $("#btnSaveDraft, #btnSubmit, #btnDeleteUploadedDoc").prop("disabled", disabled);
}

function unlockSubmission() {
    isSubmitting = false;
    toggleActionButtons(false);
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
    $("#ccaForm :input").prop("disabled", flag);
    $("#btnSaveDraft, #btnSubmit").prop("disabled", flag);
    applyDocumentReadonly(flag);
}

function submitAppraisal(payload, file) {
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
                    alert("Draft saved successfully");
                    closeModal();
                    loadAcrList();
                    unlockSubmission();
                    return;
                }

                if (file) {
                    uploadFileToStorageAndAttach(currentAcrId, file, function () {
                        submitDraftAcr(currentAcrId);
                    });
                } else {
                    submitDraftAcr(currentAcrId);
                }
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
                alert("Draft saved successfully");
                closeModal();
                loadAcrList();
                unlockSubmission();
                return;
            }

            if (file) {
                uploadFileToStorageAndAttach(acrId, file, function () {
                    submitDraftAcr(acrId);
                });
            } else {
                submitDraftAcr(acrId);
            }
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

function uploadFileToStorageAndAttach(acrId, file, onSuccess) {
    $('#uploadStatus').html('<span class="text-muted">Uploading file...</span>');

    var formData = new FormData();
    formData.append("file", file);

    $.ajax({
        url: BASE_URL + "Web/Shared/FileUploadHandler",
        method: "POST",
        data: formData,
        processData: false,
        contentType: false,
        success: function (uploadRes) {
            if (!uploadRes || !uploadRes.success) {
                alert((uploadRes && uploadRes.message) || "File upload failed.");
                $('#uploadStatus').html('<span class="text-danger">File upload failed.</span>');
                unlockSubmission();
                return;
            }

            $('#hdnUploadedFilePath').val(uploadRes.filePath || '');
            $('#hdnUploadedFileName').val(uploadRes.fileName || '');

            attachDocumentToAcr(acrId, {
                FileUrl: uploadRes.filePath,
                FileName: uploadRes.fileName,
                DocumentType: DOCUMENT_TYPE
            }, onSuccess);
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "File upload failed"));
            $('#uploadStatus').html('<span class="text-danger">File upload failed.</span>');
            unlockSubmission();
        }
    });
}

function attachDocumentToAcr(acrId, docPayload, onSuccess) {
    $.ajax({
        url: BASE_URL + "api/cca/acr/" + acrId + "/docs",
        method: "POST",
        headers: {
            "Authorization": "Bearer " + getToken(),
            "Content-Type": "application/json"
        },
        data: JSON.stringify(docPayload),
        success: function (res) {
            if (!res.Success) {
                alert(res.Message || "Document attach failed");
                $('#uploadStatus').html('<span class="text-danger">' + (res.Message || 'Document attach failed') + '</span>');
                unlockSubmission();
                return;
            }

            $('#uploadStatus').html('<span class="text-success">Document uploaded successfully</span>');
            if (typeof onSuccess === "function") onSuccess();
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Document attach failed"));
            $('#uploadStatus').html('<span class="text-danger">Document attach failed</span>');
            unlockSubmission();
        }
    });
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

    if (officerUserId) {
        suggestAuthorityChain(officerUserId);
    }
});

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
        url: BASE_URL + "api/cca/acr",
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                $("#ccaTableBody").html('<tr><td colspan="7" class="text-center text-danger">' + (res.Message || 'Failed to load records') + '</td></tr>');
                $("#paginationContainer").empty();
                $("#paginationInfo").text("");
                return;
            }

            acrListData = (res.Data && res.Data.AcrCycles) ? res.Data.AcrCycles : [];
            filteredAcrListData = acrListData.slice();

            currentPage = 1;
            applySorting();
            renderAcrTable();
        },
        error: function () {
            $("#ccaTableBody").html('<tr><td colspan="7" class="text-center text-danger">Failed to load records</td></tr>');
            $("#paginationContainer").empty();
            $("#paginationInfo").text("");
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
    $("#designation").val(data.DsgId || "").trigger("change");
    setSelect2ByText("#placePosting", data.Location || "");

    setTimeout(function () {
        $("#reportingAuthority").val(data.ReportingAuthorityUserId || "").trigger("change");

        if ($("#reportingAuthority2").length) {
            $("#reportingAuthority2").val(data.ReportingAuthority2UserId || "").trigger("change");
        }

        $("#reviewAuthority").val(data.ReviewingAuthorityUserId || "").trigger("change");
        $("#acceptingAuthority").val(data.AcceptingAuthorityUserId || "").trigger("change");
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
            bindAcrDetail(data);

            var statusUpper = (data.Status || "").toUpperCase();
            var canEditForm = statusUpper === "DRAFT";
            var canSubmitDraft = statusUpper === "DRAFT";

            $("#btnSubmit").toggle(canSubmitDraft);
            $("#btnSaveDraft").toggle(canEditForm);
            setFormReadonly(!canEditForm);

            loadDocuments();

            if (data.Documents && data.Documents.length) {
                var medicalDoc = (data.Documents || []).find(function (d) {
                    return (d.DocumentType || "").toUpperCase() === DOCUMENT_TYPE;
                });

                if (medicalDoc) {
                    currentUploadedDocument = medicalDoc;
                    showUploadedState(medicalDoc);
                }
            }

            // if (!FINAL_STATUSES.includes(statusUpper)) {
            //     applyDocumentReadonly(false);
            // } else {
            //     applyDocumentReadonly(true);
            // }
            var canEditDocs = statusUpper === "DRAFT";
            applyDocumentReadonly(!canEditDocs);
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Failed to load ACR detail"));
        }
    });
}

/* ---------------- DOCUMENT SECTION ---------------- */

function resetDocumentSection() {
    currentUploadedDocument = null;
    $("#medicalReport").val("");
    $("#hdnUploadedDocumentId").val("");
    $("#hdnUploadedFilePath").val("");
    $("#hdnUploadedFileName").val("");
    $("#uploadStatus").html("");
    showUploadState();
}

function showUploadState() {
    $("#docUploadState").removeClass("d-none");
    $("#docUploadedState").addClass("d-none");
    $("#uploadedFileName").text("--");
    $("#uploadedFileMeta").text("");
    $("#btnViewUploadedDoc").attr("href", "javascript:void(0)");
}

function formatDisplayDateTime(dateStr) {
    if (!dateStr) return "";
    var d = new Date(dateStr);
    if (isNaN(d)) return dateStr;
    return d.toLocaleString();
}

function showUploadedState(doc) {
    currentUploadedDocument = doc || null;

    $("#docUploadState").addClass("d-none");
    $("#docUploadedState").removeClass("d-none");

    $("#uploadedFileName").text(doc.FileName || "--");
    $("#uploadedFileMeta").text((doc.DocumentType || DOCUMENT_TYPE) + (doc.UploadedAt ? " | " + formatDisplayDateTime(doc.UploadedAt) : ""));
    $("#btnViewUploadedDoc").attr("href", doc.FileUrl || "javascript:void(0)");

    $("#hdnUploadedDocumentId").val(doc.DocumentId || "");
    $("#hdnUploadedFilePath").val(doc.FileUrl || "");
    $("#hdnUploadedFileName").val(doc.FileName || "");
}

function applyDocumentReadonly(flag) {
    var statusUpper = "";
    if (!flag && currentAcrId) {
        // allowed
    }

    $("#medicalReport").prop("disabled", flag);
    $("#btnDeleteUploadedDoc").prop("disabled", flag);

    if (flag) {
        $("#documentSection").addClass("readonly-mask");
    } else {
        $("#documentSection").removeClass("readonly-mask");
    }
}

$("#medicalReport").off("change").on("change", function () {
    var file = this.files && this.files[0] ? this.files[0] : null;
    if (!file) return;

    if (!currentAcrId) {
        alert("Please save draft or create the ACR first before uploading document.");
        $(this).val("");
        return;
    }

    var currentStatus = ($("#btnDeleteUploadedDoc").prop("disabled") === true);
    if (currentStatus) {
        alert("Document changes are not allowed in current state.");
        $(this).val("");
        return;
    }

    var fileValidation = validateFile(file);
    if (!fileValidation.valid) {
        alert(fileValidation.message);
        $(this).val("");
        return;
    }

    uploadFileToStorageAndAttach(currentAcrId, file, function () {
        $("#medicalReport").val("");
        loadDocuments();
        unlockSubmission();
    });
});

function loadDocuments() {
    if (!currentAcrId) {
        resetDocumentSection();
        return;
    }

    $.ajax({
        url: BASE_URL + "api/cca/acr/" + currentAcrId + "/docs",
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                showUploadState();
                return;
            }

            var docs = (res.Data && res.Data.Documents) ? res.Data.Documents : [];
            var medicalDoc = docs.find(function (d) {
                return (d.DocumentType || "").toUpperCase() === DOCUMENT_TYPE;
            }) || null;

            if (medicalDoc) {
                showUploadedState(medicalDoc);
            } else {
                currentUploadedDocument = null;
                showUploadState();
            }
        },
        error: function () {
            showUploadState();
        }
    });
}

function deleteCurrentDocument() {
    if (!currentAcrId || !currentUploadedDocument || !currentUploadedDocument.DocumentId) {
        alert("No document found to delete.");
        return;
    }

    if (!confirm("Are you sure you want to delete this document?")) return;

    $("#btnDeleteUploadedDoc").prop("disabled", true);

    $.ajax({
        url: BASE_URL + "api/cca/acr/" + currentAcrId + "/docs/" + currentUploadedDocument.DocumentId,
        method: "DELETE",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            if (!res.Success) {
                alert(res.Message || "Delete failed");
                $("#btnDeleteUploadedDoc").prop("disabled", false);
                return;
            }

            $("#uploadStatus").html('<span class="text-success">Document deleted successfully</span>');
            currentUploadedDocument = null;
            $("#hdnUploadedDocumentId").val("");
            $("#hdnUploadedFilePath").val("");
            $("#hdnUploadedFileName").val("");
            $("#medicalReport").val("");
            showUploadState();
            $("#btnDeleteUploadedDoc").prop("disabled", false);
        },
        error: function (xhr) {
            alert(apiErrorMessage(xhr, "Delete failed"));
            $("#btnDeleteUploadedDoc").prop("disabled", false);
        }
    });
}

function suggestAuthorityChain(officerUserId) {
    if (!officerUserId) return;

    $("#uploadStatus").html('<span class="text-muted">Fetching authority suggestions...</span>');

    $.ajax({
        url: BASE_URL + "api/cca/officers/" + officerUserId + "/authorities/suggestions",
        method: "GET",
        headers: { "Authorization": "Bearer " + getToken() },
        success: function (res) {
            $("#uploadStatus").html("");

            if (!res || !res.Success || !res.Data) {
                if (res && res.Message) {
                    $("#uploadStatus").html('<span class="text-warning">' + res.Message + '</span>');
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
            $("#uploadStatus").html('<span class="text-warning">' + msg + '</span>');
        }
    });
}
</script>
</asp:Content>