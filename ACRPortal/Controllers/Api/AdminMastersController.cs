using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers
{
    /// <summary>
    /// Handles GET + POST for all six master tables.
    /// Route prefix: api/admin/masters — falls under /api/admin/* so
    /// RouteAccessPolicy already restricts this to ADMIN role only.
    /// No additional role check needed in the controller.
    /// </summary>
    [RoutePrefix("api/admin/masters")]
    public class AdminMastersController : ApiController
    {
        private readonly IAdminMastersUseCase _masters;

        public AdminMastersController(IAdminMastersUseCase masters)
        {
            _masters = masters;
        }

        // ================================================================== //
        //  tbDsg — Designations                                              //
        // ================================================================== //

        // GET /api/admin/masters/designations?activeOnly=true
        [HttpGet]
        [Route("designations")]
        public HttpResponseMessage GetDesignations([FromUri] bool activeOnly = true)
        {
            try
            {
                var result = _masters.GetDesignations(activeOnly);
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/designations
        [HttpPost]
        [Route("designations")]
        public HttpResponseMessage CreateDesignation([FromBody] CreateDsgRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateDesignation(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  State                                                             //
        // ================================================================== //

        // GET /api/admin/masters/states
        [HttpGet]
        [Route("states")]
        public HttpResponseMessage GetStates()
        {
            try
            {
                var result = _masters.GetStates();
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/states
        [HttpPost]
        [Route("states")]
        public HttpResponseMessage CreateState([FromBody] CreateStateRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateState(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Zone                                                              //
        // ================================================================== //

        // GET /api/admin/masters/zones
        [HttpGet]
        [Route("zones")]
        public HttpResponseMessage GetZones()
        {
            try
            {
                var result = _masters.GetZones();
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/zones
        [HttpPost]
        [Route("zones")]
        public HttpResponseMessage CreateZone([FromBody] CreateZoneRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateZone(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Circle                                                            //
        // ================================================================== //

        // GET /api/admin/masters/circles?zoneId=1
        [HttpGet]
        [Route("circles")]
        public HttpResponseMessage GetCircles([FromUri] int? zoneId = null)
        {
            try
            {
                var result = _masters.GetCircles(zoneId);
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/circles
        [HttpPost]
        [Route("circles")]
        public HttpResponseMessage CreateCircle([FromBody] CreateCircleRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateCircle(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Division                                                          //
        // ================================================================== //

        // GET /api/admin/masters/divisions?zoneId=1&circleId=101
        [HttpGet]
        [Route("divisions")]
        public HttpResponseMessage GetDivisions([FromUri] int? zoneId = null, [FromUri] int? circleId = null)
        {
            try
            {
                var result = _masters.GetDivisions(zoneId, circleId);
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/divisions
        [HttpPost]
        [Route("divisions")]
        public HttpResponseMessage CreateDivision([FromBody] CreateDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateDivision(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  SubDivision                                                       //
        // ================================================================== //

        // GET /api/admin/masters/subdivisions?zoneId=1&circleId=101&divisionId=1001
        [HttpGet]
        [Route("subdivisions")]
        public HttpResponseMessage GetSubDivisions(
            [FromUri] int? zoneId = null,
            [FromUri] int? circleId = null,
            [FromUri] int? divisionId = null)
        {
            try
            {
                var result = _masters.GetSubDivisions(zoneId, circleId, divisionId);
                return Respond(result.Success ? HttpStatusCode.OK : HttpStatusCode.InternalServerError, result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // POST /api/admin/masters/subdivisions
        [HttpPost]
        [Route("subdivisions")]
        public HttpResponseMessage CreateSubDivision([FromBody] CreateSubDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail(HttpStatusCode.BadRequest, "Request body is required", "BAD_REQUEST");

                var result = _masters.CreateSubDivision(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex)
            {
                return Fail(HttpStatusCode.InternalServerError, ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Response helpers — same pattern as AuthController                 //
        // ================================================================== //

        private HttpResponseMessage Respond<T>(HttpStatusCode status, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(status, body);

        private HttpResponseMessage Fail(HttpStatusCode status, string message, string code)
            => Request.CreateResponse(status, ApiResponse<EmptyResponse>.Fail(message, code));

        private static HttpStatusCode MapStatus(string errorCode, bool success, HttpStatusCode successCode)
        {
            if (success) return successCode;

            switch (errorCode)
            {
                case "BAD_REQUEST": return HttpStatusCode.BadRequest;
                case "DUPLICATE_ID":
                case "DESIGNATION_EXISTS": return HttpStatusCode.Conflict;
                case "INVALID_ZONE":
                case "INVALID_CIRCLE":
                case "INVALID_DIVISION": return HttpStatusCode.BadRequest;
                case "INTERNAL_ERROR": return HttpStatusCode.InternalServerError;
                default: return HttpStatusCode.BadRequest;
            }
        }
    }
}