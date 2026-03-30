using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAcceptingUseCase
    {
        ApiResponse<PagedResult<MyAcceptingQueueItem>> GetMyAcceptingQueue(string userId, int pageNumber, int pageSize);
        ApiResponse<AcceptingAcrDetailResponse> GetAcceptingDetail(string acrId, string userId);
        ApiResponse<EmptyResponse> SubmitDecision(string acrId, string userId, AcceptingDecisionRequest request);
    }
}