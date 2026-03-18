# Reporting Officer (RA) API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose
These APIs cover the **Reporting Authority step** of the ACR workflow:

- RA views ACRs pending for them.
- RA saves their assessment as **draft** (repeatable).
- RA submits their assessment to advance the ACR to the next step.

**Draft behavior (RA step):**
- `acr_cycles.status` remains `PENDING_REPORTING` (or `PENDING_REPORTING2` for RA2) while drafting.
- Draft is represented by the relevant submitted timestamp being `NULL`:
  - RA1 draft: `reporting_assessments.ra1_submitted_at = NULL`
  - RA2 draft (A1b only): `reporting_assessments.ra2_submitted_at = NULL`
- Submitting sets the relevant timestamp and advances `acr_cycles.status`.

---

## Architecture
```
ReportingApiController → IReportingUseCase → ReportingService → IReportingRepoPort → ReportingAdapter
```

---

## Schema Reference (relevant columns)

### `dbo.acr_cycles`
```sql
[acr_id]            UNIQUEIDENTIFIER PK
[officer_user_id]   UNIQUEIDENTIFIER NOT NULL
[reporting_user_id] UNIQUEIDENTIFIER NOT NULL   -- RA1
[ra2_user_id]       UNIQUEIDENTIFIER NULL       -- RA2 (A1b only)
[form_type]         VARCHAR(5) NOT NULL          -- 'A1a' | 'A1b' | 'A2'
[status]            VARCHAR(30) NOT NULL
```

### `dbo.reporting_assessments`
One row per ACR: `UNIQUE(acr_id)`.

This table stores three layers of assessment fields (as per your schema migrations):
- **RA1 fields**: prefixed with `ra1_...`
- **RA2 fields** (A1b only): prefixed with `ra2_...`
- **RvA “preview” fields** (stored here in current schema): prefixed with `rva_...`

**Key draft markers**
```sql
[ra1_submitted_at] DATETIME NULL  -- NULL => RA1 draft
[ra2_submitted_at] DATETIME NULL  -- NULL => RA2 draft
```

---

## Status / Step Rules

| Status | Who can act | Meaning |
|---|---|---|
| `PENDING_REPORTING` | RA1 (`reporting_user_id`) | Waiting for RA1 assessment |
| `PENDING_REPORTING2` | RA2 (`ra2_user_id`) | Waiting for RA2 assessment (A1b only) |
| `PENDING_REVIEWING` | (next step) | RA step complete |

**Submit transitions**
- **A1a / A2**: `PENDING_REPORTING` → `PENDING_REVIEWING`
- **A1b (two reporting authorities)**:
  - RA1 submits: `PENDING_REPORTING` → `PENDING_REPORTING2`
  - RA2 submits: `PENDING_REPORTING2` → `PENDING_REVIEWING`

---

## Models

### `MyReportingQueueItem`
```csharp
public class MyReportingQueueItem {
  public string AcrId          { get; set; }
  public string OfficerName    { get; set; }
  public string OfficerLoginId { get; set; }
  public string FormType       { get; set; }   // A1a | A1b | A2
  public string Department     { get; set; }
  public string Location       { get; set; }
  public string PostingFrom    { get; set; }   // yyyy-MM-dd
  public string PostingTo      { get; set; }   // yyyy-MM-dd
  public int    AcrYear        { get; set; }
  public string Status         { get; set; }   // PENDING_REPORTING | PENDING_REPORTING2
  public string ReportingRole  { get; set; }   // "RA1" or "RA2"
  public bool   IsSubmitted    { get; set; }   // true if relevant submitted_at is not null
  public string CreatedAt      { get; set; }   // ISO 8601
}
```

### `MyReportingQueueResponse`
```csharp
public class MyReportingQueueResponse {
  public List<MyReportingQueueItem> AcrCycles { get; set; }
}
```

### `ReportingDraftRequest` (shared shape; server maps to RA1 or RA2)
The payload includes the currently used columns in `dbo.reporting_assessments`.
You can send only the fields relevant to the current RA role (RA1 or RA2); nulls are stored as nulls.

```csharp
public class ReportingDraftRequest {
  // Agreement and narrative
  public bool?   AgreeWithSelf     { get; set; }  // maps to ra1_agree_with_self / ra2_agree_with_self
  public string  DisagreeDetails   { get; set; }  // maps to ra1_disagree_details / ra2_disagree_details
  public string  IntegrityComments { get; set; }  // maps to ra1_integrity_comments / ra2_integrity_comments
  public string  Remarks           { get; set; }  // maps to ra1_remarks / ra2_remarks

  // Work factors
  public byte?   WorkTargets       { get; set; }
  public byte?   WorkQuality       { get; set; }
  public byte?   WorkExceptional   { get; set; }
  public decimal? WorkOverall      { get; set; }

  // Personal attributes
  public byte?   AttrAttitude         { get; set; }
  public byte?   AttrResponsibility   { get; set; }
  public byte?   AttrStability        { get; set; }
  public byte?   AttrCommunication    { get; set; }
  public byte?   AttrMoralCourage     { get; set; }
  public byte?   AttrLeadership       { get; set; }
  public byte?   AttrTimeliness       { get; set; }
  public decimal? AttrOverall         { get; set; }

  // Functional competence
  public byte?   CompKnowledge     { get; set; }
  public byte?   CompPlanning      { get; set; }
  public byte?   CompDecision      { get; set; }
  public byte?   CompInitiative    { get; set; }
  public byte?   CompTeamwork      { get; set; }
  public decimal? CompOverall      { get; set; }

  // Overall grade
  public decimal? OverallGrade     { get; set; }  // maps to ra1_overall_grade / ra2_overall_grade
}
```

---

