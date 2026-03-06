using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

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

        // POST /api/user/createuser — ADMIN only (RouteAccessPolicy enforces)
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
    }
}