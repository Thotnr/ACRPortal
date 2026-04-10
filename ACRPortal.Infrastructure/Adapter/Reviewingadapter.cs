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
        //  GetMyReviewingQueue                                               //
        // ================================================================== //
        public PagedResult<MyReviewingQueueItem> GetMyReviewingQueue(
            Guid userId, 
            int pageNumber, 
            int pageSize,
            string Status,
            string Officer_name)
        {
            Status = string.IsNullOrWhiteSpace(Status) ? null : Status.Trim().ToUpper();
            string sql = @"
        SELECT COUNT(1)
        FROM dbo.acr_cycles ac
        JOIN dbo.users u ON u.user_id = ac.officer_user_id
        WHERE ac.reviewing_user_id = @uid
          AND ac.status IN ('PENDING_REVIEWING','PENDING_ACCEPTING','APPROVED','REJECTED') " +
            (Status != null ? " AND ac.status = @status " : "") +
            (Officer_name != null ? " AND LOWER(u.display_name) LIKE LOWER(@officerName) " : "") +
                @";

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
                rv.submitted_at,
                d.dsg
        FROM    dbo.acr_cycles ac
        JOIN    dbo.users u ON u.user_id = ac.officer_user_id
        LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
        LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
        WHERE   ac.reviewing_user_id = @uid
          AND   ac.status IN ('PENDING_REVIEWING','PENDING_ACCEPTING','APPROVED','REJECTED')" +
                (Status != null ? " AND ac.status = @status " : "") +
                (Officer_name != null ? " AND LOWER(u.display_name) LIKE LOWER(@officerName) " : "") +
                @"
        ORDER BY ac.created_at DESC
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    ";

            var resp = new PagedResult<MyReviewingQueueItem>
            {
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = userId;
                cmd.Parameters.Add("@offset", SqlDbType.Int).Value = (pageNumber - 1) * pageSize;
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize;
                if (Status != null)
                    cmd.Parameters.Add("@status", SqlDbType.VarChar).Value = Status;
                if (Officer_name != null)
                    cmd.Parameters.Add("@officerName", SqlDbType.VarChar).Value = "%" + Officer_name.Trim() + "%";

                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    // total count
                    if (r.Read())
                        resp.TotalCount = r.GetInt32(0);

                    r.NextResult();

                    while (r.Read())
                    {
                        resp.Items.Add(new MyReviewingQueueItem
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
                            IsSubmitted = !r.IsDBNull(11),
                            Dsg = r.IsDBNull(12) ? null : r.GetString(12)
                        });
                    }
                }
            }

            resp.TotalPages = (int)Math.Ceiling((double)resp.TotalCount / pageSize);

            return resp;
        }

        // ================================================================== //
        //  GetReviewingDetail — full shape, all sections                     //
        //                                                                    //
        //  Column index map:                                                 //
        //                                                                    //
        //  ACR header + officer + FKs  (0-13)                               //
        //   0  acr_id            5  designation      9  user_id              //
        //   1  form_type         6  posting_from    10  login_id             //
        //   2  status            7  posting_to      11  display_name         //
        //   3  department        8  acr_year        12  reviewing_user_id    //
        //   4  location                             13  ra2_user_id          //
        //                                                                    //
        //  Section I CCA (14-23)                                             //
        //  14 date_of_birth        19 property_return_date                   //
        //  15 date_joining_nigam   20 last_medical_exam_date                 //
        //  16 date_joining_rank    21 career_posting_summary                 //
        //  17 date_joining_stn     22 academic_qual                          //
        //  18 technical_qual       23 dept_exam_passed                       //
        //                                                                    //
        //  Self-appraisal (24-39)                                            //
        //  Self-appraisal (24-39) — 16 cols                                 //
        //                                                                    //
        //  RA assessment (40-88) — same as Reporting adapter                //
        //  40 assessment_id  41 ra1_submitted  42-64 RA1 block               //
        //  65 ra2_submitted  66-88 RA2 block                                 //
        //                                                                    //
        //  rva_* overrides (89-103) — 15 items                              //
        //                                                                    //
        //  reviewing_assessments (104-109)                                   //
        //  104 review_id  105 agree_with_ra  106 disagree_details            //
        //  107 remarks    108 final_grade    109 submitted_at                //
        //                                                                    //
        //  accepting_decisions (110-117)  ← NEW                             //
        //  110 decision_id        114 final_grade                            //
        //  111 agree_with_prev    115 final_remarks                          //
        //  112 disagree_details   116 is_approved                            //
        //  113 conflict_resolved  117 decided_at                             //
        // ================================================================== //
        public ReviewingAcrDetailResponse GetReviewingDetail(Guid acrId, Guid userId, out string errorCode)
        {
            const string sql = @"
                SELECT
                    -- ACR header (0-13)
                    ac.acr_id,
                    ac.form_type,
                    ac.status,
                    ac.department,
                    ac.location,
                    d.dsg,
                    ac.posting_from,
                    ac.posting_to,
                    ac.acr_year,
                    u.user_id,
                    u.login_id,
                    u.display_name,
                    ac.reviewing_user_id,
                    ac.ra2_user_id,

                    -- Section I CCA (14-23)
                    ac.date_of_birth,
                    ac.date_joining_nigam,
                    ac.date_joining_present_rank,
                    ac.date_joining_present_station,
                    ac.technical_qualification,
                    ac.property_return_date,
                    ac.last_medical_exam_date,
                    ac.career_posting_summary,
                    ac.academic_qualification,
                    ac.departmental_exam_passed,

                    -- Self-appraisal (24-39)
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

                    -- RA assessment: id + RA1 block (40-64)
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

                    -- RA2 block (65-88)
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

                    -- rva_* overrides (89-103)
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

                    -- reviewing_assessments (104-109)
                    rv.review_id,
                    rv.agree_with_ra,
                    rv.disagree_details,
                    rv.remarks,
                    rv.final_grade,
                    rv.submitted_at,

                    -- accepting_decisions (110-117)
                    ad.decision_id,
                    ad.agree_with_previous,
                    ad.disagree_details,
                    ad.conflict_resolved,
                    ad.final_grade,
                    ad.final_remarks,
                    ad.is_approved,
                    ad.decided_at

                FROM dbo.acr_cycles ac
                JOIN  dbo.users u ON u.user_id = ac.officer_user_id
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
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return null; }

                    string status = r.IsDBNull(2) ? null : r.GetString(2);
                    Guid rvaId = r.GetGuid(12);

                    if (userId != rvaId)
                    { errorCode = "FORBIDDEN"; return null; }

                    bool canView =
                        string.Equals(status, "PENDING_REVIEWING", StringComparison.OrdinalIgnoreCase)
                        || string.Equals(status, "PENDING_ACCEPTING", StringComparison.OrdinalIgnoreCase)
                        || string.Equals(status, "APPROVED", StringComparison.OrdinalIgnoreCase)
                        || string.Equals(status, "REJECTED", StringComparison.OrdinalIgnoreCase);
                    if (!canView)
                    { errorCode = "INVALID_STATE"; return null; }

                    bool isA1b = string.Equals(
                        r.IsDBNull(1) ? null : r.GetString(1),
                        "A1b", StringComparison.OrdinalIgnoreCase);

                    var resp = new ReviewingAcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = status,
                        Department = r.IsDBNull(3) ? null : r.GetString(3),
                        Location = r.IsDBNull(4) ? null : r.GetString(4),
                        Dsg = r.IsDBNull(5) ? null : r.GetString(5),
                        PostingFrom = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8),

                        // Section I CCA
                        DateOfBirth = r.IsDBNull(14) ? null : r.GetDateTime(14).ToString("yyyy-MM-dd"),
                        DateJoiningNigam = r.IsDBNull(15) ? null : r.GetDateTime(15).ToString("yyyy-MM-dd"),
                        DateJoiningPresentRank = r.IsDBNull(16) ? null : r.GetDateTime(16).ToString("yyyy-MM-dd"),
                        DateJoiningPresentStation = r.IsDBNull(17) ? null : r.GetDateTime(17).ToString("yyyy-MM-dd"),
                        TechnicalQualification = r.IsDBNull(18) ? null : r.GetString(18),
                        PropertyReturnDate = r.IsDBNull(19) ? null : r.GetDateTime(19).ToString("yyyy-MM-dd"),
                        LastMedicalExamDate = r.IsDBNull(20) ? null : r.GetDateTime(20).ToString("yyyy-MM-dd"),
                        CareerPostingSummary = r.IsDBNull(21) ? null : r.GetString(21),
                        AcademicQualification = r.IsDBNull(22) ? null : r.GetString(22),
                        DepartmentalExamPassed = r.IsDBNull(23) ? null : r.GetString(23),
                    };

                    resp.Officer.UserId = r.GetGuid(9).ToString();
                    resp.Officer.LoginId = r.IsDBNull(10) ? null : r.GetString(10);
                    resp.Officer.DisplayName = r.IsDBNull(11) ? null : r.GetString(11);

                    // ── Self-appraisal (24-39) ───────────────────────────────
                    bool hasSelf = !r.IsDBNull(24);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? saSubmit = r.IsDBNull(25) ? (DateTime?)null : r.GetDateTime(25);
                        resp.SelfAppraisal.IsSubmitted = saSubmit.HasValue;
                        resp.SelfAppraisal.SubmittedAt = saSubmit?.ToString("o");
                        resp.SelfAppraisal.LeaveDetails = r.IsDBNull(26) ? null : r.GetString(26);
                        resp.SelfAppraisal.DutiesDescription = r.IsDBNull(27) ? null : r.GetString(27);
                        resp.SelfAppraisal.TargetsSet = r.IsDBNull(28) ? null : r.GetString(28);
                        resp.SelfAppraisal.TargetsAchieved = r.IsDBNull(29) ? null : r.GetString(29);
                        resp.SelfAppraisal.ShortfallReasons = r.IsDBNull(30) ? null : r.GetString(30);
                        resp.SelfAppraisal.MajorAchievements = r.IsDBNull(31) ? null : r.GetString(31);
                        resp.SelfAppraisal.MembershipBodies = r.IsDBNull(32) ? null : r.GetString(32);
                        resp.SelfAppraisal.TrainingDetails = r.IsDBNull(33) ? null : r.GetString(33);
                        resp.SelfAppraisal.AwardsHonours = r.IsDBNull(34) ? null : r.GetString(34);
                        resp.SelfAppraisal.AuditorCompliance = r.IsDBNull(35) ? (bool?)null : r.GetBoolean(35);
                        resp.SelfAppraisal.PropertyDeclared = !r.IsDBNull(36) && r.GetBoolean(36);
                        resp.SelfAppraisal.PropertyDeclaredDate = r.IsDBNull(37) ? null : r.GetDateTime(37).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.MedicalCompliance = !r.IsDBNull(38) && r.GetBoolean(38);
                        resp.SelfAppraisal.MedicalComplianceDate = r.IsDBNull(39) ? null : r.GetDateTime(39).ToString("yyyy-MM-dd");
                    }

                    // ── RA1 assessment (40-64) ───────────────────────────────
                    bool hasRa = !r.IsDBNull(40);
                    resp.Ra1Assessment.Exists = hasRa;
                    if (hasRa)
                    {
                        DateTime? ra1Sub = r.IsDBNull(41) ? (DateTime?)null : r.GetDateTime(41);
                        resp.Ra1Assessment.IsSubmitted = ra1Sub.HasValue;
                        resp.Ra1Assessment.SubmittedAt = ra1Sub?.ToString("o");
                        resp.Ra1Assessment.AgreeWithSelf = r.IsDBNull(42) ? (bool?)null : r.GetBoolean(42);
                        resp.Ra1Assessment.DisagreeDetails = r.IsDBNull(43) ? null : r.GetString(43);
                        resp.Ra1Assessment.IntegrityComments = r.IsDBNull(44) ? null : r.GetString(44);
                        resp.Ra1Assessment.Remarks = r.IsDBNull(45) ? null : r.GetString(45);
                        resp.Ra1Assessment.WorkTargets = r.IsDBNull(46) ? (byte?)null : r.GetByte(46);
                        resp.Ra1Assessment.WorkQuality = r.IsDBNull(47) ? (byte?)null : r.GetByte(47);
                        resp.Ra1Assessment.WorkExceptional = r.IsDBNull(48) ? (byte?)null : r.GetByte(48);
                        resp.Ra1Assessment.WorkOverall = r.IsDBNull(49) ? (decimal?)null : r.GetDecimal(49);
                        resp.Ra1Assessment.AttrAttitude = r.IsDBNull(50) ? (byte?)null : r.GetByte(50);
                        resp.Ra1Assessment.AttrResponsibility = r.IsDBNull(51) ? (byte?)null : r.GetByte(51);
                        resp.Ra1Assessment.AttrStability = r.IsDBNull(52) ? (byte?)null : r.GetByte(52);
                        resp.Ra1Assessment.AttrCommunication = r.IsDBNull(53) ? (byte?)null : r.GetByte(53);
                        resp.Ra1Assessment.AttrMoralCourage = r.IsDBNull(54) ? (byte?)null : r.GetByte(54);
                        resp.Ra1Assessment.AttrLeadership = r.IsDBNull(55) ? (byte?)null : r.GetByte(55);
                        resp.Ra1Assessment.AttrTimeliness = r.IsDBNull(56) ? (byte?)null : r.GetByte(56);
                        resp.Ra1Assessment.AttrOverall = r.IsDBNull(57) ? (decimal?)null : r.GetDecimal(57);
                        resp.Ra1Assessment.CompKnowledge = r.IsDBNull(58) ? (byte?)null : r.GetByte(58);
                        resp.Ra1Assessment.CompPlanning = r.IsDBNull(59) ? (byte?)null : r.GetByte(59);
                        resp.Ra1Assessment.CompDecision = r.IsDBNull(60) ? (byte?)null : r.GetByte(60);
                        resp.Ra1Assessment.CompInitiative = r.IsDBNull(61) ? (byte?)null : r.GetByte(61);
                        resp.Ra1Assessment.CompTeamwork = r.IsDBNull(62) ? (byte?)null : r.GetByte(62);
                        resp.Ra1Assessment.CompOverall = r.IsDBNull(63) ? (decimal?)null : r.GetDecimal(63);
                        resp.Ra1Assessment.OverallGrade = r.IsDBNull(64) ? (decimal?)null : r.GetDecimal(64);
                    }

                    // ── RA2 assessment (65-88) — A1b only ────────────────────
                    // col 66 = ra2_agree_with_self (presence proxy)
                    resp.Ra2Assessment.Exists = isA1b && hasRa && !r.IsDBNull(66);
                    if (resp.Ra2Assessment.Exists)
                    {
                        DateTime? ra2Sub = r.IsDBNull(65) ? (DateTime?)null : r.GetDateTime(65);
                        resp.Ra2Assessment.IsSubmitted = ra2Sub.HasValue;
                        resp.Ra2Assessment.SubmittedAt = ra2Sub?.ToString("o");
                        resp.Ra2Assessment.AgreeWithSelf = r.IsDBNull(66) ? (bool?)null : r.GetBoolean(66);
                        resp.Ra2Assessment.DisagreeDetails = r.IsDBNull(67) ? null : r.GetString(67);
                        resp.Ra2Assessment.IntegrityComments = r.IsDBNull(68) ? null : r.GetString(68);
                        resp.Ra2Assessment.Remarks = r.IsDBNull(69) ? null : r.GetString(69);
                        resp.Ra2Assessment.WorkTargets = r.IsDBNull(70) ? (byte?)null : r.GetByte(70);
                        resp.Ra2Assessment.WorkQuality = r.IsDBNull(71) ? (byte?)null : r.GetByte(71);
                        resp.Ra2Assessment.WorkExceptional = r.IsDBNull(72) ? (byte?)null : r.GetByte(72);
                        resp.Ra2Assessment.WorkOverall = r.IsDBNull(73) ? (decimal?)null : r.GetDecimal(73);
                        resp.Ra2Assessment.AttrAttitude = r.IsDBNull(74) ? (byte?)null : r.GetByte(74);
                        resp.Ra2Assessment.AttrResponsibility = r.IsDBNull(75) ? (byte?)null : r.GetByte(75);
                        resp.Ra2Assessment.AttrStability = r.IsDBNull(76) ? (byte?)null : r.GetByte(76);
                        resp.Ra2Assessment.AttrCommunication = r.IsDBNull(77) ? (byte?)null : r.GetByte(77);
                        resp.Ra2Assessment.AttrMoralCourage = r.IsDBNull(78) ? (byte?)null : r.GetByte(78);
                        resp.Ra2Assessment.AttrLeadership = r.IsDBNull(79) ? (byte?)null : r.GetByte(79);
                        resp.Ra2Assessment.AttrTimeliness = r.IsDBNull(80) ? (byte?)null : r.GetByte(80);
                        resp.Ra2Assessment.AttrOverall = r.IsDBNull(81) ? (decimal?)null : r.GetDecimal(81);
                        resp.Ra2Assessment.CompKnowledge = r.IsDBNull(82) ? (byte?)null : r.GetByte(82);
                        resp.Ra2Assessment.CompPlanning = r.IsDBNull(83) ? (byte?)null : r.GetByte(83);
                        resp.Ra2Assessment.CompDecision = r.IsDBNull(84) ? (byte?)null : r.GetByte(84);
                        resp.Ra2Assessment.CompInitiative = r.IsDBNull(85) ? (byte?)null : r.GetByte(85);
                        resp.Ra2Assessment.CompTeamwork = r.IsDBNull(86) ? (byte?)null : r.GetByte(86);
                        resp.Ra2Assessment.CompOverall = r.IsDBNull(87) ? (decimal?)null : r.GetDecimal(87);
                        resp.Ra2Assessment.OverallGrade = r.IsDBNull(88) ? (decimal?)null : r.GetDecimal(88);
                    }

                    // ── rva_* override grades (89-103) ───────────────────────
                    resp.RvaOverrideGrades.WorkTargets = r.IsDBNull(89) ? (byte?)null : r.GetByte(89);
                    resp.RvaOverrideGrades.WorkQuality = r.IsDBNull(90) ? (byte?)null : r.GetByte(90);
                    resp.RvaOverrideGrades.WorkExceptional = r.IsDBNull(91) ? (byte?)null : r.GetByte(91);
                    resp.RvaOverrideGrades.AttrAttitude = r.IsDBNull(92) ? (byte?)null : r.GetByte(92);
                    resp.RvaOverrideGrades.AttrResponsibility = r.IsDBNull(93) ? (byte?)null : r.GetByte(93);
                    resp.RvaOverrideGrades.AttrStability = r.IsDBNull(94) ? (byte?)null : r.GetByte(94);
                    resp.RvaOverrideGrades.AttrCommunication = r.IsDBNull(95) ? (byte?)null : r.GetByte(95);
                    resp.RvaOverrideGrades.AttrMoralCourage = r.IsDBNull(96) ? (byte?)null : r.GetByte(96);
                    resp.RvaOverrideGrades.AttrLeadership = r.IsDBNull(97) ? (byte?)null : r.GetByte(97);
                    resp.RvaOverrideGrades.AttrTimeliness = r.IsDBNull(98) ? (byte?)null : r.GetByte(98);
                    resp.RvaOverrideGrades.CompKnowledge = r.IsDBNull(99) ? (byte?)null : r.GetByte(99);
                    resp.RvaOverrideGrades.CompPlanning = r.IsDBNull(100) ? (byte?)null : r.GetByte(100);
                    resp.RvaOverrideGrades.CompDecision = r.IsDBNull(101) ? (byte?)null : r.GetByte(101);
                    resp.RvaOverrideGrades.CompInitiative = r.IsDBNull(102) ? (byte?)null : r.GetByte(102);
                    resp.RvaOverrideGrades.CompTeamwork = r.IsDBNull(103) ? (byte?)null : r.GetByte(103);

                    // ── Reviewing assessment (104-109) ───────────────────────
                    bool hasRv = !r.IsDBNull(104);
                    resp.ReviewingAssessment.Exists = hasRv;
                    if (hasRv)
                    {
                        DateTime? rvSub = r.IsDBNull(109) ? (DateTime?)null : r.GetDateTime(109);
                        resp.ReviewingAssessment.IsSubmitted = rvSub.HasValue;
                        resp.ReviewingAssessment.SubmittedAt = rvSub?.ToString("o");
                        resp.ReviewingAssessment.AgreeWithRa = r.IsDBNull(105) ? (bool?)null : r.GetBoolean(105);
                        resp.ReviewingAssessment.DisagreeDetails = r.IsDBNull(106) ? null : r.GetString(106);
                        resp.ReviewingAssessment.Comments = r.IsDBNull(107) ? null : r.GetString(107);
                        resp.ReviewingAssessment.OverallGrade = r.IsDBNull(108) ? (decimal?)null : r.GetDecimal(108);
                    }

                    // ── Accepting decision (110-117) — NEW ───────────────────
                    bool hasAd = !r.IsDBNull(110);
                    resp.Decision.Exists = hasAd;
                    if (hasAd)
                    {
                        DateTime? decidedAt = r.IsDBNull(117) ? (DateTime?)null : r.GetDateTime(117);
                        resp.Decision.IsDecided = decidedAt.HasValue;
                        resp.Decision.DecidedAt = decidedAt?.ToString("o");
                        resp.Decision.AgreeWithPrevious = r.IsDBNull(111) ? (bool?)null : r.GetBoolean(111);
                        resp.Decision.DisagreeDetails = r.IsDBNull(112) ? null : r.GetString(112);
                        resp.Decision.ConflictResolved = !r.IsDBNull(113) && r.GetBoolean(113);
                        resp.Decision.FinalGrade = r.IsDBNull(114) ? (decimal?)null : r.GetDecimal(114);
                        resp.Decision.FinalRemarks = r.IsDBNull(115) ? null : r.GetString(115);
                        resp.Decision.IsApproved = r.IsDBNull(116) ? (bool?)null : r.GetBoolean(116);
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