using System.Web.Mvc;
using System.Web.Routing;

namespace ACRPortal
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            // Explicit login route — keeps the URL clean and unambiguous
            routes.MapRoute(
                name: "Login",
                url: "Login/{action}",
                defaults: new { controller = "Login", action = "UserAuth" }
            );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Login", action = "UserAuth", id = UrlParameter.Optional }
            );
        }
    }
}