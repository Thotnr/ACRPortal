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
        public bool IsDecided { get; set; }   // true if decided_at is not null
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class MyAcceptingQueueResponse
    {
        public List<MyAcceptingQueueItem> AcrCycles { get; set; } = new List<MyAcceptingQueueItem>();
    }

    // ------------------------------------------------------------------ //
    //  Decision request (Section V — single submit, no draft)             //
    //                                                                      //
    //  The AA reviews everything and issues a final decision in one step.  //
    //  There is no draft — calling the submit endpoint writes and closes.  //
    // ------------------------------------------------------------------ //

    public class AcceptingDecisionRequest
    {
        // Section V Item 1
        public bool? AgreeWithPrevious { get; set; }   // agree with RvA assessment?
        public string DisagreeDetails { get; set; }   // "In case of difference..." — required when false

        // Section V Item 2
        public bool ConflictResolved { get; set; }   // was any conflict between RA and RvA resolved?

        // Section V Item 3
        public decimal? FinalGrade { get; set; }   // DECIMAL(4,2), 1-10

        // Section V Item 4
        public string FinalRemarks { get; set; }   // "Final remarks of Accepting Authority"

        // Section V Item 5 — the actual decision
        public bool IsApproved { get; set; }   // true = APPROVED, false = REJECTED
    }

    // ------------------------------------------------------------------ //
    //  Read-back view                                                      //
    // ------------------------------------------------------------------ //

    public class AcceptingDecisionView
    {
        public bool Exists { get; set; }
        public bool IsDecided { get; set; }   // true if decided_at is not null
        public string DecidedAt { get; set; }   // ISO 8601 | null

        public bool? AgreeWithPrevious { get; set; }
        public string DisagreeDetails { get; set; }
        public bool ConflictResolved { get; set; }
        public decimal? FinalGrade { get; set; }
        public string FinalRemarks { get; set; }
        public bool? IsApproved { get; set; }   // null until decided
    }

    // ------------------------------------------------------------------ //
    //  Detail response                                                     //
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

        // Officer identity
        public OfficerLite Officer { get; set; } = new OfficerLite();

        // Officer's self-appraisal (read-only for AA)
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();

        // RA1 assessment (read-only for AA)
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();

        // RA2 assessment (A1b only — read-only for AA)
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();

        // RvA override grades (read-only for AA)
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();

        // RvA's review (read-only for AA)
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();

        // AA's own decision
        public AcceptingDecisionView Decision { get; set; } = new AcceptingDecisionView();
    }
}