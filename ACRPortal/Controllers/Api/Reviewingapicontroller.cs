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
    public class ReviewingApiController : ApiController
    {
        private readonly IReviewingUseCase _reviewing;

        public ReviewingApiController(IReviewingUseCase reviewing)
        {
            _reviewing = reviewing;
        }

        // GET /api/acr/reviewing/my
        [HttpGet]
        [Route("reviewing/my")]
        public HttpResponseMessage MyQueue()
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reviewing.GetMyReviewingQueue(userId);
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/acr/{acrId}/reviewing
        [HttpGet]
        [Route("{acrId}/reviewing")]
        public HttpResponseMessage Detail(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reviewing.GetReviewingDetail(acrId, userId);
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

        // PATCH /api/acr/{acrId}/reviewing/draft
        [HttpPatch]
        [Route("{acrId}/reviewing/draft")]
        public HttpResponseMessage SaveDraft(string acrId, [FromBody] ReviewingDraftRequest request)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _reviewing.SaveReviewingDraft(acrId, userId, request);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "ALREADY_SUBMITTED" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "TOKEN_INVALID" ? HttpStatusCode.Unauthorized
                    : HttpStatusCode.InternalServerError;

                return Respond(status, result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/acr/{acrId}/reviewing/submit
        [HttpPost]
        [Route("{acrId}/reviewing/submit")]
        public HttpResponseMessage Submit(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _reviewing.SubmitReviewing(acrId, userId);
                var status = result.Success ? HttpStatusCode.OK
                    : result.ErrorCode == "BAD_REQUEST" ? HttpStatusCode.BadRequest
                    : result.ErrorCode == "NOT_FOUND" ? HttpStatusCode.NotFound
                    : result.ErrorCode == "FORBIDDEN" ? HttpStatusCode.Forbidden
                    : result.ErrorCode == "INVALID_STATE" ? HttpStatusCode.Conflict
                    : result.ErrorCode == "ALREADY_SUBMITTED" ? HttpStatusCode.Conflict
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