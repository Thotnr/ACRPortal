using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Queue                                                              //
    // ------------------------------------------------------------------ //

    public class MyReviewingQueueItem
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
        public string Status { get; set; }   // always PENDING_REVIEWING
        public bool IsSubmitted { get; set; }   // true if submitted_at is not null
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class MyReviewingQueueResponse
    {
        public List<MyReviewingQueueItem> AcrCycles { get; set; } = new List<MyReviewingQueueItem>();
    }

    // ------------------------------------------------------------------ //
    //  Draft request (Section IV — filled by RvA)                         //
    //                                                                      //
    //  The RvA fills two things:                                           //
    //   1. reviewing_assessments: agree/disagree, comments, overall grade  //
    //   2. reporting_assessments rva_* columns: override grades when       //
    //      they disagree with the RA's numerical assessment                //
    //      (same 15-item grid, only filled when RvA disagrees)             //
    // ------------------------------------------------------------------ //

    public class ReviewingDraftRequest
    {
        // Section IV Item 1
        public bool? AgreeWithRa { get; set; }   // YES/NO
        public string DisagreeDetails { get; set; }   // "In case of difference of opinion..."

        // Section IV Item 3
        public string Comments { get; set; }   // "Comments of Reviewing Authority (if any)"

        // Section IV Item 4
        public decimal? OverallGrade { get; set; }   // 1-10, DECIMAL(4,2)

        // RvA override grades — filled only when AgreeWithRa = false.
        // These map to rva_* columns in reporting_assessments.
        // Send null for any item the RvA agrees with; only override items they dispute.
        public byte? WorkTargets { get; set; }
        public byte? WorkQuality { get; set; }
        public byte? WorkExceptional { get; set; }

        public byte? AttrAttitude { get; set; }
        public byte? AttrResponsibility { get; set; }
        public byte? AttrStability { get; set; }
        public byte? AttrCommunication { get; set; }
        public byte? AttrMoralCourage { get; set; }
        public byte? AttrLeadership { get; set; }
        public byte? AttrTimeliness { get; set; }

        public byte? CompKnowledge { get; set; }
        public byte? CompPlanning { get; set; }
        public byte? CompDecision { get; set; }
        public byte? CompInitiative { get; set; }
        public byte? CompTeamwork { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Read-back views                                                     //
    // ------------------------------------------------------------------ //

    /// <summary>
    /// RvA's own assessment stored in reviewing_assessments.
    /// </summary>
    public class ReviewingAssessmentView
    {
        public bool Exists { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; }   // ISO 8601 | null

        public bool? AgreeWithRa { get; set; }
        public string DisagreeDetails { get; set; }
        public string Comments { get; set; }
        public decimal? OverallGrade { get; set; }
    }

    /// <summary>
    /// RvA's override grades stored in reporting_assessments (rva_* columns).
    /// Only populated when RvA disagreed with the RA's numerical assessment.
    /// </summary>
    public class RvaOverrideGradesView
    {
        public byte? WorkTargets { get; set; }
        public byte? WorkQuality { get; set; }
        public byte? WorkExceptional { get; set; }

        public byte? AttrAttitude { get; set; }
        public byte? AttrResponsibility { get; set; }
        public byte? AttrStability { get; set; }
        public byte? AttrCommunication { get; set; }
        public byte? AttrMoralCourage { get; set; }
        public byte? AttrLeadership { get; set; }
        public byte? AttrTimeliness { get; set; }

        public byte? CompKnowledge { get; set; }
        public byte? CompPlanning { get; set; }
        public byte? CompDecision { get; set; }
        public byte? CompInitiative { get; set; }
        public byte? CompTeamwork { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Detail response                                                     //
    // ------------------------------------------------------------------ //

    public class ReviewingAcrDetailResponse
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

        // Officer's self-appraisal (read-only for RvA)
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();

        // RA1 assessment (read-only for RvA)
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();

        // RA2 assessment (A1b only — read-only for RvA)
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();

        // RvA's own assessment (reviewing_assessments)
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();

        // RvA's override grades (rva_* in reporting_assessments) — null values = agreed with RA
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();
    }
}