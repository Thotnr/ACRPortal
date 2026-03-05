using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.Models; // Models ka namespace

namespace ACRPortal.Infrastructure.Adapter
{
    public class UserAdapter : IUserRepoPort
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["ACRPortalContext"].ConnectionString;

        public bool IsUserExists(string loginId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "SELECT COUNT(1) FROM dbo.users WHERE login_id = @loginId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@loginId", SqlDbType.VarChar).Value = loginId;
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        public void CreateUser(string displayName, string loginId, string passwordHash, string hashedEmail, string hashedPhone)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // User table entry (Schema alignment: user_status)
                        Guid userId = Guid.NewGuid();
                        string userSql = @"INSERT INTO users (user_id, display_name, login_id, password_hash, user_status, created_at, updated_at) 
                                         VALUES (@uid, @name, @login, @pwd, 'PENDING', GETDATE(), GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(userSql, conn, trans))
                        {
                            cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                            cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = (object)displayName ?? DBNull.Value;
                            cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                            cmd.Parameters.Add("@pwd", SqlDbType.VarChar).Value = passwordHash;
                            cmd.ExecuteNonQuery();
                        }

                        // Identity entries (Email/Phone)
                        if (hashedEmail != null) InsertIdentity(conn, trans, userId, "EMAIL", hashedEmail);
                        if (hashedPhone != null) InsertIdentity(conn, trans, userId, "PHONE", hashedPhone);

                        trans.Commit();
                    }
                    catch { trans.Rollback(); throw; }
                }
            }
        }

        private void InsertIdentity(SqlConnection conn, SqlTransaction trans, Guid userId, string type, string val)
        {
            string sql = @"INSERT INTO user_identities (identity_id, user_id, identity_type, identity_value, is_primary, is_verified, created_at, updated_at)
                           VALUES (NEWID(), @uid, @type, @val, 1, 0, GETDATE(), GETDATE())";
            using (SqlCommand cmd = new SqlCommand(sql, conn, trans))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                cmd.Parameters.Add("@type", SqlDbType.VarChar).Value = type;
                cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = val;
                cmd.ExecuteNonQuery();
            }
        }

        // 3. Get User for Authentication
        public User GetUserByLoginId(string loginId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "SELECT user_id, login_id, password_hash, display_name, user_status FROM users WHERE login_id = @login";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return null;
                        return new User
                        {
                            UserId = dr.GetGuid(0),
                            LoginId = dr.GetString(1),
                            PasswordHash = dr.GetString(2),
                            DisplayName = dr.IsDBNull(3) ? null : dr.GetString(3),
                            IsActive = dr.GetString(4) == "ACTIVE"
                        };
                    }
                }
            }
        }

        // 4. OTP Logic: Mark old OTPs as Expired/Used
        public void MarkExpiredOtpEntries(string loginId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "UPDATE otp_challenges SET status = 'EXPIRED' WHERE identity_value = @val AND expires_at < GETDATE() AND status = 'ISSUED'";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = loginId;
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // 5. Rate Limiting: Count recent attempts
        public int CountRecentOtpAttempts(string loginId, DateTime since)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "SELECT COUNT(1) FROM otp_challenges WHERE identity_value = @val AND created_at > @since";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = loginId;
                    cmd.Parameters.Add("@since", SqlDbType.DateTime).Value = since;
                    conn.Open();
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        // 6. Save New OTP Challenge
        public void SaveOtpChallenge(string identityHash, string otpHashed, string ip, string agent)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = @"INSERT INTO otp_challenges (otp_id, identity_type, identity_value, purpose, otp_hash, expires_at, ip_address, user_agent) 
                             VALUES (NEWID(), 'LOGIN', @val, 'LOGIN', @hash, DATEADD(MINUTE, 5, GETDATE()), @ip, @ua)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = identityHash;
                    cmd.Parameters.Add("@hash", SqlDbType.VarChar).Value = otpHashed;
                    cmd.Parameters.Add("@ip", SqlDbType.VarChar).Value = (object)ip ?? DBNull.Value;
                    cmd.Parameters.Add("@ua", SqlDbType.VarChar).Value = (object)agent ?? DBNull.Value;
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // 7. Get OTP for Verification
        public OtpChallenge GetOtp(string identityHash, string otpHashed, string ip, string agent)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "SELECT otp_id, expires_at FROM otp_challenges WHERE identity_value = @val AND otp_hash = @hash AND status = 'ISSUED' AND expires_at > GETDATE()";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = identityHash;
                    cmd.Parameters.Add("@hash", SqlDbType.VarChar).Value = otpHashed;
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return null;
                        return new OtpChallenge { OtpId = dr.GetGuid(0), ExpiresAt = dr.GetDateTime(1) };
                    }
                }
            }
        }

        public void MarkOtpAsVerified(Guid otpId)
        {
            ExecuteNonQuery("UPDATE otp_challenges SET status = 'VERIFIED', verified_at = GETDATE() WHERE otp_id = @id", "@id", otpId);
        }

        // 8. Session Management
        public Session CreateSession(Guid userId, string ip, string agent)
        {
            Guid sid = Guid.NewGuid();
            string sql = @"INSERT INTO sessions (session_id, user_id, session_token_hash, expires_at, ip_address, user_agent, status) 
                         VALUES (@sid, @uid, 'PENDING', DATEADD(HOUR, 2, GETDATE()), @ip, @ua, 'ACTIVE')";

            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@sid", SqlDbType.UniqueIdentifier).Value = sid;
                    cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                    cmd.Parameters.Add("@ip", SqlDbType.VarChar).Value = (object)ip ?? DBNull.Value;
                    cmd.Parameters.Add("@ua", SqlDbType.VarChar).Value = (object)agent ?? DBNull.Value;
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    return new Session { SessionId = sid, UserId = userId, IsActive = true };
                }
            }
        }

        public void DeactivateOldSessions(Guid userId, string ip, string agent)
        {
            ExecuteNonQuery("UPDATE sessions SET status = 'REVOKED', revoked_at = GETDATE() WHERE user_id = @uid AND status = 'ACTIVE'", "@uid", userId);
        }

        public void AttachSessionToken(Guid sessionId, string token)
        {
            ExecuteNonQuery("UPDATE sessions SET session_token_hash = @tk WHERE session_id = @sid", "@tk", token, "@sid", sessionId);
        }

        public UserIdentity GetUserIdentity(Guid userId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = "SELECT identity_id, identity_value FROM user_identities WHERE user_id = @uid AND is_primary = 1";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return null;
                        return new UserIdentity { IdentityId = dr.GetGuid(0), IdentityValueHash = dr.GetString(1) };
                    }
                }
            }
        }
        // Ye raha fix! Is helper method ko class ke niche daal do
        private void ExecuteNonQuery(string sql, string p1Name, object p1Val, string p2Name = null, object p2Val = null)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add(p1Name, p1Val is Guid ? SqlDbType.UniqueIdentifier : SqlDbType.VarChar).Value = p1Val;
                    if (p2Name != null)
                        cmd.Parameters.Add(p2Name, p2Val is Guid ? SqlDbType.UniqueIdentifier : SqlDbType.VarChar).Value = p2Val;

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }

}