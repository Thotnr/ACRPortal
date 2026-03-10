using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    /// <summary>
    /// Handles all business logic for master data management.
    /// Validation lives here; raw SQL lives in AdminMastersAdapter.
    /// </summary>
    public class AdminMastersService : IAdminMastersUseCase
    {
        private readonly IAdminMastersRepoPort _repo;

        public AdminMastersService(IAdminMastersRepoPort repo)
        {
            _repo = repo;
        }

        // ------------------------------------------------------------------ //
        //  tbDsg — Designations                                               //
        // ------------------------------------------------------------------ //

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
                        "Designation code '" + request.Dsg + "' already exists", "DESIGNATION_EXISTS");

                int newId = _repo.CreateDsg(request.Dsg.Trim(), request.DsgDesc?.Trim(), request.DsgLevel);

                return ApiResponse<DsgIdResponse>.Ok(
                    new DsgIdResponse { DsgId = newId }, "Designation created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<DsgIdResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  State                                                              //
        // ------------------------------------------------------------------ //

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

                _repo.CreateState(request.StateId, request.StateName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "State created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Zone                                                               //
        // ------------------------------------------------------------------ //

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

                _repo.CreateZone(request.ZoneId, request.ZoneName.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Zone created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Circle                                                             //
        // ------------------------------------------------------------------ //

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

                _repo.CreateCircle(request.ZoneId, request.CircleId, request.Circle.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Circle created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Division                                                           //
        // ------------------------------------------------------------------ //

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

                _repo.CreateDivision(request.ZoneId, request.CircleId, request.DivisionId, request.Division.Trim());
                return ApiResponse<EmptyResponse>.Ok(null, "Division created successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  SubDivision                                                        //
        // ------------------------------------------------------------------ //

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
    }
}