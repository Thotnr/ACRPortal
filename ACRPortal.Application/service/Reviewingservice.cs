using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class ReviewingService : IReviewingUseCase
    {
        private readonly IReviewingRepoPort _repo;

        public ReviewingService(IReviewingRepoPort repo)
        {
            _repo = repo;
        }

        public ApiResponse<MyReviewingQueueResponse> GetMyReviewingQueue(string userId)
        {
            try
            {
                if (!Guid.TryParse(userId, out Guid guid))
                    return ApiResponse<MyReviewingQueueResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                var result = _repo.GetMyReviewingQueue(guid);
                return ApiResponse<MyReviewingQueueResponse>.Ok(result, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<MyReviewingQueueResponse>.Fail(ex.Message, "INTERNAL_ERROR");
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

                var detail = _repo.GetReviewingDetail(acrGuid, userGuid, out string errorCode);
                if (detail != null)
                    return ApiResponse<ReviewingAcrDetailResponse>.Ok(detail, "Success");

                return ApiResponse<ReviewingAcrDetailResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "Caller is not the reviewing authority for this ACR" :
                    errorCode == "INVALID_STATE" ? "ACR is not in the reviewing step" :
                    "Unable to fetch ACR",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<ReviewingAcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SaveReviewingDraft(string acrId, string userId, ReviewingDraftRequest request)
        {
            try
            {
                if (request == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");
                if (!Guid.TryParse(userId, out Guid userGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                if (_repo.TryUpsertReviewingDraft(acrGuid, userGuid, request, out string errorCode))
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

                if (_repo.TrySubmitReviewing(acrGuid, userGuid, out string errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Reviewing assessment submitted successfully");

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