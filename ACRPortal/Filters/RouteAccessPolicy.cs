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

            switch (systemRole?.ToUpper())
            {
                case "ADMIN":
                    return path.StartsWith("/api/admin")
                        || path.StartsWith("/api/user/createuser")
                        || path.StartsWith("/admin")
                        || path.EndsWith("/home/dashboard")
                        || path.EndsWith("/home/cca")
                        || path.EndsWith("/masters")
                        || path.EndsWith("/masters/designation")
                        || path.EndsWith("/masters/zone")
                        || path.EndsWith("/masters/state")
                        || path.EndsWith("/masters/circle")
                        || path.EndsWith("/masters/division")
                        || path.EndsWith("/masters/subdivision")
                        || path.EndsWith("/masters/addemployee");

                case "CCA":
                    return path.StartsWith("/api/cca")   // covers /api/cca/acr/{id}/docs too
                        || path.StartsWith("/cca")
                        || path == "/api/admin/masters/designations";

                case "EMPLOYEE":
                    return path.StartsWith("/api/acr")   // covers /api/acr/{id}/docs too
                        || path.StartsWith("/acr");

                default:
                    return false;
            }
        }
    }
}