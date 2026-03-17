# Admin API Contract
**RoutePrefix:** `api/admin`  
**All responses:** `ApiResponse<T>`  
**Access:** `ADMIN` role only (enforced by `RouteAccessPolicy`)

---

## Architecture

```
AdminController → IAdminUseCase → AdminService → IAdminRepoPort → AdminAdapter
```

---

## Schema Reference — `dbo.users` (relevant columns)

```sql
[dsg_id]          INT NULL  FK → dbo.tbDsg(dsgId)
[state_id]        INT NULL  FK → dbo.State(State_ID)
[zone_id]         INT NULL  FK → dbo.Zone(Zone_ID)
[circle_id]       INT NULL  FK → dbo.Circle(Circle_ID)
[division_id]     INT NULL  FK → dbo.Division(Division_ID)
[sub_division_id] INT NULL  FK → dbo.SubDivision(SubDivisionID)
```

All geography fields are optional. Hierarchy is validated at the application layer — if `circle_id` is provided, `zone_id` must also be provided and the circle must belong to that zone. Frontend limits options via cascading dropdowns; backend re-validates on save.

**Designation** uses `dsg_id` (INT FK → `tbDsg.dsgId`). The old `dbo.designations` table does not exist — use `api/admin/masters/designations` to manage designations.

---

## Models

### `UserListItem`
```csharp
public class UserListItem {
    public string UserId        { get; set; }
    public string LoginId       { get; set; }
    public string DisplayName   { get; set; }
    public string SystemRole    { get; set; }  // CCA | EMPLOYEE
    public string UserStatus    { get; set; }  // PENDING | ACTIVE | INACTIVE
    public int?   DsgId         { get; set; }  // nullable
    public int?   StateId       { get; set; }  // nullable
    public int?   ZoneId        { get; set; }  // nullable
    public int?   CircleId      { get; set; }  // nullable
    public int?   DivisionId    { get; set; }  // nullable
    public int?   SubDivisionId { get; set; }  // nullable
    public string CreatedAt     { get; set; }  // ISO 8601
}
```

### `UserDetailResponse`
```csharp
public class UserDetailResponse {
    public string UserId        { get; set; }
    public string LoginId       { get; set; }
    public string DisplayName   { get; set; }
    public string SystemRole    { get; set; }
    public string UserStatus    { get; set; }
    public string CreatedAt     { get; set; }  // ISO 8601

    // Contact info (decrypted from dbo.user_identities)
    public string Email         { get; set; }  // nullable
    public string Phone         { get; set; }  // nullable

    // Master data — IDs only, all nullable
    public int?   DsgId         { get; set; }
    public int?   StateId       { get; set; }
    public int?   ZoneId        { get; set; }
    public int?   CircleId      { get; set; }
    public int?   DivisionId    { get; set; }
    public int?   SubDivisionId { get; set; }
}
```

### `CreateUserRequest`
```csharp
public class CreateUserRequest {
    // Required
    public string DisplayName   { get; set; }
    public string LoginId       { get; set; }

    // Optional
    public string Password      { get; set; }  // defaults to "welcome@123"
    public string SystemRole    { get; set; }   // "CCA" or "EMPLOYEE" — defaults to "EMPLOYEE"

    // Optional — contact info (stored AES-encrypted in dbo.user_identities)
    public string Email         { get; set; }  // nullable
    public string Phone         { get; set; }  // nullable

    // Optional master data — all nullable
    public int?   DsgId         { get; set; }  // FK → tbDsg.dsgId
    public int?   StateId       { get; set; }  // FK → State.State_ID
    public int?   ZoneId        { get; set; }  // FK → Zone.Zone_ID
    public int?   CircleId      { get; set; }  // FK → Circle.Circle_ID
    public int?   DivisionId    { get; set; }  // FK → Division.Division_ID
    public int?   SubDivisionId { get; set; }  // FK → SubDivision.SubDivisionID
}
```

### `UpdateUserRequest`
```csharp
public class UpdateUserRequest {
    // All fields optional — only non-null / non-empty fields are applied.
    // UserId, LoginId, SystemRole, UserStatus, CreatedAt are immutable (ignored if sent).

    public string DisplayName   { get; set; }
    public string Password      { get; set; }   // if set, re-hashed and stored
    public string Email         { get; set; }   // if set, replaces existing EMAIL identity
    public string Phone         { get; set; }   // if set, replaces existing PHONE identity

    // Master data
    public int?   DsgId         { get; set; }
    public int?   StateId       { get; set; }
    public int?   ZoneId        { get; set; }
    public int?   CircleId      { get; set; }
    public int?   DivisionId    { get; set; }
    public int?   SubDivisionId { get; set; }

    // Clear flags
    public bool   ClearEmail      { get; set; }  // true → removes EMAIL identity
    public bool   ClearPhone      { get; set; }  // true → removes PHONE identity
    public bool   ClearDsg        { get; set; }  // true → sets dsg_id = NULL
    public bool   ClearGeography  { get; set; }  // true → clears all 5 geography fields
}
```

