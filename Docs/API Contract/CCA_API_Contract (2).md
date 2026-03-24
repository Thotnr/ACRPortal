# CCA API Contract
**RoutePrefix:** `api/cca`  
**All responses:** `ApiResponse<T>`  
**Access:** `CCA` role only (enforced by `RouteAccessPolicy`)

---

## Architecture

```
CcaApiController         → ICcaUseCase        → CcaService        → ICcaRepoPort        → CcaAdapter
CcaDocumentApiController → IDocumentUseCase   → DocumentService   → IDocumentRepoPort   → DocumentAdapter
```

---

## Schema Reference — `dbo.acr_cycles` (all columns owned by CCA)

```sql
[acr_id]                       UNIQUEIDENTIFIER  PK  DEFAULT NEWID()
[officer_user_id]              UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[reporting_user_id]            UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)   -- RA1
[ra2_user_id]                  UNIQUEIDENTIFIER  NULL                                 -- A1b only
[reviewing_user_id]            UNIQUEIDENTIFIER  NOT NULL
[accepting_user_id]            UNIQUEIDENTIFIER  NOT NULL
[cca_user_id]                  UNIQUEIDENTIFIER  NOT NULL
[department]                   NVARCHAR(200)     NOT NULL
[location]                     NVARCHAR(200)     NOT NULL
[posting_from]                 DATE              NOT NULL
[posting_to]                   DATE              NOT NULL
[acr_year]                     INT               NOT NULL
[designation]                  NVARCHAR(200)     NOT NULL   -- dsgDesc snapshot
[form_type]                    VARCHAR(5)        NOT NULL   -- 'A1a' | 'A1b' | 'A2'
[date_of_birth]                DATE              NULL
[date_joining_nigam]           DATE              NULL
[date_joining_present_rank]    DATE              NULL
[date_joining_present_station] DATE              NULL
[academic_qualification]       NVARCHAR(500)     NULL
[technical_qualification]      NVARCHAR(500)     NULL
[departmental_exam_passed]     NVARCHAR(500)     NULL
[property_return_date]         DATE              NULL
[last_medical_exam_date]       DATE              NULL
[career_posting_summary]       NVARCHAR(MAX)     NULL
[status]                       VARCHAR(30)       NOT NULL  DEFAULT 'PENDING_OFFICER'
[created_at]                   DATETIME          NOT NULL  DEFAULT GETDATE()
[updated_at]                   DATETIME          NOT NULL  DEFAULT GETDATE()
```

### `dbo.acr_documents`
```sql
[section] VARCHAR(10)  -- 'CCA' for this role
```

> CCA section documents typically include the medical report (Annexure A) uploaded at ACR creation time, and any other supporting documents attached during setup.

---

## Models

### `CreateAcrRequest` / `UpdateDraftAcrRequest`

Both share the same fields. `CreateAcrRequest` adds `SaveAsDraft`.

```csharp
// Required
string OfficerUserId
int    DesignationId
string Department
string Location
string PostingFrom      // yyyy-MM-dd
string PostingTo        // yyyy-MM-dd (must be > PostingFrom; gap ≥ 90 days)
string DateOfBirth      // yyyy-MM-dd
string ReportingUserId  // GUID of RA1
string ReviewingUserId
string AcceptingUserId

// Conditional
string ReportingUserId2 // GUID of RA2 — required for A1b, must be null for A1a/A2

// Optional
string DateJoiningNigam
string DateJoiningPresentRank
string DateJoiningPresentStation
string AcademicQualification
string TechnicalQualification
string DepartmentalExamPassed
string PropertyReturnDate       // yyyy-MM-dd
string LastMedicalExamDate      // yyyy-MM-dd
string CareerPostingSummary

// CreateAcrRequest only
bool   SaveAsDraft

// DocumentPath removed — upload medical report / annexures separately via
// POST /api/cca/acr/{acrId}/docs after the ACR has been created
```

