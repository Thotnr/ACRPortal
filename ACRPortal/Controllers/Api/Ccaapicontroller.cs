using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
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

        // GET /api/cca/officers
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

        // GET /api/cca/employees
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

        // GET /api/cca/officers/{officerUserId}/authorities/suggestions
        [HttpGet]
        [Route("officers/{officerUserId}/authorities/suggestions")]
        public HttpResponseMessage GetAuthoritySuggestions(string officerUserId)
        {
            try
            {
                var result = _cca.GetAuthoritySuggestions(officerUserId);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "INVALID_OFFICER" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "MISSING_RA" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "INVALID_RA" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "MISSING_RVA" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "INVALID_RVA" ? HttpStatusCode.Conflict
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/cca/acr
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

        // GET /api/cca/acr
        // Must be declared BEFORE /api/cca/acr/{acrId} to avoid route ambiguity
        [HttpGet]
        [Route("acr")]
        public HttpResponseMessage GetAcrList(int pageNumber = 1, int pageSize = 10)
        {
            try
            {
                var ccaUserId = GetCallerUserId();

                var result = _cca.GetAcrList(ccaUserId, pageNumber, pageSize);

                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/cca/acr/{acrId}
        [HttpGet]
        [Route("acr/{acrId}")]
        public HttpResponseMessage GetAcrDetail(string acrId)
        {
            try
            {
                var result = _cca.GetAcrDetail(acrId);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/cca/acr/{acrId}
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