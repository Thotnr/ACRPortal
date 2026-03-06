using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Application.service
{
    public class AuthService : IAuthUseCase
    {
        private readonly IAuthRepoPort _repo;
        private readonly Security _security;

        private static readonly DateTime TokenExpiry = DateTime.UtcNow.AddHours(2);

        public AuthService(IAuthRepoPort repo)
        {
            _repo = repo;
            _security = new Security();
        }

        // ------------------------------------------------------------------ //
        //  API 1 — Login Step 1                                               //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> LoginStep1(string loginId, string password, string ip, string userAgent)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId) || string.IsNullOrWhiteSpace(password))
                    return ApiResponse<EmptyResponse>.Fail("LoginId and Password are required", "BAD_REQUEST");

                // Verify credentials
                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.PasswordHash != _security.HashWithSha256(password))
                    return ApiResponse<EmptyResponse>.Fail("Invalid credentials", "AUTH_FAILED");

                // Check account status — must be ACTIVE
                if (user.UserStatus != "ACTIVE")
                    return ApiResponse<EmptyResponse>.Fail("Your account is not active", "ACCOUNT_INACTIVE");

                // Bug fix #3 — pass identityHash not plain loginId
                string identityHash = _security.EncryptWithAes(loginId);

                // Expire stale OTPs then rate-limit check
                _repo.MarkExpiredOtpEntries(identityHash);
                int recentCount = _repo.CountRecentOtpAttempts(identityHash, DateTime.UtcNow.AddSeconds(-60));
                if (recentCount >= 3)
                    return ApiResponse<EmptyResponse>.Fail("Too many OTP requests. Please wait 60 seconds", "RATE_LIMIT");

                // Generate OTP and save challenge
                // TODO: replace hardcoded OTP with: new Random().Next(100000, 999999).ToString()
                string otp = "12345";
                _repo.SaveOtpChallenge(
                    identityHash,
                    _security.HashWithSha256(otp),
                    ip, userAgent
                );

                // TODO: send otp via email/SMS

                return ApiResponse<EmptyResponse>.Ok(null, "OTP sent successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 2 — Login Step 2                                               //
        // ------------------------------------------------------------------ //
        public ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string userAgent)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId) || string.IsNullOrWhiteSpace(otp))
                    return ApiResponse<LoginResponse>.Fail("LoginId and OTP are required", "BAD_REQUEST");

                string identityHash = _security.EncryptWithAes(loginId);
                string otpHashed = _security.HashWithSha256(otp);

                // Validate OTP (expiry checked in SQL)
                var otpEntry = _repo.GetOtp(identityHash, otpHashed);
                if (otpEntry == null)
                    return ApiResponse<LoginResponse>.Fail("Invalid or expired OTP", "OTP_INVALID");

                // Consume OTP immediately so it cannot be reused
                _repo.MarkOtpAsVerified(otpEntry.OtpId);

                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.UserId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("User record not found", "INTERNAL_ERROR");

                // Revoke any existing active sessions then create a fresh one
                _repo.DeactivateOldSessions(user.UserId);
                var session = _repo.CreateSession(user.UserId, ip, userAgent);
                if (session == null || session.SessionId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("Session creation failed", "INTERNAL_ERROR");

                DateTime expiresAt = DateTime.UtcNow.AddHours(2);
                string token = _security.EncodeJwtToken(
                    user.UserId.ToString(),
                    session.SessionId.ToString(),
                    user.SystemRole,
                    DateTime.UtcNow,
                    expiresAt
                );

                _repo.AttachSessionToken(session.SessionId, token, expiresAt);

                return ApiResponse<LoginResponse>.Ok(new LoginResponse
                {
                    Token = token,
                    ExpiresAt = expiresAt,
                    UserId = user.UserId.ToString(),
                    DisplayName = user.DisplayName,
                    SystemRole = user.SystemRole
                }, "Login successful");
            }
            catch (Exception ex)
            {
                return ApiResponse<LoginResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 3 — Logout                                                     //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> Logout(string encryptedSessionId)
        {
            try
            {
                // Decrypt the sid claim that was stored encrypted in the token
                string plainSessionId = _security.DecryptWithAes(encryptedSessionId);
                _repo.RevokeSession(plainSessionId);
                return ApiResponse<EmptyResponse>.Ok(null, "Logged out successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 4 — Get Me                                                     //
        // ------------------------------------------------------------------ //
        public ApiResponse<MeResponse> GetMe(string plainUserId)
        {
            try
            {
                if (!Guid.TryParse(plainUserId, out Guid userId))
                    return ApiResponse<MeResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                var user = _repo.GetUserById(userId);
                if (user == null)
                    return ApiResponse<MeResponse>.Fail("User no longer exists", "USER_NOT_FOUND");

                return ApiResponse<MeResponse>.Ok(new MeResponse
                {
                    UserId = user.UserId.ToString(),
                    LoginId = user.LoginId,
                    DisplayName = user.DisplayName,
                    SystemRole = user.SystemRole,
                    UserStatus = user.UserStatus
                });
            }
            catch (Exception ex)
            {
                return ApiResponse<MeResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 5 — Change Password                                            //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> ChangePassword(string plainUserId, string currentPassword, string newPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(currentPassword) || string.IsNullOrWhiteSpace(newPassword))
                    return ApiResponse<EmptyResponse>.Fail("CurrentPassword and NewPassword are required", "BAD_REQUEST");

                if (!Guid.TryParse(plainUserId, out Guid userId))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                var user = _repo.GetUserById(userId);
                if (user == null)
                    return ApiResponse<EmptyResponse>.Fail("User not found", "INTERNAL_ERROR");

                if (user.PasswordHash != _security.HashWithSha256(currentPassword))
                    return ApiResponse<EmptyResponse>.Fail("Current password is incorrect", "WRONG_PASSWORD");

                string newHash = _security.HashWithSha256(newPassword);

                if (user.PasswordHash == newHash)
                    return ApiResponse<EmptyResponse>.Fail("New password cannot be the same as current", "SAME_PASSWORD");

                _repo.UpdatePassword(userId, newHash);
                return ApiResponse<EmptyResponse>.Ok(null, "Password changed successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 6 — Forgot Password                                            //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> ForgotPassword(string loginId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId))
                    return ApiResponse<EmptyResponse>.Fail("LoginId is required", "BAD_REQUEST");

                var user = _repo.GetUserByLoginId(loginId);

                // Always return 200 regardless — never reveal if loginId exists
                if (user != null && user.IsActive)
                {
                    string resetToken = Guid.NewGuid().ToString("N"); // plain token sent in email
                    string resetTokenHash = _security.HashWithSha256(resetToken);
                    DateTime expiry = DateTime.UtcNow.AddMinutes(30);

                    _repo.SaveResetToken(loginId, resetTokenHash, expiry);

                    // TODO: send resetToken via email to user's registered address
                }

                return ApiResponse<EmptyResponse>.Ok(null,
                    "If this account exists, a password reset link has been sent");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 7 — Reset Password                                             //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> ResetPassword(string loginId, string resetToken, string newPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId) ||
                    string.IsNullOrWhiteSpace(resetToken) ||
                    string.IsNullOrWhiteSpace(newPassword))
                    return ApiResponse<EmptyResponse>.Fail("All fields are required", "BAD_REQUEST");

                string resetTokenHash = _security.HashWithSha256(resetToken);

                var user = _repo.GetUserByResetToken(loginId, resetTokenHash);
                if (user == null)
                    return ApiResponse<EmptyResponse>.Fail("Reset token is invalid or has expired", "TOKEN_INVALID");

                _repo.UpdatePassword(user.UserId, _security.HashWithSha256(newPassword));
                _repo.ClearResetToken(user.UserId);

                return ApiResponse<EmptyResponse>.Ok(null,
                    "Password reset successful. Please login with your new password.");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}