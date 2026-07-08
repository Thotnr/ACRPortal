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
- RA **uploads** supporting documents to their section (RA1 or RA2).

**Draft behaviour:** `acr_cycles.status` stays `PENDING_REPORTING` while drafting. Draft is represented by the relevant submitted timestamp being `NULL`. Submitting sets the timestamp and advances the status.

**Document behaviour:** Same flow as Officer — frontend uploads to cloud storage directly, then sends the URL here. Section (RA1 or RA2) is resolved server-side from the caller's user ID.

---

## Architecture

```
ReportingApiController  → IReportingUseCase  → ReportingService  → IReportingRepoPort  → ReportingAdapter
DocumentApiController   → IDocumentUseCase   → DocumentService   → IDocumentRepoPort   → DocumentAdapter
```

---

## Schema Reference

### `dbo.reporting_assessments` (written by RA)
One row per ACR. `document_path` column has been removed — see `dbo.acr_documents`.

### `dbo.acr_documents`
```sql
[section] VARCHAR(10) -- 'RA1' | 'RA2' (resolved server-side from caller identity)
```

---

## Models

### `ReportingDraftRequest`
```csharp
public class ReportingDraftRequest {
  bool?    AgreeWithSelf;
  string   DisagreeDetails;
  string   IntegrityComments;
  string   Remarks;
  byte?    WorkTargets;   byte?    WorkQuality;   byte? WorkExceptional;   decimal? WorkOverall;
  byte?    AttrAttitude;  byte?    AttrResponsibility; byte? AttrStability;
  byte?    AttrCommunication; byte? AttrMoralCourage; byte? AttrLeadership; byte? AttrTimeliness;
  decimal? AttrOverall;
  byte?    CompKnowledge; byte?    CompPlanning;   byte? CompDecision;
  byte?    CompInitiative; byte?   CompTeamwork;   decimal? CompOverall;
  decimal? OverallGrade;
  // DocumentPath removed — use POST /api/acr/{acrId}/docs instead
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
  byte?    WorkTargets;   byte?    WorkQuality;   byte?    WorkExceptional;   decimal? WorkOverall;
  byte?    AttrAttitude;  byte?    AttrResponsibility; byte? AttrStability;
  byte?    AttrCommunication; byte? AttrMoralCourage; byte? AttrLeadership;  byte?    AttrTimeliness;
  decimal? AttrOverall;
  byte?    CompKnowledge; byte?    CompPlanning;   byte?    CompDecision;
  byte?    CompInitiative; byte?   CompTeamwork;   decimal? CompOverall;
  decimal? OverallGrade;
  // DocumentPath removed
}
```

### `ReportingAcrDetailResponse`
```csharp
public class ReportingAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string Department; string Location; string Designation;
  string PostingFrom; string PostingTo; int AcrYear;
  OfficerLite             Officer;
  string                  ReportingRole;       // "RA1" | "RA2"
  SelfAppraisalView       SelfAppraisal;
  ReportingAssessmentView ReportingAssessment;
  // ------------------------------------------------------------------ //
  //  Section I (CCA) — visible to all authorities                      //
  // ------------------------------------------------------------------ //
  string DateOfBirth;
  string DateJoiningNigam;
  string DateJoiningPresentRank;
  string DateJoiningPresentStation;
  string AcademicQualification;
  string TechnicalQualification;
  string DepartmentalExamPassed;
  string PropertyReturnDate;
  string LastMedicalExamDate;
  string CareerPostingSummary;

  // CCA docs/photo for modal reuse across authorities
  List<AcrDocumentItem> Documents;      // section='CCA' (excludes OFFICER_PHOTO)
  AcrDocumentItem OfficerPhoto;         // section='CCA', document_type='OFFICER_PHOTO'

  // Documents uploaded by the caller's current step (section='RA1'|'RA2')
  List<AcrDocumentItem> RoleDocuments;
}
```

### `AcrDocumentItem` / `AddDocumentRequest`
See Officer API Contract for field definitions — identical across all roles.

---

## API 1 — My Reporting Queue
**GET** `/api/acr/reporting/my`  
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

---

