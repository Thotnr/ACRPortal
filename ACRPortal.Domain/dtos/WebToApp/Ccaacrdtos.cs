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

    // ------------------------------------------------------------------ //
    //  Create / Update request DTOs                                        //
    // ------------------------------------------------------------------ //

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
    //  GET /api/cca/acr/{acrId} — single ACR detail                       //
    // ------------------------------------------------------------------ //

    /// <summary>
    /// Full Section I detail for a single ACR cycle — returned to the CCA.
    /// Authority fields contain only the UserId stored on acr_cycles.
    /// Does NOT include any assessment data.
    /// </summary>
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
        public int? DsgId { get; set; }
        public string DsgDesc { get; set; }

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
        public string ReportingAuthority2UserId { get; set; }   // RA2 — null for A1a/A2
        public string ReviewingAuthorityUserId { get; set; }
        public string AcceptingAuthorityUserId { get; set; }

        // Audit
        public string CreatedAt { get; set; }
        public string UpdatedAt { get; set; }
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
        public string DsgDesc { get; set; }
        public string FormType { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }
        public int AcrYear { get; set; }
        public string Status { get; set; }
        public string CreatedAt { get; set; }
    }

    public class AcrListResponse
    {
        public List<AcrListItem> AcrCycles { get; set; } = new List<AcrListItem>();
    }

    public class DesignationLookupItem
    {
        public string DsgDesc { get; set; }
        public string FormType { get; set; }
    }
}