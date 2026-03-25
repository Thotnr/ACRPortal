# Officer API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose

These APIs cover the **Officer step** of the ACR workflow:

- Officer views ACR cycles assigned to them.
- Officer **saves** their Self-Appraisal as draft (repeatable, idempotent upsert).
- Officer **submits** their Self-Appraisal to advance the ACR to the Reporting Authority.
- Officer **uploads** supporting documents (e.g. medical Annexure-A) to their section.

**Draft behaviour:** `acr_cycles.status` stays `PENDING_OFFICER` while the Officer is working. Draft is represented by `self_appraisals.submitted_at = NULL`. Submitting sets `submitted_at` and transitions status to `PENDING_REPORTING`.

**Document behaviour:** Documents are uploaded separately from the form draft. The frontend obtains a pre-signed URL from cloud storage, uploads the file directly, then calls the document API with the resulting URL. Multiple documents per section are supported. Documents persist independently of draft saves and submissions.

---

## Architecture

```
OfficerApiController       → IOfficerUseCase   → OfficerService   → IOfficerRepoPort   → OfficerAdapter
DocumentApiController      → IDocumentUseCase  → DocumentService  → IDocumentRepoPort  → DocumentAdapter
```

---

## Schema Reference

### `dbo.acr_cycles` (read-only for Officer)
```sql
[acr_id]          UNIQUEIDENTIFIER  PK
[officer_user_id] UNIQUEIDENTIFIER  NOT NULL
[form_type]       VARCHAR(5)        NOT NULL   -- 'A1a' | 'A1b' | 'A2'
[status]          VARCHAR(30)       NOT NULL
[department]      NVARCHAR(200)     NOT NULL
[location]        NVARCHAR(200)     NOT NULL
[designation]     NVARCHAR(200)     NOT NULL
[posting_from]    DATE              NOT NULL
[posting_to]      DATE              NOT NULL
[acr_year]        INT               NOT NULL
```

### `dbo.self_appraisals` (written by Officer)
```sql
[appraisal_id]           UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]                 UNIQUEIDENTIFIER NOT NULL  UNIQUE  FK → dbo.acr_cycles(acr_id)
[leave_details]          NVARCHAR(MAX) NULL   -- Section II Item 1
[membership_bodies]      NVARCHAR(MAX) NULL   -- Section II Item 2
[training_details]       NVARCHAR(MAX) NULL   -- Section II Item 3
[awards_honours]         NVARCHAR(MAX) NULL   -- Section II Item 4
[duties_description]     NVARCHAR(MAX) NULL   -- Section II Item 5(a)
[targets_set]            NVARCHAR(MAX) NULL   -- Section II Item 5(b)
[targets_achieved]       NVARCHAR(MAX) NULL   -- Section II Item 5(c)
[shortfall_reasons]      NVARCHAR(MAX) NULL   -- Section II Item 5(d)
[major_achievements]     NVARCHAR(MAX) NULL   -- Section II Item 5(e)
[auditor_compliance]     BIT           NULL   -- Section II Item 6 (A1b only; NULL = not applicable)
[property_declared]      BIT           NOT NULL DEFAULT 0
[property_declared_date] DATE          NULL
[medical_compliance]     BIT           NOT NULL DEFAULT 0
[medical_compliance_date] DATE         NULL
[submitted_at]           DATETIME      NULL   -- NULL = draft
[created_at]             DATETIME      NOT NULL DEFAULT GETDATE()
```

> **`document_path` has been removed.** Documents are now stored in `dbo.acr_documents` and retrieved via the document API. See Migration 9.

### `dbo.acr_documents` (written by any participant via Document API)
```sql
[document_id]   UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]        UNIQUEIDENTIFIER NOT NULL  FK → dbo.acr_cycles(acr_id)
[section]       VARCHAR(10)      NOT NULL  -- 'OFFICER' for this role
[document_type] NVARCHAR(100)    NULL      -- e.g. 'MEDICAL_REPORT', 'SUPPORTING_DOC'
[file_url]      NVARCHAR(1000)   NOT NULL  -- cloud storage URL (frontend uploads directly)
[file_name]     NVARCHAR(300)    NULL      -- original filename for display
[uploaded_at]   DATETIME         NOT NULL DEFAULT GETDATE()
```

---

## Models

