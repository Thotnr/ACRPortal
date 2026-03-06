using System;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // API 2 — Login Step 2 response
    public class LoginResponse
    {
        public string Token { get; set; }
        public DateTime ExpiresAt { get; set; }
        public string UserId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
    }

    // API 4 — /me response
    public class MeResponse
    {
        public string UserId { get; set; }
        public string LoginId { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }
    }

    // API 5 — Change password request
    public class ChangePasswordRequest
    {
        public string CurrentPassword { get; set; }
        public string NewPassword { get; set; }
    }

    // API 6 — Forgot password request
    public class ForgotPasswordRequest
    {
        public string LoginId { get; set; }
    }

    // API 7 — Reset password request
    public class ResetPasswordRequest
    {
        public string LoginId { get; set; }
        public string ResetToken { get; set; }
        public string NewPassword { get; set; }
    }
}