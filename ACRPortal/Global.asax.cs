using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Http;

namespace ACRPortal
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            AreaRegistration.RegisterAllAreas();

            // Register global MVC filters (includes JwtMvcAuthFilter)
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);

            // Register Web API config (includes JwtApiAuthFilter)
            GlobalConfiguration.Configure(WebApiConfig.Register);

            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }
    }
}