### `UpdateUserStatusRequest`
```csharp
public class UpdateUserStatusRequest {
    public string UserStatus { get; set; }  // "ACTIVE" | "INACTIVE"
}
```

### `BulkCreateResult`
```csharp
public class BulkCreateResult {
    public int            TotalRows    { get; set; }
    public int            SuccessCount { get; set; }
    public int            FailureCount { get; set; }
    public List<RowError> Errors       { get; set; }
}

public class RowError {
    public int    RowNumber { get; set; }  // 1-based; header = 1, first data = 2
    public string LoginId   { get; set; }  // from that row if parseable, else null
    public string Reason    { get; set; }
}
```

---

## Geography Validation Rules (Create & Update)

Applied in this order at the service layer:

1. If `CircleId` provided → `ZoneId` must also be provided and the circle must belong to that zone
2. If `DivisionId` provided → `CircleId` must also be provided and the division must belong to that circle
3. If `SubDivisionId` provided → `DivisionId` must also be provided and the subdivision must belong to that division
4. Each ID must exist in its respective master table

On **partial update** — only the fields sent are validated. If admin updates only `SubDivisionId` without sending `DivisionId`, the backend looks up the existing `division_id` on the user to validate the parent.

| Error code | Meaning |
|---|---|
| `INVALID_DSG` | `DsgId` not found in `tbDsg` |
| `INVALID_STATE` | `StateId` not found |
| `INVALID_ZONE` | `ZoneId` not found |
| `INVALID_CIRCLE` | `CircleId` not found or doesn't belong to given `ZoneId` |
| `INVALID_DIVISION` | `DivisionId` not found or doesn't belong to given `CircleId` |
| `INVALID_SUBDIVISION` | `SubDivisionId` not found or doesn't belong to given `DivisionId` |

---

## API 1 — Create Single User
**POST** `/api/user/createuser`  
**Controller:** `UserController.cs`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Request
```json
{
  "DisplayName": "Ramesh Kumar",
  "LoginId": "emp_001",
  "Password": "welcome@123",
  "SystemRole": "EMPLOYEE",
  "Email": "ramesh.kumar@dhbvn.org",
  "Phone": "9876543210",
  "DsgId": 1001,
  "StateId": 6,
  "ZoneId": 1,
  "CircleId": 101,
  "DivisionId": 1001,
  "SubDivisionId": 10001
}
```

> All master data fields are optional. If omitted, they are stored as `NULL`.

### Success `201`
```json
{
  "Success": true,
  "Message": "User created successfully",
  "Data": { "UserId": "a1b2c3d4-..." },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `DisplayName` or `LoginId` missing | `BAD_REQUEST` | 400 |
| `SystemRole` is not `CCA` or `EMPLOYEE` | `BAD_REQUEST` | 400 |
| `LoginId` already exists | `USER_EXISTS` | 409 |
| Email or phone already registered to another user | `DUPLICATE_IDENTITY` | 409 |
| `DsgId` not found in `tbDsg` | `INVALID_DSG` | 400 |
| Geography validation failed | `INVALID_STATE` / `INVALID_ZONE` / `INVALID_CIRCLE` / `INVALID_DIVISION` / `INVALID_SUBDIVISION` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 2 — Bulk Create Users via Excel
**POST** `/api/admin/users/bulk`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`  
Content-Type: `multipart/form-data`

Accepts a single `.xlsx` file. Failed rows are skipped and reported; successful rows are committed individually.

### Expected Excel Column Layout
| Column | Field | Required | Notes |
|---|---|---|---|
| A | `LoginId` | Yes | Must be unique |
| B | `DisplayName` | Yes | |
| C | `Password` | No | Defaults to `welcome@123` |
| D | `SystemRole` | No | `CCA` or `EMPLOYEE` — defaults to `EMPLOYEE`. Any other value fails the row. |
| E | `DsgCode` | No | Short code e.g. `"SE"` — matched against `tbDsg.dsg`. Row still succeeds if not matched (stored as NULL, warning added). |
| F | `SubDivisionId` | No | INT. If provided, parent chain (`DivisionId`, `CircleId`, `ZoneId`, `StateId`) is looked up automatically from the master tables and stored on the user. Row fails if ID not found. |

> Row 1 must be the header row. Data begins at Row 2. Blank rows are silently skipped.

### Success `200`
```json
{
  "Success": true,
  "Message": "Bulk import completed",
  "Data": {
    "TotalRows": 10,
    "SuccessCount": 8,
    "FailureCount": 2,
    "Errors": [
      { "RowNumber": 4, "LoginId": "emp_007", "Reason": "LoginId already exists" },
      { "RowNumber": 9, "LoginId": "emp_012", "Reason": "SubDivisionId 99999 not found" }
    ]
  },
  "ErrorCode": null
}
```

