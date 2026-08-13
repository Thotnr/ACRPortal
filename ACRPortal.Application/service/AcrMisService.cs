using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class AcrMisService : IAcrMisUseCase
    {
        private readonly IAcrMisRepoPort _repo;

        public AcrMisService(IAcrMisRepoPort repo)
        {
            _repo = repo;
        }

        public ApiResponse<AcrMisReportResponse> GetReport(AcrMisFilterRequest request)
        {
            try
            {
                var normalized = request ?? new AcrMisFilterRequest();
                if (normalized.PageNumber <= 0) normalized.PageNumber = 1;
                if (normalized.PageSize <= 0) normalized.PageSize = 10;
                if (normalized.PageSize > 100000) normalized.PageSize = 100000;

                var data = _repo.GetReport(normalized);
                return ApiResponse<AcrMisReportResponse>.Ok(data);
            }
            catch (Exception ex)
            {
                return ApiResponse<AcrMisReportResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<AcrMisFiltersResponse> GetFilters()
        {
            try
            {
                return ApiResponse<AcrMisFiltersResponse>.Ok(_repo.GetFilters());
            }
            catch (Exception ex)
            {
                return ApiResponse<AcrMisFiltersResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}
