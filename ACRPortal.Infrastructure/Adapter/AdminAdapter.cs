using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;
using ACRPortal.Domain.Security;

namespace ACRPortal.Infrastructure.Adapter
{
    public class AdminAdapter : IAdminRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        private static readonly Security _security = new Security();

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
        //  Manager validation                                                 //
        // ================================================================== //

        public bool IsValidManager(string managerLoginId)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.users
                WHERE  login_id     = @loginId
                  AND  system_role  = 'EMPLOYEE'
                  AND  user_status  = 'ACTIVE'";
            return ExistsCheck(sql, new SqlParameter("@loginId", managerLoginId));
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
        //  Create user (transactional)                                        //
        // ================================================================== //

        public string CreateUserWithIdentities(
            string displayName,
            string loginId,
            string passwordHash,
            string systemRole,
            int? dsgId,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId,
            string managerLoginId,
            string email,
            string phone,
            string plainPassword)
        {
            const string insertUser = @"
                INSERT INTO dbo.users
                    (display_name, login_id, password_hash, decrypted_password, system_role, user_status,
                     dsg_id, state_id, zone_id, circle_id, division_id, sub_division_id, manager_id)
                OUTPUT INSERTED.user_id
                VALUES
                    (@displayName, @loginId, @passwordHash, @plainPassword, @systemRole, 'ACTIVE',
                     @dsgId, @stateId, @zoneId, @circleId, @divisionId, @subDivisionId, @managerLoginId)";

            const string insertIdentity = @"
                INSERT INTO dbo.user_identities (user_id, identity_type, identity_value, is_primary)
                VALUES (@userId, @identityType, @identityValue, 1)";

            using (var con = new SqlConnection(_conn))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                    try
                    {
                        Guid newUserId;
                        using (var cmd = new SqlCommand(insertUser, con, tx))
                        {
                            cmd.Parameters.AddWithValue("@displayName", displayName);
                            cmd.Parameters.AddWithValue("@loginId", loginId);
                            cmd.Parameters.AddWithValue("@passwordHash", passwordHash);
                            cmd.Parameters.AddWithValue("@plainPassword", (object)plainPassword ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@systemRole", systemRole);
                            cmd.Parameters.AddWithValue("@dsgId", (object)dsgId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@stateId", (object)stateId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@zoneId", (object)zoneId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@circleId", (object)circleId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@divisionId", (object)divisionId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@subDivisionId", (object)subDivisionId ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@managerLoginId", (object)managerLoginId ?? DBNull.Value);
                            newUserId = (Guid)cmd.ExecuteScalar();
                        }

                        if (email != null)
                        {
                            using (var cmd = new SqlCommand(insertIdentity, con, tx))
                            {
                                cmd.Parameters.AddWithValue("@userId", newUserId);
                                cmd.Parameters.AddWithValue("@identityType", "EMAIL");
                                cmd.Parameters.AddWithValue("@identityValue", _security.EncryptWithAes(email));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        if (phone != null)
                        {
                            using (var cmd = new SqlCommand(insertIdentity, con, tx))
                            {
                                cmd.Parameters.AddWithValue("@userId", newUserId);
                                cmd.Parameters.AddWithValue("@identityType", "PHONE");
                                cmd.Parameters.AddWithValue("@identityValue", _security.EncryptWithAes(phone));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();
                        return newUserId.ToString();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
            }
        }

        // ================================================================== //
        //  Update user profile                                                //
        // ================================================================== //

        public void UpdateUser(
            Guid userId,
            string displayName,
            string passwordHash,
            int? dsgId,
            bool clearDsg,
            int? stateId,
            int? zoneId,
            int? circleId,
            int? divisionId,
            int? subDivisionId,
            bool clearGeography,
            string managerLoginId,
            bool clearManager)
        {
            var sets = new List<string> { "updated_at = GETDATE()" };
            var parms = new List<SqlParameter>();

            if (displayName != null)
            {
                sets.Add("display_name = @displayName");
                parms.Add(new SqlParameter("@displayName", displayName));
            }

            if (passwordHash != null)
            {
                sets.Add("password_hash = @passwordHash");
                parms.Add(new SqlParameter("@passwordHash", passwordHash));
            }

            if (clearDsg)
            {
                sets.Add("dsg_id = NULL");
            }
            else if (dsgId.HasValue)
            {
                sets.Add("dsg_id = @dsgId");
                parms.Add(new SqlParameter("@dsgId", dsgId.Value));
            }

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

            if (clearManager)
            {
                sets.Add("manager_id = NULL");
            }
            else if (managerLoginId != null)
            {
                sets.Add("manager_id = @managerLoginId");
                parms.Add(new SqlParameter("@managerLoginId", managerLoginId));
            }

            if (sets.Count == 1) return;  // only updated_at — nothing meaningful to write

            string sql = $"UPDATE dbo.users SET {string.Join(", ", sets)} WHERE user_id = @userId";
            parms.Add(new SqlParameter("@userId", userId));
            ExecuteNonQuery(sql, parms.ToArray());
        }

        // ================================================================== //
        //  Identity upsert / delete                                           //
        // ================================================================== //

        public void UpsertUserIdentity(Guid userId, string identityType, string identityValue)
        {
            string encrypted = _security.EncryptWithAes(identityValue);

            const string sql = @"
                MERGE dbo.user_identities AS target
                USING (SELECT @userId AS user_id, @identityType AS identity_type) AS src
                   ON target.user_id = src.user_id AND target.identity_type = src.identity_type AND target.is_primary = 1
                WHEN MATCHED THEN
                    UPDATE SET identity_value = @identityValue
                WHEN NOT MATCHED THEN
                    INSERT (user_id, identity_type, identity_value, is_primary)
                    VALUES (@userId, @identityType, @identityValue, 1);";

            ExecuteNonQuery(sql,
                new SqlParameter("@userId", userId),
                new SqlParameter("@identityType", identityType),
                new SqlParameter("@identityValue", encrypted));
        }

        public void DeleteUserIdentity(Guid userId, string identityType)
        {
            const string sql = @"
                DELETE FROM dbo.user_identities
                WHERE user_id = @userId AND identity_type = @identityType AND is_primary = 1";

            ExecuteNonQuery(sql,
                new SqlParameter("@userId", userId),
                new SqlParameter("@identityType", identityType));
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

        public void UnlockUser(Guid userId)
        {
            const string sql = "UPDATE dbo.users SET failed_login_count = 0, updated_at = GETDATE() WHERE user_id = @userId";
            ExecuteNonQuery(sql, new SqlParameter("@userId", userId));
        }

        // ================================================================== //
        //  List users                                                         //
        // ================================================================== //

        public PagedResult<UserListItem> GetAllUsers(
    string role, string status, int? dsgId, int? zoneId, int? divisionId,
    int pageNumber, int pageSize, string search = null)
        {
            var where = new List<string>();
            var parms = new List<SqlParameter>();

            if (!string.IsNullOrWhiteSpace(role))
            {
                where.Add("u.system_role = @role");
                parms.Add(new SqlParameter("@role", role.ToUpper()));
            }
            else
            {
                where.Add("u.system_role IN ('CCA', 'EMPLOYEE')");
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                where.Add("u.user_status = @status");
                parms.Add(new SqlParameter("@status", status.ToUpper()));
            }

            if (dsgId.HasValue)
            {
                where.Add("u.dsg_id = @dsgId");
                parms.Add(new SqlParameter("@dsgId", dsgId.Value));
            }

            if (zoneId.HasValue)
            {
                where.Add("u.zone_id = @zoneId");
                parms.Add(new SqlParameter("@zoneId", zoneId.Value));
            }

            if (divisionId.HasValue)
            {
                where.Add("u.division_id = @divisionId");
                parms.Add(new SqlParameter("@divisionId", divisionId.Value));
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                where.Add("(u.login_id LIKE @search OR u.display_name LIKE @search)");
                parms.Add(new SqlParameter("@search", "%" + search.Trim() + "%"));
            }

            string whereClause = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";

            string sql = $@"
        SELECT COUNT(1)
        FROM dbo.users u
        {whereClause};

        SELECT u.user_id, u.login_id, u.display_name, u.system_role, u.user_status,
               u.dsg_id, u.state_id, u.zone_id, u.circle_id, u.division_id, u.sub_division_id,
               u.created_at,
               u.manager_id,
               ei.identity_value AS email_enc,
               pi.identity_value AS phone_enc,
               u.failed_login_count
        FROM   dbo.users u
        LEFT   JOIN dbo.user_identities ei ON ei.user_id = u.user_id
                                           AND ei.identity_type = 'EMAIL'
                                           AND ei.is_primary = 1
        LEFT   JOIN dbo.user_identities pi ON pi.user_id = u.user_id
                                           AND pi.identity_type = 'PHONE'
                                           AND pi.is_primary = 1
        {whereClause}
        ORDER  BY u.created_at DESC
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    ";

            var resp = new PagedResult<UserListItem>
            {
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(parms.ToArray());
                cmd.Parameters.Add("@offset", SqlDbType.Int).Value = (pageNumber - 1) * pageSize;
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize;

                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    // total count
                    if (r.Read())
                        resp.TotalCount = r.GetInt32(0);

                    r.NextResult();

                    while (r.Read())
                    {
                        string emailEnc = r.IsDBNull(13) ? null : r.GetString(13);
                        string phoneEnc = r.IsDBNull(14) ? null : r.GetString(14);
                        int failedLoginCount = r.IsDBNull(15) ? 0 : r.GetInt32(15);

                        resp.Items.Add(new UserListItem
                        {
                            UserId = r.GetGuid(0).ToString(),
                            LoginId = r.GetString(1),
                            DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                            SystemRole = r.GetString(3),
                            UserStatus = r.GetString(4),
                            DsgId = r.IsDBNull(5) ? (int?)null : r.GetInt32(5),
                            StateId = r.IsDBNull(6) ? (int?)null : r.GetInt32(6),
                            ZoneId = r.IsDBNull(7) ? (int?)null : r.GetInt32(7),
                            CircleId = r.IsDBNull(8) ? (int?)null : r.GetInt32(8),
                            DivisionId = r.IsDBNull(9) ? (int?)null : r.GetInt32(9),
                            SubDivisionId = r.IsDBNull(10) ? (int?)null : r.GetInt32(10),
                            CreatedAt = r.GetDateTime(11).ToString("o"),
                            ManagerId = r.IsDBNull(12) ? null : r.GetString(12),
                            Email = emailEnc == null ? null : _security.DecryptWithAes(emailEnc),
                            Phone = phoneEnc == null ? null : _security.DecryptWithAes(phoneEnc),
                            IsLocked = failedLoginCount >= AuthConstants.MaxFailedLoginAttempts,
                        });
                    }
                }
            }

            resp.TotalPages = (int)Math.Ceiling((double)resp.TotalCount / pageSize);

            return resp;
        }

        // ================================================================== //
        //  Get user detail                                                    //
        // ================================================================== //

        public UserDetailResponse GetUserById(Guid userId)
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name, u.system_role, u.user_status, u.created_at,
                       u.dsg_id, u.state_id, u.zone_id, u.circle_id, u.division_id, u.sub_division_id,
                       ei.identity_value AS email_enc,
                       pi.identity_value AS phone_enc,
                       u.manager_id,
                       u.failed_login_count
                FROM   dbo.users u
                LEFT   JOIN dbo.user_identities ei ON ei.user_id = u.user_id
                                                   AND ei.identity_type = 'EMAIL'
                                                   AND ei.is_primary = 1
                LEFT   JOIN dbo.user_identities pi ON pi.user_id = u.user_id
                                                   AND pi.identity_type = 'PHONE'
                                                   AND pi.is_primary = 1
                WHERE  u.user_id = @userId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;

                    string emailEnc = r.IsDBNull(12) ? null : r.GetString(12);
                    string phoneEnc = r.IsDBNull(13) ? null : r.GetString(13);

                    return new UserDetailResponse
                    {
                        UserId = r.GetGuid(0).ToString(),
                        LoginId = r.GetString(1),
                        DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                        SystemRole = r.GetString(3),
                        UserStatus = r.GetString(4),
                        CreatedAt = r.GetDateTime(5).ToString("o"),
                        DsgId = r.IsDBNull(6) ? (int?)null : r.GetInt32(6),
                        StateId = r.IsDBNull(7) ? (int?)null : r.GetInt32(7),
                        ZoneId = r.IsDBNull(8) ? (int?)null : r.GetInt32(8),
                        CircleId = r.IsDBNull(9) ? (int?)null : r.GetInt32(9),
                        DivisionId = r.IsDBNull(10) ? (int?)null : r.GetInt32(10),
                        SubDivisionId = r.IsDBNull(11) ? (int?)null : r.GetInt32(11),
                        Email = emailEnc == null ? null : _security.DecryptWithAes(emailEnc),
                        Phone = phoneEnc == null ? null : _security.DecryptWithAes(phoneEnc),
                        ManagerId = r.IsDBNull(14) ? null : r.GetString(14),
                        IsLocked = (r.IsDBNull(15) ? 0 : r.GetInt32(15)) >= AuthConstants.MaxFailedLoginAttempts,
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

        public PagedResult<AcrListItem> GetAllAcrs(int pageNumber, int pageSize, string Status, string Officer_name)
        {
            Status = string.IsNullOrWhiteSpace(Status) ? null : Status.Trim().ToUpper();
            string sql = @"
            SELECT COUNT(1)
            FROM dbo.acr_cycles ac 
            JOIN dbo.users u ON u.user_id = ac.officer_user_id " +
            "WHERE 1 = 1" +
            (Status != null ? " AND ac.status = @status " : "") +
            (Officer_name != null ? " AND LOWER(u.display_name) LIKE LOWER(@officerName) " : "") +
            @";

            SELECT ac.acr_id,
                    u.display_name,
                    u.login_id,
                    d.dsg,
                    ac.form_type,
                    ac.department,
                    ac.location,
                    ac.posting_from,
                    ac.posting_to,
                    ac.acr_year,
                    ac.status,
                    ac.created_at
            FROM dbo.acr_cycles ac
            JOIN dbo.users u ON u.user_id = ac.officer_user_id
            LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation " +
            "WHERE 1=1" +
            (Status != null ? " AND ac.status = @status " : "") +
            (Officer_name != null ? " AND LOWER(u.display_name) LIKE LOWER(@officerName) " : "") +
            @"
            ORDER BY ac.created_at DESC
            OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
            ";

            var resp = new PagedResult<AcrListItem>
            {
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@offset", SqlDbType.Int).Value = (pageNumber - 1) * pageSize;
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize;
                if (Status != null)
                    cmd.Parameters.Add("@status", SqlDbType.VarChar).Value = Status;
                if (Officer_name != null)
                    cmd.Parameters.Add("@officerName", SqlDbType.VarChar).Value = "%" + Officer_name.Trim() + "%";

                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                        resp.TotalCount = r.GetInt32(0);
                    r.NextResult();
                    while (r.Read())
                    {
                        resp.Items.Add(new AcrListItem
                        {
                            AcrId = r.GetGuid(0).ToString(),
                            OfficerName = r.IsDBNull(1) ? null : r.GetString(1),
                            OfficerLoginId = r.IsDBNull(2) ? null : r.GetString(2),
                            Dsg = r.IsDBNull(3) ? null : r.GetString(3),
                            FormType = r.IsDBNull(4) ? null : r.GetString(4),
                            Department = r.IsDBNull(5) ? null : r.GetString(5),
                            Location = r.IsDBNull(6) ? null : r.GetString(6),
                            PostingFrom = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                            PostingTo = r.IsDBNull(8) ? null : r.GetDateTime(8).ToString("yyyy-MM-dd"),
                            AcrYear = r.IsDBNull(9) ? 0 : r.GetInt32(9),
                            Status = r.IsDBNull(10) ? null : r.GetString(10),
                            CreatedAt = r.IsDBNull(11) ? null : r.GetDateTime(11).ToString("o")
                        });
                    }
                }
            }

            resp.TotalPages = (int)Math.Ceiling((double)resp.TotalCount / pageSize);
            return resp;
        }
    }
}