## API 2 — Get ACR for Reporting
**GET** `/api/acr/{acrId}/reporting`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the full ACR for the RA including the officer's self-appraisal, the caller's assessment draft, the caller's step attachments (`RoleDocuments`), and the CCA section I attachments (`Documents` / `OfficerPhoto`) for modal reuse.

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
    "Officer": { "UserId": "uuid", "LoginId": "EMP001", "DisplayName": "Ramesh Kumar" },
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
      "TargetsSet": "1. Reduce AT&C losses below 15%",
      "TargetsAchieved": "AT&C losses reduced to 14.2%",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder ahead of schedule.",
      "AuditorCompliance": true,
      "PropertyDeclared": true,
      "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true,
      "MedicalComplianceDate": "2023-05-15"
    },
    "ReportingAssessment": {
      "Exists": true,
      "IsSubmitted": false,
      "SubmittedAt": null,
      "AgreeWithSelf": true,
      "DisagreeDetails": null,
      "IntegrityComments": "Integrity is beyond doubt",
      "Remarks": "Good performance overall",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
      "OverallGrade": 7.61
    },
    "Documents": [
      {
        "DocumentId": "uuid",
        "Section": "CCA",
        "DocumentType": "SUPPORTING_DOC",
        "FileUrl": "https://storage.example.com/acr/uuid/ra1_note.pdf",
        "FileName": "RA1_Supporting_Note.pdf",
        "UploadedAt": "2024-07-01T10:30:00.0000000Z"
      }
    ],
    "OfficerPhoto": null,
    "RoleDocuments": []
  },
  "ErrorCode": null
}
```

> `Documents` contains only the CCA section documents (section='CCA') for modal reuse.  
> `RoleDocuments` contains only the caller's own step documents (section='RA1'|'RA2').  
> `SelfAppraisal.AuditorCompliance` is `null` for A1a/A2 officers.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not an active RA for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for this role | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 3 — Save Reporting Draft
**PATCH** `/api/acr/{acrId}/reporting/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Saves the RA's assessment. Repeatable. Section (RA1 or RA2) is determined server-side.

### Request
```json
{
  "AgreeWithSelf": true,
  "DisagreeDetails": null,
  "IntegrityComments": "Integrity is beyond doubt",
  "Remarks": "Good performance overall",
  "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
  "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
  "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
  "AttrTimeliness": 8, "AttrOverall": 7.57,
  "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
  "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60,
  "OverallGrade": 7.61
}
```

> `DocumentPath` has been removed. Use `POST /api/acr/{acrId}/docs` to attach documents.

### Success `200`
```json
{ "Success": true, "Message": "Draft saved successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| Caller not allowed for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for caller | `INVALID_STATE` | 409 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 4 — Submit Reporting Assessment
**POST** `/api/acr/{acrId}/reporting/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

**State transitions:**
- A1a / A2 (RA1 only): `PENDING_REPORTING` → `PENDING_REVIEWING`
- A1b — first RA to submit: stays `PENDING_REPORTING`
- A1b — second RA to submit: `PENDING_REPORTING` → `PENDING_REVIEWING`

### Success `200`
```json
{ "Success": true, "Message": "Reporting assessment submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| Caller not allowed for this ACR | `FORBIDDEN` | 403 |
| ACR not in reporting step for caller | `INVALID_STATE` | 409 |
| Draft never saved | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 5 — Upload Document
**POST** `/api/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Attaches a document to the caller's section (RA1 or RA2 — resolved server-side).

### Request
```json
{
  "FileUrl": "https://storage.example.com/acr/uuid/ra1_note.pdf",
  "FileName": "RA1_Supporting_Note.pdf",
  "DocumentType": "SUPPORTING_DOC"
}
```

### Success `201`
```json
{ "Success": true, "Message": "Document uploaded successfully", "Data": { "DocumentId": "uuid" }, "ErrorCode": null }
```

---

## API 6 — Get Documents
**GET** `/api/acr/{acrId}/docs`  
Returns documents in the caller's section only.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": { "Documents": [ { "DocumentId": "uuid", "Section": "RA1", "DocumentType": "SUPPORTING_DOC", "FileUrl": "...", "FileName": "RA1_Supporting_Note.pdf", "UploadedAt": "..." } ] },
  "ErrorCode": null
}
```

---

## API 7 — Delete Document
**DELETE** `/api/acr/{acrId}/docs/{documentId}`  
Removes a document from the caller's section.

### Success `200`
```json
{ "Success": true, "Message": "Document deleted successfully", "Data": {}, "ErrorCode": null }
```

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reporting/my` | List reporting queue for caller (RA1 + RA2) |
| GET | `/api/acr/{acrId}/reporting` | Get ACR detail + officer self-appraisal + RA draft + documents |
| PATCH | `/api/acr/{acrId}/reporting/draft` | Save reporting draft (repeatable) |
| POST | `/api/acr/{acrId}/reporting/submit` | Submit reporting assessment |
| POST | `/api/acr/{acrId}/docs` | Upload a document to caller's section |
| GET | `/api/acr/{acrId}/docs` | List documents in caller's section |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |