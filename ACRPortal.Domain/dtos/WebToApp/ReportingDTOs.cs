using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class OfficerLite
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
    }

    public class MyReportingQueueItem
    {
        public string AcrId { get; set; }
        public string OfficerName { get; set; }
        public string OfficerLoginId { get; set; }
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; } // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; } // PENDING_REPORTING | PENDING_REPORTING2
        public string ReportingRole { get; set; } // RA1 | RA2
        public bool IsSubmitted { get; set; }
        public string CreatedAt { get; set; } // ISO 8601
    }

    public class MyReportingQueueResponse
    {
        public List<MyReportingQueueItem> AcrCycles { get; set; } = new List<MyReportingQueueItem>();
    }

    public class ReportingDraftRequest
    {
        public bool? AgreeWithSelf { get; set; }
        public string DisagreeDetails { get; set; }
        public string IntegrityComments { get; set; }
        public string Remarks { get; set; }

        public byte? WorkTargets { get; set; }
        public byte? WorkQuality { get; set; }
        public byte? WorkExceptional { get; set; }
        public decimal? WorkOverall { get; set; }

        public byte? AttrAttitude { get; set; }
        public byte? AttrResponsibility { get; set; }
        public byte? AttrStability { get; set; }
        public byte? AttrCommunication { get; set; }
        public byte? AttrMoralCourage { get; set; }
        public byte? AttrLeadership { get; set; }
        public byte? AttrTimeliness { get; set; }
        public decimal? AttrOverall { get; set; }

        public byte? CompKnowledge { get; set; }
        public byte? CompPlanning { get; set; }
        public byte? CompDecision { get; set; }
        public byte? CompInitiative { get; set; }
        public byte? CompTeamwork { get; set; }
        public decimal? CompOverall { get; set; }

        public decimal? OverallGrade { get; set; }
    }

    public class ReportingAssessmentView
    {
        public bool Exists { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; } // ISO 8601 | null

        public bool? AgreeWithSelf { get; set; }
        public string DisagreeDetails { get; set; }
        public string IntegrityComments { get; set; }
        public string Remarks { get; set; }

        public byte? WorkTargets { get; set; }
        public byte? WorkQuality { get; set; }
        public byte? WorkExceptional { get; set; }
        public decimal? WorkOverall { get; set; }

        public byte? AttrAttitude { get; set; }
        public byte? AttrResponsibility { get; set; }
        public byte? AttrStability { get; set; }
        public byte? AttrCommunication { get; set; }
        public byte? AttrMoralCourage { get; set; }
        public byte? AttrLeadership { get; set; }
        public byte? AttrTimeliness { get; set; }
        public decimal? AttrOverall { get; set; }

        public byte? CompKnowledge { get; set; }
        public byte? CompPlanning { get; set; }
        public byte? CompDecision { get; set; }
        public byte? CompInitiative { get; set; }
        public byte? CompTeamwork { get; set; }
        public decimal? CompOverall { get; set; }

        public decimal? OverallGrade { get; set; }
    }

    public class ReportingAcrDetailResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; } // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }

        public OfficerLite Officer { get; set; } = new OfficerLite();
        public string ReportingRole { get; set; } // RA1 | RA2

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView ReportingAssessment { get; set; } = new ReportingAssessmentView();
    }
}

