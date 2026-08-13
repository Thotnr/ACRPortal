using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers.Api
{
    [RoutePrefix("api/acr")]
    public class AcceptingApiController : ApiController
    {
        private readonly IAcceptingUseCase _accepting;

        public AcceptingApiController(IAcceptingUseCase accepting)
        {
            _accepting = accepting;
        }

        // GET /api/acr/accepting/my
        [HttpGet]
        [Route("accepting/my")]
        public HttpResponseMessage MyQueue(
            int pageNumber = 1, 
            int pageSize = 10,
            [FromUri] string Status = null,
            [FromUri] string Officer_name = null)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _accepting.GetMyAcceptingQueue(userId, pageNumber, pageSize, Status, Officer_name);

                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/acr/{acrId}/accepting
        [HttpGet]
        [Route("{acrId}/accepting")]
        public HttpResponseMessage Detail(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _accepting.GetAcceptingDetail(acrId, userId);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/acr/{acrId}/accepting/submit
        [HttpPost]
        [Route("{acrId}/accepting/submit")]
        public HttpResponseMessage Submit(string acrId, [FromBody] AcceptingDecisionRequest request)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _accepting.SubmitDecision(acrId, userId, request);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "ALREADY_DECIDED" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                            //
        // ------------------------------------------------------------------ //

        private string GetCallerUserId()
        {
            var principal = User as System.Security.Claims.ClaimsPrincipal;
            return principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        private HttpResponseMessage Respond<T>(HttpStatusCode code, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(code, body);

        private HttpResponseMessage Fail(string message, string errorCode = "INTERNAL_ERROR",
            HttpStatusCode code = HttpStatusCode.InternalServerError)
            => Request.CreateResponse(code, ApiResponse<EmptyResponse>.Fail(message, errorCode));
    }
}