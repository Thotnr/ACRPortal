using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.Models;

namespace ACRPortal.Infrastructure.Adapter
{
    public class UserAdapter : IUserRepoPort
    {
        private readonly string _connStr = ConfigurationManager.ConnectionStrings["ACRPortalContext"].ConnectionString;

        // 1. Check if login ID already exists
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

        // 2. Create user + identities in one transaction
        public void CreateUser(string displayName, string loginId, string passwordHash, string hashedEmail, string hashedPhone)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        Guid userId = Guid.NewGuid();
                        string userSql = @"INSERT INTO users 
                                            (user_id, display_name, login_id, password_hash, user_status, created_at, updated_at) 
                                           VALUES 
                                            (@uid, @name, @login, @pwd, 'PENDING', GETDATE(), GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(userSql, conn, trans))
                        {
                            cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                            cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = (object)displayName ?? DBNull.Value;
                            cmd.Parameters.Add("@login", SqlDbType.VarChar).Value = loginId;
                            cmd.Parameters.Add("@pwd", SqlDbType.VarChar).Value = passwordHash;
                            cmd.ExecuteNonQuery();
                        }

                        if (hashedEmail != null) InsertIdentity(conn, trans, userId, "EMAIL", hashedEmail);
                        if (hashedPhone != null) InsertIdentity(conn, trans, userId, "PHONE", hashedPhone);

                        trans.Commit();
                    }
                    catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
                    {
                        // 2627 = UNIQUE KEY violation, 2601 = duplicate index violation
                        // Parse which field caused it from the constraint name in the message
                        trans.Rollback();

                        if (ex.Message.Contains("UQ_Identity") || ex.Message.Contains("user_identities"))
                        {
                            // Figure out which identity type was the duplicate
                            if (ex.Message.Contains("PHONE"))
                                throw new InvalidOperationException("This phone number is already registered with another account.");
                            if (ex.Message.Contains("EMAIL"))
                                throw new InvalidOperationException("This email address is already registered with another account.");

                            // Fallback if identity type isn't readable in the message
                            throw new InvalidOperationException("A contact detail you entered is already registered with another account.");
                        }

                        // Login ID duplicate (users table unique constraint)
                        throw new InvalidOperationException("This Login ID is already taken. Please choose a different one.");
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }

        // Helper — inserts one identity row
        private void InsertIdentity(SqlConnection conn, SqlTransaction trans, Guid userId, string type, string val)
        {
            string sql = @"INSERT INTO user_identities 
                            (identity_id, user_id, identity_type, identity_value, is_primary, is_verified, created_at, updated_at)
                           VALUES 
                            (NEWID(), @uid, @type, @val, 1, 0, GETDATE(), GETDATE())";

            using (SqlCommand cmd = new SqlCommand(sql, conn, trans))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                cmd.Parameters.Add("@type", SqlDbType.VarChar).Value = type;
                cmd.Parameters.Add("@val", SqlDbType.VarChar).Value = val;
                cmd.ExecuteNonQuery();
            }
        }

        // 3. Get user by login ID for authentication
        public User GetUserByLoginId(string loginId)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = @"SELECT user_id, login_id, password_hash, display_name, user_status, system_role 
                               FROM users WHERE login_id = @login";

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
                            IsActive = dr.GetString(4) == "ACTIVE",
                            SystemRole = dr.GetString(5)
                        };
                    }
                }
            }
        }

        // 4. Mark expired OTP entries for a login ID
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

        // 5. Count recent OTP attempts for rate limiting
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

        // 6. Save new OTP challenge
        public void SaveOtpChallenge(string identityHash, string otpHashed, string ip, string agent)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = @"INSERT INTO otp_challenges 
                                (otp_id, identity_type, identity_value, purpose, otp_hash, expires_at, ip_address, user_agent) 
                               VALUES 
                                (NEWID(), 'LOGIN', @val, 'LOGIN', @hash, DATEADD(MINUTE, 5, GETDATE()), @ip, @ua)";

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

        // 7. Get OTP for verification (expiry checked in SQL)
        public OtpChallenge GetOtp(string identityHash, string otpHashed, string ip, string agent)
        {
            using (SqlConnection conn = new SqlConnection(_connStr))
            {
                string sql = @"SELECT otp_id, expires_at FROM otp_challenges 
                               WHERE identity_value = @val 
                                 AND otp_hash = @hash 
                                 AND status = 'ISSUED' 
                                 AND expires_at > GETDATE()";

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
            ExecuteNonQuery(
                "UPDATE otp_challenges SET status = 'VERIFIED', verified_at = GETDATE() WHERE otp_id = @id",
                "@id", otpId);
        }

        // 8. Session management
        public Session CreateSession(Guid userId, string ip, string agent)
        {
            Guid sid = Guid.NewGuid();
            string sql = @"INSERT INTO sessions 
                            (session_id, user_id, session_token_hash, expires_at, ip_address, user_agent, status) 
                           VALUES 
                            (@sid, @uid, 'PENDING', DATEADD(HOUR, 2, GETDATE()), @ip, @ua, 'ACTIVE')";

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
            ExecuteNonQuery(
                "UPDATE sessions SET status = 'REVOKED', revoked_at = GETDATE() WHERE user_id = @uid AND status = 'ACTIVE'",
                "@uid", userId);
        }

        public void AttachSessionToken(Guid sessionId, string token)
        {
            ExecuteNonQuery(
                "UPDATE sessions SET session_token_hash = @tk WHERE session_id = @sid",
                "@tk", token, "@sid", sessionId);
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

        // Generic helper for simple non-query operations
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