using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IAcceptingRepoPort
    {
        MyAcceptingQueueResponse GetMyAcceptingQueue(Guid userId);

        /// <summary>
        /// Returns full ACR detail for the AA including all prior assessments.
        /// Sets errorCode to FORBIDDEN or INVALID_STATE when access is denied.
        /// Returns null when not found.
        /// </summary>
        AcceptingAcrDetailResponse GetAcceptingDetail(Guid acrId, Guid userId, out string errorCode);

        /// <summary>
        /// Records the AA's final decision and closes the ACR.
        /// State transition: PENDING_ACCEPTING → APPROVED or REJECTED.
        /// One-shot — cannot be repeated once decided_at is set.
        /// </summary>
        bool TrySubmitDecision(Guid acrId, Guid userId, AcceptingDecisionRequest request, out string errorCode);
    }
}