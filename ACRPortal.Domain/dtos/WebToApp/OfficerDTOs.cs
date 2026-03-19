using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
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
    //  Self-appraisal draft request (Section II, filled by Officer)        //
    // ------------------------------------------------------------------ //
    public class SelfAppraisalDraftRequest
    {
        // Section II Item 1: Period of absence / leave
        public string LeaveDetails { get; set; }   // free text — both (a) and (b) combined

        // Section II Item 2
        public string MembershipBodies { get; set; }

        // Section II Item 3: Training (stored as free text)
        public string TrainingDetails { get; set; }

        // Section II Item 4
        public string AwardsHonours { get; set; }

        // Section II Item 5: Self Assessment Report
        public string DutiesDescription { get; set; }   // 5(a)
        public string TargetsSet { get; set; }   // 5(b)
        public string TargetsAchieved { get; set; }   // 5(c)
        public string ShortfallReasons { get; set; }   // 5(d)
        public string MajorAchievements { get; set; }   // 5(e)

        // Section II Item 6 (A1b only): Auditor compliance YES/NO
        // null = not applicable (A1a / A2 officers skip this field)
        public bool? AuditorCompliance { get; set; }

        // Section II Declaration: property return
        public bool PropertyDeclared { get; set; }   // YES/NO
        public string PropertyDeclaredDate { get; set; }   // yyyy-MM-dd — date filed; null if not filed

        // Section II Declaration: medical check-up
        public bool MedicalCompliance { get; set; }   // YES/NO
        public string MedicalComplianceDate { get; set; }   // yyyy-MM-dd — date of check-up; null if not done

        // Document attachment (medical Annexure-A, etc.)
        public string DocumentPath { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  ACR detail (Officer view)                                           //
    // ------------------------------------------------------------------ //
    public class AcrDetailResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }
        public int AcrYear { get; set; }

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
    }

    // ------------------------------------------------------------------ //
    //  SelfAppraisalView — read-back shape (used by Officer and RA)        //
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

        // Section II Item 6 (A1b only)
        public bool? AuditorCompliance { get; set; }   // null = not applicable

        // Declaration
        public bool PropertyDeclared { get; set; }
        public string PropertyDeclaredDate { get; set; }   // yyyy-MM-dd | null
        public bool MedicalCompliance { get; set; }
        public string MedicalComplianceDate { get; set; }   // yyyy-MM-dd | null

        public string DocumentPath { get; set; }
    }
}