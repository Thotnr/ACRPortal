using ACRPortal.Domain.DTOs.WebToApp;
using System;


namespace ACRPortal.Application.usecase
{
    public interface IDashboardUseCase
    {
        ApiResponse<DashboardSummaryDto> GetSummary(Guid userId, string role);
    }
}
