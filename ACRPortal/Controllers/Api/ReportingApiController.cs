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
    public class ReportingApiController : ApiController
    {
        private readonly IReportingUseCase _reporting;

        public ReportingApiController(IReportingUseCase reporting)
        {
            _reporting = reporting;
        }

        // GET /api/acr/reporting/my
        [HttpGet]
        [Route("reporting/my")]
        public HttpResponseMessage MyQueue(int pageNumber = 1, int pageSize = 10)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reporting.GetMyReportingQueue(userId, pageNumber, pageSize);

                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/acr/{acrId}/reporting
        [HttpGet]
        [Route("{acrId}/reporting")]
        public HttpResponseMessage Detail(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reporting.GetReportingDetail(acrId, userId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/acr/{acrId}/reporting/draft
        [HttpPatch]
        [Route("{acrId}/reporting/draft")]
        public HttpResponseMessage SaveDraft(string acrId, [FromBody] ReportingDraftRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reporting.SaveReportingDraft(acrId, userId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/acr/{acrId}/reporting/submit
        [HttpPost]
        [Route("{acrId}/reporting/submit")]
        public HttpResponseMessage Submit(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reporting.SubmitReporting(acrId, userId);
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

