using System.Web.Mvc;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    public class MastersController : Controller
    {
        public ActionResult Designation()
        {
            ViewBag.Title = "Designation Master";
            return View("~/Views/Masters/Designation.aspx");
        }

        public ActionResult State()
        {
            ViewBag.Title = "State Master";
            return View("~/Views/Masters/State.aspx");
        }

        public ActionResult Zone()
        {
            ViewBag.Title = "Zone Master";
            return View("~/Views/Masters/Zone.aspx");
        }

        public ActionResult Circle()
        {
            ViewBag.Title = "Circle Master";
            return View("~/Views/Masters/Circle.aspx");
        }

        public ActionResult Division()
        {
            ViewBag.Title = "Division Master";
            return View("~/Views/Masters/Division.aspx");
        }

        public ActionResult SubDivision()
        {
            ViewBag.Title = "Sub Division Master";
            return View("~/Views/Masters/SubDivision.aspx");
        }

        public ActionResult AddEmployee()
        {
            ViewBag.Title = "Add Employee";
            return View("~/Views/Masters/AddEmployee.aspx");
        }
    }
}
