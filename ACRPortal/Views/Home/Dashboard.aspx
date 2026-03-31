<%@ Page Language="C#" 
Inherits="System.Web.Mvc.ViewPage"
MasterPageFile="~/Views/Shared/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<style>
    .dashboard-shell {
        --dashboard-navy: #102542;
        --dashboard-blue: #1d4ed8;
        --dashboard-cyan: #06b6d4;
        --dashboard-green: #10b981;
        --dashboard-amber: #f59e0b;
        --dashboard-red: #ef4444;
        --dashboard-ink: #172033;
        --dashboard-muted: #667085;
        --dashboard-line: rgba(15, 23, 42, 0.08);
        --dashboard-card: rgba(255, 255, 255, 0.92);
        --dashboard-shadow: 0 24px 50px rgba(16, 37, 66, 0.12);
        position: relative;
        padding: 18px 0 28px;
        color: var(--dashboard-ink);
    }

    .dashboard-shell:before,
    .dashboard-shell:after {
        content: "";
        position: absolute;
        border-radius: 50%;
        filter: blur(12px);
        opacity: 0.55;
        pointer-events: none;
    }

    .dashboard-shell:before {
        width: 180px;
        height: 180px;
        top: -20px;
        right: 8%;
        background: rgba(6, 182, 212, 0.18);
    }

    .dashboard-shell:after {
        width: 220px;
        height: 220px;
        bottom: 8px;
        left: 2%;
        background: rgba(29, 78, 216, 0.12);
    }

    .dashboard-hero {
        position: relative;
        overflow: hidden;
        background:
            radial-gradient(circle at top right, rgba(6, 182, 212, 0.22), transparent 34%),
            radial-gradient(circle at bottom left, rgba(255, 255, 255, 0.16), transparent 30%),
            linear-gradient(135deg, #102542 0%, #1d4ed8 55%, #06b6d4 100%);
        border-radius: 28px;
        padding: 30px 32px;
        margin-bottom: 24px;
        box-shadow: 0 28px 50px rgba(29, 78, 216, 0.22);
        color: #fff;
    }

    .dashboard-hero:after {
        content: "";
        position: absolute;
        width: 240px;
        height: 240px;
        right: -60px;
        top: -90px;
        border-radius: 50%;
        border: 1px solid rgba(255, 255, 255, 0.16);
        background: rgba(255, 255, 255, 0.05);
    }

    .eyebrow {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.12);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .dashboard-title {
        margin: 18px 0 10px;
        font-size: 34px;
        font-weight: 700;
        line-height: 1.15;
    }

    .dashboard-subtitle {
        max-width: 640px;
        margin: 0;
        font-size: 15px;
        line-height: 1.7;
        color: rgba(255, 255, 255, 0.82);
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
    }

    .hero-panel-label {
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: rgba(255, 255, 255, 0.7);
    }

    .hero-panel-value {
        margin: 10px 0 8px;
        font-size: 44px;
        font-weight: 700;
        line-height: 1;
    }

    .hero-panel-copy {
        margin: 0;
        font-size: 14px;
        line-height: 1.6;
        color: rgba(255, 255, 255, 0.8);
    }

    .metric-card,
    .dashboard-panel {
        background: var(--dashboard-card);
        border: 1px solid rgba(255, 255, 255, 0.7);
        border-radius: 24px;
        box-shadow: var(--dashboard-shadow);
    }

    .metric-card {
        position: relative;
        overflow: hidden;
        height: 100%;
        padding: 22px;
    }

    .metric-card:before {
        content: "";
        position: absolute;
        inset: 0;
        background: linear-gradient(135deg, rgba(255, 255, 255, 0.35), transparent 55%);
        pointer-events: none;
    }

    .metric-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 18px;
    }

    .metric-label {
        font-size: 13px;
        font-weight: 700;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        color: var(--dashboard-muted);
    }

    .metric-icon {
        width: 46px;
        height: 46px;
        border-radius: 16px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        color: #fff;
    }

    .metric-card.total .metric-icon,
    .metric-card.total .metric-trend {
        background: linear-gradient(135deg, #1d4ed8, #06b6d4);
    }

    .metric-card.completed .metric-icon,
    .metric-card.completed .metric-trend {
        background: linear-gradient(135deg, #059669, #34d399);
    }

    .metric-card.pending .metric-icon,
    .metric-card.pending .metric-trend {
        background: linear-gradient(135deg, #f59e0b, #fb7185);
    }

    .metric-value {
        font-size: 38px;
        font-weight: 700;
        line-height: 1;
        margin-bottom: 8px;
    }

    .metric-copy {
        margin: 0;
        font-size: 14px;
        color: var(--dashboard-muted);
        line-height: 1.6;
        min-height: 44px;
    }

    .metric-trend {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        margin-top: 18px;
        padding: 8px 12px;
        border-radius: 999px;
        color: #fff;
        font-size: 12px;
        font-weight: 700;
    }

    .dashboard-panel {
        height: 100%;
        padding: 24px;
        margin-top: 8px;
    }

    .panel-head {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 14px;
        margin-bottom: 20px;
    }

    .panel-title {
        margin: 0;
        font-size: 20px;
        font-weight: 700;
    }

    .panel-subtitle {
        margin: 6px 0 0;
        font-size: 14px;
        color: var(--dashboard-muted);
        line-height: 1.6;
    }

    .panel-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 14px;
        border-radius: 999px;
        background: rgba(16, 37, 66, 0.06);
        font-size: 12px;
        font-weight: 700;
        color: var(--dashboard-ink);
        white-space: nowrap;
    }

    .progress-card {
        background: linear-gradient(180deg, rgba(248, 250, 252, 0.95), rgba(235, 244, 255, 0.95));
    }

    .progress-ring-wrap {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 4px 0 10px;
    }

    .progress-ring {
        width: 182px;
        height: 182px;
        border-radius: 50%;
        background: conic-gradient(#10b981 0deg, rgba(148, 163, 184, 0.2) 0deg);
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: inset 0 0 0 1px rgba(255,255,255,0.45);
    }

    .progress-ring:before {
        content: "";
        width: 128px;
        height: 128px;
        border-radius: 50%;
        background: #fff;
        box-shadow: inset 0 0 0 1px rgba(15, 23, 42, 0.06);
    }

    .progress-ring-content {
        position: absolute;
        text-align: center;
    }

    .progress-ring-value {
        font-size: 34px;
        font-weight: 700;
        line-height: 1;
        color: var(--dashboard-ink);
    }

    .progress-ring-caption {
        margin-top: 7px;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        color: var(--dashboard-muted);
    }

    .progress-meter {
        height: 14px;
        border-radius: 999px;
        background: rgba(148, 163, 184, 0.2);
        overflow: hidden;
    }

    .progress-meter-bar {
        height: 100%;
        width: 0;
        border-radius: 999px;
        background: linear-gradient(90deg, #10b981, #34d399, #67e8f9);
        box-shadow: 0 10px 22px rgba(16, 185, 129, 0.28);
        transition: width 0.7s ease;
    }

    .progress-metrics {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 12px;
        margin-top: 18px;
    }

    .progress-metric {
        padding: 14px;
        border-radius: 18px;
        background: rgba(255, 255, 255, 0.9);
        border: 1px solid var(--dashboard-line);
        text-align: center;
    }

    .progress-metric-value {
        display: block;
        font-size: 24px;
        font-weight: 700;
        line-height: 1.1;
    }

    .progress-metric-label {
        display: block;
        margin-top: 6px;
        font-size: 12px;
        color: var(--dashboard-muted);
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }

    .status-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }

    .status-chip {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 14px 16px;
        border-radius: 18px;
        border: 1px solid var(--dashboard-line);
        background: rgba(248, 250, 252, 0.95);
    }

    .status-chip-main {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
    }

    .status-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        flex-shrink: 0;
        box-shadow: 0 0 0 4px rgba(15, 23, 42, 0.05);
    }

    .status-name {
        font-size: 13px;
        font-weight: 700;
        color: var(--dashboard-ink);
        letter-spacing: 0.02em;
    }

    .status-desc {
        display: block;
        margin-top: 2px;
        font-size: 12px;
        color: var(--dashboard-muted);
    }

    .status-value {
        font-size: 24px;
        font-weight: 700;
        line-height: 1;
        white-space: nowrap;
    }

    .insight-list {
        display: grid;
        gap: 14px;
    }

    .insight-card {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 16px;
        border-radius: 20px;
        background: rgba(248, 250, 252, 0.95);
        border: 1px solid var(--dashboard-line);
    }

    .insight-icon {
        width: 42px;
        height: 42px;
        border-radius: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #102542, #1d4ed8);
        color: #fff;
        flex-shrink: 0;
    }

    .insight-title {
        margin: 0 0 4px;
        font-size: 14px;
        font-weight: 700;
    }

    .insight-copy {
        margin: 0;
        font-size: 13px;
        color: var(--dashboard-muted);
        line-height: 1.6;
    }

    .dashboard-empty {
        padding: 24px;
        text-align: center;
        color: var(--dashboard-muted);
        border: 1px dashed rgba(102, 112, 133, 0.35);
        border-radius: 18px;
        background: rgba(248, 250, 252, 0.7);
    }

    @media (max-width: 991.98px) {
        .dashboard-hero {
            padding: 26px 24px;
        }

        .dashboard-title {
            font-size: 28px;
        }

        .status-grid,
        .progress-metrics {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 767.98px) {
        .dashboard-shell {
            padding-top: 4px;
        }

        .dashboard-hero {
            border-radius: 24px;
        }

        .hero-panel {
            margin-top: 18px;
        }

        .metric-card,
        .dashboard-panel {
            border-radius: 20px;
        }

        .panel-head {
            display: block;
        }

        .panel-badge {
            margin-top: 12px;
        }

        .status-grid {
            grid-template-columns: 1fr;
        }

    }
</style>

<div class="container-fluid dashboard-shell">
    <div class="dashboard-hero">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <span class="eyebrow">
                    <i class="fas fa-chart-line"></i>
                    ACR Performance Center
                </span>
                <h2 class="dashboard-title">A cleaner, more visual view of the ACR workflow.</h2>
                <p class="dashboard-subtitle">
                    Track completion, spot pending load quickly, and keep the current review cycle readable at a glance.
                </p>
            </div>
            <div class="col-lg-4">
                <div class="hero-panel">
                    <div class="hero-panel-label">Live Snapshot</div>
                    <div class="hero-panel-value" id="heroCompletionRate">0%</div>
                    <p class="hero-panel-copy" id="heroCompletionCopy">
                        Dashboard metrics will appear here as soon as the summary is loaded.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-4 col-md-6 mb-4">
            <div class="metric-card total">
                <div class="metric-head">
                    <span class="metric-label">Total ACRs</span>
                    <span class="metric-icon"><i class="fas fa-layer-group"></i></span>
                </div>
                <div class="metric-value" id="totalAcrs">0</div>
                <p class="metric-copy">Complete volume of records included in the current dashboard summary.</p>
                <div class="metric-trend">
                    <i class="fas fa-database"></i>
                    Portfolio size
                </div>
            </div>
        </div>

        <div class="col-xl-4 col-md-6 mb-4">
            <div class="metric-card completed">
                <div class="metric-head">
                    <span class="metric-label">Completed</span>
                    <span class="metric-icon"><i class="fas fa-check-circle"></i></span>
                </div>
                <div class="metric-value" id="completedCount">0</div>
                <p class="metric-copy">Records that have moved through the cycle and reached completion.</p>
                <div class="metric-trend">
                    <i class="fas fa-flag-checkered"></i>
                    Closed successfully
                </div>
            </div>
        </div>

        <div class="col-xl-4 col-md-6 mb-4">
            <div class="metric-card pending">
                <div class="metric-head">
                    <span class="metric-label">In Progress</span>
                    <span class="metric-icon"><i class="fas fa-hourglass-half"></i></span>
                </div>
                <div class="metric-value" id="inProgressCount">0</div>
                <p class="metric-copy">Items that still need action somewhere in the approval workflow.</p>
                <div class="metric-trend">
                    <i class="fas fa-stream"></i>
                    Active workload
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-7 mb-4">
            <div class="dashboard-panel progress-card">
                <div class="panel-head">
                    <div>
                        <h4 class="panel-title">Overall progress</h4>
                        <p class="panel-subtitle">A quick pulse check on how much of the ACR pipeline has already been completed.</p>
                    </div>
                    <div class="panel-badge">
                        <i class="fas fa-signal"></i>
                        Updated from live summary
                    </div>
                </div>

                <div class="progress-ring-wrap position-relative">
                    <div class="progress-ring" id="progressRing"></div>
                    <div class="progress-ring-content">
                        <div class="progress-ring-value" id="progressRingValue">0%</div>
                        <div class="progress-ring-caption">Completion</div>
                    </div>
                </div>

                <div class="progress-meter mt-3">
                    <div class="progress-meter-bar" id="progressBar"></div>
                </div>

                <div class="progress-metrics">
                    <div class="progress-metric">
                        <span class="progress-metric-value" id="progressCompletedMini">0</span>
                        <span class="progress-metric-label">Completed</span>
                    </div>
                    <div class="progress-metric">
                        <span class="progress-metric-value" id="progressPendingMini">0</span>
                        <span class="progress-metric-label">Pending</span>
                    </div>
                    <div class="progress-metric">
                        <span class="progress-metric-value" id="progressTotalMini">0</span>
                        <span class="progress-metric-label">Total</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-5 mb-4">
            <div class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h4 class="panel-title">Quick insights</h4>
                        <p class="panel-subtitle">Small summaries that make the numbers easier to read and discuss.</p>
                    </div>
                    <div class="panel-badge">
                        <i class="fas fa-lightbulb"></i>
                        Auto generated
                    </div>
                </div>

                <div class="insight-list">
                    <div class="insight-card">
                        <div class="insight-icon"><i class="fas fa-tasks"></i></div>
                        <div>
                            <h5 class="insight-title">Pending workload</h5>
                            <p class="insight-copy" id="insightPending">Pending distribution will appear here once the summary is available.</p>
                        </div>
                    </div>

                    <div class="insight-card">
                        <div class="insight-icon"><i class="fas fa-star"></i></div>
                        <div>
                            <h5 class="insight-title">Dominant status</h5>
                            <p class="insight-copy" id="insightDominant">The largest status group will be highlighted here.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="dashboard-panel">
                <div class="panel-head">
                    <div>
                        <h4 class="panel-title">Status distribution</h4>
                        <p class="panel-subtitle">Every ACR status is grouped into a more readable card layout for faster scanning.</p>
                    </div>
                    <div class="panel-badge" id="statusBadgeSummary">
                        <i class="fas fa-filter"></i>
                        0 tracked statuses
                    </div>
                </div>

                <div class="status-grid" id="statusDistribution">
                    <div class="dashboard-empty">
                        Status summary is loading.
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var BASE_URL = '<%= Url.Content("~/") %>';

    $(document).ready(function () {
        var token = localStorage.getItem("token");
        if (!token) {
            window.location = BASE_URL + "Login/UserAuth";
        } else {
            loadCurrentUser(token);
            loadDashboardSummary(token);
        }
    });

    function loadCurrentUser(token) {
        if (!token) {
            window.location = BASE_URL + "Login/UserAuth";
            return;
        }

        $.ajax({
            url: BASE_URL + "api/auth/me",
            method: "GET",
            headers: {
                "Authorization": "Bearer " + token
            },
            success: function (res) {
                if (res.Success) {
                    var user = res.Data;
                    localStorage.setItem("displayName", user.DisplayName);
                    localStorage.setItem("role", user.SystemRole);
                    if ($("#displayName").length) {
                        $("#displayName").text(user.DisplayName);
                    }
                    if ($("#userRole").length) {
                        $("#userRole").text(user.SystemRole);
                    }
                }
                else {
                    window.location = BASE_URL + "Login/UserAuth";
                }
            },
            error: function (xhr) {
                if (xhr.status === 401 || xhr.status === 404) {
                    localStorage.clear();
                    window.location = BASE_URL + "Login/UserAuth";
                }
                else {
                    alert("Failed to load user session");
                }
            }
        });
    }

    function loadDashboardSummary(token) {
        $.ajax({
            url: BASE_URL + "api/dashboard/summary",
            method: "GET",
            headers: {
                "Authorization": "Bearer " + token
            },
            success: function (res) {
                if (res.Success) {
                    renderDashboard(res.Data);
                }
                else {
                    console.error("Failed to load dashboard summary:", res.Message);
                    showDashboardFallback("Dashboard summary could not be loaded.");
                }
            },
            error: function (xhr) {
                console.error("Error loading dashboard summary:", xhr);
                showDashboardFallback("There was a problem loading dashboard data.");
            }
        });
    }

    function renderDashboard(data) {
        var totalAcrs = data.TotalAcrs || 0;
        var completed = data.Completion && data.Completion.Completed ? data.Completion.Completed : 0;
        var inProgress = data.Completion && data.Completion.InProgress ? data.Completion.InProgress : 0;
        var rawRate = data.Completion && data.Completion.CompletionRate ? data.Completion.CompletionRate : 0;
        var rate = Math.max(0, Math.min(rawRate, 100));
        var statusMap = data.ByStatus || {};
        var statuses = [];
        var trackedStatusCount = 0;
        var dominantStatus = null;

        $("#totalAcrs").text(totalAcrs);
        $("#completedCount").text(completed);
        $("#inProgressCount").text(inProgress);
        $("#heroCompletionRate").text(formatPercent(rate));
        $("#heroCompletionCopy").text(getHeroCopy(rate, completed, totalAcrs));

        $("#progressRingValue").text(formatPercent(rate));
        $("#progressBar").css("width", rate + "%");
        $("#progressCompletedMini").text(completed);
        $("#progressPendingMini").text(inProgress);
        $("#progressTotalMini").text(totalAcrs);

        updateProgressRing(rate);

        $.each(statusMap, function (status, count) {
            trackedStatusCount++;
            statuses.push({
                key: status,
                count: count,
                meta: getStatusMeta(status)
            });

            if (!dominantStatus || count > dominantStatus.count) {
                dominantStatus = {
                    key: status,
                    count: count
                };
            }
        });

        statuses.sort(function (a, b) {
            return b.count - a.count;
        });

        renderStatusDistribution(statuses);
        $("#statusBadgeSummary").html('<i class="fas fa-filter"></i> ' + trackedStatusCount + ' tracked statuses');

        $("#insightPending").text(getPendingInsight(inProgress, totalAcrs));
        $("#insightDominant").text(getDominantInsight(dominantStatus));
    }

    function renderStatusDistribution(statuses) {
        if (!statuses.length) {
            $("#statusDistribution").html('<div class="dashboard-empty">No status data is available for this dashboard yet.</div>');
            return;
        }

        var statusHtml = "";

        for (var i = 0; i < statuses.length; i++) {
            var item = statuses[i];
            statusHtml += '<div class="status-chip">';
            statusHtml += '  <div class="status-chip-main">';
            statusHtml += '      <span class="status-dot" style="background:' + item.meta.color + ';"></span>';
            statusHtml += '      <div>';
            statusHtml += '          <div class="status-name">' + item.meta.label + '</div>';
            statusHtml += '          <span class="status-desc">' + item.meta.description + '</span>';
            statusHtml += '      </div>';
            statusHtml += '  </div>';
            statusHtml += '  <div class="status-value" style="color:' + item.meta.color + ';">' + item.count + '</div>';
            statusHtml += '</div>';
        }

        $("#statusDistribution").html(statusHtml);
    }

    function updateProgressRing(rate) {
        var degree = Math.round((Math.max(0, Math.min(rate, 100)) / 100) * 360);
        $("#progressRing").css("background", "conic-gradient(#10b981 0deg, #34d399 " + degree + "deg, rgba(148, 163, 184, 0.2) " + degree + "deg 360deg)");
    }

    function formatPercent(value) {
        return Number(value).toFixed(1) + "%";
    }

    function getHeroCopy(rate, completed, total) {
        if (!total) {
            return "No ACR records are available in the current summary yet.";
        }

        if (rate >= 80) {
            return completed + " out of " + total + " ACRs are already complete, which reflects strong delivery momentum.";
        }

        if (rate >= 50) {
            return completed + " out of " + total + " ACRs are complete, and the cycle is moving steadily through the pipeline.";
        }

        return completed + " out of " + total + " ACRs are complete so far, leaving room to accelerate pending reviews.";
    }

    function getPendingInsight(inProgress, total) {
        if (!total) {
            return "Pending workload will become visible when ACR records are available.";
        }

        if (!inProgress) {
            return "There is no active pending workload in the current summary, which suggests the pipeline is clear.";
        }

        return inProgress + " records are still active in the workflow, which is " + formatPercent((inProgress / total) * 100) + " of the overall portfolio.";
    }

    function getDominantInsight(dominantStatus) {
        if (!dominantStatus) {
            return "No dominant status can be identified because the dashboard has not received status data.";
        }

        var meta = getStatusMeta(dominantStatus.key);
        return meta.label + " is the largest status bucket right now with " + dominantStatus.count + " record(s).";
    }

    function getStatusMeta(status) {
        var dictionary = {
            DRAFT: {
                label: "Draft",
                color: "#64748b",
                description: "Started but not yet submitted into the full review chain."
            },
            PENDING_OFFICER: {
                label: "Pending Officer",
                color: "#f59e0b",
                description: "Awaiting action from the officer stage."
            },
            PENDING_REPORTING: {
                label: "Pending Reporting",
                color: "#0ea5e9",
                description: "Queued for reporting authority review."
            },
            PENDING_REVIEWING: {
                label: "Pending Reviewing",
                color: "#8b5cf6",
                description: "Waiting for reviewing authority feedback."
            },
            PENDING_ACCEPTING: {
                label: "Pending Accepting",
                color: "#14b8a6",
                description: "At the final acceptance stage of the process."
            },
            APPROVED: {
                label: "Approved",
                color: "#10b981",
                description: "Fully approved and completed successfully."
            },
            REJECTED: {
                label: "Rejected",
                color: "#ef4444",
                description: "Requires revisit due to rejection in the process."
            }
        };

        return dictionary[status] || {
            label: status.replace(/_/g, " "),
            color: "#475569",
            description: "Tracked in the summary response."
        };
    }

    function showDashboardFallback(message) {
        $("#heroCompletionCopy").text(message);
        $("#statusDistribution").html('<div class="dashboard-empty">' + message + '</div>');
        $("#insightPending").text(message);
        $("#insightDominant").text(message);
    }
</script>
</asp:Content>
