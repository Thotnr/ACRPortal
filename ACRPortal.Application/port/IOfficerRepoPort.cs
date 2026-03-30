using System;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IOfficerRepoPort
    {
        PagedResult<MyAcrListItem> GetMyAcrs(Guid officerUserId, string status, int pageNumber, int pageSize);
        AcrDetailResponse GetAcrDetail(Guid acrId, Guid officerUserId);
        bool TryUpsertSelfAppraisalDraft(Guid acrId, Guid officerUserId, SelfAppraisalDraftRequest request, out string errorCode);
        bool TrySubmitSelfAppraisal(Guid acrId, Guid officerUserId, out string errorCode);
    }
}

