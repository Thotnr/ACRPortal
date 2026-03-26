using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  My ACR list (Officer dashboard)                                    //
    // ------------------------------------------------------------------ //

    public class MyAcrListItem
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }   // 'A1a' | 'A1b' | 'A2'
        public string Department { get; set; }
        public string Location { get; set; }
        public string Dsg { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public bool SelfAppraisalSubmitted { get; set; }
        public string CreatedAt { get; set; }   // ISO 8601
    }

    public class MyAcrListResponse
    {
        public List<MyAcrListItem> AcrCycles { get; set; } = new List<MyAcrListItem>();
    }

    // ------------------------------------------------------------------ //
    //  Self-appraisal draft request (Section II — filled by Officer)      //
    //  DocumentPath removed — documents now go through /api/acr/{id}/docs //
    // ------------------------------------------------------------------ //

    public class SelfAppraisalDraftRequest
    {
        // Section II Item 1 — Period of absence/leave
        public string LeaveDetails { get; set; }

        // Section II Item 2
        public string MembershipBodies { get; set; }

        // Section II Item 3 — Training
        public string TrainingDetails { get; set; }

        // Section II Item 4
        public string AwardsHonours { get; set; }

        // Section II Item 5: Self Assessment Report
        public string DutiesDescription { get; set; }   // 5(a)
        public string TargetsSet { get; set; }   // 5(b)
        public string TargetsAchieved { get; set; }   // 5(c)
        public string ShortfallReasons { get; set; }   // 5(d)
        public string MajorAchievements { get; set; }   // 5(e)

        // Section II Item 6 — A1b only (null = not applicable for A1a/A2)
        public bool? AuditorCompliance { get; set; }

        // Declaration: property return
        public bool PropertyDeclared { get; set; }
        public string PropertyDeclaredDate { get; set; }   // yyyy-MM-dd

        // Declaration: medical check-up
        public bool MedicalCompliance { get; set; }
        public string MedicalComplianceDate { get; set; }   // yyyy-MM-dd
    }

    // ------------------------------------------------------------------ //
    //  Self-appraisal read-back view                                      //
    //  DocumentPath removed — documents returned via Documents list       //
    // ------------------------------------------------------------------ //

    public class SelfAppraisalView
    {
        public bool Exists { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; }   // ISO 8601 | null

        // Section II Item 1
        public string LeaveDetails { get; set; }

        // Section II Item 2
        public string MembershipBodies { get; set; }

        // Section II Item 3
        public string TrainingDetails { get; set; }

        // Section II Item 4
        public string AwardsHonours { get; set; }

        // Section II Item 5
        public string DutiesDescription { get; set; }
        public string TargetsSet { get; set; }
        public string TargetsAchieved { get; set; }
        public string ShortfallReasons { get; set; }
        public string MajorAchievements { get; set; }

        // Section II Item 6 (A1b only — null = not applicable)
        public bool? AuditorCompliance { get; set; }

        // Declaration
        public bool PropertyDeclared { get; set; }
        public string PropertyDeclaredDate { get; set; }   // yyyy-MM-dd | null
        public bool MedicalCompliance { get; set; }
        public string MedicalComplianceDate { get; set; }   // yyyy-MM-dd | null
    }

    // ------------------------------------------------------------------ //
    //  ACR detail response (Officer view)                                 //
    //  Documents are returned as a separate list, not embedded in         //
    //  SelfAppraisalView, so the frontend can manage them independently.  //
    // ------------------------------------------------------------------ //

    public class AcrDetailResponse
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

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();

        /// <summary>
        /// CCA documents for this ACR (section = 'CCA', excludes OFFICER_PHOTO).
        /// This is returned consistently across all authority detail APIs
        /// so the shared modal can render them without role-specific logic.
        /// </summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();

        /// <summary>
        /// Officer photograph uploaded by the CCA for this ACR.
        /// </summary>
        public AcrDocumentItem OfficerPhoto { get; set; }

        /// <summary>
        /// Documents uploaded by the caller's current step (section = 'OFFICER').
        /// Kept separate so authority viewing (CCA docs) and document management
        /// can both work with minimal frontend changes.
        /// </summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }
}