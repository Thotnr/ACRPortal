using System.Web.Mvc;

namespace ACRPortal.Controllers
{
    public class AuthController : Controller
    {
        // GET: /auth/index (login page)
        public ActionResult Index()
        {
            return View();
        }
    }
}