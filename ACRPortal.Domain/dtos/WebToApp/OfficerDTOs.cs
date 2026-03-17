using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class MyAcrListItem
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; } // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public bool SelfAppraisalSubmitted { get; set; }
        public string CreatedAt { get; set; } // ISO 8601
    }

    public class MyAcrListResponse
    {
        public List<MyAcrListItem> AcrCycles { get; set; } = new List<MyAcrListItem>();
    }

    public class SelfAppraisalDraftRequest
    {
        public string DutiesDescription { get; set; }
        public string TargetsSet { get; set; }
        public string TargetsAchieved { get; set; }
        public string ShortfallReasons { get; set; }
        public string MajorAchievements { get; set; }
        public string MembershipBodies { get; set; }
        public string TrainingDetails { get; set; }
        public string AwardsHonours { get; set; }
        public string PropertyReturnDate { get; set; } // yyyy-MM-dd | null
        public string AuditorCompliance { get; set; }
        public bool PropertyDeclared { get; set; }
        public bool MedicalCompliance { get; set; }
        public string DocumentPath { get; set; }
    }

    public class AcrDetailResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string Designation { get; set; }
        public string PostingFrom { get; set; } // yyyy-MM-dd
        public string PostingTo { get; set; }   // yyyy-MM-dd
        public int AcrYear { get; set; }
        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
    }

    public class SelfAppraisalView
    {
        public bool Exists { get; set; }
        public bool IsSubmitted { get; set; }
        public string SubmittedAt { get; set; } // ISO 8601 | null

        public string DutiesDescription { get; set; }
        public string TargetsSet { get; set; }
        public string TargetsAchieved { get; set; }
        public string ShortfallReasons { get; set; }
        public string MajorAchievements { get; set; }
        public string MembershipBodies { get; set; }
        public string TrainingDetails { get; set; }
        public string AwardsHonours { get; set; }
        public string PropertyReturnDate { get; set; } // yyyy-MM-dd | null
        public string AuditorCompliance { get; set; }
        public bool PropertyDeclared { get; set; }
        public bool MedicalCompliance { get; set; }
        public string DocumentPath { get; set; }
    }
}

