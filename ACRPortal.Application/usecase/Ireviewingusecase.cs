using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IReviewingUseCase
    {
        ApiResponse<MyReviewingQueueResponse> GetMyReviewingQueue(string userId);
        ApiResponse<ReviewingAcrDetailResponse> GetReviewingDetail(string acrId, string userId);
        ApiResponse<EmptyResponse> SaveReviewingDraft(string acrId, string userId, ReviewingDraftRequest request);
        ApiResponse<EmptyResponse> SubmitReviewing(string acrId, string userId);
    }
}