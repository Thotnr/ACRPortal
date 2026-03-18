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

**`acr_year`:** if `posting_to` month ≥ 4 → `posting_to.Year`; otherwise `posting_to.Year - 1`.  
**`form_type` and `designation`:** resolved from `DesignationId` at INSERT — never sent by caller.  
**Uniqueness:** `UNIQUE (officer_user_id, department, posting_from)`.

---

## Models

### `CreateAcrRequest` / `UpdateDraftAcrRequest`

Both share the same fields. `CreateAcrRequest` adds `SaveAsDraft`.

```csharp
// Required
string OfficerUserId    // GUID
int    DesignationId    // tbDsg.dsgId — server resolves form_type and designation
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

Returned by `GET /api/cca/acr/{acrId}`. Authority fields contain only the stored UUID — no name resolution.

```csharp
public class CcaAcrDetailResponse {
    // Identity
    string AcrId    
    string FormType    // 'A1a' | 'A1b' | 'A2'
    string Status

    // Officer (display info resolved from users JOIN)
    string OfficerUserId
    string OfficerLoginId
    string OfficerName
    int?   DsgId
    string DsgDesc        // designation snapshot stored at creation time

    // Posting
    string Department
    string Location
    string PostingFrom    // yyyy-MM-dd
    string PostingTo      // yyyy-MM-dd
    int    AcrYear

    // Section I
    string DateOfBirth               // yyyy-MM-dd, nullable
    string DateJoiningNigam          // yyyy-MM-dd, nullable
    string DateJoiningPresentRank    // yyyy-MM-dd, nullable
    string DateJoiningPresentStation // yyyy-MM-dd, nullable
    string AcademicQualification     // nullable
    string TechnicalQualification    // nullable
    string DepartmentalExamPassed    // nullable
    string PropertyReturnDate        // yyyy-MM-dd, nullable
    string LastMedicalExamDate       // yyyy-MM-dd, nullable
    string CareerPostingSummary      // nullable

    // Authorities — UserId only (UUID string)
    string ReportingAuthorityUserId   // RA1 — always present
    string ReportingAuthority2UserId  // RA2 — null for A1a/A2
    string ReviewingAuthorityUserId
    string AcceptingAuthorityUserId

    // Audit
    string CreatedAt    // ISO 8601
    string UpdatedAt    // ISO 8601
}
```

### `AcrListItem`
```csharp
public class AcrListItem {
    string AcrId; string OfficerName; string OfficerLoginId; string DsgDesc;
    string FormType; string Department; string Location;
    string PostingFrom; string PostingTo; int AcrYear; string Status; string CreatedAt;
}
```

---

## API 1 — Get Officers List
**GET** `/api/cca/officers`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Populates the **"Select Officer"** dropdown when the CCA is creating an ACR. Returns `DsgCode`, `DsgDesc`, and `FormType` per officer — the frontend uses `FormType` to immediately know which form template applies and whether to show the RA2 field (`A1b` → show; `A1a` / `A2` → hide), without needing a separate designation lookup after officer selection.

**Why this is different from `/api/cca/employees`:** this endpoint returns `DsgCode` and `FormType` which are only needed for officer selection logic. The employees endpoint omits those fields since authority dropdowns (RA, RvA, AA) don't need form-type awareness.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Officers": [
      {
        "UserId": "uuid",
        "LoginId": "EMP001",
        "DisplayName": "Ramesh Kumar",
        "DsgId": 1002,
        "DsgCode": "XEN",
        "DsgDesc": "Executive Engineer",
        "FormType": "A1b"
      },
      {
        "UserId": "uuid",
        "LoginId": "EMP002",
        "DisplayName": "Kuldeep Atri",
        "DsgId": 1003,
        "DsgCode": "SE",
        "DsgDesc": "Superintending Engineer",
        "FormType": "A1a"
      }
    ]
  },
  "ErrorCode": null
}
```

> `DsgId`, `DsgCode`, `DsgDesc`, and `FormType` are `null` if the officer has no designation assigned yet. The CCA should not create an ACR for such officers until a designation is set.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 2 — Get Employees Dropdown
**GET** `/api/cca/employees`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Populates the **RA / RvA / AA authority dropdowns** when creating or editing an ACR. Returns the same active EMPLOYEE pool as `/api/cca/officers` but without `DsgCode` and `FormType` — those fields are irrelevant for authority selection and are omitted to keep the payload lean.

