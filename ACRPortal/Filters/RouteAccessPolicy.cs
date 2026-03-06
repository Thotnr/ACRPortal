namespace ACRPortal.Filters
{
    /// <summary>
    /// Single place that defines which system roles can access which route prefixes.
    /// Both JwtApiAuthFilter and JwtMvcAuthFilter call IsAllowed() — never duplicate this logic.
    ///
    /// Route coverage:
    ///   ADMIN    → /api/admin/*  and  /Admin/*  (user management)
    ///   CCA      → /api/cca/*   and  /CCA/*    (posting + ACR creation)
    ///   EMPLOYEE → /api/acr/*   and  /ACR/*    (self-appraisal, assessments)
    ///              /api/dashboard/*  and  /Dashboard/*
    ///
    /// Note: login routes are whitelisted via [NoAuth] and never reach this check.
    /// </summary>
    internal static class RouteAccessPolicy
    {
        public static bool IsAllowed(string systemRole, string requestPath)
        {
            string path = requestPath.ToLowerInvariant();

            // Login page is always open — safety net against redirect loops
            if (path.StartsWith("/login"))
                return true;

            // Dashboard is shared — all authenticated roles can access it
            if (path.StartsWith("/dashboard"))
                return true;

            switch (systemRole?.ToUpper())
            {
                case "ADMIN":
                    return path.StartsWith("/api/admin")
                        || path.StartsWith("/api/user/createuser")
                        || path.StartsWith("/admin");

                case "CCA":
                    return path.StartsWith("/api/cca")
                        || path.StartsWith("/cca");

                case "EMPLOYEE":
                    return path.StartsWith("/api/acr")
                        || path.StartsWith("/acr");

                default:
                    return false;
            }
        }
    }
}