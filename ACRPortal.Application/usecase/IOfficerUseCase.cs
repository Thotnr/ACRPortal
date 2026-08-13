using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IOfficerUseCase
    {
        ApiResponse<PagedResult<MyAcrListItem>> GetMyAcrs(string officerUserId, string status, int pageNumber, int pageSize);
        ApiResponse<AcrDetailResponse> GetAcrDetail(string acrId, string officerUserId);
        ApiResponse<EmptyResponse> SaveSelfAppraisalDraft(string acrId, string officerUserId, SelfAppraisalDraftRequest request);
        ApiResponse<EmptyResponse> SubmitSelfAppraisal(string acrId, string officerUserId);
    }
}

