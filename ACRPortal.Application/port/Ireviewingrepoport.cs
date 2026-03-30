using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IReviewingRepoPort
    {
        PagedResult<MyReviewingQueueItem> GetMyReviewingQueue(Guid userId, int pageNumber, int pageSize);

        ReviewingAcrDetailResponse GetReviewingDetail(Guid acrId, Guid userId, out string errorCode);
       
        bool TryUpsertReviewingDraft(Guid acrId, Guid userId, ReviewingDraftRequest request, out string errorCode);

        bool TrySubmitReviewing(Guid acrId, Guid userId, out string errorCode);
    }
}