# Officer API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose
These APIs cover the **Officer step** of the ACR workflow:

- Officer views ACR cycles assigned to them.
- Officer **saves** their Self-Appraisal as draft (repeatable).
- Officer **submits** their Self-Appraisal to advance the ACR to the Reporting Authority.

**Draft behavior (Officer step):**
- `acr_cycles.status` stays `PENDING_OFFICER` while the Officer is working.
- Draft is represented by `self_appraisals.submitted_at = NULL`.
- Submitting sets `submitted_at` and transitions `acr_cycles.status` to `PENDING_REPORTING`.
- Draft can be saved **multiple times** before submission (idempotent upsert on `self_appraisals`).

---

## Architecture

```
OfficerApiController → IOfficerUseCase → OfficerService → IOfficerRepoPort → OfficerAdapter
```

> Note: This contract defines the target layering for Officer endpoints (same style as Admin/CCA).

---

## Schema Reference (relevant tables)

### `dbo.acr_cycles` (ownership / workflow)
```sql
[acr_id]           UNIQUEIDENTIFIER  PK
[officer_user_id]  UNIQUEIDENTIFIER  NOT NULL
[form_type]        VARCHAR(5)        NOT NULL  -- 'A1a' | 'A1b' | 'A2'
[status]           VARCHAR(30)       NOT NULL  -- includes 'PENDING_OFFICER', 'PENDING_REPORTING', ...
[department]       NVARCHAR(200)     NOT NULL
[location]         NVARCHAR(200)     NOT NULL
[designation]      NVARCHAR(200)     NOT NULL
[posting_from]     DATE              NOT NULL
[posting_to]       DATE              NOT NULL
[acr_year]         INT               NOT NULL
[created_at]       DATETIME          NOT NULL
[updated_at]       DATETIME          NOT NULL
```

### `dbo.self_appraisals` (Officer step)
```sql
[appraisal_id]          UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]                UNIQUEIDENTIFIER NOT NULL  UNIQUE  FK → dbo.acr_cycles(acr_id)

-- Officer-entered fields (current schema)
[duties_description]    NVARCHAR(MAX) NULL
[targets_set]           NVARCHAR(MAX) NULL
[targets_achieved]      NVARCHAR(MAX) NULL
[shortfall_reasons]     NVARCHAR(MAX) NULL
[major_achievements]    NVARCHAR(MAX) NULL
[membership_bodies]     NVARCHAR(MAX) NULL
[training_details]      NVARCHAR(MAX) NULL
[awards_honours]        NVARCHAR(MAX) NULL
[property_return_date]  DATE          NULL
[auditor_compliance]    NVARCHAR(MAX) NULL

[property_declared]     BIT           NOT NULL DEFAULT 0
[medical_compliance]    BIT           NOT NULL DEFAULT 0
[document_path]         NVARCHAR(500) NULL
[submitted_at]          DATETIME      NULL      -- NULL = draft, NOT NULL = submitted
[created_at]            DATETIME      NOT NULL
```

---

## Status / Step Rules

| Status | Meaning (who can act) |
|---|---|
| `PENDING_OFFICER` | Officer can save drafts and submit self-appraisal |
| `PENDING_REPORTING` | Officer step is closed (read-only for officer) |
| `PENDING_REPORTING2` | Officer step is closed (A1b flow) |
| `PENDING_REVIEWING` | Officer step is closed |
| `PENDING_ACCEPTING` | Officer step is closed |
| `APPROVED` | Finalised |
| `REJECTED` | Finalised |

> Note: `DRAFT` is a CCA-only pre-submit state and is not actionable for Officers.

---

## Models

### `MyAcrListItem`
```csharp
public class MyAcrListItem {
  public string AcrId       { get; set; }
  public string FormType    { get; set; }  // 'A1a' | 'A1b' | 'A2'
  public string Department  { get; set; }
  public string Location    { get; set; }
  public string Designation { get; set; }
  public string PostingFrom { get; set; }  // "yyyy-MM-dd"
  public string PostingTo   { get; set; }  // "yyyy-MM-dd"
  public int    AcrYear     { get; set; }
  public string Status      { get; set; }

  // Draft indicator for Officer step
  public bool   SelfAppraisalSubmitted { get; set; }
  public string CreatedAt   { get; set; }  // ISO 8601
}
```

### `MyAcrListResponse`
```csharp
public class MyAcrListResponse {
  public List<MyAcrListItem> AcrCycles { get; set; }
}
```

### `SelfAppraisalDraftRequest`
```csharp
public class SelfAppraisalDraftRequest {
  public string DutiesDescription   { get; set; }
  public string TargetsSet          { get; set; }
  public string TargetsAchieved     { get; set; }
  public string ShortfallReasons    { get; set; }
  public string MajorAchievements   { get; set; }
  public string MembershipBodies    { get; set; }
  public string TrainingDetails     { get; set; }
  public string AwardsHonours       { get; set; }
  public string PropertyReturnDate  { get; set; }  // "yyyy-MM-dd" | null
  public string AuditorCompliance   { get; set; }
  public bool   PropertyDeclared    { get; set; }
  public bool   MedicalCompliance   { get; set; }

  // Optional: if using document uploads
  public string DocumentPath        { get; set; }
}
```

