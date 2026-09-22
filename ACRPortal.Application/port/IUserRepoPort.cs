using System;
using ACRPortal.Domain.DTOs.Models; // Isse Models milenge

namespace ACRPortal.Application.port
{
    public interface IUserRepoPort
    {
        // 1. Check karega ki Login ID pehle se DB mein hai ya nahi
        // Isme loginId plain text jayega as per your requirement
        bool IsUserExists(string loginId);

        // 2. Naya user record insert karne ke liye
        // Password yahan hashed aayega service se
        void CreateUser(string displayName, string loginId, string passwordHash, string email, string phone, string plainPassword);

        User GetUserByLoginId(string loginId);
        void MarkExpiredOtpEntries(string loginId);
        int CountRecentOtpAttempts(string loginId, DateTime since);
        void SaveOtpChallenge(string identityHash, string otpHashed, string ip, string agent);
        OtpChallenge GetOtp(string identityHash, string otpHashed, string ip, string agent);
        void MarkOtpAsVerified(Guid otpId);
        Session CreateSession(Guid userId, string ip, string agent);
        void DeactivateOldSessions(Guid userId, string ip, string agent);
        void AttachSessionToken(Guid sessionId, string token);
        UserIdentity GetUserIdentity(Guid userId);
    }
}