using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IReportingUseCase
    {
        ApiResponse<PagedResult<MyReportingQueueItem>> GetMyReportingQueue(string userId, int pageNumber, int pageSize, string Status, string Officer_name);
        ApiResponse<ReportingAcrDetailResponse> GetReportingDetail(string acrId, string userId);
        ApiResponse<EmptyResponse> SaveReportingDraft(string acrId, string userId, ReportingDraftRequest request);
        ApiResponse<EmptyResponse> SubmitReporting(string acrId, string userId);
    }
}
