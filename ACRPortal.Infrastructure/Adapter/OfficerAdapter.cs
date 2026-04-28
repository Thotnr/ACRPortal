using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class OfficerAdapter : IOfficerRepoPort
    {
        private const string YesValue = "Yes";
        private const string NoValue = "No";
        private const string NaValue = "NA";

        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        private static string ReadTriState(SqlDataReader reader, int ordinal)
        {
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static string NormalizeTriState(string value, string fieldName)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException(fieldName + " is required.", fieldName);

            switch (value.Trim().ToUpperInvariant())
            {
                case "YES":
                case "Y":
                case "TRUE":
                case "1":
                    return YesValue;

                case "NO":
                case "N":
                case "FALSE":
                case "0":
                    return NoValue;

                case "NA":
                case "N/A":
                    return NaValue;

                default:
                    throw new ArgumentException(
                        fieldName + " must be one of Yes, No, or NA.",
                        fieldName);
            }
        }

        // ================================================================== //
        //  GetMyAcrs                                                          //
        // ================================================================== //
        public PagedResult<MyAcrListItem> GetMyAcrs(Guid officerUserId, string status, int pageNumber, int pageSize)
        {
            string statusFilter = string.IsNullOrWhiteSpace(status) ? null : status.Trim().ToUpper();

            string sql = @"
        SELECT COUNT(1)
        FROM dbo.acr_cycles ac
        WHERE ac.officer_user_id = @uid
          AND ac.status <> 'DRAFT' " +
                (statusFilter != null ? " AND ac.status = @status " : "") +

                @";

        SELECT  ac.acr_id,
                ac.form_type,
                ac.department,
                ac.location,
                d.dsg,
                ac.posting_from,
                ac.posting_to,
                ac.acr_year,
                ac.status,
                ac.created_at,
                sa.submitted_at
        FROM dbo.acr_cycles ac
        LEFT JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
        LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
        WHERE ac.officer_user_id = @uid
          AND ac.status <> 'DRAFT' " +
                (statusFilter != null ? " AND ac.status = @status " : "") +

                @"
        ORDER BY ac.created_at DESC
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    ";

            var resp = new PagedResult<MyAcrListItem>
            {
                PageNumber = pageNumber,
                PageSize = pageSize
            };

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = officerUserId;
                cmd.Parameters.Add("@offset", SqlDbType.Int).Value = (pageNumber - 1) * pageSize;
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize;

                if (statusFilter != null)
                    cmd.Parameters.Add("@status", SqlDbType.VarChar).Value = statusFilter;

                con.Open();

                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                        resp.TotalCount = r.GetInt32(0);

                    r.NextResult();

                    while (r.Read())
                    {
                        resp.Items.Add(new MyAcrListItem
                        {
                            AcrId = r.GetGuid(0).ToString(),
                            FormType = r.IsDBNull(1) ? null : r.GetString(1),
                            Department = r.IsDBNull(2) ? null : r.GetString(2),
                            Location = r.IsDBNull(3) ? null : r.GetString(3),
                            Dsg = r.IsDBNull(4) ? null : r.GetString(4),
                            PostingFrom = r.IsDBNull(5) ? null : r.GetDateTime(5).ToString("yyyy-MM-dd"),
                            PostingTo = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                            AcrYear = r.IsDBNull(7) ? 0 : r.GetInt32(7),
                            Status = r.IsDBNull(8) ? null : r.GetString(8),
                            CreatedAt = r.IsDBNull(9) ? null : r.GetDateTime(9).ToString("o"),
                            SelfAppraisalSubmitted = !r.IsDBNull(10)
                        });
                    }
                }
            }

            resp.TotalPages = (int)Math.Ceiling((double)resp.TotalCount / pageSize);

            return resp;
        }

        // ================================================================== //
        //  GetAcrDetail — full shape, all sections                           //
        //                                                                    //
        //  Column index map:                                                 //
        //                                                                    //
        //  ACR header + officer (0-11)                                       //
        //   0  acr_id       4  location      8  acr_year                    //
        //   1  form_type    5  dsg           9  officer user_id              //
        //   2  status       6  posting_from  10 officer login_id             //
        //   3  department   7  posting_to    11 officer display_name         //
        //                                                                    //
        //  Section I CCA fields (12-21)                                      //
        //  12 date_of_birth              17 technical_qual                   //
        //  13 date_joining_nigam         18 dept_exam_passed                 //
        //  14 date_joining_present_rank  19 property_return_date             //
        //  15 date_joining_present_stn   20 last_medical_exam_date           //
        //  16 academic_qual              21 career_posting_summary           //
        //                                                                    //
        //  Self-appraisal (22-37)                                            //
        //  22 appraisal_id  29 major_achievements  35 property_decl_date    //
        //  23 submitted_at  30 membership_bodies   36 medical_compliance     //
        //  24 leave_details 31 training_details    37 medical_comp_date      //
        //  25 duties_desc   32 awards_honours                                //
        //  26 targets_set   33 auditor_compliance                            //
        //  27 targets_ach   34 property_declared                             //
        //  28 shortfall                                                       //
        //                                                                    //
        //  RA assessment: id + RA1 (38-62)                                   //
        //  38 assessment_id  39 ra1_submitted  40-62 RA1 23 fields           //
        //                                                                    //
        //  RA2 block (63-86)                                                 //
        //  63 ra2_submitted  64-86 RA2 23 fields                             //
        //                                                                    //
        //  rva_* overrides (87-101)                                          //
        //                                                                    //
        //  reviewing_assessments (102-107)                                   //
        //  102 review_id  103 agree_with_ra  104 disagree_details            //
        //  105 remarks    106 final_grade    107 submitted_at                //
        //                                                                    //
        //  accepting_decisions (108-115)                                     //
        //  108 decision_id        112 final_grade                            //
        //  109 agree_with_prev    113 final_remarks                          //
        //  110 disagree_details   114 is_approved                            //
        //  111 conflict_resolved  115 decided_at                             //
        // ================================================================== //
        public AcrDetailResponse GetAcrDetail(Guid acrId, Guid officerUserId)
        {
            const string sql = @"
                SELECT
                    -- ACR header (0-11)
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

                    -- Section I CCA fields (12-21)
                    ac.date_of_birth,
                    ac.date_joining_nigam,
                    ac.date_joining_present_rank,
                    ac.date_joining_present_station,
                    ac.academic_qualification,
                    ac.technical_qualification,
                    ac.departmental_exam_passed,
                    ac.property_return_date,
                    ac.last_medical_exam_date,
                    ac.career_posting_summary,

                    -- Self-appraisal (22-37)
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

                    -- RA assessment: id + RA1 block (38-62)
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

                    -- RA2 block (63-86)
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

                    -- rva_* overrides (87-101)
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

                    -- reviewing_assessments (102-107)
                    rv.review_id,
                    rv.agree_with_ra,
                    rv.disagree_details,
                    rv.remarks,
                    rv.final_grade,
                    rv.submitted_at,

                    -- accepting_decisions (108-115)
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
                    rv.is_skipped

                FROM dbo.acr_cycles ac
                JOIN dbo.users u ON u.user_id = ac.officer_user_id
                LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
                LEFT JOIN dbo.self_appraisals       sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
                LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
                LEFT JOIN dbo.accepting_decisions   ad ON ad.acr_id = ac.acr_id
                WHERE ac.acr_id          = @acrId
                  AND ac.officer_user_id = @uid
                  AND ac.status         <> 'DRAFT'";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = officerUserId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return null;

                    bool isA1b = string.Equals(
                        r.IsDBNull(1) ? null : r.GetString(1),
                        "A1b", StringComparison.OrdinalIgnoreCase);

                    var resp = new AcrDetailResponse
                    {
                        AcrId = r.GetGuid(0).ToString(),
                        FormType = r.IsDBNull(1) ? null : r.GetString(1),
                        Status = r.IsDBNull(2) ? null : r.GetString(2),
                        Department = r.IsDBNull(3) ? null : r.GetString(3),
                        Location = r.IsDBNull(4) ? null : r.GetString(4),
                        Dsg = r.IsDBNull(5) ? null : r.GetString(5),
                        PostingFrom = r.IsDBNull(6) ? null : r.GetDateTime(6).ToString("yyyy-MM-dd"),
                        PostingTo = r.IsDBNull(7) ? null : r.GetDateTime(7).ToString("yyyy-MM-dd"),
                        AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8),
                        DateOfBirth = r.IsDBNull(12) ? null : r.GetDateTime(12).ToString("yyyy-MM-dd"),
                        DateJoiningNigam = r.IsDBNull(13) ? null : r.GetDateTime(13).ToString("yyyy-MM-dd"),
                        DateJoiningPresentRank = r.IsDBNull(14) ? null : r.GetDateTime(14).ToString("yyyy-MM-dd"),
                        DateJoiningPresentStation = r.IsDBNull(15) ? null : r.GetDateTime(15).ToString("yyyy-MM-dd"),
                        AcademicQualification = r.IsDBNull(16) ? null : r.GetString(16),
                        TechnicalQualification = r.IsDBNull(17) ? null : r.GetString(17),
                        DepartmentalExamPassed = r.IsDBNull(18) ? null : r.GetString(18),
                        PropertyReturnDate = r.IsDBNull(19) ? null : r.GetDateTime(19).ToString("yyyy-MM-dd"),
                        LastMedicalExamDate = r.IsDBNull(20) ? null : r.GetDateTime(20).ToString("yyyy-MM-dd"),
                        CareerPostingSummary = r.IsDBNull(21) ? null : r.GetString(21),
                    };

                    resp.Officer.UserId = r.GetGuid(9).ToString();
                    resp.Officer.LoginId = r.IsDBNull(10) ? null : r.GetString(10);
                    resp.Officer.DisplayName = r.IsDBNull(11) ? null : r.GetString(11);

                    // ── Self-appraisal (22-37) ──────────────────────────────
                    bool hasSelf = !r.IsDBNull(22);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? submittedAt = r.IsDBNull(23) ? (DateTime?)null : r.GetDateTime(23);
                        resp.SelfAppraisal.IsSkipped = r.IsDBNull(116) ? (bool?)false : r.GetBoolean(116);
                        resp.SelfAppraisal.IsSubmitted = submittedAt.HasValue;
                        resp.SelfAppraisal.SubmittedAt = submittedAt?.ToString("o");
                        resp.SelfAppraisal.LeaveDetails = r.IsDBNull(24) ? null : r.GetString(24);
                        resp.SelfAppraisal.DutiesDescription = r.IsDBNull(25) ? null : r.GetString(25);
                        resp.SelfAppraisal.TargetsSet = r.IsDBNull(26) ? null : r.GetString(26);
                        resp.SelfAppraisal.TargetsAchieved = r.IsDBNull(27) ? null : r.GetString(27);
                        resp.SelfAppraisal.ShortfallReasons = r.IsDBNull(28) ? null : r.GetString(28);
                        resp.SelfAppraisal.MajorAchievements = r.IsDBNull(29) ? null : r.GetString(29);
                        resp.SelfAppraisal.MembershipBodies = r.IsDBNull(30) ? null : r.GetString(30);
                        resp.SelfAppraisal.TrainingDetails = r.IsDBNull(31) ? null : r.GetString(31);
                        resp.SelfAppraisal.AwardsHonours = r.IsDBNull(32) ? null : r.GetString(32);
                        resp.SelfAppraisal.AuditorCompliance = r.IsDBNull(33) ? (bool?)null : r.GetBoolean(33);
                        resp.SelfAppraisal.PropertyDeclared = ReadTriState(r, 34);
                        resp.SelfAppraisal.PropertyDeclaredDate = r.IsDBNull(35) ? null : r.GetDateTime(35).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.MedicalCompliance = ReadTriState(r, 36);
                        resp.SelfAppraisal.MedicalComplianceDate = r.IsDBNull(37) ? null : r.GetDateTime(37).ToString("yyyy-MM-dd");
                    }

                    // ── RA1 assessment (38-62) ───────────────────────────────
                    bool hasRa = !r.IsDBNull(38);
                    resp.Ra1Assessment.Exists = hasRa;
                    if (hasRa)
                    {
                        DateTime? ra1Sub = r.IsDBNull(39) ? (DateTime?)null : r.GetDateTime(39);
                        resp.Ra1Assessment.IsSkipped = r.IsDBNull(117) ? (bool?)false : r.GetBoolean(117);
                        resp.Ra1Assessment.IsSubmitted = ra1Sub.HasValue;
                        resp.Ra1Assessment.SubmittedAt = ra1Sub?.ToString("o");
                        resp.Ra1Assessment.AgreeWithSelf = r.IsDBNull(40) ? (bool?)null : r.GetBoolean(40);
                        resp.Ra1Assessment.DisagreeDetails = r.IsDBNull(41) ? null : r.GetString(41);
                        resp.Ra1Assessment.IntegrityComments = r.IsDBNull(42) ? null : r.GetString(42);
                        resp.Ra1Assessment.Remarks = r.IsDBNull(43) ? null : r.GetString(43);
                        resp.Ra1Assessment.WorkTargets = r.IsDBNull(44) ? (byte?)null : r.GetByte(44);
                        resp.Ra1Assessment.WorkQuality = r.IsDBNull(45) ? (byte?)null : r.GetByte(45);
                        resp.Ra1Assessment.WorkExceptional = r.IsDBNull(46) ? (byte?)null : r.GetByte(46);
                        resp.Ra1Assessment.WorkOverall = r.IsDBNull(47) ? (decimal?)null : r.GetDecimal(47);
                        resp.Ra1Assessment.AttrAttitude = r.IsDBNull(48) ? (byte?)null : r.GetByte(48);
                        resp.Ra1Assessment.AttrResponsibility = r.IsDBNull(49) ? (byte?)null : r.GetByte(49);
                        resp.Ra1Assessment.AttrStability = r.IsDBNull(50) ? (byte?)null : r.GetByte(50);
                        resp.Ra1Assessment.AttrCommunication = r.IsDBNull(51) ? (byte?)null : r.GetByte(51);
                        resp.Ra1Assessment.AttrMoralCourage = r.IsDBNull(52) ? (byte?)null : r.GetByte(52);
                        resp.Ra1Assessment.AttrLeadership = r.IsDBNull(53) ? (byte?)null : r.GetByte(53);
                        resp.Ra1Assessment.AttrTimeliness = r.IsDBNull(54) ? (byte?)null : r.GetByte(54);
                        resp.Ra1Assessment.AttrOverall = r.IsDBNull(55) ? (decimal?)null : r.GetDecimal(55);
                        resp.Ra1Assessment.CompKnowledge = r.IsDBNull(56) ? (byte?)null : r.GetByte(56);
                        resp.Ra1Assessment.CompPlanning = r.IsDBNull(57) ? (byte?)null : r.GetByte(57);
                        resp.Ra1Assessment.CompDecision = r.IsDBNull(58) ? (byte?)null : r.GetByte(58);
                        resp.Ra1Assessment.CompInitiative = r.IsDBNull(59) ? (byte?)null : r.GetByte(59);
                        resp.Ra1Assessment.CompTeamwork = r.IsDBNull(60) ? (byte?)null : r.GetByte(60);
                        resp.Ra1Assessment.CompOverall = r.IsDBNull(61) ? (decimal?)null : r.GetDecimal(61);
                        resp.Ra1Assessment.OverallGrade = r.IsDBNull(62) ? (decimal?)null : r.GetDecimal(62);
                    }

                    // ── RA2 assessment (63-86) — A1b only ───────────────────
                    // col 64 = ra2_agree_with_self (presence proxy)
                    resp.Ra2Assessment.Exists = isA1b && hasRa && !r.IsDBNull(64);
                    if (resp.Ra2Assessment.Exists)
                    {
                        DateTime? ra2Sub = r.IsDBNull(63) ? (DateTime?)null : r.GetDateTime(63);
                        resp.Ra2Assessment.IsSkipped = r.IsDBNull(117) ? (bool?)false : r.GetBoolean(117);
                        resp.Ra2Assessment.IsSubmitted = ra2Sub.HasValue;
                        resp.Ra2Assessment.SubmittedAt = ra2Sub?.ToString("o");
                        resp.Ra2Assessment.AgreeWithSelf = r.IsDBNull(64) ? (bool?)null : r.GetBoolean(64);
                        resp.Ra2Assessment.DisagreeDetails = r.IsDBNull(65) ? null : r.GetString(65);
                        resp.Ra2Assessment.IntegrityComments = r.IsDBNull(66) ? null : r.GetString(66);
                        resp.Ra2Assessment.Remarks = r.IsDBNull(67) ? null : r.GetString(67);
                        resp.Ra2Assessment.WorkTargets = r.IsDBNull(68) ? (byte?)null : r.GetByte(68);
                        resp.Ra2Assessment.WorkQuality = r.IsDBNull(69) ? (byte?)null : r.GetByte(69);
                        resp.Ra2Assessment.WorkExceptional = r.IsDBNull(70) ? (byte?)null : r.GetByte(70);
                        resp.Ra2Assessment.WorkOverall = r.IsDBNull(71) ? (decimal?)null : r.GetDecimal(71);
                        resp.Ra2Assessment.AttrAttitude = r.IsDBNull(72) ? (byte?)null : r.GetByte(72);
                        resp.Ra2Assessment.AttrResponsibility = r.IsDBNull(73) ? (byte?)null : r.GetByte(73);
                        resp.Ra2Assessment.AttrStability = r.IsDBNull(74) ? (byte?)null : r.GetByte(74);
                        resp.Ra2Assessment.AttrCommunication = r.IsDBNull(75) ? (byte?)null : r.GetByte(75);
                        resp.Ra2Assessment.AttrMoralCourage = r.IsDBNull(76) ? (byte?)null : r.GetByte(76);
                        resp.Ra2Assessment.AttrLeadership = r.IsDBNull(77) ? (byte?)null : r.GetByte(77);
                        resp.Ra2Assessment.AttrTimeliness = r.IsDBNull(78) ? (byte?)null : r.GetByte(78);
                        resp.Ra2Assessment.AttrOverall = r.IsDBNull(79) ? (decimal?)null : r.GetDecimal(79);
                        resp.Ra2Assessment.CompKnowledge = r.IsDBNull(80) ? (byte?)null : r.GetByte(80);
                        resp.Ra2Assessment.CompPlanning = r.IsDBNull(81) ? (byte?)null : r.GetByte(81);
                        resp.Ra2Assessment.CompDecision = r.IsDBNull(82) ? (byte?)null : r.GetByte(82);
                        resp.Ra2Assessment.CompInitiative = r.IsDBNull(83) ? (byte?)null : r.GetByte(83);
                        resp.Ra2Assessment.CompTeamwork = r.IsDBNull(84) ? (byte?)null : r.GetByte(84);
                        resp.Ra2Assessment.CompOverall = r.IsDBNull(85) ? (decimal?)null : r.GetDecimal(85);
                        resp.Ra2Assessment.OverallGrade = r.IsDBNull(86) ? (decimal?)null : r.GetDecimal(86);
                    }

                    // ── rva_* override grades (87-101) ──────────────────────
                    resp.RvaOverrideGrades.WorkTargets = r.IsDBNull(87) ? (byte?)null : r.GetByte(87);
                    resp.RvaOverrideGrades.WorkQuality = r.IsDBNull(88) ? (byte?)null : r.GetByte(88);
                    resp.RvaOverrideGrades.WorkExceptional = r.IsDBNull(89) ? (byte?)null : r.GetByte(89);
                    resp.RvaOverrideGrades.AttrAttitude = r.IsDBNull(90) ? (byte?)null : r.GetByte(90);
                    resp.RvaOverrideGrades.AttrResponsibility = r.IsDBNull(91) ? (byte?)null : r.GetByte(91);
                    resp.RvaOverrideGrades.AttrStability = r.IsDBNull(92) ? (byte?)null : r.GetByte(92);
                    resp.RvaOverrideGrades.AttrCommunication = r.IsDBNull(93) ? (byte?)null : r.GetByte(93);
                    resp.RvaOverrideGrades.AttrMoralCourage = r.IsDBNull(94) ? (byte?)null : r.GetByte(94);
                    resp.RvaOverrideGrades.AttrLeadership = r.IsDBNull(95) ? (byte?)null : r.GetByte(95);
                    resp.RvaOverrideGrades.AttrTimeliness = r.IsDBNull(96) ? (byte?)null : r.GetByte(96);
                    resp.RvaOverrideGrades.CompKnowledge = r.IsDBNull(97) ? (byte?)null : r.GetByte(97);
                    resp.RvaOverrideGrades.CompPlanning = r.IsDBNull(98) ? (byte?)null : r.GetByte(98);
                    resp.RvaOverrideGrades.CompDecision = r.IsDBNull(99) ? (byte?)null : r.GetByte(99);
                    resp.RvaOverrideGrades.CompInitiative = r.IsDBNull(100) ? (byte?)null : r.GetByte(100);
                    resp.RvaOverrideGrades.CompTeamwork = r.IsDBNull(101) ? (byte?)null : r.GetByte(101);

                    // ── Reviewing assessment (102-107) ───────────────────────
                    bool hasRv = !r.IsDBNull(102);
                    resp.ReviewingAssessment.Exists = hasRv;
                    if (hasRv)
                    {
                        DateTime? rvSub = r.IsDBNull(107) ? (DateTime?)null : r.GetDateTime(107);
                        resp.ReviewingAssessment.IsSkipped = r.IsDBNull(118) ? (bool?)false : r.GetBoolean(118);
                        resp.ReviewingAssessment.IsSubmitted = rvSub.HasValue;
                        resp.ReviewingAssessment.SubmittedAt = rvSub?.ToString("o");
                        resp.ReviewingAssessment.AgreeWithRa = r.IsDBNull(103) ? (bool?)null : r.GetBoolean(103);
                        resp.ReviewingAssessment.DisagreeDetails = r.IsDBNull(104) ? null : r.GetString(104);
                        resp.ReviewingAssessment.Comments = r.IsDBNull(105) ? null : r.GetString(105);
                        resp.ReviewingAssessment.OverallGrade = r.IsDBNull(106) ? (decimal?)null : r.GetDecimal(106);
                    }

                    // ── Accepting decision (108-115) ─────────────────────────
                    bool hasAd = !r.IsDBNull(108);
                    resp.Decision.Exists = hasAd;
                    if (hasAd)
                    {
                        DateTime? decidedAt = r.IsDBNull(115) ? (DateTime?)null : r.GetDateTime(115);
                        resp.Decision.IsDecided = decidedAt.HasValue;
                        resp.Decision.DecidedAt = decidedAt?.ToString("o");
                        resp.Decision.AgreeWithPrevious = r.IsDBNull(109) ? (bool?)null : r.GetBoolean(109);
                        resp.Decision.DisagreeDetails = r.IsDBNull(110) ? null : r.GetString(110);
                        resp.Decision.ConflictResolved = !r.IsDBNull(111) && r.GetBoolean(111);
                        resp.Decision.FinalGrade = r.IsDBNull(112) ? (decimal?)null : r.GetDecimal(112);
                        resp.Decision.FinalRemarks = r.IsDBNull(113) ? null : r.GetString(113);
                        resp.Decision.IsApproved = r.IsDBNull(114) ? (bool?)null : r.GetBoolean(114);
                    }

                    return resp;
                }
            }
        }

        // ================================================================== //
        //  LoadDocuments  (called by OfficerService after GetAcrDetail)       //
        //  Kept as a separate method so the main query stays focused.         //
        //  The service layer calls DocumentAdapter.GetDocuments instead —     //
        //  OfficerAdapter does NOT duplicate document fetching.               //
        //  The AcrDetailResponse.Documents list is populated in               //
        //  OfficerService.GetAcrDetail by injecting IDocumentRepoPort.        //
        // ================================================================== //

        // ================================================================== //
        //  TryUpsertSelfAppraisalDraft                                        //
        // ================================================================== //
        public bool TryUpsertSelfAppraisalDraft(
            Guid acrId, Guid officerUserId,
            SelfAppraisalDraftRequest request, out string errorCode)
        {
            // 1) Verify ACR ownership + state
            const string acrCheck = "SELECT officer_user_id, status FROM dbo.acr_cycles WHERE acr_id = @acrId";

            Guid owner;
            string status;

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(acrCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }
                    owner = r.GetGuid(0);
                    status = r.IsDBNull(1) ? null : r.GetString(1);
                }
            }

            if (owner != officerUserId) { errorCode = "FORBIDDEN"; return false; }
            if (!string.Equals(status, "PENDING_OFFICER", StringComparison.OrdinalIgnoreCase))
            { errorCode = "INVALID_STATE"; return false; }

            // 2) Block if already submitted
            const string submittedCheck = "SELECT submitted_at FROM dbo.self_appraisals WHERE acr_id = @acrId";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(submittedCheck, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                var val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value) { errorCode = "ALREADY_SUBMITTED"; return false; }
            }

            string propertyDeclared = NormalizeTriState(request.PropertyDeclared, nameof(request.PropertyDeclared));
            string medicalCompliance = NormalizeTriState(request.MedicalCompliance, nameof(request.MedicalCompliance));

            // 3) Parse optional date fields
            DateTime? propDeclaredDate = null;
            if (!string.IsNullOrWhiteSpace(request.PropertyDeclaredDate) &&
                DateTime.TryParse(request.PropertyDeclaredDate, out DateTime pdd))
                propDeclaredDate = pdd.Date;

            DateTime? medComplianceDate = null;
            if (!string.IsNullOrWhiteSpace(request.MedicalComplianceDate) &&
                DateTime.TryParse(request.MedicalComplianceDate, out DateTime mcd))
                medComplianceDate = mcd.Date;

            // 4) Upsert draft — document_path column removed
            const string upsert = @"
                MERGE dbo.self_appraisals AS target
                USING (SELECT @acrId AS acr_id) AS src
                   ON target.acr_id = src.acr_id
                WHEN MATCHED THEN
                    UPDATE SET
                        leave_details           = @leaveDetails,
                        duties_description      = @duties,
                        targets_set             = @targetsSet,
                        targets_achieved        = @targetsAchieved,
                        shortfall_reasons       = @shortfall,
                        major_achievements      = @majorAchievements,
                        membership_bodies       = @membership,
                        training_details        = @training,
                        awards_honours          = @awards,
                        auditor_compliance      = @auditor,
                        property_declared       = @propDeclared,
                        property_declared_date  = @propDeclaredDate,
                        medical_compliance      = @medical,
                        medical_compliance_date = @medComplianceDate,
                        submitted_at            = NULL
                WHEN NOT MATCHED THEN
                    INSERT (
                        appraisal_id, acr_id,
                        leave_details,
                        duties_description, targets_set, targets_achieved, shortfall_reasons,
                        major_achievements, membership_bodies, training_details, awards_honours,
                        auditor_compliance,
                        property_declared, property_declared_date,
                        medical_compliance, medical_compliance_date,
                        submitted_at, created_at
                    )
                    VALUES (
                        NEWID(), @acrId,
                        @leaveDetails,
                        @duties, @targetsSet, @targetsAchieved, @shortfall,
                        @majorAchievements, @membership, @training, @awards,
                        @auditor,
                        @propDeclared, @propDeclaredDate,
                        @medical, @medComplianceDate,
                        NULL, GETDATE()
                    );";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(upsert, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@leaveDetails", SqlDbType.NVarChar).Value = (object)request.LeaveDetails ?? DBNull.Value;
                cmd.Parameters.Add("@duties", SqlDbType.NVarChar).Value = (object)request.DutiesDescription ?? DBNull.Value;
                cmd.Parameters.Add("@targetsSet", SqlDbType.NVarChar).Value = (object)request.TargetsSet ?? DBNull.Value;
                cmd.Parameters.Add("@targetsAchieved", SqlDbType.NVarChar).Value = (object)request.TargetsAchieved ?? DBNull.Value;
                cmd.Parameters.Add("@shortfall", SqlDbType.NVarChar).Value = (object)request.ShortfallReasons ?? DBNull.Value;
                cmd.Parameters.Add("@majorAchievements", SqlDbType.NVarChar).Value = (object)request.MajorAchievements ?? DBNull.Value;
                cmd.Parameters.Add("@membership", SqlDbType.NVarChar).Value = (object)request.MembershipBodies ?? DBNull.Value;
                cmd.Parameters.Add("@training", SqlDbType.NVarChar).Value = (object)request.TrainingDetails ?? DBNull.Value;
                cmd.Parameters.Add("@awards", SqlDbType.NVarChar).Value = (object)request.AwardsHonours ?? DBNull.Value;

                cmd.Parameters.Add("@auditor", SqlDbType.Bit).Value =
                    request.AuditorCompliance.HasValue
                        ? (object)(request.AuditorCompliance.Value ? 1 : 0)
                        : DBNull.Value;

                cmd.Parameters.Add("@propDeclared", SqlDbType.VarChar, 3).Value = propertyDeclared;
                cmd.Parameters.Add("@propDeclaredDate", SqlDbType.Date).Value = (object)propDeclaredDate ?? DBNull.Value;
                cmd.Parameters.Add("@medical", SqlDbType.VarChar, 3).Value = medicalCompliance;
                cmd.Parameters.Add("@medComplianceDate", SqlDbType.Date).Value = (object)medComplianceDate ?? DBNull.Value;

                con.Open();
                cmd.ExecuteNonQuery();
            }

            errorCode = null;
            return true;
        }

        // ================================================================== //
        //  TrySubmitSelfAppraisal                                             //
        // ================================================================== //
        public bool TrySubmitSelfAppraisal(Guid acrId, Guid officerUserId, out string errorCode)
        {
            using (var con = new SqlConnection(_conn))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    // 1) Verify ACR ownership + state
                    const string acrCheck = @"
                        SELECT officer_user_id, status
                        FROM   dbo.acr_cycles
                        WHERE  acr_id = @acrId";

                    Guid owner;
                    string status;

                    using (var cmd = new SqlCommand(acrCheck, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { tx.Rollback(); errorCode = "NOT_FOUND"; return false; }
                            owner = r.GetGuid(0);
                            status = r.IsDBNull(1) ? null : r.GetString(1);
                        }
                    }

                    if (owner != officerUserId)
                    { tx.Rollback(); errorCode = "FORBIDDEN"; return false; }

                    if (!string.Equals(status, "PENDING_OFFICER", StringComparison.OrdinalIgnoreCase))
                    { tx.Rollback(); errorCode = "INVALID_STATE"; return false; }

                    // 2) Ensure self-appraisal exists and not already submitted
                    const string selfCheck = @"
                        SELECT submitted_at FROM dbo.self_appraisals WHERE acr_id = @acrId";

                    object submittedVal;
                    using (var cmd = new SqlCommand(selfCheck, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        submittedVal = cmd.ExecuteScalar();
                    }

                    if (submittedVal == null)
                    { tx.Rollback(); errorCode = "BAD_REQUEST"; return false; }

                    if (submittedVal != DBNull.Value)
                    { tx.Rollback(); errorCode = "ALREADY_SUBMITTED"; return false; }

                    // 3) Mark submitted
                    const string markSubmitted = @"
                        UPDATE dbo.self_appraisals
                        SET    submitted_at = GETDATE()
                        WHERE  acr_id      = @acrId
                          AND  submitted_at IS NULL";

                    int updatedSelf;
                    using (var cmd = new SqlCommand(markSubmitted, con, tx))
                    {
                        cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                        updatedSelf = cmd.ExecuteNonQuery();
                    }

                    if (updatedSelf == 0) { tx.Rollback(); errorCode = "ALREADY_SUBMITTED"; return false; }

                    // 4) Advance ACR status
                    const string advanceStatus = @"
                        UPDATE dbo.acr_cycles
                        SET    status     = 'PENDING_REPORTING',
                               updated_at = GETDATE()
                        WHERE  acr_id = @acrId";

                    using (var cmd = new SqlCommand(advanceStatus, con, tx))
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
