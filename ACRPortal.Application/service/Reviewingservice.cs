using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class ReviewingService : IReviewingUseCase
    {
        private readonly IReviewingRepoPort _repo;
        private readonly IDocumentRepoPort _docs;

        public ReviewingService(IReviewingRepoPort repo, IDocumentRepoPort docs)
        {
            _repo = repo;
            _docs = docs;
        }

        public ApiResponse<PagedResult<MyReviewingQueueItem>> GetMyReviewingQueue(
            string userId, 
            int pageNumber, 
            int pageSize,
            string Status,
            string Officer_name)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid guid))
                    return ApiResponse<PagedResult<MyReviewingQueueItem>>.Fail("Invalid user id", "TOKEN_INVALID");

                if (pageNumber <= 0) pageNumber = 1;
                if (pageSize <= 0 || pageSize > 100) pageSize = 10;

                var result = _repo.GetMyReviewingQueue(guid, pageNumber, pageSize, Status, Officer_name);

                return ApiResponse<PagedResult<MyReviewingQueueItem>>.Ok(result);
            }
            catch (Exception ex)
            {
                return ApiResponse<PagedResult<MyReviewingQueueItem>>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<ReviewingAcrDetailResponse> GetReviewingDetail(string acrId, string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<ReviewingAcrDetailResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<ReviewingAcrDetailResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                var detail = _repo.GetReviewingDetail(acrGuid, userGuid, out errorCode);
                if (detail == null)
                {
                    return ApiResponse<ReviewingAcrDetailResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        errorCode == "FORBIDDEN" ? "Caller is not the reviewing authority for this ACR" :
                        errorCode == "INVALID_STATE" ? "ACR is not in the reviewing step" :
                        "Unable to fetch ACR",
                        errorCode ?? "INTERNAL_ERROR");
                }

                // CCA documents + photo (shared modal)
                var allCcaDocs = _docs.GetDocuments(acrGuid, "CCA");
                detail.Documents = allCcaDocs.FindAll(d => d.DocumentType != "OFFICER_PHOTO");
                detail.OfficerPhoto = allCcaDocs.Find(d => d.DocumentType == "OFFICER_PHOTO");

                // Caller's own step documents (RVA)
                detail.RoleDocuments = _docs.GetDocuments(acrGuid, "RVA");

                return ApiResponse<ReviewingAcrDetailResponse>.Ok(detail, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<ReviewingAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SaveReviewingDraft(string acrId, string userId,
            ReviewingDraftRequest request)
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
                if (_repo.TryUpsertReviewingDraft(acrGuid, userGuid, request, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Draft saved successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller is not the reviewing authority for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR is not in the reviewing step" :
                    errorCode == "ALREADY_SUBMITTED" ? "Reviewing assessment already submitted" :
                    "Unable to save draft",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SubmitReviewing(string acrId, string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                if (_repo.TrySubmitReviewing(acrGuid, userGuid, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(),
                        "Reviewing assessment submitted successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller is not the reviewing authority for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR is not in the reviewing step" :
                    errorCode == "BAD_REQUEST" ? "No draft saved — save a draft before submitting" :
                    errorCode == "ALREADY_SUBMITTED" ? "Reviewing assessment already submitted" :
                    "Unable to submit",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}