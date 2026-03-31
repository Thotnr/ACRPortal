namespace ACRPortal.Filters
{
    internal static class RouteAccessPolicy
    {
        public static bool IsAllowed(string systemRole, string requestPath)
        {
            string path = requestPath.ToLowerInvariant();

            int apiIndex = path.IndexOf("/api/");
            if (apiIndex >= 0)
                path = path.Substring(apiIndex);

            if (path.StartsWith("/login"))
                return true;

            if (path.StartsWith("/api/auth/login")
             || path.StartsWith("/api/auth/forgot-password")
             || path.StartsWith("/api/auth/reset-password"))
                return true;

            if (path.StartsWith("/api/auth"))
                return true;

            if (path.EndsWith("/home/dashboard"))
                return true;

            if (path.StartsWith("/web/shared"))
                return true;

            switch (systemRole?.ToUpper())
            {
                case "ADMIN":
                    return path.StartsWith("/api/admin")
                        || path.StartsWith("/api/user/createuser")
                        || path.StartsWith("/admin")
                        || path.StartsWith("/masters")
                        || path.StartsWith("/api/dashboard")
                        || path.StartsWith("/api/cca")
                        || path.EndsWith("/home/dashboard")
                        || path.EndsWith("/home/cca")
                        || path.EndsWith("/home/officer");

                case "CCA":
                    return path.StartsWith("/api/cca")
                        || path.StartsWith("/cca")
                        || path.EndsWith("/home/cca")
                        || path.EndsWith("/home/dashboard")
                        || path.StartsWith("/api/admin/masters/designations")
                        || path.StartsWith("/api/admin/masters/zones")
                        || path.StartsWith("/api/admin/masters/circles")
                        || path.StartsWith("/api/admin/masters/divisions")
                        || path.StartsWith("/api/admin/masters/subdivisions")
                        || path.StartsWith("/api/admin/users")
                        || path.StartsWith("/api/dashboard")
                        || path.EndsWith("/home/cca");

                case "EMPLOYEE":
                    return path.StartsWith("/api/acr")
                        || path.StartsWith("/acr")
                        || path.EndsWith("/home/officer")
                        || path.EndsWith("/home/dashboard")
                        || path.EndsWith("/home/reporting") 
                        || path.EndsWith("/home/reviewing")
                        || path.EndsWith("/home/accepting");

                default:
                    return false;
            }
        }
    }
}