using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class CcaService : ICcaUseCase
    {
        private readonly ICcaRepoPort _repo;

        public CcaService(ICcaRepoPort repo)
        {
            _repo = repo;
        }

        // ------------------------------------------------------------------ //
        //  GET /api/cca/officers                                              //
        // ------------------------------------------------------------------ //
        public ApiResponse<CcaOfficerListResponse> GetOfficers()
        {
            try
            {
                var list = _repo.GetOfficers();
                return ApiResponse<CcaOfficerListResponse>.Ok(
                    new CcaOfficerListResponse { Officers = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<CcaOfficerListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  GET /api/cca/employees                                             //
        // ------------------------------------------------------------------ //
        public ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown()
        {
            try
            {
                var list = _repo.GetEmployeesForDropdown();
                return ApiResponse<CcaEmployeeDropdownResponse>.Ok(
                    new CcaEmployeeDropdownResponse { Employees = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<CcaEmployeeDropdownResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  POST /api/cca/acr                                                  //
        // ------------------------------------------------------------------ //
        public ApiResponse<CreateAcrResponse> CreateAcr(string ccaUserId, CreateAcrRequest request)
        {
            try
            {
                if (request == null)
                    return ApiResponse<CreateAcrResponse>.Fail("Request body is required", "BAD_REQUEST");

                if (string.IsNullOrWhiteSpace(request.OfficerUserId))
                    return ApiResponse<CreateAcrResponse>.Fail("OfficerUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.Department))
                    return ApiResponse<CreateAcrResponse>.Fail("Department is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.Location))
                    return ApiResponse<CreateAcrResponse>.Fail("Location is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.ReportingUserId))
                    return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.ReviewingUserId))
                    return ApiResponse<CreateAcrResponse>.Fail("ReviewingUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.AcceptingUserId))
                    return ApiResponse<CreateAcrResponse>.Fail("AcceptingUserId is required", "BAD_REQUEST");

                if (!Guid.TryParse(ccaUserId, out Guid ccaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("Invalid CCA session", "TOKEN_INVALID");
                if (!Guid.TryParse(request.OfficerUserId, out Guid officerGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("OfficerUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.ReportingUserId, out Guid ra1Guid))
                    return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.ReviewingUserId, out Guid rvaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("ReviewingUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.AcceptingUserId, out Guid aaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("AcceptingUserId is not a valid ID", "BAD_REQUEST");

                Guid? ra2Guid = null;
                if (!string.IsNullOrWhiteSpace(request.ReportingUserId2))
                {
                    if (!Guid.TryParse(request.ReportingUserId2, out Guid ra2Parsed))
                        return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId2 is not a valid ID", "BAD_REQUEST");
                    ra2Guid = ra2Parsed;
                }

                if (!DateTime.TryParse(request.PostingFrom, out DateTime postingFrom))
                    return ApiResponse<CreateAcrResponse>.Fail("PostingFrom must be a valid date", "BAD_REQUEST");
                if (!DateTime.TryParse(request.PostingTo, out DateTime postingTo))
                    return ApiResponse<CreateAcrResponse>.Fail("PostingTo must be a valid date", "BAD_REQUEST");
                if (postingTo <= postingFrom)
                    return ApiResponse<CreateAcrResponse>.Fail("PostingTo must be after PostingFrom", "BAD_REQUEST");
                if ((postingTo - postingFrom).TotalDays < 90)
                    return ApiResponse<CreateAcrResponse>.Fail("Posting period must be at least 3 months", "BAD_REQUEST");

                if (!DateTime.TryParse(request.DateOfBirth, out DateTime dob))
                    return ApiResponse<CreateAcrResponse>.Fail("DateOfBirth must be a valid date", "BAD_REQUEST");
                if (dob >= DateTime.Today)
                    return ApiResponse<CreateAcrResponse>.Fail("DateOfBirth must be in the past", "BAD_REQUEST");

                if (request.DesignationId <= 0)
                    return ApiResponse<CreateAcrResponse>.Fail("DesignationId is required", "BAD_REQUEST");

                var parsed = ParseOptionalDates(request.DateJoiningNigam, request.DateJoiningPresentRank,
                    request.DateJoiningPresentStation, request.PropertyReturnDate, request.LastMedicalExamDate);
                if (parsed.Error != null)
                    return ApiResponse<CreateAcrResponse>.Fail(parsed.Error, "BAD_REQUEST");

                if (officerGuid == ra1Guid || officerGuid == rvaGuid || officerGuid == aaGuid)
                    return ApiResponse<CreateAcrResponse>.Fail("Officer cannot be their own RA, RvA, or AA", "BAD_REQUEST");
                if (ra2Guid.HasValue && ra2Guid.Value == ra1Guid)
                    return ApiResponse<CreateAcrResponse>.Fail("RA1 and RA2 must be different persons", "BAD_REQUEST");

                if (!_repo.IsUserActive(officerGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("Selected officer is not active", "INVALID_OFFICER");
                if (!_repo.IsUserActive(ra1Guid))
                    return ApiResponse<CreateAcrResponse>.Fail("Selected Reporting Authority is not active", "INVALID_RA");
                if (ra2Guid.HasValue && !_repo.IsUserActive(ra2Guid.Value))
                    return ApiResponse<CreateAcrResponse>.Fail("Selected 2nd Reporting Authority is not active", "INVALID_RA2");
                if (!_repo.IsUserActive(rvaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("Selected Reviewing Authority is not active", "INVALID_RVA");
                if (!_repo.IsUserActive(aaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("Selected Accepting Authority is not active", "INVALID_AA");

                int acrYear = postingTo.Month >= 4 ? postingTo.Year : postingTo.Year - 1;

                if (_repo.IsAcrDuplicate(officerGuid, request.Department.Trim(), postingFrom))
                    return ApiResponse<CreateAcrResponse>.Fail(
                        "An ACR already exists for this officer, department, and posting start date", "DUPLICATE_ACR");

                var dsg = _repo.GetDesignationById(request.DesignationId);
                if (dsg == null)
                    return ApiResponse<CreateAcrResponse>.Fail(
                        "Designation with id " + request.DesignationId + " not found", "INVALID_DESIGNATION");

                if (string.Equals(dsg.FormType, "A1b", StringComparison.OrdinalIgnoreCase))
                {
                    if (!ra2Guid.HasValue)
                        return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId2 is required for form type A1b", "BAD_REQUEST");
                }
                else
                {
                    if (ra2Guid.HasValue)
                        return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId2 must be null for this form type", "BAD_REQUEST");
                }

                string acrId = _repo.CreateAcr(
                    officerGuid, ra1Guid, ra2Guid, rvaGuid, aaGuid, ccaGuid,
                    request.Department.Trim(), request.Location.Trim(),
                    postingFrom, postingTo, acrYear,
                    dsg.DsgDesc, dsg.FormType, dob,
                    parsed.DateJoiningNigam, parsed.DateJoiningPresentRank, parsed.DateJoiningPresentStation,
                    request.AcademicQualification?.Trim(), request.TechnicalQualification?.Trim(),
                    request.DepartmentalExamPassed?.Trim(),
                    parsed.PropertyReturnDate, parsed.LastMedicalExamDate,
                    request.CareerPostingSummary?.Trim(),
                    request.SaveAsDraft ? "DRAFT" : "PENDING_OFFICER"
                );

                string createdStatus = request.SaveAsDraft ? "DRAFT" : "PENDING_OFFICER";
                return ApiResponse<CreateAcrResponse>.Ok(
                    new CreateAcrResponse { AcrId = acrId, FormType = dsg.FormType, Status = createdStatus },
                    request.SaveAsDraft ? "ACR saved as draft" : "ACR created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<CreateAcrResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  GET /api/cca/acr/{acrId}                                           //
        // ------------------------------------------------------------------ //
        public ApiResponse<CcaAcrDetailResponse> GetAcrDetail(string acrId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(acrId))
                    return ApiResponse<CcaAcrDetailResponse>.Fail("AcrId is required", "BAD_REQUEST");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<CcaAcrDetailResponse>.Fail("AcrId is not a valid ID", "BAD_REQUEST");

                var detail = _repo.GetAcrDetail(acrGuid);
                if (detail == null)
                    return ApiResponse<CcaAcrDetailResponse>.Fail("ACR not found", "NOT_FOUND");

                return ApiResponse<CcaAcrDetailResponse>.Ok(detail);
            }
            catch (Exception ex)
            {
                return ApiResponse<CcaAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  PATCH /api/cca/acr/{acrId}                                         //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(acrId))
                    return ApiResponse<EmptyResponse>.Fail("AcrId is required", "BAD_REQUEST");
                if (request == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("AcrId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(ccaUserId, out Guid ccaGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid CCA session", "TOKEN_INVALID");

                if (string.IsNullOrWhiteSpace(request.OfficerUserId))
                    return ApiResponse<EmptyResponse>.Fail("OfficerUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.Department))
                    return ApiResponse<EmptyResponse>.Fail("Department is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.Location))
                    return ApiResponse<EmptyResponse>.Fail("Location is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.ReportingUserId))
                    return ApiResponse<EmptyResponse>.Fail("ReportingUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.ReviewingUserId))
                    return ApiResponse<EmptyResponse>.Fail("ReviewingUserId is required", "BAD_REQUEST");
                if (string.IsNullOrWhiteSpace(request.AcceptingUserId))
                    return ApiResponse<EmptyResponse>.Fail("AcceptingUserId is required", "BAD_REQUEST");

                if (!Guid.TryParse(request.OfficerUserId, out Guid officerGuid))
                    return ApiResponse<EmptyResponse>.Fail("OfficerUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.ReportingUserId, out Guid ra1Guid))
                    return ApiResponse<EmptyResponse>.Fail("ReportingUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.ReviewingUserId, out Guid rvaGuid))
                    return ApiResponse<EmptyResponse>.Fail("ReviewingUserId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(request.AcceptingUserId, out Guid aaGuid))
                    return ApiResponse<EmptyResponse>.Fail("AcceptingUserId is not a valid ID", "BAD_REQUEST");

                Guid? ra2Guid = null;
                if (!string.IsNullOrWhiteSpace(request.ReportingUserId2))
                {
                    if (!Guid.TryParse(request.ReportingUserId2, out Guid ra2Parsed))
                        return ApiResponse<EmptyResponse>.Fail("ReportingUserId2 is not a valid ID", "BAD_REQUEST");
                    ra2Guid = ra2Parsed;
                }

                if (!DateTime.TryParse(request.PostingFrom, out DateTime postingFrom))
                    return ApiResponse<EmptyResponse>.Fail("PostingFrom must be a valid date", "BAD_REQUEST");
                if (!DateTime.TryParse(request.PostingTo, out DateTime postingTo))
                    return ApiResponse<EmptyResponse>.Fail("PostingTo must be a valid date", "BAD_REQUEST");
                if (postingTo <= postingFrom)
                    return ApiResponse<EmptyResponse>.Fail("PostingTo must be after PostingFrom", "BAD_REQUEST");
                if ((postingTo - postingFrom).TotalDays < 90)
                    return ApiResponse<EmptyResponse>.Fail("Posting period must be at least 3 months", "BAD_REQUEST");

                if (!DateTime.TryParse(request.DateOfBirth, out DateTime dob))
                    return ApiResponse<EmptyResponse>.Fail("DateOfBirth must be a valid date", "BAD_REQUEST");
                if (dob >= DateTime.Today)
                    return ApiResponse<EmptyResponse>.Fail("DateOfBirth must be in the past", "BAD_REQUEST");

                if (request.DesignationId <= 0)
                    return ApiResponse<EmptyResponse>.Fail("DesignationId is required", "BAD_REQUEST");

                var parsed = ParseOptionalDates(request.DateJoiningNigam, request.DateJoiningPresentRank,
                    request.DateJoiningPresentStation, request.PropertyReturnDate, request.LastMedicalExamDate);
                if (parsed.Error != null)
                    return ApiResponse<EmptyResponse>.Fail(parsed.Error, "BAD_REQUEST");

                if (officerGuid == ra1Guid || officerGuid == rvaGuid || officerGuid == aaGuid)
                    return ApiResponse<EmptyResponse>.Fail("Officer cannot be their own RA, RvA, or AA", "BAD_REQUEST");
                if (ra2Guid.HasValue && ra2Guid.Value == ra1Guid)
                    return ApiResponse<EmptyResponse>.Fail("RA1 and RA2 must be different persons", "BAD_REQUEST");

                if (!_repo.IsUserActive(officerGuid))
                    return ApiResponse<EmptyResponse>.Fail("Selected officer is not active", "INVALID_OFFICER");
                if (!_repo.IsUserActive(ra1Guid))
                    return ApiResponse<EmptyResponse>.Fail("Selected Reporting Authority is not active", "INVALID_RA");
                if (ra2Guid.HasValue && !_repo.IsUserActive(ra2Guid.Value))
                    return ApiResponse<EmptyResponse>.Fail("Selected 2nd Reporting Authority is not active", "INVALID_RA2");
                if (!_repo.IsUserActive(rvaGuid))
                    return ApiResponse<EmptyResponse>.Fail("Selected Reviewing Authority is not active", "INVALID_RVA");
                if (!_repo.IsUserActive(aaGuid))
                    return ApiResponse<EmptyResponse>.Fail("Selected Accepting Authority is not active", "INVALID_AA");

                int acrYear = postingTo.Month >= 4 ? postingTo.Year : postingTo.Year - 1;

                if (_repo.IsAcrDuplicateExcluding(acrGuid, officerGuid, request.Department.Trim(), postingFrom))
                    return ApiResponse<EmptyResponse>.Fail(
                        "An ACR already exists for this officer, department, and posting start date", "DUPLICATE_ACR");

                var dsg = _repo.GetDesignationById(request.DesignationId);
                if (dsg == null)
                    return ApiResponse<EmptyResponse>.Fail(
                        "Designation with id " + request.DesignationId + " not found", "INVALID_DESIGNATION");

                if (string.Equals(dsg.FormType, "A1b", StringComparison.OrdinalIgnoreCase))
                {
                    if (!ra2Guid.HasValue)
                        return ApiResponse<EmptyResponse>.Fail("ReportingUserId2 is required for form type A1b", "BAD_REQUEST");
                }
                else
                {
                    if (ra2Guid.HasValue)
                        return ApiResponse<EmptyResponse>.Fail("ReportingUserId2 must be null for this form type", "BAD_REQUEST");
                }

                if (_repo.TryUpdateDraftAcr(
                        acrGuid, ccaGuid, officerGuid, ra1Guid, ra2Guid, rvaGuid, aaGuid,
                        request.Department.Trim(), request.Location.Trim(),
                        postingFrom, postingTo, acrYear,
                        dsg.DsgDesc, dsg.FormType, dob,
                        parsed.DateJoiningNigam, parsed.DateJoiningPresentRank, parsed.DateJoiningPresentStation,
                        request.AcademicQualification?.Trim(), request.TechnicalQualification?.Trim(),
                        request.DepartmentalExamPassed?.Trim(),
                        parsed.PropertyReturnDate, parsed.LastMedicalExamDate,
                        request.CareerPostingSummary?.Trim(),
                        out string errorCode))
                {
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Draft saved successfully");
                }

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "ACR does not belong to the current CCA" :
                    errorCode == "INVALID_STATE" ? "Only DRAFT ACRs can be updated" :
                    "Unable to save draft",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  POST /api/cca/acr/{acrId}/submit                                   //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> SubmitDraftAcr(string acrId, string ccaUserId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(acrId))
                    return ApiResponse<EmptyResponse>.Fail("AcrId is required", "BAD_REQUEST");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("AcrId is not a valid ID", "BAD_REQUEST");
                if (!Guid.TryParse(ccaUserId, out Guid ccaGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid CCA session", "TOKEN_INVALID");

                if (_repo.TrySubmitDraftAcr(acrGuid, ccaGuid, out string errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Draft submitted successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "ACR does not belong to the current CCA" :
                    errorCode == "INVALID_STATE" ? "Only DRAFT ACRs can be submitted" :
                    "Unable to submit draft",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  GET /api/cca/acr                                                   //
        // ------------------------------------------------------------------ //
        public ApiResponse<AcrListResponse> GetAcrList()
        {
            try
            {
                var list = _repo.GetAcrList();
                return ApiResponse<AcrListResponse>.Ok(new AcrListResponse { AcrCycles = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<AcrListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Private helpers                                                    //
        // ------------------------------------------------------------------ //

        /// <summary>
        /// Parses all five optional date strings in one place.
        /// Returns a result object: Error is non-null when any provided string
        /// cannot be parsed, so callers just check result.Error != null.
        /// </summary>
        private static ParsedOptionalDates ParseOptionalDates(
            string djNigam, string djRank, string djStation,
            string propReturn, string lastMed)
        {
            var r = new ParsedOptionalDates();

            if (!string.IsNullOrWhiteSpace(djNigam))
            {
                if (!DateTime.TryParse(djNigam, out DateTime d))
                { r.Error = "DateJoiningNigam must be a valid date"; return r; }
                r.DateJoiningNigam = d;
            }
            if (!string.IsNullOrWhiteSpace(djRank))
            {
                if (!DateTime.TryParse(djRank, out DateTime d))
                { r.Error = "DateJoiningPresentRank must be a valid date"; return r; }
                r.DateJoiningPresentRank = d;
            }
            if (!string.IsNullOrWhiteSpace(djStation))
            {
                if (!DateTime.TryParse(djStation, out DateTime d))
                { r.Error = "DateJoiningPresentStation must be a valid date"; return r; }
                r.DateJoiningPresentStation = d;
            }
            if (!string.IsNullOrWhiteSpace(propReturn))
            {
                if (!DateTime.TryParse(propReturn, out DateTime d))
                { r.Error = "PropertyReturnDate must be a valid date"; return r; }
                r.PropertyReturnDate = d;
            }
            if (!string.IsNullOrWhiteSpace(lastMed))
            {
                if (!DateTime.TryParse(lastMed, out DateTime d))
                { r.Error = "LastMedicalExamDate must be a valid date"; return r; }
                r.LastMedicalExamDate = d;
            }

            return r;
        }

        private class ParsedOptionalDates
        {
            public string Error { get; set; }
            public DateTime? DateJoiningNigam { get; set; }
            public DateTime? DateJoiningPresentRank { get; set; }
            public DateTime? DateJoiningPresentStation { get; set; }
            public DateTime? PropertyReturnDate { get; set; }
            public DateTime? LastMedicalExamDate { get; set; }
        }
    }
}