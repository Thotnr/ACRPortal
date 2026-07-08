# Reviewing Authority (RvA) API Contract
**RoutePrefix:** `api/acr`  
**All responses:** `ApiResponse<T>`  
**Access:** `EMPLOYEE` role only (enforced by `RouteAccessPolicy`)

---

## Purpose

These APIs cover the **Reviewing Authority step** of the ACR workflow:

- RvA views ACRs pending for their review.
- RvA reads the officer's self-appraisal and both RA assessments.
- RvA **saves** their own review as draft (repeatable).
- RvA **submits** their review to advance the ACR to the Accepting Authority.
- RvA **uploads** supporting documents to their section (`RVA`).

**Document behaviour:** Frontend uploads file directly to cloud storage, then sends the URL here. Section `RVA` is resolved server-side.

---

## Architecture

```
ReviewingApiController  → IReviewingUseCase  → ReviewingService  → IReviewingRepoPort  → ReviewingAdapter
DocumentApiController   → IDocumentUseCase   → DocumentService   → IDocumentRepoPort   → DocumentAdapter
```

---

## Schema Reference

### `dbo.reviewing_assessments` (written by RvA)
`document_path` column has been removed — documents are now in `dbo.acr_documents` with `section = 'RVA'`.

### `dbo.acr_documents`
```sql
[section] VARCHAR(10)  -- 'RVA' for this role
```

---

## Models

### `ReviewingDraftRequest`
```csharp
public class ReviewingDraftRequest {
  bool?    AgreeWithRa;
  string   DisagreeDetails;
  string   Comments;
  decimal? OverallGrade;       // DECIMAL(4,2), 1-10
  // rva_* override grades (15 items — send null to leave as-is)
  byte? WorkTargets; byte? WorkQuality; byte? WorkExceptional;
  byte? AttrAttitude; byte? AttrResponsibility; byte? AttrStability;
  byte? AttrCommunication; byte? AttrMoralCourage; byte? AttrLeadership; byte? AttrTimeliness;
  byte? CompKnowledge; byte? CompPlanning; byte? CompDecision; byte? CompInitiative; byte? CompTeamwork;
  // DocumentPath removed — use POST /api/acr/{acrId}/docs instead
}
```

### `ReviewingAssessmentView`
```csharp
public class ReviewingAssessmentView {
  bool     Exists;
  bool     IsSubmitted;
  string   SubmittedAt;    // ISO 8601 | null
  bool?    AgreeWithRa;
  string   DisagreeDetails;
  string   Comments;
  decimal? OverallGrade;
  // DocumentPath removed
}
```

### `ReviewingAcrDetailResponse`
```csharp
public class ReviewingAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string Department; string Location; string Designation;
  string PostingFrom; string PostingTo; int AcrYear;
  OfficerLite             Officer;
  SelfAppraisalView       SelfAppraisal;
  ReportingAssessmentView Ra1Assessment;
  ReportingAssessmentView Ra2Assessment;         // Exists=false for A1a/A2
  ReviewingAssessmentView ReviewingAssessment;
  RvaOverrideGradesView   RvaOverrideGrades;

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
  List<AcrDocumentItem> Documents;             // section='CCA' (excludes OFFICER_PHOTO)
  AcrDocumentItem OfficerPhoto;                // section='CCA', document_type='OFFICER_PHOTO'

  // Documents uploaded by the caller's current step (section='RVA')
  List<AcrDocumentItem> RoleDocuments;
}
```

---

## API 1 — My Reviewing Queue
**GET** `/api/acr/reviewing/my`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid", "OfficerName": "Ramesh Kumar", "OfficerLoginId": "EMP001",
        "FormType": "A1b", "Department": "Operation Division Hisar", "Location": "Hisar",
        "PostingFrom": "2023-04-01", "PostingTo": "2024-03-31", "AcrYear": 2024,
        "Status": "PENDING_REVIEWING", "IsSubmitted": false,
        "CreatedAt": "2024-05-01T10:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

---

