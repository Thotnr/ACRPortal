# Accepting Authority (AA) API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose

These APIs cover the **Accepting Authority step** — the final step of the ACR workflow:

- AA views ACRs pending their decision.
- AA reads the complete history: self-appraisal, RA1/RA2 assessments, RvA review.
- AA issues a **final decision** (single submit — no draft/submit separation).
- Decision closes the ACR: status transitions to `APPROVED` or `REJECTED`.

**No draft step.** Unlike other layers, the AA submit is one-shot — calling the submit endpoint both writes the decision and closes the ACR atomically.

---

## Architecture

```
AcceptingApiController → IAcceptingUseCase → AcceptingService → IAcceptingRepoPort → AcceptingAdapter
```

---

## Schema Reference

### `dbo.accepting_decisions` (written by AA, post-Migration 7)
One row per ACR: `UNIQUE(acr_id)`.

```sql
[decision_id]        UNIQUEIDENTIFIER PK DEFAULT NEWID()
[acr_id]             UNIQUEIDENTIFIER NOT NULL  UNIQUE  FK → dbo.acr_cycles(acr_id)
[agree_with_previous] BIT             NULL               -- agree with RvA?
[disagree_details]   NVARCHAR(MAX)    NULL               -- added Migration 7
[conflict_resolved]  BIT              NOT NULL DEFAULT 0 -- was RA/RvA conflict resolved?
[final_grade]        DECIMAL(4,2)     NULL               -- changed INT NOT NULL → DECIMAL NULL in Migration 7
[final_remarks]      NVARCHAR(MAX)    NULL
[is_approved]        BIT              NULL               -- changed BIT NOT NULL → BIT NULL in Migration 7
[decided_at]         DATETIME         NULL               -- NULL = not yet decided; set on submit
```

---

## Status / Step Rules

| Status | Who can act |
|---|---|
| `PENDING_ACCEPTING` | AA (`accepting_user_id`) |
| `APPROVED` | Final — ACR closed |
| `REJECTED` | Final — ACR closed |

**Submit transition:**
- `PENDING_ACCEPTING` → `APPROVED` (when `IsApproved = true`)
- `PENDING_ACCEPTING` → `REJECTED` (when `IsApproved = false`)

---

## Models

### `MyAcceptingQueueItem`
```csharp
public class MyAcceptingQueueItem {
  string AcrId;
  string OfficerName;
  string OfficerLoginId;
  string FormType;      // 'A1a' | 'A1b' | 'A2'
  string Department;
  string Location;
  string PostingFrom;   // yyyy-MM-dd
  string PostingTo;     // yyyy-MM-dd
  int    AcrYear;
  string Status;        // always PENDING_ACCEPTING
  bool   IsDecided;     // true if decided_at is not null
  string CreatedAt;     // ISO 8601
}
```

### `AcceptingDecisionRequest`
```csharp
public class AcceptingDecisionRequest {
  bool?    AgreeWithPrevious;  // agree with RvA assessment?
  string   DisagreeDetails;    // required when AgreeWithPrevious = false
  bool     ConflictResolved;   // was any RA/RvA conflict resolved by AA?
  decimal? FinalGrade;         // DECIMAL(4,2), 1-10
  string   FinalRemarks;       // final comments of AA
  bool     IsApproved;         // true → APPROVED, false → REJECTED
}
```

### `AcceptingDecisionView`
```csharp
public class AcceptingDecisionView {
  bool     Exists;
  bool     IsDecided;           // true if decided_at is not null
  string   DecidedAt;           // ISO 8601 | null
  bool?    AgreeWithPrevious;
  string   DisagreeDetails;
  bool     ConflictResolved;
  decimal? FinalGrade;
  string   FinalRemarks;
  bool?    IsApproved;          // null until decided
}
```

### `AcceptingAcrDetailResponse`
```csharp
public class AcceptingAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string Department; string Location; string Designation;
  string PostingFrom; string PostingTo; int AcrYear;

  OfficerLite             Officer;
  SelfAppraisalView       SelfAppraisal;       // officer self-appraisal (read-only)
  ReportingAssessmentView Ra1Assessment;        // RA1 grades (read-only)
  ReportingAssessmentView Ra2Assessment;        // RA2 grades (A1b only; Exists=false otherwise)
  RvaOverrideGradesView   RvaOverrideGrades;   // rva_* override items (read-only)
  ReviewingAssessmentView ReviewingAssessment;  // RvA's review (read-only)
  AcceptingDecisionView   Decision;            // AA's own decision (null until submitted)
}
```

---

## API 1 — My Accepting Queue
**GET** `/api/acr/accepting/my`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns ACR cycles where the caller is `accepting_user_id` and `status = PENDING_ACCEPTING`.

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
        "Status": "PENDING_ACCEPTING",
        "IsDecided": false,
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

## API 2 — Get ACR for Accepting
**GET** `/api/acr/{acrId}/accepting`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the complete ACR history for the AA to review before issuing a decision. Includes officer self-appraisal, all RA assessments, RvA review, RvA override grades, and the AA's own decision (if already submitted).

