using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Officer list item                                                   //
    // ------------------------------------------------------------------ //

    public class MyAcrListItem
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }     // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public bool SelfAppraisalSubmitted { get; set; }
        public string CreatedAt { get; set; }     // ISO 8601
    }

    // ------------------------------------------------------------------ //
    //  Self-appraisal draft request (Officer → Section II)               //
    // ------------------------------------------------------------------ //

    public class SelfAppraisalDraftRequest
    {
        public string LeaveDetails { get; set; }
        public string DutiesDescription { get; set; }
        public string TargetsSet { get; set; }
        public string TargetsAchieved { get; set; }
        public string ShortfallReasons { get; set; }
        public string MajorAchievements { get; set; }
        public string MembershipBodies { get; set; }
        public string TrainingDetails { get; set; }
        public string AwardsHonours { get; set; }
        public bool? AuditorCompliance { get; set; }   // null for A1a/A2
        public string PropertyDeclared { get; set; }
        public string PropertyDeclaredDate { get; set; }   // yyyy-MM-dd
        public string MedicalCompliance { get; set; }
        public string MedicalComplianceDate { get; set; }  // yyyy-MM-dd
    }

    // ------------------------------------------------------------------ //
    //  Self-appraisal read-back                                           //
    // ------------------------------------------------------------------ //

    public class SelfAppraisalView
    {   
        public bool Exists { get; set; }
        public bool? IsSkipped { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; }   // ISO 8601 | null

        public string LeaveDetails { get; set; }
        public string DutiesDescription { get; set; }
        public string TargetsSet { get; set; }
        public string TargetsAchieved { get; set; }
        public string ShortfallReasons { get; set; }
        public string MajorAchievements { get; set; }
        public string MembershipBodies { get; set; }
        public string TrainingDetails { get; set; }
        public string AwardsHonours { get; set; }
        public bool? AuditorCompliance { get; set; }
        public string PropertyDeclared { get; set; }
        public string PropertyDeclaredDate { get; set; }
        public string MedicalCompliance { get; set; }
        public string MedicalComplianceDate { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Officer ACR detail response — full shape matching all other        //
    //  authority detail responses. Downstream sections are populated      //
    //  as the ACR progresses through the workflow.                        //
    // ------------------------------------------------------------------ //

    public class AcrDetailResponse
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

        // Officer info
        public OfficerLite Officer { get; set; } = new OfficerLite();

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
        //  All downstream sections — populated as the ACR progresses         //
        // ------------------------------------------------------------------ //

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();
        public AcceptingDecisionView Decision { get; set; } = new AcceptingDecisionView();

        // ------------------------------------------------------------------ //
        //  Documents                                                          //
        // ------------------------------------------------------------------ //

        /// <summary>CCA documents (section='CCA', excludes OFFICER_PHOTO).</summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();

        /// <summary>Officer photograph uploaded by CCA.</summary>
        public AcrDocumentItem OfficerPhoto { get; set; }

        /// <summary>Documents uploaded by the Officer for their step (section='OFFICER').</summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }
}
