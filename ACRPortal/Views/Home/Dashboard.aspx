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

    .admin-mis-section {
        display: none;
        margin-top: 24px;
    }

    .mis-toolbar {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-end;
        gap: 12px;
        padding: 18px;
        border: 1px solid var(--dashboard-line);
        border-radius: 18px;
        background: rgba(248, 250, 252, 0.92);
        margin-bottom: 18px;
    }

    .mis-filter {
        min-width: 160px;
        flex: 1 1 160px;
    }

    .mis-filter label {
        display: block;
        margin-bottom: 6px;
        font-size: 12px;
        font-weight: 700;
        color: var(--dashboard-muted);
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }

    .mis-filter .form-control {
        min-height: 40px;
        border-radius: 10px;
    }

    .mis-card-grid {
        display: grid;
        grid-template-columns: repeat(6, minmax(0, 1fr));
        gap: 12px;
        margin-bottom: 18px;
    }

    .mis-summary-card {
        padding: 16px;
        border: 1px solid var(--dashboard-line);
        border-radius: 14px;
        background: #fff;
    }

    .mis-summary-label {
        font-size: 12px;
        font-weight: 700;
        color: var(--dashboard-muted);
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }

    .mis-summary-value {
        margin-top: 8px;
        font-size: 28px;
        font-weight: 700;
        color: var(--dashboard-ink);
    }

    .mis-role-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 14px;
    }

    .mis-role-card {
        border: 1px solid var(--dashboard-line);
        border-radius: 14px;
        background: rgba(255, 255, 255, 0.94);
        padding: 16px;
    }

    .mis-role-title {
        margin: 0 0 12px;
        font-size: 15px;
        font-weight: 700;
    }

    .mis-role-metrics {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 8px;
    }

    .mis-role-metric {
        padding: 10px;
        border-radius: 10px;
        background: rgba(241, 245, 249, 0.85);
    }

    .mis-role-metric span {
        display: block;
        font-size: 11px;
        color: var(--dashboard-muted);
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }

    .mis-role-metric strong {
        display: block;
        margin-top: 4px;
        font-size: 20px;
        color: var(--dashboard-ink);
    }

    .mis-chart-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 14px;
    }

    .mis-chart-card {
        border: 1px solid var(--dashboard-line);
        border-radius: 14px;
        background: #fff;
        padding: 16px;
        min-height: 260px;
    }

    .mis-chart-title {
        margin: 0 0 14px;
        font-size: 15px;
        font-weight: 700;
    }

    .mis-bar-row {
        display: grid;
        grid-template-columns: minmax(96px, 132px) 1fr 44px;
        gap: 10px;
        align-items: center;
        margin-bottom: 10px;
        font-size: 12px;
    }

    .mis-bar-track {
        height: 10px;
        border-radius: 999px;
        background: rgba(148, 163, 184, 0.18);
        overflow: hidden;
    }

    .mis-bar-fill {
        height: 100%;
        border-radius: 999px;
        background: linear-gradient(90deg, #1d4ed8, #06b6d4);
    }

    .mis-table-wrap {
        overflow-x: auto;
        border: 1px solid var(--dashboard-line);
        border-radius: 14px;
        background: #fff;
    }

    .mis-table {
        width: 100%;
        min-width: 1560px;
        margin: 0;
        border-collapse: collapse;
    }

    .mis-table th {
        background: #102542;
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        white-space: nowrap;
    }

    .mis-table th,
    .mis-table td {
        padding: 11px 12px;
        border-bottom: 1px solid var(--dashboard-line);
        vertical-align: top;
        font-size: 12px;
    }

    .mis-badge {
        display: inline-flex;
        align-items: center;
        padding: 5px 9px;
        border-radius: 999px;
        background: rgba(29, 78, 216, 0.1);
        color: #1d4ed8;
        font-size: 11px;
        font-weight: 700;
        white-space: nowrap;
    }

    .mis-badge.warn {
        background: rgba(245, 158, 11, 0.12);
        color: #b45309;
    }

    .mis-badge.ok {
        background: rgba(16, 185, 129, 0.12);
        color: #047857;
    }

    .mis-badge.danger {
        background: rgba(239, 68, 68, 0.12);
        color: #b91c1c;
    }

    .mis-pager {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        margin-top: 14px;
        color: var(--dashboard-muted);
        font-size: 13px;
    }

    .mis-loading {
        opacity: 0.55;
        pointer-events: none;
    }

    .mis-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 16px;
        border-bottom: 1px solid var(--dashboard-line);
    }

    .mis-tab-btn {
        border: 0;
        border-radius: 12px 12px 0 0;
        background: rgba(241, 245, 249, 0.9);
        color: var(--dashboard-muted);
        font-weight: 700;
        padding: 12px 16px;
        cursor: pointer;
    }

    .mis-tab-btn.active {
        background: #102542;
        color: #fff;
    }

    .mis-tab-panel {
        display: none;
    }

    .mis-tab-panel.active {
        display: block;
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

        .mis-card-grid,
        .mis-role-grid,
        .mis-chart-grid {
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

    <div class="admin-mis-section" id="adminMisSection">
        <div class="dashboard-panel">
            <div class="panel-head">
                <div>
                    <h4 class="panel-title">Admin ACR MIS Report</h4>
                    <p class="panel-subtitle">Role-wise lifecycle view across CCA, Officer, Reporting, Reviewing, Accepting, and final decisions.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="downloadMisExcel()">
                        <i class="fas fa-file-excel"></i> Download MIS Report
                    </button>
                </div>
            </div>

            <div class="mis-tabs" role="tablist" aria-label="Admin MIS tabs">
                <button type="button" class="mis-tab-btn active" data-mis-tab="summary" onclick="switchMisTab('summary')">Summary</button>
                <button type="button" class="mis-tab-btn" data-mis-tab="role" onclick="switchMisTab('role')">Role-wise MIS</button>
                <button type="button" class="mis-tab-btn" data-mis-tab="details" onclick="switchMisTab('details')">Application Details</button>
            </div>

            <div class="mis-tab-panel active" id="misTabSummary">
                <div class="mis-toolbar">
                    <div class="mis-filter"><label for="misSummaryYear">ACR Year</label><select id="misSummaryYear" class="form-control mis-year"></select></div>
                    <div class="mis-filter"><label for="misSummaryFormType">Form Type</label><select id="misSummaryFormType" class="form-control mis-form"></select></div>
                    <div class="mis-filter"><label for="misSummaryLocation">Location</label><select id="misSummaryLocation" class="form-control mis-location"></select></div>
                    <div class="mis-filter"><label for="misSummaryEmployee">Employee</label><select id="misSummaryEmployee" class="form-control mis-employee"></select></div>
                    <div class="mis-filter"><label for="misSummaryStatus">Current Status</label><select id="misSummaryStatus" class="form-control mis-status"></select></div>
                    <div>
                        <button type="button" class="btn btn-primary btn-sm" onclick="applyMisFilters('summary')"><i class="fas fa-filter"></i> Apply</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="resetMisFilters('summary')">Reset</button>
                    </div>
                </div>
                <div id="misSummaryLoading" class="dashboard-empty">Summary is loading.</div>
                <div id="misSummaryContent" style="display:none;">
                    <div class="mis-card-grid" id="misSummaryCards"></div>
                    <div class="mis-chart-grid mb-4">
                        <div class="mis-chart-card"><h5 class="mis-chart-title">Current Status Distribution</h5><div id="misStatusChart"></div></div>
                        <div class="mis-chart-card"><h5 class="mis-chart-title">Approved vs Rejected</h5><div id="misDecisionChart"></div></div>
                        <div class="mis-chart-card"><h5 class="mis-chart-title">Pending Aging</h5><div id="misAgingChart"></div></div>
                    </div>
                </div>
            </div>

            <div class="mis-tab-panel" id="misTabRole">
                <div class="mis-toolbar">
                    <div class="mis-filter"><label for="misRoleYear">ACR Year</label><select id="misRoleYear" class="form-control mis-year"></select></div>
                    <div class="mis-filter"><label for="misRoleFormType">Form Type</label><select id="misRoleFormType" class="form-control mis-form"></select></div>
                    <div class="mis-filter"><label for="misRoleLocation">Location</label><select id="misRoleLocation" class="form-control mis-location"></select></div>
                    <div class="mis-filter"><label for="misRoleEmployee">Employee / Manager</label><select id="misRoleEmployee" class="form-control mis-employee"></select></div>
                    <div class="mis-filter"><label for="misRoleStatus">Current Status</label><select id="misRoleStatus" class="form-control mis-status"></select></div>
                    <div>
                        <button type="button" class="btn btn-primary btn-sm" onclick="applyMisFilters('role')"><i class="fas fa-filter"></i> Apply</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="resetMisFilters('role')">Reset</button>
                    </div>
                </div>
                <div id="misRoleLoading" class="dashboard-empty">Role-wise MIS is loading.</div>
                <div id="misRoleContent" style="display:none;">
                    <div class="row">
                        <div class="col-xl-8 mb-4"><div class="mis-role-grid" id="misRoleCards"></div></div>
                        <div class="col-xl-4 mb-4"><div class="mis-chart-card"><h5 class="mis-chart-title">Role-wise Pending Applications</h5><div id="misPendingChart"></div></div></div>
                    </div>
                </div>
            </div>

            <div class="mis-tab-panel" id="misTabDetails">
                <div class="mis-toolbar">
                    <div class="mis-filter"><label for="misDetailsYear">ACR Year</label><select id="misDetailsYear" class="form-control mis-year"></select></div>
                    <div class="mis-filter"><label for="misDetailsFormType">Form Type</label><select id="misDetailsFormType" class="form-control mis-form"></select></div>
                    <div class="mis-filter"><label for="misDetailsLocation">Location</label><select id="misDetailsLocation" class="form-control mis-location"></select></div>
                    <div class="mis-filter"><label for="misDetailsEmployee">Employee</label><select id="misDetailsEmployee" class="form-control mis-employee"></select></div>
                    <div class="mis-filter"><label for="misDetailsStatus">Current Status</label><select id="misDetailsStatus" class="form-control mis-status"></select></div>
                    <div class="mis-filter"><label for="misDetailsSearch">Search ACR / Employee</label><input type="text" id="misDetailsSearch" class="form-control" placeholder="ACR ID or employee name"></div>
                    <div>
                        <button type="button" class="btn btn-primary btn-sm" onclick="applyMisFilters('details')"><i class="fas fa-filter"></i> Apply</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="resetMisFilters('details')">Reset</button>
                    </div>
                </div>
                <div id="misDetailsLoading" class="dashboard-empty">Application details are loading.</div>
                <div id="misDetailsContent" style="display:none;">

                <div class="panel-head">
                    <div>
                        <h4 class="panel-title">Detailed application-wise MIS</h4>
                        <p class="panel-subtitle">One row per ACR application with current pending owner and stage age.</p>
                    </div>
                    <div class="panel-badge" id="misGridTotal"><i class="fas fa-table"></i> 0 records</div>
                </div>

                <div class="mis-table-wrap">
                    <table class="mis-table">
                        <thead>
                            <tr>
                                <th>ACR ID</th>
                                <th>Employee</th>
                                <th>Designation</th>
                                <th>Form</th>
                                <th>Year</th>
                                <th>Location</th>
                                <th>CCA</th>
                                <th>RM1</th>
                                <th>RM2</th>
                                <th>Reviewing</th>
                                <th>Accepting</th>
                                <th>Status</th>
                                <th>CCA Submitted</th>
                                <th>Officer Submitted</th>
                                <th>RM1 Submitted</th>
                                <th>RM2 Submitted</th>
                                <th>Reviewing Submitted</th>
                                <th>Decision Date</th>
                                <th>Decision</th>
                                <th>Pending With</th>
                                <th>Age</th>
                                <th>Skipped</th>
                            </tr>
                        </thead>
                        <tbody id="misDetailBody"></tbody>
                    </table>
                </div>
                <div class="mis-pager">
                    <span id="misPageInfo">Page 1</span>
                    <div>
                        <button type="button" class="btn btn-outline-secondary btn-sm" id="misPrevBtn" onclick="goMisPage(-1)">Previous</button>
                        <button type="button" class="btn btn-outline-secondary btn-sm" id="misNextBtn" onclick="goMisPage(1)">Next</button>
                    </div>
                </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var BASE_URL = '<%= Url.Content("~/") %>';
    var misCurrentPage = 1;
    var misPageSize = 10;
    var misTotalPages = 1;
    var misInitialized = false;
    var activeMisTab = "summary";
    var misCache = {};

    $(document).ready(function () {
        var token = localStorage.getItem("token");
        if (!token) {
            window.location = BASE_URL + "Login/UserAuth";
        } else {
            loadCurrentUser(token);
            loadDashboardSummary(token);
            if (localStorage.getItem("role") === "ADMIN") {
                initializeMis(token);
            }
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
                    if (user.SystemRole === "ADMIN") {
                        initializeMis(token);
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

    function loadMisFilters(token) {
        $.ajax({
            url: BASE_URL + "api/admin/acr-mis/filters",
            method: "GET",
            headers: { "Authorization": "Bearer " + token },
            success: function (res) {
                if (!res.Success) return;
                var data = res.Data || {};
                fillSelect(".mis-year", data.AcrYears || [], "All Years", function (x) { return x; }, function (x) { return x; });
                fillSelect(".mis-form", data.FormTypes || [], "All Forms", function (x) { return x; }, function (x) { return x; });
                fillSelect(".mis-location", data.Locations || [], "All Locations", function (x) { return x; }, function (x) { return x; });
                fillSelect(".mis-status", data.Statuses || [], "All Statuses", function (x) { return x; }, function (x) { return x; });
                fillSelect(".mis-employee", data.Employees || [], "All Employees",
                    function (x) { return x.UserId; },
                    function (x) { return (x.DisplayName || x.LoginId || "Employee") + (x.LoginId ? " (" + x.LoginId + ")" : ""); });
            }
        });
    }

    function initializeMis(token) {
        if (misInitialized) return;
        misInitialized = true;
        $("#adminMisSection").show();
        loadMisFilters(token);
        loadMisReport(token);
    }

    function fillSelect(selector, items, emptyText, valueFn, textFn) {
        var html = '<option value="">' + emptyText + '</option>';
        for (var i = 0; i < items.length; i++) {
            html += '<option value="' + escapeHtml(valueFn(items[i])) + '">' + escapeHtml(textFn(items[i])) + '</option>';
        }
        $(selector).html(html);
    }

    function switchMisTab(tab) {
        activeMisTab = tab;
        $(".mis-tab-btn").removeClass("active");
        $('.mis-tab-btn[data-mis-tab="' + tab + '"]').addClass("active");
        $(".mis-tab-panel").removeClass("active");
        $("#misTab" + capitalizeMisTab(tab)).addClass("active");

        if (!misCache[getMisCacheKey(tab)]) {
            if (tab === "details") misCurrentPage = 1;
            loadMisReport(localStorage.getItem("token"), tab);
        }
    }

    function applyMisFilters(tab) {
        tab = tab || activeMisTab;
        if (tab === "details") misCurrentPage = 1;
        loadMisReport(localStorage.getItem("token"), tab, true);
    }

    function resetMisFilters(tab) {
        tab = tab || activeMisTab;
        getTabPanel(tab).find("select").val("");
        getTabPanel(tab).find("input").val("");
        applyMisFilters(tab);
    }

    function goMisPage(delta) {
        var target = misCurrentPage + delta;
        if (target < 1 || target > misTotalPages) return;
        misCurrentPage = target;
        loadMisReport(localStorage.getItem("token"), "details", true);
    }

    function getMisQuery(includePaging, tab) {
        tab = tab || activeMisTab;
        var ids = getTabIds(tab);
        var params = [];
        appendQuery(params, "acrYear", $("#" + ids.year).val());
        appendQuery(params, "formType", $("#" + ids.form).val());
        appendQuery(params, "location", $("#" + ids.location).val());
        appendQuery(params, "employeeUserId", $("#" + ids.employee).val());
        appendQuery(params, "status", $("#" + ids.status).val());
        if (ids.search) appendQuery(params, "search", $("#" + ids.search).val());
        if (includePaging) {
            appendQuery(params, "pageNumber", tab === "details" ? misCurrentPage : 1);
            appendQuery(params, "pageSize", misPageSize);
        }
        return params.length ? "?" + params.join("&") : "";
    }

    function appendQuery(params, key, value) {
        if (value !== null && value !== undefined && value !== "") {
            params.push(encodeURIComponent(key) + "=" + encodeURIComponent(value));
        }
    }

    function loadMisReport(token, tab, forceReload) {
        if (!token) return;
        tab = tab || activeMisTab;
        var cacheKey = getMisCacheKey(tab);
        if (!forceReload && misCache[cacheKey]) {
            renderMisReport(misCache[cacheKey], tab);
            return;
        }

        setMisLoading(tab, true, null);
        $.ajax({
            url: BASE_URL + "api/admin/acr-mis" + getMisQuery(true, tab),
            method: "GET",
            headers: { "Authorization": "Bearer " + token },
            success: function (res) {
                if (res.Success) {
                    misCache[cacheKey] = res.Data || {};
                    renderMisReport(misCache[cacheKey], tab);
                    setMisLoading(tab, false, null);
                } else {
                    setMisLoading(tab, true, res.Message || "MIS report could not be loaded.");
                }
            },
            error: function (xhr) {
                var message = xhr.status === 403 ? "Only Admin users can access MIS data." : "MIS report could not be loaded.";
                setMisLoading(tab, true, message);
            }
        });
    }

    function renderMisReport(data, tab) {
        tab = tab || activeMisTab;
        var charts = data.Charts || {};
        if (tab === "summary") {
            renderMisSummary(data.Summary || {});
            renderBarChart("#misStatusChart", charts.StatusDistribution || []);
            renderBarChart("#misDecisionChart", charts.ApprovedVsRejected || []);
            renderBarChart("#misAgingChart", charts.PendingAging || []);
        } else if (tab === "role") {
            renderMisRoles(data.RoleWise || []);
            renderBarChart("#misPendingChart", charts.RoleWisePending || []);
        } else {
            renderMisDetails(data.Details || {});
        }
    }

    function setMisLoading(tab, isLoading, message) {
        var prefix = capitalizeMisTab(tab);
        var loading = $("#mis" + prefix + "Loading");
        var content = $("#mis" + prefix + "Content");
        if (isLoading) {
            loading.show().text(message || "MIS data is loading.");
            content.hide().removeClass("mis-loading");
        } else {
            loading.hide();
            content.show().removeClass("mis-loading");
        }
    }

    function getMisCacheKey(tab) {
        return tab + "|" + getMisQuery(true, tab);
    }

    function getTabPanel(tab) {
        return $("#misTab" + capitalizeMisTab(tab));
    }

    function getTabIds(tab) {
        if (tab === "role") {
            return { year: "misRoleYear", form: "misRoleFormType", location: "misRoleLocation", employee: "misRoleEmployee", status: "misRoleStatus" };
        }
        if (tab === "details") {
            return { year: "misDetailsYear", form: "misDetailsFormType", location: "misDetailsLocation", employee: "misDetailsEmployee", status: "misDetailsStatus", search: "misDetailsSearch" };
        }
        return { year: "misSummaryYear", form: "misSummaryFormType", location: "misSummaryLocation", employee: "misSummaryEmployee", status: "misSummaryStatus" };
    }

    function capitalizeMisTab(tab) {
        if (tab === "role") return "Role";
        if (tab === "details") return "Details";
        return "Summary";
    }

    function renderMisSummary(summary) {
        var cards = [
            ["Total ACR", summary.TotalAcr || 0],
            ["Draft", summary.Draft || 0],
            ["In Workflow", summary.InWorkflow || 0],
            ["Approved", summary.Approved || 0],
            ["Rejected", summary.Rejected || 0],
            ["Auto Forwarded", summary.AutoForwarded || 0]
        ];
        var html = "";
        for (var i = 0; i < cards.length; i++) {
            html += '<div class="mis-summary-card"><div class="mis-summary-label">' + escapeHtml(cards[i][0]) + '</div><div class="mis-summary-value">' + cards[i][1] + '</div></div>';
        }
        $("#misSummaryCards").html(html);
    }

    function renderMisRoles(roles) {
        if (!roles.length) {
            $("#misRoleCards").html('<div class="dashboard-empty">No role-wise MIS data found.</div>');
            return;
        }

        var html = "";
        for (var i = 0; i < roles.length; i++) {
            var role = roles[i];
            var metrics = getRoleMetrics(role);
            html += '<div class="mis-role-card">';
            html += '<h5 class="mis-role-title">' + escapeHtml(role.RoleName || role.RoleKey) + '</h5>';
            html += '<div class="mis-role-metrics">';
            for (var j = 0; j < metrics.length; j++) {
                html += '<div class="mis-role-metric"><span>' + escapeHtml(metrics[j][0]) + '</span><strong>' + metrics[j][1] + '</strong></div>';
            }
            html += '</div></div>';
        }
        $("#misRoleCards").html(html);
    }

    function getRoleMetrics(role) {
        if (role.RoleKey === "CCA") {
            return [["Created", role.Created || 0], ["Draft", role.Draft || 0], ["Submitted", role.Submitted || 0]];
        }
        if (role.RoleKey === "ACCEPTING") {
            return [["Received", role.Received || 0], ["Approved", role.Approved || 0], ["Pending", role.Pending || 0], ["Rejected", role.Rejected || 0]];
        }
        if (role.RoleKey === "OFFICER") {
            return [["Received", role.Received || 0], ["Submitted", role.Submitted || 0], ["Pending", role.Pending || 0], ["Auto Fwd", role.AutoForwarded || 0]];
        }
        return [["Received", role.Received || 0], ["Completed", role.Completed || 0], ["Pending", role.Pending || 0], ["Auto Fwd", role.AutoForwarded || 0]];
    }

    function renderBarChart(selector, items) {
        if (!items.length) {
            $(selector).html('<div class="dashboard-empty">No chart data.</div>');
            return;
        }
        var max = 0;
        for (var i = 0; i < items.length; i++) max = Math.max(max, items[i].Value || 0);
        var html = "";
        for (var j = 0; j < items.length; j++) {
            var value = items[j].Value || 0;
            var width = max ? Math.max(4, Math.round((value / max) * 100)) : 0;
            html += '<div class="mis-bar-row">';
            html += '<div title="' + escapeHtml(items[j].Label) + '">' + escapeHtml(shortText(items[j].Label, 20)) + '</div>';
            html += '<div class="mis-bar-track"><div class="mis-bar-fill" style="width:' + width + '%"></div></div>';
            html += '<strong>' + value + '</strong>';
            html += '</div>';
        }
        $(selector).html(html);
    }

    function renderMisDetails(details) {
        var items = details.Items || [];
        misCurrentPage = details.PageNumber || 1;
        misTotalPages = details.TotalPages || 1;
        $("#misGridTotal").html('<i class="fas fa-table"></i> ' + (details.TotalCount || 0) + ' records');
        $("#misPageInfo").text("Page " + misCurrentPage + " of " + misTotalPages);
        $("#misPrevBtn").prop("disabled", misCurrentPage <= 1);
        $("#misNextBtn").prop("disabled", misCurrentPage >= misTotalPages);

        if (!items.length) {
            $("#misDetailBody").html('<tr><td colspan="22"><div class="dashboard-empty">No applications matched the selected filters.</div></td></tr>');
            return;
        }

        var html = "";
        for (var i = 0; i < items.length; i++) {
            var x = items[i];
            html += '<tr>';
            html += '<td>' + escapeHtml(shortText(x.AcrId, 8)) + '</td>';
            html += '<td><strong>' + escapeHtml(x.EmployeeName || "-") + '</strong><br><span class="text-muted">' + escapeHtml(x.EmployeeLoginId || "") + '</span></td>';
            html += '<td>' + escapeHtml(x.Designation || "-") + '</td>';
            html += '<td>' + escapeHtml(x.FormType || "-") + '</td>';
            html += '<td>' + escapeHtml(x.AcrYear || "-") + '</td>';
            html += '<td>' + escapeHtml(x.Location || "-") + '</td>';
            html += '<td>' + escapeHtml(x.CcaName || "-") + '</td>';
            html += '<td>' + escapeHtml(x.ReportingManager1Name || "-") + '</td>';
            html += '<td>' + escapeHtml(x.ReportingManager2Name || "N/A") + '</td>';
            html += '<td>' + escapeHtml(x.ReviewingManagerName || "-") + '</td>';
            html += '<td>' + escapeHtml(x.AcceptingManagerName || "-") + '</td>';
            html += '<td>' + statusBadge(x.CurrentStatus) + '</td>';
            html += '<td>' + escapeHtml(x.CcaSubmittedDate || "-") + '</td>';
            html += '<td>' + escapeHtml(x.OfficerSubmittedDate || "-") + '</td>';
            html += '<td>' + escapeHtml(x.Rm1SubmittedDate || "-") + '</td>';
            html += '<td>' + escapeHtml(x.Rm2SubmittedDate || "-") + '</td>';
            html += '<td>' + escapeHtml(x.ReviewingSubmittedDate || "-") + '</td>';
            html += '<td>' + escapeHtml(x.AcceptingDecisionDate || "-") + '</td>';
            html += '<td>' + decisionBadge(x.FinalDecision) + '</td>';
            html += '<td>' + escapeHtml(x.CurrentPendingWith || "-") + '</td>';
            html += '<td><span class="mis-badge warn">' + escapeHtml(x.CurrentStageAgeBucket || "-") + '</span><br>' + (x.CurrentStageAgeDays || 0) + ' day(s)</td>';
            html += '<td>' + (x.IsAutoForwarded ? '<span class="mis-badge warn">' + escapeHtml(x.AutoForwardedStages || "Yes") + '</span>' : '<span class="mis-badge ok">No</span>') + '</td>';
            html += '</tr>';
        }
        $("#misDetailBody").html(html);
    }

    function statusBadge(status) {
        var meta = getStatusMeta(status || "");
        return '<span class="mis-badge" style="background:' + meta.color + '22;color:' + meta.color + '">' + escapeHtml(meta.label) + '</span>';
    }

    function decisionBadge(decision) {
        if (decision === "Approved") return '<span class="mis-badge ok">Approved</span>';
        if (decision === "Rejected") return '<span class="mis-badge danger">Rejected</span>';
        return '<span class="mis-badge warn">Pending</span>';
    }

    function downloadMisExcel() {
        var token = localStorage.getItem("token");
        if (!token) return;
        var tab = activeMisTab;
        var query = getMisQuery(false, tab);
        query += (query ? "&" : "?") + "tab=" + encodeURIComponent(tab);
        var xhr = new XMLHttpRequest();
        xhr.open("GET", BASE_URL + "api/admin/acr-mis/excel" + query, true);
        xhr.setRequestHeader("Authorization", "Bearer " + token);
        xhr.responseType = "blob";
        xhr.onload = function () {
            if (xhr.status !== 200) {
                alert(xhr.status === 403 ? "Only Admin users can download the MIS Report." : "Unable to download MIS Report.");
                return;
            }
            var blob = new Blob([xhr.response], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
            var url = window.URL.createObjectURL(blob);
            var a = document.createElement("a");
            a.href = url;
            a.download = misTabFileName(tab);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        };
        xhr.onerror = function () { alert("Unable to download MIS Report."); };
        xhr.send();
    }

    function misTabFileName(tab) {
        if (tab === "role") return "ACR_MIS_RoleWise.xlsx";
        if (tab === "details") return "ACR_MIS_ApplicationDetails.xlsx";
        return "ACR_MIS_Summary.xlsx";
    }

    function shortText(value, length) {
        value = value === null || value === undefined ? "" : String(value);
        if (value.length <= length) return value;
        return value.substring(0, Math.max(0, length - 3)) + "...";
    }

    function escapeHtml(value) {
        value = value === null || value === undefined ? "" : String(value);
        return value
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function showDashboardFallback(message) {
        $("#heroCompletionCopy").text(message);
        $("#statusDistribution").html('<div class="dashboard-empty">' + message + '</div>');
        $("#insightPending").text(message);
        $("#insightDominant").text(message);
    }
</script>
</asp:Content>
