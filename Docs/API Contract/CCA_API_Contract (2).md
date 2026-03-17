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

## Schema Reference — `dbo.acr_cycles` (relevant columns)

```sql
[acr_id]                 UNIQUEIDENTIFIER  PK  DEFAULT NEWID()
[officer_user_id]        UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[reporting_user_id]      UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[ra2_user_id]            UNIQUEIDENTIFIER  NULL      FK → dbo.users(user_id)  -- A1b only
[reviewing_user_id]      UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[accepting_user_id]      UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[cca_user_id]            UNIQUEIDENTIFIER  NOT NULL  FK → dbo.users(user_id)
[department]             NVARCHAR(200)     NOT NULL
[location]               NVARCHAR(200)     NOT NULL
[posting_from]           DATE              NOT NULL
[posting_to]             DATE              NOT NULL
[acr_year]               INT               NOT NULL  -- computed: fiscal year of posting_to
[form_type]              VARCHAR(5)        NOT NULL  -- 'A1a' | 'A1b' | 'A2' (copied from tbDsg)
[date_of_birth]          DATE              NULL
[qualification]          NVARCHAR(500)     NULL      -- "AcademicQual | TechnicalQual"
[career_posting_summary] NVARCHAR(MAX)     NULL
[property_return_done]   BIT               NOT NULL  DEFAULT 0
[status]                 VARCHAR(30)       NOT NULL  DEFAULT 'PENDING_OFFICER'  -- includes 'DRAFT'
[created_at]             DATETIME          NOT NULL  DEFAULT GETDATE()
[updated_at]             DATETIME          NOT NULL  DEFAULT GETDATE()
```

**`acr_year` derivation rule:** if `posting_to` month ≥ April (month ≥ 4), `acr_year = posting_to.Year`; otherwise `acr_year = posting_to.Year - 1`.  
**`form_type` source:** resolved at INSERT time from `tbDsg.form_type` via the officer's `dsg_id`. Not sent by the caller.  
**`qualification` storage:** `AcademicQualification` and `TechnicalQualification` are joined as `"<academic> | <technical>"` before storage.  
**Uniqueness constraint:** `UNIQUE (officer_user_id, department, posting_from)` — one ACR per officer per department per posting start date.

---

## Models

### `CcaOfficerListItem`
```csharp
public class CcaOfficerListItem {
    public string UserId      { get; set; }
    public string LoginId     { get; set; }
    public string DisplayName { get; set; }
    public int?   DsgId       { get; set; }  // nullable — officer may not have a designation set
    public string DsgCode     { get; set; }  // nullable — short code e.g. "SE"
    public string DsgDesc     { get; set; }  // nullable — e.g. "Superintending Engineer"
    public string FormType    { get; set; }  // nullable — 'A1a' | 'A1b' | 'A2'
}
```

### `CcaEmployeeDropdownItem`
```csharp
public class CcaEmployeeDropdownItem {
    public string UserId      { get; set; }
    public string LoginId     { get; set; }
    public string DisplayName { get; set; }
    public int?   DsgId       { get; set; }
    public string DsgDesc     { get; set; }
}
```

### `CreateAcrRequest`
```csharp
public class CreateAcrRequest {
    // Officer
    public string OfficerUserId           { get; set; }  // required — GUID string
    public int    DesignationId           { get; set; }  // required — dsgId from tbDsg; CCA selects from dropdown

    // If true, saves ACR in DRAFT status (does not reach officer queue until submitted)
    public bool   SaveAsDraft             { get; set; }  // optional — default false

    // Posting details
    public string Department              { get; set; }  // required
    public string Location                { get; set; }  // required
    public string PostingFrom             { get; set; }  // required — "yyyy-MM-dd"
    public string PostingTo               { get; set; }  // required — "yyyy-MM-dd"

    // Officer background info
    public string DateOfBirth             { get; set; }  // required — "yyyy-MM-dd"
    public string AcademicQualification   { get; set; }  // optional
    public string TechnicalQualification  { get; set; }  // optional
    public string CareerPostingSummary    { get; set; }  // optional
    public bool   PropertyReturnDone      { get; set; }  // required (false by default)

    // Appraisal chain — all required GUID strings
    public string ReportingUserId         { get; set; }  // RA1 — required for all form types
    public string ReportingUserId2        { get; set; }  // RA2 — required when FormType = 'A1b', null otherwise
    public string ReviewingUserId         { get; set; }  // required
    public string AcceptingUserId         { get; set; }  // required
}
```

