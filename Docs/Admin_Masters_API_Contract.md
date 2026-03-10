# Admin Masters API Contract
**RoutePrefix:** `api/admin`  
**Controller:** `AdminMastersController.cs`  
**All responses:** `ApiResponse<T>`  
**Access:** `ADMIN` role only (enforced by `RouteAccessPolicy` — `/api/admin/*`)

Covers six master/lookup tables: `tbDsg`, `State`, `Zone`, `Circle`, `Division`, `SubDivision`.

---

## Architecture

```
AdminMastersController  →  IAdminMastersUseCase  →  AdminMastersService  →  IAdminMastersRepoPort  →  AdminMastersAdapter
```

---

## Schema — Optimized DDL

### ID Strategy
All tables use `IDENTITY` — the DB auto-assigns every primary/business key. Callers **never send IDs** in POST requests.

| Table | PK / surrogate | Business key (used in child FKs) | Auto-start |
|---|---|---|---|
| `tbDsg` | `dsgId` | same | 1001 |
| `State` | `SNID` | `State_ID` | both from 1 |
| `Zone` | `ZID` | `Zone_ID` | both from 1 |
| `Circle` | `CID` | `Circle_ID` | both from 1 |
| `Division` | `DID` | `Division_ID` | both from 1 |
| `SubDivision` | `SID` | `SubDivisionID` | both from 1 |

> For `State`, `Zone`, `Circle`, `Division`, `SubDivision`: the surrogate PK (`SNID`, `ZID`, etc.) and business key (`State_ID`, `Zone_ID`, etc.) are kept as **two separate columns** to preserve the existing schema shape. Both are driven by the same `IDENTITY` sequence — i.e. `State_ID` is also `IDENTITY(1,1)` and equals `SNID` in value. Child FK references use the business key column.

### Optimized DDL

```sql
-- ============================================================
-- tbDsg — Designation master  (auto-increment from 1001)
-- ============================================================
CREATE TABLE [dbo].[tbDsg] (
    [dsgId]       INT          NOT NULL IDENTITY(1001,1),
    [dsg]         VARCHAR(20)  NOT NULL,
    [dsgDesc]     VARCHAR(50)  NULL,
    [dsgLevel]    INT          NOT NULL,
    [dsgIsActive] BIT          NOT NULL DEFAULT 1,
    [created_at]  DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_tbDsg      PRIMARY KEY (dsgId),
    CONSTRAINT UQ_tbDsg_code UNIQUE (dsg)
);

-- ============================================================
-- State  (both SNID and State_ID auto-increment from 1)
-- ============================================================
CREATE TABLE [dbo].[State] (
    [SNID]       INT          NOT NULL IDENTITY(1,1),
    [Country_ID] INT          NOT NULL DEFAULT 1,
    [State_ID]   INT          NOT NULL IDENTITY(1,1),   -- same sequence, kept for FK compat
    [State]      VARCHAR(200) NOT NULL,
    [created_at] DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_State    PRIMARY KEY (SNID),
    CONSTRAINT UQ_State_ID UNIQUE (State_ID)
);
-- Note: SQL Server does not allow two IDENTITY columns in one table.
-- Practical approach: use SNID as IDENTITY(1,1), compute State_ID = SNID via a persisted computed column:
-- [State_ID] AS ([SNID]) PERSISTED NOT NULL
-- Final recommended DDL:
CREATE TABLE [dbo].[State] (
    [SNID]       INT          NOT NULL IDENTITY(1,1),
    [Country_ID] INT          NOT NULL DEFAULT 1,
    [State_ID]   AS ([SNID])  PERSISTED NOT NULL,        -- mirrors SNID; child FKs use this
    [State]      VARCHAR(200) NOT NULL,
    [created_at] DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_State    PRIMARY KEY (SNID),
    CONSTRAINT UQ_State_ID UNIQUE (State_ID)
);

-- ============================================================
-- Zone
-- ============================================================
CREATE TABLE [dbo].[Zone] (
    [ZID]     INT           NOT NULL IDENTITY(1,1),
    [Zone_ID] AS ([ZID])    PERSISTED NOT NULL,
    [Zone]    NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Zone    PRIMARY KEY (ZID),
    CONSTRAINT UQ_Zone_ID UNIQUE (Zone_ID)
);

-- ============================================================
-- Circle
-- ============================================================
CREATE TABLE [dbo].[Circle] (
    [CID]       INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]   INT           NOT NULL,
    [Circle_ID] AS ([CID])    PERSISTED NOT NULL,
    [Circle]    NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Circle      PRIMARY KEY (CID),
    CONSTRAINT UQ_Circle_ID   UNIQUE (Circle_ID),
    CONSTRAINT FK_Circle_Zone FOREIGN KEY (Zone_ID) REFERENCES [dbo].[Zone](Zone_ID)
);

-- ============================================================
-- Division
-- ============================================================
CREATE TABLE [dbo].[Division] (
    [DID]         INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]     INT           NOT NULL,
    [Circle_ID]   INT           NOT NULL,
    [Division_ID] AS ([DID])    PERSISTED NOT NULL,
    [Division]    NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Division        PRIMARY KEY (DID),
    CONSTRAINT UQ_Division_ID     UNIQUE (Division_ID),
    CONSTRAINT FK_Division_Zone   FOREIGN KEY (Zone_ID)   REFERENCES [dbo].[Zone](Zone_ID),
    CONSTRAINT FK_Division_Circle FOREIGN KEY (Circle_ID) REFERENCES [dbo].[Circle](Circle_ID)
);

-- ============================================================
-- SubDivision
-- ============================================================
CREATE TABLE [dbo].[SubDivision] (
    [SID]             INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]         INT           NOT NULL,
    [Circle_ID]       INT           NOT NULL,
    [Division_ID]     INT           NOT NULL,
    [SubDivisionID]   AS ([SID])    PERSISTED NOT NULL,
    [SubDivision]     NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_SubDivision       PRIMARY KEY (SID),
    CONSTRAINT UQ_SubDivision_ID    UNIQUE (SubDivisionID),
    CONSTRAINT FK_SubDiv_Zone       FOREIGN KEY (Zone_ID)     REFERENCES [dbo].[Zone](Zone_ID),
    CONSTRAINT FK_SubDiv_Circle     FOREIGN KEY (Circle_ID)   REFERENCES [dbo].[Circle](Circle_ID),
    CONSTRAINT FK_SubDiv_Division   FOREIGN KEY (Division_ID) REFERENCES [dbo].[Division](Division_ID)
);

-- ============================================================
-- dbo.users — FK to tbDsg
-- ============================================================
ALTER TABLE dbo.users ADD
    dsg_id INT NULL CONSTRAINT FK_users_tbDsg FOREIGN KEY REFERENCES [dbo].[tbDsg](dsgId);
```

