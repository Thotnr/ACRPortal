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