using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class AdminAdapter : IAdminRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  Existence checks                                                   //
        // ================================================================== //

        public bool IsLoginIdExists(string loginId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.users WHERE login_id = @loginId";
            return ExistsCheck(sql, new SqlParameter("@loginId", loginId));
        }

        public bool IsUserExists(Guid userId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.users WHERE user_id = @userId";
            return ExistsCheck(sql, new SqlParameter("@userId", userId));
        }

        // ================================================================== //
        //  Master data validation                                             //
        // ================================================================== //

        public bool IsDsgIdValid(int dsgId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.tbDsg WHERE dsgId = @id AND dsgIsActive = 1";
            return ExistsCheck(sql, new SqlParameter("@id", dsgId));
        }

        public bool IsStateIdValid(int stateId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.State WHERE State_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", stateId));
        }

        public bool IsZoneIdValid(int zoneId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Zone WHERE Zone_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", zoneId));
        }

        public bool IsCircleIdValid(int circleId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", circleId));
        }

        public bool IsDivisionIdValid(int divisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division_ID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", divisionId));
        }

        public bool IsSubDivisionIdValid(int subDivisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.SubDivision WHERE SubDivisionID = @id";
            return ExistsCheck(sql, new SqlParameter("@id", subDivisionId));
        }

        // ================================================================== //
        //  Hierarchy checks                                                   //
        // ================================================================== //

        public bool IsCircleInZone(int circleId, int zoneId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Circle WHERE Circle_ID = @circleId AND Zone_ID = @zoneId";
            return ExistsCheck(sql,
                new SqlParameter("@circleId", circleId),
                new SqlParameter("@zoneId", zoneId));
        }

        public bool IsDivisionInCircle(int divisionId, int circleId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.Division WHERE Division_ID = @divisionId AND Circle_ID = @circleId";
            return ExistsCheck(sql,
                new SqlParameter("@divisionId", divisionId),
                new SqlParameter("@circleId", circleId));
        }

        public bool IsSubDivisionInDivision(int subDivisionId, int divisionId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.SubDivision WHERE SubDivisionID = @subId AND Division_ID = @divisionId";
            return ExistsCheck(sql,
                new SqlParameter("@subId", subDivisionId),
                new SqlParameter("@divisionId", divisionId));
        }

        // ================================================================== //
        //  Geo snapshot (for partial update validation)                       //
        // ================================================================== //

        public UserGeoSnapshot GetUserGeoSnapshot(Guid userId)
        {
            const string sql = @"
                SELECT state_id, zone_id, circle_id, division_id, sub_division_id
                FROM   dbo.users
                WHERE  user_id = @userId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return new UserGeoSnapshot();
                    return new UserGeoSnapshot
                    {
                        StateId = r.IsDBNull(0) ? (int?)null : r.GetInt32(0),
                        ZoneId = r.IsDBNull(1) ? (int?)null : r.GetInt32(1),
                        CircleId = r.IsDBNull(2) ? (int?)null : r.GetInt32(2),
                        DivisionId = r.IsDBNull(3) ? (int?)null : r.GetInt32(3),
                        SubDivisionId = r.IsDBNull(4) ? (int?)null : r.GetInt32(4),
                    };
                }
            }
        }

        // ================================================================== //
        //  Create user                                                        //
        // ================================================================== //

        public string CreateUser(
            string displayName,
            string loginId,
            string passwordHash,
            string systemRole,
            int? dsgId,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId)
        {
            const string sql = @"
                INSERT INTO dbo.users
                    (display_name, login_id, password_hash, system_role, user_status,
                     dsg_id, state_id, zone_id, circle_id, division_id, sub_division_id)
                OUTPUT INSERTED.user_id
                VALUES
                    (@displayName, @loginId, @passwordHash, @systemRole, 'ACTIVE',
                     @dsgId, @stateId, @zoneId, @circleId, @divisionId, @subDivisionId)";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@displayName", displayName);
                cmd.Parameters.AddWithValue("@loginId", loginId);
                cmd.Parameters.AddWithValue("@passwordHash", passwordHash);
                cmd.Parameters.AddWithValue("@systemRole", systemRole);
                cmd.Parameters.AddWithValue("@dsgId", (object)dsgId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@stateId", (object)stateId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@zoneId", (object)zoneId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@circleId", (object)circleId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@divisionId", (object)divisionId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@subDivisionId", (object)subDivisionId ?? DBNull.Value);
                con.Open();
                return cmd.ExecuteScalar().ToString();
            }
        }

        // ================================================================== //
        //  Update user profile                                                //
        // ================================================================== //

        public void UpdateUser(
            Guid userId,
            string displayName,
            int? dsgId,
            bool clearDsg,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId,
            bool clearGeography)
        {
            // Build SET clause dynamically — only touch fields that were sent
            var sets = new List<string> { "updated_at = GETDATE()" };
            var parms = new List<SqlParameter>();

            if (displayName != null)
            {
                sets.Add("display_name = @displayName");
                parms.Add(new SqlParameter("@displayName", displayName));
            }

            // Designation
            if (clearDsg)
            {
                sets.Add("dsg_id = NULL");
            }
            else if (dsgId.HasValue)
            {
                sets.Add("dsg_id = @dsgId");
                parms.Add(new SqlParameter("@dsgId", dsgId.Value));
            }

            // Geography
            if (clearGeography)
            {
                sets.Add("state_id = NULL, zone_id = NULL, circle_id = NULL, division_id = NULL, sub_division_id = NULL");
            }
            else
            {
                if (stateId.HasValue) { sets.Add("state_id = @stateId"); parms.Add(new SqlParameter("@stateId", stateId.Value)); }
                if (zoneId.HasValue) { sets.Add("zone_id = @zoneId"); parms.Add(new SqlParameter("@zoneId", zoneId.Value)); }
                if (circleId.HasValue) { sets.Add("circle_id = @circleId"); parms.Add(new SqlParameter("@circleId", circleId.Value)); }
                if (divisionId.HasValue) { sets.Add("division_id = @divisionId"); parms.Add(new SqlParameter("@divisionId", divisionId.Value)); }
                if (subDivisionId.HasValue) { sets.Add("sub_division_id = @subDivisionId"); parms.Add(new SqlParameter("@subDivisionId", subDivisionId.Value)); }
            }

            if (sets.Count == 1) return;  // only updated_at — nothing meaningful to update

            string sql = $"UPDATE dbo.users SET {string.Join(", ", sets)} WHERE user_id = @userId";
            parms.Add(new SqlParameter("@userId", userId));

            ExecuteNonQuery(sql, parms.ToArray());
        }

        // ================================================================== //
        //  Update status                                                      //
        // ================================================================== //

        public void UpdateUserStatus(Guid userId, string userStatus)
        {
            const string sql = "UPDATE dbo.users SET user_status = @status, updated_at = GETDATE() WHERE user_id = @userId";
            ExecuteNonQuery(sql,
                new SqlParameter("@status", userStatus),
                new SqlParameter("@userId", userId));
        }

        // ================================================================== //
        //  List users                                                         //
        // ================================================================== //

        public UserListResponse GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId)
        {
            var where = new List<string>();
            var parms = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(role)) { where.Add("u.system_role = @role"); parms.Add(new SqlParameter("@role", role.ToUpper())); }
            if (!string.IsNullOrWhiteSpace(status)) { where.Add("u.user_status = @status"); parms.Add(new SqlParameter("@status", status.ToUpper())); }
            if (dsgId.HasValue) { where.Add("u.dsg_id = @dsgId"); parms.Add(new SqlParameter("@dsgId", dsgId.Value)); }
            if (zoneId.HasValue) { where.Add("u.zone_id = @zoneId"); parms.Add(new SqlParameter("@zoneId", zoneId.Value)); }
            if (divisionId.HasValue) { where.Add("u.division_id = @divisionId"); parms.Add(new SqlParameter("@divisionId", divisionId.Value)); }

            string whereClause = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";

            string sql = $@"
                SELECT u.user_id, u.login_id, u.display_name, u.system_role, u.user_status,
                       u.dsg_id, d.dsg AS dsg_name,
                       sd.SubDivision,
                       u.created_at
                FROM   dbo.users u
                LEFT   JOIN dbo.tbDsg       d  ON d.dsgId          = u.dsg_id
                LEFT   JOIN dbo.SubDivision sd ON sd.SubDivisionID  = u.sub_division_id
                {whereClause}
                ORDER  BY u.created_at DESC";

            var list = new List<UserListItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(parms.ToArray());
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new UserListItem
                        {
                            UserId = r.GetGuid(0).ToString(),
                            LoginId = r.GetString(1),
                            DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                            SystemRole = r.GetString(3),
                            UserStatus = r.GetString(4),
                            DsgId = r.IsDBNull(5) ? (int?)null : r.GetInt32(5),
                            DsgName = r.IsDBNull(6) ? null : r.GetString(6),
                            SubDivision = r.IsDBNull(7) ? null : r.GetString(7),
                            CreatedAt = r.GetDateTime(8).ToString("o"),
                        });
            }

            return new UserListResponse { Users = list, TotalCount = list.Count };
        }

        // ================================================================== //
        //  Get user detail                                                    //
        // ================================================================== //

        public UserDetailResponse GetUserById(Guid userId)
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name, u.system_role, u.user_status, u.created_at,
                       u.dsg_id,         d.dsg         AS dsg_name,
                       u.state_id,       st.State      AS state_name,
                       u.zone_id,        z.Zone        AS zone_name,
                       u.circle_id,      c.Circle      AS circle_name,
                       u.division_id,    dv.Division   AS division_name,
                       u.sub_division_id, sd.SubDivision AS sub_division_name
                FROM   dbo.users u
                LEFT   JOIN dbo.tbDsg       d  ON d.dsgId          = u.dsg_id
                LEFT   JOIN dbo.State       st ON st.State_ID       = u.state_id
                LEFT   JOIN dbo.Zone        z  ON z.Zone_ID         = u.zone_id
                LEFT   JOIN dbo.Circle      c  ON c.Circle_ID       = u.circle_id
                LEFT   JOIN dbo.Division    dv ON dv.Division_ID    = u.division_id
                LEFT   JOIN dbo.SubDivision sd ON sd.SubDivisionID  = u.sub_division_id
                WHERE  u.user_id = @userId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;
                    return new UserDetailResponse
                    {
                        UserId = r.GetGuid(0).ToString(),
                        LoginId = r.GetString(1),
                        DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                        SystemRole = r.GetString(3),
                        UserStatus = r.GetString(4),
                        CreatedAt = r.GetDateTime(5).ToString("o"),
                        DsgId = r.IsDBNull(6) ? (int?)null : r.GetInt32(6),
                        DsgName = r.IsDBNull(7) ? null : r.GetString(7),
                        StateId = r.IsDBNull(8) ? (int?)null : r.GetInt32(8),
                        StateName = r.IsDBNull(9) ? null : r.GetString(9),
                        ZoneId = r.IsDBNull(10) ? (int?)null : r.GetInt32(10),
                        ZoneName = r.IsDBNull(11) ? null : r.GetString(11),
                        CircleId = r.IsDBNull(12) ? (int?)null : r.GetInt32(12),
                        CircleName = r.IsDBNull(13) ? null : r.GetString(13),
                        DivisionId = r.IsDBNull(14) ? (int?)null : r.GetInt32(14),
                        DivisionName = r.IsDBNull(15) ? null : r.GetString(15),
                        SubDivisionId = r.IsDBNull(16) ? (int?)null : r.GetInt32(16),
                        SubDivision = r.IsDBNull(17) ? null : r.GetString(17),
                    };
                }
            }
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