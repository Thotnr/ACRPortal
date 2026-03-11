using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    /// <summary>
    /// Business logic for all master data operations.
    /// Rules enforced here:
    ///   - IDs must be unique on Create (DUPLICATE_ID)
    ///   - Names must be unique across the whole table on both Create and Update (DUPLICATE_NAME)
    ///   - On Update: only the name (and Dsg description/level) may change — ID is the locator, never changed
    ///   - On Update: record must exist (NOT_FOUND)
    /// </summary>
    public class AdminMastersService : IAdminMastersUseCase
    {
        private readonly IAdminMastersRepoPort _repo;

        public AdminMastersService(IAdminMastersRepoPort repo)
        {
            _repo = repo;
        }

        // ================================================================== //
        //  tbDsg — Designations                                               //
        // ================================================================== //

        public ApiResponse<DsgListResponse> GetDesignations(bool activeOnly)
        {
            try
            {
                var list = _repo.GetDesignations(activeOnly);
                return ApiResponse<DsgListResponse>.Ok(new DsgListResponse { Designations = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<DsgListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<DsgIdResponse> CreateDesignation(CreateDsgRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.Dsg))
                    return ApiResponse<DsgIdResponse>.Fail("Dsg code is required", "BAD_REQUEST");

                if (request.DsgLevel <= 0)
                    return ApiResponse<DsgIdResponse>.Fail("DsgLevel must be greater than 0", "BAD_REQUEST");

                if (_repo.IsDsgCodeExists(request.Dsg.Trim()))
                    return ApiResponse<DsgIdResponse>.Fail(
                        "Designation code '" + request.Dsg + "' already exists", "DUPLICATE_NAME");

                int newId = _repo.CreateDsg(request.Dsg.Trim(), request.DsgDesc?.Trim(), request.DsgLevel);
                return ApiResponse<DsgIdResponse>.Ok(new DsgIdResponse { DsgId = newId }, "Designation created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<DsgIdResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateDesignation(int dsgId, UpdateDsgRequest request)
        {
            try
            {
                if (request == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");

                bool hasCode = !string.IsNullOrWhiteSpace(request.Dsg);
                bool hasLevel = request.DsgLevel.HasValue;
                bool hasDesc = request.DsgDesc != null;

                if (!hasCode && !hasLevel && !hasDesc)
                    return ApiResponse<EmptyResponse>.Fail(
                        "At least one of Dsg, DsgDesc, or DsgLevel must be provided", "BAD_REQUEST");

                if (hasLevel && request.DsgLevel.Value <= 0)
                    return ApiResponse<EmptyResponse>.Fail("DsgLevel must be greater than 0", "BAD_REQUEST");

                if (!_repo.IsDsgIdExists(dsgId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Designation with DsgId " + dsgId + " not found", "NOT_FOUND");

                // If changing the code, check uniqueness excluding self
                if (hasCode && _repo.IsDsgCodeExistsExcluding(request.Dsg.Trim(), dsgId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Designation code '" + request.Dsg + "' already exists", "DUPLICATE_NAME");

                // Fetch current values so we can keep unchanged fields
                var current = _repo.GetDesignations(false)
                    .Find(d => d.DsgId == dsgId);

                string finalCode = hasCode ? request.Dsg.Trim() : current.Dsg;
                string finalDesc = hasDesc ? request.DsgDesc?.Trim() : current.DsgDesc;
                int finalLevel = hasLevel ? request.DsgLevel.Value : current.DsgLevel;

                _repo.UpdateDsg(dsgId, finalCode, finalDesc, finalLevel);
                return ApiResponse<EmptyResponse>.Ok(null, "Designation updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  State                                                              //
        // ================================================================== //

        public ApiResponse<StateListResponse> GetStates()
        {
            try
            {
                var list = _repo.GetStates();
                return ApiResponse<StateListResponse>.Ok(new StateListResponse { States = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<StateListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> CreateState(CreateStateRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.StateName) || request.StateId <= 0)
                    return ApiResponse<EmptyResponse>.Fail("StateId and StateName are required", "BAD_REQUEST");

                if (_repo.IsStateIdExists(request.StateId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "StateId " + request.StateId + " already exists", "DUPLICATE_ID");

                if (_repo.IsStateNameExists(request.StateName.Trim()))
                    return ApiResponse<EmptyResponse>.Fail(
                        "State name '" + request.StateName + "' already exists", "DUPLICATE_NAME");

                _repo.CreateState(request.StateId, request.StateName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "State created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateState(int stateId, UpdateStateRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.StateName))
                    return ApiResponse<EmptyResponse>.Fail("StateName is required", "BAD_REQUEST");

                if (!_repo.IsStateIdExists(stateId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "State with State_ID " + stateId + " not found", "NOT_FOUND");

                if (_repo.IsStateNameExistsExcluding(request.StateName.Trim(), stateId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "State name '" + request.StateName + "' already exists", "DUPLICATE_NAME");

                _repo.UpdateState(stateId, request.StateName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "State updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Zone                                                               //
        // ================================================================== //

        public ApiResponse<ZoneListResponse> GetZones()
        {
            try
            {
                var list = _repo.GetZones();
                return ApiResponse<ZoneListResponse>.Ok(new ZoneListResponse { Zones = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<ZoneListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> CreateZone(CreateZoneRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.ZoneName) || request.ZoneId <= 0)
                    return ApiResponse<EmptyResponse>.Fail("ZoneId and ZoneName are required", "BAD_REQUEST");

                if (_repo.IsZoneIdExists(request.ZoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId " + request.ZoneId + " already exists", "DUPLICATE_ID");

                if (_repo.IsZoneNameExists(request.ZoneName.Trim()))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Zone name '" + request.ZoneName + "' already exists", "DUPLICATE_NAME");

                _repo.CreateZone(request.ZoneId, request.ZoneName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Zone created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateZone(int zoneId, UpdateZoneRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.ZoneName))
                    return ApiResponse<EmptyResponse>.Fail("ZoneName is required", "BAD_REQUEST");

                if (!_repo.IsZoneIdExists(zoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Zone with Zone_ID " + zoneId + " not found", "NOT_FOUND");

                if (_repo.IsZoneNameExistsExcluding(request.ZoneName.Trim(), zoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Zone name '" + request.ZoneName + "' already exists", "DUPLICATE_NAME");

                _repo.UpdateZone(zoneId, request.ZoneName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Zone updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Circle                                                             //
        // ================================================================== //

        public ApiResponse<CircleListResponse> GetCircles(int? zoneId)
        {
            try
            {
                var list = _repo.GetCircles(zoneId);
                return ApiResponse<CircleListResponse>.Ok(new CircleListResponse { Circles = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<CircleListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> CreateCircle(CreateCircleRequest request)
        {
            try
            {
                if (request == null
                    || request.ZoneId <= 0
                    || request.CircleId <= 0
                    || string.IsNullOrWhiteSpace(request.Circle))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId, CircleId, and Circle name are required", "BAD_REQUEST");

                if (!_repo.IsZoneIdExists(request.ZoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId " + request.ZoneId + " not found", "INVALID_ZONE");

                if (_repo.IsCircleIdExists(request.CircleId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "CircleId " + request.CircleId + " already exists", "DUPLICATE_ID");

                if (_repo.IsCircleNameExists(request.Circle.Trim()))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Circle name '" + request.Circle + "' already exists", "DUPLICATE_NAME");

                _repo.CreateCircle(request.ZoneId, request.CircleId, request.Circle.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Circle created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateCircle(int circleId, UpdateCircleRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.Circle))
                    return ApiResponse<EmptyResponse>.Fail("Circle name is required", "BAD_REQUEST");

                if (!_repo.IsCircleIdExists(circleId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Circle with Circle_ID " + circleId + " not found", "NOT_FOUND");

                if (_repo.IsCircleNameExistsExcluding(request.Circle.Trim(), circleId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Circle name '" + request.Circle + "' already exists", "DUPLICATE_NAME");

                _repo.UpdateCircle(circleId, request.Circle.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Circle updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  Division                                                           //
        // ================================================================== //

        public ApiResponse<DivisionListResponse> GetDivisions(int? zoneId, int? circleId)
        {
            try
            {
                var list = _repo.GetDivisions(zoneId, circleId);
                return ApiResponse<DivisionListResponse>.Ok(new DivisionListResponse { Divisions = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<DivisionListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> CreateDivision(CreateDivisionRequest request)
        {
            try
            {
                if (request == null
                    || request.ZoneId <= 0
                    || request.CircleId <= 0
                    || request.DivisionId <= 0
                    || string.IsNullOrWhiteSpace(request.Division))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId, CircleId, DivisionId, and Division name are required", "BAD_REQUEST");

                if (!_repo.IsZoneIdExists(request.ZoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId " + request.ZoneId + " not found", "INVALID_ZONE");

                if (!_repo.IsCircleIdExists(request.CircleId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "CircleId " + request.CircleId + " not found", "INVALID_CIRCLE");

                if (_repo.IsDivisionIdExists(request.DivisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "DivisionId " + request.DivisionId + " already exists", "DUPLICATE_ID");

                if (_repo.IsDivisionNameExists(request.Division.Trim()))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Division name '" + request.Division + "' already exists", "DUPLICATE_NAME");

                _repo.CreateDivision(request.ZoneId, request.CircleId, request.DivisionId, request.Division.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Division created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateDivision(int divisionId, UpdateDivisionRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.Division))
                    return ApiResponse<EmptyResponse>.Fail("Division name is required", "BAD_REQUEST");

                if (!_repo.IsDivisionIdExists(divisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Division with Division_ID " + divisionId + " not found", "NOT_FOUND");

                if (_repo.IsDivisionNameExistsExcluding(request.Division.Trim(), divisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "Division name '" + request.Division + "' already exists", "DUPLICATE_NAME");

                _repo.UpdateDivision(divisionId, request.Division.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Division updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ================================================================== //
        //  SubDivision                                                        //
        // ================================================================== //

        public ApiResponse<SubDivisionListResponse> GetSubDivisions(int? zoneId, int? circleId, int? divisionId)
        {
            try
            {
                var list = _repo.GetSubDivisions(zoneId, circleId, divisionId);
                return ApiResponse<SubDivisionListResponse>.Ok(
                    new SubDivisionListResponse { SubDivisions = list });
            }
            catch (Exception ex)
            {
                return ApiResponse<SubDivisionListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> CreateSubDivision(CreateSubDivisionRequest request)
        {
            try
            {
                if (request == null
                    || request.ZoneId <= 0
                    || request.CircleId <= 0
                    || request.DivisionId <= 0
                    || request.SubDivisionId <= 0
                    || string.IsNullOrWhiteSpace(request.SubDivision))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId, CircleId, DivisionId, SubDivisionId, and SubDivision name are required",
                        "BAD_REQUEST");

                if (!_repo.IsZoneIdExists(request.ZoneId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "ZoneId " + request.ZoneId + " not found", "INVALID_ZONE");

                if (!_repo.IsCircleIdExists(request.CircleId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "CircleId " + request.CircleId + " not found", "INVALID_CIRCLE");

                if (!_repo.IsDivisionIdExists(request.DivisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "DivisionId " + request.DivisionId + " not found", "INVALID_DIVISION");

                if (_repo.IsSubDivisionIdExists(request.SubDivisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "SubDivisionId " + request.SubDivisionId + " already exists", "DUPLICATE_ID");

                if (_repo.IsSubDivisionNameExists(request.SubDivision.Trim()))
                    return ApiResponse<EmptyResponse>.Fail(
                        "SubDivision name '" + request.SubDivision + "' already exists", "DUPLICATE_NAME");

                _repo.CreateSubDivision(
                    request.ZoneId, request.CircleId, request.DivisionId,
                    request.SubDivisionId, request.SubDivision.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "SubDivision created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> UpdateSubDivision(int subDivisionId, UpdateSubDivisionRequest request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.SubDivision))
                    return ApiResponse<EmptyResponse>.Fail("SubDivision name is required", "BAD_REQUEST");

                if (!_repo.IsSubDivisionIdExists(subDivisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "SubDivision with SubDivisionID " + subDivisionId + " not found", "NOT_FOUND");

                if (_repo.IsSubDivisionNameExistsExcluding(request.SubDivision.Trim(), subDivisionId))
                    return ApiResponse<EmptyResponse>.Fail(
                        "SubDivision name '" + request.SubDivision + "' already exists", "DUPLICATE_NAME");

                _repo.UpdateSubDivision(subDivisionId, request.SubDivision.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "SubDivision updated successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}