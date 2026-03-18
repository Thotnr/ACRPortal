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

**Draft behaviour:** `acr_cycles.status` stays `PENDING_OFFICER` while the Officer is working. Draft is represented by `self_appraisals.submitted_at = NULL`. Submitting sets `submitted_at` and transitions status to `PENDING_REPORTING`.

---

## Architecture

```
OfficerApiController → IOfficerUseCase → OfficerService → IOfficerRepoPort → OfficerAdapter
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
[designation]     NVARCHAR(200)     NOT NULL   -- snapshot
[posting_from]    DATE              NOT NULL
[posting_to]      DATE              NOT NULL
[acr_year]        INT               NOT NULL
```

### `dbo.self_appraisals` (written by Officer)
```sql
[appraisal_id]           UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]                 UNIQUEIDENTIFIER NOT NULL  UNIQUE  FK → dbo.acr_cycles(acr_id)

-- Section II Item 1
[leave_details]          NVARCHAR(MAX) NULL

-- Section II Item 2
[membership_bodies]      NVARCHAR(MAX) NULL

-- Section II Item 3
[training_details]       NVARCHAR(MAX) NULL

-- Section II Item 4
[awards_honours]         NVARCHAR(MAX) NULL

-- Section II Item 5: Self Assessment Report
[duties_description]     NVARCHAR(MAX) NULL   -- 5(a)
[targets_set]            NVARCHAR(MAX) NULL   -- 5(b)
[targets_achieved]       NVARCHAR(MAX) NULL   -- 5(c)
[shortfall_reasons]      NVARCHAR(MAX) NULL   -- 5(d)
[major_achievements]     NVARCHAR(MAX) NULL   -- 5(e)

-- Section II Item 6 (A1b only)
[auditor_compliance]     BIT           NULL   -- NULL = not applicable (A1a/A2)

-- Declaration
[property_declared]      BIT           NOT NULL DEFAULT 0
[property_declared_date] DATE          NULL
[medical_compliance]     BIT           NOT NULL DEFAULT 0
[medical_compliance_date] DATE         NULL

[document_path]          NVARCHAR(500) NULL
[submitted_at]           DATETIME      NULL   -- NULL = draft
[created_at]             DATETIME      NOT NULL DEFAULT GETDATE()
```

---

## Status / Step Rules

| Status | Meaning |
|---|---|
| `PENDING_OFFICER` | Officer can save drafts and submit |
| `PENDING_REPORTING` | Officer step closed — read-only |
| `PENDING_REPORTING2` | Officer step closed (A1b) |
| `PENDING_REVIEWING` | Officer step closed |
| `PENDING_ACCEPTING` | Officer step closed |
| `APPROVED` / `REJECTED` | Finalised |

> `DRAFT` is a CCA-only pre-submit state — never visible to Officers.

---

## Models

### `MyAcrListItem`
```csharp
public class MyAcrListItem {
  string AcrId;
  string FormType;          // 'A1a' | 'A1b' | 'A2'
  string Department;
  string Location;
  string Designation;
  string PostingFrom;       // yyyy-MM-dd
  string PostingTo;         // yyyy-MM-dd
  int    AcrYear;
  string Status;
  bool   SelfAppraisalSubmitted;
  string CreatedAt;         // ISO 8601
}
```

### `SelfAppraisalDraftRequest`
```csharp
public class SelfAppraisalDraftRequest {
  // Section II Item 1 — Period of absence/leave (both On Leave and Others combined)
  string LeaveDetails           // free text, nullable

  // Section II Item 2
  string MembershipBodies       // nullable

  // Section II Item 3 — Training (free text; date from/to/institution/subject)
  string TrainingDetails        // nullable

  // Section II Item 4
  string AwardsHonours          // nullable

  // Section II Item 5: Self Assessment Report
  string DutiesDescription      // 5(a), nullable
  string TargetsSet             // 5(b), nullable
  string TargetsAchieved        // 5(c), nullable
  string ShortfallReasons       // 5(d), nullable
  string MajorAchievements      // 5(e), nullable

  // Section II Item 6 — A1b only (auditor compliance YES/NO)
  // Send null for A1a/A2 officers — stored as NULL in DB (not applicable)
  bool?  AuditorCompliance      // nullable

  // Declaration: property return
  bool   PropertyDeclared       // YES/NO
  string PropertyDeclaredDate   // yyyy-MM-dd — date filed; null if not filed yet

  // Declaration: medical check-up
  bool   MedicalCompliance      // YES/NO
  string MedicalComplianceDate  // yyyy-MM-dd — date of check-up; null if not done yet

  // Document attachment (e.g. medical Annexure-A)
  string DocumentPath           // nullable
}
```

