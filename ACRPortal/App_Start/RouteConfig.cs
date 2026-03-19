using System.Web.Mvc;
using System.Web.Routing;

namespace ACRPortal
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            // Login
            routes.MapRoute(
                name: "Login",
                url: "Login/{action}",
                defaults: new { controller = "Login", action = "UserAuth" }
            );

            // Admin dashboard → DashboardController.Admin()
            routes.MapRoute(
                name: "AdminDashboard",
                url: "Admin/Dashboard",
                defaults: new { controller = "Dashboard", action = "Admin" }
            );

            // CCA dashboard → DashboardController.CCA()
            routes.MapRoute(
                name: "CCADashboard",
                url: "CCA/Dashboard",
                defaults: new { controller = "Dashboard", action = "CCA" }
            );

            routes.MapRoute(
                name: "Masters",
                url: "Masters/{action}",
                defaults: new { controller = "Masters", action = "State" }
            );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Dashboard", action = "Index", id = UrlParameter.Optional }
            );         
        }
    }
}