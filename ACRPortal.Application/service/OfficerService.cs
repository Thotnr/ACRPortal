using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class OfficerService : IOfficerUseCase
    {
        private readonly IOfficerRepoPort _repo;
        private readonly IDocumentRepoPort _docs;

        public OfficerService(IOfficerRepoPort repo, IDocumentRepoPort docs)
        {
            _repo = repo;
            _docs = docs;
        }

        public ApiResponse<MyAcrListResponse> GetMyAcrs(string officerUserId, string status)
        {
            try
            {
                if (!Guid.TryParse(officerUserId, out Guid officerGuid))
                    return ApiResponse<MyAcrListResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                var result = _repo.GetMyAcrs(officerGuid,
                    string.IsNullOrWhiteSpace(status) ? null : status.Trim().ToUpper());

                return ApiResponse<MyAcrListResponse>.Ok(result, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<MyAcrListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<AcrDetailResponse> GetAcrDetail(string acrId, string officerUserId)
        {
            try
            {
                if (!Guid.TryParse(officerUserId, out Guid officerGuid))
                    return ApiResponse<AcrDetailResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<AcrDetailResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                var detail = _repo.GetAcrDetail(acrGuid, officerGuid);
                if (detail == null)
                    return ApiResponse<AcrDetailResponse>.Fail("ACR not found", "NOT_FOUND");

                // Attach CCA documents + photo (section = 'CCA')
                var allCcaDocs = _docs.GetDocuments(acrGuid, "CCA");
                detail.Documents = allCcaDocs.FindAll(d => d.DocumentType != "OFFICER_PHOTO");
                detail.OfficerPhoto = allCcaDocs.Find(d => d.DocumentType == "OFFICER_PHOTO");

                // Preserve caller-step documents separately (section = 'OFFICER')
                detail.RoleDocuments = _docs.GetDocuments(acrGuid, "OFFICER");

                return ApiResponse<AcrDetailResponse>.Ok(detail, "Success");
            }
            catch (Exception ex)
            {
                return ApiResponse<AcrDetailResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SaveSelfAppraisalDraft(string acrId, string officerUserId,
            SelfAppraisalDraftRequest request)
        {
            try
            {
                if (request == null)
                    return ApiResponse<EmptyResponse>.Fail("Request body is required", "BAD_REQUEST");

                if (!Guid.TryParse(officerUserId, out Guid officerGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                if (_repo.TryUpsertSelfAppraisalDraft(acrGuid, officerGuid, request, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Draft saved successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "ACR does not belong to caller" :
                    errorCode == "INVALID_STATE" ? "ACR is not in Officer step" :
                    errorCode == "ALREADY_SUBMITTED" ? "Self-appraisal already submitted" :
                    "Unable to save draft",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        public ApiResponse<EmptyResponse> SubmitSelfAppraisal(string acrId, string officerUserId)
        {
            try
            {
                if (!Guid.TryParse(officerUserId, out Guid officerGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid acrId format", "BAD_REQUEST");

                string errorCode;
                if (_repo.TrySubmitSelfAppraisal(acrGuid, officerGuid, out errorCode))
                    return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(),
                        "Self-appraisal submitted successfully");

                return ApiResponse<EmptyResponse>.Fail(
                    errorCode == "NOT_FOUND" ? "ACR not found" :
                    errorCode == "FORBIDDEN" ? "ACR does not belong to caller" :
                    errorCode == "INVALID_STATE" ? "ACR is not in Officer step" :
                    errorCode == "BAD_REQUEST" ? "Self-appraisal draft is required before submitting" :
                    errorCode == "ALREADY_SUBMITTED" ? "Self-appraisal already submitted" :
                    "Unable to submit self-appraisal",
                    errorCode ?? "INTERNAL_ERROR");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}