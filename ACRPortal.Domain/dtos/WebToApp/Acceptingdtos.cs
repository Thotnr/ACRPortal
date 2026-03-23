using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Queue                                                              //
    // ------------------------------------------------------------------ //

    public class MyAcceptingQueueItem
    {
        public string AcrId { get; set; }
        public string OfficerName { get; set; }
        public string OfficerLoginId { get; set; }
        public string FormType { get; set; }   // 'A1a' | 'A1b' | 'A2'
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }   // always PENDING_ACCEPTING
        public bool IsDecided { get; set; }
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class MyAcceptingQueueResponse
    {
        public List<MyAcceptingQueueItem> AcrCycles { get; set; } = new List<MyAcceptingQueueItem>();
    }

    // ------------------------------------------------------------------ //
    //  Decision request (Section V — single submit, no draft)            //
    //  DocumentPath removed — documents go through /api/acr/{id}/docs    //
    // ------------------------------------------------------------------ //

    public class AcceptingDecisionRequest
    {
        // Section V Item 1
        public bool? AgreeWithPrevious { get; set; }
        public string DisagreeDetails { get; set; }   // required when false

        // Section V Item 2
        public bool ConflictResolved { get; set; }

        // Section V Item 3
        public decimal? FinalGrade { get; set; }   // DECIMAL(4,2), 1-10

        // Section V Item 4
        public string FinalRemarks { get; set; }

        // Section V Item 5
        public bool IsApproved { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Read-back view                                                     //
    // ------------------------------------------------------------------ //

    public class AcceptingDecisionView
    {
        public bool Exists { get; set; }
        public bool IsDecided { get; set; }
        public string DecidedAt { get; set; }   // ISO 8601 | null

        public bool? AgreeWithPrevious { get; set; }
        public string DisagreeDetails { get; set; }
        public bool ConflictResolved { get; set; }
        public decimal? FinalGrade { get; set; }
        public string FinalRemarks { get; set; }
        public bool? IsApproved { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Detail response                                                    //
    // ------------------------------------------------------------------ //

    public class AcceptingAcrDetailResponse
    {
        // ACR header
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }

        public OfficerLite Officer { get; set; } = new OfficerLite();
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();
        public AcceptingDecisionView Decision { get; set; } = new AcceptingDecisionView();

        /// <summary>
        /// Documents uploaded by the AA for this ACR (section = 'AA').
        /// </summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();
    }
}