### `MyAcrListItem`
```csharp
public class MyAcrListItem {
  string AcrId;
  string FormType;               // 'A1a' | 'A1b' | 'A2'
  string Department;
  string Location;
  string Designation;
  string PostingFrom;            // yyyy-MM-dd
  string PostingTo;              // yyyy-MM-dd
  int    AcrYear;
  string Status;
  bool   SelfAppraisalSubmitted;
  string CreatedAt;              // ISO 8601
}
```

### `SelfAppraisalDraftRequest`
```csharp
public class SelfAppraisalDraftRequest {
  string LeaveDetails;           // Section II Item 1, nullable
  string MembershipBodies;       // Section II Item 2, nullable
  string TrainingDetails;        // Section II Item 3, nullable
  string AwardsHonours;          // Section II Item 4, nullable
  string DutiesDescription;      // Section II Item 5(a), nullable
  string TargetsSet;             // Section II Item 5(b), nullable
  string TargetsAchieved;        // Section II Item 5(c), nullable
  string ShortfallReasons;       // Section II Item 5(d), nullable
  string MajorAchievements;      // Section II Item 5(e), nullable
  bool?  AuditorCompliance;      // Section II Item 6 — A1b only; send null for A1a/A2
  bool   PropertyDeclared;
  string PropertyDeclaredDate;   // yyyy-MM-dd | null
  bool   MedicalCompliance;
  string MedicalComplianceDate;  // yyyy-MM-dd | null
  // DocumentPath removed — use POST /api/acr/{acrId}/docs instead
}
```

### `SelfAppraisalView` (read-back in AcrDetailResponse)
Same fields as `SelfAppraisalDraftRequest` plus:
```csharp
bool   Exists;
bool   IsSubmitted;
string SubmittedAt;              // ISO 8601 | null
// DocumentPath removed
```

### `AcrDetailResponse`
```csharp
public class AcrDetailResponse {
  string              AcrId;
  string              FormType;
  string              Status;
  string              Department;
  string              Location;
  string              Designation;
  string              PostingFrom;     // yyyy-MM-dd
  string              PostingTo;       // yyyy-MM-dd
  int                 AcrYear;
  SelfAppraisalView   SelfAppraisal;
  List<AcrDocumentItem> Documents;     // officer's own documents (section='OFFICER')
}
```

### `AcrDocumentItem`
```csharp
public class AcrDocumentItem {
  string DocumentId;    // GUID
  string Section;       // always 'OFFICER' in this context
  string DocumentType;  // e.g. 'MEDICAL_REPORT' | 'SUPPORTING_DOC'
  string FileUrl;       // cloud storage URL
  string FileName;      // original filename
  string UploadedAt;    // ISO 8601
}
```

### `AddDocumentRequest`
```csharp
public class AddDocumentRequest {
  string FileUrl;       // required — URL returned by cloud storage after direct upload
  string FileName;      // required — original filename for display
  string DocumentType;  // optional — defaults to 'SUPPORTING_DOC'
}
```

---

## API 1 — List My ACRs
**GET** `/api/acr/my`  
**Query params:** `?status=PENDING_OFFICER` (optional)  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid",
        "FormType": "A1b",
        "Department": "Operation Division Hisar",
        "Location": "Hisar",
        "Designation": "Executive Engineer",
        "PostingFrom": "2023-04-01",
        "PostingTo": "2024-03-31",
        "AcrYear": 2024,
        "Status": "PENDING_OFFICER",
        "SelfAppraisalSubmitted": false,
        "CreatedAt": "2024-05-01T10:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

---

## API 2 — Get ACR Detail
**GET** `/api/acr/{acrId}`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns posting info, current self-appraisal draft, and the officer's uploaded documents.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_OFFICER",
    "Department": "Operation Division Hisar",
    "Location": "Hisar",
    "Designation": "Executive Engineer",
    "PostingFrom": "2023-04-01",
    "PostingTo": "2024-03-31",
    "AcrYear": 2024,
    "SelfAppraisal": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "LeaveDetails": "On EL from 10-Jun-2023 to 20-Jun-2023",
      "MembershipBodies": "IEEE, ISTE",
      "TrainingDetails": "Energy Audit Training, NPTI Faridabad, 15-Jan-2024 to 19-Jan-2024",
      "AwardsHonours": null,
      "DutiesDescription": "Managed 132 KV sub-station operations...",
      "TargetsSet": "1. Reduce AT&C losses to below 15%\n2. Commission new feeder...",
      "TargetsAchieved": "AT&C losses reduced to 14.2%...",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder ahead of schedule.",
      "AuditorCompliance": true,
      "PropertyDeclared": true,
      "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true,
      "MedicalComplianceDate": "2023-05-15"
    },
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

