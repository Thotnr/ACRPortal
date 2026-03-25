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
        public string Designation { get; set; }
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
        public string Designation { get; set; }
        public string PostingFrom { get; set; }   // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();

        /// <summary>
        /// All documents uploaded by the Officer for this ACR (section = 'OFFICER').
        /// Empty list when none have been uploaded yet.
        /// </summary>
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();
    }
}