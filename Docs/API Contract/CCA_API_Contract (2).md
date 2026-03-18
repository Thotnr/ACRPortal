# CCA API Contract
**RoutePrefix:** `api/cca`  
**All responses:** `ApiResponse<T>`  
**Access:** `CCA` role only (enforced by `RouteAccessPolicy`)

---

## Architecture

```
CcaApiController → ICcaUseCase → CcaService → ICcaRepoPort → CcaAdapter
```

---

## Schema Reference — `dbo.acr_cycles` (all columns owned by CCA)

```sql
[acr_id]                       UNIQUEIDENTIFIER  PK  DEFAULT NEWID()
[officer_user_id]              UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[reporting_user_id]            UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)   -- RA1
[ra2_user_id]                  UNIQUEIDENTIFIER  NULL      FK → dbo.users(user_id)   -- A1b only
[reviewing_user_id]            UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[accepting_user_id]            UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[cca_user_id]                  UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[department]                   NVARCHAR(200)     NOT NULL
[location]                     NVARCHAR(200)     NOT NULL
[posting_from]                 DATE              NOT NULL
[posting_to]                   DATE              NOT NULL
[acr_year]                     INT               NOT NULL
[designation]                  NVARCHAR(200)     NOT NULL   -- dsgDesc snapshot at creation time
[form_type]                    VARCHAR(5)        NOT NULL   -- 'A1a' | 'A1b' | 'A2'
[date_of_birth]                DATE              NULL
[date_joining_nigam]           DATE              NULL       -- Sr.5
[date_joining_present_rank]    DATE              NULL       -- Sr.6
[date_joining_present_station] DATE              NULL       -- Sr.7
[academic_qualification]       NVARCHAR(500)     NULL       -- Sr.4(a)
[technical_qualification]      NVARCHAR(500)     NULL       -- Sr.4(b)
[departmental_exam_passed]     NVARCHAR(500)     NULL       -- Sr.8
[property_return_date]         DATE              NULL       -- Sr.10
[last_medical_exam_date]       DATE              NULL       -- Sr.11
[career_posting_summary]       NVARCHAR(MAX)     NULL
[status]                       VARCHAR(30)       NOT NULL  DEFAULT 'PENDING_OFFICER'
[created_at]                   DATETIME          NOT NULL  DEFAULT GETDATE()
[updated_at]                   DATETIME          NOT NULL  DEFAULT GETDATE()
```

**`acr_year`:** if `posting_to` month ≥ 4, `posting_to.Year`; otherwise `posting_to.Year - 1`.  
**`form_type` and `designation`:** resolved from `DesignationId` at INSERT time — not sent by caller.  
**Uniqueness:** `UNIQUE (officer_user_id, department, posting_from)`.

---

## Models

### `CreateAcrRequest` / `UpdateDraftAcrRequest`

Both share the same fields. `CreateAcrRequest` adds `SaveAsDraft`.

```csharp
// Required
string OfficerUserId    // GUID
int    DesignationId    // tbDsg.dsgId — server resolves form_type and designation from this
string Department
string Location
string PostingFrom      // yyyy-MM-dd
string PostingTo        // yyyy-MM-dd (must be > PostingFrom; gap ≥ 90 days)
string DateOfBirth      // yyyy-MM-dd
string ReportingUserId  // GUID of RA1
string ReviewingUserId  // GUID of RvA
string AcceptingUserId  // GUID of AA

// Conditional
string ReportingUserId2 // GUID of RA2 — required for A1b, must be null for A1a/A2

// Optional
string DateJoiningNigam            // yyyy-MM-dd  Sr.5
string DateJoiningPresentRank      // yyyy-MM-dd  Sr.6
string DateJoiningPresentStation   // yyyy-MM-dd  Sr.7
string AcademicQualification       // Sr.4(a)
string TechnicalQualification      // Sr.4(b)
string DepartmentalExamPassed      // Sr.8  free text
string PropertyReturnDate          // yyyy-MM-dd  Sr.10 — null if not yet filed
string LastMedicalExamDate         // yyyy-MM-dd  Sr.11 — null if not applicable
string CareerPostingSummary

// CreateAcrRequest only
bool   SaveAsDraft   // true → DRAFT; false (default) → PENDING_OFFICER
```

### `CcaAcrDetailResponse`

Returned by `GET /api/cca/acr/{acrId}`.

