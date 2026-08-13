using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IReviewingUseCase
    {
        ApiResponse<PagedResult<MyReviewingQueueItem>> GetMyReviewingQueue(string userId, int pageNumber, int pageSize, string Status, string Officer_name);
        ApiResponse<ReviewingAcrDetailResponse> GetReviewingDetail(string acrId, string userId);
        ApiResponse<EmptyResponse> SaveReviewingDraft(string acrId, string userId, ReviewingDraftRequest request);
        ApiResponse<EmptyResponse> SubmitReviewing(string acrId, string userId);
    }
}