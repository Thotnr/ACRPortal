using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class DashboardSummaryDto
    {
        public int TotalAcrs { get; set; }

        public StatusCounts ByStatus { get; set; }
        public CompletionStats Completion { get; set; }
    }

    public class StatusCounts
    {
        public int DRAFT { get; set; }
        public int PENDING_OFFICER { get; set; }
        public int PENDING_REPORTING { get; set; }
        public int PENDING_REVIEWING { get; set; }
        public int PENDING_ACCEPTING { get; set; }
        public int APPROVED { get; set; }
        public int REJECTED { get; set; }
    }

    public class StageCounts
    {
        public int PendingWithOfficer { get; set; }
        public int PendingWithReporting { get; set; }
        public int PendingWithReviewing { get; set; }
        public int PendingWithAccepting { get; set; }
    }

    public class CompletionStats
    {
        public int Completed { get; set; }
        public int InProgress { get; set; }
        public double CompletionRate { get; set; }
    }
}