**Why this is different from `/api/cca/officers`:** authority dropdowns only need to show name and designation description for identification. The form-type logic that drives the RA2 field is driven by the officer's designation (from API 1), not by the authority's.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Employees": [
      {
        "UserId": "uuid",
        "LoginId": "EMP010",
        "DisplayName": "Suresh Singh",
        "DsgId": 1005,
        "DsgDesc": "Superintending Engineer"
      },
      {
        "UserId": "uuid",
        "LoginId": "EMP020",
        "DisplayName": "Anita Sharma",
        "DsgId": 1006,
        "DsgDesc": "Chief Engineer"
      }
    ]
  },
  "ErrorCode": null
}
```

> `DsgId` and `DsgDesc` are `null` if the employee has no designation assigned.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

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
  "Success": true, "Message": "ACR created successfully",
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
| Any referenced user not active | `INVALID_OFFICER` / `INVALID_RA` / `INVALID_RA2` / `INVALID_RVA` / `INVALID_AA` | 400 |
| Duplicate ACR | `DUPLICATE_ACR` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Get ACR List
**GET** `/api/cca/acr`  
Returns all ACR cycles ordered by creation date descending.

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "AcrCycles": [
      {
        "AcrId": "uuid", "OfficerName": "Ramesh Kumar", "OfficerLoginId": "EMP001",
        "DsgDesc": "Executive Engineer", "FormType": "A1b",
        "Department": "Operation Division Hisar", "Location": "Hisar",
        "PostingFrom": "2023-04-01", "PostingTo": "2024-03-31",
        "AcrYear": 2024, "Status": "PENDING_OFFICER",
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

Returns full Section I data for one ACR. Authority fields contain only the stored `UserId` — no name resolution. Any CCA can read any ACR (no ownership restriction on reads).

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "AcrId": "uuid",
    "FormType": "A1b",
    "Status": "PENDING_REPORTING",
    "OfficerUserId": "uuid-officer",
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
    "ReportingAuthorityUserId": "uuid-ra1",
    "ReportingAuthority2UserId": "uuid-ra2",
    "ReviewingAuthorityUserId": "uuid-rva",
    "AcceptingAuthorityUserId": "uuid-aa",
    "CreatedAt": "2024-05-01T10:00:00.0000000Z",
    "UpdatedAt": "2024-05-03T14:22:00.0000000Z"
  },
  "ErrorCode": null
}
```

> `ReportingAuthority2UserId` is `null` for A1a/A2 form types.  
> All optional date/text fields may be `null` if not yet populated by CCA.

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
ACR must be in `DRAFT` status. Same body as `CreateAcrRequest` excluding `SaveAsDraft`.

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
| GET | `/api/cca/officers` | Officer dropdown — includes `DsgCode` and `FormType` to drive RA2 visibility |
| GET | `/api/cca/employees` | Authority dropdowns (RA/RvA/AA) — name + designation only, no form-type fields |
| POST | `/api/cca/acr` | Create a new ACR cycle |
| GET | `/api/cca/acr` | List all ACR cycles |
| GET | `/api/cca/acr/{acrId}` | Get full Section I detail for one ACR |
| PATCH | `/api/cca/acr/{acrId}` | Save changes to a DRAFT ACR |
| POST | `/api/cca/acr/{acrId}/submit` | Submit DRAFT → PENDING_OFFICER |

---

## `ICcaUseCase` — interface shape
```csharp
ApiResponse<CcaOfficerListResponse>      GetOfficers();
ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
ApiResponse<CreateAcrResponse>           CreateAcr(string ccaUserId, CreateAcrRequest request);
ApiResponse<CcaAcrDetailResponse>        GetAcrDetail(string acrId);
ApiResponse<EmptyResponse>               UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request);
ApiResponse<EmptyResponse>               SubmitDraftAcr(string acrId, string ccaUserId);
ApiResponse<AcrListResponse>             GetAcrList();
```

## `ICcaRepoPort` — interface shape
```csharp
List<CcaOfficerListItem>      GetOfficers();
List<CcaEmployeeDropdownItem> GetEmployeesForDropdown();
bool IsUserActive(Guid userId);
bool IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom);
bool IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom);
DesignationLookupItem GetDesignationById(int dsgId);
string CreateAcr(/* ... Section I params ... */ string status);
bool   TryUpdateDraftAcr(/* ... Section I params ... */ out string errorCode);
bool   TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode);
CcaAcrDetailResponse GetAcrDetail(Guid acrId);
List<AcrListItem> GetAcrList();
```