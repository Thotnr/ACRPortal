using System;

namespace ACRPortal.Domain.DTOs.Models
{
    public class User
    {
        public Guid UserId { get; set; }
        public string LoginId { get; set; }
        public string PasswordHash { get; set; }
        public string DisplayName { get; set; }
        public string SystemRole { get; set; }
        public string UserStatus { get; set; }       // raw: PENDING / ACTIVE / INACTIVE
        public bool IsActive { get { return UserStatus == "ACTIVE"; } }  // computed, read-only
    }

    public class UserIdentity
    {
        public Guid IdentityId { get; set; }
        public Guid UserId { get; set; }
        public string IdentityType { get; set; }
        public string IdentityValueHash { get; set; }
        public bool IsVerified { get; set; }
    }

    public class OtpChallenge
    {
        public Guid OtpId { get; set; }
        public string IdentityHash { get; set; }
        public string OtpHashed { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; }
    }

    public class Session
    {
        public Guid SessionId { get; set; }
        public Guid UserId { get; set; }
        public string SessionToken { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}