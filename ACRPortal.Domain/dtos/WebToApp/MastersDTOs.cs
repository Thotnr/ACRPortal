using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Response item DTOs                                                 //
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
        public int CircleId { get; set; }   // Circle_ID — caller-assigned business key
        public int ZoneId { get; set; }
        public string Circle { get; set; }
    }

    public class DivisionItem
    {
        public int DivisionId { get; set; } // Division_ID — caller-assigned business key
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public string Division { get; set; }
    }

    public class SubDivisionItem
    {
        public int SubDivisionId { get; set; } // SubDivisionID — caller-assigned business key
        public int ZoneId { get; set; }
        public int CircleId { get; set; }
        public int DivisionId { get; set; }
        public string SubDivision { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  CREATE Request DTOs                                                //
    // ------------------------------------------------------------------ //

    public class CreateDsgRequest
    {
        public string Dsg { get; set; }  // required — short code e.g. "SE"; must be unique
        public string DsgDesc { get; set; }  // optional
        public int DsgLevel { get; set; }  // required — > 0
    }

    public class CreateStateRequest
    {
        public int StateId { get; set; }  // caller-assigned business key; must be unique
        public string StateName { get; set; }  // must be unique
    }

    public class CreateZoneRequest
    {
        public int ZoneId { get; set; }   // caller-assigned business key; must be unique
        public string ZoneName { get; set; }   // must be unique
    }

    public class CreateCircleRequest
    {
        public int ZoneId { get; set; }   // must exist in Zone table
        public int CircleId { get; set; }   // caller-assigned business key; must be unique
        public string Circle { get; set; }   // must be unique
    }

    public class CreateDivisionRequest
    {
        public int ZoneId { get; set; }  // must exist
        public int CircleId { get; set; }  // must exist
        public int DivisionId { get; set; }  // caller-assigned business key; must be unique
        public string Division { get; set; }  // must be unique
    }

    public class CreateSubDivisionRequest
    {
        public int ZoneId { get; set; }  // must exist
        public int CircleId { get; set; }  // must exist
        public int DivisionId { get; set; }  // must exist
        public int SubDivisionId { get; set; }  // caller-assigned business key; must be unique
        public string SubDivision { get; set; }  // must be unique
    }

    // ------------------------------------------------------------------ //
    //  UPDATE Request DTOs — only name fields; IDs are route params       //
    // ------------------------------------------------------------------ //

    public class UpdateDsgRequest
    {
        public string Dsg { get; set; }  // optional — new short code; must be unique if supplied
        public string DsgDesc { get; set; }  // optional
        public int? DsgLevel { get; set; }  // optional — > 0 if supplied
    }

    public class UpdateStateRequest
    {
        public string StateName { get; set; }  // required — must be unique
    }

    public class UpdateZoneRequest
    {
        public string ZoneName { get; set; }   // required — must be unique
    }

    public class UpdateCircleRequest
    {
        public string Circle { get; set; }     // required — must be unique
    }

    public class UpdateDivisionRequest
    {
        public string Division { get; set; }   // required — must be unique
    }

    public class UpdateSubDivisionRequest
    {
        public string SubDivision { get; set; }  // required — must be unique
    }

    // ------------------------------------------------------------------ //
    //  Response list wrappers                                             //
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