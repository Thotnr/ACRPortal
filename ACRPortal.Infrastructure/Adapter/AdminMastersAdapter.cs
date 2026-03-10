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
    /// Raw ADO.NET adapter for all six master tables.
    /// Connection string: ACRPortalContext (same as every other adapter).
    /// No Dapper — pure SqlCommand / SqlDataReader per project standard.
    ///
    /// For State / Zone / Circle / Division / SubDivision the caller supplies
    /// the business-key ID (State_ID, Zone_ID, etc.) explicitly in the request.
    /// The surrogate IDENTITY PK (SNID, ZID, …) is ignored — never read back.
    /// </summary>
    public class AdminMastersAdapter : IAdminMastersRepoPort
    {
        private readonly string _connStr =
            ConfigurationManager.ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  tbDsg — Designations                                              //
        // ================================================================== //

        public bool IsDsgCodeExists(string dsg)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.tbDsg WHERE dsg = @dsg";
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@dsg", SqlDbType.VarChar).Value = dsg;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        public int CreateDsg(string dsg, string dsgDesc, int dsgLevel)
        {
            // IDENTITY(1001,1) — OUTPUT INSERTED.dsgId returns the generated key
            const string sql = @"
                INSERT INTO dbo.tbDsg (dsg, dsgDesc, dsgLevel, dsgIsActive)
                OUTPUT INSERTED.dsgId
                VALUES (@dsg, @desc, @level, 1)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@dsg", SqlDbType.VarChar).Value = dsg;
                cmd.Parameters.Add("@desc", SqlDbType.VarChar).Value = (object)dsgDesc ?? DBNull.Value;
                cmd.Parameters.Add("@level", SqlDbType.Int).Value = dsgLevel;
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        public List<DsgItem> GetDesignations(bool activeOnly)
        {
            string sql = @"
                SELECT dsgId, dsg, dsgDesc, dsgLevel, dsgIsActive
                FROM   dbo.tbDsg"
                + (activeOnly ? " WHERE dsgIsActive = 1" : "")
                + " ORDER BY dsgLevel ASC";

            var list = new List<DsgItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        list.Add(new DsgItem
                        {
                            DsgId = dr.GetInt32(0),
                            Dsg = dr.GetString(1),
                            DsgDesc = dr.IsDBNull(2) ? null : dr.GetString(2),
                            DsgLevel = dr.GetInt32(3),
                            IsActive = dr.GetBoolean(4)
                        });
                    }
                }
            }
            return list;
        }

        // ================================================================== //
        //  State                                                             //
        // ================================================================== //

        public bool IsStateIdExists(int stateId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.State WHERE State_ID = @id";
            return ScalarBool(sql, "@id", SqlDbType.Int, stateId);
        }

        public void CreateState(int stateId, string stateName)
        {
            const string sql = @"
                INSERT INTO dbo.State (Country_ID, State_ID, State)
                VALUES (1, @id, @name)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = stateId;
                cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = stateName;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public List<StateItem> GetStates()
        {
            const string sql = "SELECT State_ID, State FROM dbo.State ORDER BY State ASC";
            var list = new List<StateItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        list.Add(new StateItem { StateId = dr.GetInt32(0), StateName = dr.GetString(1) });
                }
            }
            return list;
        }

        // ================================================================== //
        //  Zone                                                              //
        // ================================================================== //

        public bool IsZoneIdExists(int zoneId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Zone WHERE Zone_ID = @id";
            return ScalarBool(sql, "@id", SqlDbType.Int, zoneId);
        }

        public void CreateZone(int zoneId, string zoneName)
        {
            const string sql = "INSERT INTO dbo.Zone (Zone_ID, Zone) VALUES (@id, @name)";
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = zoneId;
                cmd.Parameters.Add("@name", SqlDbType.NVarChar).Value = zoneName;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public List<ZoneItem> GetZones()
        {
            const string sql = "SELECT Zone_ID, Zone FROM dbo.Zone ORDER BY Zone ASC";
            var list = new List<ZoneItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        list.Add(new ZoneItem { ZoneId = dr.GetInt32(0), ZoneName = dr.GetString(1) });
                }
            }
            return list;
        }

        // ================================================================== //
        //  Circle                                                            //
        // ================================================================== //

        public bool IsCircleIdExists(int circleId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle_ID = @id";
            return ScalarBool(sql, "@id", SqlDbType.Int, circleId);
        }

        public void CreateCircle(int zoneId, int circleId, string circle)
        {
            const string sql = @"
                INSERT INTO dbo.Circle (Zone_ID, Circle_ID, Circle)
                VALUES (@zoneId, @circleId, @circle)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId;
                cmd.Parameters.Add("@circleId", SqlDbType.Int).Value = circleId;
                cmd.Parameters.Add("@circle", SqlDbType.NVarChar).Value = circle;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public List<CircleItem> GetCircles(int? zoneId)
        {
            string sql = @"
                SELECT Circle_ID, Zone_ID, Circle
                FROM   dbo.Circle"
                + (zoneId.HasValue ? " WHERE Zone_ID = @zoneId" : "")
                + " ORDER BY Circle ASC";

            var list = new List<CircleItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (zoneId.HasValue)
                    cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId.Value;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        list.Add(new CircleItem
                        {
                            CircleId = dr.GetInt32(0),
                            ZoneId = dr.GetInt32(1),
                            Circle = dr.GetString(2)
                        });
                }
            }
            return list;
        }

        // ================================================================== //
        //  Division                                                          //
        // ================================================================== //

        public bool IsDivisionIdExists(int divisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division_ID = @id";
            return ScalarBool(sql, "@id", SqlDbType.Int, divisionId);
        }

        public void CreateDivision(int zoneId, int circleId, int divisionId, string division)
        {
            const string sql = @"
                INSERT INTO dbo.Division (Zone_ID, Circle_ID, Division_ID, Division)
                VALUES (@zoneId, @circleId, @divId, @div)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId;
                cmd.Parameters.Add("@circleId", SqlDbType.Int).Value = circleId;
                cmd.Parameters.Add("@divId", SqlDbType.Int).Value = divisionId;
                cmd.Parameters.Add("@div", SqlDbType.NVarChar).Value = division;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public List<DivisionItem> GetDivisions(int? zoneId, int? circleId)
        {
            string where = BuildWhere(
                zoneId.HasValue ? "Zone_ID = @zoneId" : null,
                circleId.HasValue ? "Circle_ID = @circleId" : null);

            string sql = "SELECT Division_ID, Zone_ID, Circle_ID, Division FROM dbo.Division"
                         + where + " ORDER BY Division ASC";

            var list = new List<DivisionItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (zoneId.HasValue) cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId.Value;
                if (circleId.HasValue) cmd.Parameters.Add("@circleId", SqlDbType.Int).Value = circleId.Value;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        list.Add(new DivisionItem
                        {
                            DivisionId = dr.GetInt32(0),
                            ZoneId = dr.GetInt32(1),
                            CircleId = dr.GetInt32(2),
                            Division = dr.GetString(3)
                        });
                }
            }
            return list;
        }

        // ================================================================== //
        //  SubDivision                                                       //
        // ================================================================== //

        public bool IsSubDivisionIdExists(int subDivisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.SubDivision WHERE SubDivisionID = @id";
            return ScalarBool(sql, "@id", SqlDbType.Int, subDivisionId);
        }

        public void CreateSubDivision(int zoneId, int circleId, int divisionId,
                                       int subDivisionId, string subDivision)
        {
            const string sql = @"
                INSERT INTO dbo.SubDivision (Zone_ID, Circle_ID, Division_ID, SubDivisionID, SubDivision)
                VALUES (@zoneId, @circleId, @divId, @subId, @sub)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId;
                cmd.Parameters.Add("@circleId", SqlDbType.Int).Value = circleId;
                cmd.Parameters.Add("@divId", SqlDbType.Int).Value = divisionId;
                cmd.Parameters.Add("@subId", SqlDbType.Int).Value = subDivisionId;
                cmd.Parameters.Add("@sub", SqlDbType.NVarChar).Value = subDivision;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public List<SubDivisionItem> GetSubDivisions(int? zoneId, int? circleId, int? divisionId)
        {
            string where = BuildWhere(
                zoneId.HasValue ? "Zone_ID = @zoneId" : null,
                circleId.HasValue ? "Circle_ID = @circleId" : null,
                divisionId.HasValue ? "Division_ID = @divisionId" : null);

            string sql = @"
                SELECT SubDivisionID, Zone_ID, Circle_ID, Division_ID, SubDivision
                FROM   dbo.SubDivision"
                + where + " ORDER BY SubDivision ASC";

            var list = new List<SubDivisionItem>();
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (zoneId.HasValue) cmd.Parameters.Add("@zoneId", SqlDbType.Int).Value = zoneId.Value;
                if (circleId.HasValue) cmd.Parameters.Add("@circleId", SqlDbType.Int).Value = circleId.Value;
                if (divisionId.HasValue) cmd.Parameters.Add("@divisionId", SqlDbType.Int).Value = divisionId.Value;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        list.Add(new SubDivisionItem
                        {
                            SubDivisionId = dr.GetInt32(0),
                            ZoneId = dr.GetInt32(1),
                            CircleId = dr.GetInt32(2),
                            DivisionId = dr.GetInt32(3),
                            SubDivision = dr.GetString(4)
                        });
                }
            }
            return list;
        }

        // ================================================================== //
        //  Private helpers                                                   //
        // ================================================================== //

        private bool ScalarBool(string sql, string paramName, SqlDbType type, object value)
        {
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add(paramName, type).Value = value;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private static string BuildWhere(params string[] conditions)
        {
            var parts = new System.Collections.Generic.List<string>();
            foreach (var c in conditions)
                if (c != null) parts.Add(c);
            return parts.Count == 0 ? string.Empty : " WHERE " + string.Join(" AND ", parts);
        }
    }
}