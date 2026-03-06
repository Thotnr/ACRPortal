using System;
using ACRPortal.Application.usecase;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.DTOs.Models; // Repo models ke liye
using ACRPortal.Domain.Security;

namespace ACRPortal.Application.service
{
    public class UserService : IUserUseCase
    {
        private readonly IUserRepoPort _repo;
        private readonly Security _security;

        public UserService(IUserRepoPort repo)
        {
            _repo = repo;
            _security = new Security(); // Domain Security Library
        }

        public ApiResponse<EmptyResponse> Signup(string displayName, string loginId, string password, string email, string phone)
        {
            try
            {
                // 1. Duplicate Check (Plain Login ID)
                if (_repo.IsUserExists(loginId))
                {
                    return ApiResponse<EmptyResponse>.Fail("User already exists", "USER_EXISTS");
                }

                // 2. Hashing Logic (Service ki zimmedari)
                string finalPwd = string.IsNullOrEmpty(password) ? "welcome@123" : password;
                string pwdHash = _security.HashWithSha256(finalPwd);

                // Email aur Phone ko bhi hash kar rahe hain as per requirement
                string hashedEmail = !string.IsNullOrEmpty(email) ? _security.EncryptWithAes(email) : null;
                string hashedPhone = !string.IsNullOrEmpty(phone) ? _security.EncryptWithAes(phone) : null;

                // 3. Repo Port call (Saara hashed data pass kar rahe hain)
                _repo.CreateUser(displayName, loginId, pwdHash, hashedEmail, hashedPhone);

                return ApiResponse<EmptyResponse>.Ok(null, "Signup successful");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
        public ApiResponse<EmptyResponse> LoginStep1(string loginId, string password, string ip, string userAgent)
        {
            try
            {
                // STEP 1: Verify Password
                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.PasswordHash != _security.HashWithSha256(password))
                    return ApiResponse<EmptyResponse>.Fail("Invalid credentials", "AUTH_FAILED");

                // STEP 2: Expire old entries & Rate Limit (Java logic Step 1 & 2)
                _repo.MarkExpiredOtpEntries(loginId);
                int recentCount = _repo.CountRecentOtpAttempts(loginId, DateTime.Now.AddSeconds(-60));
                if (recentCount >= 3) return ApiResponse<EmptyResponse>.Fail("OTP limit exceeded", "RATE_LIMIT");

                // STEP 3: Identity & OTP (Java logic Step 3)
                var identity = _repo.GetUserIdentity(user.UserId);
                //string otp = new Random().Next(100000, 999999).ToString();
                string otp = "12345";

                _repo.SaveOtpChallenge(
                    _security.EncryptWithAes(loginId),
                    _security.HashWithSha256(otp),
                    ip, userAgent
                );

                // STEP 4: Send SMS/Email (Java logic Step 4)
                // smsSender.Send(identity.Value, otp); 

                return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "OTP Sent");
            }
            catch (Exception ex) { return ApiResponse<EmptyResponse>.Fail(ex.Message, "ERROR"); }
        }

        public ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string userAgent)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"--- LOGIN STEP 2 START ---");
                System.Diagnostics.Debug.WriteLine($"Inputs: loginId={loginId}, ip={ip}");

                if (string.IsNullOrEmpty(loginId)) return ApiResponse<LoginResponse>.Fail("LoginId cannot be null", "BAD_INPUT");
                if (string.IsNullOrEmpty(otp)) return ApiResponse<LoginResponse>.Fail("OTP cannot be null", "BAD_INPUT");

                System.Diagnostics.Debug.WriteLine("Step 1: Encrypting identity...");
                string identityHash = _security.EncryptWithAes(loginId);
                string otpHashed = _security.HashWithSha256(otp);

                System.Diagnostics.Debug.WriteLine("Step 2: Checking OTP in Repo...");
                var otpEntry = _repo.GetOtp(identityHash, otpHashed, ip, userAgent);
                if (otpEntry == null) return ApiResponse<LoginResponse>.Fail("Invalid OTP or Expired", "OTP_NOT_FOUND");

                System.Diagnostics.Debug.WriteLine("Step 3: Fetching User...");
                var user = _repo.GetUserByLoginId(loginId);
                if (user == null || user.UserId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("User record not found", "USER_NULL");

                System.Diagnostics.Debug.WriteLine("Step 4: Creating Session...");
                _repo.DeactivateOldSessions(user.UserId, ip, userAgent);
                var session = _repo.CreateSession(user.UserId, ip, userAgent);

                if (session == null || session.SessionId == Guid.Empty)
                    return ApiResponse<LoginResponse>.Fail("Session creation failed", "SESSION_NULL");

                System.Diagnostics.Debug.WriteLine($"Step 5: Generating JWT for User={user.UserId}, Session={session.SessionId}");

                // YAHAN CRASH HO SAKTA HAI - Isliye variables ko pehle string mein convert kar lo
                string uidStr = user.UserId.ToString();
                string sidStr = session.SessionId.ToString();

                string token = _security.EncodeJwtToken(uidStr, sidStr, user.DisplayName, DateTime.UtcNow, DateTime.UtcNow.AddHours(2));

                System.Diagnostics.Debug.WriteLine("Step 6: Attaching Token to Session...");
                _repo.AttachSessionToken(session.SessionId, token);

                System.Diagnostics.Debug.WriteLine("--- LOGIN STEP 2 SUCCESS ---");
                return ApiResponse<LoginResponse>.Ok(new LoginResponse { Token = token, SystemRole = user.SystemRole }, "Welcome");
            }
            catch (Exception ex)
            {
                // StackTrace zaroori hai asali line number janne ke liye
                string fullError = $"Error: {ex.Message} | StackTrace: {ex.StackTrace}";
                System.Diagnostics.Debug.WriteLine(fullError);
                return ApiResponse<LoginResponse>.Fail(fullError, "INTERNAL_ERROR");
            }
        }
        //public ApiResponse<string> LoginStep1(LoginStep1Request request, string ip) => throw new NotImplementedException();
        //public ApiResponse<LoginResponse> LoginStep2(string loginId, string otp, string ip, string ua) => throw new NotImplementedException();
    }
}