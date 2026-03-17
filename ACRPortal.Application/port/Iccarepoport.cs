using System;
using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface ICcaRepoPort
    {
        List<CcaOfficerListItem> GetOfficers();
        List<CcaEmployeeDropdownItem> GetEmployeesForDropdown();
        bool IsUserActive(Guid userId);
        bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom);
        DesignationLookupItem GetDesignationById(int dsgId);
        string CreateAcr(
            Guid officerUserId,
            Guid reportingUserId,
            Guid? reportingUserId2,
            Guid reviewingUserId,
            Guid acceptingUserId,
            Guid ccaUserId,
            string department,
            string location,
            DateTime postingFrom,
            DateTime postingTo,
            int acrYear,
            string designation,
            string formType,
            DateTime dateOfBirth,
            string academicQualification,
            string technicalQualification,
            string careerPostingSummary,
            bool propertyReturnDone
        );
        List<AcrListItem> GetAcrList();
    }
}