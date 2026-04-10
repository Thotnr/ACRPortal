using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class CcaOfficerListItem
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public int? DsgId { get; set; }
        public string DsgCode { get; set; }
        public string DsgDesc { get; set; }
        public string FormType { get; set; }
    }

    public class CcaEmployeeDropdownItem
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public int? DsgId { get; set; }
        public string DsgDesc { get; set; }
    }

    public class CcaOfficerListResponse
    {
        public List<CcaOfficerListItem> Officers { get; set; } = new List<CcaOfficerListItem>();
    }

    public class CcaEmployeeDropdownResponse
    {
        public List<CcaEmployeeDropdownItem> Employees { get; set; } = new List<CcaEmployeeDropdownItem>();
    }

    public class CcaAuthoritySuggestionResponse
    {
        public string OfficerUserId { get; set; }
        public string ReportingUserId { get; set; }
        public string ReviewingUserId { get; set; }
    }

    public class CreateAcrRequest
    {
        public string OfficerUserId { get; set; }
        public int DesignationId { get; set; }
        public bool SaveAsDraft { get; set; }

        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }

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

        public string ReportingUserId { get; set; }
        public string ReportingUserId2 { get; set; }
        public string ReviewingUserId { get; set; }
        public string AcceptingUserId { get; set; }
    }

    public class UpdateDraftAcrRequest
    {
        public string OfficerUserId { get; set; }
        public int DesignationId { get; set; }

        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }

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

        public string ReportingUserId { get; set; }
        public string ReportingUserId2 { get; set; }
        public string ReviewingUserId { get; set; }
        public string AcceptingUserId { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  GET /api/cca/acr/{acrId} — full ACR detail (all sections)         //
    //  CCA can see everything that has been filled so far.                //
    // ------------------------------------------------------------------ //

    public class CcaAcrDetailResponse
    {
        // Identity
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }

        // Officer
        public string OfficerUserId { get; set; }
        public string OfficerLoginId { get; set; }
        public string OfficerName { get; set; }
        public string Dsg { get; set; }

        // Posting
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }
        public int AcrYear { get; set; }

        // Section I: bio
        public string DateOfBirth { get; set; }

        // Section I: joining dates
        public string DateJoiningNigam { get; set; }
        public string DateJoiningPresentRank { get; set; }
        public string DateJoiningPresentStation { get; set; }

        // Section I: qualifications & exam
        public string AcademicQualification { get; set; }
        public string TechnicalQualification { get; set; }
        public string DepartmentalExamPassed { get; set; }

        // Section I: property return & medical
        public string PropertyReturnDate { get; set; }
        public string LastMedicalExamDate { get; set; }

        // Misc
        public string CareerPostingSummary { get; set; }

        // Authorities — UserId only
        public string ReportingAuthorityUserId { get; set; }   // RA1
        public string ReportingAuthority2UserId { get; set; }  // RA2 — null for A1a/A2
        public string ReviewingAuthorityUserId { get; set; }
        public string AcceptingAuthorityUserId { get; set; }

        // Audit
        public string CreatedAt { get; set; }
        public string UpdatedAt { get; set; }

        // ------------------------------------------------------------------ //
        //  All downstream sections — populated as the ACR progresses         //
        // ------------------------------------------------------------------ //

        public SelfAppraisalView SelfAppraisal { get; set; } = new SelfAppraisalView();
        public ReportingAssessmentView Ra1Assessment { get; set; } = new ReportingAssessmentView();
        public ReportingAssessmentView Ra2Assessment { get; set; } = new ReportingAssessmentView();
        public RvaOverrideGradesView RvaOverrideGrades { get; set; } = new RvaOverrideGradesView();
        public ReviewingAssessmentView ReviewingAssessment { get; set; } = new ReviewingAssessmentView();
        public AcceptingDecisionView Decision { get; set; } = new AcceptingDecisionView();

        // Documents
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();
        public AcrDocumentItem OfficerPhoto { get; set; }

        /// <summary>
        /// For CCA, RoleDocuments is always empty — CCA's own docs are in Documents.
        /// Kept for response shape consistency with other authority detail APIs.
        /// </summary>
        public List<AcrDocumentItem> RoleDocuments { get; set; } = new List<AcrDocumentItem>();
    }

    // ------------------------------------------------------------------ //
    //  Shared response DTOs                                               //
    // ------------------------------------------------------------------ //

    public class CreateAcrResponse
    {
        public string AcrId { get; set; }
        public string FormType { get; set; }
        public string Status { get; set; }
    }

    public class AcrListItem
    {
        public string AcrId { get; set; }
        public string OfficerName { get; set; }
        public string OfficerLoginId { get; set; }
        public string Dsg { get; set; }
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public string CreatedAt { get; set; }
    }

    public class DesignationLookupItem
    {
        public string DsgDesc { get; set; }
        public string FormType { get; set; }
    }
}