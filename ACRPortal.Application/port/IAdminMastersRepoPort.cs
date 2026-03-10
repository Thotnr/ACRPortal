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
        int CreateDsg(string dsg, string dsgDesc, int dsgLevel);          // returns new dsgId
        List<DsgItem> GetDesignations(bool activeOnly);

        // ---- State -------------------------------------------------------
        bool IsStateIdExists(int stateId);
        void CreateState(int stateId, string stateName);
        List<StateItem> GetStates();

        // ---- Zone --------------------------------------------------------
        bool IsZoneIdExists(int zoneId);
        void CreateZone(int zoneId, string zoneName);
        List<ZoneItem> GetZones();

        // ---- Circle ------------------------------------------------------
        bool IsCircleIdExists(int circleId);
        void CreateCircle(int zoneId, int circleId, string circle);
        List<CircleItem> GetCircles(int? zoneId);

        // ---- Division ----------------------------------------------------
        bool IsDivisionIdExists(int divisionId);
        void CreateDivision(int zoneId, int circleId, int divisionId, string division);
        List<DivisionItem> GetDivisions(int? zoneId, int? circleId);

        // ---- SubDivision -------------------------------------------------
        bool IsSubDivisionIdExists(int subDivisionId);
        void CreateSubDivision(int zoneId, int circleId, int divisionId, int subDivisionId, string subDivision);
        List<SubDivisionItem> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
    }
}