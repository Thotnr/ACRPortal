using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface ICcaUseCase
    {
        ApiResponse<CcaOfficerListResponse> GetOfficers();
        ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
        ApiResponse<CreateAcrResponse> CreateAcr(string ccaUserId, CreateAcrRequest request);
        ApiResponse<EmptyResponse> UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request);
        ApiResponse<EmptyResponse> SubmitDraftAcr(string acrId, string ccaUserId);
        ApiResponse<AcrListResponse> GetAcrList();
    }
}