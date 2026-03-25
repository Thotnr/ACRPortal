<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<div class="container-fluid px-0" id="reviewingDiv" style="display:none;">
    <h2 class="mb-4">Reviewing Authority Dashboard</h2>

    <div class="row mb-3">
        <div class="col-md-3">
            <input type="text" id="reviewSearch" class="form-control"
                placeholder="Search ACR..."
                onkeyup="searchReviewingQueue(this.value)">
        </div>

        <div class="col-md-3">
            Show 
            <select id="reviewPageSizeSelect" class="form-select d-inline-block"
                    style="width:80px;" onchange="changeReviewPageSize()">
                <option value="5">5</option>
                <option value="10" selected>10</option>
                <option value="30">30</option>
                <option value="50">50</option>
            </select>
            entries
        </div>

        <div class="col-md-6 text-end" id="reviewTableInfo"></div>
    </div>
    <!-- TABLE -->
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <thead class="table-primary">
                <tr>
                    <th>Form Type</th>
                    <th>Officer</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="reviewingBody"></tbody>
        </table>
        <nav>
            <ul class="pagination justify-content-center" id="reviewPagination"></ul>
        </nav>
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

                <!-- TABS -->
                <ul class="nav nav-tabs">
                    <li class="nav-item">
                        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#infoTab">ACR Info</button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#reviewTab">Reviewing</button>
                    </li>
                </ul>

                <div class="tab-content mt-3">

                    <!-- INFO TAB -->
                    <div class="tab-pane fade show active" id="infoTab">
                        <div class="row g-3">
                            <div class="col-md-6"><label>Officer</label><input class="form-control" id="infoOfficer" readonly></div>
                            <div class="col-md-6"><label>Status</label><input class="form-control" id="infoStatus" readonly></div>
                        </div>
                    </div>

                    <!-- REVIEW TAB -->
                    <div class="tab-pane fade" id="reviewTab">

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

<script>

let selectedAcrId = null;
let draftSaved = false;
let reviewingData = [];
let filteredReviewing = [];
let reviewPageSize = 10;
let reviewCurrentPage = 1;

$(document).ready(function(){
    $("#reviewingDiv").show();
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

    value = value.toLowerCase();

    filteredReviewing = reviewingData.filter(a=>{
        return a.FormType.toLowerCase().includes(value) ||
               a.OfficerName.toLowerCase().includes(value) ||
               a.Location.toLowerCase().includes(value) ||
               a.Status.toLowerCase().includes(value);
    });

    reviewCurrentPage = 1;
    renderReviewingTable();
}

function gotoReviewPage(p){
    const totalPages = Math.ceil(filteredReviewing.length / reviewPageSize);

    if(p < 1 || p > totalPages) return;

    reviewCurrentPage = p;
    renderReviewingTable();
}

function renderReviewPagination(){

    const totalPages = Math.ceil(filteredReviewing.length / reviewPageSize);
    let html = '';

    html += `<li class="page-item ${reviewCurrentPage==1?'disabled':''}">
                <a class="page-link" onclick="gotoReviewPage(${reviewCurrentPage-1})">Prev</a>
             </li>`;

    for(let i=1;i<=totalPages;i++){
        html += `<li class="page-item ${i==reviewCurrentPage?'active':''}">
                    <a class="page-link" onclick="gotoReviewPage(${i})">${i}</a>
                 </li>`;
    }

    html += `<li class="page-item ${reviewCurrentPage==totalPages?'disabled':''}">
                <a class="page-link" onclick="gotoReviewPage(${reviewCurrentPage+1})">Next</a>
             </li>`;

    $("#reviewPagination").html(html);
}

function renderReviewingTable(){

    const tbody = $("#reviewingBody");
    tbody.empty();

    const start = (reviewCurrentPage - 1) * reviewPageSize;
    const end = start + reviewPageSize;

    const pageData = filteredReviewing.slice(start, end);

    if(pageData.length === 0){
        tbody.append(`<tr><td colspan="5" class="text-center">No entries found</td></tr>`);
    } else {
        pageData.forEach(a=>{
            tbody.append(`<tr>
                <td>${a.FormType}</td>
                <td>${a.OfficerName}</td>
                <td>${a.Location}</td>
                <td>${a.Status}</td>
                <td><button class="btn btn-info btn-sm" onclick="openReview('${a.AcrId}')">View</button></td>
            </tr>`);
        });
    }

    updateReviewInfo(start, end);
    renderReviewPagination();
}

function loadReviewingQueue(){
    $.ajax({
        url: BASE_URL + "api/acr/reviewing/my",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            if(res.Success){
                reviewingData = res.Data.AcrCycles;
                filteredReviewing = [...reviewingData];
                reviewCurrentPage = 1;
                renderReviewingTable();
            }
        }
    });
}

let reviewingModal = new bootstrap.Modal(document.getElementById('reviewingModal'));

function openReview(id){
    selectedAcrId = id;

    $.ajax({
        url: BASE_URL + "api/acr/"+id+"/reviewing",
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            const d = res.Data;

            $("#infoOfficer").val(d.Officer.DisplayName);
            $("#infoStatus").val(d.Status);

            const ra = d.ReviewingAssessment || {};

            $("input[name='agree'][value='"+ra.Agree+"']").prop("checked", true);
            $("#txtReason").val(ra.Reason);
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
    const grade = $("#txtGrade").val();

    $(".form-control").removeClass("is-invalid");

    if(!agree){
        alert("Select Yes/No");
        return false;
    }

    if(agree === "false" && !reason){
        $("#txtReason").addClass("is-invalid");
        valid = false;
    }

    if(!grade || grade < 1 || grade > 10){
        $("#txtGrade").addClass("is-invalid");
        valid = false;
    }

    return valid;
}

$("#saveDraft").click(function(){

    const payload = {
        Agree: $("input[name='agree']:checked").val() === "true",
        Reason: $("#txtReason").val(),
        Comments: $("#txtComments").val(),
        OverallGrade: Number($("#txtGrade").val())
    };

    $.ajax({
        url: BASE_URL+"api/acr/"+selectedAcrId+"/reviewing/draft",
        type:'PATCH',
        contentType:'application/json',
        data: JSON.stringify(payload),
        headers:{'Authorization':'Bearer '+localStorage.getItem('token')},
        success:function(res){
            alert(res.Message);
            draftSaved = true;
        }
    });
});

$("#submitReview").click(function(){

    if(!draftSaved){
        alert("Save draft first");
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
        }
    });
});

</script>

</asp:Content>