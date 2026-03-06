using System.Security.Claims;
using System.Web.Mvc;

namespace ACRPortal.Controllers
{
    // URL: /Dashboard/Index — same URL for all roles
    // Access is allowed by RouteAccessPolicy for ADMIN, CCA, and EMPLOYEE
    public class DashboardController : Controller
    {
        public ActionResult Index()
        {
            var principal = (ClaimsPrincipal)HttpContext.User;
            string role = principal.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;

            ViewBag.Role = role;

            return View("~/Views/Dashboard/Index.cshtml");
        }
    }
}