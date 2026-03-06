using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Filters
{
    /// <summary>
    /// Global Web API authentication + authorisation filter.
    /// Registered once in WebApiConfig — applies to every ApiController.
    ///
    /// Flow:
    ///   1. Skip if [NoAuth] is present on the action or controller
    ///   2. Extract Bearer token from Authorization header
    ///   3. Validate token via Security.DecodeJwtToken
    ///   4. Decrypt NameIdentifier claim → plain userId
    ///   5. Extract Role claim
    ///   6. Check RouteAccessPolicy — 403 if role not allowed for this path
    ///   7. Rebuild ClaimsPrincipal with plain userId and set Thread.CurrentPrincipal
    /// </summary>
    public class JwtApiAuthFilter : IAuthenticationFilter
    {
        private readonly Security _security = new Security();

        public bool AllowMultiple => false;

        // ------------------------------------------------------------------ //
        //  AuthenticateAsync — main logic                                      //
        // ------------------------------------------------------------------ //
        public Task AuthenticateAsync(HttpAuthenticationContext context, CancellationToken cancellationToken)
        {
            // Step 1 — skip public endpoints marked with [NoAuth]
            if (HasNoAuthAttribute(context.ActionContext))
                return Task.FromResult(0);

            // Step 2 — extract token from "Authorization: Bearer <token>"
            var authHeader = context.Request.Headers.Authorization;
            if (authHeader == null || !authHeader.Scheme.Equals("Bearer", StringComparison.OrdinalIgnoreCase)
                || string.IsNullOrWhiteSpace(authHeader.Parameter))
            {
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Unauthorized,
                    "Authorization header missing or invalid.", "UNAUTHORIZED");
                return Task.FromResult(0);
            }

            string token = authHeader.Parameter;

            // Step 3 — validate token (signature + expiry)
            ClaimsPrincipal principal;
            try
            {
                principal = _security.DecodeJwtToken(token);
            }
            catch (Exception)
            {
                // Expired, tampered, or otherwise invalid token
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Unauthorized,
                    "Token is invalid or has expired.", "TOKEN_INVALID");
                return Task.FromResult(0);
            }

            // Step 4 — decrypt the NameIdentifier claim to get plain userId
            var encryptedUserIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
            if (encryptedUserIdClaim == null)
            {
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Unauthorized,
                    "Token payload is malformed.", "TOKEN_MALFORMED");
                return Task.FromResult(0);
            }

            string plainUserId;
            try
            {
                plainUserId = _security.DecryptWithAes(encryptedUserIdClaim.Value);
            }
            catch (Exception)
            {
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Unauthorized,
                    "Token payload could not be decrypted.", "TOKEN_DECRYPT_FAILED");
                return Task.FromResult(0);
            }

            // Step 5 — extract Role claim
            var roleClaim = principal.FindFirst(ClaimTypes.Role);
            if (roleClaim == null || string.IsNullOrWhiteSpace(roleClaim.Value))
            {
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Unauthorized,
                    "Token is missing role information.", "TOKEN_MALFORMED");
                return Task.FromResult(0);
            }

            string systemRole = roleClaim.Value;

            // Step 6 — role vs route check
            string requestPath = context.Request.RequestUri.AbsolutePath;
            if (!RouteAccessPolicy.IsAllowed(systemRole, requestPath))
            {
                context.ErrorResult = BuildErrorResult(context.Request, HttpStatusCode.Forbidden,
                    "You do not have permission to access this resource.", "FORBIDDEN");
                return Task.FromResult(0);
            }

            // Step 7 — rebuild principal with plain (decrypted) userId so controllers
            //           can read it directly via User.FindFirst(ClaimTypes.NameIdentifier)
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, plainUserId),
                new Claim(ClaimTypes.Role, systemRole)
            };
            var identity  = new ClaimsIdentity(claims, "JWT");
            var cleanPrincipal = new ClaimsPrincipal(identity);

            // Set on both the context and the thread
            context.Principal = cleanPrincipal;
            Thread.CurrentPrincipal = cleanPrincipal;

            return Task.FromResult(0);
        }

        // ------------------------------------------------------------------ //
        //  ChallengeAsync — attach WWW-Authenticate header on 401 responses   //
        // ------------------------------------------------------------------ //
        public Task ChallengeAsync(HttpAuthenticationChallengeContext context, CancellationToken cancellationToken)
        {
            // Only add the header — do not override the error result set above
            context.Result = new AddChallengeOnUnauthorizedResult("Bearer", context.Result);
            return Task.FromResult(0);
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                             //
        // ------------------------------------------------------------------ //
        private static bool HasNoAuthAttribute(HttpActionContext actionContext)
        {
            // Check the action first, then the controller
            bool onAction     = actionContext.ActionDescriptor
                                    .GetCustomAttributes<NoAuthAttribute>().Any();
            bool onController = actionContext.ActionDescriptor.ControllerDescriptor
                                    .GetCustomAttributes<NoAuthAttribute>().Any();
            return onAction || onController;
        }

        private static IHttpActionResult BuildErrorResult(HttpRequestMessage request,
            HttpStatusCode statusCode, string message, string errorCode)
        {
            var body = statusCode == HttpStatusCode.Forbidden
                ? ApiResponse<EmptyResponse>.Fail(message, errorCode)
                : ApiResponse<EmptyResponse>.Fail(message, errorCode);

            return new ErrorMessageResult(request, statusCode, body);
        }
    }

    // ------------------------------------------------------------------ //
    //  Helper: adds WWW-Authenticate challenge header                      //
    // ------------------------------------------------------------------ //
    internal class AddChallengeOnUnauthorizedResult : IHttpActionResult
    {
        private readonly string _scheme;
        private readonly IHttpActionResult _inner;

        public AddChallengeOnUnauthorizedResult(string scheme, IHttpActionResult inner)
        {
            _scheme = scheme;
            _inner  = inner;
        }

        public async Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            var response = await _inner.ExecuteAsync(cancellationToken);
            if (response.StatusCode == HttpStatusCode.Unauthorized)
                response.Headers.WwwAuthenticate.Add(
                    new System.Net.Http.Headers.AuthenticationHeaderValue(_scheme));
            return response;
        }
    }

    // ------------------------------------------------------------------ //
    //  Helper: wraps ApiResponse into an IHttpActionResult                 //
    // ------------------------------------------------------------------ //
    internal class ErrorMessageResult : IHttpActionResult
    {
        private readonly HttpRequestMessage _request;
        private readonly HttpStatusCode _statusCode;
        private readonly ApiResponse<EmptyResponse> _body;

        public ErrorMessageResult(HttpRequestMessage request, HttpStatusCode statusCode,
            ApiResponse<EmptyResponse> body)
        {
            _request    = request;
            _statusCode = statusCode;
            _body       = body;
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            var response = _request.CreateResponse(_statusCode, _body);
            return Task.FromResult(response);
        }
    }
}
