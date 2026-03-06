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

        // ------------------------------------------------------------------ //
        //  API 1 — POST /api/auth/login/step1                                 //
        // ------------------------------------------------------------------ //
        [NoAuth]
        [HttpPost]
        [Route("login/step1")]
        public HttpResponseMessage LoginStep1([FromBody] LoginStep1Request request)
        {
            try
            {
                if (request == null)
                    return Respond(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("LoginId and Password are required", "BAD_REQUEST"));

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent != null ? Request.Headers.UserAgent.ToString() : null;

                var result = _auth.LoginStep1(request.LoginId, request.Password, ip, ua);

                return Respond(GetStatusStep1(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private static HttpStatusCode GetStatusStep1(string errorCode, bool success)
        {
            if (errorCode == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (errorCode == "AUTH_FAILED") return HttpStatusCode.Unauthorized;
            if (errorCode == "ACCOUNT_INACTIVE") return HttpStatusCode.Forbidden;
            if (errorCode == "RATE_LIMIT") return (HttpStatusCode)429;
            if (errorCode == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  API 2 — POST /api/auth/login/step2                                 //
        // ------------------------------------------------------------------ //
        [NoAuth]
        [HttpPost]
        [Route("login/step2")]
        public HttpResponseMessage LoginStep2([FromBody] LoginStep2Request request)
        {
            try
            {
                if (request == null)
                    return Respond(HttpStatusCode.BadRequest,
                        ApiResponse<LoginResponse>.Fail("LoginId and OTP are required", "BAD_REQUEST"));

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent != null ? Request.Headers.UserAgent.ToString() : null;

                var result = _auth.LoginStep2(request.LoginId, request.Otp, ip, ua);

                return Respond(GetStatusStep2(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<LoginResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private static HttpStatusCode GetStatusStep2(string errorCode, bool success)
        {
            if (errorCode == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (errorCode == "OTP_INVALID") return HttpStatusCode.Unauthorized;
            if (errorCode == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  API 3 — POST /api/auth/logout                                      //
        // ------------------------------------------------------------------ //
        [HttpPost]
        [Route("logout")]
        public HttpResponseMessage Logout()
        {
            try
            {
                var principal = (ClaimsPrincipal)User;
                var encryptedSidClaim = principal.FindFirst("sid");

                if (encryptedSidClaim == null)
                    return Respond(HttpStatusCode.Unauthorized,
                        ApiResponse<EmptyResponse>.Fail("Token missing or invalid", "TOKEN_INVALID"));

                var result = _auth.Logout(encryptedSidClaim.Value);

                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        // ------------------------------------------------------------------ //
        //  API 4 — GET /api/auth/me                                           //
        // ------------------------------------------------------------------ //
        [HttpGet]
        [Route("me")]
        public HttpResponseMessage Me()
        {
            try
            {
                var principal = (ClaimsPrincipal)User;
                string plainUserId = principal.FindFirst(ClaimTypes.NameIdentifier) != null
                    ? principal.FindFirst(ClaimTypes.NameIdentifier).Value
                    : null;

                var result = _auth.GetMe(plainUserId);

                return Respond(GetStatusMe(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<MeResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private static HttpStatusCode GetStatusMe(string errorCode, bool success)
        {
            if (errorCode == "TOKEN_INVALID") return HttpStatusCode.Unauthorized;
            if (errorCode == "USER_NOT_FOUND") return HttpStatusCode.NotFound;
            if (errorCode == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  API 5 — POST /api/auth/change-password                             //
        // ------------------------------------------------------------------ //
        [HttpPost]
        [Route("change-password")]
        public HttpResponseMessage ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Respond(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("CurrentPassword and NewPassword are required", "BAD_REQUEST"));

                var principal = (ClaimsPrincipal)User;
                string plainUserId = principal.FindFirst(ClaimTypes.NameIdentifier) != null
                    ? principal.FindFirst(ClaimTypes.NameIdentifier).Value
                    : null;

                var result = _auth.ChangePassword(plainUserId, request.CurrentPassword, request.NewPassword);

                return Respond(GetStatusChangePassword(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private static HttpStatusCode GetStatusChangePassword(string errorCode, bool success)
        {
            if (errorCode == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (errorCode == "TOKEN_INVALID") return HttpStatusCode.Unauthorized;
            if (errorCode == "WRONG_PASSWORD") return HttpStatusCode.BadRequest;
            if (errorCode == "SAME_PASSWORD") return HttpStatusCode.BadRequest;
            if (errorCode == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  API 6 — POST /api/auth/forgot-password                             //
        // ------------------------------------------------------------------ //
        [NoAuth]
        [HttpPost]
        [Route("forgot-password")]
        public HttpResponseMessage ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Respond(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("LoginId is required", "BAD_REQUEST"));

                var result = _auth.ForgotPassword(request.LoginId);

                HttpStatusCode status = result.ErrorCode == "INTERNAL_ERROR"
                    ? HttpStatusCode.InternalServerError
                    : HttpStatusCode.OK;

                return Respond(status, result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        // ------------------------------------------------------------------ //
        //  API 7 — POST /api/auth/reset-password                              //
        // ------------------------------------------------------------------ //
        [NoAuth]
        [HttpPost]
        [Route("reset-password")]
        public HttpResponseMessage ResetPassword([FromBody] ResetPasswordRequest request)
        {
            try
            {
                if (request == null)
                    return Respond(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("All fields are required", "BAD_REQUEST"));

                var result = _auth.ResetPassword(request.LoginId, request.ResetToken, request.NewPassword);

                return Respond(GetStatusResetPassword(result.ErrorCode, result.Success), result);
            }
            catch (Exception ex)
            {
                return Respond(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private static HttpStatusCode GetStatusResetPassword(string errorCode, bool success)
        {
            if (errorCode == "BAD_REQUEST") return HttpStatusCode.BadRequest;
            if (errorCode == "TOKEN_INVALID") return HttpStatusCode.BadRequest;
            if (errorCode == "INTERNAL_ERROR") return HttpStatusCode.InternalServerError;
            return success ? HttpStatusCode.OK : HttpStatusCode.BadRequest;
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                             //
        // ------------------------------------------------------------------ //

        private HttpResponseMessage Respond<T>(HttpStatusCode status, ApiResponse<T> body)
            where T : class, new()
        {
            return Request.CreateResponse(status, body);
        }

        private string GetClientIp()
        {
            var req = HttpContext.Current.Request;
            string ip = req.ServerVariables["HTTP_X_FORWARDED_FOR"];
            return string.IsNullOrEmpty(ip) ? req.ServerVariables["REMOTE_ADDR"] : ip;
        }
    }
}