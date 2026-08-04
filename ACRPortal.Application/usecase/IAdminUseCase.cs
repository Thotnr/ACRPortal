using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAdminUseCase
    {
        ApiResponse<CreateUserResponse> CreateUser(CreateUserRequest request);
        ApiResponse<PagedResult<UserListItem>> GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId, int pageNumber, int pageSize);
        ApiResponse<UserDetailResponse> GetUserById(string userId);
        ApiResponse<EmptyResponse> UpdateUser(string userId, UpdateUserRequest request);
        ApiResponse<EmptyResponse> UpdateUserStatus(string userId, string userStatus);

        ApiResponse<PagedResult<AcrListItem>> GetAcrList(int pageNumber, int pageSize, string Status, string Officer_name);
        ApiResponse<CcaAcrDetailResponse> GetAcrDetail(string acrId);
    }
}