> HTTP `200` even when some rows fail. HTTP `400` only for an unparseable file.

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| No file in request | `BAD_REQUEST` | 400 |
| File is not `.xlsx` | `INVALID_FILE_TYPE` | 400 |
| File is corrupt / unreadable | `FILE_PARSE_ERROR` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |

---

## API 3 — List All Users
**GET** `/api/admin/users`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Query Params (all optional)
| Param | Type | Description |
|---|---|---|
| `role` | string | Filter by `CCA` or `EMPLOYEE` |
| `status` | string | Filter by `ACTIVE`, `INACTIVE`, or `PENDING` |
| `dsgId` | int | Filter by designation |
| `zoneId` | int | Filter by zone |
| `divisionId` | int | Filter by division |

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "Users": [
      {
        "UserId": "a1b2c3d4-...",
        "LoginId": "emp_001",
        "DisplayName": "Ramesh Kumar",
        "SystemRole": "EMPLOYEE",
        "UserStatus": "ACTIVE",
        "DsgId": 1001,
        "StateId": 6,
        "ZoneId": 1,
        "CircleId": 101,
        "DivisionId": 1001,
        "SubDivisionId": 10001,
        "CreatedAt": "2026-01-15T10:30:00"
      }
    ],
    "TotalCount": 1
  },
  "ErrorCode": null
}
```

---

## API 4 — Get User Detail
**GET** `/api/admin/users/{userId}`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Success `200`
```json
{
  "Success": true,
  "Message": "Success",
  "Data": {
    "UserId": "a1b2c3d4-...",
    "LoginId": "emp_001",
    "DisplayName": "Ramesh Kumar",
    "SystemRole": "EMPLOYEE",
    "UserStatus": "ACTIVE",
    "CreatedAt": "2026-01-15T10:30:00",
    "Email": "ramesh.kumar@dhbvn.org",
    "Phone": "9876543210",
    "DsgId": 1001,
    "StateId": 6,
    "ZoneId": 1,
    "CircleId": 101,
    "DivisionId": 1001,
    "SubDivisionId": 10001
  },
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| User not found | `USER_NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |

---

## API 5 — Update User Profile
**PATCH** `/api/admin/users/{userId}`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

Partial update — only fields present and non-empty in the body are applied.  
`UserId`, `LoginId`, `SystemRole`, `UserStatus`, and `CreatedAt` are immutable.  
Use `ClearEmail`, `ClearPhone`, `ClearDsg`, or `ClearGeography` flags to explicitly remove those values.

### Request
```json
{
  "DisplayName": "Ramesh Kumar Sharma",
  "Password": "newPass@456",
  "Email": "ramesh.new@dhbvn.org",
  "Phone": "9123456789",
  "DsgId": 1002,
  "ZoneId": 1,
  "CircleId": 101,
  "DivisionId": 1001,
  "SubDivisionId": 10001
}
```

### Success `200`
```json
{
  "Success": true,
  "Message": "User updated successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Email already registered to another user | `DUPLICATE_IDENTITY` | 409 |
| Phone already registered to another user | `DUPLICATE_IDENTITY` | 409 |
| Geography validation failed | `INVALID_DSG` / `INVALID_ZONE` / `INVALID_CIRCLE` / `INVALID_DIVISION` / `INVALID_SUBDIVISION` | 400 |
| User not found | `USER_NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 6 — Update User Status
**PATCH** `/api/admin/users/{userId}/status`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Request
```json
{ "UserStatus": "INACTIVE" }
```

### Success `200`
```json
{
  "Success": true,
  "Message": "User status updated successfully",
  "Data": {},
  "ErrorCode": null
}
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Body missing or `UserStatus` invalid | `BAD_REQUEST` | 400 |
| User not found | `USER_NOT_FOUND` | 404 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |

---

## Note on Designations
Designations are managed entirely through the Masters APIs:

- `GET  /api/admin/masters/designations` — list all
- `POST /api/admin/masters/designations` — create new
- `PATCH /api/admin/masters/designations/{dsgId}` — update

There is no separate `/api/admin/designations` endpoint. When populating the designation dropdown on the Create/Edit User form, call the Masters API.

---

## `IAdminUseCase` — interface shape
```csharp
public interface IAdminUseCase {
    ApiResponse<UserListResponse>   GetAllUsers(string role, string status, int? dsgId, int? zoneId, int? divisionId);
    ApiResponse<UserDetailResponse> GetUserById(string userId);
    ApiResponse<EmptyResponse>      UpdateUser(string userId, UpdateUserRequest request);
    ApiResponse<EmptyResponse>      UpdateUserStatus(string userId, string userStatus);
    ApiResponse<BulkCreateResult>   BulkCreateUsers(Stream excelStream);
}
```
