using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class AcrMisFilterRequest
    {
        public int? AcrYear { get; set; }
        public string FormType { get; set; }
        public string Location { get; set; }
        public string EmployeeUserId { get; set; }
        public string Status { get; set; }
        public string Search { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
    }

    public class AcrMisReportResponse
    {
        public AcrMisSummary Summary { get; set; } = new AcrMisSummary();
        public List<AcrMisRoleSummary> RoleWise { get; set; } = new List<AcrMisRoleSummary>();
        public AcrMisCharts Charts { get; set; } = new AcrMisCharts();
        public PagedResult<AcrMisDetailItem> Details { get; set; } = new PagedResult<AcrMisDetailItem>();
        public AcrMisAppliedFilters AppliedFilters { get; set; } = new AcrMisAppliedFilters();
    }

    public class AcrMisFiltersResponse
    {
        public List<int> AcrYears { get; set; } = new List<int>();
        public List<string> FormTypes { get; set; } = new List<string>();
        public List<string> Locations { get; set; } = new List<string>();
        public List<AcrMisEmployeeOption> Employees { get; set; } = new List<AcrMisEmployeeOption>();
        public List<string> Statuses { get; set; } = new List<string>();
    }

    public class AcrMisEmployeeOption
    {
        public string UserId { get; set; }
        public string DisplayName { get; set; }
        public string LoginId { get; set; }
    }

    public class AcrMisAppliedFilters
    {
        public string AcrYear { get; set; }
        public string FormType { get; set; }
        public string Location { get; set; }
        public string Employee { get; set; }
        public string Status { get; set; }
        public string Search { get; set; }
    }

    public class AcrMisSummary
    {
        public int TotalAcr { get; set; }
        public int Draft { get; set; }
        public int InWorkflow { get; set; }
        public int Approved { get; set; }
        public int Rejected { get; set; }
        public int AutoForwarded { get; set; }
    }

    public class AcrMisRoleSummary
    {
        public string RoleKey { get; set; }
        public string RoleName { get; set; }
        public int Created { get; set; }
        public int Draft { get; set; }
        public int Submitted { get; set; }
        public int Received { get; set; }
        public int Completed { get; set; }
        public int Pending { get; set; }
        public int AutoForwarded { get; set; }
        public int Approved { get; set; }
        public int Rejected { get; set; }
    }

    public class AcrMisCharts
    {
        public List<AcrMisChartItem> StatusDistribution { get; set; } = new List<AcrMisChartItem>();
        public List<AcrMisChartItem> RoleWisePending { get; set; } = new List<AcrMisChartItem>();
        public List<AcrMisChartItem> ApprovedVsRejected { get; set; } = new List<AcrMisChartItem>();
        public List<AcrMisChartItem> PendingAging { get; set; } = new List<AcrMisChartItem>();
    }

    public class AcrMisChartItem
    {
        public string Label { get; set; }
        public int Value { get; set; }
    }

    public class AcrMisDetailItem
    {
        public string AcrId { get; set; }
        public string EmployeeName { get; set; }
        public string EmployeeLoginId { get; set; }
        public string Designation { get; set; }
        public string FormType { get; set; }
        public int AcrYear { get; set; }
        public string Location { get; set; }
        public string CcaName { get; set; }
        public string ReportingManager1Name { get; set; }
        public string ReportingManager2Name { get; set; }
        public string ReviewingManagerName { get; set; }
        public string AcceptingManagerName { get; set; }
        public string CurrentStatus { get; set; }
        public string CcaSubmittedDate { get; set; }
        public string OfficerSubmittedDate { get; set; }
        public string Rm1SubmittedDate { get; set; }
        public string Rm2SubmittedDate { get; set; }
        public string ReviewingSubmittedDate { get; set; }
        public string AcceptingDecisionDate { get; set; }
        public string FinalDecision { get; set; }
        public string CurrentPendingWith { get; set; }
        public int CurrentStageAgeDays { get; set; }
        public string CurrentStageAgeBucket { get; set; }
        public bool IsAutoForwarded { get; set; }
        public string AutoForwardedStages { get; set; }
    }
}
