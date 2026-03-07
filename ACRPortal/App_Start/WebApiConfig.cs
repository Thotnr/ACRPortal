using System.Web.Http;
using ACRPortal.Filters;

namespace ACRPortal
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Global JWT authentication filter — applies to every ApiController.
            // Individual public endpoints opt out using [NoAuth].
            config.Filters.Add(new JwtApiAuthFilter());

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}