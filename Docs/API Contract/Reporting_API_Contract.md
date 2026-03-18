# Reporting Officer (RA) API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose

These APIs cover the **Reporting Authority step** of the ACR workflow:

- RA views ACRs pending for them.
- RA **saves** their assessment as draft (repeatable, idempotent).
- RA **submits** their assessment to advance the ACR to the next step.

**Draft behaviour:**
- `acr_cycles.status` stays `PENDING_REPORTING` (or `PENDING_REPORTING2` for RA2) while drafting.
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

## Schema Reference

### `dbo.acr_cycles` (read-only for RA)
```sql
[acr_id]            UNIQUEIDENTIFIER  PK
[officer_user_id]   UNIQUEIDENTIFIER  NOT NULL
[reporting_user_id] UNIQUEIDENTIFIER  NOT NULL   -- RA1
[ra2_user_id]       UNIQUEIDENTIFIER  NULL       -- RA2 (A1b only)
[form_type]         VARCHAR(5)        NOT NULL   -- 'A1a' | 'A1b' | 'A2'
[status]            VARCHAR(30)       NOT NULL
[department]        NVARCHAR(200)     NOT NULL
[location]          NVARCHAR(200)     NOT NULL
[designation]       NVARCHAR(200)     NOT NULL
[posting_from]      DATE              NOT NULL
[posting_to]        DATE              NOT NULL
[acr_year]          INT               NOT NULL
```

### `dbo.self_appraisals` (read-only for RA — filled by Officer)
```sql
[appraisal_id]           UNIQUEIDENTIFIER PK
[acr_id]                 UNIQUEIDENTIFIER NOT NULL  UNIQUE

-- Section II Item 1
[leave_details]          NVARCHAR(MAX) NULL

-- Section II Item 2
[membership_bodies]      NVARCHAR(MAX) NULL

-- Section II Item 3
[training_details]       NVARCHAR(MAX) NULL

-- Section II Item 4
[awards_honours]         NVARCHAR(MAX) NULL

-- Section II Item 5
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
[submitted_at]           DATETIME      NULL   -- NULL = officer draft, NOT NULL = submitted
[created_at]             DATETIME      NOT NULL
```

### `dbo.reporting_assessments` (written by RA)
One row per ACR: `UNIQUE(acr_id)`. Row is created on first draft save.

```sql
[assessment_id]          UNIQUEIDENTIFIER PK
[acr_id]                 UNIQUEIDENTIFIER NOT NULL  UNIQUE

-- RA1 fields
[ra1_submitted_at]       DATETIME NULL    -- NULL = RA1 draft
[ra1_agree_with_self]    BIT NULL
[ra1_disagree_details]   NVARCHAR(MAX) NULL
[ra1_integrity_comments] NVARCHAR(MAX) NULL
[ra1_remarks]            NVARCHAR(MAX) NULL
[ra1_work_targets]       TINYINT NULL     -- 1-10
[ra1_work_quality]       TINYINT NULL
[ra1_work_exceptional]   TINYINT NULL
[ra1_work_overall]       DECIMAL(4,2) NULL
[ra1_attr_attitude]      TINYINT NULL
[ra1_attr_responsibility] TINYINT NULL
[ra1_attr_stability]     TINYINT NULL
[ra1_attr_communication] TINYINT NULL
[ra1_attr_moral_courage] TINYINT NULL
[ra1_attr_leadership]    TINYINT NULL
[ra1_attr_timeliness]    TINYINT NULL
[ra1_attr_overall]       DECIMAL(4,2) NULL
[ra1_comp_knowledge]     TINYINT NULL
[ra1_comp_planning]      TINYINT NULL
[ra1_comp_decision]      TINYINT NULL
[ra1_comp_initiative]    TINYINT NULL
[ra1_comp_teamwork]      TINYINT NULL
[ra1_comp_overall]       DECIMAL(4,2) NULL
[ra1_overall_grade]      DECIMAL(4,2) NULL

-- RA2 fields (A1b only — same structure, ra2_ prefix)
[ra2_submitted_at]       DATETIME NULL
[ra2_agree_with_self]    BIT NULL
[ra2_disagree_details]   NVARCHAR(MAX) NULL
[ra2_integrity_comments] NVARCHAR(MAX) NULL
[ra2_remarks]            NVARCHAR(MAX) NULL
-- ... (same 15 grade columns as ra1_*, with ra2_ prefix)
[ra2_overall_grade]      DECIMAL(4,2) NULL
```

