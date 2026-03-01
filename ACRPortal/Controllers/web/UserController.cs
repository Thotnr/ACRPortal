using System;
using System.Web.Mvc;

namespace ACRPortal.Web.Controllers.web
{
    public class LoginController : Controller
    {
        // Route: /Login/UserAuth
        public ActionResult UserAuth()
        {
            // Ye check karta hai ki file sahi jagah hai ya nahi
            return View("~/Views/Auth/Login.cshtml");
        }
    }
}