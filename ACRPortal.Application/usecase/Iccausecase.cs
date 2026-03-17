using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface ICcaUseCase
    {
        ApiResponse<CcaOfficerListResponse> GetOfficers();
        ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
        ApiResponse<CreateAcrResponse> CreateAcr(string ccaUserId, CreateAcrRequest request);
        ApiResponse<AcrListResponse> GetAcrList();
    }
}