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

        // Legacy aliases so old /Home/* master URLs still resolve under the current Masters controller.
        public ActionResult Designation()
        {
            return RedirectToAction("Designation", "Masters");
        }

        public ActionResult State()
        {
            return RedirectToAction("State", "Masters");
        }

        public ActionResult Zone()
        {
            return RedirectToAction("Zone", "Masters");
        }

        public ActionResult Circle()
        {
            return RedirectToAction("Circle", "Masters");
        }

        public ActionResult Division()
        {
            return RedirectToAction("Division", "Masters");
        }

        public ActionResult SubDivision()
        {
            return RedirectToAction("SubDivision", "Masters");
        }

        public ActionResult AddEmployee()
        {
            return RedirectToAction("AddEmployee", "Masters");
        }
    }
}
