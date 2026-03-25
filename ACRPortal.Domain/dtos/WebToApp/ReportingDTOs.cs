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
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }   // always PENDING_REPORTING
        public string ReportingRole { get; set; }   // RA1 | RA2
        public bool IsSubmitted { get; set; }
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class MyReportingQueueResponse
    {
        public List<MyReportingQueueItem> AcrCycles { get; set; } = new List<MyReportingQueueItem>();
    }

    // ------------------------------------------------------------------ //
    //  Draft request                                                       //
    //  DocumentPath removed — documents go through /api/acr/{id}/docs     //
    // ------------------------------------------------------------------ //

    public class ReportingDraftRequest
    {
        // Agreement
        public bool? AgreeWithSelf { get; set; }
        public string DisagreeDetails { get; set; }
        public string IntegrityComments { get; set; }
        public string Remarks { get; set; }

        // Work output (scale 1-10)
        public byte? WorkTargets { get; set; }
        public byte? WorkQuality { get; set; }
        public byte? WorkExceptional { get; set; }
        public decimal? WorkOverall { get; set; }

        // Personal attributes
        public byte? AttrAttitude { get; set; }
        public byte? AttrResponsibility { get; set; }
        public byte? AttrStability { get; set; }
        public byte? AttrCommunication { get; set; }
        public byte? AttrMoralCourage { get; set; }
        public byte? AttrLeadership { get; set; }
        public byte? AttrTimeliness { get; set; }
        public decimal? AttrOverall { get; set; }

        // Functional competency
        public byte? CompKnowledge { get; set; }
        public byte? CompPlanning { get; set; }
        public byte? CompDecision { get; set; }
        public byte? CompInitiative { get; set; }
        public byte? CompTeamwork { get; set; }
        public decimal? CompOverall { get; set; }

        // Overall grade — average of all 15 items, 2 decimal places
        public decimal? OverallGrade { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Assessment read-back view                                          //
    //  DocumentPath removed — documents returned via Documents list       //
    // ------------------------------------------------------------------ //

    public class ReportingAssessmentView
    {
        public bool Exists { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; }   // ISO 8601 | null

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

    // ------------------------------------------------------------------ //
    //  Detail response                                                    //
    //  Documents split by role: Ra1Documents / Ra2Documents              //
    // ------------------------------------------------------------------ //

    public class ReportingAcrDetailResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
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
        public string ReportingRole { get; set; }   // RA1 | RA2
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView ReportingAssessment { get; set; } = new ReportingAssessmentView();

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
        /// Documents uploaded by the caller's current step (section = 'RA1'|'RA2').
        /// </summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }
}