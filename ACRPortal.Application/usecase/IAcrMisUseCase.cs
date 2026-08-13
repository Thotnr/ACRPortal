using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IAcrMisUseCase
    {
        ApiResponse<AcrMisReportResponse> GetReport(AcrMisFilterRequest request);
        ApiResponse<AcrMisFiltersResponse> GetFilters();
    }
}