## API 2 — Get ACR for Reviewing
**GET** `/api/acr/{acrId}/reviewing`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the complete ACR including self-appraisal, both RA assessments, RvA's own draft, rva override grades, the caller's step attachments (`RoleDocuments`), and the CCA section I attachments (`Documents` / `OfficerPhoto`) for modal reuse.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrId": "uuid", "FormType": "A1b", "Status": "PENDING_REVIEWING",
    "Department": "Operation Division Hisar", "Location": "Hisar",
    "Designation": "Executive Engineer",
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
    "Officer": { "UserId": "uuid", "LoginId": "EMP001", "DisplayName": "Ramesh Kumar" },
    "SelfAppraisal": {
      "Exists": true, "IsSubmitted": true,
      "SubmittedAt": "2024-06-01T09:30:00.0000000Z",
      "LeaveDetails": "On EL from 10-Jun-2023 to 20-Jun-2023",
      "MembershipBodies": "IEEE",
      "TrainingDetails": "Energy Audit Training, NPTI Faridabad",
      "AwardsHonours": null,
      "DutiesDescription": "Managed 132 KV sub-station operations...",
      "TargetsSet": "1. Reduce AT&C losses below 15%",
      "TargetsAchieved": "AT&C losses reduced to 14.2%",
      "ShortfallReasons": null,
      "MajorAchievements": "Commissioned new 33 KV feeder.",
      "AuditorCompliance": true,
      "PropertyDeclared": true, "PropertyDeclaredDate": "2023-06-30",
      "MedicalCompliance": true, "MedicalComplianceDate": "2023-05-15"
    },
    "Ra1Assessment": {
      "Exists": true, "IsSubmitted": true, "SubmittedAt": "2024-07-01T11:00:00.0000000Z",
      "AgreeWithSelf": true, "DisagreeDetails": null,
      "IntegrityComments": "Integrity beyond doubt", "Remarks": "Good performance",
      "WorkTargets": 8, "WorkQuality": 8, "WorkExceptional": 7, "WorkOverall": 7.67,
      "AttrAttitude": 8, "AttrResponsibility": 8, "AttrStability": 7,
      "AttrCommunication": 7, "AttrMoralCourage": 8, "AttrLeadership": 7,
      "AttrTimeliness": 8, "AttrOverall": 7.57,
      "CompKnowledge": 8, "CompPlanning": 7, "CompDecision": 7,
      "CompInitiative": 8, "CompTeamwork": 8, "CompOverall": 7.60, "OverallGrade": 7.61
    },
    "Ra2Assessment": { "Exists": true, "IsSubmitted": true, "SubmittedAt": "2024-07-10T14:00:00.0000000Z",
      "AgreeWithSelf": true, "OverallGrade": 7.61 },
    "ReviewingAssessment": {
      "Exists": true, "IsSubmitted": false, "SubmittedAt": null,
      "AgreeWithRa": true, "DisagreeDetails": null,
      "Comments": "Well-deserved assessment.", "OverallGrade": 7.61
    },
    "RvaOverrideGrades": {
      "WorkTargets": null, "WorkQuality": null, "WorkExceptional": null,
      "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
      "AttrCommunication": null, "AttrMoralCourage": null, "AttrLeadership": null,
      "AttrTimeliness": null,
      "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
      "CompInitiative": null, "CompTeamwork": null
    },
    "Documents": [
      {
        "DocumentId": "uuid", "Section": "CCA", "DocumentType": "SUPPORTING_DOC",
        "FileUrl": "https://storage.example.com/acr/uuid/cca_note.pdf",
        "FileName": "CCA_Supporting_Note.pdf", "UploadedAt": "2024-08-01T09:00:00.0000000Z"
      }
    ],
    "OfficerPhoto": null,
    "RoleDocuments": []
  },
  "ErrorCode": null
}
```

> `Documents` is `[]` if no CCA documents uploaded yet.  
> `RoleDocuments` is `[]` if no documents uploaded in the caller's current step yet.  
> `Ra2Assessment.Exists` is `false` for A1a/A2 form types.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 3 — Save Reviewing Draft
**PATCH** `/api/acr/{acrId}/reviewing/draft`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Writes to `reviewing_assessments` (agree/disagree, comments, overall grade) and optionally to `reporting_assessments` rva_* override columns.

### Request
```json
{
  "AgreeWithRa": false,
  "DisagreeDetails": "Work targets score overstated.",
  "Comments": "Officer shows good potential. Scores adjusted on work targets item.",
  "OverallGrade": 7.40,
  "WorkTargets": 6,
  "WorkQuality": null, "WorkExceptional": null,
  "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
  "AttrCommunication": null, "AttrMoralCourage": null, "AttrLeadership": null,
  "AttrTimeliness": null,
  "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
  "CompInitiative": null, "CompTeamwork": null
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
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 4 — Submit Reviewing Assessment
**POST** `/api/acr/{acrId}/reviewing/submit`  
**State transition:** `PENDING_REVIEWING` → `PENDING_ACCEPTING`

### Success `200`
```json
{ "Success": true, "Message": "Reviewing assessment submitted successfully", "Data": {}, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the reviewing authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_REVIEWING` step | `INVALID_STATE` | 409 |
| Draft never saved | `BAD_REQUEST` | 400 |
| Already submitted | `ALREADY_SUBMITTED` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 5 — Upload Document
**POST** `/api/acr/{acrId}/docs`  
Section resolved server-side as `RVA`.

### Request
```json
{ "FileUrl": "https://storage.example.com/acr/uuid/rva_note.pdf", "FileName": "RvA_Supporting_Note.pdf", "DocumentType": "SUPPORTING_DOC" }
```

### Success `201`
```json
{ "Success": true, "Message": "Document uploaded successfully", "Data": { "DocumentId": "uuid" }, "ErrorCode": null }
```

---

## API 6 — Get Documents
**GET** `/api/acr/{acrId}/docs`  
Returns RvA's section documents only (`section='RVA'`).

---

## API 7 — Delete Document
**DELETE** `/api/acr/{acrId}/docs/{documentId}`

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/reviewing/my` | List reviewing queue for caller |
| GET | `/api/acr/{acrId}/reviewing` | Get full ACR detail + documents |
| PATCH | `/api/acr/{acrId}/reviewing/draft` | Save reviewing draft (repeatable) |
| POST | `/api/acr/{acrId}/reviewing/submit` | Submit reviewing assessment |
| POST | `/api/acr/{acrId}/docs` | Upload a document (section=RVA) |
| GET | `/api/acr/{acrId}/docs` | List RvA's documents |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |