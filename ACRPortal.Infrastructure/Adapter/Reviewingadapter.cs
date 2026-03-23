using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class ReviewingAdapter : IReviewingRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  GetMyReviewingQueue                                                //
        // ================================================================== //
        public MyReviewingQueueResponse GetMyReviewingQueue(Guid userId)
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
                        rv.submitted_at
                FROM    dbo.acr_cycles ac
                JOIN    dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
                WHERE   ac.reviewing_user_id = @uid
                  AND   ac.status <> 'DRAFT'
                ORDER BY ac.created_at DESC";

            var resp = new MyReviewingQueueResponse();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        resp.AcrCycles.Add(new MyReviewingQueueItem
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
                            Status = r.IsDBNull(9) ? null : r.GetString(9),
                            CreatedAt = r.IsDBNull(10) ? null : r.GetDateTime(10).ToString("o"),
                            IsSubmitted = !r.IsDBNull(11)
                        });
            }
            return resp;
        }

        // ================================================================== //
        //  GetReviewingDetail                                                 //
        //                                                                     //
        //  Column index map (document_path removed from self_appraisals):    //
        //                                                                     //
        //  ACR header + officer + FKs  (0-13)                                //
        //   0  acr_id            5  designation      9  user_id              //
        //   1  form_type         6  posting_from    10  login_id             //
        //   2  status            7  posting_to      11  display_name         //
        //   3  department        8  acr_year        12  reviewing_user_id    //
        //   4  location                             13  ra2_user_id          //
        //                                                                     //
        //  Self-appraisal (14-29) — 16 cols, document_path removed           //
        //  14  appraisal_id     22  membership_bodies  27  prop_decl_date    //
        //  15  submitted_at     23  training_details   28  medical_compl     //
        //  16  leave_details    24  awards_honours     29  med_compl_date    //
        //  17  duties_desc      25  auditor_compliance                       //
        //  18  targets_set      26  property_declared                        //
        //  19  targets_achieved                                               //
        //  20  shortfall_reasons                                              //
        //  21  major_achievements                                             //
        //                                                                     //
        //  RA assessment (30-78) — same structure as ReportingAdapter        //
        //  30  assessment_id    31  ra1_submitted    32-55  RA1 block        //
        //  55  ra1_overall      56  ra2_submitted    57-78  RA2 block (but   //
        //       ra2_agree starts at col 57 → RA2 hasRa2 proxy = col 57)     //
        //                                                                     //
        //  rva_* override grades (79-93) — 15 items                         //
        //  79  rva_work_targets  ...  93  rva_comp_teamwork                  //
        //                                                                     //
        //  reviewing_assessments (94-99)                                     //
        //  94  review_id  95  agree_with_ra  96  disagree_details            //
        //  97  remarks    98  final_grade    99  submitted_at                //
        // ================================================================== //
        public ReviewingAcrDetailResponse GetReviewingDetail(Guid acrId, Guid userId, out string errorCode)
        {
            const string sql = @"
                SELECT
                    -- ACR header (0-8)
                    ac.acr_id,
                    ac.form_type,
                    ac.status,
                    ac.department,
                    ac.location,
                    ac.designation,
                    ac.posting_from,
                    ac.posting_to,
                    ac.acr_year,

                    -- Officer (9-11)
                    u.user_id,
                    u.login_id,
                    u.display_name,

                    -- Access-control (12-13)
                    ac.reviewing_user_id,
                    ac.ra2_user_id,

                    -- Self-appraisal (14-29): document_path removed
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

                    -- RA assessment: id + RA1 block (30-55)
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

                    -- RA2 block (56-79)
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

                    -- rva_* overrides in reporting_assessments (79-93)
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

                    -- reviewing_assessments (94-99)
                    rv.review_id,
                    rv.agree_with_ra,
                    rv.disagree_details,
                    rv.remarks,
                    rv.final_grade,
                    rv.submitted_at

                FROM dbo.acr_cycles ac
                JOIN  dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.self_appraisals       sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
                LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
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
                    Guid rvaId = r.GetGuid(12);

                    if (userId != rvaId)
                    { errorCode = "FORBIDDEN"; return null; }
                    if (!string.Equals(status, "PENDING_REVIEWING", StringComparison.OrdinalIgnoreCase))
                    { errorCode = "INVALID_STATE"; return null; }

                    var resp = new ReviewingAcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = status,
                        Department = r.IsDBNull(3) ? null : r.GetString(3),
                        Location = r.IsDBNull(4) ? null : r.GetString(4),
                        Designation = r.IsDBNull(5) ? null : r.GetString(5),
                        PostingFrom = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8)
                    };

                    resp.Officer.UserId = r.GetGuid(9).ToString();
                    resp.Officer.LoginId = r.IsDBNull(10) ? null : r.GetString(10);
                    resp.Officer.DisplayName = r.IsDBNull(11) ? null : r.GetString(11);

                    // ── Self-appraisal (14-29) ───────────────────────────────
                    bool hasSelf = !r.IsDBNull(14);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? saSubmit = r.IsDBNull(15) ? (DateTime?)null : r.GetDateTime(15);
                        resp.SelfAppraisal.IsSubmitted = saSubmit.HasValue;
                        resp.SelfAppraisal.SubmittedAt = saSubmit?.ToString("o");
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
                        // document_path removed — documents fetched separately via DocumentAdapter
                    }

                    // ── RA1 assessment (30-55) ───────────────────────────────
                    bool hasRa = !r.IsDBNull(30);   // assessment_id
                    resp.Ra1Assessment.Exists = hasRa;
                    if (hasRa)
                    {
                        DateTime? ra1Sub = r.IsDBNull(31) ? (DateTime?)null : r.GetDateTime(31);
                        resp.Ra1Assessment.IsSubmitted = ra1Sub.HasValue;
                        resp.Ra1Assessment.SubmittedAt = ra1Sub?.ToString("o");
                        resp.Ra1Assessment.AgreeWithSelf = r.IsDBNull(32) ? (bool?)null : r.GetBoolean(32);
                        resp.Ra1Assessment.DisagreeDetails = r.IsDBNull(33) ? null : r.GetString(33);
                        resp.Ra1Assessment.IntegrityComments = r.IsDBNull(34) ? null : r.GetString(34);
                        resp.Ra1Assessment.Remarks = r.IsDBNull(35) ? null : r.GetString(35);
                        resp.Ra1Assessment.WorkTargets = r.IsDBNull(36) ? (byte?)null : r.GetByte(36);
                        resp.Ra1Assessment.WorkQuality = r.IsDBNull(37) ? (byte?)null : r.GetByte(37);
                        resp.Ra1Assessment.WorkExceptional = r.IsDBNull(38) ? (byte?)null : r.GetByte(38);
                        resp.Ra1Assessment.WorkOverall = r.IsDBNull(39) ? (decimal?)null : r.GetDecimal(39);
                        resp.Ra1Assessment.AttrAttitude = r.IsDBNull(40) ? (byte?)null : r.GetByte(40);
                        resp.Ra1Assessment.AttrResponsibility = r.IsDBNull(41) ? (byte?)null : r.GetByte(41);
                        resp.Ra1Assessment.AttrStability = r.IsDBNull(42) ? (byte?)null : r.GetByte(42);
                        resp.Ra1Assessment.AttrCommunication = r.IsDBNull(43) ? (byte?)null : r.GetByte(43);
                        resp.Ra1Assessment.AttrMoralCourage = r.IsDBNull(44) ? (byte?)null : r.GetByte(44);
                        resp.Ra1Assessment.AttrLeadership = r.IsDBNull(45) ? (byte?)null : r.GetByte(45);
                        resp.Ra1Assessment.AttrTimeliness = r.IsDBNull(46) ? (byte?)null : r.GetByte(46);
                        resp.Ra1Assessment.AttrOverall = r.IsDBNull(47) ? (decimal?)null : r.GetDecimal(47);
                        resp.Ra1Assessment.CompKnowledge = r.IsDBNull(48) ? (byte?)null : r.GetByte(48);
                        resp.Ra1Assessment.CompPlanning = r.IsDBNull(49) ? (byte?)null : r.GetByte(49);
                        resp.Ra1Assessment.CompDecision = r.IsDBNull(50) ? (byte?)null : r.GetByte(50);
                        resp.Ra1Assessment.CompInitiative = r.IsDBNull(51) ? (byte?)null : r.GetByte(51);
                        resp.Ra1Assessment.CompTeamwork = r.IsDBNull(52) ? (byte?)null : r.GetByte(52);
                        resp.Ra1Assessment.CompOverall = r.IsDBNull(53) ? (decimal?)null : r.GetDecimal(53);
                        resp.Ra1Assessment.OverallGrade = r.IsDBNull(54) ? (decimal?)null : r.GetDecimal(54);
                    }

                    // ── RA2 assessment (55-78) — null for A1a/A2 ────────────
                    // 55 = ra2_submitted_at, 56 = ra2_agree_with_self (presence proxy)
                    bool isA1b = string.Equals(r.IsDBNull(1) ? null : r.GetString(1), "A1b", StringComparison.OrdinalIgnoreCase);
                    resp.Ra2Assessment.Exists = isA1b && hasRa && !r.IsDBNull(56);
                    if (resp.Ra2Assessment.Exists)
                    {
                        DateTime? ra2Sub = r.IsDBNull(55) ? (DateTime?)null : r.GetDateTime(55);
                        resp.Ra2Assessment.IsSubmitted = ra2Sub.HasValue;
                        resp.Ra2Assessment.SubmittedAt = ra2Sub?.ToString("o");
                        resp.Ra2Assessment.AgreeWithSelf = r.IsDBNull(56) ? (bool?)null : r.GetBoolean(56);
                        resp.Ra2Assessment.DisagreeDetails = r.IsDBNull(57) ? null : r.GetString(57);
                        resp.Ra2Assessment.IntegrityComments = r.IsDBNull(58) ? null : r.GetString(58);
                        resp.Ra2Assessment.Remarks = r.IsDBNull(59) ? null : r.GetString(59);
                        resp.Ra2Assessment.WorkTargets = r.IsDBNull(60) ? (byte?)null : r.GetByte(60);
                        resp.Ra2Assessment.WorkQuality = r.IsDBNull(61) ? (byte?)null : r.GetByte(61);
                        resp.Ra2Assessment.WorkExceptional = r.IsDBNull(62) ? (byte?)null : r.GetByte(62);
                        resp.Ra2Assessment.WorkOverall = r.IsDBNull(63) ? (decimal?)null : r.GetDecimal(63);
                        resp.Ra2Assessment.AttrAttitude = r.IsDBNull(64) ? (byte?)null : r.GetByte(64);
                        resp.Ra2Assessment.AttrResponsibility = r.IsDBNull(65) ? (byte?)null : r.GetByte(65);
                        resp.Ra2Assessment.AttrStability = r.IsDBNull(66) ? (byte?)null : r.GetByte(66);
                        resp.Ra2Assessment.AttrCommunication = r.IsDBNull(67) ? (byte?)null : r.GetByte(67);
                        resp.Ra2Assessment.AttrMoralCourage = r.IsDBNull(68) ? (byte?)null : r.GetByte(68);
                        resp.Ra2Assessment.AttrLeadership = r.IsDBNull(69) ? (byte?)null : r.GetByte(69);
                        resp.Ra2Assessment.AttrTimeliness = r.IsDBNull(70) ? (byte?)null : r.GetByte(70);
                        resp.Ra2Assessment.AttrOverall = r.IsDBNull(71) ? (decimal?)null : r.GetDecimal(71);
                        resp.Ra2Assessment.CompKnowledge = r.IsDBNull(72) ? (byte?)null : r.GetByte(72);
                        resp.Ra2Assessment.CompPlanning = r.IsDBNull(73) ? (byte?)null : r.GetByte(73);
                        resp.Ra2Assessment.CompDecision = r.IsDBNull(74) ? (byte?)null : r.GetByte(74);
                        resp.Ra2Assessment.CompInitiative = r.IsDBNull(75) ? (byte?)null : r.GetByte(75);
                        resp.Ra2Assessment.CompTeamwork = r.IsDBNull(76) ? (byte?)null : r.GetByte(76);
                        resp.Ra2Assessment.CompOverall = r.IsDBNull(77) ? (decimal?)null : r.GetDecimal(77);
                        resp.Ra2Assessment.OverallGrade = r.IsDBNull(78) ? (decimal?)null : r.GetDecimal(78);
                    }

                    // ── rva_* override grades (79-93) ────────────────────────
                    resp.RvaOverrideGrades.WorkTargets = r.IsDBNull(79) ? (byte?)null : r.GetByte(79);
                    resp.RvaOverrideGrades.WorkQuality = r.IsDBNull(80) ? (byte?)null : r.GetByte(80);
                    resp.RvaOverrideGrades.WorkExceptional = r.IsDBNull(81) ? (byte?)null : r.GetByte(81);
                    resp.RvaOverrideGrades.AttrAttitude = r.IsDBNull(82) ? (byte?)null : r.GetByte(82);
                    resp.RvaOverrideGrades.AttrResponsibility = r.IsDBNull(83) ? (byte?)null : r.GetByte(83);
                    resp.RvaOverrideGrades.AttrStability = r.IsDBNull(84) ? (byte?)null : r.GetByte(84);
                    resp.RvaOverrideGrades.AttrCommunication = r.IsDBNull(85) ? (byte?)null : r.GetByte(85);
                    resp.RvaOverrideGrades.AttrMoralCourage = r.IsDBNull(86) ? (byte?)null : r.GetByte(86);
                    resp.RvaOverrideGrades.AttrLeadership = r.IsDBNull(87) ? (byte?)null : r.GetByte(87);
                    resp.RvaOverrideGrades.AttrTimeliness = r.IsDBNull(88) ? (byte?)null : r.GetByte(88);
                    resp.RvaOverrideGrades.CompKnowledge = r.IsDBNull(89) ? (byte?)null : r.GetByte(89);
                    resp.RvaOverrideGrades.CompPlanning = r.IsDBNull(90) ? (byte?)null : r.GetByte(90);
                    resp.RvaOverrideGrades.CompDecision = r.IsDBNull(91) ? (byte?)null : r.GetByte(91);
                    resp.RvaOverrideGrades.CompInitiative = r.IsDBNull(92) ? (byte?)null : r.GetByte(92);
                    resp.RvaOverrideGrades.CompTeamwork = r.IsDBNull(93) ? (byte?)null : r.GetByte(93);

                    // ── Reviewing assessment (94-99) ─────────────────────────
                    bool hasRv = !r.IsDBNull(94);
                    resp.ReviewingAssessment.Exists = hasRv;
                    if (hasRv)
                    {
                        DateTime? rvSub = r.IsDBNull(99) ? (DateTime?)null : r.GetDateTime(99);
                        resp.ReviewingAssessment.IsSubmitted = rvSub.HasValue;
                        resp.ReviewingAssessment.SubmittedAt = rvSub?.ToString("o");
                        resp.ReviewingAssessment.AgreeWithRa = r.IsDBNull(95) ? (bool?)null : r.GetBoolean(95);
                        resp.ReviewingAssessment.DisagreeDetails = r.IsDBNull(96) ? null : r.GetString(96);
                        resp.ReviewingAssessment.Comments = r.IsDBNull(97) ? null : r.GetString(97);
                        resp.ReviewingAssessment.OverallGrade = r.IsDBNull(98) ? (decimal?)null : r.GetDecimal(98);
                        // document_path removed — documents fetched separately via DocumentAdapter
                    }

                    errorCode = null;
                    return resp;
                }
            }
        }

        // ================================================================== //
        //  TryUpsertReviewingDraft — unchanged from original                 //
        // ================================================================== //
        public bool TryUpsertReviewingDraft(Guid acrId, Guid userId, ReviewingDraftRequest request, out string errorCode)
        {
            const string acrCheck = @"
                SELECT reviewing_user_id, status
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            Guid rvaId;
            string status;

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(acrCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }
                    rvaId = r.GetGuid(0);
                    status = r.IsDBNull(1) ? null : r.GetString(1);
                }
            }

            if (userId != rvaId)
            { errorCode = "FORBIDDEN"; return false; }
            if (!string.Equals(status, "PENDING_REVIEWING", StringComparison.OrdinalIgnoreCase))
            { errorCode = "INVALID_STATE"; return false; }

            const string submittedCheck = @"
                SELECT submitted_at FROM dbo.reviewing_assessments WHERE acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(submittedCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                var val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value) { errorCode = "ALREADY_SUBMITTED"; return false; }
            }

            const string upsertRv = @"
                MERGE dbo.reviewing_assessments AS target
                USING (SELECT @acrId AS acr_id) AS src
                   ON target.acr_id = src.acr_id
                WHEN MATCHED THEN
                    UPDATE SET
                        agree_with_ra    = @agreeWithRa,
                        disagree_details = @disagreeDetails,
                        remarks          = @comments,
                        final_grade      = @overallGrade,
                        submitted_at     = NULL
                WHEN NOT MATCHED THEN
                    INSERT (review_id, acr_id, agree_with_ra, disagree_details, remarks, final_grade)
                    VALUES (NEWID(), @acrId, @agreeWithRa, @disagreeDetails, @comments, @overallGrade);";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(upsertRv, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@agreeWithRa", SqlDbType.Bit).Value = (object)request.AgreeWithRa ?? DBNull.Value;
                cmd.Parameters.Add("@disagreeDetails", SqlDbType.NVarChar).Value = (object)request.DisagreeDetails ?? DBNull.Value;
                cmd.Parameters.Add("@comments", SqlDbType.NVarChar).Value = (object)request.Comments ?? DBNull.Value;
                var gradeParam = cmd.Parameters.Add("@overallGrade", SqlDbType.Decimal);
                gradeParam.Precision = 4; gradeParam.Scale = 2;
                gradeParam.Value = (object)request.OverallGrade ?? DBNull.Value;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            const string ensureRa = @"
                IF NOT EXISTS (SELECT 1 FROM dbo.reporting_assessments WHERE acr_id = @acrId)
                    INSERT INTO dbo.reporting_assessments (assessment_id, acr_id) VALUES (NEWID(), @acrId);";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(ensureRa, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            const string updateRva = @"
                UPDATE dbo.reporting_assessments SET
                    rva_work_targets        = @WorkTargets,
                    rva_work_quality        = @WorkQuality,
                    rva_work_exceptional    = @WorkExceptional,
                    rva_attr_attitude       = @AttrAttitude,
                    rva_attr_responsibility = @AttrResponsibility,
                    rva_attr_stability      = @AttrStability,
                    rva_attr_communication  = @AttrCommunication,
                    rva_attr_moral_courage  = @AttrMoralCourage,
                    rva_attr_leadership     = @AttrLeadership,
                    rva_attr_timeliness     = @AttrTimeliness,
                    rva_comp_knowledge      = @CompKnowledge,
                    rva_comp_planning       = @CompPlanning,
                    rva_comp_decision       = @CompDecision,
                    rva_comp_initiative     = @CompInitiative,
                    rva_comp_teamwork       = @CompTeamwork
                WHERE acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(updateRva, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@WorkTargets", SqlDbType.TinyInt).Value = (object)request.WorkTargets ?? DBNull.Value;
                cmd.Parameters.Add("@WorkQuality", SqlDbType.TinyInt).Value = (object)request.WorkQuality ?? DBNull.Value;
                cmd.Parameters.Add("@WorkExceptional", SqlDbType.TinyInt).Value = (object)request.WorkExceptional ?? DBNull.Value;
                cmd.Parameters.Add("@AttrAttitude", SqlDbType.TinyInt).Value = (object)request.AttrAttitude ?? DBNull.Value;
                cmd.Parameters.Add("@AttrResponsibility", SqlDbType.TinyInt).Value = (object)request.AttrResponsibility ?? DBNull.Value;
                cmd.Parameters.Add("@AttrStability", SqlDbType.TinyInt).Value = (object)request.AttrStability ?? DBNull.Value;
                cmd.Parameters.Add("@AttrCommunication", SqlDbType.TinyInt).Value = (object)request.AttrCommunication ?? DBNull.Value;
                cmd.Parameters.Add("@AttrMoralCourage", SqlDbType.TinyInt).Value = (object)request.AttrMoralCourage ?? DBNull.Value;
                cmd.Parameters.Add("@AttrLeadership", SqlDbType.TinyInt).Value = (object)request.AttrLeadership ?? DBNull.Value;
                cmd.Parameters.Add("@AttrTimeliness", SqlDbType.TinyInt).Value = (object)request.AttrTimeliness ?? DBNull.Value;
                cmd.Parameters.Add("@CompKnowledge", SqlDbType.TinyInt).Value = (object)request.CompKnowledge ?? DBNull.Value;
                cmd.Parameters.Add("@CompPlanning", SqlDbType.TinyInt).Value = (object)request.CompPlanning ?? DBNull.Value;
                cmd.Parameters.Add("@CompDecision", SqlDbType.TinyInt).Value = (object)request.CompDecision ?? DBNull.Value;
                cmd.Parameters.Add("@CompInitiative", SqlDbType.TinyInt).Value = (object)request.CompInitiative ?? DBNull.Value;
                cmd.Parameters.Add("@CompTeamwork", SqlDbType.TinyInt).Value = (object)request.CompTeamwork ?? DBNull.Value;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            errorCode = null;
            return true;
        }

        // ================================================================== //
        //  TrySubmitReviewing — unchanged from original                      //
        // ================================================================== //
        public bool TrySubmitReviewing(Guid acrId, Guid userId, out string errorCode)
        {
            using (var con = new SqlConnection(_conn))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    const string acrCheck = @"
                        SELECT reviewing_user_id, status
                        FROM   dbo.acr_cycles WHERE acr_id = @acrId";

                    Guid rvaId;
                    string status;

                    using (var cmd = new SqlCommand(acrCheck, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { tx.Rollback(); errorCode = "NOT_FOUND"; return false; }
                            rvaId = r.GetGuid(0);
                            status = r.IsDBNull(1) ? null : r.GetString(1);
                        }
                    }

                    if (userId != rvaId)
                    { tx.Rollback(); errorCode = "FORBIDDEN"; return false; }
                    if (!string.Equals(status, "PENDING_REVIEWING", StringComparison.OrdinalIgnoreCase))
                    { tx.Rollback(); errorCode = "INVALID_STATE"; return false; }

                    const string rvCheck = @"
                        SELECT submitted_at FROM dbo.reviewing_assessments WHERE acr_id = @acrId";

                    object submittedVal;
                    using (var cmd = new SqlCommand(rvCheck, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        submittedVal = cmd.ExecuteScalar();
                    }

                    if (submittedVal == null)
                    { tx.Rollback(); errorCode = "BAD_REQUEST"; return false; }
                    if (submittedVal != DBNull.Value)
                    { tx.Rollback(); errorCode = "ALREADY_SUBMITTED"; return false; }

                    const string markSql = @"
                        UPDATE dbo.reviewing_assessments
                        SET    submitted_at = GETDATE()
                        WHERE  acr_id = @acrId AND submitted_at IS NULL;
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
                        SET    status = 'PENDING_ACCEPTING', updated_at = GETDATE()
                        WHERE  acr_id = @acrId";

                    using (var cmd = new SqlCommand(advanceSql, con, tx))
                    {
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