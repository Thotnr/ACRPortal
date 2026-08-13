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
    public class AcrMisAdapter : IAcrMisRepoPort
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["ACRPortalContext"].ConnectionString;

        public AcrMisReportResponse GetReport(AcrMisFilterRequest request)
        {
            var rows = LoadRows(request);
            var orderedRows = rows
                .OrderByDescending(x => x.CreatedAt)
                .ThenBy(x => x.EmployeeName ?? string.Empty)
                .ToList();

            int pageNumber = request.PageNumber <= 0 ? 1 : request.PageNumber;
            int pageSize = request.PageSize <= 0 ? 10 : request.PageSize;

            var response = new AcrMisReportResponse
            {
                AppliedFilters = BuildAppliedFilters(request, rows),
                Summary = BuildSummary(rows),
                RoleWise = BuildRoleWise(rows),
                Charts = BuildCharts(rows),
                Details = new PagedResult<AcrMisDetailItem>
                {
                    PageNumber = pageNumber,
                    PageSize = pageSize,
                    TotalCount = orderedRows.Count,
                    TotalPages = (int)Math.Ceiling((double)orderedRows.Count / pageSize),
                    Items = orderedRows.Skip((pageNumber - 1) * pageSize).Take(pageSize).Select(ToDetailItem).ToList()
                }
            };

            return response;
        }

        public AcrMisFiltersResponse GetFilters()
        {
            var response = new AcrMisFiltersResponse();

            const string sql = @"
                SELECT DISTINCT acr_year FROM dbo.acr_cycles WHERE acr_year IS NOT NULL ORDER BY acr_year DESC;
                SELECT DISTINCT form_type FROM dbo.acr_cycles WHERE form_type IS NOT NULL AND LTRIM(RTRIM(form_type)) <> '' ORDER BY form_type;
                SELECT DISTINCT location FROM dbo.acr_cycles WHERE location IS NOT NULL AND LTRIM(RTRIM(location)) <> '' ORDER BY location;
                SELECT DISTINCT ac.officer_user_id, u.display_name, u.login_id
                FROM dbo.acr_cycles ac
                INNER JOIN dbo.users u ON u.user_id = ac.officer_user_id
                ORDER BY u.display_name, u.login_id;
                SELECT DISTINCT status FROM dbo.acr_cycles WHERE status IS NOT NULL ORDER BY status;";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read()) response.AcrYears.Add(r.GetInt32(0));
                    r.NextResult();
                    while (r.Read()) response.FormTypes.Add(r.GetString(0));
                    r.NextResult();
                    while (r.Read()) response.Locations.Add(r.GetString(0));
                    r.NextResult();
                    while (r.Read())
                    {
                        response.Employees.Add(new AcrMisEmployeeOption
                        {
                            UserId = r.GetGuid(0).ToString(),
                            DisplayName = r.IsDBNull(1) ? null : r.GetString(1),
                            LoginId = r.IsDBNull(2) ? null : r.GetString(2)
                        });
                    }
                    r.NextResult();
                    while (r.Read()) response.Statuses.Add(r.GetString(0));
                }
            }

            return response;
        }

        private List<MisRow> LoadRows(AcrMisFilterRequest request)
        {
            var where = new List<string>();
            var parameters = new List<SqlParameter>();

            if (request.AcrYear.HasValue)
            {
                where.Add("ac.acr_year = @acrYear");
                parameters.Add(new SqlParameter("@acrYear", SqlDbType.Int) { Value = request.AcrYear.Value });
            }
            if (!string.IsNullOrWhiteSpace(request.FormType))
            {
                where.Add("ac.form_type = @formType");
                parameters.Add(new SqlParameter("@formType", SqlDbType.VarChar, 20) { Value = request.FormType.Trim() });
            }
            if (!string.IsNullOrWhiteSpace(request.Location))
            {
                where.Add("ac.location = @location");
                parameters.Add(new SqlParameter("@location", SqlDbType.NVarChar, 200) { Value = request.Location.Trim() });
            }
            if (!string.IsNullOrWhiteSpace(request.EmployeeUserId))
            {
                Guid employeeId;
                if (Guid.TryParse(request.EmployeeUserId, out employeeId))
                {
                    where.Add("ac.officer_user_id = @employeeUserId");
                    parameters.Add(new SqlParameter("@employeeUserId", SqlDbType.UniqueIdentifier) { Value = employeeId });
                }
            }
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                where.Add("ac.status = @status");
                parameters.Add(new SqlParameter("@status", SqlDbType.VarChar, 30) { Value = request.Status.Trim().ToUpperInvariant() });
            }
            if (!string.IsNullOrWhiteSpace(request.Search))
            {
                where.Add("(CONVERT(VARCHAR(36), ac.acr_id) LIKE @search OR LOWER(officer.display_name) LIKE LOWER(@search) OR LOWER(officer.login_id) LIKE LOWER(@search) OR LOWER(ac.designation) LIKE LOWER(@search) OR LOWER(ac.location) LIKE LOWER(@search))");
                parameters.Add(new SqlParameter("@search", SqlDbType.NVarChar, 220) { Value = "%" + request.Search.Trim() + "%" });
            }

            string whereSql = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : string.Empty;

            string sql = @"
                SELECT
                    ac.acr_id,
                    ac.form_type,
                    ac.status,
                    ac.cca_user_id,
                    ac.officer_user_id,
                    ac.reporting_user_id,
                    ac.ra2_user_id,
                    ac.reviewing_user_id,
                    ac.accepting_user_id,
                    ac.department,
                    ac.location,
                    ac.designation,
                    ac.posting_from,
                    ac.posting_to,
                    ac.acr_year,
                    ac.created_at,
                    ac.updated_at,
                    ac.submitted_at,
                    officer.display_name AS officer_name,
                    officer.login_id AS officer_login,
                    cca.display_name AS cca_name,
                    ra1.display_name AS ra1_name,
                    ra2.display_name AS ra2_name,
                    rva.display_name AS rva_name,
                    aa.display_name AS aa_name,
                    sa.submitted_at AS officer_submitted_at,
                    ISNULL(sa.is_skipped, 0) AS officer_is_skipped,
                    ra.ra1_submitted_at,
                    ra.ra2_submitted_at,
                    ISNULL(ra.is_skipped, 0) AS reporting_is_skipped,
                    rv.submitted_at AS reviewing_submitted_at,
                    ISNULL(rv.is_skipped, 0) AS reviewing_is_skipped,
                    ad.decided_at,
                    ad.is_approved,
                    ISNULL(ad.is_skipped, 0) AS accepting_is_skipped
                FROM dbo.acr_cycles ac
                LEFT JOIN dbo.users officer ON officer.user_id = ac.officer_user_id
                LEFT JOIN dbo.users cca ON cca.user_id = ac.cca_user_id
                LEFT JOIN dbo.users ra1 ON ra1.user_id = ac.reporting_user_id
                LEFT JOIN dbo.users ra2 ON ra2.user_id = ac.ra2_user_id
                LEFT JOIN dbo.users rva ON rva.user_id = ac.reviewing_user_id
                LEFT JOIN dbo.users aa ON aa.user_id = ac.accepting_user_id
                LEFT JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
                LEFT JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
                LEFT JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
                LEFT JOIN dbo.accepting_decisions ad ON ad.acr_id = ac.acr_id
                " + whereSql + @"
                ORDER BY ac.created_at DESC;";

            var rows = new List<MisRow>();

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddRange(parameters.ToArray());
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        rows.Add(new MisRow
                        {
                            AcrId = r.GetGuid(0),
                            FormType = ReadString(r, 1),
                            Status = ReadString(r, 2),
                            CcaUserId = ReadGuid(r, 3),
                            OfficerUserId = ReadGuid(r, 4),
                            ReportingUserId = ReadGuid(r, 5),
                            Ra2UserId = ReadNullableGuid(r, 6),
                            ReviewingUserId = ReadGuid(r, 7),
                            AcceptingUserId = ReadGuid(r, 8),
                            Department = ReadString(r, 9),
                            Location = ReadString(r, 10),
                            Designation = ReadString(r, 11),
                            PostingFrom = ReadNullableDate(r, 12),
                            PostingTo = ReadNullableDate(r, 13),
                            AcrYear = r.IsDBNull(14) ? 0 : r.GetInt32(14),
                            CreatedAt = ReadNullableDate(r, 15),
                            UpdatedAt = ReadNullableDate(r, 16),
                            CcaSubmittedAt = ReadNullableDate(r, 17),
                            EmployeeName = ReadString(r, 18),
                            EmployeeLoginId = ReadString(r, 19),
                            CcaName = ReadString(r, 20),
                            Ra1Name = ReadString(r, 21),
                            Ra2Name = ReadString(r, 22),
                            ReviewingName = ReadString(r, 23),
                            AcceptingName = ReadString(r, 24),
                            OfficerSubmittedAt = ReadNullableDate(r, 25),
                            OfficerIsSkipped = ReadBool(r, 26),
                            Ra1SubmittedAt = ReadNullableDate(r, 27),
                            Ra2SubmittedAt = ReadNullableDate(r, 28),
                            ReportingIsSkipped = ReadBool(r, 29),
                            ReviewingSubmittedAt = ReadNullableDate(r, 30),
                            ReviewingIsSkipped = ReadBool(r, 31),
                            DecidedAt = ReadNullableDate(r, 32),
                            IsApproved = ReadNullableBool(r, 33),
                            AcceptingIsSkipped = ReadBool(r, 34)
                        });
                    }
                }
            }

            return rows;
        }

        private static AcrMisSummary BuildSummary(List<MisRow> rows)
        {
            return new AcrMisSummary
            {
                TotalAcr = CountDistinct(rows),
                Draft = CountDistinct(rows.Where(IsDraft)),
                InWorkflow = CountDistinct(rows.Where(x => IsOneOf(x.Status, "PENDING_OFFICER", "PENDING_REPORTING", "PENDING_REVIEWING", "PENDING_ACCEPTING"))),
                Approved = CountDistinct(rows.Where(x => IsStatus(x, "APPROVED"))),
                Rejected = CountDistinct(rows.Where(x => IsStatus(x, "REJECTED"))),
                AutoForwarded = CountDistinct(rows.Where(HasAnySkip))
            };
        }

        private static List<AcrMisRoleSummary> BuildRoleWise(List<MisRow> rows)
        {
            return new List<AcrMisRoleSummary>
            {
                new AcrMisRoleSummary
                {
                    RoleKey = "CCA",
                    RoleName = "CCA",
                    Created = CountDistinct(rows.Where(x => x.CcaUserId != Guid.Empty)),
                    Draft = CountDistinct(rows.Where(IsDraft)),
                    Submitted = CountDistinct(rows.Where(x => x.CcaSubmittedAt.HasValue))
                },
                new AcrMisRoleSummary
                {
                    RoleKey = "OFFICER",
                    RoleName = "Officer / Employee",
                    Received = CountDistinct(rows.Where(x => x.OfficerUserId != Guid.Empty && !IsDraft(x))),
                    Submitted = CountDistinct(rows.Where(x => x.OfficerSubmittedAt.HasValue)),
                    Pending = CountDistinct(rows.Where(x => IsStatus(x, "PENDING_OFFICER") && !x.OfficerSubmittedAt.HasValue)),
                    AutoForwarded = CountDistinct(rows.Where(x => x.OfficerIsSkipped))
                },
                new AcrMisRoleSummary
                {
                    RoleKey = "RA1",
                    RoleName = "Reporting Manager 1",
                    Received = CountDistinct(rows.Where(x => x.ReportingUserId != Guid.Empty && x.OfficerSubmittedAt.HasValue)),
                    Completed = CountDistinct(rows.Where(x => x.Ra1SubmittedAt.HasValue)),
                    Pending = CountDistinct(rows.Where(x => IsStatus(x, "PENDING_REPORTING") && !x.Ra1SubmittedAt.HasValue)),
                    AutoForwarded = CountDistinct(rows.Where(x => x.ReportingIsSkipped && x.Ra1SubmittedAt.HasValue))
                },
                new AcrMisRoleSummary
                {
                    RoleKey = "RA2",
                    RoleName = "Reporting Manager 2",
                    Received = CountDistinct(rows.Where(x => x.Ra2UserId.HasValue && x.OfficerSubmittedAt.HasValue)),
                    Completed = CountDistinct(rows.Where(x => x.Ra2UserId.HasValue && x.Ra2SubmittedAt.HasValue)),
                    Pending = CountDistinct(rows.Where(x => x.Ra2UserId.HasValue && IsStatus(x, "PENDING_REPORTING") && !x.Ra2SubmittedAt.HasValue)),
                    AutoForwarded = CountDistinct(rows.Where(x => x.Ra2UserId.HasValue && x.ReportingIsSkipped && x.Ra2SubmittedAt.HasValue))
                },
                new AcrMisRoleSummary
                {
                    RoleKey = "REVIEWING",
                    RoleName = "Reviewing Manager",
                    Received = CountDistinct(rows.Where(x => x.ReviewingUserId != Guid.Empty && IsReportingComplete(x))),
                    Completed = CountDistinct(rows.Where(x => x.ReviewingSubmittedAt.HasValue)),
                    Pending = CountDistinct(rows.Where(x => IsStatus(x, "PENDING_REVIEWING") && !x.ReviewingSubmittedAt.HasValue)),
                    AutoForwarded = CountDistinct(rows.Where(x => x.ReviewingIsSkipped))
                },
                new AcrMisRoleSummary
                {
                    RoleKey = "ACCEPTING",
                    RoleName = "Accepting Manager",
                    Received = CountDistinct(rows.Where(x => x.AcceptingUserId != Guid.Empty && x.ReviewingSubmittedAt.HasValue)),
                    Approved = CountDistinct(rows.Where(IsApproved)),
                    Pending = CountDistinct(rows.Where(x => IsStatus(x, "PENDING_ACCEPTING") && !x.DecidedAt.HasValue)),
                    Rejected = CountDistinct(rows.Where(IsRejected))
                }
            };
        }

        private static AcrMisCharts BuildCharts(List<MisRow> rows)
        {
            var charts = new AcrMisCharts();
            string[] statuses = { "DRAFT", "PENDING_OFFICER", "PENDING_REPORTING", "PENDING_REVIEWING", "PENDING_ACCEPTING", "APPROVED", "REJECTED" };
            foreach (string status in statuses)
                charts.StatusDistribution.Add(new AcrMisChartItem { Label = status, Value = CountDistinct(rows.Where(x => IsStatus(x, status))) });

            var roles = BuildRoleWise(rows);
            foreach (var role in roles.Where(x => x.RoleKey != "CCA"))
                charts.RoleWisePending.Add(new AcrMisChartItem { Label = role.RoleName, Value = role.Pending });

            charts.ApprovedVsRejected.Add(new AcrMisChartItem { Label = "Approved", Value = CountDistinct(rows.Where(IsApproved)) });
            charts.ApprovedVsRejected.Add(new AcrMisChartItem { Label = "Rejected", Value = CountDistinct(rows.Where(IsRejected)) });

            foreach (var bucket in rows.Select(GetAgeBucket).GroupBy(x => x).OrderBy(x => AgingOrder(x.Key)))
                charts.PendingAging.Add(new AcrMisChartItem { Label = bucket.Key, Value = bucket.Count() });

            return charts;
        }

        private static AcrMisDetailItem ToDetailItem(MisRow row)
        {
            return new AcrMisDetailItem
            {
                AcrId = row.AcrId.ToString(),
                EmployeeName = row.EmployeeName,
                EmployeeLoginId = row.EmployeeLoginId,
                Designation = row.Designation,
                FormType = row.FormType,
                AcrYear = row.AcrYear,
                Location = row.Location,
                CcaName = row.CcaName,
                ReportingManager1Name = row.Ra1Name,
                ReportingManager2Name = row.Ra2UserId.HasValue ? row.Ra2Name : "N/A",
                ReviewingManagerName = row.ReviewingName,
                AcceptingManagerName = row.AcceptingName,
                CurrentStatus = row.Status,
                CcaSubmittedDate = FormatDate(row.CcaSubmittedAt),
                OfficerSubmittedDate = FormatDate(row.OfficerSubmittedAt),
                Rm1SubmittedDate = FormatDate(row.Ra1SubmittedAt),
                Rm2SubmittedDate = row.Ra2UserId.HasValue ? FormatDate(row.Ra2SubmittedAt) : "N/A",
                ReviewingSubmittedDate = FormatDate(row.ReviewingSubmittedAt),
                AcceptingDecisionDate = FormatDate(row.DecidedAt),
                FinalDecision = GetFinalDecision(row),
                CurrentPendingWith = GetCurrentPendingWith(row),
                CurrentStageAgeDays = GetCurrentStageAgeDays(row),
                CurrentStageAgeBucket = GetAgeBucket(row),
                IsAutoForwarded = HasAnySkip(row),
                AutoForwardedStages = GetSkippedStages(row)
            };
        }

        private static AcrMisAppliedFilters BuildAppliedFilters(AcrMisFilterRequest request, List<MisRow> rows)
        {
            string employee = null;
            if (!string.IsNullOrWhiteSpace(request.EmployeeUserId))
            {
                var match = rows.FirstOrDefault(x => x.OfficerUserId.ToString().Equals(request.EmployeeUserId, StringComparison.OrdinalIgnoreCase));
                employee = match == null ? request.EmployeeUserId : (match.EmployeeName ?? match.EmployeeLoginId);
            }

            return new AcrMisAppliedFilters
            {
                AcrYear = request.AcrYear.HasValue ? request.AcrYear.Value.ToString() : "All",
                FormType = string.IsNullOrWhiteSpace(request.FormType) ? "All" : request.FormType,
                Location = string.IsNullOrWhiteSpace(request.Location) ? "All" : request.Location,
                Employee = string.IsNullOrWhiteSpace(employee) ? "All" : employee,
                Status = string.IsNullOrWhiteSpace(request.Status) ? "All" : request.Status,
                Search = string.IsNullOrWhiteSpace(request.Search) ? "All" : request.Search
            };
        }

        private static bool IsReportingComplete(MisRow row)
        {
            if (!row.Ra1SubmittedAt.HasValue) return false;
            return !row.Ra2UserId.HasValue || row.Ra2SubmittedAt.HasValue;
        }

        private static int CountDistinct(IEnumerable<MisRow> rows)
        {
            return rows.Select(x => x.AcrId).Distinct().Count();
        }

        private static bool IsApproved(MisRow row)
        {
            return IsStatus(row, "APPROVED") || (row.DecidedAt.HasValue && row.IsApproved.HasValue && row.IsApproved.Value);
        }

        private static bool IsRejected(MisRow row)
        {
            return IsStatus(row, "REJECTED") || (row.DecidedAt.HasValue && row.IsApproved.HasValue && !row.IsApproved.Value);
        }

        private static bool HasAnySkip(MisRow row)
        {
            return row.OfficerIsSkipped || row.ReportingIsSkipped || row.ReviewingIsSkipped || row.AcceptingIsSkipped;
        }

        private static string GetSkippedStages(MisRow row)
        {
            var stages = new List<string>();
            if (row.OfficerIsSkipped) stages.Add("Officer");
            if (row.ReportingIsSkipped) stages.Add("Reporting");
            if (row.ReviewingIsSkipped) stages.Add("Reviewing");
            if (row.AcceptingIsSkipped) stages.Add("Accepting");
            return stages.Count == 0 ? "No" : string.Join(", ", stages);
        }

        private static string GetFinalDecision(MisRow row)
        {
            if (IsApproved(row)) return "Approved";
            if (IsRejected(row)) return "Rejected";
            return "Pending";
        }

        private static string GetCurrentPendingWith(MisRow row)
        {
            if (IsStatus(row, "DRAFT")) return "CCA";
            if (IsStatus(row, "PENDING_OFFICER")) return row.EmployeeName ?? "Officer";
            if (IsStatus(row, "PENDING_REPORTING"))
            {
                if (!row.Ra1SubmittedAt.HasValue) return row.Ra1Name ?? "Reporting Manager 1";
                if (row.Ra2UserId.HasValue && !row.Ra2SubmittedAt.HasValue) return row.Ra2Name ?? "Reporting Manager 2";
                return "Reporting";
            }
            if (IsStatus(row, "PENDING_REVIEWING")) return row.ReviewingName ?? "Reviewing Manager";
            if (IsStatus(row, "PENDING_ACCEPTING")) return row.AcceptingName ?? "Accepting Manager";
            if (IsStatus(row, "APPROVED") || IsStatus(row, "REJECTED")) return "Completed";
            return row.Status;
        }

        private static int GetCurrentStageAgeDays(MisRow row)
        {
            if (IsStatus(row, "APPROVED") || IsStatus(row, "REJECTED")) return 0;

            DateTime? start = row.CreatedAt;
            if (IsStatus(row, "PENDING_OFFICER")) start = row.CcaSubmittedAt ?? row.CreatedAt;
            else if (IsStatus(row, "PENDING_REPORTING")) start = row.OfficerSubmittedAt ?? row.UpdatedAt ?? row.CreatedAt;
            else if (IsStatus(row, "PENDING_REVIEWING")) start = Latest(row.Ra1SubmittedAt, row.Ra2SubmittedAt) ?? row.UpdatedAt ?? row.CreatedAt;
            else if (IsStatus(row, "PENDING_ACCEPTING")) start = row.ReviewingSubmittedAt ?? row.UpdatedAt ?? row.CreatedAt;

            if (!start.HasValue) return 0;
            return Math.Max(0, (int)Math.Floor((DateTime.Now - start.Value).TotalDays));
        }

        private static string GetAgeBucket(MisRow row)
        {
            if (IsStatus(row, "APPROVED") || IsStatus(row, "REJECTED")) return "Completed";

            int days = GetCurrentStageAgeDays(row);
            if (days <= 3) return "0-3 days";
            if (days <= 7) return "4-7 days";
            if (days <= 15) return "8-15 days";
            return "15+ days";
        }

        private static int AgingOrder(string bucket)
        {
            switch (bucket)
            {
                case "0-3 days": return 1;
                case "4-7 days": return 2;
                case "8-15 days": return 3;
                case "15+ days": return 4;
                case "Completed": return 5;
                default: return 6;
            }
        }

        private static DateTime? Latest(DateTime? first, DateTime? second)
        {
            if (!first.HasValue) return second;
            if (!second.HasValue) return first;
            return first.Value >= second.Value ? first : second;
        }

        private static bool IsDraft(MisRow row)
        {
            return IsStatus(row, "DRAFT");
        }

        private static bool IsStatus(MisRow row, string status)
        {
            return string.Equals(row.Status, status, StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsOneOf(string value, params string[] values)
        {
            return values.Any(x => string.Equals(value, x, StringComparison.OrdinalIgnoreCase));
        }

        private static string FormatDate(DateTime? value)
        {
            return value.HasValue ? value.Value.ToString("yyyy-MM-dd") : null;
        }

        private static string ReadString(SqlDataReader r, int index)
        {
            return r.IsDBNull(index) ? null : r.GetString(index);
        }

        private static Guid ReadGuid(SqlDataReader r, int index)
        {
            return r.IsDBNull(index) ? Guid.Empty : r.GetGuid(index);
        }

        private static Guid? ReadNullableGuid(SqlDataReader r, int index)
        {
            return r.IsDBNull(index) ? (Guid?)null : r.GetGuid(index);
        }

        private static DateTime? ReadNullableDate(SqlDataReader r, int index)
        {
            return r.IsDBNull(index) ? (DateTime?)null : r.GetDateTime(index);
        }

        private static bool ReadBool(SqlDataReader r, int index)
        {
            return !r.IsDBNull(index) && Convert.ToBoolean(r.GetValue(index));
        }

        private static bool? ReadNullableBool(SqlDataReader r, int index)
        {
            return r.IsDBNull(index) ? (bool?)null : Convert.ToBoolean(r.GetValue(index));
        }

        private class MisRow
        {
            public Guid AcrId { get; set; }
            public string FormType { get; set; }
            public string Status { get; set; }
            public Guid CcaUserId { get; set; }
            public Guid OfficerUserId { get; set; }
            public Guid ReportingUserId { get; set; }
            public Guid? Ra2UserId { get; set; }
            public Guid ReviewingUserId { get; set; }
            public Guid AcceptingUserId { get; set; }
            public string Department { get; set; }
            public string Location { get; set; }
            public string Designation { get; set; }
            public DateTime? PostingFrom { get; set; }
            public DateTime? PostingTo { get; set; }
            public int AcrYear { get; set; }
            public DateTime? CreatedAt { get; set; }
            public DateTime? UpdatedAt { get; set; }
            public DateTime? CcaSubmittedAt { get; set; }
            public string EmployeeName { get; set; }
            public string EmployeeLoginId { get; set; }
            public string CcaName { get; set; }
            public string Ra1Name { get; set; }
            public string Ra2Name { get; set; }
            public string ReviewingName { get; set; }
            public string AcceptingName { get; set; }
            public DateTime? OfficerSubmittedAt { get; set; }
            public bool OfficerIsSkipped { get; set; }
            public DateTime? Ra1SubmittedAt { get; set; }
            public DateTime? Ra2SubmittedAt { get; set; }
            public bool ReportingIsSkipped { get; set; }
            public DateTime? ReviewingSubmittedAt { get; set; }
            public bool ReviewingIsSkipped { get; set; }
            public DateTime? DecidedAt { get; set; }
            public bool? IsApproved { get; set; }
            public bool AcceptingIsSkipped { get; set; }
        }
    }
}
