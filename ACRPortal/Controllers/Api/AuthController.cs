using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Web;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    [RoutePrefix("api/auth")]
    public class AuthController : ApiController
    {
        private readonly IAuthUseCase _auth;

        public AuthController(IAuthUseCase auth)
        {
            _auth = auth;
        }

        // POST /api/auth/login/step1
        [NoAuth]
        [HttpPost]
        [Route("login/step1")]
        public HttpResponseMessage LoginStep1([FromBody] LoginStep1Request request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "LoginId and Password are required", "BAD_REQUEST");

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent != null ? Request.Headers.UserAgent.ToString() : null;

                var result = _auth.LoginStep1(request.LoginId, request.Password, ip, ua);
                return Respond(StatusStep1(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/login/step2
        [NoAuth]
        [HttpPost]
        [Route("login/step2")]
        public HttpResponseMessage LoginStep2([FromBody] LoginStep2Request request)
        {
            try
            {
                if (request == null)
                    return Fail<LoginResponse>(HttpStatusCode.BadRequest, "LoginId and OTP are required", "BAD_REQUEST");

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent != null ? Request.Headers.UserAgent.ToString() : null;

                var result = _auth.LoginStep2(request.LoginId, request.Otp, ip, ua);
                return Respond(StatusStep2(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail<LoginResponse>(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/logout
        [HttpPost]
        [Route("logout")]
        public HttpResponseMessage Logout()
        {
            try
            {
                var principal = (ClaimsPrincipal)User;
                var sidClaim = principal.FindFirst("sid");

                if (sidClaim == null || string.IsNullOrEmpty(sidClaim.Value))
                    return Fail(HttpStatusCode.Unauthorized, "Token missing or invalid", "TOKEN_INVALID");

                var result = _auth.Logout(sidClaim.Value);

                var response = Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);

                // Expire the jwt_token cookie so the browser clears it immediately
                var expiredCookie = new System.Net.Http.Headers.CookieHeaderValue("jwt_token", "")
                {
                    Expires = DateTimeOffset.UtcNow.AddDays(-1),
                    Path = "/",
                    HttpOnly = true
                };
                response.Headers.AddCookies(new[] { expiredCookie });

                return response;
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // GET /api/auth/me
        [HttpGet]
        [Route("me")]
        public HttpResponseMessage Me()
        {
            try
            {
                var principal = (ClaimsPrincipal)User;
                var uidClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
                string userId = uidClaim != null ? uidClaim.Value : null;

                var result = _auth.GetMe(userId);
                return Respond(StatusMe(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail<MeResponse>(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/change-password
        [HttpPost]
        [Route("change-password")]
        public HttpResponseMessage ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "CurrentPassword and NewPassword are required", "BAD_REQUEST");

                var principal = (ClaimsPrincipal)User;
                var uidClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
                string userId = uidClaim != null ? uidClaim.Value : null;

                var result = _auth.ChangePassword(userId, request.CurrentPassword, request.NewPassword);
                return Respond(StatusChangePassword(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/forgot-password
        [NoAuth]
        [HttpPost]
        [Route("forgot-password")]
        public HttpResponseMessage ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "LoginId is required", "BAD_REQUEST");

                var result = _auth.ForgotPassword(request.LoginId);
                HttpStatusCode status = result.ErrorCode == "INTERNAL_ERROR"
                    ? HttpStatusCode.InternalServerError : HttpStatusCode.OK;
                return Respond(status, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/forgot-password/verify-otp
        [NoAuth]
        [HttpPost]
        [Route("forgot-password/verify-otp")]
        public HttpResponseMessage VerifyResetOtp([FromBody] VerifyResetOtpRequest request)
        {
            try
            {
                if (request == null)
                    return Fail<ResetOtpVerifiedResponse>(HttpStatusCode.BadRequest, "LoginId and OTP are required", "BAD_REQUEST");

                var result = _auth.VerifyResetOtp(request.LoginId, request.Otp);
                return Respond(StatusVerifyResetOtp(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail<ResetOtpVerifiedResponse>(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/auth/reset-password
        [NoAuth]
        [HttpPost]
        [Route("reset-password")]
        public HttpResponseMessage ResetPassword([FromBody] ResetPasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "All fields are required", "BAD_REQUEST");

                var result = _auth.ResetPassword(request.LoginId, request.ResetToken, request.NewPassword, request.ConfirmPassword);
                return Respond(StatusResetPassword(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Status helpers                                                      //
        // ------------------------------------------------------------------ //
        private static HttpStatusCode StatusStep1(string code, bool ok)
        {
            if (code == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (code == "AUTH_FAILED") return HttpStatusCode.Unauthorized;
            if (code == "ACCOUNT_INACTIVE") return HttpStatusCode.Forbidden;
            if (code == "ACCOUNT_LOCKED") return HttpStatusCode.Forbidden;
            if (code == "PHONE_NOT_FOUND") return HttpStatusCode.BadRequest;
            if (code == "SMS_FAILED") return HttpStatusCode.InternalServerError;
            if (code == "RATE_LIMIT") return (HttpStatusCode)429;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        private static HttpStatusCode StatusStep2(string code, bool ok)
        {
            if (code == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (code == "OTP_INVALID") return HttpStatusCode.Unauthorized;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        private static HttpStatusCode StatusMe(string code, bool ok)
        {
            if (code == "TOKEN_INVALID") return HttpStatusCode.Unauthorized;
            if (code == "USER_NOT_FOUND") return HttpStatusCode.NotFound;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        private static HttpStatusCode StatusChangePassword(string code, bool ok)
        {
            if (code == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (code == "TOKEN_INVALID") return HttpStatusCode.Unauthorized;
            if (code == "WRONG_PASSWORD") return HttpStatusCode.BadRequest;
            if (code == "SAME_PASSWORD") return HttpStatusCode.BadRequest;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        private static HttpStatusCode StatusVerifyResetOtp(string code, bool ok)
        {
            if (code == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (code == "OTP_INVALID") return HttpStatusCode.Unauthorized;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        private static HttpStatusCode StatusResetPassword(string code, bool ok)
        {
            if (code == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (code == "PASSWORD_MISMATCH") return HttpStatusCode.BadRequest;
            if (code == "TOKEN_INVALID") return HttpStatusCode.BadRequest;
            if (code == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return ok ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  Response helpers                                                    //
        // ------------------------------------------------------------------ //
        private HttpResponseMessage Respond<T>(HttpStatusCode status, ApiResponse<T> body)
            where T : class, new()
        {
            return Request.CreateResponse(status, body);
        }

        // EmptyResponse shortcut
        private HttpResponseMessage Fail(HttpStatusCode status, string message, string code)
        {
            return Request.CreateResponse(status,
                ApiResponse<EmptyResponse>.Fail(message, code));
        }

        // Typed shortcut for non-EmptyResponse failures
        private HttpResponseMessage Fail<T>(HttpStatusCode status, string message, string code)
            where T : class, new()
        {
            return Request.CreateResponse(status,
                ApiResponse<T>.Fail(message, code));
        }

        private string GetClientIp()
        {
            var req = HttpContext.Current.Request;
            string ip = req.ServerVariables["HTTP_X_FORWARDED_FOR"];
            return string.IsNullOrEmpty(ip) ? req.ServerVariables["REMOTE_ADDR"] : ip;
        }
    }
}