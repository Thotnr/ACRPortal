using System;
using System.Linq;
using System.Security.Claims;
using System.Web;
using System.Web.Mvc;
using ACRPortal.Domain.Security;

namespace ACRPortal.Filters
{
    /// <summary>
    /// Global MVC authentication + authorisation filter.
    /// Registered once in FilterConfig — applies to every MVC Controller.
    ///
    /// Flow:
    ///   1. Skip if [NoAuth] is present on the action or controller
    ///   2. Extract token from "jwt_token" cookie (set by login page on success)
    ///   3. Validate token via Security.DecodeJwtToken
    ///   4. Decrypt NameIdentifier claim → plain userId
    ///   5. Extract Role claim
    ///   6. Check RouteAccessPolicy — redirect to /Unauthorized if role not allowed
    ///   7. Rebuild ClaimsPrincipal with plain userId and set HttpContext.User
    /// </summary>
    public class JwtMvcAuthFilter : ActionFilterAttribute
    {
        private readonly Security _security = new Security();

        private const string CookieName   = "jwt_token";
        private const string LoginPath    = "~/Login/UserAuth";
        private const string DeniedPath   = "~/Unauthorized";

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // Step 1 — skip public endpoints marked with [NoAuth]
            if (HasNoAuthAttribute(filterContext))
            {
                base.OnActionExecuting(filterContext);
                return;
            }

            // Step 2 — extract token from cookie
            var cookie = filterContext.HttpContext.Request.Cookies[CookieName];
            if (cookie == null || string.IsNullOrWhiteSpace(cookie.Value))
            {
                RedirectToLogin(filterContext);
                return;
            }

            string token = cookie.Value;

            // Step 3 — validate token (signature + expiry)
            ClaimsPrincipal principal;
            try
            {
                principal = _security.DecodeJwtToken(token);
            }
            catch (Exception)
            {
                // Token invalid or expired — clear the stale cookie and send to login
                ExpireCookie(filterContext.HttpContext.Response, CookieName);
                RedirectToLogin(filterContext);
                return;
            }

            // Step 4 — decrypt the NameIdentifier claim to get plain userId
            var encryptedUserIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
            if (encryptedUserIdClaim == null)
            {
                ExpireCookie(filterContext.HttpContext.Response, CookieName);
                RedirectToLogin(filterContext);
                return;
            }

            string plainUserId;
            try
            {
                plainUserId = _security.DecryptWithAes(encryptedUserIdClaim.Value);
            }
            catch (Exception)
            {
                ExpireCookie(filterContext.HttpContext.Response, CookieName);
                RedirectToLogin(filterContext);
                return;
            }

            // Step 5 — extract Role claim
            var roleClaim = principal.FindFirst(ClaimTypes.Role);
            if (roleClaim == null || string.IsNullOrWhiteSpace(roleClaim.Value))
            {
                ExpireCookie(filterContext.HttpContext.Response, CookieName);
                RedirectToLogin(filterContext);
                return;
            }

            string systemRole = roleClaim.Value;

            // Step 6 — role vs route check
            string requestPath = filterContext.HttpContext.Request.Path;
            if (!RouteAccessPolicy.IsAllowed(systemRole, requestPath))
            {
                filterContext.Result = new RedirectResult(VirtualPathUtility.ToAbsolute(DeniedPath));
                return;
            }

            // Step 7 — rebuild principal with plain userId and set on HttpContext
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, plainUserId),
                new Claim(ClaimTypes.Role, systemRole)
            };
            var identity       = new ClaimsIdentity(claims, "JWT");
            var cleanPrincipal = new ClaimsPrincipal(identity);

            filterContext.HttpContext.User = cleanPrincipal;

            base.OnActionExecuting(filterContext);
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                             //
        // ------------------------------------------------------------------ //
        private static bool HasNoAuthAttribute(ActionExecutingContext filterContext)
        {
            // Check action-level first, then controller-level
            bool onAction     = filterContext.ActionDescriptor
                                    .GetCustomAttributes(typeof(NoAuthAttribute), false).Any();
            bool onController = filterContext.ActionDescriptor.ControllerDescriptor
                                    .GetCustomAttributes(typeof(NoAuthAttribute), false).Any();
            return onAction || onController;
        }

        private static void RedirectToLogin(ActionExecutingContext filterContext)
        {
            filterContext.Result = new RedirectResult(VirtualPathUtility.ToAbsolute(LoginPath));
        }

        private static void ExpireCookie(HttpResponseBase response, string cookieName)
        {
            var expiredCookie = new HttpCookie(cookieName)
            {
                Expires  = DateTime.Now.AddDays(-1),
                HttpOnly = true
            };
            response.Cookies.Add(expiredCookie);
        }
    }
}