Access restricted to `accepting_user_id`. Only accessible when `status = PENDING_ACCEPTING`.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_ACCEPTING",
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
      "Exists": true, "IsSubmitted": true,
      "SubmittedAt": "2024-07-01T11:00:00.0000000Z",
      "AgreeWithSelf": true, "DisagreeDetails": null,
      "IntegrityComments": "Integrity beyond doubt", "Remarks": "Good performance",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
      "OverallGrade": 7.61
    },
    "Ra2Assessment": {
      "Exists": true, "IsSubmitted": true,
      "SubmittedAt": "2024-07-10T14:00:00.0000000Z",
      "AgreeWithSelf": true, "DisagreeDetails": null,
      "IntegrityComments": "Concurs with RA1", "Remarks": "Agrees with RA1 assessment",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
      "OverallGrade": 7.61
    },
    "RvaOverrideGrades": {
      "WorkTargets": null, "WorkQuality": null, "WorkExceptional": null,
      "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
      "AttrCommunication": null, "AttrMoralCourage": null,
      "AttrLeadership": null, "AttrTimeliness": null,
      "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
      "CompInitiative": null, "CompTeamwork": null
    },
    "ReviewingAssessment": {
      "Exists": true, "IsSubmitted": true,
      "SubmittedAt": "2024-08-01T10:00:00.0000000Z",
      "AgreeWithRa": true, "DisagreeDetails": null,
      "Comments": "Well-deserved assessment. Officer performed consistently.",
      "OverallGrade": 7.61
    },
    "Decision": {
      "Exists": false,
      "IsDecided": false,
      "DecidedAt": null,
      "AgreeWithPrevious": null,
      "DisagreeDetails": null,
      "ConflictResolved": false,
      "FinalGrade": null,
      "FinalRemarks": null,
      "IsApproved": null
    }
  },
  "ErrorCode": null
}
```

> `Ra2Assessment.Exists` is `false` for A1a/A2 form types.  
> `SelfAppraisal.AuditorCompliance` is `null` for A1a/A2 officers (not applicable).  
> `Decision.Exists` is `false` until the AA submits. After submission the status will have moved to `APPROVED` or `REJECTED` so `PENDING_ACCEPTING` access will no longer apply — the decision is effectively write-once.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the accepting authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_ACCEPTING` step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Submit Decision (finalises ACR)
**POST** `/api/acr/{acrId}/accepting/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Records the AA's final decision and closes the ACR. **One-shot — cannot be repeated.** Once `decided_at` is set the ACR status moves to `APPROVED` or `REJECTED` and is permanently closed.

**State transition:**
- `PENDING_ACCEPTING` → `APPROVED` when `IsApproved = true`
- `PENDING_ACCEPTING` → `REJECTED` when `IsApproved = false`

### Request
```json
{
  "AgreeWithPrevious": true,
  "DisagreeDetails": null,
  "ConflictResolved": false,
  "FinalGrade": 7.61,
  "FinalRemarks": "The officer has performed satisfactorily during the assessment year. ACR is approved.",
  "IsApproved": true
}
```

**Field notes:**
- `DisagreeDetails` — required when `AgreeWithPrevious = false`; explain the nature of disagreement with the RvA.
- `ConflictResolved` — set `true` when there was a prior conflict between RA and RvA that the AA resolved.
- `FinalGrade` — `DECIMAL(4,2)`, range 1–10. The AA may confirm or adjust the RvA's grade.
- `IsApproved` — `true` closes with `APPROVED`; `false` closes with `REJECTED`.

### Success `200`
```json
{ "Success": true, "Message": "Decision submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| Request body missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the accepting authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_ACCEPTING` step | `INVALID_STATE` | 409 |
| Decision already recorded | `ALREADY_DECIDED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/accepting/my` | List accepting queue for caller |
| GET | `/api/acr/{acrId}/accepting` | Get full ACR detail for accepting |
| POST | `/api/acr/{acrId}/accepting/submit` | Submit final decision (closes ACR) |

---

## Registration — required in 4 places

### `UnityConfig.cs`
```csharp
container.RegisterType<IAcceptingRepoPort, AcceptingAdapter>();
container.RegisterType<IAcceptingUseCase,  AcceptingService>();
```

### `ACRPortal.csproj`
```xml
<Compile Include="Controllers\Api\AcceptingApiController.cs" />
```

### `ACRPortal.Application.csproj`
```xml
<Compile Include="port\IAcceptingRepoPort.cs" />
<Compile Include="usecase\IAcceptingUseCase.cs" />
<Compile Include="service\AcceptingService.cs" />
```

### `ACRPortal.Infrastructure.csproj`
```xml
<Compile Include="Adapter\AcceptingAdapter.cs" />
```

### `ACRPortal.Domain.csproj`
```xml
<Compile Include="dtos\WebToApp\AcceptingDTOs.cs" />
```

### `RouteAccessPolicy.cs`
The existing `/api/acr/*` → `EMPLOYEE` mapping already covers all three routes. No new entry needed.

---

## `IAcceptingUseCase` — interface shape
```csharp
ApiResponse<MyAcceptingQueueResponse>   GetMyAcceptingQueue(string userId);
ApiResponse<AcceptingAcrDetailResponse> GetAcceptingDetail(string acrId, string userId);
ApiResponse<EmptyResponse>              SubmitDecision(string acrId, string userId, AcceptingDecisionRequest request);
```

## `IAcceptingRepoPort` — interface shape
```csharp
MyAcceptingQueueResponse    GetMyAcceptingQueue(Guid userId);
AcceptingAcrDetailResponse  GetAcceptingDetail(Guid acrId, Guid userId, out string errorCode);
bool TrySubmitDecision(Guid acrId, Guid userId, AcceptingDecisionRequest request, out string errorCode);
```