```csharp
public class AuthorityInfo {
    public string UserId      { get; set; }
    public string LoginId     { get; set; }
    public string DisplayName { get; set; }
    public string DsgDesc     { get; set; }   // nullable
}

public class CcaAcrDetailResponse {
    // Identity
    public string AcrId    { get; set; }
    public string FormType { get; set; }   // 'A1a' | 'A1b' | 'A2'
    public string Status   { get; set; }

    // Officer
    public string OfficerUserId  { get; set; }
    public string OfficerLoginId { get; set; }
    public string OfficerName    { get; set; }
    public int?   DsgId          { get; set; }
    public string DsgDesc        { get; set; }   // designation snapshot at creation time

    // Posting
    public string Department  { get; set; }
    public string Location    { get; set; }
    public string PostingFrom { get; set; }   // yyyy-MM-dd
    public string PostingTo   { get; set; }   // yyyy-MM-dd
    public int    AcrYear     { get; set; }

    // Section I
    public string DateOfBirth               { get; set; }   // yyyy-MM-dd
    public string DateJoiningNigam          { get; set; }   // nullable
    public string DateJoiningPresentRank    { get; set; }   // nullable
    public string DateJoiningPresentStation { get; set; }   // nullable
    public string AcademicQualification     { get; set; }   // nullable
    public string TechnicalQualification    { get; set; }   // nullable
    public string DepartmentalExamPassed    { get; set; }   // nullable
    public string PropertyReturnDate        { get; set; }   // yyyy-MM-dd, nullable
    public string LastMedicalExamDate       { get; set; }   // yyyy-MM-dd, nullable
    public string CareerPostingSummary      { get; set; }   // nullable

    // Resolved authorities
    public AuthorityInfo ReportingAuthority  { get; set; }   // RA1 — always present
    public AuthorityInfo ReportingAuthority2 { get; set; }   // RA2 — null for A1a/A2
    public AuthorityInfo ReviewingAuthority  { get; set; }
    public AuthorityInfo AcceptingAuthority  { get; set; }

    // Audit
    public string CreatedAt { get; set; }   // ISO 8601
    public string UpdatedAt { get; set; }   // ISO 8601
}
```

### `AcrListItem`
```csharp
public class AcrListItem {
    public string AcrId          { get; set; }
    public string OfficerName    { get; set; }
    public string OfficerLoginId { get; set; }
    public string DsgDesc        { get; set; }
    public string FormType       { get; set; }
    public string Department     { get; set; }
    public string Location       { get; set; }
    public string PostingFrom    { get; set; }   // yyyy-MM-dd
    public string PostingTo      { get; set; }   // yyyy-MM-dd
    public int    AcrYear        { get; set; }
    public string Status         { get; set; }
    public string CreatedAt      { get; set; }   // ISO 8601
}
```

---

## API 1 — Get Officers List
**GET** `/api/cca/officers`

Returns all ACTIVE EMPLOYEE users for the officer dropdown. Response shape: `{ "Officers": [ CcaOfficerListItem ] }`.

---

## API 2 — Get Employees Dropdown
**GET** `/api/cca/employees`

Returns all ACTIVE EMPLOYEE users for RA/RvA/AA dropdowns. Response shape: `{ "Employees": [ CcaEmployeeDropdownItem ] }`.

---

## API 3 — Create ACR
**POST** `/api/cca/acr`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

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
  "Success": true,
  "Message": "ACR created successfully",
  "Data": { "AcrId": "uuid", "FormType": "A1b", "Status": "PENDING_OFFICER" },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Required field missing | `BAD_REQUEST` | 400 |
| Any date field malformed | `BAD_REQUEST` | 400 |
| PostingTo ≤ PostingFrom or gap < 90 days | `BAD_REQUEST` | 400 |
| DesignationId not found / inactive | `INVALID_DESIGNATION` | 400 |
| RA2 required but missing (A1b) | `BAD_REQUEST` | 400 |
| RA2 provided but not allowed (A1a/A2) | `BAD_REQUEST` | 400 |
| Officer is their own authority | `BAD_REQUEST` | 400 |
| Any user not active | `INVALID_OFFICER` / `INVALID_RA` / `INVALID_RA2` / `INVALID_RVA` / `INVALID_AA` | 400 |
| Duplicate ACR | `DUPLICATE_ACR` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Get ACR List
**GET** `/api/cca/acr`

