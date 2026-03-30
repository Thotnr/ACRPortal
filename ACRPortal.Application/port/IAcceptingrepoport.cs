using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IAcceptingRepoPort
    {
        PagedResult<MyAcceptingQueueItem> GetMyAcceptingQueue(Guid userId, int pageNumber, int pageSize);

        AcceptingAcrDetailResponse GetAcceptingDetail(Guid acrId, Guid userId, out string errorCode);

        bool TrySubmitDecision(Guid acrId, Guid userId, AcceptingDecisionRequest request, out string errorCode);
    }
}