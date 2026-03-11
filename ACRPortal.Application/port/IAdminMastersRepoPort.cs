using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    /// <summary>
    /// Data access port for the six master/lookup tables.
    /// Implemented by AdminMastersAdapter in ACRPortal.Infrastructure.
    /// </summary>
    public interface IAdminMastersRepoPort
    {
        // ---- tbDsg -------------------------------------------------------
        bool IsDsgCodeExists(string dsg);
        bool IsDsgCodeExistsExcluding(string dsg, int excludeDsgId);   // for update: ignore self
        bool IsDsgIdExists(int dsgId);
        int CreateDsg(string dsg, string dsgDesc, int dsgLevel);      // returns new dsgId (IDENTITY)
        void UpdateDsg(int dsgId, string dsg, string dsgDesc, int dsgLevel);
        List<DsgItem> GetDesignations(bool activeOnly);

        // ---- State -------------------------------------------------------
        bool IsStateIdExists(int stateId);
        bool IsStateNameExists(string stateName);
        bool IsStateNameExistsExcluding(string stateName, int excludeStateId); // for update
        void CreateState(int stateId, string stateName);
        void UpdateState(int stateId, string stateName);
        List<StateItem> GetStates();

        // ---- Zone --------------------------------------------------------
        bool IsZoneIdExists(int zoneId);
        bool IsZoneNameExists(string zoneName);
        bool IsZoneNameExistsExcluding(string zoneName, int excludeZoneId);    // for update
        void CreateZone(int zoneId, string zoneName);
        void UpdateZone(int zoneId, string zoneName);
        List<ZoneItem> GetZones();

        // ---- Circle ------------------------------------------------------
        bool IsCircleIdExists(int circleId);
        bool IsCircleNameExists(string circle);
        bool IsCircleNameExistsExcluding(string circle, int excludeCircleId);  // for update
        void CreateCircle(int zoneId, int circleId, string circle);
        void UpdateCircle(int circleId, string circle);
        List<CircleItem> GetCircles(int? zoneId);

        // ---- Division ----------------------------------------------------
        bool IsDivisionIdExists(int divisionId);
        bool IsDivisionNameExists(string division);
        bool IsDivisionNameExistsExcluding(string division, int excludeDivisionId); // for update
        void CreateDivision(int zoneId, int circleId, int divisionId, string division);
        void UpdateDivision(int divisionId, string division);
        List<DivisionItem> GetDivisions(int? zoneId, int? circleId);

        // ---- SubDivision -------------------------------------------------
        bool IsSubDivisionIdExists(int subDivisionId);
        bool IsSubDivisionNameExists(string subDivision);
        bool IsSubDivisionNameExistsExcluding(string subDivision, int excludeSubDivisionId); // for update
        void CreateSubDivision(int zoneId, int circleId, int divisionId, int subDivisionId, string subDivision);
        void UpdateSubDivision(int subDivisionId, string subDivision);
        List<SubDivisionItem> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
    }
}