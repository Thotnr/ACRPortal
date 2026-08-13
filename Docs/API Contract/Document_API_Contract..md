# Document API Contract
**RoutePrefixes:** `api/acr` (EMPLOYEE role) and `api/cca` (CCA role)  
**All responses:** `ApiResponse<T>`  
**Controllers:** `DocumentApiController` (EMPLOYEE) · `CcaDocumentApiController` (CCA)

---

## Overview

ACR participants upload supporting documents (medical reports, annexures, evidence files) to their own section of an ACR. Documents are stored as URL references — the actual file lives in cloud storage (S3 / Azure Blob / GCS).

**Upload flow:**
1. Frontend requests a pre-signed upload URL from cloud storage.
2. Frontend uploads the file directly to cloud storage (no server involvement).
3. Frontend calls `POST .../docs` with the resulting URL.

**Section isolation:**
- Each participant has their own section: `CCA`, `OFFICER`, `RA1`, `RA2`, `RVA`, `AA`.
- The server resolves the caller's section automatically from their user ID — the frontend never sends a `section` field.
- Callers can only read, upload, and delete documents in **their own section**.

**Delete restriction:**
- A document can only be deleted **before the caller submits their step**. Once the ACR advances past the caller's active status, the section is locked and delete returns `INVALID_STATE`.
- This mirrors the upload restriction — the same status window applies to both upload and delete.

---

## Schema

### `dbo.acr_documents`
```sql
CREATE TABLE [dbo].[acr_documents] (
    [document_id]   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [acr_id]        UNIQUEIDENTIFIER NOT NULL FK → dbo.acr_cycles(acr_id) ON DELETE CASCADE,
    [section]       VARCHAR(10)      NOT NULL,   -- CCA | OFFICER | RA1 | RA2 | RVA | AA
    [document_type] NVARCHAR(100)    NULL,        -- free label, defaults to 'SUPPORTING_DOC'
    [file_url]      NVARCHAR(1000)   NOT NULL,
    [file_name]     NVARCHAR(300)    NULL,
    [uploaded_at]   DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_acr_documents PRIMARY KEY (document_id),
    CONSTRAINT CK_acr_doc_section CHECK (section IN ('CCA','OFFICER','RA1','RA2','RVA','AA'))
);
CREATE NONCLUSTERED INDEX idx_acr_documents_acr_section
    ON dbo.acr_documents (acr_id, section);
```

---

## Section Resolution Rules

`DocumentAdapter.ResolveCallerSection` performs one query — fetching all six participant IDs and the current status — then applies these rules in order. **The same status window governs both upload and delete.**

| Condition | Section assigned | Upload/Delete allowed when status is… |
|---|---|---|
| `callerId == cca_user_id` | `CCA` | Any non-final status (`DRAFT`, `PENDING_*`) |
| `callerId == officer_user_id` | `OFFICER` | `PENDING_OFFICER` only |
| `callerId == reporting_user_id` | `RA1` | `PENDING_REPORTING` only |
| `callerId == ra2_user_id` | `RA2` | `PENDING_REPORTING` only |
| `callerId == reviewing_user_id` | `RVA` | `PENDING_REVIEWING` only |
| `callerId == accepting_user_id` | `AA` | `PENDING_ACCEPTING` only |
| No match | — | → `FORBIDDEN` |

If the status check fails → `INVALID_STATE` (applies to both upload and delete). Once a participant submits their step, the ACR moves to the next status and their section is permanently locked.

---

## Models

### `AddDocumentRequest`
```csharp
public class AddDocumentRequest {
    public string FileUrl      { get; set; }   // required
    public string FileName     { get; set; }   // required
    public string DocumentType { get; set; }   // optional, defaults to 'SUPPORTING_DOC'
}
```

### `AddDocumentResponse`
```csharp
public class AddDocumentResponse {
    public string DocumentId { get; set; }   // GUID of newly created row
}
```

### `AcrDocumentItem`
```csharp
public class AcrDocumentItem {
    public string DocumentId   { get; set; }
    public string Section      { get; set; }   // caller's section
    public string DocumentType { get; set; }
    public string FileUrl      { get; set; }
    public string FileName     { get; set; }
    public string UploadedAt   { get; set; }   // ISO 8601
}
```

### `AcrDocumentListResponse`
```csharp
public class AcrDocumentListResponse {
    public List<AcrDocumentItem> Documents { get; set; } = new List<AcrDocumentItem>();
}
```

---

## EMPLOYEE Routes (`api/acr`)

Used by: Officer, RA1, RA2, RvA, AA.

### POST `/api/acr/{acrId}/docs`
Upload a document to the caller's section.

**Request**
```json
{
  "FileUrl": "https://storage.example.com/acr/{acrId}/file.pdf",
  "FileName": "Medical_Report.pdf",
  "DocumentType": "MEDICAL_REPORT"
}
```

**Success `201`**
```json
{
  "Success": true,
  "Message": "Document uploaded successfully",
  "Data": { "DocumentId": "a1b2c3d4-..." },
  "ErrorCode": null
}
```

