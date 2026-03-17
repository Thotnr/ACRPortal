using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class CcaAdapter : ICcaRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        public List<CcaOfficerListItem> GetOfficers()
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name,
                       d.dsgId, d.dsgDesc, d.form_type
                FROM   dbo.users u
                LEFT JOIN dbo.tbDsg d ON u.dsg_id = d.dsgId
                WHERE  u.system_role = 'EMPLOYEE'
                  AND  u.user_status = 'ACTIVE'
                ORDER BY u.display_name";

            var list = new List<CcaOfficerListItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new CcaOfficerListItem
                        {
                            UserId = r.GetGuid(0).ToString(),
                            LoginId = r.IsDBNull(1) ? null : r.GetString(1),
                            DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                            DsgId = r.IsDBNull(3) ? (int?)null : r.GetInt32(3),
                            DsgDesc = r.IsDBNull(4) ? null : r.GetString(4),
                            FormType = r.IsDBNull(5) ? null : r.GetString(5)
                        });
            }
            return list;
        }

        public List<CcaEmployeeDropdownItem> GetEmployeesForDropdown()
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name,
                       d.dsgId, d.dsgDesc
                FROM   dbo.users u
                LEFT JOIN dbo.tbDsg d ON u.dsg_id = d.dsgId
                WHERE  u.system_role = 'EMPLOYEE'
                  AND  u.user_status = 'ACTIVE'
                ORDER BY u.display_name";

            var list = new List<CcaEmployeeDropdownItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new CcaEmployeeDropdownItem
                        {
                            UserId = r.GetGuid(0).ToString(),
                            LoginId = r.IsDBNull(1) ? null : r.GetString(1),
                            DisplayName = r.IsDBNull(2) ? null : r.GetString(2),
                            DsgId = r.IsDBNull(3) ? (int?)null : r.GetInt32(3),
                            DsgDesc = r.IsDBNull(4) ? null : r.GetString(4)
                        });
            }
            return list;
        }

        public bool IsUserActive(Guid userId)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.users
                WHERE  user_id = @userId AND user_status = 'ACTIVE'";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                con.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        public bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.acr_cycles
                WHERE  officer_user_id = @officerId
                  AND  department      = @dept
                  AND  posting_from    = @from";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@officerId", officerUserId);
                cmd.Parameters.AddWithValue("@dept", department);
                cmd.Parameters.AddWithValue("@from", postingFrom.Date);
                con.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        public bool IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.acr_cycles
                WHERE  acr_id          <> @acrId
                  AND  officer_user_id  = @officerId
                  AND  department       = @dept
                  AND  posting_from     = @from";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@acrId", acrId);
                cmd.Parameters.AddWithValue("@officerId", officerUserId);
                cmd.Parameters.AddWithValue("@dept", department);
                cmd.Parameters.AddWithValue("@from", postingFrom.Date);
                con.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        public DesignationLookupItem GetDesignationById(int dsgId)
        {
            const string sql = @"
                SELECT dsgDesc, form_type
                FROM   dbo.tbDsg
                WHERE  dsgId = @dsgId AND dsgIsActive = 1";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@dsgId", dsgId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;
                    return new DesignationLookupItem
                    {
                        DsgDesc = r.IsDBNull(0) ? null : r.GetString(0),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1)
                    };
                }
            }
        }

        public string CreateAcr(
            Guid officerUserId,
            Guid reportingUserId,
            Guid? reportingUserId2,
            Guid reviewingUserId,
            Guid acceptingUserId,
            Guid ccaUserId,
            string department,
            string location,
            DateTime postingFrom,
            DateTime postingTo,
            int acrYear,
            string designation,
            string formType,
            DateTime dateOfBirth,
            string academicQualification,
            string technicalQualification,
            string careerPostingSummary,
            bool propertyReturnDone,
            string status)
        {
            const string insertSql = @"
                INSERT INTO dbo.acr_cycles (
                    officer_user_id, reporting_user_id, ra2_user_id,
                    reviewing_user_id, accepting_user_id, cca_user_id,
                    department, location, designation, posting_from, posting_to, acr_year,
                    form_type, date_of_birth, qualification,
                    career_posting_summary, property_return_done,
                    status, created_at, updated_at
                )
                OUTPUT INSERTED.acr_id
                VALUES (
                    @officerId, @ra1Id, @ra2Id,
                    @rvaId, @aaId, @ccaId,
                    @dept, @loc, @designation, @from, @to, @year,
                    @formType, @dob, @qual,
                    @summary, @propReturn,
                    @status, GETDATE(), GETDATE()
                )";

            using (var con = new SqlConnection(_conn))
            {
                con.Open();

                string combinedQual = string.Join(" | ",
                    new[] { academicQualification, technicalQualification }
                        .Where(q => !string.IsNullOrWhiteSpace(q)));

                using (var cmd = new SqlCommand(insertSql, con))
                {
                    cmd.Parameters.AddWithValue("@officerId", officerUserId);
                    cmd.Parameters.AddWithValue("@ra1Id", reportingUserId);
                    cmd.Parameters.AddWithValue("@ra2Id", (object)reportingUserId2 ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@rvaId", reviewingUserId);
                    cmd.Parameters.AddWithValue("@aaId", acceptingUserId);
                    cmd.Parameters.AddWithValue("@ccaId", ccaUserId);
                    cmd.Parameters.AddWithValue("@dept", department);
                    cmd.Parameters.AddWithValue("@loc", location);
                    cmd.Parameters.AddWithValue("@designation", designation);
                    cmd.Parameters.AddWithValue("@from", postingFrom.Date);
                    cmd.Parameters.AddWithValue("@to", postingTo.Date);
                    cmd.Parameters.AddWithValue("@year", acrYear);
                    cmd.Parameters.AddWithValue("@formType", formType);
                    cmd.Parameters.AddWithValue("@dob", dateOfBirth.Date);
                    cmd.Parameters.AddWithValue("@qual", string.IsNullOrWhiteSpace(combinedQual) ? (object)DBNull.Value : combinedQual);
                    cmd.Parameters.AddWithValue("@summary", string.IsNullOrWhiteSpace(careerPostingSummary) ? (object)DBNull.Value : careerPostingSummary);
                    cmd.Parameters.AddWithValue("@propReturn", propertyReturnDone ? 1 : 0);
                    cmd.Parameters.AddWithValue("@status", status);

                    var newId = cmd.ExecuteScalar();
                    return newId.ToString();
                }
            }
        }

        public bool TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode)
        {
            const string sql = @"
                UPDATE dbo.acr_cycles
                SET    status = 'PENDING_OFFICER',
                       updated_at = GETDATE()
                WHERE  acr_id = @acrId
                  AND  cca_user_id = @ccaUserId
                  AND  status = 'DRAFT';

                SELECT @@ROWCOUNT;";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@acrId", acrId);
                cmd.Parameters.AddWithValue("@ccaUserId", ccaUserId);
                con.Open();

                int affected = Convert.ToInt32(cmd.ExecuteScalar());
                if (affected > 0)
                {
                    errorCode = null;
                    return true;
                }
            }

            // Distinguish failure reasons (not found vs wrong owner vs wrong state)
            const string checkSql = @"
                SELECT cca_user_id, status
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.AddWithValue("@acrId", acrId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        errorCode = "NOT_FOUND";
                        return false;
                    }

                    Guid owner = r.GetGuid(0);
                    string status = r.IsDBNull(1) ? null : r.GetString(1);

                    if (owner != ccaUserId)
                    {
                        errorCode = "FORBIDDEN";
                        return false;
                    }

                    errorCode = status == "DRAFT" ? "INTERNAL_ERROR" : "INVALID_STATE";
                    return false;
                }
            }
        }

        public bool TryUpdateDraftAcr(
            Guid acrId,
            Guid ccaUserId,
            Guid officerUserId,
            Guid reportingUserId,
            Guid? reportingUserId2,
            Guid reviewingUserId,
            Guid acceptingUserId,
            string department,
            string location,
            DateTime postingFrom,
            DateTime postingTo,
            int acrYear,
            string designation,
            string formType,
            DateTime dateOfBirth,
            string academicQualification,
            string technicalQualification,
            string careerPostingSummary,
            bool propertyReturnDone,
            out string errorCode)
        {
            const string updateSql = @"
                UPDATE dbo.acr_cycles
                SET    officer_user_id        = @officerId,
                       reporting_user_id      = @ra1Id,
                       ra2_user_id            = @ra2Id,
                       reviewing_user_id      = @rvaId,
                       accepting_user_id      = @aaId,
                       department             = @dept,
                       location               = @loc,
                       designation            = @designation,
                       posting_from           = @from,
                       posting_to             = @to,
                       acr_year               = @year,
                       form_type              = @formType,
                       date_of_birth          = @dob,
                       qualification          = @qual,
                       career_posting_summary = @summary,
                       property_return_done   = @propReturn,
                       updated_at             = GETDATE()
                WHERE  acr_id = @acrId
                  AND  cca_user_id = @ccaUserId
                  AND  status = 'DRAFT';

                SELECT @@ROWCOUNT;";

            string combinedQual = string.Join(" | ",
                new[] { academicQualification, technicalQualification }
                    .Where(q => !string.IsNullOrWhiteSpace(q)));

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(updateSql, con))
            {
                cmd.Parameters.AddWithValue("@acrId", acrId);
                cmd.Parameters.AddWithValue("@ccaUserId", ccaUserId);
                cmd.Parameters.AddWithValue("@officerId", officerUserId);
                cmd.Parameters.AddWithValue("@ra1Id", reportingUserId);
                cmd.Parameters.AddWithValue("@ra2Id", (object)reportingUserId2 ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@rvaId", reviewingUserId);
                cmd.Parameters.AddWithValue("@aaId", acceptingUserId);
                cmd.Parameters.AddWithValue("@dept", department);
                cmd.Parameters.AddWithValue("@loc", location);
                cmd.Parameters.AddWithValue("@designation", designation);
                cmd.Parameters.AddWithValue("@from", postingFrom.Date);
                cmd.Parameters.AddWithValue("@to", postingTo.Date);
                cmd.Parameters.AddWithValue("@year", acrYear);
                cmd.Parameters.AddWithValue("@formType", formType);
                cmd.Parameters.AddWithValue("@dob", dateOfBirth.Date);
                cmd.Parameters.AddWithValue("@qual", string.IsNullOrWhiteSpace(combinedQual) ? (object)DBNull.Value : combinedQual);
                cmd.Parameters.AddWithValue("@summary", string.IsNullOrWhiteSpace(careerPostingSummary) ? (object)DBNull.Value : careerPostingSummary);
                cmd.Parameters.AddWithValue("@propReturn", propertyReturnDone ? 1 : 0);

                con.Open();
                int affected = Convert.ToInt32(cmd.ExecuteScalar());
                if (affected > 0)
                {
                    errorCode = null;
                    return true;
                }
            }

            // Not updated: determine why
            const string checkSql = @"
                SELECT cca_user_id, status
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.AddWithValue("@acrId", acrId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        errorCode = "NOT_FOUND";
                        return false;
                    }

                    Guid owner = r.GetGuid(0);
                    string status = r.IsDBNull(1) ? null : r.GetString(1);

                    if (owner != ccaUserId)
                    {
                        errorCode = "FORBIDDEN";
                        return false;
                    }

                    errorCode = status == "DRAFT" ? "INTERNAL_ERROR" : "INVALID_STATE";
                    return false;
                }
            }
        }

        public List<AcrListItem> GetAcrList()
        {
            const string sql = @"
                SELECT  ac.acr_id,
                        u.display_name,
                        u.login_id,
                        d.dsgDesc,
                        ac.form_type,
                        ac.department,
                        ac.location,
                        ac.posting_from,
                        ac.posting_to,
                        ac.acr_year,
                        ac.status,
                        ac.created_at
                FROM    dbo.acr_cycles ac
                JOIN    dbo.users u  ON ac.officer_user_id = u.user_id
                LEFT JOIN dbo.tbDsg d ON u.dsg_id = d.dsgId
                ORDER BY ac.created_at DESC";

            var list = new List<AcrListItem>();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        list.Add(new AcrListItem
                        {
                            AcrId = r.GetGuid(0).ToString(),
                            OfficerName = r.IsDBNull(1) ? null : r.GetString(1),
                            OfficerLoginId = r.IsDBNull(2) ? null : r.GetString(2),
                            DsgDesc = r.IsDBNull(3) ? null : r.GetString(3),
                            FormType = r.IsDBNull(4) ? null : r.GetString(4),
                            Department = r.IsDBNull(5) ? null : r.GetString(5),
                            Location = r.IsDBNull(6) ? null : r.GetString(6),
                            PostingFrom = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                            PostingTo = r.IsDBNull(8) ? null : r.GetDateTime(8).ToString("yyyy-MM-dd"),
                            AcrYear = r.IsDBNull(9) ? 0 : r.GetInt32(9),
                            Status = r.IsDBNull(10) ? null : r.GetString(10),
                            CreatedAt = r.IsDBNull(11) ? null : r.GetDateTime(11).ToString("yyyy-MM-ddTHH:mm:ss")
                        });
            }
            return list;
        }
    }
}