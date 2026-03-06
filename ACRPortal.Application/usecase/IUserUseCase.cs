using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    // Handles user management operations (admin actions)
    // Auth operations (login, logout, me, password) live in IAuthUseCase
    public interface IUserUseCase
    {
        ApiResponse<EmptyResponse> Signup(string displayName, string loginId,
            string password, string email, string phone);
    }
}