---

## Status / Step Rules

| Status | Who can act | Meaning |
|---|---|---|
| `PENDING_REPORTING` | RA1 (`reporting_user_id`) | Waiting for RA1 assessment |
| `PENDING_REPORTING2` | RA2 (`ra2_user_id`) | Waiting for RA2 assessment (A1b only) |
| `PENDING_REVIEWING` | RvA | RA step complete |

**Submit transitions:**
- A1a / A2: `PENDING_REPORTING` → `PENDING_REVIEWING`
- A1b RA1 submits: `PENDING_REPORTING` → `PENDING_REPORTING2`
- A1b RA2 submits: `PENDING_REPORTING2` → `PENDING_REVIEWING`

---

## Models

### `MyReportingQueueItem`
```csharp
public class MyReportingQueueItem {
  string AcrId;
  string OfficerName;
  string OfficerLoginId;
  string FormType;       // 'A1a' | 'A1b' | 'A2'
  string Department;
  string Location;
  string PostingFrom;    // yyyy-MM-dd
  string PostingTo;      // yyyy-MM-dd
  int    AcrYear;
  string Status;         // PENDING_REPORTING | PENDING_REPORTING2
  string ReportingRole;  // "RA1" | "RA2"
  bool   IsSubmitted;    // true if caller's submitted_at is not null
  string CreatedAt;      // ISO 8601
}
```

### `SelfAppraisalView` (read-only for RA)
```csharp
public class SelfAppraisalView {
  bool   Exists;
  bool   IsSubmitted;
  string SubmittedAt;            // ISO 8601 | null

  // Section II Item 1
  string LeaveDetails;           // nullable

  // Section II Item 2
  string MembershipBodies;       // nullable

  // Section II Item 3
  string TrainingDetails;        // nullable

  // Section II Item 4
  string AwardsHonours;          // nullable

  // Section II Item 5
  string DutiesDescription;      // nullable
  string TargetsSet;             // nullable
  string TargetsAchieved;        // nullable
  string ShortfallReasons;       // nullable
  string MajorAchievements;      // nullable

  // Section II Item 6 (A1b only)
  bool?  AuditorCompliance;      // null = not applicable (A1a/A2)

  // Declaration
  bool   PropertyDeclared;
  string PropertyDeclaredDate;   // yyyy-MM-dd | null
  bool   MedicalCompliance;
  string MedicalComplianceDate;  // yyyy-MM-dd | null

  string DocumentPath;           // nullable
}
```

### `ReportingDraftRequest`
Server maps fields to `ra1_*` or `ra2_*` columns based on caller role. All fields are optional — send only what is being filled; nulls are stored as-is.

```csharp
public class ReportingDraftRequest {
  // Agreement
  bool?    AgreeWithSelf;       // ra1_agree_with_self / ra2_agree_with_self
  string   DisagreeDetails;     // ra1_disagree_details / ra2_disagree_details
  string   IntegrityComments;   // ra1_integrity_comments / ra2_integrity_comments
  string   Remarks;             // ra1_remarks / ra2_remarks

  // Work output (scale 1–10, whole numbers for individual items)
  byte?    WorkTargets;
  byte?    WorkQuality;
  byte?    WorkExceptional;
  decimal? WorkOverall;         // average to 2 decimal places

  // Personnel attributes (scale 1–10)
  byte?    AttrAttitude;
  byte?    AttrResponsibility;
  byte?    AttrStability;
  byte?    AttrCommunication;
  byte?    AttrMoralCourage;
  byte?    AttrLeadership;
  byte?    AttrTimeliness;
  decimal? AttrOverall;

  // Functional competency (scale 1–10)
  byte?    CompKnowledge;
  byte?    CompPlanning;
  byte?    CompDecision;
  byte?    CompInitiative;
  byte?    CompTeamwork;
  decimal? CompOverall;

  // Overall grade — average of all 15 items, rounded to 2 decimal places
  decimal? OverallGrade;
}
```

