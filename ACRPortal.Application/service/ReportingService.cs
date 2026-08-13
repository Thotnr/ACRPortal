using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class ReportingService : IReportingUseCase
    {
        private readonly IReportingRepoPort _repo;
        private readonly IDocumentRepoPort _docs;

        public ReportingService(IReportingRepoPort repo, IDocumentRepoPort docs)
        {
            _repo = repo;
            _docs = docs;
        }

        public ApiResponse<PagedResult<MyReportingQueueItem>> GetMyReportingQueue(
            string userId, 
            int pageNumber, 
            int pageSize,
            string Status, 
            string Officer_name)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid guid))
                    return ApiResponse<PagedResult<MyReportingQueueItem>>.Fail("Invalid user id", "TOKEN_INVALID");

                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0 || pageSize > 100) pageSize = 10;

                var result = _repo.GetMyReportingQueue(guid, pageNumber, pageSize, Status, Officer_name);

                return ApiResponse<PagedResult<MyReportingQueueItem>>.Ok(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<PagedResult<MyReportingQueueItem>>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<ReportingAcrDetailResponse> GetReportingDetail(string acrId, string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<ReportingAcrDetailResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<ReportingAcrDetailResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                var detail = _repo.GetReportingDetail(acrGuid, userGuid, out errorCode);
                if (detail == null)
                {
                    return ApiResponse<ReportingAcrDetailResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        errorCode == "FORBIDDEN" ? "Caller is not the active reporting authority for this ACR" :
                        errorCode == "INVALID_STATE" ? "ACR not in reporting step for this role" :
                        "Unable to fetch ACR",
                        errorCode ?? "INTERNAL_ERROR");
                }

                // CCA documents + photo (shared modal)
                var allCcaDocs = _docs.GetDocuments(acrGuid, "CCA");
                detail.Documents = allCcaDocs.FindAll(d => d.DocumentType != "OFFICER_PHOTO");
                detail.OfficerPhoto = allCcaDocs.Find(d => d.DocumentType == "OFFICER_PHOTO");

                // Caller's own step documents (RA1 or RA2)
                string section = detail.ReportingRole == "RA2" ? "RA2" : "RA1";
                detail.RoleDocuments = _docs.GetDocuments(acrGuid, section);

                return ApiResponse<ReportingAcrDetailResponse>.Ok(detail, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<ReportingAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SaveReportingDraft(string acrId, string userId,
            ReportingDraftRequest request)
        {
            try
            {
                if (request == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");

                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                if (_repo.TryUpsertReportingDraft(acrGuid, userGuid, request, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Draft saved successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller not allowed for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR not in reporting step for caller" :
                    errorCode == "ALREADY_SUBMITTED" ? "Caller already submitted their step" :
                    "Unable to save draft",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SubmitReporting(string acrId, string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                if (_repo.TrySubmitReporting(acrGuid, userGuid, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(),
                        "Reporting assessment submitted successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller not allowed for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR not in reporting step for caller" :
                    errorCode == "ALREADY_SUBMITTED" ? "Caller already submitted their step" :
                    errorCode == "BAD_REQUEST" ? "Draft is required before submitting" :
                    "Unable to submit reporting assessment",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}