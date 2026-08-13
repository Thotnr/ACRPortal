using System.Net;
using System.Net.Http;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Filters;

namespace ACRPortal.Controllers.Api
{
    /// <summary>
    /// Handles user creation.
    /// Route kept as /api/user/createuser for backward compatibility.
    /// Delegates directly to IAdminUseCase — the old IUserUseCase is no longer needed for this endpoint.
    /// </summary>
    [RoutePrefix("api/user")]
    public class UserController : ApiController
    {
        private readonly IAdminUseCase _admin;

        public UserController(IAdminUseCase admin)
        {
            _admin = admin;
        }

        // POST api/user/createuser
        [HttpPost]
        [Route("createuser")]
        public HttpResponseMessage CreateUser([FromBody] CreateUserRequest request)
        {
            var result = _admin.CreateUser(request);

            HttpStatusCode status;
            switch (result.ErrorCode)
            {
                case null: status = HttpStatusCode.Created; break;
                case "USER_EXISTS": status = HttpStatusCode.Conflict; break;
                case "TOKEN_INVALID": status = HttpStatusCode.Unauthorized; break;
                case "FORBIDDEN": status = HttpStatusCode.Forbidden; break;
                case "INTERNAL_ERROR": status = HttpStatusCode.InternalServerError; break;
                default: status = HttpStatusCode.BadRequest; break;
            }

            return Request.CreateResponse(status, result);
        }
    }
}