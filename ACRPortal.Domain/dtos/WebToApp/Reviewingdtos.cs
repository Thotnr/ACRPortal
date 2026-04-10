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
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }     // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public bool IsSubmitted { get; set; }
        public string CreatedAt { get; set; }     // ISO 8601
    }

    // ------------------------------------------------------------------ //
    //  Draft request                                                      //
    // ------------------------------------------------------------------ //

    public class ReviewingDraftRequest
    {
        public bool? AgreeWithRa { get; set; }
        public string DisagreeDetails { get; set; }
        public string Comments { get; set; }
        public decimal? OverallGrade { get; set; }   // 1-10, DECIMAL(4,2)

        // rva_* override grades — null = agrees with RA's score
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
    //  Detail response — full shape, all sections                         //
    // ------------------------------------------------------------------ //

    public class ReviewingAcrDetailResponse
    {
        // ACR header
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }     // yyyy-MM-dd
        public int AcrYear { get; set; }

        // ------------------------------------------------------------------ //
        //  Section I (CCA) — always visible                                  //
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

        // ------------------------------------------------------------------ //
        //  All sections — populated as the ACR progresses                    //
        // ------------------------------------------------------------------ //
        public OfficerLite Officer { get; set; } = new OfficerLite();
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();

        /// <summary>
        /// Accepting decision — populated once the ACR reaches PENDING_ACCEPTING or beyond.
        /// Exists=false until the AA has viewed/submitted.
        /// </summary>
        public AcceptingDecisionView Decision { get; set; } = new AcceptingDecisionView();

        // ------------------------------------------------------------------ //
        //  Documents                                                          //
        // ------------------------------------------------------------------ //

        /// <summary>CCA documents (section='CCA', excludes OFFICER_PHOTO).</summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();

        /// <summary>Officer photograph uploaded by CCA.</summary>
        public AcrDocumentItem OfficerPhoto { get; set; }

        /// <summary>Documents uploaded by the caller's current step (section='RVA').</summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }
}