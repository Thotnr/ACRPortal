using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class CcaAdapter : ICcaRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  GetOfficers                                                        //
        // ================================================================== //
        public List<CcaOfficerListItem> GetOfficers()
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name,
                       u.dsg_id, d.dsg, d.dsgDesc, d.form_type
                FROM   dbo.users u
                LEFT JOIN dbo.tbDsg d ON d.dsgId = u.dsg_id
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
                            DsgCode = r.IsDBNull(4) ? null : r.GetString(4),
                            DsgDesc = r.IsDBNull(5) ? null : r.GetString(5),
                            FormType = r.IsDBNull(6) ? null : r.GetString(6)
                        });
            }
            return list;
        }

        // ================================================================== //
        //  GetEmployeesForDropdown                                            //
        // ================================================================== //
        public List<CcaEmployeeDropdownItem> GetEmployeesForDropdown()
        {
            const string sql = @"
                SELECT u.user_id, u.login_id, u.display_name,
                       u.dsg_id, d.dsgDesc
                FROM   dbo.users u
                LEFT JOIN dbo.tbDsg d ON d.dsgId = u.dsg_id
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

        // ================================================================== //
        //  GetAuthoritySuggestions                                             //
        // ================================================================== //
        public CcaAuthoritySuggestionResponse GetAuthoritySuggestions(Guid officerUserId, out string errorCode)
        {
            const string sql = @"
                SELECT
                    o.user_id         AS officer_user_id,
                    o.system_role     AS officer_role,
                    o.user_status     AS officer_status,
                    o.manager_id      AS officer_manager_login,
                    ra.user_id        AS reporting_user_id,
                    ra.system_role    AS reporting_role,
                    ra.user_status    AS reporting_status,
                    ra.manager_id     AS reporting_manager_login,
                    rva.user_id       AS reviewing_user_id,
                    rva.system_role   AS reviewing_role,
                    rva.user_status   AS reviewing_status
                FROM dbo.users o
                LEFT JOIN dbo.users ra  ON ra.login_id  = o.manager_id
                LEFT JOIN dbo.users rva ON rva.login_id = ra.manager_id
                WHERE o.user_id = @officerId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@officerId", SqlDbType.UniqueIdentifier).Value = officerUserId;
                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        errorCode = "NOT_FOUND";
                        return null;
                    }

                    string officerRole = r.IsDBNull(1) ? null : r.GetString(1);
                    string officerStatus = r.IsDBNull(2) ? null : r.GetString(2);
                    if (!string.Equals(officerRole, "EMPLOYEE", StringComparison.OrdinalIgnoreCase)
                        || !string.Equals(officerStatus, "ACTIVE", StringComparison.OrdinalIgnoreCase))
                    {
                        errorCode = "INVALID_OFFICER";
                        return null;
                    }

                    if (r.IsDBNull(4))
                    {
                        errorCode = "MISSING_RA";
                        return null;
                    }

                    string reportingRole = r.IsDBNull(5) ? null : r.GetString(5);
                    string reportingStatus = r.IsDBNull(6) ? null : r.GetString(6);
                    if (!string.Equals(reportingRole, "EMPLOYEE", StringComparison.OrdinalIgnoreCase)
                        || !string.Equals(reportingStatus, "ACTIVE", StringComparison.OrdinalIgnoreCase))
                    {
                        errorCode = "INVALID_RA";
                        return null;
                    }

                    if (r.IsDBNull(8))
                    {
                        errorCode = "MISSING_RVA";
                        return null;
                    }

                    string reviewingRole = r.IsDBNull(9) ? null : r.GetString(9);
                    string reviewingStatus = r.IsDBNull(10) ? null : r.GetString(10);
                    if (!string.Equals(reviewingRole, "EMPLOYEE", StringComparison.OrdinalIgnoreCase)
                        || !string.Equals(reviewingStatus, "ACTIVE", StringComparison.OrdinalIgnoreCase))
                    {
                        errorCode = "INVALID_RVA";
                        return null;
                    }

                    errorCode = null;
                    return new CcaAuthoritySuggestionResponse
                    {
                        OfficerUserId = officerUserId.ToString(),
                        ReportingUserId = r.GetGuid(4).ToString(),
                        ReviewingUserId = r.GetGuid(8).ToString()
                    };
                }
            }
        }

        // ================================================================== //
        //  IsUserActive                                                       //
        // ================================================================== //
        public bool IsUserActive(Guid userId)
        {
            const string sql = "SELECT COUNT(1) FROM dbo.users WHERE user_id = @uid AND user_status = 'ACTIVE'";
            return ExistsCheck(sql, new SqlParameter("@uid", SqlDbType.UniqueIdentifier) { Value = userId });
        }

        // ================================================================== //
        //  Duplicate checks                                                   //
        // ================================================================== //
        public bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.acr_cycles
                WHERE officer_user_id = @uid AND posting_from = @from";
            return ExistsCheck(sql,
                new SqlParameter("@uid", SqlDbType.UniqueIdentifier) { Value = officerUserId },
                // new SqlParameter("@dept", SqlDbType.NVarChar) { Value = department },
                new SqlParameter("@from", SqlDbType.Date) { Value = postingFrom.Date });
        }

        public bool IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom)
        {
            const string sql = @"
                SELECT COUNT(1) FROM dbo.acr_cycles
                WHERE officer_user_id = @uid AND posting_from = @from AND acr_id <> @acrId";
            return ExistsCheck(sql,
                new SqlParameter("@uid", SqlDbType.UniqueIdentifier) { Value = officerUserId },
                // new SqlParameter("@dept", SqlDbType.NVarChar) { Value = department },
                new SqlParameter("@from", SqlDbType.Date) { Value = postingFrom.Date },
                new SqlParameter("@acrId", SqlDbType.UniqueIdentifier) { Value = acrId });
        }

        // ================================================================== //
        //  GetDesignationById                                                 //
        // ================================================================== //
        public DesignationLookupItem GetDesignationById(int dsgId)
        {
            const string sql = "SELECT dsgDesc, form_type FROM dbo.tbDsg WHERE dsgId = @id AND dsgIsActive = 1";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = dsgId;
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

        // ================================================================== //
        //  CreateAcr                                                          //
        // ================================================================== //
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
            DateTime? dateJoiningNigam,
            DateTime? dateJoiningPresentRank,
            DateTime? dateJoiningPresentStation,
            string academicQualification,
            string technicalQualification,
            string departmentalExamPassed,
            DateTime? propertyReturnDate,
            DateTime? lastMedicalExamDate,
            string careerPostingSummary,
            string status)
        {
            const string sql = @"
                INSERT INTO dbo.acr_cycles (
                    officer_user_id, reporting_user_id, ra2_user_id,
                    reviewing_user_id, accepting_user_id, cca_user_id,
                    department, location, designation,
                    posting_from, posting_to, acr_year,
                    form_type, date_of_birth,
                    date_joining_nigam, date_joining_present_rank, date_joining_present_station,
                    academic_qualification, technical_qualification, departmental_exam_passed,
                    property_return_date, last_medical_exam_date,
                    career_posting_summary,
                    status, created_at, updated_at
                )
                OUTPUT INSERTED.acr_id
                VALUES (
                    @officerId, @ra1Id, @ra2Id,
                    @rvaId, @aaId, @ccaId,
                    @dept, @loc, @designation,
                    @from, @to, @year,
                    @formType, @dob,
                    @djNigam, @djRank, @djStation,
                    @academicQual, @technicalQual, @deptExam,
                    @propReturnDate, @lastMedDate,
                    @summary,
                    @status, GETDATE(), GETDATE()
                )";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                AddAcrParams(cmd, officerUserId, reportingUserId, reportingUserId2,
                    reviewingUserId, acceptingUserId, ccaUserId,
                    department, location, designation, postingFrom, postingTo, acrYear,
                    formType, dateOfBirth,
                    dateJoiningNigam, dateJoiningPresentRank, dateJoiningPresentStation,
                    academicQualification, technicalQualification, departmentalExamPassed,
                    propertyReturnDate, lastMedicalExamDate, careerPostingSummary);

                cmd.Parameters.Add("@status", SqlDbType.VarChar).Value = status;
                con.Open();
                return cmd.ExecuteScalar().ToString();
            }
        }

        // ================================================================== //
        //  TryUpdateDraftAcr                                                  //
        // ================================================================== //
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
            DateTime? dateJoiningNigam,
            DateTime? dateJoiningPresentRank,
            DateTime? dateJoiningPresentStation,
            string academicQualification,
            string technicalQualification,
            string departmentalExamPassed,
            DateTime? propertyReturnDate,
            DateTime? lastMedicalExamDate,
            string careerPostingSummary,
            out string errorCode)
        {
            const string sql = @"
                UPDATE dbo.acr_cycles
                SET    officer_user_id               = @officerId,
                       reporting_user_id             = @ra1Id,
                       ra2_user_id                   = @ra2Id,
                       reviewing_user_id             = @rvaId,
                       accepting_user_id             = @aaId,
                       department                    = @dept,
                       location                      = @loc,
                       designation                   = @designation,
                       posting_from                  = @from,
                       posting_to                    = @to,
                       acr_year                      = @year,
                       form_type                     = @formType,
                       date_of_birth                 = @dob,
                       date_joining_nigam            = @djNigam,
                       date_joining_present_rank     = @djRank,
                       date_joining_present_station  = @djStation,
                       academic_qualification        = @academicQual,
                       technical_qualification       = @technicalQual,
                       departmental_exam_passed      = @deptExam,
                       property_return_date          = @propReturnDate,
                       last_medical_exam_date        = @lastMedDate,
                       career_posting_summary        = @summary,
                       updated_at                    = GETDATE()
                WHERE  acr_id      = @acrId
                  AND  cca_user_id = @ccaUserId
                  AND  status      = 'DRAFT';
                SELECT @@ROWCOUNT;";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@ccaUserId", SqlDbType.UniqueIdentifier).Value = ccaUserId;

                AddAcrParams(cmd, officerUserId, reportingUserId, reportingUserId2,
                    reviewingUserId, acceptingUserId, ccaUserId,
                    department, location, designation, postingFrom, postingTo, acrYear,
                    formType, dateOfBirth,
                    dateJoiningNigam, dateJoiningPresentRank, dateJoiningPresentStation,
                    academicQualification, technicalQualification, departmentalExamPassed,
                    propertyReturnDate, lastMedicalExamDate, careerPostingSummary);

                con.Open();
                if (Convert.ToInt32(cmd.ExecuteScalar()) > 0) { errorCode = null; return true; }
            }

            const string checkSql = "SELECT cca_user_id, status FROM dbo.acr_cycles WHERE acr_id = @acrId";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }
                    Guid owner = r.GetGuid(0);
                    string st = r.IsDBNull(1) ? null : r.GetString(1);
                    if (owner != ccaUserId) { errorCode = "FORBIDDEN"; return false; }
                    errorCode = st == "DRAFT" ? "INTERNAL_ERROR" : "INVALID_STATE";
                    return false;
                }
            }
        }

        // ================================================================== //
        //  TrySubmitDraftAcr                                                  //
        // ================================================================== //
        public bool TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode)
        {
            const string sql = @"
                UPDATE dbo.acr_cycles
                SET    status = 'PENDING_OFFICER', updated_at = GETDATE()
                WHERE  acr_id = @acrId AND cca_user_id = @ccaUserId AND status = 'DRAFT';
                SELECT @@ROWCOUNT;";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@ccaUserId", SqlDbType.UniqueIdentifier).Value = ccaUserId;
                con.Open();
                if (Convert.ToInt32(cmd.ExecuteScalar()) > 0) { errorCode = null; return true; }
            }

            const string checkSql = "SELECT cca_user_id, status FROM dbo.acr_cycles WHERE acr_id = @acrId";
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }
                    Guid owner = r.GetGuid(0);
                    string st = r.IsDBNull(1) ? null : r.GetString(1);
                    if (owner != ccaUserId) { errorCode = "FORBIDDEN"; return false; }
                    errorCode = st == "DRAFT" ? "INTERNAL_ERROR" : "INVALID_STATE";
                    return false;
                }
            }
        }

        // ================================================================== //
        //  GetAcrDetail                                                       //
        // ================================================================== //
        public CcaAcrDetailResponse GetAcrDetail(Guid acrId)
        {
            // Single table read + one JOIN for the officer's display info.
            // Authority fields are the raw UUID columns on acr_cycles � no user JOINs needed.
            const string sql = @"
                SELECT
                    ac.acr_id,                        -- 0
                    ac.form_type,                     -- 1
                    ac.status,                        -- 2

                    u.user_id,                        -- 3   officer
                    u.login_id,                       -- 4
                    u.display_name,                   -- 5
                    d.dsg,                            -- 6
                    ac.designation,                   -- 7   snapshot

                    ac.department,                    -- 8
                    ac.location,                      -- 9
                    ac.posting_from,                  -- 10
                    ac.posting_to,                    -- 11
                    ac.acr_year,                      -- 12

                    ac.date_of_birth,                 -- 13

                    ac.date_joining_nigam,            -- 14
                    ac.date_joining_present_rank,     -- 15
                    ac.date_joining_present_station,  -- 16

                    ac.academic_qualification,        -- 17
                    ac.technical_qualification,       -- 18
                    ac.departmental_exam_passed,      -- 19

                    ac.property_return_date,          -- 20
                    ac.last_medical_exam_date,        -- 21

                    ac.career_posting_summary,        -- 22

                    ac.reporting_user_id,             -- 23   RA1 UserId
                    ac.ra2_user_id,                   -- 24   RA2 UserId (NULL for A1a/A2)
                    ac.reviewing_user_id,             -- 25   RvA UserId
                    ac.accepting_user_id,             -- 26   AA  UserId

                    ac.created_at,                    -- 27
                    ac.updated_at                     -- 28

                FROM dbo.acr_cycles ac
                JOIN dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
                WHERE ac.acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;

                    return new CcaAcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = r.IsDBNull(2) ? null : r.GetString(2),

                        OfficerUserId = r.GetGuid(3).ToString(),
                        OfficerLoginId = r.IsDBNull(4) ? null : r.GetString(4),
                        OfficerName = r.IsDBNull(5) ? null : r.GetString(5),
                        Dsg = r.IsDBNull(6) ? null : r.GetString(6),
                        // DsgDesc = r.IsDBNull(7) ? null : r.GetString(7),

                        Department = r.IsDBNull(8) ? null : r.GetString(8),
                        Location = r.IsDBNull(9) ? null : r.GetString(9),
                        PostingFrom = r.IsDBNull(10) ? null : r.GetDateTime(10).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(11) ? null : r.GetDateTime(11).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(12) ? 0 : r.GetInt32(12),

                        DateOfBirth = r.IsDBNull(13) ? null : r.GetDateTime(13).ToString("yyyy-MM-dd"),

                        DateJoiningNigam = r.IsDBNull(14) ? null : r.GetDateTime(14).ToString("yyyy-MM-dd"),
                        DateJoiningPresentRank = r.IsDBNull(15) ? null : r.GetDateTime(15).ToString("yyyy-MM-dd"),
                        DateJoiningPresentStation = r.IsDBNull(16) ? null : r.GetDateTime(16).ToString("yyyy-MM-dd"),

                        AcademicQualification = r.IsDBNull(17) ? null : r.GetString(17),
                        TechnicalQualification = r.IsDBNull(18) ? null : r.GetString(18),
                        DepartmentalExamPassed = r.IsDBNull(19) ? null : r.GetString(19),

                        PropertyReturnDate = r.IsDBNull(20) ? null : r.GetDateTime(20).ToString("yyyy-MM-dd"),
                        LastMedicalExamDate = r.IsDBNull(21) ? null : r.GetDateTime(21).ToString("yyyy-MM-dd"),

                        CareerPostingSummary = r.IsDBNull(22) ? null : r.GetString(22),

                        ReportingAuthorityUserId = r.GetGuid(23).ToString(),
                        ReportingAuthority2UserId = r.IsDBNull(24) ? null : r.GetGuid(24).ToString(),
                        ReviewingAuthorityUserId = r.GetGuid(25).ToString(),
                        AcceptingAuthorityUserId = r.GetGuid(26).ToString(),

                        CreatedAt = r.IsDBNull(27) ? null : r.GetDateTime(27).ToString("o"),
                        UpdatedAt = r.IsDBNull(28) ? null : r.GetDateTime(28).ToString("o")
                    };
                }
            }
        }

        // ================================================================== //
        //  GetAcrList                                                         //
        // ================================================================== //

        public PagedResult<AcrListItem> GetCcaAcrs(Guid ccaUserId, int pageNumber, int pageSize)
        {
            string sql = @"
        SELECT COUNT(1)
        FROM dbo.acr_cycles
        WHERE cca_user_id = @ccaUserId;

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
        LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
        WHERE ac.cca_user_id = @ccaUserId
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
                cmd.Parameters.Add("@ccaUserId", SqlDbType.UniqueIdentifier).Value = ccaUserId;
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

        // ================================================================== //
        //  Private helpers                                                    //
        // ================================================================== //

        private static void AddAcrParams(
            SqlCommand cmd,
            Guid officerUserId,
            Guid reportingUserId,
            Guid? reportingUserId2,
            Guid reviewingUserId,
            Guid acceptingUserId,
            Guid ccaUserId,
            string department,
            string location,
            string designation,
            DateTime postingFrom,
            DateTime postingTo,
            int acrYear,
            string formType,
            DateTime dateOfBirth,
            DateTime? dateJoiningNigam,
            DateTime? dateJoiningPresentRank,
            DateTime? dateJoiningPresentStation,
            string academicQualification,
            string technicalQualification,
            string departmentalExamPassed,
            DateTime? propertyReturnDate,
            DateTime? lastMedicalExamDate,
            string careerPostingSummary)
        {
            cmd.Parameters.Add("@officerId", SqlDbType.UniqueIdentifier).Value = officerUserId;
            cmd.Parameters.Add("@ra1Id", SqlDbType.UniqueIdentifier).Value = reportingUserId;
            cmd.Parameters.Add("@ra2Id", SqlDbType.UniqueIdentifier).Value =
                reportingUserId2.HasValue ? (object)reportingUserId2.Value : DBNull.Value;
            cmd.Parameters.Add("@rvaId", SqlDbType.UniqueIdentifier).Value = reviewingUserId;
            cmd.Parameters.Add("@aaId", SqlDbType.UniqueIdentifier).Value = acceptingUserId;
            cmd.Parameters.Add("@ccaId", SqlDbType.UniqueIdentifier).Value = ccaUserId;

            cmd.Parameters.Add("@dept", SqlDbType.NVarChar).Value = department;
            cmd.Parameters.Add("@loc", SqlDbType.NVarChar).Value = location;
            cmd.Parameters.Add("@designation", SqlDbType.NVarChar).Value = (object)designation ?? DBNull.Value;
            cmd.Parameters.Add("@from", SqlDbType.Date).Value = postingFrom.Date;
            cmd.Parameters.Add("@to", SqlDbType.Date).Value = postingTo.Date;
            cmd.Parameters.Add("@year", SqlDbType.Int).Value = acrYear;
            cmd.Parameters.Add("@formType", SqlDbType.VarChar).Value = (object)formType ?? DBNull.Value;
            cmd.Parameters.Add("@dob", SqlDbType.Date).Value = dateOfBirth.Date;

            cmd.Parameters.Add("@djNigam", SqlDbType.Date).Value =
                dateJoiningNigam.HasValue ? (object)dateJoiningNigam.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@djRank", SqlDbType.Date).Value =
                dateJoiningPresentRank.HasValue ? (object)dateJoiningPresentRank.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@djStation", SqlDbType.Date).Value =
                dateJoiningPresentStation.HasValue ? (object)dateJoiningPresentStation.Value.Date : DBNull.Value;

            cmd.Parameters.Add("@academicQual", SqlDbType.NVarChar).Value =
                string.IsNullOrWhiteSpace(academicQualification) ? (object)DBNull.Value : academicQualification.Trim();
            cmd.Parameters.Add("@technicalQual", SqlDbType.NVarChar).Value =
                string.IsNullOrWhiteSpace(technicalQualification) ? (object)DBNull.Value : technicalQualification.Trim();
            cmd.Parameters.Add("@deptExam", SqlDbType.NVarChar).Value =
                string.IsNullOrWhiteSpace(departmentalExamPassed) ? (object)DBNull.Value : departmentalExamPassed.Trim();

            cmd.Parameters.Add("@propReturnDate", SqlDbType.Date).Value =
                propertyReturnDate.HasValue ? (object)propertyReturnDate.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@lastMedDate", SqlDbType.Date).Value =
                lastMedicalExamDate.HasValue ? (object)lastMedicalExamDate.Value.Date : DBNull.Value;

            cmd.Parameters.Add("@summary", SqlDbType.NVarChar).Value =
                string.IsNullOrWhiteSpace(careerPostingSummary) ? (object)DBNull.Value : careerPostingSummary.Trim();
        }

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
    }
}