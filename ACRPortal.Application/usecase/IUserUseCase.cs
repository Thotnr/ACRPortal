using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IUserUseCase
    {
        ApiResponse<EmptyResponse> Signup(string displayName, string loginId,
            string password, string email, string phone);
    }
}