### `SelfAppraisalView` (read-back in AcrDetailResponse)
Same fields as `SelfAppraisalDraftRequest` plus:
```csharp
bool   Exists        // false if officer has never saved a draft
bool   IsSubmitted   // true once submitted
string SubmittedAt   // ISO 8601 | null
```

### `AcrDetailResponse`
```csharp
public class AcrDetailResponse {
  string AcrId;
  string FormType;
  string Status;
  string Department;
  string Location;
  string Designation;
  string PostingFrom;       // yyyy-MM-dd
  string PostingTo;         // yyyy-MM-dd
  int    AcrYear;
  SelfAppraisalView SelfAppraisal;
}
```

---

## API 1 — List My ACRs
**GET** `/api/acr/my`  
**Query params:** `?status=PENDING_OFFICER` (optional — omit to get all)  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns all ACR cycles belonging to the caller, excluding CCA drafts.

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

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 2 — Get ACR Detail
**GET** `/api/acr/{acrId}`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns posting info plus the current state of the officer's self-appraisal draft (if any).

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
      "TargetsSet": "1. Reduce AT&C losses to below 15%...",
      "TargetsAchieved": "AT&C losses reduced to 14.2%...",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder...",
      "AuditorCompliance": true,
      "PropertyDeclared": true,
      "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true,
      "MedicalComplianceDate": "2023-05-15",
      "DocumentPath": null
    }
  },
  "ErrorCode": null
}
```

> `SelfAppraisal.Exists` is `false` if the officer has never saved a draft.  
> `AuditorCompliance` is `null` for A1a/A2 officers (field not applicable).  
> `PropertyDeclaredDate` and `MedicalComplianceDate` are `null` if not yet filled in.

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

Saves (or updates) the self-appraisal. All fields are optional — only provided fields are stored. Repeatable; can be called multiple times before submission.

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
  "MedicalComplianceDate": "2023-05-15",
  "DocumentPath": null
}
```

**Field notes:**
- `AuditorCompliance` — send `true`/`false` for A1b officers; send `null` for A1a/A2 (stored as NULL — not applicable).
- `PropertyDeclaredDate` / `MedicalComplianceDate` — `yyyy-MM-dd` string or `null`. Stored as DATE in DB.
- All text fields accept `null` to clear a previously saved value.

### Success `200`
```json
{ "Success": true, "Message": "Draft saved successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in `PENDING_OFFICER` step | `INVALID_STATE` | 409 |
| Self-appraisal already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Submit Self-Appraisal
**POST** `/api/acr/{acrId}/self-appraisal/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Finalises the self-appraisal. A draft must have been saved at least once before calling this.  
**State transition:** `PENDING_OFFICER` → `PENDING_REPORTING`

### Success `200`
```json
{ "Success": true, "Message": "Self-appraisal submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in Officer step | `INVALID_STATE` | 409 |
| Draft never saved (no row in self_appraisals) | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/my` | List caller's ACR cycles |
| GET | `/api/acr/{acrId}` | Get ACR detail + current self-appraisal draft |
| PATCH | `/api/acr/{acrId}/self-appraisal/draft` | Save self-appraisal draft (repeatable) |
| POST | `/api/acr/{acrId}/self-appraisal/submit` | Submit self-appraisal (advance to RA) |

---

## `IOfficerUseCase` — interface shape
```csharp
ApiResponse<MyAcrListResponse> GetMyAcrs(string officerUserId, string status);
ApiResponse<AcrDetailResponse> GetAcrDetail(string acrId, string officerUserId);
ApiResponse<EmptyResponse>     SaveSelfAppraisalDraft(string acrId, string officerUserId, SelfAppraisalDraftRequest request);
ApiResponse<EmptyResponse>     SubmitSelfAppraisal(string acrId, string officerUserId);
```

## `IOfficerRepoPort` — interface shape
```csharp
MyAcrListResponse GetMyAcrs(Guid officerUserId, string status);
AcrDetailResponse GetAcrDetail(Guid acrId, Guid officerUserId);
bool TryUpsertSelfAppraisalDraft(Guid acrId, Guid officerUserId, SelfAppraisalDraftRequest request, out string errorCode);
bool TrySubmitSelfAppraisal(Guid acrId, Guid officerUserId, out string errorCode);
```