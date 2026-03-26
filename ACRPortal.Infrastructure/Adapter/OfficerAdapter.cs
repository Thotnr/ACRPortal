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
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  GetMyAcrs                                                          //
        // ================================================================== //
        public MyAcrListResponse GetMyAcrs(Guid officerUserId, string status)
        {
            string statusFilter = string.IsNullOrWhiteSpace(status) ? null : status.Trim().ToUpper();

            string sql = @"
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
                FROM    dbo.acr_cycles ac
                LEFT JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
                WHERE   ac.officer_user_id = @uid
                  AND   ac.status <> 'DRAFT' ";

            if (!string.IsNullOrWhiteSpace(statusFilter))
                sql += " AND ac.status = @status ";

            sql += " ORDER BY ac.created_at DESC";

            var resp = new MyAcrListResponse();
            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@uid", SqlDbType.UniqueIdentifier).Value = officerUserId;
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    cmd.Parameters.Add("@status", SqlDbType.VarChar).Value = statusFilter;

                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                        resp.AcrCycles.Add(new MyAcrListItem
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
            return resp;
        }

        // ================================================================== //
        //  GetAcrDetail                                                       //
        //                                                                     //
        //  Column index map (document_path removed vs. old version):          //
        //   0  acr_id           8  acr_year                                   //
        //   1  form_type        9  appraisal_id (NULL → no self-appraisal)   //
        //   2  status          10  sa.submitted_at                            //
        //   3  department      11  leave_details                              //
        //   4  location        12  duties_description                         //
        //   5  designation     13  targets_set                                //
        //   6  posting_from    14  targets_achieved                           //
        //   7  posting_to      15  shortfall_reasons                          //
        //                      16  major_achievements                         //
        //                      17  membership_bodies                          //
        //                      18  training_details                           //
        //                      19  awards_honours                             //
        //                      20  auditor_compliance  (BIT)                  //
        //                      21  property_declared                          //
        //                      22  property_declared_date                     //
        //                      23  medical_compliance                         //
        //                      24  medical_compliance_date                    //
        //  (document_path was col 25 in old schema — now gone)                //
        // ================================================================== //
        public AcrDetailResponse GetAcrDetail(Guid acrId, Guid officerUserId)
        {
            const string sql = @"
                SELECT  ac.acr_id,
                        ac.form_type,
                        ac.status,
                        ac.department,
                        ac.location,
                        d.dsg,
                        ac.posting_from,
                        ac.posting_to,
                        ac.acr_year,

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

                        -- CCA (Section I) fields — returned to all authorities
                        ac.date_of_birth                 AS cca_date_of_birth,
                        ac.date_joining_nigam          AS cca_date_joining_nigam,
                        ac.date_joining_present_rank  AS cca_date_joining_present_rank,
                        ac.date_joining_present_station AS cca_date_joining_present_station,
                        ac.academic_qualification       AS cca_academic_qualification,
                        ac.technical_qualification      AS cca_technical_qualification,
                        ac.departmental_exam_passed    AS cca_departmental_exam_passed,
                        ac.property_return_date        AS cca_property_return_date,
                        ac.last_medical_exam_date      AS cca_last_medical_exam_date,
                        ac.career_posting_summary      AS cca_career_posting_summary
                FROM dbo.acr_cycles ac
                LEFT JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.tbDsg d ON d.dsgDesc = ac.designation
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
                        AcrYear = r.IsDBNull(8) ? 0 : r.GetInt32(8)
                    };

                    bool hasSelf = !r.IsDBNull(9);
                    resp.SelfAppraisal.Exists = hasSelf;
                    if (hasSelf)
                    {
                        DateTime? submittedAt = r.IsDBNull(10) ? (DateTime?)null : r.GetDateTime(10);
                        resp.SelfAppraisal.IsSubmitted = submittedAt.HasValue;
                        resp.SelfAppraisal.SubmittedAt = submittedAt?.ToString("o");
                        resp.SelfAppraisal.LeaveDetails = r.IsDBNull(11) ? null : r.GetString(11);
                        resp.SelfAppraisal.DutiesDescription = r.IsDBNull(12) ? null : r.GetString(12);
                        resp.SelfAppraisal.TargetsSet = r.IsDBNull(13) ? null : r.GetString(13);
                        resp.SelfAppraisal.TargetsAchieved = r.IsDBNull(14) ? null : r.GetString(14);
                        resp.SelfAppraisal.ShortfallReasons = r.IsDBNull(15) ? null : r.GetString(15);
                        resp.SelfAppraisal.MajorAchievements = r.IsDBNull(16) ? null : r.GetString(16);
                        resp.SelfAppraisal.MembershipBodies = r.IsDBNull(17) ? null : r.GetString(17);
                        resp.SelfAppraisal.TrainingDetails = r.IsDBNull(18) ? null : r.GetString(18);
                        resp.SelfAppraisal.AwardsHonours = r.IsDBNull(19) ? null : r.GetString(19);
                        resp.SelfAppraisal.AuditorCompliance = r.IsDBNull(20) ? (bool?)null : r.GetBoolean(20);
                        resp.SelfAppraisal.PropertyDeclared = !r.IsDBNull(21) && r.GetBoolean(21);
                        resp.SelfAppraisal.PropertyDeclaredDate = r.IsDBNull(22) ? null : r.GetDateTime(22).ToString("yyyy-MM-dd");
                        resp.SelfAppraisal.MedicalCompliance = !r.IsDBNull(23) && r.GetBoolean(23);
                        resp.SelfAppraisal.MedicalComplianceDate = r.IsDBNull(24) ? null : r.GetDateTime(24).ToString("yyyy-MM-dd");
                    }

                    // CCA (Section I) — always mapped for officer authorities
                    int ccaDobIdx = r.GetOrdinal("cca_date_of_birth");
                    resp.DateOfBirth = r.IsDBNull(ccaDobIdx) ? null : r.GetDateTime(ccaDobIdx).ToString("yyyy-MM-dd");

                    int ccaDjNigamIdx = r.GetOrdinal("cca_date_joining_nigam");
                    resp.DateJoiningNigam = r.IsDBNull(ccaDjNigamIdx) ? null : r.GetDateTime(ccaDjNigamIdx).ToString("yyyy-MM-dd");

                    int ccaDjRankIdx = r.GetOrdinal("cca_date_joining_present_rank");
                    resp.DateJoiningPresentRank = r.IsDBNull(ccaDjRankIdx) ? null : r.GetDateTime(ccaDjRankIdx).ToString("yyyy-MM-dd");

                    int ccaDjStationIdx = r.GetOrdinal("cca_date_joining_present_station");
                    resp.DateJoiningPresentStation = r.IsDBNull(ccaDjStationIdx) ? null : r.GetDateTime(ccaDjStationIdx).ToString("yyyy-MM-dd");

                    int ccaAcademicIdx = r.GetOrdinal("cca_academic_qualification");
                    resp.AcademicQualification = r.IsDBNull(ccaAcademicIdx) ? null : r.GetString(ccaAcademicIdx);

                    int ccaTechnicalIdx = r.GetOrdinal("cca_technical_qualification");
                    resp.TechnicalQualification = r.IsDBNull(ccaTechnicalIdx) ? null : r.GetString(ccaTechnicalIdx);

                    int ccaDeptExamIdx = r.GetOrdinal("cca_departmental_exam_passed");
                    resp.DepartmentalExamPassed = r.IsDBNull(ccaDeptExamIdx) ? null : r.GetString(ccaDeptExamIdx);

                    int ccaPropReturnIdx = r.GetOrdinal("cca_property_return_date");
                    resp.PropertyReturnDate = r.IsDBNull(ccaPropReturnIdx) ? null : r.GetDateTime(ccaPropReturnIdx).ToString("yyyy-MM-dd");

                    int ccaLastMedIdx = r.GetOrdinal("cca_last_medical_exam_date");
                    resp.LastMedicalExamDate = r.IsDBNull(ccaLastMedIdx) ? null : r.GetDateTime(ccaLastMedIdx).ToString("yyyy-MM-dd");

                    int ccaSummaryIdx = r.GetOrdinal("cca_career_posting_summary");
                    resp.CareerPostingSummary = r.IsDBNull(ccaSummaryIdx) ? null : r.GetString(ccaSummaryIdx);

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

                cmd.Parameters.Add("@propDeclared", SqlDbType.Bit).Value = request.PropertyDeclared ? 1 : 0;
                cmd.Parameters.Add("@propDeclaredDate", SqlDbType.Date).Value = (object)propDeclaredDate ?? DBNull.Value;
                cmd.Parameters.Add("@medical", SqlDbType.Bit).Value = request.MedicalCompliance ? 1 : 0;
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