### `CreateAcrResponse`
```csharp
public class CreateAcrResponse {
    public string AcrId    { get; set; }  // newly created acr_id (GUID string)
    public string FormType { get; set; }  // resolved from officer's designation
    public string Status   { get; set; }  // "DRAFT" when SaveAsDraft=true, else "PENDING_OFFICER"
}
```

### `AcrListItem`
```csharp
public class AcrListItem {
    public string AcrId          { get; set; }
    public string OfficerName    { get; set; }
    public string OfficerLoginId { get; set; }
    public string DsgDesc        { get; set; }
    public string FormType       { get; set; }  // 'A1a' | 'A1b' | 'A2'
    public string Department     { get; set; }
    public string Location       { get; set; }
    public string PostingFrom    { get; set; }  // "yyyy-MM-dd"
    public string PostingTo      { get; set; }  // "yyyy-MM-dd"
    public int    AcrYear        { get; set; }
    public string Status         { get; set; }
    public string CreatedAt      { get; set; }  // ISO 8601
}
```

---

## API 1 — Get Officers (for officer selection dropdown)
**GET** `/api/cca/officers`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Returns all active `EMPLOYEE` users with their designation and form type. Used to populate the "Select Officer" dropdown when raising an appraisal. `FormType` tells the frontend which template applies and whether to show the RA2 field.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Officers": [
      {
        "UserId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "LoginId": "9BE877",
        "DisplayName": "Kuldeep Atri",
        "DsgId": 1003,
        "DsgCode": "SE",
        "DsgDesc": "Superintending Engineer",
        "FormType": "A1a"
      },
      {
        "UserId": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
        "LoginId": "ASD2C6",
        "DisplayName": "Dheeraj Kumar",
        "DsgId": 1002,
        "DsgCode": "XEN",
        "DsgDesc": "Executive Engineer",
        "FormType": "A1b"
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
| Role not CCA | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 2 — Get Employees (for RA / RvA / AA dropdowns)
**GET** `/api/cca/employees`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Returns all active `EMPLOYEE` users for populating the Reporting Authority, Reviewing Authority, and Accepting Authority dropdowns. Same user pool as officers — the CCA is responsible for selecting appropriate authorities based on the hierarchy rules.

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Employees": [
      {
        "UserId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "LoginId": "2N45FC",
        "DisplayName": "R.K. Sabharwal",
        "DsgId": 1004,
        "DsgDesc": "Chief Engineer"
      },
      {
        "UserId": "c3d4e5f6-a7b8-9012-cdef-123456789012",
        "LoginId": "9BE877",
        "DisplayName": "Kuldeep Atri",
        "DsgId": 1003,
        "DsgDesc": "Superintending Engineer"
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
| Role not CCA | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 3 — Create ACR Cycle
**POST** `/api/cca/acr`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Creates a new ACR cycle for a specific officer posting. The CCA's own `user_id` is read from the JWT token and stored as `cca_user_id` — it is not sent in the request body. `form_type` is resolved server-side from the officer's designation and is not sent by the caller.

**Draft rule:** when `SaveAsDraft = true`, the ACR is created with `status = 'DRAFT'`. It will not appear in the officer's queue until the CCA submits it using **API 5**.

**`ReportingUserId2` rule:** must be provided when the officer's designation has `FormType = 'A1b'`. Must be `null` or omitted for `A1a` and `A2`.

**`acr_year` derivation:** computed from `PostingTo` — if month ≥ April, `acr_year = PostingTo.Year`; otherwise `acr_year = PostingTo.Year - 1`.

### Request
```json
{
  "OfficerUserId": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "DesignationId": 1002,
  "SaveAsDraft": false,
  "Department": "OP Division, Sirsa",
  "Location": "Sirsa",
  "PostingFrom": "2025-04-01",
  "PostingTo": "2026-03-31",
  "DateOfBirth": "1980-06-15",
  "AcademicQualification": "B.Tech (Electrical)",
  "TechnicalQualification": "M.Tech (Power Systems)",
  "CareerPostingSummary": "15 years in Operation Wing across Hisar, Sirsa, and Fatehabad circles.",
  "PropertyReturnDone": true,
  "ReportingUserId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "ReportingUserId2": null,
  "ReviewingUserId": "c3d4e5f6-a7b8-9012-cdef-123456789012",
  "AcceptingUserId": "d4e5f6a7-b8c9-0123-defa-234567890123"
}
```

### Success `201`
```json
{
  "Success": true,
  "Message": "ACR created successfully",
  "Data": {
    "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
    "FormType": "A1b",
    "Status": "PENDING_OFFICER"
  },
  "ErrorCode": null
}
```

### Success `201` (Draft)
```json
{
  "Success": true,
  "Message": "ACR saved as draft",
  "Data": {
    "AcrId": "e5f6a7b8-c9d0-1234-efab-345678901234",
    "FormType": "A1b",
    "Status": "DRAFT"
  },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `DesignationId` is 0 or not provided | `BAD_REQUEST` | 400 |
| `DesignationId` not found or inactive | `INVALID_DESIGNATION` | 400 |
| Any required field missing or blank | `BAD_REQUEST` | 400 |
| Any GUID field is not a valid GUID | `BAD_REQUEST` | 400 |
| `PostingTo` ≤ `PostingFrom` | `BAD_REQUEST` | 400 |
| Posting period < 90 days | `BAD_REQUEST` | 400 |
| `DateOfBirth` not in the past | `BAD_REQUEST` | 400 |
| Officer is their own RA, RvA, or AA | `BAD_REQUEST` | 400 |
| RA1 and RA2 are the same person | `BAD_REQUEST` | 400 |
| Selected officer is not active | `INVALID_OFFICER` | 400 |
| Selected RA1 is not active | `INVALID_RA` | 400 |
| Selected RA2 is not active | `INVALID_RA2` | 400 |
| Selected RvA is not active | `INVALID_RVA` | 400 |
| Selected AA is not active | `INVALID_AA` | 400 |
| ACR already exists for this officer + department + posting start date | `DUPLICATE_ACR` | 409 |
| CCA user_id cannot be resolved from token | `TOKEN_INVALID` | 401 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not CCA | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 4 — Get ACR List
**GET** `/api/cca/acr`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Returns all ACR cycles across all officers, ordered by creation date descending. Used for the CCA dashboard table.

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
        "DsgDesc": "Executive Engineer",
        "FormType": "A1b",
        "Department": "OP Division, Sirsa",
        "Location": "Sirsa",
        "PostingFrom": "2025-04-01",
        "PostingTo": "2026-03-31",
        "AcrYear": 2025,
        "Status": "PENDING_OFFICER",
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
| Role not CCA | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Status Values

| Status | Who sets it | Meaning |
|---|---|---|
| `DRAFT` | CCA (save as draft) | ACR saved by CCA but not yet submitted to the officer step |
| `PENDING_OFFICER` | CCA (on submit) | ACR is active at officer step, waiting for officer self-appraisal |
| `PENDING_REPORTING` | System (on officer submit) | Officer submitted, waiting for RA1 |
| `PENDING_REPORTING2` | System (on RA1 submit, A1b only) | RA1 done, waiting for RA2 |
| `PENDING_REVIEWING` | System (on RA submit) | RA done, waiting for RvA |
| `PENDING_ACCEPTING` | System (on RvA submit) | RvA done, waiting for AA |
| `APPROVED` | System (on AA accept) | ACR finalised and approved |
| `REJECTED` | System (on AA reject) | ACR finalised and rejected |

---

## API 5 — Save Draft Changes (Update Draft ACR)
**PATCH** `/api/cca/acr/{acrId}`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Updates the draft data entered by CCA **without** advancing workflow.

**Allowed only when:** `acr_cycles.status = 'DRAFT'` and `cca_user_id` matches the caller.

### Request
Same shape as `CreateAcrRequest` **except** `SaveAsDraft` is not used here (status remains `DRAFT`).

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
| `acrId` is missing/invalid | `BAD_REQUEST` | 400 |
| Body missing | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR was created by a different CCA | `FORBIDDEN` | 403 |
| ACR is not in `DRAFT` status | `INVALID_STATE` | 409 |
| Changes make it a duplicate (officer + department + posting_from) | `DUPLICATE_ACR` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 5 — Submit Draft ACR Cycle
**POST** `/api/cca/acr/{acrId}/submit`  
Requires: `Authorization: Bearer <token>` | Role: `CCA`

Moves a drafted ACR to the officer step.

**State transition:** `DRAFT` → `PENDING_OFFICER`

### Success `200`
```json
{
  "Success": true,
  "Message": "Draft submitted successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `acrId` is missing/invalid | `BAD_REQUEST` | 400 |
| ACR not found | `NOT_FOUND` | 404 |
| ACR was created by a different CCA | `FORBIDDEN` | 403 |
| ACR is not in `DRAFT` status | `INVALID_STATE` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/cca/officers` | List active employees for officer dropdown |
| GET | `/api/cca/employees` | List active employees for RA/RvA/AA dropdowns |
| POST | `/api/cca/acr` | Create a new ACR cycle |
| GET | `/api/cca/acr` | List all ACR cycles |
| PATCH | `/api/cca/acr/{acrId}` | Save changes to a drafted ACR (DRAFT only) |
| POST | `/api/cca/acr/{acrId}/submit` | Submit a drafted ACR (DRAFT → PENDING_OFFICER) |

---

## `ICcaUseCase` — interface shape
```csharp
public interface ICcaUseCase {
    ApiResponse<CcaOfficerListResponse>    GetOfficers();
    ApiResponse<CcaEmployeeDropdownResponse> GetEmployeesForDropdown();
    ApiResponse<CreateAcrResponse>         CreateAcr(string ccaUserId, CreateAcrRequest request);
    ApiResponse<EmptyResponse>             UpdateDraftAcr(string acrId, string ccaUserId, UpdateDraftAcrRequest request);
    ApiResponse<EmptyResponse>             SubmitDraftAcr(string acrId, string ccaUserId);
    ApiResponse<AcrListResponse>           GetAcrList();
}
```

## `ICcaRepoPort` — interface shape
```csharp
public interface ICcaRepoPort {
    List<CcaOfficerListItem>       GetOfficers();
    List<CcaEmployeeDropdownItem>  GetEmployeesForDropdown();
    bool                           IsUserActive(Guid userId);
    bool                           IsAcrDuplicate(Guid officerUserId, string department, DateTime postingFrom);
    bool                           IsAcrDuplicateExcluding(Guid acrId, Guid officerUserId, string department, DateTime postingFrom);
    DesignationLookupItem          GetDesignationById(int dsgId);
    string                         CreateAcr(
                                       Guid officerUserId, Guid reportingUserId, Guid? reportingUserId2,
                                       Guid reviewingUserId, Guid acceptingUserId, Guid ccaUserId,
                                       string department, string location,
                                       DateTime postingFrom, DateTime postingTo, int acrYear,
                                       string designation, string formType,
                                       DateTime dateOfBirth,
                                       string academicQualification, string technicalQualification,
                                       string careerPostingSummary, bool propertyReturnDone,
                                       string status);
    bool                           TryUpdateDraftAcr(
                                       Guid acrId, Guid ccaUserId,
                                       Guid officerUserId, Guid reportingUserId, Guid? reportingUserId2,
                                       Guid reviewingUserId, Guid acceptingUserId,
                                       string department, string location,
                                       DateTime postingFrom, DateTime postingTo, int acrYear,
                                       string designation, string formType,
                                       DateTime dateOfBirth,
                                       string academicQualification, string technicalQualification,
                                       string careerPostingSummary, bool propertyReturnDone,
                                       out string errorCode);
    bool                           TrySubmitDraftAcr(Guid acrId, Guid ccaUserId, out string errorCode);
    List<AcrListItem>              GetAcrList();
}
```
