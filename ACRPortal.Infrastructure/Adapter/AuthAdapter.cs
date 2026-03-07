using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.Models;

namespace ACRPortal.Infrastructure.Adapter
{
    public class AuthAdapter : IAuthRepoPort
    {
        private readonly string _connStr = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ------------------------------------------------------------------ //
        //  Login Step 1                                                        //
        // ------------------------------------------------------------------ //

        public User GetUserByLoginId(string loginId)
        {
            const string sql = @"
                SELECT user_id, login_id, password_hash, display_name,
                       user_status, system_role
                FROM   dbo.users
                WHERE  login_id = @login";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return null;
                    return MapUser(dr);
                }
            }
        }

        // identityHash = AES-encrypted loginId  (Bug fix #3)
        public void MarkExpiredOtpEntries(string identityHash)
        {
            const string sql = @"
                UPDATE dbo.otp_challenges
                SET    status = 'EXPIRED'
                WHERE  identity_value = @val
                  AND  status = 'ISSUED'
                  AND  expires_at < GETDATE()";

            ExecNonQuery(sql, "@val", SqlDbType.VarChar, identityHash);
        }

        public int CountRecentOtpAttempts(string identityHash, int withinSeconds)
        {
            // Entire window comparison done in SQL with GETDATE() — no C# DateTime involved.
            // This avoids UTC vs IST mismatch between C# (DateTime.UtcNow) and SQL (GETDATE()=local).
            const string sql = @"
                SELECT COUNT(1)
                FROM   dbo.otp_challenges
                WHERE  identity_value = @val
                  AND  created_at    > DATEADD(SECOND, -@seconds, GETDATE())";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = identityHash;
                cmd.Parameters.Add("@seconds", SqlDbType.Int).Value = withinSeconds;
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        public void SaveOtpChallenge(string identityHash, string otpHashed, string ip, string agent)
        {
            const string sql = @"
                INSERT INTO dbo.otp_challenges
                    (otp_id, identity_type, identity_value, purpose,
                     otp_hash, expires_at, ip_address, user_agent)
                VALUES
                    (NEWID(), 'LOGIN', @val, 'LOGIN',
                     @hash, DATEADD(MINUTE, 5, GETDATE()), @ip, @ua)";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = identityHash;
                cmd.Parameters.Add("@hash", SqlDbType.VarChar).Value = otpHashed;
                cmd.Parameters.Add("@ip", SqlDbType.VarChar).Value = (object)ip ?? DBNull.Value;
                cmd.Parameters.Add("@ua", SqlDbType.NVarChar).Value = (object)agent ?? DBNull.Value;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ------------------------------------------------------------------ //
        //  Login Step 2                                                        //
        // ------------------------------------------------------------------ //

        // ip/agent not used in query — kept out of signature (only identity + hash needed)
        public OtpChallenge GetOtp(string identityHash, string otpHashed)
        {
            const string sql = @"
                SELECT otp_id, expires_at
                FROM   dbo.otp_challenges
                WHERE  identity_value = @val
                  AND  otp_hash       = @hash
                  AND  status         = 'ISSUED'
                  AND  expires_at    > GETDATE()";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = identityHash;
                cmd.Parameters.Add("@hash", SqlDbType.VarChar).Value = otpHashed;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return null;
                    return new OtpChallenge
                    {
                        OtpId = dr.GetGuid(0),
                        ExpiresAt = dr.GetDateTime(1)
                    };
                }
            }
        }

        public void MarkOtpAsVerified(Guid otpId)
        {
            const string sql = @"
                UPDATE dbo.otp_challenges
                SET    status      = 'VERIFIED',
                       verified_at = GETDATE()
                WHERE  otp_id = @id";

            ExecNonQuery(sql, "@id", SqlDbType.UniqueIdentifier, otpId);
        }

        public Session CreateSession(Guid userId, string ip, string agent)
        {
            Guid sid = Guid.NewGuid();
            const string sql = @"
                INSERT INTO dbo.sessions
                    (session_id, user_id, session_token_hash,
                     expires_at, ip_address, user_agent, status)
                VALUES
                    (@sid, @uid, 'PENDING',
                     DATEADD(HOUR, 2, GETDATE()), @ip, @ua, 'ACTIVE')";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.UniqueIdentifier).Value = sid;
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                cmd.Parameters.Add("@ip", SqlDbType.VarChar).Value = (object)ip ?? DBNull.Value;
                cmd.Parameters.Add("@ua", SqlDbType.NVarChar).Value = (object)agent ?? DBNull.Value;
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            return new Session { SessionId = sid, UserId = userId };
        }

        public void DeactivateOldSessions(Guid userId)
        {
            const string sql = @"
                UPDATE dbo.sessions
                SET    status     = 'REVOKED',
                       revoked_at = GETDATE()
                WHERE  user_id = @uid
                  AND  status  = 'ACTIVE'";

            ExecNonQuery(sql, "@uid", SqlDbType.UniqueIdentifier, userId);
        }

        public void AttachSessionToken(Guid sessionId, string token, DateTime expiresAt)
        {
            // expiresAt is kept in the interface for the LoginResponse, but we recalculate
            // expiry in SQL using GETDATE() to avoid UTC vs local time mismatch.
            const string sql = @"
                UPDATE dbo.sessions
                SET    session_token_hash = @tk,
                       expires_at        = DATEADD(HOUR, 2, GETDATE())
                WHERE  session_id = @sid";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@tk", SqlDbType.VarChar).Value = token;
                cmd.Parameters.Add("@sid", SqlDbType.UniqueIdentifier).Value = sessionId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ------------------------------------------------------------------ //
        //  Logout                                                              //
        // ------------------------------------------------------------------ //

        public void RevokeSession(string plainSessionId)
        {
            const string sql = @"
                UPDATE dbo.sessions
                SET    status     = 'REVOKED',
                       revoked_at = GETDATE()
                WHERE  session_id = @sid";

            if (!Guid.TryParse(plainSessionId, out Guid sid)) return;
            ExecNonQuery(sql, "@sid", SqlDbType.UniqueIdentifier, sid);
        }

        public bool IsSessionActive(string plainSessionId)
        {
            if (!Guid.TryParse(plainSessionId, out Guid sid)) return false;

            const string sql = @"
                SELECT COUNT(1)
                FROM   dbo.sessions
                WHERE  session_id = @sid
                  AND  status     = 'ACTIVE'
                  AND  expires_at > GETDATE()";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.UniqueIdentifier).Value = sid;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        // ------------------------------------------------------------------ //
        //  Me                                                                  //
        // ------------------------------------------------------------------ //

        public User GetUserById(Guid userId)
        {
            const string sql = @"
                SELECT user_id, login_id, password_hash, display_name,
                       user_status, system_role
                FROM   dbo.users
                WHERE  user_id = @uid";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return null;
                    return MapUser(dr);
                }
            }
        }

        // ------------------------------------------------------------------ //
        //  Change Password                                                     //
        // ------------------------------------------------------------------ //

        public void UpdatePassword(Guid userId, string newPasswordHash)
        {
            const string sql = @"
                UPDATE dbo.users
                SET    password_hash = @pwd,
                       updated_at   = GETDATE()
                WHERE  user_id = @uid";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@pwd", SqlDbType.VarChar).Value = newPasswordHash;
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ------------------------------------------------------------------ //
        //  Forgot Password                                                     //
        // ------------------------------------------------------------------ //

        public void SaveResetToken(string loginId, string resetTokenHash)
        {
            // Expiry is 30 minutes from now, computed in SQL so timezone is consistent with
            // the GETDATE() comparison in GetUserByResetToken.
            const string sql = @"
                UPDATE dbo.users
                SET    reset_token        = @token,
                       reset_token_expiry = DATEADD(MINUTE, 30, GETDATE()),
                       updated_at        = GETDATE()
                WHERE  login_id = @login";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@token", SqlDbType.VarChar).Value = resetTokenHash;
                cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ------------------------------------------------------------------ //
        //  Reset Password                                                      //
        // ------------------------------------------------------------------ //

        public User GetUserByResetToken(string loginId, string resetTokenHash)
        {
            const string sql = @"
                SELECT user_id, login_id, password_hash, display_name,
                       user_status, system_role
                FROM   dbo.users
                WHERE  login_id           = @login
                  AND  reset_token        = @token
                  AND  reset_token_expiry > GETDATE()";

            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                cmd.Parameters.Add("@token", SqlDbType.VarChar).Value = resetTokenHash;
                conn.Open();
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return null;
                    return MapUser(dr);
                }
            }
        }

        public void ClearResetToken(Guid userId)
        {
            const string sql = @"
                UPDATE dbo.users
                SET    reset_token        = NULL,
                       reset_token_expiry = NULL,
                       updated_at        = GETDATE()
                WHERE  user_id = @uid";

            ExecNonQuery(sql, "@uid", SqlDbType.UniqueIdentifier, userId);
        }

        // ------------------------------------------------------------------ //
        //  Helpers                                                             //
        // ------------------------------------------------------------------ //

        private User MapUser(SqlDataReader dr) => new User
        {
            UserId = dr.GetGuid(0),
            LoginId = dr.GetString(1),
            PasswordHash = dr.GetString(2),
            DisplayName = dr.IsDBNull(3) ? null : dr.GetString(3),
            UserStatus = dr.GetString(4),
            SystemRole = dr.GetString(5)
        };

        // Single-param non-query helper (.NET 4.5 compatible — no ValueTuple)
        private void ExecNonQuery(string sql, string p1Name, SqlDbType p1Type, object p1Val)
        {
            using (var conn = new SqlConnection(_connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add(p1Name, p1Type).Value = p1Val ?? DBNull.Value;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}