### `CcaAcrDetailResponse`
```csharp
public class CcaAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string OfficerUserId; string OfficerLoginId; string OfficerName;
  int?   DsgId; string DsgDesc;
  string Department; string Location; string PostingFrom; string PostingTo; int AcrYear;
  string DateOfBirth;
  string DateJoiningNigam; string DateJoiningPresentRank; string DateJoiningPresentStation;
  string AcademicQualification; string TechnicalQualification; string DepartmentalExamPassed;
  string PropertyReturnDate; string LastMedicalExamDate;
  string CareerPostingSummary;
  string ReportingAuthorityUserId;   // RA1
  string ReportingAuthority2UserId;  // RA2 — null for A1a/A2
  string ReviewingAuthorityUserId;
  string AcceptingAuthorityUserId;
  string CreatedAt; string UpdatedAt;
  List<AcrDocumentItem> Documents;   // CCA's section docs (section='CCA') — excludes photo
  AcrDocumentItem OfficerPhoto;      // null if not yet uploaded
}
```

### `AcrDocumentItem` / `AddDocumentRequest`
See Officer API Contract for field definitions — identical across all roles.

---

## API 1 — Get Officers List
**GET** `/api/cca/officers`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Officers": [
      { "UserId": "uuid", "LoginId": "EMP001", "DisplayName": "Ramesh Kumar", "DsgId": 1002, "DsgCode": "XEN", "DsgDesc": "Executive Engineer", "FormType": "A1b" },
      { "UserId": "uuid", "LoginId": "EMP002", "DisplayName": "Kuldeep Atri", "DsgId": 1003, "DsgCode": "SE", "DsgDesc": "Superintending Engineer", "FormType": "A1a" }
    ]
  },
  "ErrorCode": null
}
```

---

## API 2 — Get Employees Dropdown
**GET** `/api/cca/employees`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Employees": [
      { "UserId": "uuid", "LoginId": "EMP010", "DisplayName": "Suresh Singh", "DsgId": 1005, "DsgDesc": "Superintending Engineer" }
    ]
  },
  "ErrorCode": null
}
```

---

## API 2A — Suggest Authority Chain From Officer
**GET** `/api/cca/officers/{officerUserId}/authorities/suggestions`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Resolves default authority chain from the selected officer's manager hierarchy:

- `ReportingUserId` = officer's direct manager (`users.manager_id`)
- `ReviewingUserId` = reporting authority's direct manager

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "OfficerUserId": "uuid-officer",
    "ReportingUserId": "uuid-ra1",
    "ReviewingUserId": "uuid-rva"
  },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `officerUserId` missing/invalid GUID | `BAD_REQUEST` | 400 |
| Officer not found | `NOT_FOUND` | 404 |
| Officer is not active EMPLOYEE | `INVALID_OFFICER` | 400 |
| Officer has no manager mapped | `MISSING_RA` | 409 |
| Resolved reporting authority is not active EMPLOYEE | `INVALID_RA` | 409 |
| Reporting authority has no manager mapped | `MISSING_RVA` | 409 |
| Resolved reviewing authority is not active EMPLOYEE | `INVALID_RVA` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 3 — Create ACR
**POST** `/api/cca/acr`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Creates the ACR. Upload medical report or other annexures separately via `POST /api/cca/acr/{acrId}/docs` after creation.

### Request
```json
{
  "OfficerUserId": "uuid",
  "DesignationId": 1002,
  "SaveAsDraft": false,
  "Department": "Operation Division Hisar",
  "Location": "Hisar",
  "PostingFrom": "2023-04-01",
  "PostingTo": "2024-03-31",
  "DateOfBirth": "1982-06-15",
  "DateJoiningNigam": "2008-08-01",
  "DateJoiningPresentRank": "2020-03-10",
  "DateJoiningPresentStation": "2022-07-01",
  "AcademicQualification": "B.Tech (Electrical)",
  "TechnicalQualification": "AMIE, Section B",
  "DepartmentalExamPassed": "Accounts Test 2015",
  "PropertyReturnDate": "2023-06-30",
  "LastMedicalExamDate": "2023-05-15",
  "CareerPostingSummary": "15 years in distribution operations.",
  "ReportingUserId": "uuid-ra1",
  "ReportingUserId2": null,
  "ReviewingUserId": "uuid-rva",
  "AcceptingUserId": "uuid-aa"
}
```

### Success `201`
```json
{
  "Success": true, "Message": "ACR created successfully",
  "Data": { "AcrId": "uuid", "FormType": "A1b", "Status": "PENDING_OFFICER" },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Required field missing | `BAD_REQUEST` | 400 |
| Date field malformed | `BAD_REQUEST` | 400 |
| PostingTo ≤ PostingFrom or gap < 90 days | `BAD_REQUEST` | 400 |
| DesignationId not found / inactive | `INVALID_DESIGNATION` | 400 |
| RA2 required but missing (A1b) | `BAD_REQUEST` | 400 |
| RA2 provided but not allowed (A1a/A2) | `BAD_REQUEST` | 400 |
| Any referenced user not active | `INVALID_OFFICER` / `INVALID_RA` / `INVALID_RA2` / `INVALID_RVA` / `INVALID_AA` | 400 |
| Duplicate ACR | `DUPLICATE_ACR` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 4 — Get ACR List
**GET** `/api/cca/acr`  

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid", "OfficerName": "Ramesh Kumar", "OfficerLoginId": "EMP001",
        "DsgDesc": "Executive Engineer", "FormType": "A1b",
        "Department": "Operation Division Hisar", "Location": "Hisar",
        "PostingFrom": "2023-04-01", "PostingTo": "2024-03-31",
        "AcrYear": 2024, "Status": "PENDING_OFFICER",
        "CreatedAt": "2024-05-01T10:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

---

## API 5 — Get Single ACR Detail
**GET** `/api/cca/acr/{acrId}`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Returns full Section I data plus CCA's uploaded documents.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrId": "uuid", "FormType": "A1b", "Status": "PENDING_REPORTING",
    "OfficerUserId": "uuid", "OfficerLoginId": "EMP001", "OfficerName": "Ramesh Kumar",
    "DsgId": 1002, "DsgDesc": "Executive Engineer",
    "Department": "Operation Division Hisar", "Location": "Hisar",
    "PostingFrom": "2023-04-01", "PostingTo": "2024-03-31", "AcrYear": 2024,
    "DateOfBirth": "1982-06-15",
    "DateJoiningNigam": "2008-08-01",
    "DateJoiningPresentRank": "2020-03-10",
    "DateJoiningPresentStation": "2022-07-01",
    "AcademicQualification": "B.Tech (Electrical)",
    "TechnicalQualification": "AMIE, Section B",
    "DepartmentalExamPassed": "Accounts Test 2015",
    "PropertyReturnDate": "2023-06-30",
    "LastMedicalExamDate": "2023-05-15",
    "CareerPostingSummary": "15 years in distribution operations.",
    "ReportingAuthorityUserId": "uuid-ra1",
    "ReportingAuthority2UserId": "uuid-ra2",
    "ReviewingAuthorityUserId": "uuid-rva",
    "AcceptingAuthorityUserId": "uuid-aa",
    "CreatedAt": "2024-05-01T10:00:00.0000000Z",
    "UpdatedAt": "2024-05-03T14:22:00.0000000Z",
    "Documents": [
      {
        "DocumentId": "uuid", "Section": "CCA", "DocumentType": "MEDICAL_REPORT",
        "FileUrl": "https://storage.example.com/acr/uuid/annexure_a.pdf",
        "FileName": "Annexure_A_Medical.pdf", "UploadedAt": "2024-05-03T14:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

> `Documents` is `[]` if no CCA documents uploaded yet.  
> `ReportingAuthority2UserId` is `null` for A1a/A2 form types.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` missing or invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 6 — Update Draft ACR
**PATCH** `/api/cca/acr/{acrId}`  
ACR must be in `DRAFT` status. Same body as `CreateAcrRequest` excluding `SaveAsDraft`.

### Success `200`
```json
{ "Success": true, "Message": "Draft saved successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Same validation failures as Create | (same codes) | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR belongs to a different CCA | `FORBIDDEN` | 403 |
| ACR is not in DRAFT status | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 7 — Submit Draft ACR
**POST** `/api/cca/acr/{acrId}/submit`  
**State transition:** `DRAFT` → `PENDING_OFFICER`

### Success `200`
```json
{ "Success": true, "Message": "Draft submitted successfully", "Data": {}, "ErrorCode": null }
```

---

## API 8 — Upload Document
**POST** `/api/cca/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Attaches a document to the CCA section. Section `CCA` is resolved server-side. CCA can upload documents when the ACR is in any non-final status (DRAFT, PENDING_OFFICER, etc.).

