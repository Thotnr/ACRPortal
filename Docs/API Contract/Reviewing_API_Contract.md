# Reviewing Authority (RvA) API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose

These APIs cover the **Reviewing Authority step** of the ACR workflow:

- RvA views ACRs pending for their review.
- RvA reads the officer's self-appraisal and RA's submitted assessment.
- RvA **saves** their own review as draft (repeatable).
- RvA **submits** their review to advance the ACR to the Accepting Authority.

**Draft behaviour:**
- `acr_cycles.status` stays `PENDING_REVIEWING` while drafting.
- Draft is represented by `reviewing_assessments.submitted_at = NULL`.
- Submitting sets `submitted_at` and transitions status to `PENDING_ACCEPTING`.

---

## Architecture

```
ReviewingApiController → IReviewingUseCase → ReviewingService → IReviewingRepoPort → ReviewingAdapter
```

---

## Schema Reference

### `dbo.reviewing_assessments` (written by RvA, post-Migration 7)
One row per ACR: `UNIQUE(acr_id)`.

```sql
[review_id]       UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]          UNIQUEIDENTIFIER NOT NULL  UNIQUE  FK → dbo.acr_cycles(acr_id)
[agree_with_ra]   BIT              NULL
[disagree_details] NVARCHAR(MAX)   NULL       -- added Migration 7
[remarks]         NVARCHAR(MAX)    NULL        -- "Comments of Reviewing Authority"
[final_grade]     DECIMAL(4,2)     NULL        -- changed INT NOT NULL → DECIMAL NULL in Migration 7
[submitted_at]    DATETIME         NULL        -- NULL = draft
```

### `dbo.reporting_assessments` — rva_* columns (written by RvA, from Migration 4)
These override columns are stored on the reporting_assessments row and are only populated when the RvA disagrees with the RA's numerical grades. There are 15 items — no `rva_*_overall` columns exist.

```sql
-- Work output (3 items)
[rva_work_targets]        TINYINT NULL
[rva_work_quality]        TINYINT NULL
[rva_work_exceptional]    TINYINT NULL

-- Personal attributes (7 items)
[rva_attr_attitude]       TINYINT NULL
[rva_attr_responsibility] TINYINT NULL
[rva_attr_stability]      TINYINT NULL
[rva_attr_communication]  TINYINT NULL
[rva_attr_moral_courage]  TINYINT NULL
[rva_attr_leadership]     TINYINT NULL
[rva_attr_timeliness]     TINYINT NULL

-- Functional competency (5 items)
[rva_comp_knowledge]      TINYINT NULL
[rva_comp_planning]       TINYINT NULL
[rva_comp_decision]       TINYINT NULL
[rva_comp_initiative]     TINYINT NULL
[rva_comp_teamwork]       TINYINT NULL
```

> Note: There are no `rva_work_overall`, `rva_attr_overall`, `rva_comp_overall`, or `rva_overall_grade` columns. The RvA's overall grade goes into `reviewing_assessments.final_grade`.

### `dbo.self_appraisals` (read-only for RvA, post-Migration 7)
See Officer API Contract for the full column list. Key fields visible to RvA:
`leave_details`, `duties_description` through `major_achievements`, `auditor_compliance BIT NULL`, `property_declared`, `property_declared_date`, `medical_compliance`, `medical_compliance_date`.

---

## Status / Step Rules

| Status | Who can act |
|---|---|
| `PENDING_REVIEWING` | RvA (`reviewing_user_id`) |
| `PENDING_ACCEPTING` | Next step — RvA step closed |

**Submit transition:** `PENDING_REVIEWING` → `PENDING_ACCEPTING`

---

## Models

### `MyReviewingQueueItem`
```csharp
public class MyReviewingQueueItem {
  string AcrId;
  string OfficerName;
  string OfficerLoginId;
  string FormType;       // 'A1a' | 'A1b' | 'A2'
  string Department;
  string Location;
  string PostingFrom;    // yyyy-MM-dd
  string PostingTo;      // yyyy-MM-dd
  int    AcrYear;
  string Status;         // always PENDING_REVIEWING
  bool   IsSubmitted;    // true if reviewing_assessments.submitted_at is not null
  string CreatedAt;      // ISO 8601
}
```

### `ReviewingDraftRequest`
```csharp
public class ReviewingDraftRequest {
  // reviewing_assessments fields
  bool?    AgreeWithRa;       // YES/NO agreement with RA assessment
  string   DisagreeDetails;   // required when AgreeWithRa = false
  string   Comments;          // "Comments of Reviewing Authority (if any)"
  decimal? OverallGrade;      // DECIMAL(4,2), 1-10 — goes into reviewing_assessments.final_grade

  // rva_* override grades (reporting_assessments) — send null to leave as-is
  // Only populate when disagreeing with RA's individual item scores
  byte? WorkTargets;
  byte? WorkQuality;
  byte? WorkExceptional;

  byte? AttrAttitude;
  byte? AttrResponsibility;
  byte? AttrStability;
  byte? AttrCommunication;
  byte? AttrMoralCourage;
  byte? AttrLeadership;
  byte? AttrTimeliness;

  byte? CompKnowledge;
  byte? CompPlanning;
  byte? CompDecision;
  byte? CompInitiative;
  byte? CompTeamwork;
}
```

> There are no `WorkOverall`, `AttrOverall`, or `CompOverall` fields in the RvA override block — those columns don't exist in the schema. The RvA's single summary grade is `OverallGrade`.

### `ReviewingAssessmentView` (RvA's own record)
```csharp
public class ReviewingAssessmentView {
  bool     Exists;
  bool     IsSubmitted;
  string   SubmittedAt;      // ISO 8601 | null
  bool?    AgreeWithRa;
  string   DisagreeDetails;
  string   Comments;
  decimal? OverallGrade;
}
```

### `RvaOverrideGradesView` (rva_* from reporting_assessments)
```csharp
public class RvaOverrideGradesView {
  byte? WorkTargets; byte? WorkQuality; byte? WorkExceptional;
  byte? AttrAttitude; byte? AttrResponsibility; byte? AttrStability;
  byte? AttrCommunication; byte? AttrMoralCourage; byte? AttrLeadership; byte? AttrTimeliness;
  byte? CompKnowledge; byte? CompPlanning; byte? CompDecision;
  byte? CompInitiative; byte? CompTeamwork;
}
```

### `ReviewingAcrDetailResponse`
```csharp
public class ReviewingAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string Department; string Location; string Designation;
  string PostingFrom; string PostingTo; int AcrYear;

  OfficerLite             Officer;              // { UserId, LoginId, DisplayName }
  SelfAppraisalView       SelfAppraisal;        // officer's self-appraisal (read-only)
  ReportingAssessmentView Ra1Assessment;         // RA1 grades (read-only)
  ReportingAssessmentView Ra2Assessment;         // RA2 grades (A1b only; Exists=false otherwise)
  ReviewingAssessmentView ReviewingAssessment;   // RvA's own draft/submission
  RvaOverrideGradesView   RvaOverrideGrades;    // rva_* override items (all null if not yet set)
}
```

---

## API 1 — My Reviewing Queue
**GET** `/api/acr/reviewing/my`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns ACR cycles where the caller is `reviewing_user_id` and `status = PENDING_REVIEWING`.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid",
        "OfficerName": "Ramesh Kumar",
        "OfficerLoginId": "EMP001",
        "FormType": "A1b",
        "Department": "Operation Division Hisar",
        "Location": "Hisar",
        "PostingFrom": "2023-04-01",
        "PostingTo": "2024-03-31",
        "AcrYear": 2024,
        "Status": "PENDING_REVIEWING",
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

## API 2 — Get ACR for Reviewing
**GET** `/api/acr/{acrId}/reviewing`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the full ACR for the RvA to review. Includes officer's self-appraisal (read-only), RA1 and RA2 assessments (read-only), and the RvA's own current draft/submission.

Access restricted to the `reviewing_user_id` on the ACR. Only accessible when status is `PENDING_REVIEWING`.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_REVIEWING",
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
    "SelfAppraisal": {
      "Exists": true,
      "IsSubmitted": true,
      "SubmittedAt": "2024-06-01T09:30:00.0000000Z",
      "LeaveDetails": "On EL from 10-Jun-2023 to 20-Jun-2023",
      "MembershipBodies": "IEEE",
      "TrainingDetails": "Energy Audit Training, NPTI Faridabad, 15-Jan-2024 to 19-Jan-2024",
      "AwardsHonours": null,
      "DutiesDescription": "Managed 132 KV sub-station operations...",
      "TargetsSet": "1. Reduce AT&C losses below 15%",
      "TargetsAchieved": "AT&C losses reduced to 14.2%",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder ahead of schedule.",
      "AuditorCompliance": true,
      "PropertyDeclared": true,
      "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true,
      "MedicalComplianceDate": "2023-05-15",
      "DocumentPath": null
    },
    "Ra1Assessment": {
      "Exists": true,
      "IsSubmitted": true,
      "SubmittedAt": "2024-07-01T11:00:00.0000000Z",
      "AgreeWithSelf": true,
      "DisagreeDetails": null,
      "IntegrityComments": "Integrity beyond doubt",
      "Remarks": "Good performance",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
      "OverallGrade": 7.61
    },
    "Ra2Assessment": {
      "Exists": true,
      "IsSubmitted": true,
      "SubmittedAt": "2024-07-10T14:00:00.0000000Z",
      "AgreeWithSelf": true,
      "DisagreeDetails": null,
      "IntegrityComments": "Agree with RA1",
      "Remarks": "Concurs with RA1 assessment",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
      "OverallGrade": 7.61
    },
    "ReviewingAssessment": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "AgreeWithRa": true,
      "DisagreeDetails": null,
      "Comments": "Well-deserved assessment. Officer has performed consistently.",
      "OverallGrade": 7.61
    },
    "RvaOverrideGrades": {
      "WorkTargets": null, "WorkQuality": null, "WorkExceptional": null,
      "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
      "AttrCommunication": null, "AttrMoralCourage": null, "AttrLeadership": null,
      "AttrTimeliness": null,
      "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
      "CompInitiative": null, "CompTeamwork": null
    }
  },
  "ErrorCode": null
}
```

> `Ra2Assessment.Exists` is `false` for A1a/A2 form types.  
> `SelfAppraisal.AuditorCompliance` is `null` for A1a/A2 officers (not applicable).  
> All `RvaOverrideGrades` items are `null` when the RvA agrees with the RA's scores.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Save Reviewing Draft
**PATCH** `/api/acr/{acrId}/reviewing/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Saves the RvA's review without advancing the workflow. Repeatable — last save wins.

