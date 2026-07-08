using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Controllers
{
    /// <summary>
    /// Admin masters controller — GET, POST, PATCH for all six lookup tables.
    /// Route prefix: api/admin/masters
    /// Access restricted to ADMIN role by RouteAccessPolicy (applies to all /api/admin/* routes).
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
        //  tbDsg — Designations                                               //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/designations
        [HttpPost]
        [Route("designations")]
        public HttpResponseMessage CreateDesignation([FromBody] CreateDsgRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateDesignation(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/designations/{dsgId}
        // Body: { "Dsg": "XEN", "DsgDesc": "Executive Engineer", "DsgLevel": 3 }   (all optional)
        // Only name/description/level can change. DsgId in route is the locator — never updated.
        [HttpPatch]
        [Route("designations/{dsgId:int}")]
        public HttpResponseMessage UpdateDesignation(int dsgId, [FromBody] UpdateDsgRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateDesignation(dsgId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  State                                                              //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/states
        [HttpPost]
        [Route("states")]
        public HttpResponseMessage CreateState([FromBody] CreateStateRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateState(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/states/{stateId}
        // Body: { "StateName": "Punjab" }
        // State_ID (route param) is the locator — cannot be changed.
        [HttpPatch]
        [Route("states/{stateId:int}")]
        public HttpResponseMessage UpdateState(int stateId, [FromBody] UpdateStateRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateState(stateId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  Zone                                                               //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/zones
        [HttpPost]
        [Route("zones")]
        public HttpResponseMessage CreateZone([FromBody] CreateZoneRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateZone(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/zones/{zoneId}
        // Body: { "ZoneName": "Hisar Zone" }
        // Zone_ID (route param) is the locator — cannot be changed.
        [HttpPatch]
        [Route("zones/{zoneId:int}")]
        public HttpResponseMessage UpdateZone(int zoneId, [FromBody] UpdateZoneRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateZone(zoneId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  Circle                                                             //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/circles
        [HttpPost]
        [Route("circles")]
        public HttpResponseMessage CreateCircle([FromBody] CreateCircleRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateCircle(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/circles/{circleId}
        // Body: { "Circle": "Hisar Circle" }
        // Circle_ID (route param) is the locator — cannot be changed.
        [HttpPatch]
        [Route("circles/{circleId:int}")]
        public HttpResponseMessage UpdateCircle(int circleId, [FromBody] UpdateCircleRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateCircle(circleId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  Division                                                           //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/divisions
        [HttpPost]
        [Route("divisions")]
        public HttpResponseMessage CreateDivision([FromBody] CreateDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateDivision(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/divisions/{divisionId}
        // Body: { "Division": "Hisar Division" }
        // Division_ID (route param) is the locator — cannot be changed.
        [HttpPatch]
        [Route("divisions/{divisionId:int}")]
        public HttpResponseMessage UpdateDivision(int divisionId, [FromBody] UpdateDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateDivision(divisionId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  SubDivision                                                        //
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
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // POST /api/admin/masters/subdivisions
        [HttpPost]
        [Route("subdivisions")]
        public HttpResponseMessage CreateSubDivision([FromBody] CreateSubDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.CreateSubDivision(request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.Created), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // PATCH /api/admin/masters/subdivisions/{subDivisionId}
        // Body: { "SubDivision": "Hisar Urban Sub-Division" }
        // SubDivisionID (route param) is the locator — cannot be changed.
        [HttpPatch]
        [Route("subdivisions/{subDivisionId:int}")]
        public HttpResponseMessage UpdateSubDivision(int subDivisionId, [FromBody] UpdateSubDivisionRequest request)
        {
            try
            {
                if (request == null)
                    return Fail("Request body is required", "BAD_REQUEST", HttpStatusCode.BadRequest);

                var result = _masters.UpdateSubDivision(subDivisionId, request);
                return Respond(MapStatus(result.ErrorCode, result.Success, HttpStatusCode.OK), result);
            }
            catch (Exception ex) { return Fail(ex.Message); }
        }

        // ================================================================== //
        //  Helpers                                                            //
        // ================================================================== //

        private HttpResponseMessage Respond<T>(HttpStatusCode status, ApiResponse<T> body)
            where T : class, new()
            => Request.CreateResponse(status, body);

        private HttpResponseMessage Fail(string message,
            string code = "INTERNAL_ERROR",
            HttpStatusCode status = HttpStatusCode.InternalServerError)
            => Request.CreateResponse(status,
                ApiResponse<EmptyResponse>.Fail(message, code));

        private static HttpStatusCode MapStatus(string errorCode, bool success, HttpStatusCode successCode)
        {
            if (success) return successCode;

            switch (errorCode)
            {
                case "BAD_REQUEST": return HttpStatusCode.BadRequest;
                case "NOT_FOUND": return HttpStatusCode.NotFound;
                case "DUPLICATE_ID":
                case "DUPLICATE_NAME": return HttpStatusCode.Conflict;
                case "INVALID_ZONE":
                case "INVALID_CIRCLE":
                case "INVALID_DIVISION": return HttpStatusCode.BadRequest;
                default: return HttpStatusCode.InternalServerError;
            }
        }
    }
}