using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IReportingUseCase
    {
        ApiResponse<MyReportingQueueResponse> GetMyReportingQueue(string userId);
        ApiResponse<ReportingAcrDetailResponse> GetReportingDetail(string acrId, string userId);
        ApiResponse<EmptyResponse> SaveReportingDraft(string acrId, string userId, ReportingDraftRequest request);
        ApiResponse<EmptyResponse> SubmitReporting(string acrId, string userId);
    }
}

