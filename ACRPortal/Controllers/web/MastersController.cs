using System.Web.Mvc;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    /// <summary>
    /// Masters Controller - Admin only
    /// Manages system master data: State, Zone, Circle, Division, SubDivision, Employees
    /// </summary>
    [Authorize]
    public class MastersController : Controller
    {
        /// <summary>
        /// State Master Page
        /// URL: /Masters/State
        /// </summary>
        [NoAuth]
        public ActionResult State()
        {
            ViewBag.Title = "State Master";
            return View(); // will load Views/Masters/State.aspx
        }

        /// <summary>
        /// Zone Master Page
        /// URL: /Masters/Zone
        /// </summary>
        [NoAuth]
        public ActionResult Zone()
        {
            ViewBag.Title = "Zone Master";
            return View(); // will load Views/Masters/Zone.aspx
        }

        /// <summary>
        /// Circle Master Page
        /// URL: /Masters/Circle
        /// </summary>
        [NoAuth]
        public ActionResult Circle()
        {
            ViewBag.Title = "Circle Master";
            return View(); // will load Views/Masters/Circle.aspx
        }

        /// <summary>
        /// Division Master Page
        /// URL: /Masters/Division
        /// </summary>
        [NoAuth]
        public ActionResult Division()
        {
            ViewBag.Title = "Division Master";
            return View(); // will load Views/Masters/Division.aspx
        }

        /// <summary>
        /// Sub Division Master Page
        /// URL: /Masters/SubDivision
        /// </summary>
        [NoAuth]
        public ActionResult SubDivision()
        {
            ViewBag.Title = "Sub Division Master";
            return View(); // will load Views/Masters/SubDivision.aspx
        }

        /// <summary>
        /// Add Employee Page
        /// URL: /Masters/AddEmployee
        /// </summary>
        [NoAuth]
        public ActionResult AddEmployee()
        {
            ViewBag.Title = "Add Employee";
            return View(); // will load Views/Masters/AddEmployee.aspx
        }
    }
}