## API 1 — My Reporting Queue
**GET** `/api/acr/reporting/my`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns ACR cycles where the caller is either:
- `reporting_user_id` and `status = PENDING_REPORTING` (RA1 queue)
- `ra2_user_id` and `status = PENDING_REPORTING2` (RA2 queue, A1b only)

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
        "OfficerName": "Dheeraj Kumar",
        "OfficerLoginId": "ASD2C6",
        "FormType": "A1b",
        "Department": "OP Division, Sirsa",
        "Location": "Sirsa",
        "PostingFrom": "2025-04-01",
        "PostingTo": "2026-03-31",
        "AcrYear": 2025,
        "Status": "PENDING_REPORTING2",
        "ReportingRole": "RA2",
        "IsSubmitted": false,
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

## API 2 — Get ACR for Reporting (Officer + Self + Reporting draft)
**GET** `/api/acr/{acrId}/reporting`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns:
- ACR header fields (department, posting period, form type, status)
- Officer’s self-appraisal (read-only for RA)
- Reporting assessment (draft/submitted) relevant to the caller’s role (RA1 or RA2)

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
    "FormType": "A1b",
    "Status": "PENDING_REPORTING2",
    "Department": "OP Division, Sirsa",
    "Location": "Sirsa",
    "Designation": "Executive Engineer",
    "PostingFrom": "2025-04-01",
    "PostingTo": "2026-03-31",
    "AcrYear": 2025,
    "Officer": {
      "UserId": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "LoginId": "ASD2C6",
      "DisplayName": "Dheeraj Kumar"
    },
    "ReportingRole": "RA2",
    "SelfAppraisal": {
      "Exists": true,
      "IsSubmitted": true,
      "SubmittedAt": "2026-03-18T10:05:00.0000000Z",
      "DutiesDescription": "Worked as ...",
      "TargetsSet": "Targets ...",
      "TargetsAchieved": "Achieved ...",
      "ShortfallReasons": null,
      "MajorAchievements": "....",
      "MembershipBodies": null,
      "TrainingDetails": null,
      "AwardsHonours": null,
      "PropertyReturnDate": "2025-12-31",
      "AuditorCompliance": null,
      "PropertyDeclared": true,
      "MedicalCompliance": true,
      "DocumentPath": null
    },
    "ReportingAssessment": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "AgreeWithSelf": true,
      "DisagreeDetails": null,
      "IntegrityComments": "Integrity is beyond doubt",
      "Remarks": "Good performance",
      "WorkTargets": 8,
      "WorkQuality": 8,
      "WorkExceptional": 7,
      "WorkOverall": 7.75,
      "AttrAttitude": 8,
      "AttrResponsibility": 8,
      "AttrStability": 7,
      "AttrCommunication": 7,
      "AttrMoralCourage": 8,
      "AttrLeadership": 7,
      "AttrTimeliness": 8,
      "AttrOverall": 7.65,
      "CompKnowledge": 8,
      "CompPlanning": 7,
      "CompDecision": 7,
      "CompInitiative": 8,
      "CompTeamwork": 8,
      "CompOverall": 7.60,
      "OverallGrade": 7.70
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
| Caller is not the active RA for this ACR | `FORBIDDEN` | 403 |
| ACR not in Reporting step for this role | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Save Reporting Draft (repeatable)
**PATCH** `/api/acr/{acrId}/reporting/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Saves RA assessment without advancing workflow.

**Rules**
- If status is `PENDING_REPORTING`, only RA1 may save; maps fields to `ra1_*` columns.
- If status is `PENDING_REPORTING2`, only RA2 may save; maps fields to `ra2_*` columns.
- Draft can be saved multiple times; last save wins.
- Does not change `acr_cycles.status`.

### Request
```json
{
  "AgreeWithSelf": true,
  "DisagreeDetails": null,
  "IntegrityComments": "Integrity is beyond doubt",
  "Remarks": "Good performance",

  "WorkTargets": 8,
  "WorkQuality": 8,
  "WorkExceptional": 7,
  "WorkOverall": 7.75,

  "AttrAttitude": 8,
  "AttrResponsibility": 8,
  "AttrStability": 7,
  "AttrCommunication": 7,
  "AttrMoralCourage": 8,
  "AttrLeadership": 7,
  "AttrTimeliness": 8,
  "AttrOverall": 7.65,

  "CompKnowledge": 8,
  "CompPlanning": 7,
  "CompDecision": 7,
  "CompInitiative": 8,
  "CompTeamwork": 8,
  "CompOverall": 7.60,

  "OverallGrade": 7.70
}
```

### Success `200`
```json
{ "Success": true, "Message": "Draft saved successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller not allowed for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for caller | `INVALID_STATE` | 409 |
| Caller already submitted their step | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Submit Reporting Assessment (advance workflow)
**POST** `/api/acr/{acrId}/reporting/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Submits the RA’s assessment and advances `acr_cycles.status`:
- RA1 submit:
  - A1b: `PENDING_REPORTING` → `PENDING_REPORTING2`
  - A1a/A2: `PENDING_REPORTING` → `PENDING_REVIEWING`
- RA2 submit (A1b only): `PENDING_REPORTING2` → `PENDING_REVIEWING`

### Success `200`
```json
{ "Success": true, "Message": "Reporting assessment submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller not allowed for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for caller | `INVALID_STATE` | 409 |
| Draft missing (never saved) | `BAD_REQUEST` | 400 |
| Caller already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reporting/my` | List reporting queue for caller (RA1 + RA2) |
| GET | `/api/acr/{acrId}/reporting` | Get ACR for reporting (includes self + RA draft) |
| PATCH | `/api/acr/{acrId}/reporting/draft` | Save reporting draft (repeatable) |
| POST | `/api/acr/{acrId}/reporting/submit` | Submit reporting assessment (advance status) |