**Failure Cases**
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` or `FileName` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not a participant in this ACR | `FORBIDDEN` | 403 |
| ACR not in the correct step for caller's section | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

### GET `/api/acr/{acrId}/docs`
List all documents in the caller's section.

**Success `200`**
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Documents": [
      {
        "DocumentId": "uuid",
        "Section": "OFFICER",
        "DocumentType": "MEDICAL_REPORT",
        "FileUrl": "https://storage.example.com/acr/uuid/medical.pdf",
        "FileName": "Annexure_A_Medical.pdf",
        "UploadedAt": "2024-06-01T09:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

> Returns `[]` if no documents have been uploaded yet.

**Failure Cases**
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not a participant | `FORBIDDEN` | 403 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

### DELETE `/api/acr/{acrId}/docs/{documentId}`
Delete a document. Caller can only delete from their own section, and only while their step is still active (before submitting).

**Success `200`**
```json
{ "Success": true, "Message": "Document deleted successfully", "Data": {}, "ErrorCode": null }
```

**Failure Cases**
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Document not found or belongs to a different section | `NOT_FOUND` | 404 |
| Caller is not a participant | `FORBIDDEN` | 403 |
| Caller has already submitted (step advanced past their section) | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## CCA Routes (`api/cca`)

Used by: CCA only.

### POST `/api/cca/acr/{acrId}/photo`

Upload (or replace) the officer's photograph. Only the CCA who owns the ACR can call this. If a photo already exists it is **replaced atomically** — no separate delete needed.

`DocumentType` is always `OFFICER_PHOTO` — the caller does not set it.  
The photo is returned as `OfficerPhoto` in `GET /api/cca/acr/{acrId}` (separate from `Documents`).

**Request**
```json
{
  "FileUrl": "https://storage.example.com/acr/uuid/officer_photo.jpg",
  "FileName": "Ramesh_Kumar_Photo.jpg"
}
```

> `DocumentType` is ignored — always stored as `OFFICER_PHOTO`.

**Success `201`**
```json
{
  "Success": true,
  "Message": "Officer photo uploaded successfully",
  "Data": { "DocumentId": "uuid" },
  "ErrorCode": null
}
```

**Failure Cases**
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the CCA for this ACR | `FORBIDDEN` | 403 |
| ACR is `APPROVED` or `REJECTED` | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

### POST `/api/cca/acr/{acrId}/docs`
Upload a document to the CCA section.  
Same request/response shape as `POST /api/acr/{acrId}/docs`.

### GET `/api/cca/acr/{acrId}/docs`
List CCA section documents.  
Same response shape as `GET /api/acr/{acrId}/docs`.

### DELETE `/api/cca/acr/{acrId}/docs/{documentId}`
Delete a CCA section document. Only allowed while the ACR is not yet `APPROVED` or `REJECTED`.  
Same response/failure shape as `DELETE /api/acr/{acrId}/docs/{documentId}` (including `INVALID_STATE` when the ACR is finalised).

---

## Integration Notes

### Where `Documents` appears in detail responses

Each role's detail response now includes a `Documents` field populated by the server before returning:

| Detail endpoint | Documents shown |
|---|---|
| `GET /api/acr/{acrId}` (Officer) | section = `CCA` (modal reuse; excludes photo) |
| `GET /api/acr/{acrId}/reporting` | section = `CCA` (modal reuse; excludes photo) |
| `GET /api/acr/{acrId}/reviewing` | section = `CCA` (modal reuse; excludes photo) |
| `GET /api/acr/{acrId}/accepting` | section = `CCA` (modal reuse; excludes photo) |
| `GET /api/cca/acr/{acrId}` | section = `CCA` |

For the non-CCA authority detail endpoints, the caller's step-specific attachments are exposed via `RoleDocuments` (section = `OFFICER` / `RA1` / `RA2` / `RVA` / `AA`). The modal-friendly `Documents` field is reserved for CCA section I attachments (section = `CCA`, excluding `OFFICER_PHOTO`).

### `DocumentPath` removal

The `document_path` column has been removed from `self_appraisals`, `reporting_assessments`, `reviewing_assessments`, and `accepting_decisions`. Any request DTO that previously included a `DocumentPath` field no longer does. All document references go through `dbo.acr_documents`.

### Officer photograph

The photograph is stored in `dbo.acr_documents` with `section = 'CCA'` and `document_type = 'OFFICER_PHOTO'`. It is surfaced separately from the general `Documents` list:

- `GET /api/cca/acr/{acrId}` returns `OfficerPhoto: { DocumentId, FileUrl, FileName, UploadedAt }` (null if not yet uploaded) alongside `Documents` (which excludes the photo).
- `GET /api/acr/{acrId}`, `/api/acr/{acrId}/reporting`, `/api/acr/{acrId}/reviewing`, `/api/acr/{acrId}/accepting` also include `OfficerPhoto` in the response (so the shared authority modal can show the same CCA media consistently).
- Upload/replace via `POST /api/cca/acr/{acrId}/photo` — not via the generic docs endpoint.
- Delete via `DELETE /api/cca/acr/{acrId}/docs/{documentId}` using the `DocumentId` from `OfficerPhoto`.

---

## `IDocumentUseCase` — interface shape
```csharp
ApiResponse<AddDocumentResponse>     AddDocument(string acrId, string callerUserId, AddDocumentRequest request);
ApiResponse<AddDocumentResponse>     UploadOfficerPhoto(string acrId, string ccaUserId, AddDocumentRequest request);
ApiResponse<AcrDocumentListResponse> GetDocuments(string acrId, string callerUserId);
ApiResponse<EmptyResponse>           DeleteDocument(string acrId, string documentId, string callerUserId);
```

## `IDocumentRepoPort` — interface shape
```csharp
bool   ResolveCallerSection(Guid acrId, Guid callerId, out string section, out string errorCode);
bool   IsParticipant(Guid acrId, Guid callerId, out string errorCode);
string AddDocument(Guid acrId, string section, string fileUrl, string fileName, string documentType);
string ReplaceDocumentByType(Guid acrId, string section, string documentType, string fileUrl, string fileName);
List<AcrDocumentItem> GetDocuments(Guid acrId, string section = null);
bool   DeleteDocument(Guid documentId, Guid acrId, string section);
```