---

## Models

### Response item shapes

```csharp
public class DsgItem {
    public int    DsgId    { get; set; }
    public string Dsg      { get; set; }
    public string DsgDesc  { get; set; }
    public int    DsgLevel { get; set; }
    public bool   IsActive { get; set; }
}

public class StateItem {
    public int    StateId   { get; set; }   // = SNID
    public string StateName { get; set; }
}

public class ZoneItem {
    public int    ZoneId   { get; set; }    // = ZID
    public string ZoneName { get; set; }
}

public class CircleItem {
    public int    CircleId { get; set; }    // = CID
    public int    ZoneId   { get; set; }
    public string Circle   { get; set; }
}

public class DivisionItem {
    public int    DivisionId { get; set; }  // = DID
    public int    ZoneId     { get; set; }
    public int    CircleId   { get; set; }
    public string Division   { get; set; }
}

public class SubDivisionItem {
    public int    SubDivisionId { get; set; }  // = SID
    public int    ZoneId        { get; set; }
    public int    CircleId      { get; set; }
    public int    DivisionId    { get; set; }
    public string SubDivision   { get; set; }
}
```

### Create request shapes — **IDs are never sent by caller**

```csharp
public class CreateDsgRequest      { string Dsg; string DsgDesc; int DsgLevel; }
public class CreateStateRequest    { string StateName; }
public class CreateZoneRequest     { string ZoneName; }
public class CreateCircleRequest   { int ZoneId; string Circle; }
public class CreateDivisionRequest { int ZoneId; int CircleId; string Division; }
public class CreateSubDivisionRequest { int ZoneId; int CircleId; int DivisionId; string SubDivision; }
```

### Create response shapes — **DB-assigned ID returned**

```csharp
public class DsgIdResponse         { int DsgId; }
public class StateIdResponse       { int StateId; }
public class ZoneIdResponse        { int ZoneId; }
public class CircleIdResponse      { int CircleId; }
public class DivisionIdResponse    { int DivisionId; }
public class SubDivisionIdResponse { int SubDivisionId; }
```

---