Writes to two places:
1. `reviewing_assessments` — `agree_with_ra`, `disagree_details`, `remarks` (comments), `final_grade`
2. `reporting_assessments` `rva_*` columns — individual item overrides (send `null` for items where the RvA agrees)

### Request
```json
{
  "AgreeWithRa": false,
  "DisagreeDetails": "Work targets score overstated — feeder commissioning was delayed by 3 weeks.",
  "Comments": "Officer shows good potential. Scores adjusted on work targets item.",
  "OverallGrade": 7.40,
  "WorkTargets": 6,
  "WorkQuality": null,
  "WorkExceptional": null,
  "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
  "AttrCommunication": null, "AttrMoralCourage": null, "AttrLeadership": null,
  "AttrTimeliness": null,
  "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
  "CompInitiative": null, "CompTeamwork": null
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
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Submit Reviewing Assessment
**POST** `/api/acr/{acrId}/reviewing/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Finalises the RvA's review and advances status.  
**State transition:** `PENDING_REVIEWING` → `PENDING_ACCEPTING`

### Success `200`
```json
{ "Success": true, "Message": "Reviewing assessment submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Draft never saved | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reviewing/my` | List reviewing queue for caller |
| GET | `/api/acr/{acrId}/reviewing` | Get full ACR detail for reviewing |
| PATCH | `/api/acr/{acrId}/reviewing/draft` | Save reviewing draft (repeatable) |
| POST | `/api/acr/{acrId}/reviewing/submit` | Submit reviewing assessment |

---

## Registration — required in 4 places

### `UnityConfig.cs`
```csharp
container.RegisterType<IReviewingRepoPort, ReviewingAdapter>();
container.RegisterType<IReviewingUseCase,  ReviewingService>();
```

### `ACRPortal.csproj` (Compile items)
```xml
<Compile Include="Controllers\Api\ReviewingApiController.cs" />
```

### `ACRPortal.Application.csproj` (Compile items)
```xml
<Compile Include="port\IReviewingRepoPort.cs" />
<Compile Include="usecase\IReviewingUseCase.cs" />
<Compile Include="service\ReviewingService.cs" />
```

### `ACRPortal.Infrastructure.csproj` (Compile items)
```xml
<Compile Include="Adapter\ReviewingAdapter.cs" />
```

### `ACRPortal.Domain.csproj` (Compile items)
```xml
<Compile Include="dtos\WebToApp\ReviewingDTOs.cs" />
```

### `RouteAccessPolicy.cs`
The route prefix `/api/acr/*` is already mapped to the `EMPLOYEE` role — no new entry needed.

---

## `IReviewingUseCase` — interface shape
```csharp
ApiResponse<MyReviewingQueueResponse>   GetMyReviewingQueue(string userId);
ApiResponse<ReviewingAcrDetailResponse> GetReviewingDetail(string acrId, string userId);
ApiResponse<EmptyResponse>              SaveReviewingDraft(string acrId, string userId, ReviewingDraftRequest request);
ApiResponse<EmptyResponse>              SubmitReviewing(string acrId, string userId);
```

## `IReviewingRepoPort` — interface shape
```csharp
MyReviewingQueueResponse    GetMyReviewingQueue(Guid userId);
ReviewingAcrDetailResponse  GetReviewingDetail(Guid acrId, Guid userId, out string errorCode);
bool TryUpsertReviewingDraft(Guid acrId, Guid userId, ReviewingDraftRequest request, out string errorCode);
bool TrySubmitReviewing(Guid acrId, Guid userId, out string errorCode);
```
