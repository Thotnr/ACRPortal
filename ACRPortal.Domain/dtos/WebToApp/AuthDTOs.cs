using System;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    public class LoginResponse
    {
        public string Token { get; set; }
        public DateTime ExpiresAt { get; set; }
        public string UserId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
    }

    public class MeResponse
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }
    }

    public class ChangePasswordRequest
    {
        public string CurrentPassword { get; set; }
        public string NewPassword { get; set; }
    }

    public class ForgotPasswordRequest
    {
        public string LoginId { get; set; }
    }

    public class VerifyResetOtpRequest
    {
        public string LoginId { get; set; }
        public string Otp { get; set; }
    }

    public class ResetOtpVerifiedResponse
    {
        public string ResetToken { get; set; }
    }

    public class ResetPasswordRequest
    {
        public string LoginId { get; set; }
        public string ResetToken { get; set; }
        public string NewPassword { get; set; }
        public string ConfirmPassword { get; set; }
    }
}