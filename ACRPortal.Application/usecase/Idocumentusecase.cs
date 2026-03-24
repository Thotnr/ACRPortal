using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.usecase
{
    public interface IDocumentUseCase
    {
        /// <summary>
        /// Adds a document URL for the given section of an ACR.
        /// The section is derived server-side from the caller's role and their
        /// position in the ACR chain — the frontend does NOT send the section.
        /// </summary>
        ApiResponse<AddDocumentResponse> AddDocument(
            string acrId,
            string callerUserId,
            AddDocumentRequest request);

        /// <summary>
        /// Uploads (or replaces) the officer's photograph for an ACR.
        /// Only the CCA who owns the ACR can call this.
        /// If a photo already exists it is replaced atomically — no separate delete needed.
        /// DocumentType is fixed to 'OFFICER_PHOTO'.
        /// </summary>
        ApiResponse<AddDocumentResponse> UploadOfficerPhoto(
            string acrId,
            string ccaUserId,
            AddDocumentRequest request);

        /// <summary>
        /// Returns all documents for the given ACR that the caller is allowed to see.
        /// Any participant in the ACR chain (CCA, Officer, RA1, RA2, RvA, AA) can read
        /// all documents once the ACR has passed that section.
        /// </summary>
        ApiResponse<AcrDocumentListResponse> GetDocuments(string acrId, string callerUserId);

        /// <summary>
        /// Deletes a document. Only the uploader's section owner can delete their own documents,
        /// and only while the ACR is still in their step.
        /// </summary>
        ApiResponse<EmptyResponse> DeleteDocument(string acrId, string documentId, string callerUserId);
    }
}