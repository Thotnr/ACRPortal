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

        public ActionResult Officer()
        {
            ViewBag.Title = "Officer Dashboard";
            return View();
        }

        public ActionResult Reporting()
        {
            ViewBag.Title = "Reporting Dashboard";
            return View();
        }

        public ActionResult Reviewing()
        {
            ViewBag.Title = "Reviewing Dashboard";
            return View();
        }
        
        public ActionResult Accepting()
        {
            ViewBag.Title = "Accepting Dashboard";
            return View();
        }
    }
}