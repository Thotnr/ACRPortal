using System;
using System.Collections.Generic;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Application.port
{
    public interface IDocumentRepoPort
    {
        /// <summary>
        /// Looks up the ACR, determines the caller's section from their position
        /// in the ACR chain, and validates that the current workflow status allows
        /// document uploads for that section.
        ///
        /// On success: returns true, sets section to 'CCA'|'OFFICER'|'RA1'|'RA2'|'RVA'|'AA',
        ///             sets errorCode to null.
        ///
        /// On failure: returns false, sets errorCode to NOT_FOUND | FORBIDDEN | INVALID_STATE,
        ///             sets section to null.
        ///
        /// Section → allowed status mapping:
        ///   CCA     → any status except APPROVED / REJECTED  (CCA can attach docs freely)
        ///   OFFICER → PENDING_OFFICER
        ///   RA1     → PENDING_REPORTING
        ///   RA2     → PENDING_REPORTING
        ///   RVA     → PENDING_REVIEWING
        ///   AA      → PENDING_ACCEPTING
        /// </summary>
        bool ResolveCallerSection(Guid acrId, Guid callerId, out string section, out string errorCode);

        /// <summary>
        /// Checks whether the caller is any participant in the ACR chain.
        /// Used for read access — any participant can read all documents on an ACR.
        /// Sets errorCode to NOT_FOUND if ACR does not exist.
        /// </summary>
        bool IsParticipant(Guid acrId, Guid callerId, out string errorCode);

        /// <summary>
        /// Inserts a row into dbo.acr_documents.
        /// Returns the new document_id as a string.
        /// </summary>
        string AddDocument(Guid acrId, string section, string fileUrl, string fileName, string documentType);

        /// <summary>
        /// Returns all documents for a given ACR, optionally filtered by section.
        /// </summary>
        List<AcrDocumentItem> GetDocuments(Guid acrId, string section = null);

        /// <summary>
        /// Deletes a specific document belonging to the given ACR and section.
        /// Returns false if not found or section mismatch.
        /// </summary>
        bool DeleteDocument(Guid documentId, Guid acrId, string section);

        /// <summary>
        /// Atomically replaces any existing document of the given type+section for an ACR
        /// with a new one. Used for the officer photo — ensures only one photo exists at a time.
        /// Returns the new document_id as a string.
        /// </summary>
        string ReplaceDocumentByType(Guid acrId, string section, string documentType,
            string fileUrl, string fileName);
    }
}