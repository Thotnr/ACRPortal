using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Shared master item DTOs                                            //
    // ------------------------------------------------------------------ //

    public class DsgItem
    {
        public int DsgId { get; set; }
        public string Dsg { get; set; }
        public string DsgDesc { get; set; }
        public int DsgLevel { get; set; }
        public bool IsActive { get; set; }
    }

    public class StateItem
    {
        public int StateId { get; set; }  // State_ID — caller-assigned business key
        public string StateName { get; set; }
    }

    public class ZoneItem
    {
        public int ZoneId { get; set; }   // Zone_ID — caller-assigned business key
        public string ZoneName { get; set; }
    }

    public class CircleItem
    {
        public int CircleId { get; set; }
        public int ZoneId { get; set; }
        public string Circle { get; set; }
    }

    public class DivisionItem
    {
        public int DivisionId { get; set; }
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public string Division { get; set; }
    }

    public class SubDivisionItem
    {
        public int SubDivisionId { get; set; }
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public int DivisionId { get; set; }
        public string SubDivision { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Request DTOs                                                       //
    // ------------------------------------------------------------------ //

    public class CreateDsgRequest
    {
        public string Dsg { get; set; }  // required — short code e.g. "SE"
        public string DsgDesc { get; set; }  // optional
        public int DsgLevel { get; set; }  // required — > 0
    }

    public class CreateStateRequest
    {
        public int StateId { get; set; }  // caller-assigned business key
        public string StateName { get; set; }
    }

    public class CreateZoneRequest
    {
        public int ZoneId { get; set; }
        public string ZoneName { get; set; }
    }

    public class CreateCircleRequest
    {
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public string Circle { get; set; }
    }

    public class CreateDivisionRequest
    {
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public int DivisionId { get; set; }
        public string Division { get; set; }
    }

    public class CreateSubDivisionRequest
    {
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public int DivisionId { get; set; }
        public int SubDivisionId { get; set; }
        public string SubDivision { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Response list wrappers — all list properties must be non-null      //
    //  so ApiResponse<T> new() doesn't throw                             //
    // ------------------------------------------------------------------ //

    public class DsgListResponse
    {
        public List<DsgItem> Designations { get; set; } = new List<DsgItem>();
    }

    public class DsgIdResponse
    {
        public int DsgId { get; set; }
    }

    public class StateListResponse
    {
        public List<StateItem> States { get; set; } = new List<StateItem>();
    }

    public class ZoneListResponse
    {
        public List<ZoneItem> Zones { get; set; } = new List<ZoneItem>();
    }

    public class CircleListResponse
    {
        public List<CircleItem> Circles { get; set; } = new List<CircleItem>();
    }

    public class DivisionListResponse
    {
        public List<DivisionItem> Divisions { get; set; } = new List<DivisionItem>();
    }

    public class SubDivisionListResponse
    {
        public List<SubDivisionItem> SubDivisions { get; set; } = new List<SubDivisionItem>();
    }
}