using System.Net;
using System.Net.Http;
using System.Web.Http;
using System;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers.Api
{
    [RoutePrefix("api/admin")]
    public class AdminController : ApiController
    {
        private readonly IAdminUseCase _admin;

        public AdminController(IAdminUseCase admin)
        {
            _admin = admin;
        }

        // ------------------------------------------------------------------ //
        //  GET api/admin/users                                                //
        // ------------------------------------------------------------------ //
        [HttpGet]
        [Route("users")]
        public HttpResponseMessage GetAllUsers(
            [FromUri] string role = null,
            [FromUri] string status = null,
            [FromUri] int? dsgId = null,
            [FromUri] int? zoneId = null,
            [FromUri] int? divisionId = null,
            [FromUri] int pageNumber = 1,
            [FromUri] int pageSize = 10)
        {
            var result = _admin.GetAllUsers(
                role, status, dsgId, zoneId, divisionId,
                pageNumber, pageSize);

            return Request.CreateResponse(MapStatus(result.ErrorCode), result);
        }

        // ------------------------------------------------------------------ //
        //  GET api/admin/users/{userId}                                       //
        // ------------------------------------------------------------------ //
        [HttpGet]
        [Route("users/{userId}")]
        public HttpResponseMessage GetUserById(string userId)
        {
            var result = _admin.GetUserById(userId);
            return Request.CreateResponse(MapStatus(result.ErrorCode), result);
        }

        // ------------------------------------------------------------------ //
        //  PATCH api/admin/users/{userId}                                     //
        // ------------------------------------------------------------------ //
        [HttpPatch]
        [Route("users/{userId}")]
        public HttpResponseMessage UpdateUser(string userId, [FromBody] UpdateUserRequest request)
        {
            var result = _admin.UpdateUser(userId, request);
            return Request.CreateResponse(MapStatus(result.ErrorCode), result);
        }

        // ------------------------------------------------------------------ //
        //  PATCH api/admin/users/{userId}/status                              //
        // ------------------------------------------------------------------ //
        [HttpPatch]
        [Route("users/{userId}/status")]
        public HttpResponseMessage UpdateUserStatus(string userId, [FromBody] UpdateUserStatusRequest request)
        {
            if (request == null)
            {
                var bad = ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");
                return Request.CreateResponse(HttpStatusCode.BadRequest, bad);
            }

            var result = _admin.UpdateUserStatus(userId, request.UserStatus);
            return Request.CreateResponse(MapStatus(result.ErrorCode), result);
        }

        // ================================================================== //
        //  Helpers                                                            //
        // ================================================================== //

        private static HttpStatusCode MapStatus(string errorCode)
        {
            if (errorCode == null) return HttpStatusCode.OK;
            switch (errorCode)
            {
                case "BAD_REQUEST":
                case "INVALID_DSG":
                case "INVALID_STATE":
                case "INVALID_ZONE":
                case "INVALID_CIRCLE":
                case "INVALID_DIVISION":
                case "INVALID_SUBDIVISION":
                case "INVALID_MANAGER":
                    return HttpStatusCode.BadRequest;
                case "USER_EXISTS":
                case "DUPLICATE_IDENTITY":
                    return HttpStatusCode.Conflict;
                case "TOKEN_INVALID":
                    return HttpStatusCode.Unauthorized;
                case "FORBIDDEN":
                    return HttpStatusCode.Forbidden;
                case "USER_NOT_FOUND":
                    return HttpStatusCode.NotFound;
                default:
                    return HttpStatusCode.InternalServerError;
            }
        }

        [HttpGet]
        [Route("acr")]
        public HttpResponseMessage GetAcrList(
            int pageNumber = 1, 
            int pageSize = 10, 
            [FromUri] string Status = null,
            [FromUri] string Officer_name = null)
        {
            try
            {
                var result = _admin.GetAcrList(pageNumber, pageSize, Status, Officer_name);
                return Request.CreateResponse(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        [HttpGet]
        [Route("acr/{acrId}")]
        public HttpResponseMessage GetAcrDetail(string acrId)
        {
            try
            {
                var result = _admin.GetAcrDetail(acrId);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : HttpStatusCode.InternalServerError;

                return Request.CreateResponse(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        private HttpResponseMessage Fail(string message, string errorCode = "INTERNAL_ERROR",
            HttpStatusCode code = HttpStatusCode.InternalServerError)
            => Request.CreateResponse(code, ApiResponse<EmptyResponse>.Fail(message, errorCode));
    }
}
