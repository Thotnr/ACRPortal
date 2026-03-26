<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .dashboard-card {
        background: #fff;
        border: 1px solid #e9ecef;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    
    .stat-box {
        text-align: center;
        padding: 20px;
        border-radius: 8px;
        background: #f8f9fa;
        margin: 10px 0;
    }
    
    .stat-number {
        font-size: 32px;
        font-weight: bold;
        color: #0d6efd;
    }
    
    .stat-label {
        font-size: 14px;
        color: #6c757d;
        margin-top: 5px;
    }
    
    .status-badge {
        display: inline-block;
        padding: 8px 12px;
        border-radius: 4px;
        margin: 5px;
        font-size: 13px;
    }
    
    .progress-section {
        padding: 15px 0;
    }
</style>

<div class="container-fluid mt-4">
    <div class="row mb-4">
        <div class="col-md-12">
            <h2 class="page-title">Dashboard</h2>
        </div>
    </div>

    <!-- Summary Cards Row -->
    <div class="row">
        <div class="col-md-3">
            <div class="dashboard-card">
                <div class="stat-box">
                    <div class="stat-number" id="totalAcrs">0</div>
                    <div class="stat-label">Total ACRs</div>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="dashboard-card">
                <div class="stat-box">
                    <div class="stat-number" id="completedCount">0</div>
                    <div class="stat-label">Completed</div>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="dashboard-card">
                <div class="stat-box">
                    <div class="stat-number" id="inProgressCount">0</div>
                    <div class="stat-label">In Progress</div>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="dashboard-card">
                <div class="stat-box">
                    <div class="stat-number" id="completionRate">0%</div>
                    <div class="stat-label">Completion Rate</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Status Distribution -->
    <div class="row mt-3">
        <div class="col-md-12">
            <div class="dashboard-card">
                <h5 class="mb-3">Status Distribution</h5>
                <div id="statusDistribution" class="row">
                    <!-- Status badges will be populated here -->
                </div>
            </div>
        </div>
    </div>

    <!-- Completion Progress -->
    <div class="row mt-3">
        <div class="col-md-12">
            <div class="dashboard-card">
                <h5 class="mb-3">Overall Progress</h5>
                <div class="progress-section">
                    <div class="mb-2">
                        <small class="text-muted">Completion Progress</small>
                        <div class="progress" style="height: 25px;">
                            <div class="progress-bar bg-success" id="progressBar" role="progressbar" 
                                 style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                                <span id="progressText" style="color: white; font-weight: bold;">0%</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
    var BASE_URL = '<%= Url.Content("~/") %>';
    $(document).ready(function(){
        var token = localStorage.getItem("token");
        if(!token){
            window.location= BASE_URL + "Login/UserAuth";
        }else {
            loadCurrentUser(token);
            loadDashboardSummary(token);
        }
    });

    function loadCurrentUser(token){
        if(!token){
            window.location = BASE_URL + "Login/UserAuth";
            return;
        }

        $.ajax({
            url: BASE_URL + "api/auth/me",
            method: "GET",
            headers:{
                "Authorization":"Bearer " + token
            },
            success:function(res){
                if(res.Success){
                    var user = res.Data;
                    localStorage.setItem("displayName", user.DisplayName);
                    localStorage.setItem("role", user.SystemRole);
                    if($("#displayName").length){
                        $("#displayName").text(user.DisplayName);
                    }
                    if($("#userRole").length){
                        $("#userRole").text(user.SystemRole);
                    }
                }
                else{
                    window.location = BASE_URL + "Login/UserAuth";
                }
            },
            error:function(xhr){
                if(xhr.status === 401 || xhr.status === 404){
                    localStorage.clear();
                    window.location = BASE_URL + "Login/UserAuth";
                }
                else{
                    alert("Failed to load user session");
                }
            }
        });
    }

    function loadDashboardSummary(token){
        $.ajax({
            url: BASE_URL + "api/dashboard/summary",
            method: "GET",
            headers:{
                "Authorization":"Bearer " + token
            },
            success:function(res){
                if(res.Success){
                    var data = res.Data;
                    
                    // Update summary cards
                    $("#totalAcrs").text(data.TotalAcrs);
                    $("#completedCount").text(data.Completion.Completed);
                    $("#inProgressCount").text(data.Completion.InProgress);
                    $("#completionRate").text(data.Completion.CompletionRate.toFixed(1) + "%");
                    
                    // Update progress bar
                    var rate = data.Completion.CompletionRate;
                    $("#progressBar").css("width", rate + "%").attr("aria-valuenow", rate);
                    $("#progressText").text(rate.toFixed(1) + "%");
                    
                    // Display status distribution
                    var statusHtml = '';
                    var statusColors = {
                        'DRAFT': 'badge-secondary',
                        'PENDING_OFFICER': 'badge-warning',
                        'PENDING_REPORTING': 'badge-info',
                        'PENDING_REVIEWING': 'badge-warning',
                        'PENDING_ACCEPTING': 'badge-info',
                        'APPROVED': 'badge-success',
                        'REJECTED': 'badge-danger'
                    };
                    
                    for(var status in data.ByStatus){
                        var count = data.ByStatus[status];
                        var badgeClass = statusColors[status] || 'badge-secondary';
                        statusHtml += '<div class="col-md-4 col-sm-6 mb-2">';
                        statusHtml += '<span class="badge ' + badgeClass + ' p-2" style="font-size: 13px;">';
                        statusHtml += status + ': <strong>' + count + '</strong>';
                        statusHtml += '</span>';
                        statusHtml += '</div>';
                    }
                    
                    $("#statusDistribution").html(statusHtml);
                }
                else{
                    console.error("Failed to load dashboard summary:", res.Message);
                }
            },
            error:function(xhr){
                console.error("Error loading dashboard summary:", xhr);
            }
        });
    }
</script>
</asp:Content>