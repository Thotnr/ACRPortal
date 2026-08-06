using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IAcrMisRepoPort
    {
        AcrMisReportResponse GetReport(AcrMisFilterRequest request);
        AcrMisFiltersResponse GetFilters();
    }
}
