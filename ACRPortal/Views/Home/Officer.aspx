<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Bootstrap JS (bundle includes Popper, required for modal & tabs) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery (optional, if using your AJAX scripts) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<div class="container-fluid px-0" id="employeeACRDiv" style="display:none;">
    <h2 class="mb-4">Officer ACR Portal</h2>

    <!-- ACR List Table -->
    <table class="table table-striped table-hover table-bordered" id="acrListTable">
        <thead class="table-primary">
            <tr>
                <th>Form Type</th>
                <th>Location</th>
                <th>Designation</th>
                <th>Posting From</th>
                <th>Posting To</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="acrListBody"></tbody>
    </table>

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
                        <button type="button" class="btn btn-sm btn-success mb-2" id="addTrainingRow">
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
        // Check Role from localStorage
        $(document).ready(function () {
            const role = localStorage.getItem('role');
            if(role !== "EMPLOYEE"){
                alert("Access denied. Only EMPLOYEE can access this page.");
                window.location.href = BASE_URL + "Home/Dashboard";
                return;
            }
            $("#employeeACRDiv").show();
            loadAcrList();
        });

        $(document).on('input change', '#selfTab input, #selfTab textarea', function () {
            isFormChanged = true;
            draftSaved = false;
            $('#submitBtn').addClass('d-none'); // hide submit again
        });

        function validateForm() {
            let isValid = true;
            let msg = '';

            if (!$('#dutiesDescription').val().trim()) {
                msg = 'Duties Description is required';
                isValid = false;
            }
            else if (!$('#targetsSet').val().trim()) {
                msg = 'Targets Set is required';
                isValid = false;
            }
            else if (!$('#targetsAchieved').val().trim()) {
                msg = 'Targets Achieved is required';
                isValid = false;
            }
            else if ($('#propertyDeclared').is(':checked') && !$('#propertyDeclaredDate').val()) {
                msg = 'Property Declared Date is required';
                isValid = false;
            }
            else if ($('#medicalCompliance').is(':checked') && !$('#medicalComplianceDate').val()) {
                msg = 'Medical Compliance Date is required';
                isValid = false;
            }

            if (!isValid) alert(msg);

            return isValid;
        }

        let selectedAcrId = null;

        function loadAcrList() {
            $.ajax({
                url: '/api/acr/my',
                headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') },
                success: function (res) {
                    if (res.Success) {
                        let rows = '';
                        res.Data.AcrCycles.forEach(a => {
                            // Determine badge color based on status
                            let statusBadge = '';
                            switch(a.Status) {
                                case 'PENDING_OFFICER':
                                    statusBadge = '<span class="badge bg-warning text-dark">Pending</span>';
                                    break;
                                case 'APPROVED':
                                    statusBadge = '<span class="badge bg-success">Approved</span>';
                                    break;
                                case 'REJECTED':
                                    statusBadge = '<span class="badge bg-danger">Rejected</span>';
                                    break;
                                default:
                                    statusBadge = `<span class="badge bg-secondary">${a.Status}</span>`;
                            }

                            rows += `<tr>
                                <td>${a.FormType}</td>
                                <td>${a.Location}</td>
                                <td>${a.Designation}</td>
                                <td>${a.PostingFrom}</td>
                                <td>${a.PostingTo}</td>
                                <td>${statusBadge}</td>
                                <td>
                                    <button class="btn btn-sm btn-info" onclick="viewAcr('${a.AcrId}')">
                                        <i class="bi bi-eye"></i> View
                                    </button>
                                </td>
                            </tr>`;
                        });
                        $('#acrListBody').html(rows);
                    } else alert(res.Message);
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
                        $('#viewDesignation').val(data.Designation || '');
                        $('#viewPostingFrom').val(data.PostingFrom || '');
                        $('#viewPostingTo').val(data.PostingTo || '');
                        $('#viewAcrYear').val(data.AcrYear || '');
                        $('#viewDepartment').val(data.Department || '');
                        $('#viewDOB').val(formatDate(data.DateOfBirth) || '');
                        $('#viewJoinNigam').val(data.DateJoiningNigam || '');
                        $('#viewJoinRank').val(data.DateJoiningPresentRank || '');
                        $('#viewJoinStation').val(data.DateJoiningPresentStation || '');
                        $('#viewAcademic').val(data.AcademicQualification || '');
                        $('#viewTechnical').val(data.TechnicalQualification || '');
                        $('#viewDeptExam').val(data.DepartmentalExamPassed || '');
                        $('#viewPropertyReturn').val(data.PropertyReturnDate || '');
                        $('#viewMedicalExam').val(data.LastMedicalExamDate || '');
                        $('#viewCareerSummary').val(data.CareerPostingSummary || '');

                        let docs = '';
                        (data.Documents || []).forEach(d=>{
                            docs += `<li class="list-group-item">${d.FileName} (${d.DocumentType})</li>`;
                        });
                        $('#viewDocList').html(docs);

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

        $('#saveDraftBtn').click(function () {
            if (!validateForm()) return;
            
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
                    draftSaved = true; // Set flag true once draft is saved
                    isFormChanged = false;
                    $('#submitBtn').removeClass('d-none'); 
                },
                error: function() {
                    alert('Error saving draft. Please try again.');
                    draftSaved = false; // Ensure flag stays false if save failed
                }
            });
        });

        $('#submitBtn').click(function () {
            
            if (isFormChanged) {
                alert("Please save draft before submitting updated data.");
                return;
            }

            if (!draftSaved) {
                alert("Please save draft first.");
                return;
            }

            if (window.isDocMandatory) {

                let hasDoc = !!currentUploadedDocument;

                if (!hasDoc) {
                    alert("Medical document is mandatory for age 40+");
                    return;
                }
            }

            if (!validateForm()) return;

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

    </script>
</asp:Content>