### `AcrDetailResponse` (Officer view)
```csharp
public class AcrDetailResponse {
  public string AcrId       { get; set; }
  public string FormType    { get; set; }
  public string Status      { get; set; }
  public string Department  { get; set; }
  public string Location    { get; set; }
  public string Designation { get; set; }
  public string PostingFrom { get; set; }
  public string PostingTo   { get; set; }
  public int    AcrYear     { get; set; }

  public SelfAppraisalView SelfAppraisal { get; set; }
}

public class SelfAppraisalView {
  public bool   Exists                { get; set; }
  public bool   IsSubmitted           { get; set; } // submitted_at != null
  public string SubmittedAt           { get; set; } // ISO 8601 | null

  public string DutiesDescription     { get; set; }
  public string TargetsSet            { get; set; }
  public string TargetsAchieved       { get; set; }
  public string ShortfallReasons      { get; set; }
  public string MajorAchievements     { get; set; }
  public string MembershipBodies      { get; set; }
  public string TrainingDetails       { get; set; }
  public string AwardsHonours         { get; set; }
  public string PropertyReturnDate    { get; set; } // "yyyy-MM-dd" | null
  public string AuditorCompliance     { get; set; }
  public bool   PropertyDeclared      { get; set; }
  public bool   MedicalCompliance     { get; set; }
  public string DocumentPath          { get; set; }
}
```

---

## API 1 — List My ACRs (Officer queue)
**GET** `/api/acr/my?status=PENDING_OFFICER`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns ACR cycles where the caller is `officer_user_id`.  
If `status` is omitted, returns all ACRs for the officer (including historical).

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
        "FormType": "A1a",
        "Department": "OP Division, Sirsa",
        "Location": "Sirsa",
        "Designation": "Superintending Engineer",
        "PostingFrom": "2025-04-01",
        "PostingTo": "2026-03-31",
        "AcrYear": 2025,
        "Status": "PENDING_OFFICER",
        "SelfAppraisalSubmitted": false,
        "CreatedAt": "2026-03-17T11:45:00"
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
| Role not EMPLOYEE | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 2 — Get ACR Detail (Officer view)
**GET** `/api/acr/{acrId}`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the ACR header + officer’s self-appraisal (draft or submitted).

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
    "FormType": "A1a",
    "Status": "PENDING_OFFICER",
    "Department": "OP Division, Sirsa",
    "Location": "Sirsa",
    "Designation": "Superintending Engineer",
    "PostingFrom": "2025-04-01",
    "PostingTo": "2026-03-31",
    "AcrYear": 2025,
    "SelfAppraisal": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "DutiesDescription": "....",
      "TargetsSet": null,
      "TargetsAchieved": null,
      "ShortfallReasons": null,
      "MajorAchievements": null,
      "MembershipBodies": null,
      "TrainingDetails": null,
      "AwardsHonours": null,
      "PropertyReturnDate": null,
      "AuditorCompliance": null,
      "PropertyDeclared": false,
      "MedicalCompliance": false,
      "DocumentPath": null
    }
  },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Save Self-Appraisal Draft (repeatable)
**PATCH** `/api/acr/{acrId}/self-appraisal/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Creates or updates the officer’s self-appraisal record for the ACR.

**Rules**
- Allowed only when `acr_cycles.status = 'PENDING_OFFICER'`.
- Does **not** change `acr_cycles.status`.
- Sets/keeps `self_appraisals.submitted_at = NULL`.
- Can be called multiple times; last save wins.

### Request
```json
{
  "DutiesDescription": "Worked as ...",
  "TargetsSet": "Targets ...",
  "TargetsAchieved": "Achieved ...",
  "ShortfallReasons": "Reasons ...",
  "MajorAchievements": "Achievements ...",
  "MembershipBodies": "Bodies ...",
  "TrainingDetails": "Trainings ...",
  "AwardsHonours": "Awards ...",
  "PropertyReturnDate": "2025-12-31",
  "AuditorCompliance": "Complied ...",
  "PropertyDeclared": true,
  "MedicalCompliance": true,
  "DocumentPath": null
}
```

### Success `200`
```json
{
  "Success": true,
  "Message": "Draft saved successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in Officer step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Submit Self-Appraisal (advance workflow)
**POST** `/api/acr/{acrId}/self-appraisal/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Marks the self-appraisal as submitted and advances the workflow.

**State transition:** `PENDING_OFFICER` → `PENDING_REPORTING`

### Success `200`
```json
{
  "Success": true,
  "Message": "Self-appraisal submitted successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR does not belong to caller | `FORBIDDEN` | 403 |
| ACR not in Officer step | `INVALID_STATE` | 409 |
| Self-appraisal missing (never saved) | `BAD_REQUEST` | 400 |
| Self-appraisal already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## `IOfficerUseCase` — interface shape
```csharp
public interface IOfficerUseCase {
  ApiResponse<MyAcrListResponse> GetMyAcrs(string officerUserId, string status);
  ApiResponse<AcrDetailResponse> GetAcrDetail(string acrId, string officerUserId);
  ApiResponse<EmptyResponse>     SaveSelfAppraisalDraft(string acrId, string officerUserId, SelfAppraisalDraftRequest request);
  ApiResponse<EmptyResponse>     SubmitSelfAppraisal(string acrId, string officerUserId);
}
```

## `IOfficerRepoPort` — interface shape
```csharp
public interface IOfficerRepoPort {
  MyAcrListResponse GetMyAcrs(Guid officerUserId, string status);
  AcrDetailResponse GetAcrDetail(Guid acrId, Guid officerUserId);
  bool TryUpsertSelfAppraisalDraft(Guid acrId, Guid officerUserId, SelfAppraisalDraftRequest request, out string errorCode);
  bool TrySubmitSelfAppraisal(Guid acrId, Guid officerUserId, out string errorCode);
}
```

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/my` | List caller’s ACR cycles |
| GET | `/api/acr/{acrId}` | Get ACR detail for officer |
| PATCH | `/api/acr/{acrId}/self-appraisal/draft` | Save self-appraisal draft (repeatable) |
| POST | `/api/acr/{acrId}/self-appraisal/submit` | Submit self-appraisal (advance status) |

