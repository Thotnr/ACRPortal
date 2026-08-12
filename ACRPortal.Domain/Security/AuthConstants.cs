namespace ACRPortal.Domain.Security
{
    public static class AuthConstants
    {
        // Shared between AuthService (enforces the lockout on login) and
        // AdminService (surfaces IsLocked to the admin user list/detail screens).
        public const int MaxFailedLoginAttempts = 5;
    }
}