## API 9 — Get Designations
**GET** `/api/admin/masters/designations?activeOnly=true`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Query Params
| Param | Type | Default | Description |
|---|---|---|---|
| `activeOnly` | bool | `true` | When `true`, returns only `dsgIsActive = 1` rows |

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Designations": [
      { "DsgId": 1001, "Dsg": "JE",  "DsgDesc": "Junior Engineer",         "DsgLevel": 1, "IsActive": true },
      { "DsgId": 1002, "Dsg": "AE",  "DsgDesc": "Assistant Engineer",      "DsgLevel": 2, "IsActive": true },
      { "DsgId": 1003, "Dsg": "SE",  "DsgDesc": "Superintending Engineer", "DsgLevel": 3, "IsActive": true }
    ]
  }, "ErrorCode": null
}
```

---

## API 10 — Create Designation
**POST** `/api/admin/masters/designations`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`dsgId` is auto-assigned starting at 1001. Do **not** send `dsgId`.

### Request
```json
{ "Dsg": "XEN", "DsgDesc": "Executive Engineer", "DsgLevel": 4 }
```

### Success `201`
```json
{ "Success": true, "Message": "Designation created successfully", "Data": { "DsgId": 1004 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `Dsg` missing | `BAD_REQUEST` | 400 |
| `DsgLevel` missing or <= 0 | `BAD_REQUEST` | 400 |
| `Dsg` code already exists | `DESIGNATION_EXISTS` | 409 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 11 — Get States
**GET** `/api/admin/masters/states`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "States": [
      { "StateId": 1, "StateName": "Haryana" },
      { "StateId": 2, "StateName": "Punjab" }
    ]
  }, "ErrorCode": null
}
```

---

## API 12 — Create State
**POST** `/api/admin/masters/states`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`StateId` is auto-assigned by DB. Do **not** send `StateId`.

### Request
```json
{ "StateName": "Rajasthan" }
```

### Success `201`
```json
{ "Success": true, "Message": "State created successfully", "Data": { "StateId": 3 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `StateName` missing | `BAD_REQUEST` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 13 — Get Zones
**GET** `/api/admin/masters/zones`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Zones": [
      { "ZoneId": 1, "ZoneName": "Hisar Zone" },
      { "ZoneId": 2, "ZoneName": "Rohtak Zone" }
    ]
  }, "ErrorCode": null
}
```

---

## API 14 — Create Zone
**POST** `/api/admin/masters/zones`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`ZoneId` is auto-assigned. Do **not** send `ZoneId`.

### Request
```json
{ "ZoneName": "Faridabad Zone" }
```

### Success `201`
```json
{ "Success": true, "Message": "Zone created successfully", "Data": { "ZoneId": 3 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `ZoneName` missing | `BAD_REQUEST` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 15 — Get Circles
**GET** `/api/admin/masters/circles?zoneId=1`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Query Params
| Param | Type | Required | Description |
|---|---|---|---|
| `zoneId` | int | No | Filter by parent zone |

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Circles": [
      { "CircleId": 1, "ZoneId": 1, "Circle": "Hisar Circle" },
      { "CircleId": 2, "ZoneId": 1, "Circle": "Sirsa Circle" }
    ]
  }, "ErrorCode": null
}
```

---

## API 16 — Create Circle
**POST** `/api/admin/masters/circles`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`CircleId` is auto-assigned. Do **not** send `CircleId`.

### Request
```json
{ "ZoneId": 1, "Circle": "Fatehabad Circle" }
```

### Success `201`
```json
{ "Success": true, "Message": "Circle created successfully", "Data": { "CircleId": 3 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| `ZoneId` or `Circle` missing | `BAD_REQUEST` | 400 |
| `ZoneId` not found | `INVALID_ZONE` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 17 — Get Divisions
**GET** `/api/admin/masters/divisions?zoneId=1&circleId=1`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Query Params
| Param | Type | Required | Description |
|---|---|---|---|
| `zoneId` | int | No | Filter by zone |
| `circleId` | int | No | Filter by circle |

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "Divisions": [
      { "DivisionId": 1, "ZoneId": 1, "CircleId": 1, "Division": "Hisar Division" },
      { "DivisionId": 2, "ZoneId": 1, "CircleId": 1, "Division": "Hansi Division" }
    ]
  }, "ErrorCode": null
}
```

---

## API 18 — Create Division
**POST** `/api/admin/masters/divisions`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`DivisionId` is auto-assigned. Do **not** send `DivisionId`.

### Request
```json
{ "ZoneId": 1, "CircleId": 1, "Division": "Adampur Division" }
```

### Success `201`
```json
{ "Success": true, "Message": "Division created successfully", "Data": { "DivisionId": 3 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Any required field missing | `BAD_REQUEST` | 400 |
| `ZoneId` not found | `INVALID_ZONE` | 400 |
| `CircleId` not found | `INVALID_CIRCLE` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## API 19 — Get SubDivisions
**GET** `/api/admin/masters/subdivisions?zoneId=1&circleId=1&divisionId=1`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

### Query Params
| Param | Type | Required | Description |
|---|---|---|---|
| `zoneId` | int | No | Filter by zone |
| `circleId` | int | No | Filter by circle |
| `divisionId` | int | No | Filter by division |

### Success `200`
```json
{
  "Success": true, "Message": "Success",
  "Data": {
    "SubDivisions": [
      { "SubDivisionId": 1, "ZoneId": 1, "CircleId": 1, "DivisionId": 1, "SubDivision": "Hisar-I Sub Division" },
      { "SubDivisionId": 2, "ZoneId": 1, "CircleId": 1, "DivisionId": 1, "SubDivision": "Hisar-II Sub Division" }
    ]
  }, "ErrorCode": null
}
```

---

## API 20 — Create SubDivision
**POST** `/api/admin/masters/subdivisions`  
Requires: `Authorization: Bearer <token>` | Role: `ADMIN`

`SubDivisionId` is auto-assigned. Do **not** send `SubDivisionId`.

### Request
```json
{ "ZoneId": 1, "CircleId": 1, "DivisionId": 1, "SubDivision": "Hisar-III Sub Division" }
```

### Success `201`
```json
{ "Success": true, "Message": "SubDivision created successfully", "Data": { "SubDivisionId": 3 }, "ErrorCode": null }
```

### Failure Cases
| Scenario | ErrorCode | HTTP |
|---|---|---|
| Any required field missing | `BAD_REQUEST` | 400 |
| `ZoneId` not found | `INVALID_ZONE` | 400 |
| `CircleId` not found | `INVALID_CIRCLE` | 400 |
| `DivisionId` not found | `INVALID_DIVISION` | 400 |
| Token missing / invalid | `TOKEN_INVALID` | 401 |
| Role not ADMIN | `FORBIDDEN` | 403 |
| Unexpected error | `INTERNAL_ERROR` | 500 |

---

## `IAdminMastersUseCase` — interface shape

```csharp
// tbDsg
ApiResponse<DsgListResponse>         GetDesignations(bool activeOnly);
ApiResponse<DsgIdResponse>           CreateDesignation(CreateDsgRequest request);

// State
ApiResponse<StateListResponse>       GetStates();
ApiResponse<StateIdResponse>         CreateState(CreateStateRequest request);

// Zone
ApiResponse<ZoneListResponse>        GetZones();
ApiResponse<ZoneIdResponse>          CreateZone(CreateZoneRequest request);

// Circle
ApiResponse<CircleListResponse>      GetCircles(int? zoneId);
ApiResponse<CircleIdResponse>        CreateCircle(CreateCircleRequest request);

// Division
ApiResponse<DivisionListResponse>    GetDivisions(int? zoneId, int? circleId);
ApiResponse<DivisionIdResponse>      CreateDivision(CreateDivisionRequest request);

// SubDivision
ApiResponse<SubDivisionListResponse> GetSubDivisions(int? zoneId, int? circleId, int? divisionId);
ApiResponse<SubDivisionIdResponse>   CreateSubDivision(CreateSubDivisionRequest request);
```

---

## Route Summary

| Method | Route | Description |
|---|---|---|
| GET | `/api/admin/masters/designations` | List designations |
| POST | `/api/admin/masters/designations` | Create designation |
| GET | `/api/admin/masters/states` | List states |
| POST | `/api/admin/masters/states` | Create state |
| GET | `/api/admin/masters/zones` | List zones |
| POST | `/api/admin/masters/zones` | Create zone |
| GET | `/api/admin/masters/circles?zoneId=` | List circles |
| POST | `/api/admin/masters/circles` | Create circle |
| GET | `/api/admin/masters/divisions?zoneId=&circleId=` | List divisions |
| POST | `/api/admin/masters/divisions` | Create division |
| GET | `/api/admin/masters/subdivisions?zoneId=&circleId=&divisionId=` | List subdivisions |
| POST | `/api/admin/masters/subdivisions` | Create subdivision |
