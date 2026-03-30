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
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }   // always PENDING_REVIEWING
        public bool IsSubmitted { get; set; }
        public string CreatedAt { get; set; }   // ISO 8601
    }

    // ------------------------------------------------------------------ //
    //  Draft request                                                      //
    //  DocumentPath removed — documents go through /api/acr/{id}/docs    //
    // ------------------------------------------------------------------ //

    public class ReviewingDraftRequest
    {
        // Section IV Item 1
        public bool? AgreeWithRa { get; set; }
        public string DisagreeDetails { get; set; }

        // Section IV Item 3
        public string Comments { get; set; }

        // Section IV Item 4
        public decimal? OverallGrade { get; set; }   // 1-10, DECIMAL(4,2)

        // RvA override grades — rva_* columns in reporting_assessments
        // Null = agrees with RA's score for that item
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
    //  Read-back views                                                    //
    // ------------------------------------------------------------------ //

    /// <summary>
    /// RvA's own assessment stored in reviewing_assessments.
    /// DocumentPath removed — documents returned via Documents list.
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
    /// Only populated when RvA disagreed with RA's numerical assessment.
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
    //  Detail response                                                    //
    // ------------------------------------------------------------------ //

    public class ReviewingAcrDetailResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }

        // ------------------------------------------------------------------ //
        //  Section I (CCA) — shown to all authorities                         //
        // ------------------------------------------------------------------ //
        public string DateOfBirth { get; set; }
        public string DateJoiningNigam { get; set; }
        public string DateJoiningPresentRank { get; set; }
        public string DateJoiningPresentStation { get; set; }
        public string AcademicQualification { get; set; }
        public string TechnicalQualification { get; set; }
        public string DepartmentalExamPassed { get; set; }
        public string PropertyReturnDate { get; set; }
        public string LastMedicalExamDate { get; set; }
        public string CareerPostingSummary { get; set; }

        public OfficerLite Officer { get; set; } = new OfficerLite();
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();

        /// <summary>
        /// CCA documents for this ACR (section = 'CCA', excludes OFFICER_PHOTO).
        /// Returned consistently across authority detail APIs.
        /// </summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();

        /// <summary>
        /// Officer photograph uploaded by the CCA for this ACR.
        /// </summary>
        public AcrDocumentItem OfficerPhoto { get; set; }

        /// <summary>
        /// Documents uploaded by the caller's current step (section = 'RVA').
        /// </summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }
}