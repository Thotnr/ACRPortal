<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" MasterPageFile="~/Views/Shared/Site.Master" %>

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

    #acceptingTable th {
        white-space: nowrap;
        user-select: none;
        cursor: pointer;
    }

    #acceptingTable td {
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

    #pagination .page-link {
        cursor: pointer;
    }
</style>
<div class="container-fluid px-0" id="acceptingDiv" style="display:none;">
    <h2 class="mb-4 page-title">Accepting Authority Dashboard</h2>

    <div class="card shadow-sm border-0 page-block">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h5 class="mb-0 text-primary">
                    <i class="bi bi-table"></i> Accepting Queue
                </h5>
                <div class="d-flex gap-2 flex-wrap">
                    <input type="text" id="searchBox" class="form-control" placeholder="Search ACR..." style="width:260px;">
                    <select id="pageSize" class="form-select" style="width:110px;">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0" id="acceptingTable">
                    <thead class="table-primary">
                        <tr>
                            <th onclick="sortTable('OfficerName')">Officer</th>
                            <th onclick="sortTable('Location')">Location</th>
                            <th onclick="sortTable('PostingFrom')">From</th>
                            <th onclick="sortTable('PostingTo')">To</th>
                            <th onclick="sortTable('AcrYear')">Year</th>
                            <th onclick="sortTable('Status')">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="acrTableBody"></tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
                <div id="tableInfo" class="small text-muted"></div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="pagination"></ul>
                </nav>
            </div>
        </div>
    </div>
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
                        <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab"
                                data-bs-target="#infoTab">ACR Info</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab"
                                data-bs-target="#reportingTab">Reporting</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab"
                                data-bs-target="#reviewingTab">Reviewing</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab"
                                data-bs-target="#acceptingTab">Accepting</button></li>
                    </ul>

                    <div class="tab-content mt-3">

                        <!-- INFO -->
                        <div class="tab-pane fade show active" id="infoTab">
                            <div class="section-card">

                                <div class="row g-3">
                                    <div class="col-md-6"><label class="form-label fw-bold">Officer</label><input
                                            id="infoOfficer" class="form-control" readonly></div>
                                    <div class="col-md-6"><label class="form-label fw-bold">Year</label><input
                                            id="infoYear" class="form-control" readonly></div>
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
                                    <div class="col-md-6"><label class="form-label fw-bold">Status</label><input
                                            id="infoStatus" class="form-control" readonly></div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Date Of Birth</label>
                                        <input id="infoDOB" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Date Joining Nigam</label>
                                        <input id="infoJoinNigam" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Joining Present Rank</label>
                                        <input id="infoJoinRank" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Joining Present Station</label>
                                        <input id="infoJoinStation" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Academic Qualification</label>
                                        <input id="infoAcademic" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Technical Qualification</label>
                                        <input id="infoTechnical" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Departmental Exam Passed</label>
                                        <input id="infoDeptExam" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Property Return Date</label>
                                        <input id="infoPropertyReturn" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Last Medical Exam</label>
                                        <input id="infoMedicalExam" class="form-control" readonly>
                                    </div>
    
                                    <div class="col-md-12">
                                        <label class="form-label fw-bold">Career Posting Summary</label>
                                        <textarea id="infoCareerSummary" class="form-control" rows="2"
                                            readonly></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- REPORTING -->
                        <div class="tab-pane fade" id="reportingTab">
                            <div class="rating-card">
                                <h5>RA1 Assessment</h5>
                                <div class="row g-3 mb-3">
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
                                <div>
                                    <label class="form-label fw-bold">Remarks</label>
                                    <textarea id="ra1Remarks" class="form-control" rows="3" readonly></textarea>
                                </div>
                            </div>

                            <div id="ra2Section" style="display:none;" class="mt-3">
                                <div class="rating-card">
                                    <h5>Second Reporting Officer (RA2)</h5>
                                    <div class="row g-3 mb-3">
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
                                    <div>
                                        <label class="form-label fw-bold">Remarks</label>
                                        <textarea id="ra2Remarks" class="form-control" rows="3" readonly></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- REVIEWING -->
                        <div class="tab-pane fade" id="reviewingTab">
                            <div class="rating-card">
                                <h5>Reviewing Assessment</h5>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Agree with RA</label>
                                        <input id="reviewAgree" class="form-control" readonly>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Overall Grade</label>
                                        <input id="reviewGrade" class="form-control" readonly>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Disagree Details</label>
                                    <textarea id="reviewDisagree" class="form-control" rows="3" readonly></textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Comments</label>
                                    <textarea id="reviewComments" class="form-control" rows="3" readonly></textarea>
                                </div>

                                <div class="alert alert-info mb-0">
                                    <strong>Submitted:</strong> <span id="reviewSubmittedAt">-</span>
                                </div>
                            </div>
                        </div>

                        <!-- ACCEPTING -->
                        <div class="tab-pane fade" id="acceptingTab">
                            <div class="section-card">
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
    </div>

    <script>

        let dataList = [], filtered = [], pageSize = 10, currentPage = 1;
        let currentAcrId = null;
        let modal = new bootstrap.Modal(document.getElementById('acrModal'));
        let sortColumn = "";
        let sortAsc = true;

        $(document).ready(function () {
            const role = localStorage.getItem("role");
            if (role && role !== "EMPLOYEE") {
                alert("Access denied");
                return;
            }
            $("#acceptingDiv").show();
            $("#searchBox").on("input", function () {
                searchTable($(this).val());
            });
            $("#pageSize").on("change", function () {
                changePageSize();
            });
            loadTable();
        });

        function loadTable() {
            $.ajax({
                url: "/api/acr/accepting/my",
                headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') }, // ✅ cookie auth fix
                success: function (res) {
                    console.log(res);
                    dataList = (res.Data && res.Data.AcrCycles) ? res.Data.AcrCycles : [];
                    filtered = [...dataList];
                    currentPage = 1;
                    sortColumn = "OfficerName";
                    sortAsc = true;
                    sortTable("OfficerName");
                },
                error: function (err) {
                    console.error(err);
                    alert("Failed to load data (check auth)");
                }
            });
        }

        function formatDate(dateStr) {
            if (!dateStr) return '-';
            let d = new Date(dateStr);
            return d.toLocaleDateString('en-GB'); // dd/mm/yyyy
        }

        function renderTable() {
            let start = (currentPage - 1) * pageSize;
            let pageData = filtered.slice(start, start + pageSize);
            let html = "";

            if (pageData.length === 0) {
                html = `<tr><td colspan="7" class="text-center text-muted">No entries found</td></tr>`;
            } else {
                pageData.forEach(x => {
                    html += `<tr>
                        <td>${x.OfficerName || ''}</td>
                        <td>${x.Location || '-'}</td>
                        <td>${formatDate(x.PostingFrom)}</td>
                        <td>${formatDate(x.PostingTo)}</td>
                        <td>${x.AcrYear || ''}</td>
                        <td>${getStatusBadge(x.Status)}</td>
                        <td>
                            <button class="btn btn-sm btn-info" onclick="openAcr('${x.AcrId}')">
                                <i class="bi bi-eye"></i> View
                            </button>
                        </td>
                    </tr>`;
                });
            }

            $("#acrTableBody").html(html);

            if (filtered.length === 0) {
                $("#tableInfo").text("Showing 0 to 0 of 0 entries");
            } else {
                $("#tableInfo").text(
                    `Showing ${start + 1} to ${Math.min(start + pageSize, filtered.length)} of ${filtered.length} entries`
                );
            }

            renderPagination();
        }

        function renderPagination() {
            const totalPages = Math.ceil(filtered.length / pageSize);
            let html = '';

            if (totalPages <= 1) {
                $("#pagination").html("");
                return;
            }

            html += `<li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage - 1})">Previous</a>
            </li>`;

            const startPage = Math.max(1, currentPage - 2);
            const endPage = Math.min(totalPages, currentPage + 2);

            if (startPage > 1) {
                html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="gotoPage(1)">1</a></li>`;
                if (startPage > 2) {
                    html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
                }
            }

            for (let i = startPage; i <= endPage; i++) {
                html += `<li class="page-item ${i == currentPage ? 'active' : ''}">
                    <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${i})">${i}</a>
                </li>`;
            }

            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
                }
                html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="gotoPage(${totalPages})">${totalPages}</a></li>`;
            }

            html += `<li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link" href="javascript:void(0)" onclick="gotoPage(${currentPage + 1})">Next</a>
            </li>`;

            $("#pagination").html(html);
        }

        // function gotoPage(p){currentPage=p;renderTable();}
        function gotoPage(p) {

            const totalPages = Math.ceil(filtered.length / pageSize);

            if (p < 1 || p > totalPages) return;

            currentPage = p;
            renderTable();
        }

        function changePageSize() {
            pageSize = parseInt($("#pageSize").val(), 10) || 10;
            currentPage = 1;
            renderTable();
        }

        function searchTable(val) {
            val = (val || "").toLowerCase().trim();
            if (!val) {
                filtered = [...dataList];
            } else {
                filtered = dataList.filter(x =>
                    (x.OfficerName || "").toLowerCase().includes(val) ||
                    (x.Location || "").toLowerCase().includes(val) ||
                    (x.PostingFrom || "").toLowerCase().includes(val) ||
                    (x.PostingTo || "").toLowerCase().includes(val) ||
                    (x.AcrYear || "").toString().toLowerCase().includes(val) ||
                    (x.Status || "").toLowerCase().includes(val)
                );
            }
            currentPage = 1;
            renderTable();
        }

        function openAcr(id) {
            currentAcrId = id;
            $("#aaAgree").val("");
            $("#aaDisagree").val("");
            $("#aaRemarks").val("");
            $("#aaGrade").val("");
            $("#aaDecision").val("");
            $("#aaAgree, #aaDisagree, #aaRemarks, #aaGrade, #aaDecision").removeClass("is-invalid");

            $.ajax({
                url: `/api/acr/${id}/accepting`,
                headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
                success: function (res) {
                    let d = res.Data;

                    // Info Tab
                    $("#infoOfficer").val(d.Officer.DisplayName);
                    $("#infoYear").val(d.AcrYear);
                    $("#infoStatus").val(d.Status);
                    $("#infoLocation").val(d.Location);
                    $("#infoFrom").val(formatDate(d.PostingFrom));
                    $("#infoTo").val(formatDate(d.PostingTo));
                    $("#infoDOB").val(formatDate(d.DateOfBirth));
                    $("#infoJoinNigam").val(formatDate(d.DateJoiningNigam));
                    $("#infoJoinRank").val(formatDate(d.DateJoiningPresentRank));
                    $("#infoJoinStation").val(formatDate(d.DateJoiningPresentStation));
                    $("#infoAcademic").val(d.AcademicQualification || '');
                    $("#infoTechnical").val(d.TechnicalQualification || '');
                    $("#infoDeptExam").val(d.DepartmentalExamPassed || '');
                    $("#infoPropertyReturn").val(formatDate(d.PropertyReturnDate));
                    $("#infoMedicalExam").val(formatDate(d.LastMedicalExamDate));
                    $("#infoCareerSummary").val(d.CareerPostingSummary || '');

                    // REPORTING TAB - RA1 Data
                    const ra1 = d.Ra1Assessment || {};
                    $("#ra1Targets").val(safeRating(ra1.WorkTargets));
                    $("#ra1Quality").val(safeRating(ra1.WorkQuality));
                    $("#ra1Overall").val(safeRating(ra1.OverallGrade));
                    $("#ra1Remarks").val(ra1.Remarks || '');

                    // REPORTING TAB - RA2 Data
                    const ra2 = d.Ra2Assessment || {};
                    if (ra2.Exists) {
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

                    let readOnly = d.Status !== "PENDING_ACCEPTING";
                    toggleViewOnly(readOnly);

                    modal.show();
                },
                error: function (err) {
                    console.error(err);
                    alert("Failed to load details");
                }
            });
        }

        function safeRating(val) {
            if (val === null || val === undefined || val === '') return '-';
            if (val > 10) return 10;
            if (val < 1) return 1;
            return val;
        }

        function toggleViewOnly(flag) {
            $("#acceptingTab input, #acceptingTab textarea, #acceptingTab select").prop("disabled", flag);
            if (flag) { $("#submitAA").hide(); $("#readonlyMsg").show(); }
            else { $("#submitAA").show(); $("#readonlyMsg").hide(); }
        }

        $("#submitAA").click(function (e) {
            e.preventDefault();
            if (!validateAAForm()) return;
                if (!confirm("Final submit? Cannot edit later")) return;
                let payload = {
                    AgreeWithPrevious: $("#aaAgree").val() === "true",
                    DisagreeDetails: $("#aaDisagree").val(),
                    ConflictResolved: false,
                    FinalGrade: Number($("#aaGrade").val()),
                    FinalRemarks: $("#aaRemarks").val(),
                    IsApproved: $("#aaDecision").val() === "true"
                };

                $.ajax({
                    url: `/api/acr/${currentAcrId}/accepting/submit`,
                    type: "POST",
                    contentType: "application/json",
                    headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
                    data: JSON.stringify(payload),
                    success: function () {
                        alert("Submitted successfully");
                        modal.hide();
                        loadTable();
                    },
                    error: function (err) {
                        console.error(err);
                        alert("Submit failed");
                    }
                });
        });

        function sortTable(col) {
            sortAsc = (sortColumn === col) ? !sortAsc : true;
            sortColumn = col;

            filtered.sort((a, b) => {
                let x = (a[col] || "").toString().toLowerCase();
                let y = (b[col] || "").toString().toLowerCase();

                if (col === "PostingFrom" || col === "PostingTo" || col === "AcrYear") {
                    x = a[col] || "";
                    y = b[col] || "";
                }

                if (x > y) return sortAsc ? 1 : -1;
                if (x < y) return sortAsc ? -1 : 1;
                return 0;
            });

            renderTable();
        }

        // Using getCommonStatusBadge from constant.js
        var getStatusBadge = getCommonStatusBadge;

        function validateAAForm() {
            $("#aaAgree, #aaRemarks, #aaGrade, #aaDecision, #aaDisagree").removeClass("is-invalid");

            const agree = $("#aaAgree").val();
            const remarks = ($("#aaRemarks").val() || "").trim();
            const grade = Number($("#aaGrade").val());
            const decision = $("#aaDecision").val();
            const disagree = ($("#aaDisagree").val() || "").trim();

            if (!agree) {
                $("#aaAgree").addClass("is-invalid");
                alert("Please select Agree with RA/Reviewing.");
                return false;
            }

            if (agree === "false" && !disagree) {
                $("#aaDisagree").addClass("is-invalid");
                alert("Disagree Details is required when you select No.");
                return false;
            }

            if (!remarks) {
                $("#aaRemarks").addClass("is-invalid");
                alert("Comments is required.");
                return false;
            }

            if (!grade || grade < 1 || grade > 10) {
                $("#aaGrade").addClass("is-invalid");
                alert("Overall Grade must be between 1 and 10.");
                return false;
            }

            if (!decision) {
                $("#aaDecision").addClass("is-invalid");
                alert("Please select Decision.");
                return false;
            }

            return true;
        }
    </script>
</asp:Content>