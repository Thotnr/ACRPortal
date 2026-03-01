using System;
using ACRPortal.Domain.DTOs.WebToApp; // Is line se error chala jayega

namespace ACRPortal.Application.usecase
{
    public interface IUserUseCase
    {
        ApiResponse<EmptyResponse> Signup(string displayName, string loginId, string password, string email, string phone);

        ApiResponse<EmptyResponse> LoginStep1(string loginId, string password, string ip, string userAgent);

        // Ab LoginResponse red nahi dikhayega
        ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string userAgent);

       // ApiResponse<EmptyResponse> Logout(Guid sessionId);
    }
}