using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers
{
    [RoutePrefix("api/cca")]
    public class CcaApiController : ApiController
    {
        private readonly ICcaUseCase _cca;

        public CcaApiController(ICcaUseCase cca)
        {
            _cca = cca;
        }

        [HttpGet]
        [Route("officers")]
        public HttpResponseMessage GetOfficers()
        {
            try
            {
                var result = _cca.GetOfficers();
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        [HttpGet]
        [Route("employees")]
        public HttpResponseMessage GetEmployeesForDropdown()
        {
            try
            {
                var result = _cca.GetEmployeesForDropdown();
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        [HttpPost]
        [Route("acr")]
        public HttpResponseMessage CreateAcr([FromBody] CreateAcrRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string ccaUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(ccaUserId))
                    return Fail("Unable to identify CCA from token", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _cca.CreateAcr(ccaUserId, request);
                var status = result.Success ? HttpStatusCode.Created
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "DUPLICATE_ACR" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/cca/acr/{acrId}
        // Saves changes to a drafted ACR (status must remain DRAFT).
        [HttpPatch]
        [Route("acr/{acrId}")]
        public HttpResponseMessage UpdateDraftAcr(string acrId, [FromBody] UpdateDraftAcrRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string ccaUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(ccaUserId))
                    return Fail("Unable to identify CCA from token", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _cca.UpdateDraftAcr(acrId, ccaUserId, request);

                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "DUPLICATE_ACR" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/cca/acr/{acrId}/submit
        // Submits a drafted ACR to the Officer step (DRAFT → PENDING_OFFICER).
        [HttpPost]
        [Route("acr/{acrId}/submit")]
        public HttpResponseMessage SubmitDraftAcr(string acrId)
        {
            try
            {
                string ccaUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(ccaUserId))
                    return Fail("Unable to identify CCA from token", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _cca.SubmitDraftAcr(acrId, ccaUserId);

                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        [HttpGet]
        [Route("acr")]
        public HttpResponseMessage GetAcrList()
        {
            try
            {
                var result = _cca.GetAcrList();
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        private string GetCallerUserId()
        {
            var principal = Thread.CurrentPrincipal as ClaimsPrincipal;
            return principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        private HttpResponseMessage Respond<T>(HttpStatusCode code, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(code, body);

        private HttpResponseMessage Fail(string msg, string errorCode = "INTERNAL_ERROR",
            HttpStatusCode code = default)
        {
            if (code == default) code = HttpStatusCode.InternalServerError;
            return Request.CreateResponse(code,
                ApiResponse<EmptyResponse>.Fail(msg, errorCode));
        }
    }
}