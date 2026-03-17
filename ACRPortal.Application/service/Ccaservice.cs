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

                if (!Guid.TryParse(request.OfficerUserId, out Guid officerGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("OfficerUserId is not a valid ID", "BAD_REQUEST");

                if (!Guid.TryParse(request.ReportingUserId, out Guid ra1Guid))
                    return ApiResponse<CreateAcrResponse>.Fail("ReportingUserId is not a valid ID", "BAD_REQUEST");

                if (!Guid.TryParse(request.ReviewingUserId, out Guid rvaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("ReviewingUserId is not a valid ID", "BAD_REQUEST");

                if (!Guid.TryParse(request.AcceptingUserId, out Guid aaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("AcceptingUserId is not a valid ID", "BAD_REQUEST");

                if (!Guid.TryParse(ccaUserId, out Guid ccaGuid))
                    return ApiResponse<CreateAcrResponse>.Fail("Invalid CCA session", "TOKEN_INVALID");

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

                string acrId = _repo.CreateAcr(
                    officerGuid,
                    ra1Guid,
                    ra2Guid,
                    rvaGuid,
                    aaGuid,
                    ccaGuid,
                    request.Department.Trim(),
                    request.Location.Trim(),
                    postingFrom,
                    postingTo,
                    acrYear,
                    dsg.DsgDesc,
                    dsg.FormType,
                    dob,
                    request.AcademicQualification?.Trim(),
                    request.TechnicalQualification?.Trim(),
                    request.CareerPostingSummary?.Trim(),
                    request.PropertyReturnDone
                );

                return ApiResponse<CreateAcrResponse>.Ok(
                    new CreateAcrResponse { AcrId = acrId, FormType = dsg.FormType, Status = "PENDING_OFFICER" },
                    "ACR created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<CreateAcrResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

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
    }
}