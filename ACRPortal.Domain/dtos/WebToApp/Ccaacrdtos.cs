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

    public class CreateAcrRequest
    {
        public string OfficerUserId { get; set; }
        public int DesignationId { get; set; }
        public string Department { get; set; }
        public string Location { get; set; }
        public string PostingFrom { get; set; }
        public string PostingTo { get; set; }
        public string DateOfBirth { get; set; }
        public string AcademicQualification { get; set; }
        public string TechnicalQualification { get; set; }
        public string CareerPostingSummary { get; set; }
        public bool PropertyReturnDone { get; set; }
        public string ReportingUserId { get; set; }
        public string ReportingUserId2 { get; set; }
        public string ReviewingUserId { get; set; }
        public string AcceptingUserId { get; set; }
    }

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