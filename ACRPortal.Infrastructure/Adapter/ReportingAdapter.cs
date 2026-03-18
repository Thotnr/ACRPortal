using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class ReportingAdapter : IReportingRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  GetMyReportingQueue                                                //
        // ================================================================== //
        public MyReportingQueueResponse GetMyReportingQueue(Guid userId)
        {
            const string sql = @"
                SELECT  ac.acr_id,
                        u.display_name,
                        u.login_id,
                        ac.form_type,
                        ac.department,
                        ac.location,
                        ac.posting_from,
                        ac.posting_to,
                        ac.acr_year,
                        ac.status,
                        ac.created_at,
                        ac.reporting_user_id,
                        ac.ra2_user_id,
                        ra.ra1_submitted_at,
                        ra.ra2_submitted_at
                FROM    dbo.acr_cycles ac
                JOIN    dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
                WHERE  (ac.reporting_user_id = @uid OR ac.ra2_user_id = @uid)
                  AND   ac.status IN ('PENDING_REPORTING', 'PENDING_REPORTING2')
                ORDER BY ac.created_at DESC";

            var resp = new MyReportingQueueResponse();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string status = r.IsDBNull(9) ? null : r.GetString(9);
                        Guid ra1Id = r.GetGuid(11);
                        Guid? ra2Id = r.IsDBNull(12) ? (Guid?)null : r.GetGuid(12);
                        bool isRa2 = ra2Id.HasValue && userId == ra2Id.Value;

                        DateTime? ra1Sub = r.IsDBNull(13) ? (DateTime?)null : r.GetDateTime(13);
                        DateTime? ra2Sub = r.IsDBNull(14) ? (DateTime?)null : r.GetDateTime(14);
                        bool submitted = isRa2 ? ra2Sub.HasValue : ra1Sub.HasValue;

                        resp.AcrCycles.Add(new MyReportingQueueItem
                        {
                            AcrId = r.GetGuid(0).ToString(),
                            OfficerName = r.IsDBNull(1) ? null : r.GetString(1),
                            OfficerLoginId = r.IsDBNull(2) ? null : r.GetString(2),
                            FormType = r.IsDBNull(3) ? null : r.GetString(3),
                            Department = r.IsDBNull(4) ? null : r.GetString(4),
                            Location = r.IsDBNull(5) ? null : r.GetString(5),
                            PostingFrom = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                            PostingTo = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                            AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8),
                            Status = status,
                            ReportingRole = isRa2 ? "RA2" : "RA1",
                            IsSubmitted = submitted,
                            CreatedAt = r.IsDBNull(10) ? null : r.GetDateTime(10).ToString("o")
                        });
                    }
                }
            }
            return resp;
        }

        // ================================================================== //
        //  GetReportingDetail                                                 //
        // ================================================================== //
        public ReportingAcrDetailResponse GetReportingDetail(Guid acrId, Guid userId, out string errorCode)
        {
            // Self-appraisal column index map (relative to query):
            //  14  sa.appraisal_id
            //  15  sa.submitted_at
            //  16  sa.leave_details          ← new (Migration 7)
            //  17  sa.duties_description
            //  18  sa.targets_set
            //  19  sa.targets_achieved
            //  20  sa.shortfall_reasons
            //  21  sa.major_achievements
            //  22  sa.membership_bodies
            //  23  sa.training_details
            //  24  sa.awards_honours
            //  25  sa.auditor_compliance     ← BIT now
            //  26  sa.property_declared
            //  27  sa.property_declared_date ← new (Migration 7)
            //  28  sa.medical_compliance
            //  29  sa.medical_compliance_date← new (Migration 7)
            //  30  sa.document_path
            //
            // Reporting assessment block starts at 31 (was 29 before Migration 7)
            //  31  ra.assessment_id
            //  32  ra.ra1_submitted_at
            //  33  ra.ra2_submitted_at
            //  34  ra1_agree_with_self  → baseIdx = 34 (RA1 block)
            //  57  ra2_agree_with_self  → baseIdx = 57+3 = 60 (RA2 block)

            const string sql = @"
                SELECT  ac.acr_id,
                        ac.form_type,
                        ac.status,
                        ac.department,
                        ac.location,
                        ac.designation,
                        ac.posting_from,
                        ac.posting_to,
                        ac.acr_year,
                        ac.officer_user_id,
                        u.login_id,
                        u.display_name,
                        ac.reporting_user_id,
                        ac.ra2_user_id,

                        -- Self-appraisal (14–30)
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
                        sa.document_path,

                        -- Reporting assessment (31–)
                        ra.assessment_id,
                        ra.ra1_submitted_at,
                        ra.ra2_submitted_at,
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
                        ra.ra2_overall_grade

                FROM dbo.acr_cycles ac
                JOIN dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.self_appraisals        sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.reporting_assessments  ra ON ra.acr_id = ac.acr_id
                WHERE ac.acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return null; }

                    string status = r.IsDBNull(2) ? null : r.GetString(2);
                    Guid ra1 = r.GetGuid(12);
                    Guid? ra2 = r.IsDBNull(13) ? (Guid?)null : r.GetGuid(13);

                    bool isRa1Active = string.Equals(status, "PENDING_REPORTING", StringComparison.OrdinalIgnoreCase);
                    bool isRa2Active = string.Equals(status, "PENDING_REPORTING2", StringComparison.OrdinalIgnoreCase);

                    if (isRa1Active)
                    {
                        if (userId != ra1) { errorCode = "FORBIDDEN"; return null; }
                    }
                    else if (isRa2Active)
                    {
                        if (!ra2.HasValue || userId != ra2.Value) { errorCode = "FORBIDDEN"; return null; }
                    }
                    else { errorCode = "INVALID_STATE"; return null; }

                    var resp = new ReportingAcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = status,
                        Department = r.IsDBNull(3) ? null : r.GetString(3),
                        Location = r.IsDBNull(4) ? null : r.GetString(4),
                        Designation = r.IsDBNull(5) ? null : r.GetString(5),
                        PostingFrom = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8),
                        ReportingRole = isRa2Active ? "RA2" : "RA1"
                    };

                    resp.Officer.UserId = r.GetGuid(9).ToString();
                    resp.Officer.LoginId = r.IsDBNull(10) ? null : r.GetString(10);
                    resp.Officer.DisplayName = r.IsDBNull(11) ? null : r.GetString(11);

                    // ── Self-appraisal (14–30) ──────────────────────────────
                    bool hasSelf = !r.IsDBNull(14);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? saSubmitted = r.IsDBNull(15) ? (DateTime?)null : r.GetDateTime(15);
                        resp.SelfAppraisal.IsSubmitted = saSubmitted.HasValue;
                        resp.SelfAppraisal.SubmittedAt = saSubmitted?.ToString("o");
                        resp.SelfAppraisal.LeaveDetails = r.IsDBNull(16) ? null : r.GetString(16);
                        resp.SelfAppraisal.DutiesDescription = r.IsDBNull(17) ? null : r.GetString(17);
                        resp.SelfAppraisal.TargetsSet = r.IsDBNull(18) ? null : r.GetString(18);
                        resp.SelfAppraisal.TargetsAchieved = r.IsDBNull(19) ? null : r.GetString(19);
                        resp.SelfAppraisal.ShortfallReasons = r.IsDBNull(20) ? null : r.GetString(20);
                        resp.SelfAppraisal.MajorAchievements = r.IsDBNull(21) ? null : r.GetString(21);
                        resp.SelfAppraisal.MembershipBodies = r.IsDBNull(22) ? null : r.GetString(22);
                        resp.SelfAppraisal.TrainingDetails = r.IsDBNull(23) ? null : r.GetString(23);
                        resp.SelfAppraisal.AwardsHonours = r.IsDBNull(24) ? null : r.GetString(24);
                        resp.SelfAppraisal.AuditorCompliance = r.IsDBNull(25) ? (bool?)null : r.GetBoolean(25);
                        resp.SelfAppraisal.PropertyDeclared = !r.IsDBNull(26) && r.GetBoolean(26);
                        resp.SelfAppraisal.PropertyDeclaredDate = r.IsDBNull(27) ? null : r.GetDateTime(27).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.MedicalCompliance = !r.IsDBNull(28) && r.GetBoolean(28);
                        resp.SelfAppraisal.MedicalComplianceDate = r.IsDBNull(29) ? null : r.GetDateTime(29).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.DocumentPath = r.IsDBNull(30) ? null : r.GetString(30);
                    }

                    // ── Reporting assessment (31–) ──────────────────────────
                    bool hasRa = !r.IsDBNull(31);
                    resp.ReportingAssessment.Exists = hasRa;

                    if (hasRa)
                    {
                        DateTime? ra1Submitted = r.IsDBNull(32) ? (DateTime?)null : r.GetDateTime(32);
                        DateTime? ra2Submitted = r.IsDBNull(33) ? (DateTime?)null : r.GetDateTime(33);

                        if (isRa2Active)
                        {
                            resp.ReportingAssessment.IsSubmitted = ra2Submitted.HasValue;
                            resp.ReportingAssessment.SubmittedAt = ra2Submitted?.ToString("o");

                            const int baseIdx = 60;   // ra2_agree_with_self (was 57, +3 for new sa cols)
                            resp.ReportingAssessment.AgreeWithSelf = r.IsDBNull(baseIdx + 0) ? (bool?)null : r.GetBoolean(baseIdx + 0);
                            resp.ReportingAssessment.DisagreeDetails = r.IsDBNull(baseIdx + 1) ? null : r.GetString(baseIdx + 1);
                            resp.ReportingAssessment.IntegrityComments = r.IsDBNull(baseIdx + 2) ? null : r.GetString(baseIdx + 2);
                            resp.ReportingAssessment.Remarks = r.IsDBNull(baseIdx + 3) ? null : r.GetString(baseIdx + 3);
                            resp.ReportingAssessment.WorkTargets = r.IsDBNull(baseIdx + 4) ? (byte?)null : r.GetByte(baseIdx + 4);
                            resp.ReportingAssessment.WorkQuality = r.IsDBNull(baseIdx + 5) ? (byte?)null : r.GetByte(baseIdx + 5);
                            resp.ReportingAssessment.WorkExceptional = r.IsDBNull(baseIdx + 6) ? (byte?)null : r.GetByte(baseIdx + 6);
                            resp.ReportingAssessment.WorkOverall = r.IsDBNull(baseIdx + 7) ? (decimal?)null : r.GetDecimal(baseIdx + 7);
                            resp.ReportingAssessment.AttrAttitude = r.IsDBNull(baseIdx + 8) ? (byte?)null : r.GetByte(baseIdx + 8);
                            resp.ReportingAssessment.AttrResponsibility = r.IsDBNull(baseIdx + 9) ? (byte?)null : r.GetByte(baseIdx + 9);
                            resp.ReportingAssessment.AttrStability = r.IsDBNull(baseIdx + 10) ? (byte?)null : r.GetByte(baseIdx + 10);
                            resp.ReportingAssessment.AttrCommunication = r.IsDBNull(baseIdx + 11) ? (byte?)null : r.GetByte(baseIdx + 11);
                            resp.ReportingAssessment.AttrMoralCourage = r.IsDBNull(baseIdx + 12) ? (byte?)null : r.GetByte(baseIdx + 12);
                            resp.ReportingAssessment.AttrLeadership = r.IsDBNull(baseIdx + 13) ? (byte?)null : r.GetByte(baseIdx + 13);
                            resp.ReportingAssessment.AttrTimeliness = r.IsDBNull(baseIdx + 14) ? (byte?)null : r.GetByte(baseIdx + 14);
                            resp.ReportingAssessment.AttrOverall = r.IsDBNull(baseIdx + 15) ? (decimal?)null : r.GetDecimal(baseIdx + 15);
                            resp.ReportingAssessment.CompKnowledge = r.IsDBNull(baseIdx + 16) ? (byte?)null : r.GetByte(baseIdx + 16);
                            resp.ReportingAssessment.CompPlanning = r.IsDBNull(baseIdx + 17) ? (byte?)null : r.GetByte(baseIdx + 17);
                            resp.ReportingAssessment.CompDecision = r.IsDBNull(baseIdx + 18) ? (byte?)null : r.GetByte(baseIdx + 18);
                            resp.ReportingAssessment.CompInitiative = r.IsDBNull(baseIdx + 19) ? (byte?)null : r.GetByte(baseIdx + 19);
                            resp.ReportingAssessment.CompTeamwork = r.IsDBNull(baseIdx + 20) ? (byte?)null : r.GetByte(baseIdx + 20);
                            resp.ReportingAssessment.CompOverall = r.IsDBNull(baseIdx + 21) ? (decimal?)null : r.GetDecimal(baseIdx + 21);
                            resp.ReportingAssessment.OverallGrade = r.IsDBNull(baseIdx + 22) ? (decimal?)null : r.GetDecimal(baseIdx + 22);
                        }
                        else
                        {
                            resp.ReportingAssessment.IsSubmitted = ra1Submitted.HasValue;
                            resp.ReportingAssessment.SubmittedAt = ra1Submitted?.ToString("o");

                            const int baseIdx = 34;   // ra1_agree_with_self (was 32, +2 for assessment_id + submitted cols)
                            resp.ReportingAssessment.AgreeWithSelf = r.IsDBNull(baseIdx + 0) ? (bool?)null : r.GetBoolean(baseIdx + 0);
                            resp.ReportingAssessment.DisagreeDetails = r.IsDBNull(baseIdx + 1) ? null : r.GetString(baseIdx + 1);
                            resp.ReportingAssessment.IntegrityComments = r.IsDBNull(baseIdx + 2) ? null : r.GetString(baseIdx + 2);
                            resp.ReportingAssessment.Remarks = r.IsDBNull(baseIdx + 3) ? null : r.GetString(baseIdx + 3);
                            resp.ReportingAssessment.WorkTargets = r.IsDBNull(baseIdx + 4) ? (byte?)null : r.GetByte(baseIdx + 4);
                            resp.ReportingAssessment.WorkQuality = r.IsDBNull(baseIdx + 5) ? (byte?)null : r.GetByte(baseIdx + 5);
                            resp.ReportingAssessment.WorkExceptional = r.IsDBNull(baseIdx + 6) ? (byte?)null : r.GetByte(baseIdx + 6);
                            resp.ReportingAssessment.WorkOverall = r.IsDBNull(baseIdx + 7) ? (decimal?)null : r.GetDecimal(baseIdx + 7);
                            resp.ReportingAssessment.AttrAttitude = r.IsDBNull(baseIdx + 8) ? (byte?)null : r.GetByte(baseIdx + 8);
                            resp.ReportingAssessment.AttrResponsibility = r.IsDBNull(baseIdx + 9) ? (byte?)null : r.GetByte(baseIdx + 9);
                            resp.ReportingAssessment.AttrStability = r.IsDBNull(baseIdx + 10) ? (byte?)null : r.GetByte(baseIdx + 10);
                            resp.ReportingAssessment.AttrCommunication = r.IsDBNull(baseIdx + 11) ? (byte?)null : r.GetByte(baseIdx + 11);
                            resp.ReportingAssessment.AttrMoralCourage = r.IsDBNull(baseIdx + 12) ? (byte?)null : r.GetByte(baseIdx + 12);
                            resp.ReportingAssessment.AttrLeadership = r.IsDBNull(baseIdx + 13) ? (byte?)null : r.GetByte(baseIdx + 13);
                            resp.ReportingAssessment.AttrTimeliness = r.IsDBNull(baseIdx + 14) ? (byte?)null : r.GetByte(baseIdx + 14);
                            resp.ReportingAssessment.AttrOverall = r.IsDBNull(baseIdx + 15) ? (decimal?)null : r.GetDecimal(baseIdx + 15);
                            resp.ReportingAssessment.CompKnowledge = r.IsDBNull(baseIdx + 16) ? (byte?)null : r.GetByte(baseIdx + 16);
                            resp.ReportingAssessment.CompPlanning = r.IsDBNull(baseIdx + 17) ? (byte?)null : r.GetByte(baseIdx + 17);
                            resp.ReportingAssessment.CompDecision = r.IsDBNull(baseIdx + 18) ? (byte?)null : r.GetByte(baseIdx + 18);
                            resp.ReportingAssessment.CompInitiative = r.IsDBNull(baseIdx + 19) ? (byte?)null : r.GetByte(baseIdx + 19);
                            resp.ReportingAssessment.CompTeamwork = r.IsDBNull(baseIdx + 20) ? (byte?)null : r.GetByte(baseIdx + 20);
                            resp.ReportingAssessment.CompOverall = r.IsDBNull(baseIdx + 21) ? (decimal?)null : r.GetDecimal(baseIdx + 21);
                            resp.ReportingAssessment.OverallGrade = r.IsDBNull(baseIdx + 22) ? (decimal?)null : r.GetDecimal(baseIdx + 22);
                        }
                    }

                    errorCode = null;
                    return resp;
                }
            }
        }

        // ================================================================== //
        //  TryUpsertReportingDraft                                            //
        // ================================================================== //
        public bool TryUpsertReportingDraft(Guid acrId, Guid userId, ReportingDraftRequest request, out string errorCode)
        {
            // Verify ACR state and caller role
            const string acrCheck = @"
                SELECT status, form_type, reporting_user_id, ra2_user_id
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            string status; string formType; Guid ra1; Guid? ra2;

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(acrCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }
                    status = r.IsDBNull(0) ? null : r.GetString(0);
                    formType = r.IsDBNull(1) ? null : r.GetString(1);
                    ra1 = r.GetGuid(2);
                    ra2 = r.IsDBNull(3) ? (Guid?)null : r.GetGuid(3);
                }
            }

            bool isRa1Active = string.Equals(status, "PENDING_REPORTING", StringComparison.OrdinalIgnoreCase);
            bool isRa2Active = string.Equals(status, "PENDING_REPORTING2", StringComparison.OrdinalIgnoreCase);

            if (!isRa1Active && !isRa2Active) { errorCode = "INVALID_STATE"; return false; }

            if (isRa1Active && userId != ra1) { errorCode = "FORBIDDEN"; return false; }
            if (isRa2Active && (!ra2.HasValue || userId != ra2.Value)) { errorCode = "FORBIDDEN"; return false; }

            // Check not already submitted for this role
            const string submittedCheck = @"
                SELECT ra1_submitted_at, ra2_submitted_at
                FROM   dbo.reporting_assessments
                WHERE  acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(submittedCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        DateTime? ra1Sub = r.IsDBNull(0) ? (DateTime?)null : r.GetDateTime(0);
                        DateTime? ra2Sub = r.IsDBNull(1) ? (DateTime?)null : r.GetDateTime(1);
                        if (isRa2Active && ra2Sub.HasValue) { errorCode = "ALREADY_SUBMITTED"; return false; }
                        if (isRa1Active && ra1Sub.HasValue) { errorCode = "ALREADY_SUBMITTED"; return false; }
                    }
                }
            }

            // Ensure row exists
            const string ensureRow = @"
                IF NOT EXISTS (SELECT 1 FROM dbo.reporting_assessments WHERE acr_id = @acrId)
                BEGIN
                    INSERT INTO dbo.reporting_assessments (assessment_id, acr_id)
                    VALUES (NEWID(), @acrId);
                END";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(ensureRow, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            string updateSql = isRa2Active
                ? @"UPDATE dbo.reporting_assessments SET
                        ra2_agree_with_self     = @AgreeWithSelf,
                        ra2_disagree_details    = @DisagreeDetails,
                        ra2_integrity_comments  = @IntegrityComments,
                        ra2_remarks             = @Remarks,
                        ra2_work_targets        = @WorkTargets,
                        ra2_work_quality        = @WorkQuality,
                        ra2_work_exceptional    = @WorkExceptional,
                        ra2_work_overall        = @WorkOverall,
                        ra2_attr_attitude       = @AttrAttitude,
                        ra2_attr_responsibility = @AttrResponsibility,
                        ra2_attr_stability      = @AttrStability,
                        ra2_attr_communication  = @AttrCommunication,
                        ra2_attr_moral_courage  = @AttrMoralCourage,
                        ra2_attr_leadership     = @AttrLeadership,
                        ra2_attr_timeliness     = @AttrTimeliness,
                        ra2_attr_overall        = @AttrOverall,
                        ra2_comp_knowledge      = @CompKnowledge,
                        ra2_comp_planning       = @CompPlanning,
                        ra2_comp_decision       = @CompDecision,
                        ra2_comp_initiative     = @CompInitiative,
                        ra2_comp_teamwork       = @CompTeamwork,
                        ra2_comp_overall        = @CompOverall,
                        ra2_overall_grade       = @OverallGrade
                   WHERE acr_id = @acrId"
                : @"UPDATE dbo.reporting_assessments SET
                        ra1_agree_with_self     = @AgreeWithSelf,
                        ra1_disagree_details    = @DisagreeDetails,
                        ra1_integrity_comments  = @IntegrityComments,
                        ra1_remarks             = @Remarks,
                        ra1_work_targets        = @WorkTargets,
                        ra1_work_quality        = @WorkQuality,
                        ra1_work_exceptional    = @WorkExceptional,
                        ra1_work_overall        = @WorkOverall,
                        ra1_attr_attitude       = @AttrAttitude,
                        ra1_attr_responsibility = @AttrResponsibility,
                        ra1_attr_stability      = @AttrStability,
                        ra1_attr_communication  = @AttrCommunication,
                        ra1_attr_moral_courage  = @AttrMoralCourage,
                        ra1_attr_leadership     = @AttrLeadership,
                        ra1_attr_timeliness     = @AttrTimeliness,
                        ra1_attr_overall        = @AttrOverall,
                        ra1_comp_knowledge      = @CompKnowledge,
                        ra1_comp_planning       = @CompPlanning,
                        ra1_comp_decision       = @CompDecision,
                        ra1_comp_initiative     = @CompInitiative,
                        ra1_comp_teamwork       = @CompTeamwork,
                        ra1_comp_overall        = @CompOverall,
                        ra1_overall_grade       = @OverallGrade
                   WHERE acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(updateSql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@AgreeWithSelf", SqlDbType.Bit).Value = (object)request.AgreeWithSelf ?? DBNull.Value;
                cmd.Parameters.Add("@DisagreeDetails", SqlDbType.NVarChar).Value = (object)request.DisagreeDetails ?? DBNull.Value;
                cmd.Parameters.Add("@IntegrityComments", SqlDbType.NVarChar).Value = (object)request.IntegrityComments ?? DBNull.Value;
                cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar).Value = (object)request.Remarks ?? DBNull.Value;
                cmd.Parameters.Add("@WorkTargets", SqlDbType.TinyInt).Value = (object)request.WorkTargets ?? DBNull.Value;
                cmd.Parameters.Add("@WorkQuality", SqlDbType.TinyInt).Value = (object)request.WorkQuality ?? DBNull.Value;
                cmd.Parameters.Add("@WorkExceptional", SqlDbType.TinyInt).Value = (object)request.WorkExceptional ?? DBNull.Value;
                cmd.Parameters.Add("@WorkOverall", SqlDbType.Decimal).Value = (object)request.WorkOverall ?? DBNull.Value;
                if (request.WorkOverall.HasValue) { cmd.Parameters["@WorkOverall"].Precision = 4; cmd.Parameters["@WorkOverall"].Scale = 2; }
                cmd.Parameters.Add("@AttrAttitude", SqlDbType.TinyInt).Value = (object)request.AttrAttitude ?? DBNull.Value;
                cmd.Parameters.Add("@AttrResponsibility", SqlDbType.TinyInt).Value = (object)request.AttrResponsibility ?? DBNull.Value;
                cmd.Parameters.Add("@AttrStability", SqlDbType.TinyInt).Value = (object)request.AttrStability ?? DBNull.Value;
                cmd.Parameters.Add("@AttrCommunication", SqlDbType.TinyInt).Value = (object)request.AttrCommunication ?? DBNull.Value;
                cmd.Parameters.Add("@AttrMoralCourage", SqlDbType.TinyInt).Value = (object)request.AttrMoralCourage ?? DBNull.Value;
                cmd.Parameters.Add("@AttrLeadership", SqlDbType.TinyInt).Value = (object)request.AttrLeadership ?? DBNull.Value;
                cmd.Parameters.Add("@AttrTimeliness", SqlDbType.TinyInt).Value = (object)request.AttrTimeliness ?? DBNull.Value;
                cmd.Parameters.Add("@AttrOverall", SqlDbType.Decimal).Value = (object)request.AttrOverall ?? DBNull.Value;
                if (request.AttrOverall.HasValue) { cmd.Parameters["@AttrOverall"].Precision = 4; cmd.Parameters["@AttrOverall"].Scale = 2; }
                cmd.Parameters.Add("@CompKnowledge", SqlDbType.TinyInt).Value = (object)request.CompKnowledge ?? DBNull.Value;
                cmd.Parameters.Add("@CompPlanning", SqlDbType.TinyInt).Value = (object)request.CompPlanning ?? DBNull.Value;
                cmd.Parameters.Add("@CompDecision", SqlDbType.TinyInt).Value = (object)request.CompDecision ?? DBNull.Value;
                cmd.Parameters.Add("@CompInitiative", SqlDbType.TinyInt).Value = (object)request.CompInitiative ?? DBNull.Value;
                cmd.Parameters.Add("@CompTeamwork", SqlDbType.TinyInt).Value = (object)request.CompTeamwork ?? DBNull.Value;
                cmd.Parameters.Add("@CompOverall", SqlDbType.Decimal).Value = (object)request.CompOverall ?? DBNull.Value;
                if (request.CompOverall.HasValue) { cmd.Parameters["@CompOverall"].Precision = 4; cmd.Parameters["@CompOverall"].Scale = 2; }
                cmd.Parameters.Add("@OverallGrade", SqlDbType.Decimal).Value = (object)request.OverallGrade ?? DBNull.Value;
                if (request.OverallGrade.HasValue) { cmd.Parameters["@OverallGrade"].Precision = 4; cmd.Parameters["@OverallGrade"].Scale = 2; }

                con.Open();
                cmd.ExecuteNonQuery();
            }

            errorCode = null;
            return true;
        }

        // ================================================================== //
        //  TrySubmitReporting                                                 //
        // ================================================================== //
        public bool TrySubmitReporting(Guid acrId, Guid userId, out string errorCode)
        {
            using (var con = new SqlConnection(_conn))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    const string acrCheck = @"
                        SELECT status, form_type, reporting_user_id, ra2_user_id
                        FROM   dbo.acr_cycles WHERE acr_id = @acrId";

                    string status; string formType; Guid ra1; Guid? ra2;

                    using (var cmd = new SqlCommand(acrCheck, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { tx.Rollback(); errorCode = "NOT_FOUND"; return false; }
                            status = r.IsDBNull(0) ? null : r.GetString(0);
                            formType = r.IsDBNull(1) ? null : r.GetString(1);
                            ra1 = r.GetGuid(2);
                            ra2 = r.IsDBNull(3) ? (Guid?)null : r.GetGuid(3);
                        }
                    }

                    bool isRa1Active = string.Equals(status, "PENDING_REPORTING", StringComparison.OrdinalIgnoreCase);
                    bool isRa2Active = string.Equals(status, "PENDING_REPORTING2", StringComparison.OrdinalIgnoreCase);
                    bool requireA1b = string.Equals(formType, "A1b", StringComparison.OrdinalIgnoreCase);

                    if (isRa1Active)
                    {
                        if (userId != ra1) { tx.Rollback(); errorCode = "FORBIDDEN"; return false; }
                    }
                    else if (isRa2Active)
                    {
                        if (!ra2.HasValue || userId != ra2.Value) { tx.Rollback(); errorCode = "FORBIDDEN"; return false; }
                    }
                    else { tx.Rollback(); errorCode = "INVALID_STATE"; return false; }

                    string nextStatus = isRa1Active
                        ? (requireA1b ? "PENDING_REPORTING2" : "PENDING_REVIEWING")
                        : "PENDING_REVIEWING";

                    string submittedCol = isRa2Active ? "ra2_submitted_at" : "ra1_submitted_at";

                    string markSql = $@"
                        UPDATE dbo.reporting_assessments
                        SET    {submittedCol} = GETDATE()
                        WHERE  acr_id = @acrId AND {submittedCol} IS NULL;
                        SELECT @@ROWCOUNT;";

                    int affected;
                    using (var cmd = new SqlCommand(markSql, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        affected = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (affected == 0) { tx.Rollback(); errorCode = "ALREADY_SUBMITTED"; return false; }

                    const string advanceSql = @"
                        UPDATE dbo.acr_cycles
                        SET    status = @nextStatus, updated_at = GETDATE()
                        WHERE  acr_id = @acrId";

                    using (var cmd = new SqlCommand(advanceSql, con, tx))
                    {
                        cmd.Parameters.Add("@nextStatus", SqlDbType.VarChar).Value = nextStatus;
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    errorCode = null;
                    return true;
                }
            }
        }
    }
}