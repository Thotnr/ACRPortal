using System;
using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface ICcaRepoPort
    {
        List<CcaOfficerListItem> GetOfficers();
        List<CcaEmployeeDropdownItem> GetEmployeesForDropdown();
        CcaAuthoritySuggestionResponse GetAuthoritySuggestions(Guid officerUserId, out string errorCode);

        bool IsUserActive(Guid userId);
        bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom);
        bool IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom);

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
            DateTime? dateJoiningNigam,
            DateTime? dateJoiningPresentRank,
            DateTime? dateJoiningPresentStation,
            string academicQualification,
            string technicalQualification,
            string departmentalExamPassed,
            DateTime? propertyReturnDate,
            DateTime? lastMedicalExamDate,
            string careerPostingSummary,
            string status
        );

        bool TryUpdateDraftAcr(
            Guid acrId,
            Guid ccaUserId,
            Guid officerUserId,
            Guid reportingUserId,
            Guid? reportingUserId2,
            Guid reviewingUserId,
            Guid acceptingUserId,
            string department,
            string location,
            DateTime postingFrom,
            DateTime postingTo,
            int acrYear,
            string designation,
            string formType,
            DateTime dateOfBirth,
            DateTime? dateJoiningNigam,
            DateTime? dateJoiningPresentRank,
            DateTime? dateJoiningPresentStation,
            string academicQualification,
            string technicalQualification,
            string departmentalExamPassed,
            DateTime? propertyReturnDate,
            DateTime? lastMedicalExamDate,
            string careerPostingSummary,
            out string errorCode
        );

        bool TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode);

        /// <summary>
        /// Fetches full Section I detail for a single ACR including resolved authority names.
        /// Returns null when the ACR does not exist.
        /// No CCA ownership check � any CCA can view any ACR.
        /// </summary>
        CcaAcrDetailResponse GetAcrDetail(Guid acrId);

        PagedResult<AcrListItem> GetCcaAcrs(Guid userId, int pageNumber, int pageSize, string Status, string Officer_name);
    }
}