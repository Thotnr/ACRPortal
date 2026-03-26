using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACRPortal.Application.service
{
    public class DashboardService : IDashboardUseCase
    {
        private readonly IDashboardRepoPort _repo;

        public DashboardService(IDashboardRepoPort repo)
        {
            _repo = repo;
        }

        public ApiResponse<DashboardSummaryDto> GetSummary(Guid userId, string role)
        {
            try
            {
                var data = _repo.GetSummary(userId, role);

                // calculate completion rate
                data.Completion.CompletionRate =
                    data.TotalAcrs == 0 ? 0 :
                    (double)data.Completion.Completed / data.TotalAcrs * 100;

                return ApiResponse<DashboardSummaryDto>.Ok(data);
            }
            catch
            {
                return ApiResponse<DashboardSummaryDto>.Fail("INTERNAL_ERROR");
            }
        }
    }
}
