using System.Web.Mvc;
using ACRPortal.Filters;

namespace ACRPortal
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());

            // Global JWT authentication filter — applies to every MVC Controller.
            // Individual public actions/controllers opt out using [NoAuth].
            filters.Add(new JwtMvcAuthFilter());
        }
    }
}