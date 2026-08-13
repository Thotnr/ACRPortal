using ACRPortal.Domain.DTOs.WebToApp;
using System;


namespace ACRPortal.Application.port
{
    public interface IDashboardRepoPort
    {
        DashboardSummaryDto GetSummary(Guid userId, string role);
    }
}