### `ReportingAssessmentView`
```csharp
public class ReportingAssessmentView {
  bool     Exists;
  bool     IsSubmitted;
  string   SubmittedAt;          // ISO 8601 | null

  bool?    AgreeWithSelf;
  string   DisagreeDetails;
  string   IntegrityComments;
  string   Remarks;

  byte?    WorkTargets;
  byte?    WorkQuality;
  byte?    WorkExceptional;
  decimal? WorkOverall;

  byte?    AttrAttitude;
  byte?    AttrResponsibility;
  byte?    AttrStability;
  byte?    AttrCommunication;
  byte?    AttrMoralCourage;
  byte?    AttrLeadership;
  byte?    AttrTimeliness;
  decimal? AttrOverall;

  byte?    CompKnowledge;
  byte?    CompPlanning;
  byte?    CompDecision;
  byte?    CompInitiative;
  byte?    CompTeamwork;
  decimal? CompOverall;

  decimal? OverallGrade;
}
```

### `ReportingAcrDetailResponse`
```csharp
public class ReportingAcrDetailResponse {
  string AcrId;
  string FormType;
  string Status;
  string Department;
  string Location;
  string Designation;
  string PostingFrom;            // yyyy-MM-dd
  string PostingTo;              // yyyy-MM-dd
  int    AcrYear;

  OfficerLite           Officer;            // { UserId, LoginId, DisplayName }
  string                ReportingRole;      // "RA1" | "RA2"
  SelfAppraisalView     SelfAppraisal;
  ReportingAssessmentView ReportingAssessment;
}
```

---

## API 1 — My Reporting Queue
**GET** `/api/acr/reporting/my`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns ACR cycles where the caller is RA1 (`status = PENDING_REPORTING`) or RA2 (`status = PENDING_REPORTING2`).

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid",
        "OfficerName": "Dheeraj Kumar",
        "OfficerLoginId": "EMP002",
        "FormType": "A1b",
        "Department": "Operation Division Hisar",
        "Location": "Hisar",
        "PostingFrom": "2023-04-01",
        "PostingTo": "2024-03-31",
        "AcrYear": 2024,
        "Status": "PENDING_REPORTING",
        "ReportingRole": "RA1",
        "IsSubmitted": false,
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

## API 2 — Get ACR for Reporting
**GET** `/api/acr/{acrId}/reporting`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns full ACR data for the RA to fill in their assessment. Includes:
- ACR header (posting details, form type, status)
- Officer identity
- Officer's complete self-appraisal (read-only for RA)
- Caller's own assessment draft (RA1 or RA2 fields depending on status)

Access is restricted to the active RA for the current step — if you are RA1 you can only access when status is `PENDING_REPORTING`; RA2 only when `PENDING_REPORTING2`.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_REPORTING",
    "Department": "Operation Division Hisar",
    "Location": "Hisar",
    "Designation": "Executive Engineer",
    "PostingFrom": "2023-04-01",
    "PostingTo": "2024-03-31",
    "AcrYear": 2024,
    "Officer": {
      "UserId": "uuid-officer",
      "LoginId": "EMP001",
      "DisplayName": "Ramesh Kumar"
    },
    "ReportingRole": "RA1",
    "SelfAppraisal": {
      "Exists": true,
      "IsSubmitted": true,
      "SubmittedAt": "2024-06-01T09:30:00.0000000Z",
      "LeaveDetails": "On EL from 10-Jun-2023 to 20-Jun-2023",
      "MembershipBodies": "IEEE",
      "TrainingDetails": "Energy Audit Training, NPTI Faridabad, 15-Jan-2024 to 19-Jan-2024",
      "AwardsHonours": null,
      "DutiesDescription": "Managed 132 KV sub-station operations...",
      "TargetsSet": "1. Reduce AT&C losses below 15%\n2. Commission new feeder",
      "TargetsAchieved": "AT&C losses reduced to 14.2%...",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder ahead of schedule.",
      "AuditorCompliance": true,
      "PropertyDeclared": true,
      "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true,
      "MedicalComplianceDate": "2023-05-15",
      "DocumentPath": null
    },
    "ReportingAssessment": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "AgreeWithSelf": true,
      "DisagreeDetails": null,
      "IntegrityComments": "Integrity is beyond doubt",
      "Remarks": "Good performance overall",
      "WorkTargets": 8,
      "WorkQuality": 8,
      "WorkExceptional": 7,
      "WorkOverall": 7.67,
      "AttrAttitude": 8,
      "AttrResponsibility": 8,
      "AttrStability": 7,
      "AttrCommunication": 7,
      "AttrMoralCourage": 8,
      "AttrLeadership": 7,
      "AttrTimeliness": 8,
      "AttrOverall": 7.57,
      "CompKnowledge": 8,
      "CompPlanning": 7,
      "CompDecision": 7,
      "CompInitiative": 8,
      "CompTeamwork": 8,
      "CompOverall": 7.60,
      "OverallGrade": 7.61
    }
  },
  "ErrorCode": null
}
```

> `SelfAppraisal.AuditorCompliance` is `null` for A1a/A2 officers (field not applicable).  
> `SelfAppraisal.PropertyDeclaredDate` and `MedicalComplianceDate` are `null` if the officer did not fill them in.  
> `ReportingAssessment.Exists` is `false` if the RA has never saved a draft.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the active RA for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for this role | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Save Reporting Draft
**PATCH** `/api/acr/{acrId}/reporting/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Saves the RA's assessment without advancing the workflow. Repeatable — last save wins.

