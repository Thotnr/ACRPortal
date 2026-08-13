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
- AA **uploads** supporting documents to their section (`AA`).

**No draft step for the decision.** Unlike other layers, the AA submit is one-shot — calling the submit endpoint both writes the decision and closes the ACR atomically.

**Document behaviour:** AA can upload documents at any time while the ACR is in `PENDING_ACCEPTING`. Section `AA` is resolved server-side.

---

## Architecture

```
AcceptingApiController  → IAcceptingUseCase  → AcceptingService  → IAcceptingRepoPort  → AcceptingAdapter
DocumentApiController   → IDocumentUseCase   → DocumentService   → IDocumentRepoPort   → DocumentAdapter
```

---

## Schema Reference

### `dbo.accepting_decisions` (written by AA)
`document_path` column has been removed — documents are now in `dbo.acr_documents` with `section = 'AA'`.

### `dbo.acr_documents`
```sql
[section] VARCHAR(10)  -- 'AA' for this role
```

---

## Models

### `AcceptingDecisionRequest`
```csharp
public class AcceptingDecisionRequest {
  bool?    AgreeWithPrevious;   // agree with RvA assessment?
  string   DisagreeDetails;     // required when AgreeWithPrevious = false
  bool     ConflictResolved;
  decimal? FinalGrade;          // DECIMAL(4,2), 1-10
  string   FinalRemarks;
  bool     IsApproved;          // true → APPROVED, false → REJECTED
  // DocumentPath removed — use POST /api/acr/{acrId}/docs before or alongside submit
}
```

### `AcceptingDecisionView`
```csharp
public class AcceptingDecisionView {
  bool     Exists;
  bool     IsDecided;
  string   DecidedAt;           // ISO 8601 | null
  bool?    AgreeWithPrevious;
  string   DisagreeDetails;
  bool     ConflictResolved;
  decimal? FinalGrade;
  string   FinalRemarks;
  bool?    IsApproved;          // null until decided
  // DocumentPath removed
}
```

### `AcceptingAcrDetailResponse`
```csharp
public class AcceptingAcrDetailResponse {
  string AcrId; string FormType; string Status;
  string Department; string Location; string Designation;
  string PostingFrom; string PostingTo; int AcrYear;
  OfficerLite             Officer;
  SelfAppraisalView       SelfAppraisal;
  ReportingAssessmentView Ra1Assessment;
  ReportingAssessmentView Ra2Assessment;        // Exists=false for A1a/A2
  RvaOverrideGradesView   RvaOverrideGrades;
  ReviewingAssessmentView ReviewingAssessment;
  AcceptingDecisionView   Decision;

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
  List<AcrDocumentItem> Documents;            // section='CCA' (excludes OFFICER_PHOTO)
  AcrDocumentItem OfficerPhoto;               // section='CCA', document_type='OFFICER_PHOTO'

  // Documents uploaded by the caller's current step (section='AA')
  List<AcrDocumentItem> RoleDocuments;
}
```

---

## API 1 — My Accepting Queue
**GET** `/api/acr/accepting/my`  
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
        "Status": "PENDING_ACCEPTING", "IsDecided": false,
        "CreatedAt": "2024-05-01T10:00:00.0000000Z"
      }
    ]
  },
  "ErrorCode": null
}
```

---

## API 2 — Get ACR for Accepting
**GET** `/api/acr/{acrId}/accepting`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Returns the complete ACR history for the AA including all assessments, the AA's own decision (if already submitted), the caller's step attachments (`RoleDocuments`), and the CCA section I attachments (`Documents` / `OfficerPhoto`) for modal reuse.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrId": "uuid", "FormType": "A1b", "Status": "PENDING_ACCEPTING",
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
    "Ra2Assessment": {
      "Exists": true, "IsSubmitted": true, "SubmittedAt": "2024-07-10T14:00:00.0000000Z",
      "AgreeWithSelf": true, "OverallGrade": 7.61
    },
    "RvaOverrideGrades": {
      "WorkTargets": null, "WorkQuality": null, "WorkExceptional": null,
      "AttrAttitude": null, "AttrResponsibility": null, "AttrStability": null,
      "AttrCommunication": null, "AttrMoralCourage": null, "AttrLeadership": null,
      "AttrTimeliness": null,
      "CompKnowledge": null, "CompPlanning": null, "CompDecision": null,
      "CompInitiative": null, "CompTeamwork": null
    },
    "ReviewingAssessment": {
      "Exists": true, "IsSubmitted": true, "SubmittedAt": "2024-08-01T10:00:00.0000000Z",
      "AgreeWithRa": true, "DisagreeDetails": null,
      "Comments": "Well-deserved assessment. Officer performed consistently.", "OverallGrade": 7.61
    },
    "Decision": {
      "Exists": false, "IsDecided": false, "DecidedAt": null,
      "AgreeWithPrevious": null, "DisagreeDetails": null,
      "ConflictResolved": false, "FinalGrade": null, "FinalRemarks": null, "IsApproved": null
    },
    "Documents": [
      {
        "DocumentId": "uuid", "Section": "CCA", "DocumentType": "SUPPORTING_DOC",
        "FileUrl": "https://storage.example.com/acr/uuid/cca_note.pdf",
        "FileName": "CCA_Supporting_Note.pdf", "UploadedAt": "2024-09-01T09:00:00.0000000Z"
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
> `Decision.Exists` is `false` until the AA submits.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the accepting authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_ACCEPTING` step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 3 — Submit Decision (finalises ACR)
**POST** `/api/acr/{acrId}/accepting/submit`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Records the AA's final decision and closes the ACR. **One-shot — cannot be repeated.**

**State transition:**
- `PENDING_ACCEPTING` → `APPROVED` when `IsApproved = true`
- `PENDING_ACCEPTING` → `REJECTED` when `IsApproved = false`

Upload any documents **before** calling submit if needed — they can be uploaded while the ACR is in `PENDING_ACCEPTING`.

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

> `DocumentPath` has been removed from this request. Upload documents separately via `POST /api/acr/{acrId}/docs`.

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

---

## API 4 — Upload Document
**POST** `/api/acr/{acrId}/docs`  
Requires: `Authorization: Bearer <token>` | Role: `EMPLOYEE`

Section resolved server-side as `AA`. Documents can be uploaded before or after submit is called (during `PENDING_ACCEPTING` only).

### Request
```json
{ "FileUrl": "https://storage.example.com/acr/uuid/aa_note.pdf", "FileName": "AA_Decision_Note.pdf", "DocumentType": "SUPPORTING_DOC" }
```

### Success `201`
```json
{ "Success": true, "Message": "Document uploaded successfully", "Data": { "DocumentId": "uuid" }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `FileUrl` or `FileName` missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Caller is not the accepting authority | `FORBIDDEN` | 403 |
| ACR not in `PENDING_ACCEPTING` step | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## API 5 — Get Documents
**GET** `/api/acr/{acrId}/docs`  
Returns AA's section documents only (`section='AA'`).

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": { "Documents": [ { "DocumentId": "uuid", "Section": "AA", "DocumentType": "SUPPORTING_DOC", "FileUrl": "...", "FileName": "AA_Decision_Note.pdf", "UploadedAt": "..." } ] },
  "ErrorCode": null
}
```

---

## API 6 — Delete Document
**DELETE** `/api/acr/{acrId}/docs/{documentId}`  
Removes a document from the AA's section.

### Success `200`
```json
{ "Success": true, "Message": "Document deleted successfully", "Data": {}, "ErrorCode": null }
```

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/acr/accepting/my` | List accepting queue for caller |
| GET | `/api/acr/{acrId}/accepting` | Get full ACR detail + documents |
| POST | `/api/acr/{acrId}/accepting/submit` | Submit final decision (closes ACR) |
| POST | `/api/acr/{acrId}/docs` | Upload a document (section=AA) |
| GET | `/api/acr/{acrId}/docs` | List AA's documents |
| DELETE | `/api/acr/{acrId}/docs/{documentId}` | Delete a document |