> `Documents` is an empty array `[]` if no documents have been uploaded yet.  
> `SelfAppraisal.AuditorCompliance` is `null` for A1a/A2 officers.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found or belongs to another officer | `NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Save Self-Appraisal Draft
**PATCH** `/api/acr/{acrId}/self-appraisal/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Saves the self-appraisal. All fields are optional — only provided fields are stored. Repeatable.

### Request
```json
{
  "LeaveDetails": "On EL from 10-Jun-2023 to 20-Jun-2023",
  "MembershipBodies": "IEEE, ISTE",
  "TrainingDetails": "Energy Audit Training, NPTI Faridabad, 15-Jan-2024 to 19-Jan-2024",
  "AwardsHonours": null,
  "DutiesDescription": "Managed 132 KV sub-station operations...",
  "TargetsSet": "1. Reduce AT&C losses to below 15%\n2. Commission new feeder...",
  "TargetsAchieved": "AT&C losses reduced to 14.2%...",
  "ShortfallReasons": null,
  "MajorAchievements": "Commissioned new 33 KV feeder ahead of schedule.",
  "AuditorCompliance": true,
  "PropertyDeclared": true,
  "PropertyDeclaredDate": "2023-06-30",
  "MedicalCompliance": true,
  "MedicalComplianceDate": "2023-05-15"
}
```

> `DocumentPath` field has been removed. Upload documents separately via `POST /api/acr/{acrId}/docs`.

### Success `200`
```json
{ "Success": true, "Message": "Draft saved successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in `PENDING_OFFICER` step | `INVALID_STATE` | 409 |
| Self-appraisal already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 4 — Submit Self-Appraisal
**POST** `/api/acr/{acrId}/self-appraisal/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Finalises the self-appraisal. A draft must exist first.  
**State transition:** `PENDING_OFFICER` → `PENDING_REPORTING`

### Success `200`
```json
{ "Success": true, "Message": "Self-appraisal submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in Officer step | `INVALID_STATE` | 409 |
| Draft never saved | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 5 — Upload Document
**POST** `/api/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Attaches a document to the officer's section. The file must already be uploaded to cloud storage — only the URL is stored here.

**Upload flow:**
1. Frontend requests a pre-signed upload URL from cloud storage (S3/Azure Blob/GCS).
2. Frontend uploads the file directly to cloud storage.
3. Frontend calls this endpoint with the resulting URL.

The server resolves the caller's section automatically (`OFFICER`) — no `section` field is sent by the frontend.

### Request
```json
{
  "FileUrl": "https://storage.example.com/acr/uuid/medical.pdf",
  "FileName": "Annexure_A_Medical.pdf",
  "DocumentType": "MEDICAL_REPORT"
}
```

> `DocumentType` is optional — defaults to `SUPPORTING_DOC` if omitted.

### Success `201`
```json
{
  "Success": true,
  "Message": "Document uploaded successfully",
  "Data": { "DocumentId": "uuid" },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` or `FileName` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not a participant in this ACR | `FORBIDDEN` | 403 |
| ACR step does not allow document uploads for caller | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 6 — Get Documents
**GET** `/api/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns all documents in the caller's section (`OFFICER`).

### Success `200`
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

---

## API 7 — Delete Document
**DELETE** `/api/acr/{acrId}/docs/{documentId}`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Removes a document. Caller can only delete documents in their own section.

### Success `200`
```json
{ "Success": true, "Message": "Document deleted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Document not found or belongs to a different section | `NOT_FOUND` | 404 |
| Caller is not a participant in this ACR | `FORBIDDEN` | 403 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/my` | List caller's ACR cycles |
| GET | `/api/acr/{acrId}` | Get ACR detail + self-appraisal draft + documents |
| PATCH | `/api/acr/{acrId}/self-appraisal/draft` | Save self-appraisal draft (repeatable) |
| POST | `/api/acr/{acrId}/self-appraisal/submit` | Submit self-appraisal |
| POST | `/api/acr/{acrId}/docs` | Upload a document |
| GET | `/api/acr/{acrId}/docs` | List uploaded documents |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |