using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAuthUseCase
    {
        ApiResponse<EmptyResponse> LoginStep1(string loginId, string password, string ip, string userAgent);
        ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string userAgent);
        ApiResponse<EmptyResponse> Logout(string encryptedSessionId);
        ApiResponse<MeResponse> GetMe(string plainUserId);
        ApiResponse<EmptyResponse> ChangePassword(string plainUserId, string currentPassword, string newPassword);
        ApiResponse<EmptyResponse> ForgotPassword(string loginId);
        ApiResponse<EmptyResponse> ResetPassword(string loginId, string resetToken, string newPassword);
    }
}