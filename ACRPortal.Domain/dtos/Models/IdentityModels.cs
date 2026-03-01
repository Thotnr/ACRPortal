using System;

namespace ACRPortal.Domain.DTOs.Models
{
    // 1. User Table Mapping
    public class User
    {
        public Guid UserId { get; set; }
        public string LoginId { get; set; }
        public string PasswordHash { get; set; } // SHA-256 Hashed
        public string DisplayName { get; set; }
        public bool IsActive { get; set; }
    }

    // 2. Encrypted Identity (Phone/Email)
    public class UserIdentity
    {
        public Guid IdentityId { get; set; }
        public Guid UserId { get; set; }
        public string IdentityType { get; set; } // PHONE or EMAIL
        public string IdentityValueHash { get; set; } // AES Encrypted
        public bool IsVerified { get; set; }
    }

    // 3. OTP Tracking
    public class OtpChallenge
    {
        public Guid OtpId { get; set; }
        public string IdentityHash { get; set; } // AES Encrypted LoginId
        public string OtpHashed { get; set; }    // SHA-256 Hashed OTP
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; }
    }

    // 4. Session Tracking
    public class Session
    {
        public Guid SessionId { get; set; }
        public Guid UserId { get; set; }
        public string SessionToken { get; set; } // JWT Token
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}