using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IAdminMastersRepoPort
    {
        bool IsDsgCodeExists(string dsg);
        bool IsDsgCodeExistsExcluding(string dsg, int excludeDsgId);
        bool IsDsgIdExists(int dsgId);
        int CreateDsg(string dsg, string dsgDesc, int dsgLevel, string formType);
        void UpdateDsg(int dsgId, string dsg, string dsgDesc, int dsgLevel, string formType);
        List<DsgItem> GetDesignations(bool activeOnly);

        bool IsStateIdExists(int stateId);
        bool IsStateNameExists(string stateName);
        bool IsStateNameExistsExcluding(string stateName, int excludeStateId);
        void CreateState(int stateId, string stateName);
        void UpdateState(int stateId, string stateName);
        List<StateItem> GetStates();

        bool IsZoneIdExists(int zoneId);
        bool IsZoneNameExists(string zoneName);
        bool IsZoneNameExistsExcluding(string zoneName, int excludeZoneId);
        void CreateZone(int zoneId, string zoneName);
        void UpdateZone(int zoneId, string zoneName);
        List<ZoneItem> GetZones();

        bool IsCircleIdExists(int circleId);
        bool IsCircleNameExists(string circle);
        bool IsCircleNameExistsExcluding(string circle, int excludeCircleId);
        void CreateCircle(int zoneId, int circleId, string circle);
        void UpdateCircle(int circleId, string circle);
        List<CircleItem> GetCircles(int? zoneId);

        bool IsDivisionIdExists(int divisionId);
        bool IsDivisionNameExists(string division);
        bool IsDivisionNameExistsExcluding(string division, int excludeDivisionId);
        void CreateDivision(int zoneId, int circleId, int divisionId, string division);
        void UpdateDivision(int divisionId, string division);
        List<DivisionItem> GetDivisions(int? zoneId, int? circleId);

        bool IsSubDivisionIdExists(int subDivisionId);
        bool IsSubDivisionNameExists(string subDivision);
        bool IsSubDivisionNameExistsExcluding(string subDivision, int excludeSubDivisionId);
        void CreateSubDivision(int zoneId, int circleId, int divisionId, int subDivisionId, string subDivision);
        void UpdateSubDivision(int subDivisionId, string subDivision);
        List<SubDivisionItem> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
    }
}