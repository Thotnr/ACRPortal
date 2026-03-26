using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;
using System;
using System.Data.SqlClient;
using System.Configuration;

namespace ACRPortal.Infrastructure.Adapter
{
    public class DashboardAdapter : IDashboardRepoPort
    {
        private readonly string _connectionString = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        public DashboardSummaryDto GetSummary(Guid userId, string role)
        {
            var dto = new DashboardSummaryDto
            {
                ByStatus = new StatusCounts(),
                Completion = new CompletionStats()
            };

            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();

                string whereClause = role == "CCA"
                    ? "WHERE cca_user_id = @UserId"
                    : "";

                // 1. STATUS COUNTS
                var statusQuery = $@"
                SELECT 
                    COUNT(1) AS Total,

                    SUM(CASE WHEN status = 'DRAFT' THEN 1 ELSE 0 END) AS Draft,
                    SUM(CASE WHEN status = 'PENDING_OFFICER' THEN 1 ELSE 0 END) AS PendingOfficer,
                    SUM(CASE WHEN status = 'PENDING_REPORTING' THEN 1 ELSE 0 END) AS PendingReporting,
                    SUM(CASE WHEN status = 'PENDING_REVIEWING' THEN 1 ELSE 0 END) AS PendingReviewing,
                    SUM(CASE WHEN status = 'PENDING_ACCEPTING' THEN 1 ELSE 0 END) AS PendingAccepting,
                    SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) AS Approved,
                    SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) AS Rejected

                FROM acr_cycles
                {whereClause}";

                using (var cmd = new SqlCommand(statusQuery, conn))
                {
                    if (role == "CCA")
                        cmd.Parameters.AddWithValue("@UserId", userId);

                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            dto.TotalAcrs = Convert.ToInt32(r["Total"]);

                            dto.ByStatus.DRAFT = Convert.ToInt32(r["Draft"]);
                            dto.ByStatus.PENDING_OFFICER = Convert.ToInt32(r["PendingOfficer"]);
                            dto.ByStatus.PENDING_REPORTING = Convert.ToInt32(r["PendingReporting"]);
                            dto.ByStatus.PENDING_REVIEWING = Convert.ToInt32(r["PendingReviewing"]);
                            dto.ByStatus.PENDING_ACCEPTING = Convert.ToInt32(r["PendingAccepting"]);
                            dto.ByStatus.APPROVED = Convert.ToInt32(r["Approved"]);
                            dto.ByStatus.REJECTED = Convert.ToInt32(r["Rejected"]);
                        }
                    }
                }

                // 2. COMPLETION
                dto.Completion.Completed = dto.ByStatus.APPROVED + dto.ByStatus.REJECTED;
                dto.Completion.InProgress = dto.TotalAcrs - dto.Completion.Completed;
            }

            return dto;
        }
    }
}
