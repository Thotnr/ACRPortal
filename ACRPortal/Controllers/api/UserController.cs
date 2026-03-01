using System;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Web.Controllers
{
    [RoutePrefix("api/user")]
    public class UserController : ApiController
    {
        private readonly IUserUseCase _userUseCase;

        public UserController(IUserUseCase userUseCase)
        {
            _userUseCase = userUseCase;
        }

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

                return Request.CreateResponse(result.Success ? HttpStatusCode.Created : HttpStatusCode.BadRequest, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError,
                    ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR"));
            }
        }

        // STEP 1: Login & OTP Trigger
        [HttpPost]
        [Route("login/step1")]
        public HttpResponseMessage LoginStep1([FromBody] LoginStep1Request request)
        {
            try
            {
                if (request == null) return Request.CreateResponse(HttpStatusCode.BadRequest, "Invalid Request");

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent.ToString();

                var result = _userUseCase.LoginStep1(request.LoginId, request.Password, ip, ua);

                return Request.CreateResponse(result.Success ? HttpStatusCode.OK : HttpStatusCode.Unauthorized, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ApiResponse<EmptyResponse>.Fail(ex.Message, "ERROR"));
            }
        }

        // STEP 2: Verify OTP & Get Token
        [HttpPost]
        [Route("login/step2")]
        public HttpResponseMessage LoginStep2([FromBody] LoginStep2Request request)
        {
            try
            {
                if (request == null) return Request.CreateResponse(HttpStatusCode.BadRequest, "Invalid Request");

                string ip = GetClientIp();
                string ua = Request.Headers.UserAgent.ToString();

                // Yahan log dalo ki kya mila
                System.Diagnostics.Debug.WriteLine($"Controller Log: LoginId={request.LoginId}, Otp={request.Otp}");

                var result = _userUseCase.LoginStep2(request.LoginId, request.Otp, ip, ua);

                return Request.CreateResponse(result.Success ? HttpStatusCode.OK : HttpStatusCode.Unauthorized, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ApiResponse<LoginResponse>.Fail(ex.Message, "ERROR"));
            }
        }

        // Helper to get IP Address
        private string GetClientIp()
        {
            var request = HttpContext.Current.Request;
            string ip = request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(ip)) ip = request.ServerVariables["REMOTE_ADDR"];
            return ip;
        }
    }
}