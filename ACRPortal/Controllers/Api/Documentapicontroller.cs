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
    /// <summary>
    /// Document management for ACR cycles.
    ///
    /// The frontend:
    ///   1. Uploads the file to cloud storage directly (S3, Azure Blob, etc.)
    ///   2. Receives a public URL from the storage provider
    ///   3. Calls POST /api/acr/{acrId}/docs with that URL
    ///
    /// The backend:
    ///   - Resolves the caller's section from their role in the ACR chain
    ///   - Validates the current workflow state allows uploads for that section
    ///   - Stores the URL in dbo.acr_documents
    ///
    /// Routes are under api/acr so the existing EMPLOYEE role policy in
    /// RouteAccessPolicy covers them without any change.
    /// CCA routes (POST /api/cca/acr/{acrId}/docs) are declared separately
    /// below to keep the CCA section under /api/cca/ and covered by the CCA policy.
    /// Both controllers inject the same IDocumentUseCase — the service resolves
    /// the section from the caller's position in the ACR chain, so the same
    /// logic handles both.
    /// </summary>
    [RoutePrefix("api/acr")]
    public class DocumentApiController : ApiController
    {
        private readonly IDocumentUseCase _docs;

        public DocumentApiController(IDocumentUseCase docs)
        {
            _docs = docs;
        }

        // POST /api/acr/{acrId}/docs
        [HttpPost]
        [Route("{acrId}/docs")]
        public HttpResponseMessage AddDocument(string acrId, [FromBody] AddDocumentRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.AddDocument(acrId, userId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/acr/{acrId}/docs
        [HttpGet]
        [Route("{acrId}/docs")]
        public HttpResponseMessage GetDocuments(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.GetDocuments(acrId, userId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // DELETE /api/acr/{acrId}/docs/{documentId}
        [HttpDelete]
        [Route("{acrId}/docs/{documentId}")]
        public HttpResponseMessage DeleteDocument(string acrId, string documentId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.DeleteDocument(acrId, documentId, userId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                            //
        // ------------------------------------------------------------------ //

        private string GetCallerUserId()
        {
            var principal = Thread.CurrentPrincipal as ClaimsPrincipal;
            return principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        private HttpResponseMessage Respond<T>(HttpStatusCode code, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(code, body);

        private HttpResponseMessage Fail(string msg, string errorCode = "INTERNAL_ERROR",
            HttpStatusCode code = HttpStatusCode.InternalServerError)
            => Request.CreateResponse(code, ApiResponse<EmptyResponse>.Fail(msg, errorCode));

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
                default: return HttpStatusCode.InternalServerError;
            }
        }
    }

    /// <summary>
    /// CCA-specific document endpoints.
    /// Separate controller so routes live under /api/cca/ and are covered
    /// by the existing CCA role policy in RouteAccessPolicy.
    /// </summary>
    [RoutePrefix("api/cca")]
    public class CcaDocumentApiController : ApiController
    {
        private readonly IDocumentUseCase _docs;

        public CcaDocumentApiController(IDocumentUseCase docs)
        {
            _docs = docs;
        }

        // POST /api/cca/acr/{acrId}/photo
        [HttpPost]
        [Route("acr/{acrId}/photo")]
        public HttpResponseMessage UploadOfficerPhoto(string acrId, [FromBody] AddDocumentRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.UploadOfficerPhoto(acrId, userId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/cca/acr/{acrId}/docs
        [HttpPost]
        [Route("acr/{acrId}/docs")]
        public HttpResponseMessage AddDocument(string acrId, [FromBody] AddDocumentRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.AddDocument(acrId, userId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // GET /api/cca/acr/{acrId}/docs
        [HttpGet]
        [Route("acr/{acrId}/docs")]
        public HttpResponseMessage GetDocuments(string acrId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.GetDocuments(acrId, userId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // DELETE /api/cca/acr/{acrId}/docs/{documentId}
        [HttpDelete]
        [Route("acr/{acrId}/docs/{documentId}")]
        public HttpResponseMessage DeleteDocument(string acrId, string documentId)
        {
            try
            {
                string userId = GetCallerUserId();
                if (string.IsNullOrWhiteSpace(userId))
                    return Fail("Token missing or invalid", "TOKEN_INVALID", HttpStatusCode.Unauthorized);

                var result = _docs.DeleteDocument(acrId, documentId, userId);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        private string GetCallerUserId()
        {
            var principal = User as ClaimsPrincipal;
            return principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        private HttpResponseMessage Respond<T>(HttpStatusCode code, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(code, body);

        private HttpResponseMessage Fail(string msg, string errorCode = "INTERNAL_ERROR",
            HttpStatusCode code = HttpStatusCode.InternalServerError)
            => Request.CreateResponse(code, ApiResponse<EmptyResponse>.Fail(msg, errorCode));

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
                default: return HttpStatusCode.InternalServerError;
            }
        }
    }
}