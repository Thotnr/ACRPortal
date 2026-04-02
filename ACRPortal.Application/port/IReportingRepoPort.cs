using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IReportingRepoPort
    {
        PagedResult<MyReportingQueueItem> GetMyReportingQueue(Guid userId, int pageNumber, int pageSize, string Status, string Officer_name);
        ReportingAcrDetailResponse GetReportingDetail(Guid acrId, Guid userId, out string errorCode);
        bool TryUpsertReportingDraft(Guid acrId, Guid userId, ReportingDraftRequest request, out string errorCode);
        bool TrySubmitReporting(Guid acrId, Guid userId, out string errorCode);
    }
}