Returns all ACR cycles (all statuses), ordered by creation date descending.

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
        "DsgDesc": "Executive Engineer",
        "FormType": "A1b",
        "Department": "Operation Division Hisar",
        "Location": "Hisar",
        "PostingFrom": "2023-04-01",
        "PostingTo": "2024-03-31",
        "AcrYear": 2024,
        "Status": "PENDING_OFFICER",
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

Returns the full Section I record for one ACR including all stored fields and resolved authority names. Any CCA can fetch any ACR — no ownership restriction on reads.

Does **not** include any assessment data (self-appraisal, RA grades, reviewing/accepting sections).

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_REPORTING",
    "OfficerUserId": "uuid",
    "OfficerLoginId": "EMP001",
    "OfficerName": "Ramesh Kumar",
    "DsgId": 1002,
    "DsgDesc": "Executive Engineer",
    "Department": "Operation Division Hisar",
    "Location": "Hisar",
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
    "ReportingAuthority": {
      "UserId": "uuid-ra1",
      "LoginId": "EMP010",
      "DisplayName": "Suresh Singh",
      "DsgDesc": "Superintending Engineer"
    },
    "ReportingAuthority2": {
      "UserId": "uuid-ra2",
      "LoginId": "EMP011",
      "DisplayName": "Vikram Patel",
      "DsgDesc": "Executive Engineer"
    },
    "ReviewingAuthority": {
      "UserId": "uuid-rva",
      "LoginId": "EMP020",
      "DisplayName": "Anita Sharma",
      "DsgDesc": "Chief Engineer"
    },
    "AcceptingAuthority": {
      "UserId": "uuid-aa",
      "LoginId": "EMP030",
      "DisplayName": "Rajesh Gupta",
      "DsgDesc": "Director"
    },
    "CreatedAt": "2024-05-01T10:00:00.0000000Z",
    "UpdatedAt": "2024-05-03T14:22:00.0000000Z"
  },
  "ErrorCode": null
}
```

> For A1a/A2 form types, `ReportingAuthority2` is `null`.  
> All optional date/text fields (joining dates, qualifications, property return, medical) may be `null` if not yet filled in.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` missing or not a valid GUID | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 6 — Update Draft ACR
**PATCH** `/api/cca/acr/{acrId}`  
ACR must be in `DRAFT` status. Same validation rules as Create.

Request body: same fields as `CreateAcrRequest` excluding `SaveAsDraft`.

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

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` missing / invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR belongs to a different CCA | `FORBIDDEN` | 403 |
| ACR is not in DRAFT status | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/cca/officers` | Active employees for officer dropdown |
| GET | `/api/cca/employees` | Active employees for RA/RvA/AA dropdowns |
| POST | `/api/cca/acr` | Create a new ACR cycle |
| GET | `/api/cca/acr` | List all ACR cycles |
| GET | `/api/cca/acr/{acrId}` | Get full Section I detail for one ACR |
| PATCH | `/api/cca/acr/{acrId}` | Save changes to a DRAFT ACR |
| POST | `/api/cca/acr/{acrId}/submit` | Submit DRAFT → PENDING_OFFICER |

---

## `ICcaUseCase` — interface shape
```csharp
public interface ICcaUseCase {
    ApiResponse<CcaOfficerListResponse>      GetOfficers();
    ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
    ApiResponse<CreateAcrResponse>           CreateAcr(string ccaUserId, CreateAcrRequest request);
    ApiResponse<CcaAcrDetailResponse>        GetAcrDetail(string acrId);
    ApiResponse<EmptyResponse>               UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request);
    ApiResponse<EmptyResponse>               SubmitDraftAcr(string acrId, string ccaUserId);
    ApiResponse<AcrListResponse>             GetAcrList();
}
```

## `ICcaRepoPort` — interface shape
```csharp
public interface ICcaRepoPort {
    List<CcaOfficerListItem>      GetOfficers();
    List<CcaEmployeeDropdownItem> GetEmployeesForDropdown();
    bool IsUserActive(Guid userId);
    bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom);
    bool IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom);
    DesignationLookupItem GetDesignationById(int dsgId);
    string CreateAcr(/* ... all Section I params ... */ string status);
    bool TryUpdateDraftAcr(/* ... all Section I params ... */ out string errorCode);
    bool TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode);
    CcaAcrDetailResponse GetAcrDetail(Guid acrId);
    List<AcrListItem> GetAcrList();
}
```