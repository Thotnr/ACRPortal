using System;
using ACRPortal.Application.port;
using ACRPortal.Application.usecase;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.service
{
    public class DocumentService : IDocumentUseCase
    {
        private readonly IDocumentRepoPort _repo;

        public DocumentService(IDocumentRepoPort repo)
        {
            _repo = repo;
        }

        // ------------------------------------------------------------------ //
        //  Add document                                                        //
        // ------------------------------------------------------------------ //
        public ApiResponse<AddDocumentResponse> AddDocument(
            string acrId,
            string callerUserId,
            AddDocumentRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(acrId))
                    return ApiResponse<AddDocumentResponse>.Fail("AcrId is required", "BAD_REQUEST");

                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<AddDocumentResponse>.Fail("AcrId is not a valid GUID", "BAD_REQUEST");

                if (!Guid.TryParse(callerUserId, out Guid callerGuid))
                    return ApiResponse<AddDocumentResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                if (request == null || string.IsNullOrWhiteSpace(request.FileUrl))
                    return ApiResponse<AddDocumentResponse>.Fail("FileUrl is required", "BAD_REQUEST");

                // Single DB call: resolve section + validate state
                string section, errorCode;
                if (!_repo.ResolveCallerSection(acrGuid, callerGuid, out section, out errorCode))
                {
                    return ApiResponse<AddDocumentResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        errorCode == "FORBIDDEN" ? "You are not a participant in this ACR" :
                        errorCode == "INVALID_STATE" ? "Documents cannot be added at the current workflow step" :
                        "Unable to upload document",
                        errorCode ?? "INTERNAL_ERROR");
                }

                string docType = string.IsNullOrWhiteSpace(request.DocumentType)
                    ? "SUPPORTING_DOC"
                    : request.DocumentType.Trim().ToUpper();

                string documentId = _repo.AddDocument(
                    acrGuid,
                    section,
                    request.FileUrl.Trim(),
                    request.FileName?.Trim(),
                    docType);

                return ApiResponse<AddDocumentResponse>.Ok(
                    new AddDocumentResponse { DocumentId = documentId },
                    "Document added successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<AddDocumentResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Get documents                                                       //
        // ------------------------------------------------------------------ //
        public ApiResponse<AcrDocumentListResponse> GetDocuments(string acrId, string callerUserId)
        {
            try
            {
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<AcrDocumentListResponse>.Fail("AcrId is not a valid GUID", "BAD_REQUEST");

                if (!Guid.TryParse(callerUserId, out Guid callerGuid))
                    return ApiResponse<AcrDocumentListResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                string errorCode;
                if (!_repo.IsParticipant(acrGuid, callerGuid, out errorCode))
                {
                    return ApiResponse<AcrDocumentListResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        "You are not a participant in this ACR",
                        errorCode ?? "FORBIDDEN");
                }

                var docs = _repo.GetDocuments(acrGuid);
                return ApiResponse<AcrDocumentListResponse>.Ok(
                    new AcrDocumentListResponse { Documents = docs });
            }
            catch (Exception ex)
            {
                return ApiResponse<AcrDocumentListResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }

        // ------------------------------------------------------------------ //
        //  Delete document                                                     //
        // ------------------------------------------------------------------ //
        public ApiResponse<EmptyResponse> DeleteDocument(string acrId, string documentId, string callerUserId)
        {
            try
            {
                if (!Guid.TryParse(acrId, out Guid acrGuid))
                    return ApiResponse<EmptyResponse>.Fail("AcrId is not a valid GUID", "BAD_REQUEST");

                if (!Guid.TryParse(documentId, out Guid docGuid))
                    return ApiResponse<EmptyResponse>.Fail("DocumentId is not a valid GUID", "BAD_REQUEST");

                if (!Guid.TryParse(callerUserId, out Guid callerGuid))
                    return ApiResponse<EmptyResponse>.Fail("Invalid user id in token", "TOKEN_INVALID");

                string section, errorCode;
                if (!_repo.ResolveCallerSection(acrGuid, callerGuid, out section, out errorCode))
                {
                    return ApiResponse<EmptyResponse>.Fail(
                        errorCode == "NOT_FOUND" ? "ACR not found" :
                        errorCode == "FORBIDDEN" ? "You are not a participant in this ACR" :
                        errorCode == "INVALID_STATE" ? "Documents cannot be deleted at the current workflow step" :
                        "Unable to delete document",
                        errorCode ?? "INTERNAL_ERROR");
                }

                bool deleted = _repo.DeleteDocument(docGuid, acrGuid, section);
                if (!deleted)
                    return ApiResponse<EmptyResponse>.Fail(
                        "Document not found or does not belong to your section", "NOT_FOUND");

                return ApiResponse<EmptyResponse>.Ok(new EmptyResponse(), "Document deleted successfully");
            }
            catch (Exception ex)
            {
                return ApiResponse<EmptyResponse>.Fail(ex.Message, "INTERNAL_ERROR");
            }
        }
    }
}