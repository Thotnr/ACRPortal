using System;
using ACRPortal.Domain.DTOs.Models;

namespace ACRPortal.Application.port
{
    public interface IAuthRepoPort
    {
        // Login Step 1
        User GetUserByLoginId(string loginId);
        void MarkExpiredOtpEntries(string identityHash);
        int CountRecentOtpAttempts(string identityHash, int withinSeconds);
        void SaveOtpChallenge(string identityHash, string otpHashed, string ip, string agent);

        // Login Step 2
        OtpChallenge GetOtp(string identityHash, string otpHashed);
        void MarkOtpAsVerified(Guid otpId);
        Session CreateSession(Guid userId, string ip, string agent);
        void DeactivateOldSessions(Guid userId);
        void AttachSessionToken(Guid sessionId, string token, DateTime expiresAt);

        // Logout
        void RevokeSession(string plainSessionId);

        // Me
        User GetUserById(Guid userId);

        // Change Password
        void UpdatePassword(Guid userId, string newPasswordHash);

        // Forgot Password
        void SaveResetToken(string loginId, string resetTokenHash);

        // Reset Password
        User GetUserByResetToken(string loginId, string resetTokenHash);
        void ClearResetToken(Guid userId);
    }
}