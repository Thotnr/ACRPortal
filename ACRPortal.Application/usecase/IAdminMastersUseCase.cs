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

        // State
        ApiResponse<StateListResponse> GetStates();
        ApiResponse<EmptyResponse> CreateState(CreateStateRequest request);

        // Zone
        ApiResponse<ZoneListResponse> GetZones();
        ApiResponse<EmptyResponse> CreateZone(CreateZoneRequest request);

        // Circle
        ApiResponse<CircleListResponse> GetCircles(int? zoneId);
        ApiResponse<EmptyResponse> CreateCircle(CreateCircleRequest request);

        // Division
        ApiResponse<DivisionListResponse> GetDivisions(int? zoneId, int? circleId);
        ApiResponse<EmptyResponse> CreateDivision(CreateDivisionRequest request);

        // SubDivision
        ApiResponse<SubDivisionListResponse> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
        ApiResponse<EmptyResponse> CreateSubDivision(CreateSubDivisionRequest request);
    }
}