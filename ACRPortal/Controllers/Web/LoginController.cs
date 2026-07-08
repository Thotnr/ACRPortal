using System.Web.Mvc;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    [NoAuth] // Entire controller is public — no token needed to reach the login page
    public class LoginController : Controller
    {
        // Route: /Login/UserAuth
        public ActionResult UserAuth()
        {
            return View("~/Views/Auth/Login.cshtml");
        }

        // Route: /Login/reset-password
        public ActionResult ResetPassword()
        {
            return View("~/Views/Auth/reset-password.cshtml");
        }
    }
}