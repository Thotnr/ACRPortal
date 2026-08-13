using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Threading;
using System.Web.Http;
using System;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Helpers;

namespace ACRPortal.Controllers.Api
{
    [RoutePrefix("api/admin")]
    public class AdminController : ApiController
    {
        private readonly IAdminUseCase _admin;
        private readonly IAcrMisUseCase _mis;

        public AdminController(IAdminUseCase admin, IAcrMisUseCase mis)
        {
            _admin = admin;
            _mis = mis;
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
            [FromUri] int pageSize = 10,
            [FromUri] string search = null)
        {
            var result = _admin.GetAllUsers(
                role, status, dsgId, zoneId, divisionId,
                pageNumber, pageSize, search);

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

        // ------------------------------------------------------------------ //
        //  PATCH api/admin/users/{userId}/unlock                              //
        // ------------------------------------------------------------------ //
        [HttpPatch]
        [Route("users/{userId}/unlock")]
        public HttpResponseMessage UnlockUser(string userId)
        {
            var result = _admin.UnlockUser(userId);
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

        [HttpGet]
        [Route("acr-mis")]
        public HttpResponseMessage GetAcrMis(
            [FromUri] int? acrYear = null,
            [FromUri] string formType = null,
            [FromUri] string location = null,
            [FromUri] string employeeUserId = null,
            [FromUri] string status = null,
            [FromUri] string search = null,
            [FromUri] int pageNumber = 1,
            [FromUri] int pageSize = 10)
        {
            if (!IsAdminCaller())
                return Request.CreateResponse(HttpStatusCode.Forbidden,
                    ApiResponse<EmptyResponse>.Fail("Only Admin users can access ACR MIS data.", "FORBIDDEN"));

            var request = new AcrMisFilterRequest
            {
                AcrYear = acrYear,
                FormType = formType,
                Location = location,
                EmployeeUserId = employeeUserId,
                Status = status,
                Search = search,
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            var result = _mis.GetReport(request);
            return Request.CreateResponse(result.Success ? HttpStatusCode.OK : MapStatus(result.ErrorCode), result);
        }

        [HttpGet]
        [Route("acr-mis/filters")]
        public HttpResponseMessage GetAcrMisFilters()
        {
            if (!IsAdminCaller())
                return Request.CreateResponse(HttpStatusCode.Forbidden,
                    ApiResponse<EmptyResponse>.Fail("Only Admin users can access ACR MIS filters.", "FORBIDDEN"));

            var result = _mis.GetFilters();
            return Request.CreateResponse(result.Success ? HttpStatusCode.OK : MapStatus(result.ErrorCode), result);
        }

        [HttpGet]
        [Route("acr-mis/excel")]
        public HttpResponseMessage DownloadAcrMisExcel(
            [FromUri] int? acrYear = null,
            [FromUri] string formType = null,
            [FromUri] string location = null,
            [FromUri] string employeeUserId = null,
            [FromUri] string status = null,
            [FromUri] string search = null,
            [FromUri] string tab = null)
        {
            if (!IsAdminCaller())
                return Request.CreateResponse(HttpStatusCode.Forbidden,
                    ApiResponse<EmptyResponse>.Fail("Only Admin users can download ACR MIS Excel.", "FORBIDDEN"));

            var request = new AcrMisFilterRequest
            {
                AcrYear = acrYear,
                FormType = formType,
                Location = location,
                EmployeeUserId = employeeUserId,
                Status = status,
                Search = search,
                PageNumber = 1,
                PageSize = 100000
            };

            var result = _mis.GetReport(request);
            if (!result.Success)
                return Request.CreateResponse(MapStatus(result.ErrorCode), result);

            byte[] excel = MisExcelBuilder.Build(result.Data, tab);
            var response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(excel)
            };
            response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = MisExcelBuilder.GetFileNamePrefix(tab) + "_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".xlsx"
            };
            return response;
        }

        [HttpGet]
        [Route("acr-mis/pdf")]
        public HttpResponseMessage DownloadAcrMisPdf(
            [FromUri] int? acrYear = null,
            [FromUri] string formType = null,
            [FromUri] string location = null,
            [FromUri] string employeeUserId = null,
            [FromUri] string status = null,
            [FromUri] string search = null)
        {
            if (!IsAdminCaller())
                return Request.CreateResponse(HttpStatusCode.Forbidden,
                    ApiResponse<EmptyResponse>.Fail("Only Admin users can download ACR MIS PDF.", "FORBIDDEN"));

            var request = new AcrMisFilterRequest
            {
                AcrYear = acrYear,
                FormType = formType,
                Location = location,
                EmployeeUserId = employeeUserId,
                Status = status,
                Search = search,
                PageNumber = 1,
                PageSize = 100000
            };

            var result = _mis.GetReport(request);
            if (!result.Success)
                return Request.CreateResponse(MapStatus(result.ErrorCode), result);

            byte[] pdf = SimpleMisPdfBuilder.Build(result.Data);
            var response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new ByteArrayContent(pdf)
            };
            response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
            response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = "ACR_MIS_Report_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".pdf"
            };
            return response;
        }

        private static bool IsAdminCaller()
        {
            var principal = Thread.CurrentPrincipal as ClaimsPrincipal;
            var role = principal == null ? null : principal.FindFirst(ClaimTypes.Role);
            return role != null && string.Equals(role.Value, "ADMIN", StringComparison.OrdinalIgnoreCase);
        }
    }
}
