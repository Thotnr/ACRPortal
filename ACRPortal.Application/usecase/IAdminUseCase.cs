using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAdminUseCase
    {
        ApiResponse<CreateUserResponse> CreateUser(CreateUserRequest request);
        ApiResponse<UserListResponse> GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId);
        ApiResponse<UserDetailResponse> GetUserById(string userId);
        ApiResponse<EmptyResponse> UpdateUser(string userId, UpdateUserRequest request);
        ApiResponse<EmptyResponse> UpdateUserStatus(string userId, string userStatus);

        /// <summary>
        /// Returns all ACTIVE EMPLOYEE users as a lightweight list for the
        /// manager dropdown on Create / Edit User forms.
        /// </summary>
        ApiResponse<ManagerListResponse> GetManagers();

        ApiResponse<PagedResult<AcrListItem>> GetAcrList(int pageNumber, int pageSize);
    }
}