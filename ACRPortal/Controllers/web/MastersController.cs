using System.Web.Mvc;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    public class MastersController : Controller
    {
        public ActionResult Designation()
        {
            ViewBag.Title = "Designation Master";
            return View();
        }

        public ActionResult State()
        {
            ViewBag.Title = "State Master";
            return View();
        }

        public ActionResult Zone()
        {
            ViewBag.Title = "Zone Master";
            return View();
        }

        public ActionResult Circle()
        {
            ViewBag.Title = "Circle Master";
            return View();
        }

        public ActionResult Division()
        {
            ViewBag.Title = "Division Master";
            return View();
        }

        public ActionResult SubDivision()
        {
            ViewBag.Title = "Sub Division Master";
            return View();
        }

        public ActionResult AddEmployee()
        {
            ViewBag.Title = "Add Employee";
            return View();
        }
    }
}