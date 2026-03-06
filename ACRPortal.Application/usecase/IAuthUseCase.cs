using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAuthUseCase
    {
        // API 1
        ApiResponse<EmptyResponse> LoginStep1(string loginId, string password, string ip, string userAgent);

        // API 2
        ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string userAgent);

        // API 3
        ApiResponse<EmptyResponse> Logout(string encryptedSessionId);

        // API 4
        ApiResponse<MeResponse> GetMe(string plainUserId);

        // API 5
        ApiResponse<EmptyResponse> ChangePassword(string plainUserId, string currentPassword, string newPassword);

        // API 6
        ApiResponse<EmptyResponse> ForgotPassword(string loginId);

        // API 7
        ApiResponse<EmptyResponse> ResetPassword(string loginId, string resetToken, string newPassword);
    }
}