Typical use: upload the medical report (Annexure A) immediately after creating the ACR.

### Request
```json
{
  "FileUrl": "https://storage.example.com/acr/uuid/annexure_a.pdf",
  "FileName": "Annexure_A_Medical.pdf",
  "DocumentType": "MEDICAL_REPORT"
}
```

> `DocumentType` is optional — defaults to `SUPPORTING_DOC` if omitted.

### Success `201`
```json
{
  "Success": true, "Message": "Document uploaded successfully",
  "Data": { "DocumentId": "uuid" },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` or `FileName` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the CCA for this ACR | `FORBIDDEN` | 403 |
| ACR in a status that does not permit CCA uploads | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 9 — Get Documents
**GET** `/api/cca/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Returns CCA section documents only.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Documents": [
      {
        "DocumentId": "uuid", "Section": "CCA", "DocumentType": "MEDICAL_REPORT",
        "FileUrl": "https://storage.example.com/acr/uuid/annexure_a.pdf",
        "FileName": "Annexure_A_Medical.pdf", "UploadedAt": "2024-05-03T14:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

---

## API 10 — Delete Document
**DELETE** `/api/cca/acr/{acrId}/docs/{documentId}`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Removes a document from the CCA section. Also used to delete the officer photograph (use the `DocumentId` from the `OfficerPhoto` field in the ACR detail response).

### Success `200`
```json
{ "Success": true, "Message": "Document deleted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Document not found or belongs to a different section | `NOT_FOUND` | 404 |
| Caller is not the CCA for this ACR | `FORBIDDEN` | 403 |
| ACR is `APPROVED` or `REJECTED` | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 11 — Upload Officer Photograph
**POST** `/api/cca/acr/{acrId}/photo`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Uploads the officer's photograph. If a photo already exists it is **replaced atomically** — no need to delete first.

`DocumentType` is fixed to `OFFICER_PHOTO` regardless of what the caller sends.

The photograph is returned as `OfficerPhoto` in `GET /api/cca/acr/{acrId}` (separate from the `Documents` list). The `Documents` list never contains the photo.

### Request
```json
{
  "FileUrl": "https://storage.example.com/acr/uuid/officer_photo.jpg",
  "FileName": "Ramesh_Kumar_Photo.jpg"
}
```

### Success `201`
```json
{
  "Success": true,
  "Message": "Officer photo uploaded successfully",
  "Data": { "DocumentId": "uuid" },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the CCA for this ACR | `FORBIDDEN` | 403 |
| ACR is `APPROVED` or `REJECTED` | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/cca/officers` | Officer dropdown (includes FormType) |
| GET | `/api/cca/employees` | Authority dropdowns (RA/RvA/AA) |
| GET | `/api/cca/officers/{officerUserId}/authorities/suggestions` | Suggest RA/RvA from manager chain |
| POST | `/api/cca/acr` | Create a new ACR cycle |
| GET | `/api/cca/acr` | List all ACR cycles |
| GET | `/api/cca/acr/{acrId}` | Get full Section I detail + photo + documents |
| PATCH | `/api/cca/acr/{acrId}` | Save changes to a DRAFT ACR |
| POST | `/api/cca/acr/{acrId}/submit` | Submit DRAFT → PENDING_OFFICER |
| POST | `/api/cca/acr/{acrId}/photo` | Upload (or replace) officer photograph |
| POST | `/api/cca/acr/{acrId}/docs` | Upload a document (section=CCA) |
| GET | `/api/cca/acr/{acrId}/docs` | List CCA's documents (excludes photo) |
| DELETE | `/api/cca/acr/{acrId}/docs/{documentId}` | Delete a document or photo |

---

## Document API — New Endpoint (CcaDocumentApiController)

```
CcaDocumentApiController [RoutePrefix: api/cca]
  POST   /api/cca/acr/{acrId}/photo
  POST   /api/cca/acr/{acrId}/docs
  GET    /api/cca/acr/{acrId}/docs
  DELETE /api/cca/acr/{acrId}/docs/{documentId}
```

This is a separate controller from `CcaApiController` but shares the same `IDocumentUseCase`. The section `CCA` is resolved automatically by `DocumentAdapter.ResolveCallerSection` using the caller's user ID matched against `acr_cycles.cca_user_id`.