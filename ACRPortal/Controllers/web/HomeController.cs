using System.Web.Mvc;

namespace ACRPortal.Controllers
{
    public class HomeController : Controller
    {
        // URL: /home/hello
        public ActionResult Hello()
        {
            return View(); // will load Views/Home/Hello.aspx (if view engine supports)
        }
    }
}