- Status `PENDING_REPORTING` → caller must be RA1 → fields written to `ra1_*` columns.
- Status `PENDING_REPORTING2` → caller must be RA2 → fields written to `ra2_*` columns.

### Request
```json
{
  "AgreeWithSelf": true,
  "DisagreeDetails": null,
  "IntegrityComments": "Integrity is beyond doubt",
  "Remarks": "Good performance overall",
  "WorkTargets": 8,
  "WorkQuality": 8,
  "WorkExceptional": 7,
  "WorkOverall": 7.67,
  "AttrAttitude": 8,
  "AttrResponsibility": 8,
  "AttrStability": 7,
  "AttrCommunication": 7,
  "AttrMoralCourage": 8,
  "AttrLeadership": 7,
  "AttrTimeliness": 8,
  "AttrOverall": 7.57,
  "CompKnowledge": 8,
  "CompPlanning": 7,
  "CompDecision": 7,
  "CompInitiative": 8,
  "CompTeamwork": 8,
  "CompOverall": 7.60,
  "OverallGrade": 7.61
}
```

**Grade computation:** `OverallGrade` is the average of all 15 individual items (3 work + 7 attr + 5 comp), rounded to 2 decimal places. The server does **not** compute this automatically — the frontend sends it. Individual items are whole numbers 1–10; averages are `DECIMAL(4,2)`.

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
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Submit Reporting Assessment
**POST** `/api/acr/{acrId}/reporting/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Finalises the RA's assessment and advances `acr_cycles.status`.

**State transitions:**
- RA1 (A1a/A2): `PENDING_REPORTING` → `PENDING_REVIEWING`
- RA1 (A1b): `PENDING_REPORTING` → `PENDING_REPORTING2`
- RA2 (A1b): `PENDING_REPORTING2` → `PENDING_REVIEWING`

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
| Draft never saved | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reporting/my` | List reporting queue for caller (RA1 + RA2) |
| GET | `/api/acr/{acrId}/reporting` | Get ACR detail for reporting (self-appraisal + RA draft) |
| PATCH | `/api/acr/{acrId}/reporting/draft` | Save reporting draft (repeatable) |
| POST | `/api/acr/{acrId}/reporting/submit` | Submit reporting assessment (advance status) |

---

## `IReportingUseCase` — interface shape
```csharp
ApiResponse<MyReportingQueueResponse>    GetMyReportingQueue(string userId);
ApiResponse<ReportingAcrDetailResponse>  GetReportingDetail(string acrId, string userId);
ApiResponse<EmptyResponse>               SaveReportingDraft(string acrId, string userId, ReportingDraftRequest request);
ApiResponse<EmptyResponse>               SubmitReporting(string acrId, string userId);
```

## `IReportingRepoPort` — interface shape
```csharp
MyReportingQueueResponse    GetMyReportingQueue(Guid userId);
ReportingAcrDetailResponse  GetReportingDetail(Guid acrId, Guid userId, out string errorCode);
bool TryUpsertReportingDraft(Guid acrId, Guid userId, ReportingDraftRequest request, out string errorCode);
bool TrySubmitReporting(Guid acrId, Guid userId, out string errorCode);
```