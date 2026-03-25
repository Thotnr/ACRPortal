using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class AcceptingService : IAcceptingUseCase
    {
        private readonly IAcceptingRepoPort _repo;
        private readonly IDocumentRepoPort _docs;

        public AcceptingService(IAcceptingRepoPort repo, IDocumentRepoPort docs)
        {
            _repo = repo;
            _docs = docs;
        }

        public ApiResponse<MyAcceptingQueueResponse> GetMyAcceptingQueue(string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid guid))
                    return ApiResponse<MyAcceptingQueueResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                var result = _repo.GetMyAcceptingQueue(guid);
                return ApiResponse<MyAcceptingQueueResponse>.Ok(result, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<MyAcceptingQueueResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<AcceptingAcrDetailResponse> GetAcceptingDetail(string acrId, string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<AcceptingAcrDetailResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<AcceptingAcrDetailResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                var detail = _repo.GetAcceptingDetail(acrGuid, userGuid, out errorCode);
                if (detail == null)
                {
                    return ApiResponse<AcceptingAcrDetailResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        errorCode == "FORBIDDEN" ? "Caller is not the accepting authority for this ACR" :
                        errorCode == "INVALID_STATE" ? "ACR is not in the accepting step" :
                        "Unable to fetch ACR",
                        errorCode ?? "INTERNAL_ERROR");
                }

                // Attach CCA documents + photo (section = 'CCA') for shared modal
                var allCcaDocs = _docs.GetDocuments(acrGuid, "CCA");
                detail.Documents = allCcaDocs.FindAll(d => d.DocumentType != "OFFICER_PHOTO");
                detail.OfficerPhoto = allCcaDocs.Find(d => d.DocumentType == "OFFICER_PHOTO");

                // Preserve caller-step documents separately (section = 'AA')
                detail.RoleDocuments = _docs.GetDocuments(acrGuid, "AA");

                return ApiResponse<AcceptingAcrDetailResponse>.Ok(detail, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<AcceptingAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SubmitDecision(string acrId, string userId,
            AcceptingDecisionRequest request)
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
                if (_repo.TrySubmitDecision(acrGuid, userGuid, request, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Decision submitted successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller is not the accepting authority for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR is not in the accepting step" :
                    errorCode == "ALREADY_DECIDED" ? "A decision has already been recorded for this ACR" :
                    "Unable to submit decision",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}