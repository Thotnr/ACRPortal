using System;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Filters;

namespace ACRPortal.Controllers
{
    [RoutePrefix("api/user")]
    public class UserController : ApiController
    {
        private readonly IUserUseCase _userUseCase;

        public UserController(IUserUseCase userUseCase)
        {
            _userUseCase = userUseCase;
        }

        // Protected — only ADMIN can create users (enforced by RouteAccessPolicy)
        [HttpPost]
        [Route("createuser")]
        public HttpResponseMessage CreateUser([FromBody] SignupRequest request)
        {
            try
            {
                if (request == null)
                    return Request.CreateResponse(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("Invalid request data", "BAD_REQUEST"));

                var result = _userUseCase.Signup(
                    request.DisplayName,
                    request.LoginId,
                    request.Password,
                    request.Email,
                    request.Phone
                );

                return Request.CreateResponse(
                    result.Success ? HttpStatusCode.Created : HttpStatusCode.BadRequest, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        // Public — no token needed to reach the login step
        [NoAuth]
        [HttpPost]
        [Route("login/step1")]
        public HttpResponseMessage LoginStep1([FromBody] LoginStep1Request request)
        {
            try
            {
                if (request == null)
                    return Request.CreateResponse(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("Invalid request", "BAD_REQUEST"));

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent?.ToString();

                var result = _userUseCase.LoginStep1(request.LoginId, request.Password, ip, ua);

                return Request.CreateResponse(
                    result.Success ? HttpStatusCode.OK : HttpStatusCode.Unauthorized, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        // Public — no token needed to verify OTP and receive the token
        [NoAuth]
        [HttpPost]
        [Route("login/step2")]
        public HttpResponseMessage LoginStep2([FromBody] LoginStep2Request request)
        {
            try
            {
                if (request == null)
                    return Request.CreateResponse(HttpStatusCode.BadRequest,
                        ApiResponse<EmptyResponse>.Fail("Invalid request", "BAD_REQUEST"));

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent?.ToString();

                var result = _userUseCase.LoginStep2(request.LoginId, request.Otp, ip, ua);

                return Request.CreateResponse(
                    result.Success ? HttpStatusCode.OK : HttpStatusCode.Unauthorized, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError,
                    ApiResponse<LoginResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        private string GetClientIp()
        {
            var req = HttpContext.Current.Request;
            string ip = req.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(ip)) ip = req.ServerVariables["REMOTE_ADDR"];
            return ip;
        }
    }
}