using System;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers.Api
{
    [RoutePrefix("api/acr")]
    public class OfficerApiController : ApiController
    {
        private readonly IOfficerUseCase _officer;

        public OfficerApiController(IOfficerUseCase officer)
        {
            _officer = officer;
        }

        // GET /api/acr/my
        [HttpGet]
        [Route("my")]
        public HttpResponseMessage My([FromUri] string status = null, int pageNumber = 1, int pageSize = 10)
        {
            try
            {
                string officerUserId = GetCallerUserId();

                var result = _officer.GetMyAcrs(officerUserId, status, pageNumber, pageSize);

                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/acr/{acrId}
        [HttpGet]
        [Route("{acrId}")]
        public HttpResponseMessage Detail(string acrId)
        {
            try
            {
                string officerUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(officerUserId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _officer.GetAcrDetail(acrId, officerUserId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/acr/{acrId}/self-appraisal/draft
        [HttpPatch]
        [Route("{acrId}/self-appraisal/draft")]
        public HttpResponseMessage SaveSelfAppraisalDraft(string acrId, [FromBody] SelfAppraisalDraftRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string officerUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(officerUserId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _officer.SaveSelfAppraisalDraft(acrId, officerUserId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/acr/{acrId}/self-appraisal/submit
        [HttpPost]
        [Route("{acrId}/self-appraisal/submit")]
        public HttpResponseMessage SubmitSelfAppraisal(string acrId)
        {
            try
            {
                string officerUserId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(officerUserId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _officer.SubmitSelfAppraisal(acrId, officerUserId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
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

        private HttpResponseMessage Fail(string msg, string errorCode = "INTERNAL_ERROR", HttpStatusCode code = default)
        {
            if (code == default) code = HttpStatusCode.InternalServerError;
            return Request.CreateResponse(code,
                ApiResponse<EmptyResponse>.Fail(msg, errorCode));
        }

        private static HttpStatusCode MapStatus(string errorCode, bool success, HttpStatusCode successCode)
        {
            if (success) return successCode;

            switch (errorCode)
            {
                case "BAD_REQUEST": return HttpStatusCode.BadRequest;
                case "TOKEN_INVALID": return HttpStatusCode.Unauthorized;
                case "FORBIDDEN": return HttpStatusCode.Forbidden;
                case "NOT_FOUND": return HttpStatusCode.NotFound;
                case "INVALID_STATE": return HttpStatusCode.Conflict;
                case "ALREADY_SUBMITTED": return HttpStatusCode.Conflict;
                default: return HttpStatusCode.InternalServerError;
            }
        }
    }
}

