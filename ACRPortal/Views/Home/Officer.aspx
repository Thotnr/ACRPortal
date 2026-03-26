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
</style>
<div class="container-fluid px-0" id="employeeACRDiv" style="display:none;">
    <h2 class="mb-4 page-title">Officer ACR Portal</h2>

    <!-- ACR List Table -->
    <div class="card shadow-sm border-0">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h5 class="mb-0 text-primary">
                    <i class="bi bi-table"></i> My ACR List
                </h5>
                <div class="d-flex gap-2 flex-wrap">
                    <input type="text" id="acrSearchBox" class="form-control" placeholder="Search ACR..." style="width:260px;">
                    <select id="pageSize" class="form-select" style="width:110px;">
                        <option value="5">5</option>
                        <option value="10" selected>10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover table-bordered align-middle mb-0" id="acrListTable">
                    <thead class="table-primary">
                        <tr>
                            <th onclick="sortTable(0)" style="cursor:pointer;">Form Type</th>
                            <th onclick="sortTable(1)" style="cursor:pointer;">Location</th>
                            <th onclick="sortTable(2)" style="cursor:pointer;">Designation</th>
                            <th onclick="sortTable(3)" style="cursor:pointer;">Posting From</th>
                            <th onclick="sortTable(4)" style="cursor:pointer;">Posting To</th>
                            <th onclick="sortTable(5)" style="cursor:pointer;">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="acrListBody"></tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
                <div id="paginationInfo" class="small text-muted"></div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationContainer"></ul>
                </nav>
            </div>
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
                <!-- Tabs -->
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
                    <div class="section-card">
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
                    <div class="row g-3">
                    <div class="col-6"><label for="leaveDetails" class="form-label">Leave Details</label><textarea id="leaveDetails" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="membershipBodies" class="form-label">Membership Bodies</label><textarea id="membershipBodies" class="form-control" rows="2"></textarea></div>
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
                    <div class="col-6"><label for="awardsHonours" class="form-label">Awards / Honours</label><textarea id="awardsHonours" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="dutiesDescription" class="form-label">Duties Description <span class="text-danger">*</span></label><textarea id="dutiesDescription" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="targetsSet" class="form-label">Targets Set <span class="text-danger">*</span></label><textarea id="targetsSet" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="targetsAchieved" class="form-label">Targets Achieved <span class="text-danger">*</span></label><textarea id="targetsAchieved" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="shortfallReasons" class="form-label">Shortfall Reasons</label><textarea id="shortfallReasons" class="form-control" rows="2"></textarea></div>
                    <div class="col-6"><label for="majorAchievements" class="form-label">Major Achievements</label><textarea id="majorAchievements" class="form-control" rows="2"></textarea></div>

                    <!-- Compliance -->
                    <div class="row mt-3">
                        <div class="col-4"><div class="form-check"><input type="checkbox" class="form-check-input" id="auditorCompliance"><label class="form-check-label" for="auditorCompliance">Auditor Compliance</label></div></div>
                        <div class="col-4">
                            <div class="form-check">
                                <input type="checkbox" class="form-check-input" id="propertyDeclared">
                                <label class="form-check-label" for="propertyDeclared">Property Declared</label>
                            </div>
                            <!-- Wrap date input in a div for toggling -->
                            <div id="propertyDeclaredDateDiv" class="mt-1" style="display:none;">
                                <label for="propertyDeclaredDate" class="form-label">Property Declared Date</label>
                                <input type="date" class="form-control" id="propertyDeclaredDate">
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="form-check">
                                <input type="checkbox" class="form-check-input" id="medicalCompliance">
                                <label class="form-check-label" for="medicalCompliance">Medical Compliance</label>
                            </div>

                            <!-- Wrap date input in a div for toggling -->
                            <div id="medicalComplianceDateDiv" class="mt-1" style="display:none;">
                                <label for="medicalComplianceDate" class="form-label">Medical Compliance Date</label>
                                <input type="date" class="form-control" id="medicalComplianceDate">
                            </div>
                        </div>
                    </div>

                    <!-- Document upload -->
                     <div class="col-12 mt-3">
                        <label class="form-label fw-bold">
                            Medical Report
                            <span id="docMandatoryMsg" class="text-danger" style="display:none;">* Required for age 40+</span>
                        </label>

                        <div id="documentUploadSection" class="border rounded p-3 bg-light">
                            <!-- Upload state -->
                            <div id="docUploadBox">
                                <input type="file" id="fuAutoUpload" class="form-control"
                                    accept=".pdf,.jpg,.jpeg,.png"
                                    onchange="uploadFile(this)" />
                                <div class="form-text">Allowed: PDF, JPG, JPEG, PNG | Max size: 5 MB</div>
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
                                        <button type="button" id="deleteDocumentBtn" class="btn btn-sm btn-outline-danger" onclick="deleteCurrentDocument()">
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
                    <!-- Document upload -->

                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button class="btn btn-primary" id="saveDraftBtn"><i class="bi bi-save"></i> Save Draft</button>
                        <button class="btn btn-success d-none" id="submitBtn"><i class="bi bi-send"></i> Submit Self-Appraisal</button>
                    </div>
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
    let currentUploadedDocument = null;
    const DOCUMENT_TYPE = "MEDICAL_REPORT";

    let acrListData = [];
    let filteredAcrListData = [];
    let currentPage = 1;
    let pageSize = 10;
    let currentSortColumn = -1;
    let currentSortDirection = 'asc';

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

        $("#pageSize").on("change", function () {
            pageSize = parseInt($(this).val(), 10) || 10;
            currentPage = 1;
            renderAcrTable();
        });
        loadAcrList();
    });

    $(document).on('input change', '#selfTab input, #selfTab textarea', function () {
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

        if ($('#propertyDeclared').is(':checked') && !$('#propertyDeclaredDate').val()) {
            alert('Property Declared Date is required');
            $('#propertyDeclaredDate').focus();
            return false;
        }

        if ($('#medicalCompliance').is(':checked') && !$('#medicalComplianceDate').val()) {
            alert('Medical Compliance Date is required');
            $('#medicalComplianceDate').focus();
            return false;
        }

        return true;
    }
    let selectedAcrId = null;

    function loadAcrList() {
        $.ajax({
            url: '/api/acr/my',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (res.Success) {
                    acrListData = (res.Data && res.Data.AcrCycles) ? res.Data.AcrCycles : [];
                    filteredAcrListData = acrListData.slice();
                    currentPage = 1;
                    applySorting();
                    renderAcrTable();
                } else {
                    alert(res.Message);
                }
            },
            error: function () {
                $('#acrListBody').html('<tr><td colspan="7" class="text-center text-danger">Failed to load ACR list</td></tr>');
            }
        });
    }

    function formatDate(d){
        if(!d) return '';
        return new Date(d).toLocaleDateString('en-GB');
    }

    let acrModal = new bootstrap.Modal(document.getElementById('acrDetailModal'));

    function viewAcr(acrId){
        selectedAcrId = acrId;
        $.ajax({
            url: `/api/acr/${acrId}`,
            headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
            success: function(res){
                if(res.Success){
                    const data = res.Data;
                    let age = calculateAge(data.DateOfBirth);
                    // Global flag
                    window.isDocMandatory = age >= 40;
                    if (window.isDocMandatory) {
                        $('#docMandatoryMsg').show();
                    } else {
                        $('#docMandatoryMsg').hide();
                    }
                    if (data.Status && data.Status.toUpperCase() === 'PENDING_OFFICER') {
                        $('#saveDraftBtn').show();
                        $('#addTrainingRow').show();
                        $(".removeTrainingRow").show();
                        $('#submitBtn').removeClass('d-none');
                        $('#documentUploadSection').show();
                        $('#fuAutoUpload').prop('disabled', false);
                        $('#deleteDocumentBtn').prop('disabled', false);
                    } else {
                        $('#saveDraftBtn').hide();
                        $('#addTrainingRow').hide();
                        $(".removeTrainingRow").hide();
                        $('#submitBtn').addClass('d-none');
                        $('#documentUploadSection').hide();
                        $('#fuAutoUpload').prop('disabled', true);
                        $('#deleteDocumentBtn').prop('disabled', true);
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
                    $('#propertyDeclared').prop('checked', s.PropertyDeclared || false);
                    $('#propertyDeclaredDate').val(s.PropertyDeclaredDate || '');
                    $('#medicalCompliance').prop('checked', s.MedicalCompliance || false);
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
                    loadDocuments();
                    // --- Always activate the first tab (ACR Info) ---
                    const firstTab = new bootstrap.Tab(document.querySelector('#view-tab'));
                    firstTab.show();

                    acrModal.show();
                } else alert(res.Message);
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
            PropertyDeclared: $('#propertyDeclared').is(':checked'),
            PropertyDeclaredDate: $('#propertyDeclaredDate').val(),
            MedicalCompliance: $('#medicalCompliance').is(':checked'),
            MedicalComplianceDate: $('#medicalComplianceDate').val()
        };

        $.ajax({
            url: `/api/acr/${selectedAcrId}/self-appraisal/draft`,
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
            let hasDoc = !!currentUploadedDocument;
            if (!hasDoc) {
                alert("Medical document is mandatory for age 40+");
                return;
            }
        }

        $.ajax({
            url: `/api/acr/${selectedAcrId}/self-appraisal/submit`,
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

    function callDocsApi(fileData) {
        var payload = {
                FileUrl: fileData.FileUrl,
                FileName: fileData.FileName,
                DocumentType: DOCUMENT_TYPE
            };

            $.ajax({
                url: `/api/acr/${selectedAcrId}/docs`,
                type: 'POST',
                headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
                contentType: 'application/json',
                data: JSON.stringify(payload),
                success: function (res) {
                    if (res.Success) {
                        $('#uploadStatus').html('<span class="text-success">Document uploaded successfully</span>');
                        loadDocuments();
                        $('#fuAutoUpload').val('');
                    } else {
                        $('#uploadStatus').html('<span class="text-danger">' + (res.Message || 'Document API failed') + '</span>');
                    }
                },
                error: function (xhr) {
                    let msg = 'API Error';
                    if (xhr.responseJSON && xhr.responseJSON.Message) {
                        msg = xhr.responseJSON.Message;
                    }
                    $('#uploadStatus').html('<span class="text-danger">' + msg + '</span>');
                }
            });
    }
    // ---------------- Document ----------------
    function loadDocuments() {
        if (!selectedAcrId) return;
        $.ajax({
            url: `/api/acr/${selectedAcrId}/docs`,
            type: 'GET',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (!res.Success) {
                    showUploadState();
                    return;
                }

                const documents = (res.Data && res.Data.Documents) ? res.Data.Documents : [];
                const medicalDoc = documents.find(d => d.DocumentType === DOCUMENT_TYPE) || null;

                currentUploadedDocument = medicalDoc;

                if (medicalDoc) {
                    showUploadedState(medicalDoc);
                } else {
                    showUploadState();
                }
            },
            error: function () {
                showUploadState();
            }
        });
    }

    // Show/Hide Property Declared date
    $('#propertyDeclared').change(function() {
        if($(this).is(':checked')){
            $('#propertyDeclaredDateDiv').show();
        } else {
            $('#propertyDeclaredDateDiv').hide();
            $('#propertyDeclaredDate').val(''); // optional: clear date
        }
    });

    // Optional: On modal open, set initial state
    function togglePropertyDeclaredDate(s) {
        if(s.PropertyDeclared){
            $('#propertyDeclared').prop('checked', true);
            $('#propertyDeclaredDateDiv').show();
        } else {
            $('#propertyDeclared').prop('checked', false);
            $('#propertyDeclaredDateDiv').hide();
        }
    }

    $('#medicalCompliance').change(function() {
        if($(this).is(':checked')){
            $('#medicalComplianceDateDiv').show();
        } else {
            $('#medicalComplianceDateDiv').hide();
            $('#medicalComplianceDate').val(''); // clear date when unchecked
        }
    });

    // Optional: Set initial state when loading data
    function toggleMedicalComplianceDate(s) {
        if(s.MedicalCompliance){
            $('#medicalCompliance').prop('checked', true);
            $('#medicalComplianceDateDiv').show();
        } else {
            $('#medicalCompliance').prop('checked', false);
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

        const file = input.files[0];
        const maxSize = 5 * 1024 * 1024;

        if (file.size > maxSize) {
            alert("File size cannot exceed 5MB");
            input.value = "";
            return;
        }

        var allowedTypes = ["application/pdf", "image/png", "image/jpeg"];
        if (!allowedTypes.includes(file.type)) {
            alert("Invalid file type! Only PDF, JPG, JPEG, PNG allowed.");
            input.value = "";
            return;
        }

        $('#uploadStatus').html('<span class="text-muted">Uploading file...</span>');

        var formData = new FormData();
        formData.append("file", file);

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/Web/Shared/FileUploadHandler", true);

        xhr.upload.onprogress = function (e) {
            if (e.lengthComputable) {
                var percent = (e.loaded / e.total) * 100;
                $('#uploadStatus').html('<span class="text-muted">Uploading... ' + percent.toFixed(0) + '%</span>');
            }
        };

        xhr.onload = function () {
            if (xhr.status === 200) {
                var res = JSON.parse(xhr.responseText);

                if (res.success) {
                    $('#hdnUploadedFilePath').val(res.filePath || '');
                    $('#hdnUploadedFileName').val(res.fileName || '');

                    callDocsApi({
                        FileUrl: res.filePath,
                        FileName: res.fileName
                    });
                } else {
                    $('#uploadStatus').html('<span class="text-danger">Upload failed: ' + (res.message || 'Unknown error') + '</span>');
                    input.value = "";
                }
            } else {
                $('#uploadStatus').html('<span class="text-danger">Upload error!</span>');
                input.value = "";
            }
        };

        xhr.onerror = function () {
            $('#uploadStatus').html('<span class="text-danger">Upload error!</span>');
            input.value = "";
        };

        xhr.send(formData);
    }

    function resetDocumentSection() {
        currentUploadedDocument = null;
        $('#hdnUploadedDocumentId').val('');
        $('#hdnUploadedFilePath').val('');
        $('#hdnUploadedFileName').val('');
        $('#uploadStatus').html('');
        $('#fuAutoUpload').val('');
        showUploadState();
    }

    function showUploadState() {
        $('#docUploadBox').removeClass('d-none');
        $('#docUploadedBox').addClass('d-none');
        $('#uploadedFileName').text('');
        $('#uploadedFileLink').attr('href', 'javascript:void(0)').addClass('d-none');
        $('#hdnUploadedDocumentId').val('');
    }

    function showUploadedState(doc) {
        $('#docUploadBox').addClass('d-none');
        $('#docUploadedBox').removeClass('d-none');

        $('#uploadedFileName').text(doc.FileName || '');
        $('#hdnUploadedDocumentId').val(doc.DocumentId || '');
        $('#hdnUploadedFilePath').val(doc.FileUrl || '');
        $('#hdnUploadedFileName').val(doc.FileName || '');

        if (doc.FileUrl) {
            $('#uploadedFileLink').attr('href', doc.FileUrl).removeClass('d-none');
        } else {
            $('#uploadedFileLink').attr('href', 'javascript:void(0)').addClass('d-none');
        }
    }

    function deleteCurrentDocument() {
        if (!selectedAcrId || !currentUploadedDocument || !currentUploadedDocument.DocumentId) {
            alert('No document found to delete.');
            return;
        }

        if (!confirm('Are you sure you want to delete this document?')) {
            return;
        }

        $('#deleteDocumentBtn').prop('disabled', true);

        $.ajax({
            url: `/api/acr/${selectedAcrId}/docs/${currentUploadedDocument.DocumentId}`,
            type: 'DELETE',
            headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
            success: function (res) {
                if (res.Success) {
                    $('#uploadStatus').html('<span class="text-success">Document deleted successfully</span>');
                    currentUploadedDocument = null;
                    showUploadState();
                    $('#hdnUploadedDocumentId').val('');
                    $('#hdnUploadedFilePath').val('');
                    $('#hdnUploadedFileName').val('');
                    $('#fuAutoUpload').val('');
                } else {
                    $('#uploadStatus').html('<span class="text-danger">' + (res.Message || 'Delete failed') + '</span>');
                }
            },
            error: function (xhr) {
                let msg = 'Delete failed';
                if (xhr.responseJSON && xhr.responseJSON.Message) {
                    msg = xhr.responseJSON.Message;
                }
                $('#uploadStatus').html('<span class="text-danger">' + msg + '</span>');
            },
            complete: function () {
                $('#deleteDocumentBtn').prop('disabled', false);
            }
        });
    }

function searchTable(value) {
    value = (value || '').toLowerCase().trim();

    if (!value) {
        filteredAcrListData = acrListData.slice();
    } else {
        filteredAcrListData = acrListData.filter(function (a) {
            return (
                (a.FormType || '').toLowerCase().includes(value) ||
                (a.Location || '').toLowerCase().includes(value) ||
                (a.Dsg || '').toLowerCase().includes(value) ||
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
        $('#paginationContainer').empty();
        $('#paginationInfo').text('Showing 0 to 0 of 0 entries');
        return;
    }

    let totalRecords = filteredAcrListData.length;
    let totalPages = Math.ceil(totalRecords / pageSize);

    if (currentPage > totalPages) {
        currentPage = totalPages;
    }

    let startIndex = (currentPage - 1) * pageSize;
    let endIndex = Math.min(startIndex + pageSize, totalRecords);
    let pageData = filteredAcrListData.slice(startIndex, endIndex);

    let rows = '';
    pageData.forEach(a => {
        rows += `<tr>
            <td>${a.FormType || ''}</td>
            <td>${a.Location || ''}</td>
            <td>${a.Dsg || ''}</td>
            <td>${a.PostingFrom || ''}</td>
            <td>${a.PostingTo || ''}</td>
            <td>${getStatusBadge(a.Status)}</td>
            <td>
                <button class="btn btn-sm btn-info" onclick="viewAcr('${a.AcrId}')">
                    <i class="bi bi-eye"></i> View
                </button>
            </td>
        </tr>`;
    });

    tbody.html(rows);

    $('#paginationInfo').text(
        'Showing ' + (startIndex + 1) + ' to ' + endIndex + ' of ' + totalRecords + ' entries'
    );

    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    let container = $('#paginationContainer');
    container.empty();

    if (totalPages <= 1) return;

    let prevDisabled = currentPage === 1 ? 'disabled' : '';
    container.append(
        `<li class="page-item ${prevDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">Previous</a>
        </li>`
    );

    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPages, currentPage + 2);

    if (startPage > 1) {
        container.append(`<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="goToPage(1)">1</a></li>`);
        if (startPage > 2) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
    }

    for (let i = startPage; i <= endPage; i++) {
        let active = currentPage === i ? 'active' : '';
        container.append(
            `<li class="page-item ${active}">
                <a class="page-link" href="javascript:void(0)" onclick="goToPage(${i})">${i}</a>
            </li>`
        );
    }

    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            container.append(`<li class="page-item disabled"><span class="page-link">...</span></li>`);
        }
        container.append(
            `<li class="page-item">
                <a class="page-link" href="javascript:void(0)" onclick="goToPage(${totalPages})">${totalPages}</a>
            </li>`
        );
    }

    let nextDisabled = currentPage === totalPages ? 'disabled' : '';
    container.append(
        `<li class="page-item ${nextDisabled}">
            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">Next</a>
        </li>`
    );
}

function goToPage(page) {
    let totalPages = Math.ceil(filteredAcrListData.length / pageSize);
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    renderAcrTable();
}
</script>
</asp:Content>