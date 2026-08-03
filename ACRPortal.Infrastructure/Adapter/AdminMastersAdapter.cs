using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    /// <summary>
    /// ADO.NET adapter for all six master tables.
    ///
    /// Key rules enforced at DB layer:
    ///   • UNIQUE constraints on name columns (added by schema migration — see migration script).
    ///   • Business-key columns (State_ID, Zone_ID, Circle_ID, Division_ID, SubDivisionID)
    ///     are used as the stable identifier for every UPDATE and for all "exists" checks.
    ///   • The IDENTITY PKs (SNID, ZID, CID, DID, SID) are NEVER exposed to the caller.
    /// </summary>
    public class AdminMastersAdapter : IAdminMastersRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  tbDsg                                                              //
        // ================================================================== //

        public bool IsDsgCodeExists(string dsg)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.tbDsg WHERE dsg = @dsg";
            return ExistsCheck(sql, new SqlParameter("@dsg", dsg));
        }

        public bool IsDsgCodeExistsExcluding(string dsg, int excludeDsgId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.tbDsg WHERE dsg = @dsg AND dsgId <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@dsg", dsg),
                new SqlParameter("@id", excludeDsgId));
        }

        public bool IsDsgIdExists(int dsgId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.tbDsg WHERE dsgId = @id";
            return ExistsCheck(sql, new SqlParameter("@id", dsgId));
        }

        public int CreateDsg(string dsg, string dsgDesc, int dsgLevel, string formType)
        {
            const string sql = @"
                INSERT INTO dbo.tbDsg (dsg, dsgDesc, dsgLevel, dsgIsActive, form_type)
                VALUES (@dsg, @dsgDesc, @dsgLevel, 1, @formType);
                SELECT SCOPE_IDENTITY();";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@dsg", dsg);
                cmd.Parameters.AddWithValue("@dsgDesc", (object)dsgDesc ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@dsgLevel", dsgLevel);
                cmd.Parameters.AddWithValue("@formType", formType);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public void UpdateDsg(int dsgId, string dsg, string dsgDesc, int dsgLevel, string formType)
        {
            const string sql = @"
                UPDATE dbo.tbDsg
                SET    dsg       = @dsg,
                       dsgDesc   = @dsgDesc,
                       dsgLevel  = @dsgLevel,
                       form_type = @formType
                WHERE  dsgId     = @id";

            ExecuteNonQuery(sql,
                new SqlParameter("@dsg", dsg),
                new SqlParameter("@dsgDesc", (object)dsgDesc ?? DBNull.Value),
                new SqlParameter("@dsgLevel", dsgLevel),
                new SqlParameter("@formType", formType),
                new SqlParameter("@id", dsgId));
        }

        public List<DsgItem> GetDesignations(bool activeOnly)
        {
            string sql = @"
                SELECT dsgId, dsg, dsgDesc, dsgLevel, dsgIsActive, form_type
                FROM   dbo.tbDsg"
                + (activeOnly ? " WHERE dsgIsActive = 1" : "")
                + " ORDER BY dsgLevel, dsgId";

            var list = new List<DsgItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new DsgItem
                        {
                            DsgId = r.GetInt32(0),
                            Dsg = r.IsDBNull(1) ? null : r.GetString(1),
                            DsgDesc = r.IsDBNull(2) ? null : r.GetString(2),
                            DsgLevel = r.IsDBNull(3) ? 0 : r.GetInt32(3),
                            IsActive = !r.IsDBNull(4) && r.GetBoolean(4),
                            FormType = r.IsDBNull(5) ? null : r.GetString(5)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  State                                                              //
        // ================================================================== //

        public bool IsStateIdExists(int stateId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.State WHERE State_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", stateId));
        }

        public bool IsStateNameExists(string stateName)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.State WHERE State = @name";
            return ExistsCheck(sql, new SqlParameter("@name", stateName));
        }

        public bool IsStateNameExistsExcluding(string stateName, int excludeStateId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.State WHERE State = @name AND State_ID <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@name", stateName),
                new SqlParameter("@id", excludeStateId));
        }

        public void CreateState(int stateId, string stateName)
        {
            const string sql = @"
                INSERT INTO dbo.State (State_ID, State)
                VALUES (@stateId, @stateName)";

            ExecuteNonQuery(sql,
                new SqlParameter("@stateId", stateId),
                new SqlParameter("@stateName", stateName));
        }

        public void UpdateState(int stateId, string stateName)
        {
            // Locate by business key State_ID — never touch SNID (identity PK)
            const string sql = @"
                UPDATE dbo.State
                SET    State    = @stateName
                WHERE  State_ID = @stateId";

            ExecuteNonQuery(sql,
                new SqlParameter("@stateName", stateName),
                new SqlParameter("@stateId", stateId));
        }

        public List<StateItem> GetStates()
        {
            const string sql = "SELECT State_ID, State FROM dbo.State ORDER BY State_ID";
            var list = new List<StateItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new StateItem
                        {
                            StateId = r.GetInt32(0),
                            StateName = r.IsDBNull(1) ? null : r.GetString(1)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  Zone                                                               //
        // ================================================================== //

        public bool IsZoneIdExists(int zoneId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Zone WHERE Zone_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", zoneId));
        }

        public bool IsZoneNameExists(string zoneName)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Zone WHERE Zone = @name";
            return ExistsCheck(sql, new SqlParameter("@name", zoneName));
        }

        public bool IsZoneNameExistsExcluding(string zoneName, int excludeZoneId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Zone WHERE Zone = @name AND Zone_ID <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@name", zoneName),
                new SqlParameter("@id", excludeZoneId));
        }

        public void CreateZone(int zoneId, string zoneName)
        {
            const string sql = @"
                INSERT INTO dbo.Zone (Zone_ID, Zone)
                VALUES (@zoneId, @zoneName)";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneId", zoneId),
                new SqlParameter("@zoneName", zoneName));
        }

        public void UpdateZone(int zoneId, string zoneName)
        {
            // Locate by business key Zone_ID — never touch ZID (identity PK)
            const string sql = @"
                UPDATE dbo.Zone
                SET    Zone    = @zoneName
                WHERE  Zone_ID = @zoneId";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneName", zoneName),
                new SqlParameter("@zoneId", zoneId));
        }

        public List<ZoneItem> GetZones()
        {
            const string sql = "SELECT Zone_ID, Zone FROM dbo.Zone ORDER BY Zone_ID";
            var list = new List<ZoneItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new ZoneItem
                        {
                            ZoneId = r.GetInt32(0),
                            ZoneName = r.IsDBNull(1) ? null : r.GetString(1)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  Circle                                                             //
        // ================================================================== //

        public bool IsCircleIdExists(int circleId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", circleId));
        }

        public bool IsCircleNameExists(string circle)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle = @name";
            return ExistsCheck(sql, new SqlParameter("@name", circle));
        }

        public bool IsCircleNameExistsExcluding(string circle, int excludeCircleId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle = @name AND Circle_ID <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@name", circle),
                new SqlParameter("@id", excludeCircleId));
        }

        public void CreateCircle(int zoneId, int circleId, string circle)
        {
            const string sql = @"
                INSERT INTO dbo.Circle (Zone_ID, Circle_ID, Circle)
                VALUES (@zoneId, @circleId, @circle)";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneId", zoneId),
                new SqlParameter("@circleId", circleId),
                new SqlParameter("@circle", circle));
        }

        public void UpdateCircle(int zoneId, int circleId, string circle)
        {
            // Locate by business key Circle_ID — never touch CID (identity PK)
            const string sql = @"
                UPDATE dbo.Circle
                SET    Zone_ID   = @zoneId,
                       Circle    = @circle
                WHERE  Circle_ID = @circleId";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneId", zoneId),
                new SqlParameter("@circle", circle),
                new SqlParameter("@circleId", circleId));
        }

        public List<CircleItem> GetCircles(int? zoneId)
        {
            string sql = "SELECT Zone_ID, Circle_ID, Circle FROM dbo.Circle"
                + (zoneId.HasValue ? " WHERE Zone_ID = @zoneId" : "")
                + " ORDER BY Circle_ID";

            var list = new List<CircleItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                if (zoneId.HasValue)
                    cmd.Parameters.AddWithValue("@zoneId", zoneId.Value);
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new CircleItem
                        {
                            ZoneId = r.GetInt32(0),
                            CircleId = r.GetInt32(1),
                            Circle = r.IsDBNull(2) ? null : r.GetString(2)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  Division                                                           //
        // ================================================================== //

        public bool IsDivisionIdExists(int divisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", divisionId));
        }

        public bool IsDivisionNameExists(string division)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division = @name";
            return ExistsCheck(sql, new SqlParameter("@name", division));
        }

        public bool IsDivisionNameExistsExcluding(string division, int excludeDivisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division = @name AND Division_ID <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@name", division),
                new SqlParameter("@id", excludeDivisionId));
        }

        public void CreateDivision(int zoneId, int circleId, int divisionId, string division)
        {
            const string sql = @"
                INSERT INTO dbo.Division (Zone_ID, Circle_ID, Division_ID, Division)
                VALUES (@zoneId, @circleId, @divisionId, @division)";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneId", zoneId),
                new SqlParameter("@circleId", circleId),
                new SqlParameter("@divisionId", divisionId),
                new SqlParameter("@division", division));
        }

        public void UpdateDivision(int divisionId, string division)
        {
            // Locate by business key Division_ID — never touch DID (identity PK)
            const string sql = @"
                UPDATE dbo.Division
                SET    Division    = @division
                WHERE  Division_ID = @divisionId";

            ExecuteNonQuery(sql,
                new SqlParameter("@division", division),
                new SqlParameter("@divisionId", divisionId));
        }

        public List<DivisionItem> GetDivisions(int? zoneId, int? circleId)
        {
            string where = "";
            if (zoneId.HasValue && circleId.HasValue)
                where = " WHERE Zone_ID = @zoneId AND Circle_ID = @circleId";
            else if (zoneId.HasValue)
                where = " WHERE Zone_ID = @zoneId";
            else if (circleId.HasValue)
                where = " WHERE Circle_ID = @circleId";

            string sql = "SELECT Zone_ID, Circle_ID, Division_ID, Division FROM dbo.Division"
                + where + " ORDER BY Division_ID";

            var list = new List<DivisionItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                if (zoneId.HasValue) cmd.Parameters.AddWithValue("@zoneId", zoneId.Value);
                if (circleId.HasValue) cmd.Parameters.AddWithValue("@circleId", circleId.Value);
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new DivisionItem
                        {
                            ZoneId = r.GetInt32(0),
                            CircleId = r.GetInt32(1),
                            DivisionId = r.GetInt32(2),
                            Division = r.IsDBNull(3) ? null : r.GetString(3)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  SubDivision                                                        //
        // ================================================================== //

        public bool IsSubDivisionIdExists(int subDivisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.SubDivision WHERE SubDivisionID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", subDivisionId));
        }

        public bool IsSubDivisionNameExists(string subDivision)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.SubDivision WHERE SubDivision = @name";
            return ExistsCheck(sql, new SqlParameter("@name", subDivision));
        }

        public bool IsSubDivisionNameExistsExcluding(string subDivision, int excludeSubDivisionId)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.SubDivision
                WHERE  SubDivision   = @name
                AND    SubDivisionID <> @id";
            return ExistsCheck(sql,
                new SqlParameter("@name", subDivision),
                new SqlParameter("@id", excludeSubDivisionId));
        }

        public void CreateSubDivision(int zoneId, int circleId, int divisionId, int subDivisionId, string subDivision)
        {
            const string sql = @"
                INSERT INTO dbo.SubDivision (Zone_ID, Circle_ID, Division_ID, SubDivisionID, SubDivision)
                VALUES (@zoneId, @circleId, @divisionId, @subDivisionId, @subDivision)";

            ExecuteNonQuery(sql,
                new SqlParameter("@zoneId", zoneId),
                new SqlParameter("@circleId", circleId),
                new SqlParameter("@divisionId", divisionId),
                new SqlParameter("@subDivisionId", subDivisionId),
                new SqlParameter("@subDivision", subDivision));
        }

        public void UpdateSubDivision(int subDivisionId, string subDivision)
        {
            // Locate by business key SubDivisionID — never touch SID (identity PK)
            const string sql = @"
                UPDATE dbo.SubDivision
                SET    SubDivision   = @subDivision
                WHERE  SubDivisionID = @subDivisionId";

            ExecuteNonQuery(sql,
                new SqlParameter("@subDivision", subDivision),
                new SqlParameter("@subDivisionId", subDivisionId));
        }

        public List<SubDivisionItem> GetSubDivisions(int? zoneId, int? circleId, int? divisionId)
        {
            string where = "";
            var conditions = new List<string>();
            if (zoneId.HasValue) conditions.Add("Zone_ID = @zoneId");
            if (circleId.HasValue) conditions.Add("Circle_ID = @circleId");
            if (divisionId.HasValue) conditions.Add("Division_ID = @divisionId");
            if (conditions.Count > 0) where = " WHERE " + string.Join(" AND ", conditions);

            string sql = "SELECT Zone_ID, Circle_ID, Division_ID, SubDivisionID, SubDivision FROM dbo.SubDivision"
                + where + " ORDER BY SubDivisionID";

            var list = new List<SubDivisionItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                if (zoneId.HasValue) cmd.Parameters.AddWithValue("@zoneId", zoneId.Value);
                if (circleId.HasValue) cmd.Parameters.AddWithValue("@circleId", circleId.Value);
                if (divisionId.HasValue) cmd.Parameters.AddWithValue("@divisionId", divisionId.Value);
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new SubDivisionItem
                        {
                            ZoneId = r.GetInt32(0),
                            CircleId = r.GetInt32(1),
                            DivisionId = r.GetInt32(2),
                            SubDivisionId = r.GetInt32(3),
                            SubDivision = r.IsDBNull(4) ? null : r.GetString(4)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  Private helpers                                                    //
        // ================================================================== //

        private bool ExistsCheck(string sql, params SqlParameter[] parameters)
        {
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(parameters);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private void ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(parameters);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
