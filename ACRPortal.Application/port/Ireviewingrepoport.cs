using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IReviewingRepoPort
    {
        MyReviewingQueueResponse GetMyReviewingQueue(Guid userId);

        /// <summary>
        /// Fetches full ACR detail for the RvA: header, self-appraisal, both RA
        /// assessments, and the RvA's own draft (if any).
        /// Returns null when not found; sets errorCode to FORBIDDEN or INVALID_STATE
        /// when the caller is not the reviewing authority or the ACR is not in the
        /// right step.
        /// </summary>
        ReviewingAcrDetailResponse GetReviewingDetail(Guid acrId, Guid userId, out string errorCode);

        /// <summary>
        /// Upserts the RvA's draft into reviewing_assessments and (optionally) the
        /// rva_* override columns in reporting_assessments.
        /// </summary>
        bool TryUpsertReviewingDraft(Guid acrId, Guid userId, ReviewingDraftRequest request, out string errorCode);

        /// <summary>
        /// Submits the RvA's assessment.
        /// State transition: PENDING_REVIEWING → PENDING_ACCEPTING
        /// </summary>
        bool TrySubmitReviewing(Guid acrId, Guid userId, out string errorCode);
    }
}