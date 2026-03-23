using System;
using System.Collections.Generic;

namespace ACRPortal.Domain.DTOs.WebToApp
{
    // ------------------------------------------------------------------ //
    //  Upload request — sent by frontend after file is stored             //
    //  Frontend uploads the file to cloud/storage directly, gets back     //
    //  a URL, then calls our API with just that URL.                      //
    // ------------------------------------------------------------------ //

    public class AddDocumentRequest
    {
        /// <summary>
        /// The public URL returned by the storage provider after upload.
        /// Required.
        /// </summary>
        public string FileUrl { get; set; }

        /// <summary>
        /// Original filename for display purposes (e.g. "medical_report.pdf").
        /// Optional but recommended.
        /// </summary>
        public string FileName { get; set; }

        /// <summary>
        /// Category tag for this document within the section.
        /// Examples: MEDICAL_REPORT, TRAINING_CERT, AWARD_LETTER, SUPPORTING_DOC,
        ///           PROPERTY_RETURN, INTEGRITY_EVIDENCE, FINAL_ORDER
        /// Optional — defaults to SUPPORTING_DOC if omitted.
        /// </summary>
        public string DocumentType { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Response after adding a document                                   //
    // ------------------------------------------------------------------ //

    public class AddDocumentResponse
    {
        public string DocumentId { get; set; }
    }

    // ------------------------------------------------------------------ //
    //  Single document item — used in list responses and detail views     //
    // ------------------------------------------------------------------ //

    public class AcrDocumentItem
    {
        public string DocumentId { get; set; }
        public string Section { get; set; }   // CCA | OFFICER | RA1 | RA2 | RVA | AA
        public string DocumentType { get; set; }
        public string FileUrl { get; set; }
        public string FileName { get; set; }
        public string UploadedAt { get; set; }   // ISO 8601
    }

    // ------------------------------------------------------------------ //
    //  List response                                                       //
    // ------------------------------------------------------------------ //

    public class AcrDocumentListResponse
    {
        public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();
    }
}