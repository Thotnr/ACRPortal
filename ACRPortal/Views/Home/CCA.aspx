<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

<style>
#ccaTable{ font-size:14px; }
#ccaTable th{ cursor:pointer; font-weight:600; }

.status-badge{ padding:4px 10px; border-radius:15px; font-size:12px; }
.status-pending{ background:#fff3cd; color:#856404; }
.status-completed{ background:#d4edda; color:#155724; }

.modal-body{ max-height:80vh; overflow-y:auto; }
.modal-dialog{ margin-top:30px; }
.ccaFormClass{ padding:0 20px 20px 20px; }
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
<td>Rahul Sharma</td>
<td>Manager</td>
<td>Gurgaon</td>
<td>01-04-2024</td>
<td>31-03-2025</td>
<td><span class="status-badge status-pending">Pending</span></td>
<td><button class="btn btn-sm btn-info" onclick="openAppraisalModal()">View</button></td>
</tr>
</tbody>

</table>
</div>
</div>

<!-- MODAL -->
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
<label>From</label>
<input type="date" class="form-control" id="periodFrom">
</div>
<div class="form-group col-md-6">
<label>To</label>
<input type="date" class="form-control" id="periodTo">
</div>
</div>

<div class="form-group">
<label>Place / Office of Posting</label>
<!-- <input type="text" class="form-control" id="placePosting"> -->
 <select class="form-control" id="placePosting"></select>
</div>

<h5 class="mt-3">Basic Information</h5>

<div class="form-row">
<div class="form-group col-md-6">
<label>Name of the Officer</label>
<!-- <input type="text" class="form-control" id="officerName"> -->
<select class="form-control" id="officerName"></select>
</div>

<div class="form-group col-md-6">
<label>Designation</label>
<select class="form-control" id="designation" onchange="onDesignationChange()">
<option value="">Loading...</option>
</select>
</div>
</div>

<div class="form-row">
<div class="form-group col-md-6">
<label>Date of Birth</label>
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
<input type="text" class="form-control" id="academicQualification">
</div>
<div class="form-group col-md-6" id="technicalDiv">
<label>Technical Qualification</label>
<input type="text" class="form-control" id="technicalQualification">
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
<input type="text" class="form-control" id="deptExam">
</div>

<h5 class="mt-3">Authorities</h5>

<div class="form-row" id="authorityRow">
<div class="form-group col-md-4">
<label>Reporting Authority</label>
<select class="form-control authority-ddl" id="reportingAuthority"></select>
</div>

<div class="form-group col-md-4">
<label>Review Authority</label>
<select class="form-control authority-ddl" id="reviewAuthority"></select>
</div>

<div class="form-group col-md-4">
<label>Accepting Authority</label>
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
<label>Medical Report</label>
<input type="file" class="form-control" id="medicalReport">
</div>

<div class="text-center mt-4">
<button type="button" class="btn btn-secondary mr-2" id="btnSaveDraft">Save as Draft</button>
<button type="submit" class="btn btn-success">Submit</button>
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
var isDraft = false;

$(document).ready(function(){
    var token = localStorage.getItem("token");
    if(!token){
        window.location = BASE_URL + "Login/UserAuth";
    }else{
        loadCurrentUser(token);   
        // ✅ SEQUENTIAL loading - पहले सब load हो जाएं
        loadDesignations()
            .then(() => loadSubDivisionsForDropdown())
            .then(() => loadEmployees())
            .then(() => {
                console.log("All dropdowns loaded successfully");
            });
    }
    sortTable(0);
});

function loadCurrentUser(token){

    $.ajax({
        url: BASE_URL + "api/auth/me",
        method: "GET",
        headers:{ "Authorization":"Bearer " + token },
        success:function(res){
            if(!res.Success){
                window.location = BASE_URL + "Login/UserAuth";
            }
        }
    });
}

function loadDesignations(){
    return new Promise((resolve) => {
        var token = localStorage.getItem("token");
        $.ajax({
            url: BASE_URL + "api/admin/masters/designations?activeOnly=true",
            method: "GET",
            headers:{ "Authorization":"Bearer "+token },
            success:function(res){
                if(res.Success){
                    designationsList = res.Data.Designations || [];
                    bindDesignationDropdown();
                }
                resolve(); // ✅ Always resolve
            },
            error: () => resolve() // ✅ Handle error भी
        });
    });
}

function bindDesignationDropdown(){

    var ddl = $("#designation");
    ddl.empty();
    ddl.append('<option value="">Select</option>');

    designationsList.forEach(function(d){

        ddl.append(`
            <option 
                value="${d.DsgId}" 
                data-formtype="${d.FormType}">
                ${d.Dsg} - ${d.DsgDesc}
            </option>
        `);
    });
}

function onDesignationChange(){

    var selected = $("#designation option:selected");
    formType = selected.data("formtype");

    $("#formTitle").text(getFormTitle(formType));

    applyFormRules();
}

function applyFormRules(){

    // 🔥 REMOVE if already exists (important fix)
    $("#reportingAuthority2Div").remove();

    $("#technicalDiv").show();

    if(formType === "A1b"){

        // add only once
        if(!$("#reportingAuthority2").length){

            $("#authorityRow").append(`
            <div class="form-group col-md-4" id="reportingAuthority2Div">
                <label>Second Reporting Authority</label>
                <select class="form-control authority-ddl" id="reportingAuthority2"></select>
            </div>
            `);
        }
    }

    if(formType === "A2"){
        // $("#technicalDiv").hide();
    }

    bindAuthorityDropdowns();
}

function getFormTitle(type){
    if(type === "A1a") return "Senior Engineering Officers (SE & Above)";
    if(type === "A1b") return "Engineering Officers (AE to XEN)";
    if(type === "A2") return "General & Accounts Officers";
    return "CCA Officer Appraisal";
}

function openAppraisalModal(){
    $('#appraisalModal').modal('show');
}

function closeModal(){
    $('#appraisalModal').modal('hide');
}

function searchTable(value){
    value=value.toLowerCase();
    document.querySelectorAll("#ccaTable tbody tr").forEach(function(row){
        row.style.display=row.innerText.toLowerCase().includes(value)?"":"none";
    });
}

function sortTable(col){
    var table=document.getElementById("ccaTable"), switching=true;
    while(switching){
        switching=false;
        var rows=table.rows;
        for(var i=1;i<rows.length-1;i++){
            var x=rows[i].getElementsByTagName("TD")[col];
            var y=rows[i+1].getElementsByTagName("TD")[col];
            if(x.innerHTML.toLowerCase()>y.innerHTML.toLowerCase()){
                rows[i].parentNode.insertBefore(rows[i+1],rows[i]);
                switching=true; break;
            }
        }
    }
}

var employeesList = [];

function loadEmployees(){
    return new Promise((resolve) => {
        var token = localStorage.getItem("token");
        $.ajax({
            url: BASE_URL + "api/admin/users?role=EMPLOYEE",
            method: "GET",
            headers:{ "Authorization":"Bearer "+token },
            success:function(res){
                if(res.Success){
                    employeesList = res.Data.Users || [];
                    bindEmployeeDropdown();
                    bindAuthorityDropdowns(); // ✅ Authorities भी load हों
                }
                resolve();
            },
            error: () => {
                alert("Failed to load employees");
                resolve();
            }
        });
    });
}

function bindAuthorityDropdowns(){

    var selectedOfficer = $("#officerName").val();

    $(".authority-ddl").each(function(){

        var ddl = $(this);

        if (ddl.hasClass("select2-hidden-accessible")) {
            ddl.select2("destroy");
        }

        ddl.empty();
        ddl.append('<option value="">Select</option>');

        employeesList.forEach(function(emp){

            // ❌ remove selected officer
            if(emp.LoginId === selectedOfficer) return;

            ddl.append(`
                <option value="${emp.LoginId}">
                    ${emp.DisplayName} (${emp.LoginId})
                </option>
            `);
        });

        ddl.select2({
            width: '100%',
            placeholder: "Search employee",
            allowClear: true,
            dropdownParent: $('#appraisalModal')
        });

    });

    preventReportingDuplicate();
}

function preventReportingDuplicate(){

    // only bind if second reporting exists
    if(!$("#reportingAuthority2").length) return;

    $("#reportingAuthority, #reportingAuthority2")
    .off("change.reporting") // namespaced event (best practice)
    .on("change.reporting", function(){

        var reporting = $("#reportingAuthority").val();
        var second = $("#reportingAuthority2").val();

        if(reporting && second && reporting === second){

            alert("Reporting Authority and Second Reporting Authority cannot be same");

            $(this).val(null).trigger("change"); // better reset for select2
        }

    });
}

function bindEmployeeDropdown(){
    var ddl = $("#officerName");

    if (ddl.hasClass("select2-hidden-accessible")) {
        ddl.select2("destroy");
    }

    ddl.empty();
    ddl.append('<option value="">Select Employee</option>');

    employeesList.forEach(function(emp){
        ddl.append(`
            <option 
                value="${emp.LoginId}" 
                data-dsgid="${emp.DsgId}">
                ${emp.DisplayName} (${emp.LoginId})
            </option>
        `);
    });

    ddl.select2({
        width: '100%',
        placeholder: "Search employee",
        allowClear: true,
        dropdownParent: $('#appraisalModal')
    });

    // ✅ IMPROVED change handler - designation properly bind होता है
    ddl.off("change.officer").on("change.officer", function(){
        var data = $(this).select2('data');
        var loginId = $(this).val();
        var dsgId = null;
        
        console.log("🔍 Officer Selection Triggered");
        console.log("Full Selected Data:", data);
        
        if(data && data.length && loginId){
            var selectedItem = data[0];
            console.log("✅ Selected Officer ID:", loginId);
            console.log("✅ Selected Officer Name:", selectedItem.text);

            // ✅ Get dsgId from option data attribute
            dsgId = $(this).find(`option[value="${loginId}"]`).data("dsgid");
            console.log("✅ Found DsgId:", dsgId);
        }

        // ✅ Designation auto-select with proper trigger
        if(dsgId){
            console.log("🔗 Setting designation:", dsgId);
            $("#designation").val(dsgId).trigger("change");
            onDesignationChange(); // ✅ Form rules apply करें
        } else {
            console.log("⚠️ No designation found for officer");
            $("#designation").empty().append('<option value="">No Designation</option>');
        }

        // ✅ Rebind authorities WITHOUT selected officer
        bindAuthorityDropdowns();
        
        // ✅ Form input event trigger
        $("#ccaForm")[0].dispatchEvent(new Event('input', { bubbles: true }));
    });
}

var subDivisionList = [];

function loadSubDivisionsForDropdown(){
    return new Promise((resolve) => {
        var token = localStorage.getItem("token");
        $.ajax({
            url: BASE_URL + "api/admin/masters/subdivisions",
            method: "GET",
            headers:{ "Authorization":"Bearer "+token },
            success:function(res){
                if(res.Success){
                    subDivisionList = res.Data.SubDivisions || [];
                    bindSubDivisionDropdown();
                }
                resolve();
            },
            error: () => resolve()
        });
    });
}

function bindSubDivisionDropdown(){
var ddl = $("#placePosting");

    if (ddl.hasClass("select2-hidden-accessible")) {
        ddl.select2("destroy");
    }

    ddl.empty();
    ddl.append('<option value="">Select SubDivision</option>');

    subDivisionList.forEach(function(s){
        ddl.append(`
            <option value="${s.SubDivisionId}">
                ${s.SubDivision}
            </option>
        `);
    });

    ddl.select2({
        width: '100%',
        placeholder: "Search SubDivision",
        allowClear: true,
        dropdownParent: $('#appraisalModal')
    });

    // ✅ IMPROVED change handler - properly logs और bind करता है
    ddl.off("change.place").on("change.place", function(){
        var val = $(this).val();
        var data = $(this).select2('data');
        
        if(val && data && data.length){
            var item = data[0];
            console.log("✅ Selected Posting ID:", item.id);
            console.log("✅ Selected Posting Name:", item.text);
            console.log("✅ PlacePosting value set:", val);
            
            // ✅ Manual trigger for form validation
            $("#ccaForm")[0].dispatchEvent(new Event('input', { bubbles: true }));
        } else {
            console.log("❌ No posting selected");
        }
    });
}

function formatDate(dateValue){

    if(!dateValue) return null;

    // Already yyyy-MM-dd hai to direct return
    if(/^\d{4}-\d{2}-\d{2}$/.test(dateValue)){
        return dateValue;
    }

    var d = new Date(dateValue);

    if(isNaN(d)) return null;

    var month = (d.getMonth() + 1).toString().padStart(2,'0');
    var day = d.getDate().toString().padStart(2,'0');

    return d.getFullYear() + "-" + month + "-" + day;
}

function buildPayload(isDraft){

    var officerData = $("#officerName").select2('data') || [];
    var postingData = $("#placePosting").select2('data') || [];

    var location = "";

    if (postingData.length) {
        location = postingData[0].text
            .trim()
            .replace(/\s*\(.*?\)/, ''); // remove (101)
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
        DesignationId: $("#designation").val(),

        SaveAsDraft: isDraft,

        Department: "",

        Location: location,

        AcademicQualification: $("#academicQualification").val(),
        TechnicalQualification: formType === "A2"
            ? null
            : $("#technicalQualification").val(),

        DepartmentalExamPassed: $("#deptExam").val(),

        ReportingUserId: $("#reportingAuthority").val(),
        ReportingUserId2: $("#reportingAuthority2").length
            ? $("#reportingAuthority2").val()
            : null,

        ReviewingUserId: $("#reviewAuthority").val(),
        AcceptingUserId: $("#acceptingAuthority").val(),

        CareerPostingSummary: ""
    };
}

$("#ccaForm").off("submit").on("submit", function(e){
    e.preventDefault();
    
    var payload = buildPayload(isDraft);
debugger
    // ✅ Strict validation only for final submit
    if(!isDraft){

        if(!payload.OfficerUserId){
            alert("Officer is required");
            return;
        }

        if(!payload.DesignationId){
            alert("Designation is required");
            return;
        }

        if(!payload.PostingFrom || !payload.PostingTo){
            alert("Posting period required");
            return;
        }

        if(payload.PostingTo <= payload.PostingFrom){
            alert("Posting To must be greater than From");
            return;
        }

        if(formType === "A1b" && !payload.ReportingUserId2){
            alert("Second Reporting Authority required");
            return;
        }

        if((formType === "A1a" || formType === "A2") && payload.ReportingUserId2){
            alert("Second Reporting Authority not allowed");
            return;
        }
    }

    submitAppraisal(payload);

    isDraft = false; // reset
});

function submitAppraisal(data){

    var token = localStorage.getItem("token");

    $.ajax({
        url: BASE_URL + "api/cca/acr",
        method: "POST",
        headers:{ "Authorization":"Bearer "+token },
        contentType: "application/json",
        data: JSON.stringify(data),

        success:function(res){
            if(res.Success){
                alert("ACR Submitted Successfully");
                closeModal();
            }else{
                alert(res.Message || "Error");
            }
        },

        error:function(err){
            alert("Submission Failed");
        }
    });
}

$("#btnSaveDraft").click(function(){
    isDraft = true;
    $("#ccaForm").submit();
});

</script>

</asp:Content>