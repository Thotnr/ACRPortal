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
                    status, created_at, updated_at, submitted_at
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
                    @status, GETDATE(), GETDATE(),
                    CASE WHEN @status = 'DRAFT' THEN NULL ELSE GETDATE() END
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
                EnsureAcrSubmittedAtColumn(con);
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
                EnsureAutoAdvanceColumns(con);
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
                SET    status = 'PENDING_OFFICER', updated_at = GETDATE(), submitted_at = GETDATE()
                WHERE  acr_id = @acrId AND cca_user_id = @ccaUserId AND status = 'DRAFT';
                SELECT @@ROWCOUNT;";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@ccaUserId", SqlDbType.UniqueIdentifier).Value = ccaUserId;
                con.Open();
                EnsureAcrSubmittedAtColumn(con);
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
        //  GetAcrDetail — full shape, all sections                           //
        //                                                                    //
        //  Column index map:                                                 //
        //                                                                    //
        //  ACR header + officer (0-28)                                       //
        //   0  acr_id              8  department        16 date_joining_nigam//
        //   1  form_type           9  location          17 date_joining_rank //
        //   2  status             10  posting_from      18 date_joining_stn  //
        //   3  dsg (code)         11  posting_to        19 academic_qual     //
        //   4  officer user_id    12  acr_year          20 technical_qual    //
        //   5  officer login_id   13  date_of_birth     21 dept_exam         //
        //   6  officer name       14  property_rtn_dt   22 last_med_exam_dt  //
        //   7  designation snap   15  career_summary    23 reporting_uid     //
        //                                               24 ra2_uid           //
        //                                               25 reviewing_uid     //
        //                                               26 accepting_uid     //
        //                                               27 created_at        //
        //                                               28 updated_at        //
        //                                                                    //
        //  Self-appraisal (29-44)                                            //
        //  29 appraisal_id  36 major_achievements  43 medical_compliance     //
        //  30 submitted_at  37 membership_bodies   44 medical_comp_date      //
        //  31 leave_details 38 training_details                              //
        //  32 duties_desc   39 awards_honours                                //
        //  33 targets_set   40 auditor_compliance                            //
        //  34 targets_ach   41 property_declared                             //
        //  35 shortfall     42 property_decl_date                            //
        //                                                                    //
        //  RA assessment: id + RA1 (45-69)                                   //
        //  45 assessment_id  46 ra1_submitted  47-69 RA1 23 fields           //
        //                                                                    //
        //  RA2 block (70-93)                                                 //
        //  70 ra2_submitted  71-93 RA2 23 fields                             //
        //                                                                    //
        //  rva_* overrides (94-108)                                          //
        //                                                                    //
        //  reviewing_assessments (109-114)                                   //
        //  109 review_id  110 agree_with_ra  111 disagree_details            //
        //  112 remarks    113 final_grade    114 submitted_at                //
        //                                                                    //
        //  accepting_decisions (115-122)                                     //
        //  115 decision_id        119 final_grade                            //
        //  116 agree_with_prev    120 final_remarks                          //
        //  117 disagree_details   121 is_approved                            //
        //  118 conflict_resolved  122 decided_at                             //
        // ================================================================== //
        public CcaAcrDetailResponse GetAcrDetail(Guid acrId)
        {
            const string sql = @"
                SELECT
                    -- ACR header (0-28)
                    ac.acr_id,
                    ac.form_type,
                    ac.status,
                    d.dsg,
                    u.user_id,
                    u.login_id,
                    u.display_name,
                    ac.designation,
                    ac.department,
                    ac.location,
                    ac.posting_from,
                    ac.posting_to,
                    ac.acr_year,
                    ac.date_of_birth,
                    ac.property_return_date,
                    ac.career_posting_summary,
                    ac.date_joining_nigam,
                    ac.date_joining_present_rank,
                    ac.date_joining_present_station,
                    ac.academic_qualification,
                    ac.technical_qualification,
                    ac.departmental_exam_passed,
                    ac.last_medical_exam_date,
                    ac.reporting_user_id,
                    ac.ra2_user_id,
                    ac.reviewing_user_id,
                    ac.accepting_user_id,
                    ac.created_at,
                    ac.updated_at,

                    -- Self-appraisal (29-44)
                    sa.appraisal_id,
                    sa.submitted_at,
                    sa.leave_details,
                    sa.duties_description,
                    sa.targets_set,
                    sa.targets_achieved,
                    sa.shortfall_reasons,
                    sa.major_achievements,
                    sa.membership_bodies,
                    sa.training_details,
                    sa.awards_honours,
                    sa.auditor_compliance,
                    sa.property_declared,
                    sa.property_declared_date,
                    sa.medical_compliance,
                    sa.medical_compliance_date,

                    -- RA assessment: id + RA1 block (45-69)
                    ra.assessment_id,
                    ra.ra1_submitted_at,
                    ra.ra1_agree_with_self,
                    ra.ra1_disagree_details,
                    ra.ra1_integrity_comments,
                    ra.ra1_remarks,
                    ra.ra1_work_targets,
                    ra.ra1_work_quality,
                    ra.ra1_work_exceptional,
                    ra.ra1_work_overall,
                    ra.ra1_attr_attitude,
                    ra.ra1_attr_responsibility,
                    ra.ra1_attr_stability,
                    ra.ra1_attr_communication,
                    ra.ra1_attr_moral_courage,
                    ra.ra1_attr_leadership,
                    ra.ra1_attr_timeliness,
                    ra.ra1_attr_overall,
                    ra.ra1_comp_knowledge,
                    ra.ra1_comp_planning,
                    ra.ra1_comp_decision,
                    ra.ra1_comp_initiative,
                    ra.ra1_comp_teamwork,
                    ra.ra1_comp_overall,
                    ra.ra1_overall_grade,

                    -- RA2 block (70-93)
                    ra.ra2_submitted_at,
                    ra.ra2_agree_with_self,
                    ra.ra2_disagree_details,
                    ra.ra2_integrity_comments,
                    ra.ra2_remarks,
                    ra.ra2_work_targets,
                    ra.ra2_work_quality,
                    ra.ra2_work_exceptional,
                    ra.ra2_work_overall,
                    ra.ra2_attr_attitude,
                    ra.ra2_attr_responsibility,
                    ra.ra2_attr_stability,
                    ra.ra2_attr_communication,
                    ra.ra2_attr_moral_courage,
                    ra.ra2_attr_leadership,
                    ra.ra2_attr_timeliness,
                    ra.ra2_attr_overall,
                    ra.ra2_comp_knowledge,
                    ra.ra2_comp_planning,
                    ra.ra2_comp_decision,
                    ra.ra2_comp_initiative,
                    ra.ra2_comp_teamwork,
                    ra.ra2_comp_overall,
                    ra.ra2_overall_grade,

                    -- rva_* overrides (94-108)
                    ra.rva_work_targets,
                    ra.rva_work_quality,
                    ra.rva_work_exceptional,
                    ra.rva_attr_attitude,
                    ra.rva_attr_responsibility,
                    ra.rva_attr_stability,
                    ra.rva_attr_communication,
                    ra.rva_attr_moral_courage,
                    ra.rva_attr_leadership,
                    ra.rva_attr_timeliness,
                    ra.rva_comp_knowledge,
                    ra.rva_comp_planning,
                    ra.rva_comp_decision,
                    ra.rva_comp_initiative,
                    ra.rva_comp_teamwork,

                    -- reviewing_assessments (109-114)
                    rv.review_id,
                    rv.agree_with_ra,
                    rv.disagree_details,
                    rv.remarks,
                    rv.final_grade,
                    rv.submitted_at,

                    -- accepting_decisions (115-122)
                    ad.decision_id,
                    ad.agree_with_previous,
                    ad.disagree_details,
                    ad.conflict_resolved,
                    ad.final_grade,
                    ad.final_remarks,
                    ad.is_approved,
                    ad.decided_at,
                    
                    sa.is_skipped,
                    ra.is_skipped,
                    rv.is_skipped,

                    cca.user_id,
                    cca.login_id,
                    cca.display_name,
                    ra1u.login_id,
                    ra1u.display_name,
                    ra2u.login_id,
                    ra2u.display_name,
                    rvau.login_id,
                    rvau.display_name,
                    aau.login_id,
                    aau.display_name

                FROM dbo.acr_cycles ac
                JOIN dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.users cca ON cca.user_id = ac.cca_user_id
                LEFT JOIN dbo.users ra1u ON ra1u.user_id = ac.reporting_user_id
                LEFT JOIN dbo.users ra2u ON ra2u.user_id = ac.ra2_user_id
                LEFT JOIN dbo.users rvau ON rvau.user_id = ac.reviewing_user_id
                LEFT JOIN dbo.users aau ON aau.user_id = ac.accepting_user_id
                LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
                LEFT JOIN dbo.self_appraisals       sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
                LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
                LEFT JOIN dbo.accepting_decisions   ad ON ad.acr_id = ac.acr_id
                WHERE ac.acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                EnsureAutoAdvanceColumns(con);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;

                    bool isA1b = string.Equals(
                        r.IsDBNull(1) ? null : r.GetString(1),
                        "A1b", StringComparison.OrdinalIgnoreCase);

                    var resp = new CcaAcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = r.IsDBNull(2) ? null : r.GetString(2),
                        Dsg = r.IsDBNull(3) ? null : r.GetString(3),
                        OfficerUserId = r.GetGuid(4).ToString(),
                        OfficerLoginId = r.IsDBNull(5) ? null : r.GetString(5),
                        OfficerName = r.IsDBNull(6) ? null : r.GetString(6),
                        // col 7 = designation snapshot (raw text) — Dsg (col 3) is the short code
                        Department = r.IsDBNull(8) ? null : r.GetString(8),
                        Location = r.IsDBNull(9) ? null : r.GetString(9),
                        PostingFrom = r.IsDBNull(10) ? null : r.GetDateTime(10).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(11) ? null : r.GetDateTime(11).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(12) ? 0 : r.GetInt32(12),
                        DateOfBirth = r.IsDBNull(13) ? null : r.GetDateTime(13).ToString("yyyy-MM-dd"),
                        PropertyReturnDate = r.IsDBNull(14) ? null : r.GetDateTime(14).ToString("yyyy-MM-dd"),
                        CareerPostingSummary = r.IsDBNull(15) ? null : r.GetString(15),
                        DateJoiningNigam = r.IsDBNull(16) ? null : r.GetDateTime(16).ToString("yyyy-MM-dd"),
                        DateJoiningPresentRank = r.IsDBNull(17) ? null : r.GetDateTime(17).ToString("yyyy-MM-dd"),
                        DateJoiningPresentStation = r.IsDBNull(18) ? null : r.GetDateTime(18).ToString("yyyy-MM-dd"),
                        AcademicQualification = r.IsDBNull(19) ? null : r.GetString(19),
                        TechnicalQualification = r.IsDBNull(20) ? null : r.GetString(20),
                        DepartmentalExamPassed = r.IsDBNull(21) ? null : r.GetString(21),
                        LastMedicalExamDate = r.IsDBNull(22) ? null : r.GetDateTime(22).ToString("yyyy-MM-dd"),
                        ReportingAuthorityUserId = r.GetGuid(23).ToString(),
                        ReportingAuthority2UserId = r.IsDBNull(24) ? null : r.GetGuid(24).ToString(),
                        ReviewingAuthorityUserId = r.GetGuid(25).ToString(),
                        AcceptingAuthorityUserId = r.GetGuid(26).ToString(),
                        CreatedAt = r.IsDBNull(27) ? null : r.GetDateTime(27).ToString("o"),
                        UpdatedAt = r.IsDBNull(28) ? null : r.GetDateTime(28).ToString("o"),
                        CcaUserId = r.IsDBNull(126) ? null : r.GetGuid(126).ToString(),
                        CcaLoginId = r.IsDBNull(127) ? null : r.GetString(127),
                        CcaName = r.IsDBNull(128) ? null : r.GetString(128),
                        ReportingAuthorityLoginId = r.IsDBNull(129) ? null : r.GetString(129),
                        ReportingAuthorityName = r.IsDBNull(130) ? null : r.GetString(130),
                        ReportingAuthority2LoginId = r.IsDBNull(131) ? null : r.GetString(131),
                        ReportingAuthority2Name = r.IsDBNull(132) ? null : r.GetString(132),
                        ReviewingAuthorityLoginId = r.IsDBNull(133) ? null : r.GetString(133),
                        ReviewingAuthorityName = r.IsDBNull(134) ? null : r.GetString(134),
                        AcceptingAuthorityLoginId = r.IsDBNull(135) ? null : r.GetString(135),
                        AcceptingAuthorityName = r.IsDBNull(136) ? null : r.GetString(136),
                    };

                    // ── Self-appraisal (29-44) ──────────────────────────────
                    bool hasSelf = !r.IsDBNull(29);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? saSubmit = r.IsDBNull(30) ? (DateTime?)null : r.GetDateTime(30);
                        resp.SelfAppraisal.IsSkipped = r.IsDBNull(123) ? (bool?)false : r.GetBoolean(123);
                        resp.SelfAppraisal.IsSubmitted = saSubmit.HasValue;
                        resp.SelfAppraisal.SubmittedAt = saSubmit?.ToString("o");
                        resp.SelfAppraisal.LeaveDetails = r.IsDBNull(31) ? null : r.GetString(31);
                        resp.SelfAppraisal.DutiesDescription = r.IsDBNull(32) ? null : r.GetString(32);
                        resp.SelfAppraisal.TargetsSet = r.IsDBNull(33) ? null : r.GetString(33);
                        resp.SelfAppraisal.TargetsAchieved = r.IsDBNull(34) ? null : r.GetString(34);
                        resp.SelfAppraisal.ShortfallReasons = r.IsDBNull(35) ? null : r.GetString(35);
                        resp.SelfAppraisal.MajorAchievements = r.IsDBNull(36) ? null : r.GetString(36);
                        resp.SelfAppraisal.MembershipBodies = r.IsDBNull(37) ? null : r.GetString(37);
                        resp.SelfAppraisal.TrainingDetails = r.IsDBNull(38) ? null : r.GetString(38);
                        resp.SelfAppraisal.AwardsHonours = r.IsDBNull(39) ? null : r.GetString(39);
                        resp.SelfAppraisal.AuditorCompliance = r.IsDBNull(40) ? (bool?)null : r.GetBoolean(40);
                        resp.SelfAppraisal.PropertyDeclared = r.IsDBNull(41) ? null : r.GetString(41);
                        resp.SelfAppraisal.PropertyDeclaredDate = r.IsDBNull(42) ? null : r.GetDateTime(42).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.MedicalCompliance = r.IsDBNull(43) ? null : r.GetString(43);
                        resp.SelfAppraisal.MedicalComplianceDate = r.IsDBNull(44) ? null : r.GetDateTime(44).ToString("yyyy-MM-dd");
                    }

                    // ── RA1 assessment (45-69) ───────────────────────────────
                    bool hasRa = !r.IsDBNull(45);
                    resp.Ra1Assessment.Exists = hasRa;
                    if (hasRa)
                    {
                        DateTime? ra1Sub = r.IsDBNull(46) ? (DateTime?)null : r.GetDateTime(46);
                        resp.Ra1Assessment.IsSkipped = r.IsDBNull(124) ? (bool?)false : r.GetBoolean(124);
                        resp.Ra1Assessment.IsSubmitted = ra1Sub.HasValue;
                        resp.Ra1Assessment.SubmittedAt = ra1Sub?.ToString("o");
                        resp.Ra1Assessment.AgreeWithSelf = r.IsDBNull(47) ? (bool?)null : r.GetBoolean(47);
                        resp.Ra1Assessment.DisagreeDetails = r.IsDBNull(48) ? null : r.GetString(48);
                        resp.Ra1Assessment.IntegrityComments = r.IsDBNull(49) ? null : r.GetString(49);
                        resp.Ra1Assessment.Remarks = r.IsDBNull(50) ? null : r.GetString(50);
                        resp.Ra1Assessment.WorkTargets = r.IsDBNull(51) ? (byte?)null : r.GetByte(51);
                        resp.Ra1Assessment.WorkQuality = r.IsDBNull(52) ? (byte?)null : r.GetByte(52);
                        resp.Ra1Assessment.WorkExceptional = r.IsDBNull(53) ? (byte?)null : r.GetByte(53);
                        resp.Ra1Assessment.WorkOverall = r.IsDBNull(54) ? (decimal?)null : r.GetDecimal(54);
                        resp.Ra1Assessment.AttrAttitude = r.IsDBNull(55) ? (byte?)null : r.GetByte(55);
                        resp.Ra1Assessment.AttrResponsibility = r.IsDBNull(56) ? (byte?)null : r.GetByte(56);
                        resp.Ra1Assessment.AttrStability = r.IsDBNull(57) ? (byte?)null : r.GetByte(57);
                        resp.Ra1Assessment.AttrCommunication = r.IsDBNull(58) ? (byte?)null : r.GetByte(58);
                        resp.Ra1Assessment.AttrMoralCourage = r.IsDBNull(59) ? (byte?)null : r.GetByte(59);
                        resp.Ra1Assessment.AttrLeadership = r.IsDBNull(60) ? (byte?)null : r.GetByte(60);
                        resp.Ra1Assessment.AttrTimeliness = r.IsDBNull(61) ? (byte?)null : r.GetByte(61);
                        resp.Ra1Assessment.AttrOverall = r.IsDBNull(62) ? (decimal?)null : r.GetDecimal(62);
                        resp.Ra1Assessment.CompKnowledge = r.IsDBNull(63) ? (byte?)null : r.GetByte(63);
                        resp.Ra1Assessment.CompPlanning = r.IsDBNull(64) ? (byte?)null : r.GetByte(64);
                        resp.Ra1Assessment.CompDecision = r.IsDBNull(65) ? (byte?)null : r.GetByte(65);
                        resp.Ra1Assessment.CompInitiative = r.IsDBNull(66) ? (byte?)null : r.GetByte(66);
                        resp.Ra1Assessment.CompTeamwork = r.IsDBNull(67) ? (byte?)null : r.GetByte(67);
                        resp.Ra1Assessment.CompOverall = r.IsDBNull(68) ? (decimal?)null : r.GetDecimal(68);
                        resp.Ra1Assessment.OverallGrade = r.IsDBNull(69) ? (decimal?)null : r.GetDecimal(69);
                    }

                    // ── RA2 assessment (70-93) — A1b only ───────────────────
                    // col 71 = ra2_agree_with_self (presence proxy)
                    resp.Ra2Assessment.Exists = isA1b && hasRa && !r.IsDBNull(71);
                    if (resp.Ra2Assessment.Exists)
                    {
                        DateTime? ra2Sub = r.IsDBNull(70) ? (DateTime?)null : r.GetDateTime(70);
                        resp.Ra2Assessment.IsSkipped = r.IsDBNull(124) ? (bool?)false : r.GetBoolean(124);
                        resp.Ra2Assessment.IsSubmitted = ra2Sub.HasValue;
                        resp.Ra2Assessment.SubmittedAt = ra2Sub?.ToString("o");
                        resp.Ra2Assessment.AgreeWithSelf = r.IsDBNull(71) ? (bool?)null : r.GetBoolean(71);
                        resp.Ra2Assessment.DisagreeDetails = r.IsDBNull(72) ? null : r.GetString(72);
                        resp.Ra2Assessment.IntegrityComments = r.IsDBNull(73) ? null : r.GetString(73);
                        resp.Ra2Assessment.Remarks = r.IsDBNull(74) ? null : r.GetString(74);
                        resp.Ra2Assessment.WorkTargets = r.IsDBNull(75) ? (byte?)null : r.GetByte(75);
                        resp.Ra2Assessment.WorkQuality = r.IsDBNull(76) ? (byte?)null : r.GetByte(76);
                        resp.Ra2Assessment.WorkExceptional = r.IsDBNull(77) ? (byte?)null : r.GetByte(77);
                        resp.Ra2Assessment.WorkOverall = r.IsDBNull(78) ? (decimal?)null : r.GetDecimal(78);
                        resp.Ra2Assessment.AttrAttitude = r.IsDBNull(79) ? (byte?)null : r.GetByte(79);
                        resp.Ra2Assessment.AttrResponsibility = r.IsDBNull(80) ? (byte?)null : r.GetByte(80);
                        resp.Ra2Assessment.AttrStability = r.IsDBNull(81) ? (byte?)null : r.GetByte(81);
                        resp.Ra2Assessment.AttrCommunication = r.IsDBNull(82) ? (byte?)null : r.GetByte(82);
                        resp.Ra2Assessment.AttrMoralCourage = r.IsDBNull(83) ? (byte?)null : r.GetByte(83);
                        resp.Ra2Assessment.AttrLeadership = r.IsDBNull(84) ? (byte?)null : r.GetByte(84);
                        resp.Ra2Assessment.AttrTimeliness = r.IsDBNull(85) ? (byte?)null : r.GetByte(85);
                        resp.Ra2Assessment.AttrOverall = r.IsDBNull(86) ? (decimal?)null : r.GetDecimal(86);
                        resp.Ra2Assessment.CompKnowledge = r.IsDBNull(87) ? (byte?)null : r.GetByte(87);
                        resp.Ra2Assessment.CompPlanning = r.IsDBNull(88) ? (byte?)null : r.GetByte(88);
                        resp.Ra2Assessment.CompDecision = r.IsDBNull(89) ? (byte?)null : r.GetByte(89);
                        resp.Ra2Assessment.CompInitiative = r.IsDBNull(90) ? (byte?)null : r.GetByte(90);
                        resp.Ra2Assessment.CompTeamwork = r.IsDBNull(91) ? (byte?)null : r.GetByte(91);
                        resp.Ra2Assessment.CompOverall = r.IsDBNull(92) ? (decimal?)null : r.GetDecimal(92);
                        resp.Ra2Assessment.OverallGrade = r.IsDBNull(93) ? (decimal?)null : r.GetDecimal(93);
                    }

                    // ── rva_* override grades (94-108) ──────────────────────
                    resp.RvaOverrideGrades.WorkTargets = r.IsDBNull(94) ? (byte?)null : r.GetByte(94);
                    resp.RvaOverrideGrades.WorkQuality = r.IsDBNull(95) ? (byte?)null : r.GetByte(95);
                    resp.RvaOverrideGrades.WorkExceptional = r.IsDBNull(96) ? (byte?)null : r.GetByte(96);
                    resp.RvaOverrideGrades.AttrAttitude = r.IsDBNull(97) ? (byte?)null : r.GetByte(97);
                    resp.RvaOverrideGrades.AttrResponsibility = r.IsDBNull(98) ? (byte?)null : r.GetByte(98);
                    resp.RvaOverrideGrades.AttrStability = r.IsDBNull(99) ? (byte?)null : r.GetByte(99);
                    resp.RvaOverrideGrades.AttrCommunication = r.IsDBNull(100) ? (byte?)null : r.GetByte(100);
                    resp.RvaOverrideGrades.AttrMoralCourage = r.IsDBNull(101) ? (byte?)null : r.GetByte(101);
                    resp.RvaOverrideGrades.AttrLeadership = r.IsDBNull(102) ? (byte?)null : r.GetByte(102);
                    resp.RvaOverrideGrades.AttrTimeliness = r.IsDBNull(103) ? (byte?)null : r.GetByte(103);
                    resp.RvaOverrideGrades.CompKnowledge = r.IsDBNull(104) ? (byte?)null : r.GetByte(104);
                    resp.RvaOverrideGrades.CompPlanning = r.IsDBNull(105) ? (byte?)null : r.GetByte(105);
                    resp.RvaOverrideGrades.CompDecision = r.IsDBNull(106) ? (byte?)null : r.GetByte(106);
                    resp.RvaOverrideGrades.CompInitiative = r.IsDBNull(107) ? (byte?)null : r.GetByte(107);
                    resp.RvaOverrideGrades.CompTeamwork = r.IsDBNull(108) ? (byte?)null : r.GetByte(108);

                    // ── Reviewing assessment (109-114) ───────────────────────
                    bool hasRv = !r.IsDBNull(109);
                    resp.ReviewingAssessment.Exists = hasRv;
                    if (hasRv)
                    {
                        DateTime? rvSub = r.IsDBNull(114) ? (DateTime?)null : r.GetDateTime(114);
                        resp.ReviewingAssessment.IsSkipped = r.IsDBNull(125) ? (bool?)false : r.GetBoolean(125);
                        resp.ReviewingAssessment.IsSubmitted = rvSub.HasValue;
                        resp.ReviewingAssessment.SubmittedAt = rvSub?.ToString("o");
                        resp.ReviewingAssessment.AgreeWithRa = r.IsDBNull(110) ? (bool?)null : r.GetBoolean(110);
                        resp.ReviewingAssessment.DisagreeDetails = r.IsDBNull(111) ? null : r.GetString(111);
                        resp.ReviewingAssessment.Comments = r.IsDBNull(112) ? null : r.GetString(112);
                        resp.ReviewingAssessment.OverallGrade = r.IsDBNull(113) ? (decimal?)null : r.GetDecimal(113);
                    }

                    // ── Accepting decision (115-122) ─────────────────────────
                    bool hasAd = !r.IsDBNull(115);
                    resp.Decision.Exists = hasAd;
                    if (hasAd)
                    {
                        DateTime? decidedAt = r.IsDBNull(122) ? (DateTime?)null : r.GetDateTime(122);
                        resp.Decision.IsDecided = decidedAt.HasValue;
                        resp.Decision.DecidedAt = decidedAt?.ToString("o");
                        resp.Decision.AgreeWithPrevious = r.IsDBNull(116) ? (bool?)null : r.GetBoolean(116);
                        resp.Decision.DisagreeDetails = r.IsDBNull(117) ? null : r.GetString(117);
                        resp.Decision.ConflictResolved = !r.IsDBNull(118) && r.GetBoolean(118);
                        resp.Decision.FinalGrade = r.IsDBNull(119) ? (decimal?)null : r.GetDecimal(119);
                        resp.Decision.FinalRemarks = r.IsDBNull(120) ? null : r.GetString(120);
                        resp.Decision.IsApproved = r.IsDBNull(121) ? (bool?)null : r.GetBoolean(121);
                    }

                    return resp;
                }
            }
        }

        // ================================================================== //
        //  GetAcrList                                                         //
        // ================================================================== //

        public PagedResult<AcrListItem> GetCcaAcrs(
            Guid ccaUserId, 
            int pageNumber, 
            int pageSize, 
            string Status, 
            string Officer_name)
        {
            Status = string.IsNullOrWhiteSpace(Status) ? null : Status.Trim().ToUpper();
            var where = new List<string>();
            var parms = new List<SqlParameter>();

            where.Add("cca_user_id = @ccaUserId");
            parms.Add(new SqlParameter("@ccaUserId", ccaUserId));

            if (!string.IsNullOrWhiteSpace(Status))
            {
                where.Add("ac.status = @status");
                parms.Add(new SqlParameter("@status", Status.ToUpper()));
            }
            if (!string.IsNullOrWhiteSpace(Officer_name))
            {
                where.Add("LOWER(u.display_name) LIKE LOWER(@officerName)");
                parms.Add(new SqlParameter("@officerName", "%" + Officer_name.Trim() + "%"));
            }

            string whereClause = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";

            string sql = $@"
                SELECT COUNT(1)
                FROM dbo.acr_cycles ac
                JOIN dbo.users u ON u.user_id = ac.officer_user_id
                {whereClause};

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
                {whereClause}
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
                cmd.Parameters.AddRange(parms.ToArray());
                // cmd.Parameters.Add("@ccaUserId", SqlDbType.UniqueIdentifier).Value = ccaUserId;
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

        private static void EnsureAcrSubmittedAtColumn(SqlConnection con)
        {
            const string sql = @"
                IF COL_LENGTH('dbo.acr_cycles', 'submitted_at') IS NULL
                    EXEC('ALTER TABLE dbo.acr_cycles ADD [submitted_at] DATETIME NULL');

                EXEC('
                    UPDATE dbo.acr_cycles
                    SET    submitted_at = created_at
                    WHERE  submitted_at IS NULL
                      AND  status <> ''DRAFT''
                ');";

            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private static void EnsureAutoAdvanceColumns(SqlConnection con)
        {
            EnsureAcrSubmittedAtColumn(con);

            const string sql = @"
                IF COL_LENGTH('dbo.self_appraisals', 'is_skipped') IS NULL
                    EXEC('ALTER TABLE dbo.self_appraisals ADD [is_skipped] BIT NOT NULL CONSTRAINT DF_self_appraisals_is_skipped DEFAULT 0');

                IF COL_LENGTH('dbo.reporting_assessments', 'is_skipped') IS NULL
                    EXEC('ALTER TABLE dbo.reporting_assessments ADD [is_skipped] BIT NOT NULL CONSTRAINT DF_reporting_assessments_is_skipped DEFAULT 0');

                IF COL_LENGTH('dbo.reviewing_assessments', 'is_skipped') IS NULL
                    EXEC('ALTER TABLE dbo.reviewing_assessments ADD [is_skipped] BIT NOT NULL CONSTRAINT DF_reviewing_assessments_is_skipped DEFAULT 0');

                IF COL_LENGTH('dbo.accepting_decisions', 'is_skipped') IS NULL
                    EXEC('ALTER TABLE dbo.accepting_decisions ADD [is_skipped] BIT NOT NULL CONSTRAINT DF_accepting_decisions_is_skipped DEFAULT 0');";

            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.ExecuteNonQuery();
            }
        }
    }
}
