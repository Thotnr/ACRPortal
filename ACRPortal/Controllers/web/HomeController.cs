using System.Web.Mvc;

namespace ACRPortal.Controllers
{
    public class HomeController : Controller
    {
        // URL: /home/hello
        public ActionResult Hello()
        {
            ViewBag.Title = "Home";
            return View(); // will load Views/Home/Hello.aspx (if view engine supports)
        }

        // URL: /home/dashboard
        public ActionResult Dashboard()
        {
            ViewBag.Title = "Dashboard";
            return View();
        }

        // URL: /home/cca
        public ActionResult CCA()
        {
            ViewBag.Title = "Cadre Controlling Authority";
            return View();
        }
    }
}