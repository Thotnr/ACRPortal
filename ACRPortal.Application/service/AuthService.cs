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

                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.PasswordHash != _security.HashWithSha256(password))
                    return ApiResponse<EmptyResponse>.Fail("Invalid credentials", "AUTH_FAILED");

                if (user.UserStatus != "ACTIVE")
                    return ApiResponse<EmptyResponse>.Fail("Your account is not active", "ACCOUNT_INACTIVE");

                string identityHash = _security.EncryptWithAes(loginId);

                _repo.MarkExpiredOtpEntries(identityHash);
                int recentCount = _repo.CountRecentOtpAttempts(identityHash, 60);
                if (recentCount >= 3)
                    return ApiResponse<EmptyResponse>.Fail("Too many OTP requests. Please wait 60 seconds", "RATE_LIMIT");

                // TODO: replace hardcoded OTP with: new Random().Next(100000, 999999).ToString()
                string otp = "211916";
                _repo.SaveOtpChallenge(identityHash, _security.HashWithSha256(otp), ip, userAgent);

                // TODO: send otp via SMS/email

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

                var otpEntry = _repo.GetOtp(identityHash, otpHashed);
                if (otpEntry == null)
                    return ApiResponse<LoginResponse>.Fail("Invalid or expired OTP", "OTP_INVALID");

                // Consume immediately — prevents reuse
                _repo.MarkOtpAsVerified(otpEntry.OtpId);

                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.UserId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("User record not found", "INTERNAL_ERROR");

                _repo.DeactivateOldSessions(user.UserId);
                var session = _repo.CreateSession(user.UserId, ip, userAgent);
                if (session == null || session.SessionId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("Session creation failed", "INTERNAL_ERROR");

                // JWT must use UTC (spec requirement)
                DateTime nowUtc = DateTime.UtcNow;
                DateTime expiresUtc = nowUtc.AddHours(2);
                // Local time for client display and DB (avoids UTC vs IST mismatch)
                DateTime expiresLocal = DateTime.Now.AddHours(2);

                string token = _security.EncodeJwtToken(
                    user.UserId.ToString(),
                    session.SessionId.ToString(),
                    user.SystemRole,
                    nowUtc,
                    expiresUtc
                );

                // DB expiry is recomputed in SQL as DATEADD(HOUR,2,GETDATE()) — expiresLocal only for response
                _repo.AttachSessionToken(session.SessionId, token, expiresLocal);

                return ApiResponse<LoginResponse>.Ok(new LoginResponse
                {
                    Token = token,
                    ExpiresAt = expiresLocal,
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
                Guid userId;
                if (!Guid.TryParse(plainUserId, out userId))
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

                Guid userId;
                if (!Guid.TryParse(plainUserId, out userId))
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

                if (user != null && user.IsActive)
                {
                    string resetToken = Guid.NewGuid().ToString("N");
                    string resetTokenHash = _security.HashWithSha256(resetToken);

                    _repo.SaveResetToken(loginId, resetTokenHash); // expiry = GETDATE()+30min in SQL

                    // TODO: send resetToken via email before production
                    System.Diagnostics.Debug.WriteLine("[DEV ONLY] Reset token for " + loginId + ": " + resetToken);
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