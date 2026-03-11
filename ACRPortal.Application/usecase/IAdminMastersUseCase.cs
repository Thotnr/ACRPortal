using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    /// <summary>
    /// Use-case interface for admin master data management.
    /// Covers: tbDsg, State, Zone, Circle, Division, SubDivision.
    /// </summary>
    public interface IAdminMastersUseCase
    {
        // tbDsg
        ApiResponse<DsgListResponse> GetDesignations(bool activeOnly);
        ApiResponse<DsgIdResponse> CreateDesignation(CreateDsgRequest request);
        ApiResponse<EmptyResponse> UpdateDesignation(int dsgId, UpdateDsgRequest request);

        // State
        ApiResponse<StateListResponse> GetStates();
        ApiResponse<EmptyResponse> CreateState(CreateStateRequest request);
        ApiResponse<EmptyResponse> UpdateState(int stateId, UpdateStateRequest request);

        // Zone
        ApiResponse<ZoneListResponse> GetZones();
        ApiResponse<EmptyResponse> CreateZone(CreateZoneRequest request);
        ApiResponse<EmptyResponse> UpdateZone(int zoneId, UpdateZoneRequest request);

        // Circle
        ApiResponse<CircleListResponse> GetCircles(int? zoneId);
        ApiResponse<EmptyResponse> CreateCircle(CreateCircleRequest request);
        ApiResponse<EmptyResponse> UpdateCircle(int circleId, UpdateCircleRequest request);

        // Division
        ApiResponse<DivisionListResponse> GetDivisions(int? zoneId, int? circleId);
        ApiResponse<EmptyResponse> CreateDivision(CreateDivisionRequest request);
        ApiResponse<EmptyResponse> UpdateDivision(int divisionId, UpdateDivisionRequest request);

        // SubDivision
        ApiResponse<SubDivisionListResponse> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
        ApiResponse<EmptyResponse> CreateSubDivision(CreateSubDivisionRequest request);
        ApiResponse<EmptyResponse> UpdateSubDivision(int subDivisionId, UpdateSubDivisionRequest request);
    }
}