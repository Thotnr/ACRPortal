using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface ICcaUseCase
    {
        ApiResponse<CcaOfficerListResponse> GetOfficers();
        ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
        ApiResponse<CcaAuthoritySuggestionResponse> GetAuthoritySuggestions(string officerUserId);
        ApiResponse<CreateAcrResponse> CreateAcr(string ccaUserId, CreateAcrRequest request);
        ApiResponse<CcaAcrDetailResponse> GetAcrDetail(string acrId);
        ApiResponse<EmptyResponse> UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request);
        ApiResponse<EmptyResponse> SubmitDraftAcr(string acrId, string ccaUserId);
        ApiResponse<AcrListResponse> GetAcrList();
    }
}