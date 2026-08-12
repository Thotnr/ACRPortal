using System;
using System.Security.Cryptography;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Application.service
{
    public class AuthService : IAuthUseCase
    {
        private const string PurposeLogin = "LOGIN";
        private const string PurposePasswordReset = "PASSWORD_RESET";

        private readonly IAuthRepoPort _repo;
        private readonly ISmsSender _sms;
        private readonly Security _security;

        public AuthService(IAuthRepoPort repo, ISmsSender sms)
        {
            _repo = repo;
            _sms = sms;
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
                if (user != null && user.IsLocked)
                    return ApiResponse<EmptyResponse>.Fail("Your account is blocked due to too many failed attempts. Contact the administrator.", "ACCOUNT_LOCKED");

                if (user == null || user.PasswordHash != _security.HashWithSha256(password))
                {
                    if (user != null)
                        _repo.IncrementFailedLoginCount(loginId);
                    return ApiResponse<EmptyResponse>.Fail("Invalid credentials", "AUTH_FAILED");
                }

                if (user.UserStatus != "ACTIVE")
                    return ApiResponse<EmptyResponse>.Fail("Your account is not active", "ACCOUNT_INACTIVE");

                string identityHash = _security.EncryptWithAes(loginId);

                _repo.MarkExpiredOtpEntries(identityHash);
                int recentCount = _repo.CountRecentOtpAttempts(identityHash, PurposeLogin, 60);
                if (recentCount >= 3)
                    return ApiResponse<EmptyResponse>.Fail("Too many OTP requests. Please wait 60 seconds", "RATE_LIMIT");

                string phone = _repo.GetPhoneForLoginId(loginId);
                if (string.IsNullOrWhiteSpace(phone))
                    return ApiResponse<EmptyResponse>.Fail("Mobile number not registered. Contact administrator.", "PHONE_NOT_FOUND");

                string otp = GenerateOtp();
                // Must match the DLT-registered template text for dlt_template_id exactly —
                // any deviation gets silently scrubbed by the carrier even though the
                // InstaAlerts gateway itself accepts the submission (HTTP 200).
                string message = "OTP for your Transaction is " + otp + " and is Valid for Next 10 Minutes.-DHBVNL";

                var smsResult = _sms.Send(phone, message, isLoginOtp: true);
                if (!smsResult.Success)
                    return ApiResponse<EmptyResponse>.Fail("Failed to send OTP. Please try again.", "SMS_FAILED");

                _repo.SaveOtpChallenge(identityHash, _security.HashWithSha256(otp), PurposeLogin, ip, userAgent);

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

                var otpEntry = _repo.GetOtp(identityHash, otpHashed, PurposeLogin);
                if (otpEntry == null)
                {
                    _repo.IncrementFailedLoginCount(loginId);
                    return ApiResponse<LoginResponse>.Fail("Invalid or expired OTP", "OTP_INVALID");
                }

                // Consume immediately — prevents reuse
                _repo.MarkOtpAsVerified(otpEntry.OtpId);

                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.UserId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("User record not found", "INTERNAL_ERROR");

                // Full login succeeded (password + OTP) — clear the lockout counter.
                _repo.ResetFailedLoginCount(user.UserId);

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
        //  API 6 — Forgot Password (sends OTP to registered mobile)           //
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
                    string phone = _repo.GetPhoneForLoginId(loginId);
                    if (!string.IsNullOrWhiteSpace(phone))
                    {
                        string identityHash = _security.EncryptWithAes(loginId);

                        _repo.MarkExpiredOtpEntries(identityHash);
                        int recentCount = _repo.CountRecentOtpAttempts(identityHash, PurposePasswordReset, 60);
                        if (recentCount < 3)
                        {
                            string otp = GenerateOtp();
                            // Must match the DLT-registered template text exactly (see LoginStep1) —
                            // this is the reset-password template registered under the same entity id.
                            string message = "OTP for resetting the password of Online Portal is " + otp + ". DHBVN";

                            var smsResult = _sms.Send(phone, message, isLoginOtp: false);
                            if (smsResult.Success)
                            {
                                _repo.SaveOtpChallenge(identityHash, _security.HashWithSha256(otp), PurposePasswordReset, null, null);
                            }
                        }
                    }
                }

                // Generic response regardless of outcome — avoids leaking account existence.
                return ApiResponse<EmptyResponse>.Ok(null,
                    "If this account exists, an OTP has been sent to the registered mobile number");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 6b — Verify Reset OTP (issues a short-lived reset session)     //
        // ------------------------------------------------------------------ //
        public ApiResponse<ResetOtpVerifiedResponse> VerifyResetOtp(string loginId, string otp)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId) || string.IsNullOrWhiteSpace(otp))
                    return ApiResponse<ResetOtpVerifiedResponse>.Fail("LoginId and OTP are required", "BAD_REQUEST");

                string identityHash = _security.EncryptWithAes(loginId);
                string otpHashed = _security.HashWithSha256(otp);

                var otpEntry = _repo.GetOtp(identityHash, otpHashed, PurposePasswordReset);
                if (otpEntry == null)
                    return ApiResponse<ResetOtpVerifiedResponse>.Fail("Invalid or expired OTP", "OTP_INVALID");

                _repo.MarkOtpAsVerified(otpEntry.OtpId);

                string resetToken = Guid.NewGuid().ToString("N");
                string resetTokenHash = _security.HashWithSha256(resetToken);
                _repo.SaveResetToken(loginId, resetTokenHash); // expiry = GETDATE()+10min in SQL

                return ApiResponse<ResetOtpVerifiedResponse>.Ok(
                    new ResetOtpVerifiedResponse { ResetToken = resetToken },
                    "OTP verified. You can now set a new password.");
            }
            catch (Exception ex)
            {
                return ApiResponse<ResetOtpVerifiedResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  API 7 — Reset Password                                             //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> ResetPassword(string loginId, string resetToken, string newPassword, string confirmPassword)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(loginId) ||
                    string.IsNullOrWhiteSpace(resetToken) ||
                    string.IsNullOrWhiteSpace(newPassword) ||
                    string.IsNullOrWhiteSpace(confirmPassword))
                    return ApiResponse<EmptyResponse>.Fail("All fields are required", "BAD_REQUEST");

                if (newPassword != confirmPassword)
                    return ApiResponse<EmptyResponse>.Fail("New password and confirm password do not match", "PASSWORD_MISMATCH");

                string resetTokenHash = _security.HashWithSha256(resetToken);

                var user = _repo.GetUserByResetToken(loginId, resetTokenHash);
                if (user == null)
                    return ApiResponse<EmptyResponse>.Fail("Reset session is invalid or has expired", "TOKEN_INVALID");

                _repo.UpdatePassword(user.UserId, _security.HashWithSha256(newPassword));
                _repo.ClearResetToken(user.UserId);

                // Password changed — force re-login everywhere by killing any existing sessions.
                _repo.DeactivateOldSessions(user.UserId);

                return ApiResponse<EmptyResponse>.Ok(null,
                    "Password reset successful. Please login with your new password.");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                            //
        // ------------------------------------------------------------------ //

        // Zero-padding isn't needed — the % range keeps every result at 6 digits —
        // but this uses a CSPRNG instead of System.Random, unlike the OTP scheme
        // being ported from (which also wasn't zero-padded, so lengths varied 4-6 digits).
        private static string GenerateOtp()
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] bytes = new byte[4];
                rng.GetBytes(bytes);
                uint value = BitConverter.ToUInt32(bytes, 0);
                int otp = (int)(value % 900000) + 100000;
                return otp.ToString();
            }
        }
    }
}