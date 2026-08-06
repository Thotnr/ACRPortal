using System;
using System.IO;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Routing;

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

        protected void Application_Error(object sender, EventArgs e)
        {
            try
            {
                Exception ex = Server.GetLastError();
                string logDir = Server.MapPath("~/App_Data/logs");
                Directory.CreateDirectory(logDir);

                string logPath = Path.Combine(logDir, "application-errors.log");
                string requestUrl = Request?.Url?.ToString() ?? "(unknown)";
                string message =
                    "==================================================" + Environment.NewLine +
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + Environment.NewLine +
                    requestUrl + Environment.NewLine +
                    ex + Environment.NewLine;

                File.AppendAllText(logPath, message);
            }
            catch
            {
                // Keep the original ASP.NET error visible if logging is unavailable.
            }
        }
    }
}
