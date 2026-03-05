# ACR Portal – Complete Project Understanding
**Tech Stack: ASP.NET MVC (.NET Framework 4.x) | SQL Server (SSMS) | Visual Studio 2019**

---

## What Is This Project?

An **Online Annual Confidential Report (ACR) Portal** for DHBVN (a power distribution company in Haryana). It digitizes the process of evaluating Engineering Wing Officers (rank: SE and above) through a strict sequential workflow.

---

## Critical Design Concept 1: Roles Are Per-ACR, Not Per-Person

**A person does not have a fixed role.** The same person can simultaneously be:

- An **Officer** (subject to their own appraisal)
- A **Reporting Authority** (evaluating someone junior to them)
- A **Reviewing Authority** (reviewing someone else's evaluation)
- An **Accepting Authority** (final approver in yet another ACR)

Think of it like a chain of managers. Everyone has a boss above them and subordinates below them.

**The only fixed roles are Admin and CCA** — these are system-level roles, not part of the appraisal chain.

### Real Example:
```
[Officer: Ramesh EMP001]  →  evaluated by  →  [Reporting Auth: Suresh EMP002]
[Officer: Suresh EMP002]  →  evaluated by  →  [Reporting Auth: Mahesh EMP003]
```
When Suresh (EMP002) logs in, his dashboard shows:
1. "Fill your own self-appraisal" (he is the Officer in his own ACR)
2. "Assess Ramesh's appraisal" (he is the Reporting Authority in Ramesh's ACR)

---

## Critical Design Concept 2: One ACR Per Posting, Not Per Year

An officer who worked in **multiple departments/postings during an ACR year** will have **one separate ACR for each posting**. Each ACR covers only the period they were posted at that location.

### Real Example:
```
Ramesh (EMP001) in ACR Year 2024:

  Posting 1: SE at Hisar Division    (01-Apr-2024 to 30-Sep-2024) → ACR #1
  Posting 2: SE at Sirsa Division    (01-Oct-2024 to 31-Mar-2025) → ACR #2
```

Ramesh has **two separate ACRs** for 2024. Each has its own Reporting Authority, Reviewing Authority, Accepting Authority, and goes through the full workflow independently.

This means:
- The unique constraint on ACR is `(OfficerCode, PostingId)` — not `(OfficerCode, ACRYear)`
- CCA creates one ACR per posting, entering the posting period and department each time
- The dashboard groups ACRs by year but shows each posting separately
- A person can be evaluating Ramesh's Hisar ACR while Ramesh's Sirsa ACR is still pending

---

## The Roles in Context

| Role | Nature | Who Has It |
|---|---|---|
| **Administrator** | Fixed system role | 1 dedicated admin account |
| **Cadre Controlling Authority (CCA)** | Fixed system role | 1 or more dedicated CCA accounts |
| **Officer** | Per-ACR role | The person being evaluated for that posting |
| **Reporting Authority** | Per-ACR role | The direct manager during that posting period |
| **Reviewing Authority** | Per-ACR role | The manager's manager during that posting period |
| **Accepting Authority** | Per-ACR role | The top authority for that ACR |

> Note: Because postings can have different managers, Ramesh's RA in his Hisar ACR could be a completely different person from his RA in his Sirsa ACR.

---

## End-to-End Flow (From Login to Final Step)

```
[Admin creates all employee accounts]
        ↓
[CCA logs in → Creates ACR for a specific posting of an Officer
             → Enters posting details (dept, location, from date, to date)
             → Assigns RA, RvA, AA relevant to THAT posting → Submits]
        ↓
[Officer logs in → Sees ALL their pending posting-wise ACRs on dashboard
                → Fills self-appraisal for each posting → Submits]
        ↓
[Reporting Authority logs in → Sees ACRs from their posting period in queue → Grades → Forwards]
        ↓
[Reviewing Authority logs in → Reviews → Forwards]
        ↓
[Accepting Authority logs in → Final decision → ACR Closed]
```

Each posting-ACR goes through the workflow **independently and in parallel** with other ACRs for the same officer.

---

## Authentication Flow (OTP-Based, Single Token)

### How Login Works:
1. User goes to `/Login`
2. Enters **Employee Code + Password** — EmployeeCode is the username, no separate ID
3. System finds the employee in `Users` table by EmployeeCode
4. If valid → Generates a **6-digit OTP**, stores in `OTPLog` with 5-minute expiry, sends via email
5. User enters OTP on next screen
6. If OTP matches and not expired → Mark OTP as used → Generate **JWT Token** (24-hour expiry, NO refresh token)
7. JWT payload: `{ EmployeeCode, SystemRole, FullName, exp: now+24hrs }`
8. Token stored in `AuthTokens` table AND server-side Session
9. Every subsequent request validates this token via a custom `JwtAuthFilter`

> The JWT only carries `SystemRole` (Admin/CCA/Employee). The person's contextual role in any specific ACR (Officer/RA/RvA/AA) is always looked up live from `OfficerProfiles` at request time.

---

## Database Schema (SQL Server / SSMS)

---

### Table 1: `Users`
```sql
CREATE TABLE Users (
    EmployeeCode NVARCHAR(50)  PRIMARY KEY,    -- The unique identifier. No separate UserId.
    FullName     NVARCHAR(200) NOT NULL,
    Email        NVARCHAR(200) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,        -- BCrypt hash
    SystemRole   NVARCHAR(50)  NOT NULL,        -- 'Admin' | 'CCA' | 'Employee'
    IsActive     BIT DEFAULT 1,
    CreatedAt    DATETIME DEFAULT GETDATE()
)
```

> All appraisal chain members are `'Employee'`. Their role in any given ACR (Officer/RA/RvA/AA) is determined per posting via `OfficerProfiles`.

---

### Table 2: `Postings` ← NEW TABLE
```sql
CREATE TABLE Postings (
    PostingId        INT PRIMARY KEY IDENTITY,
    EmployeeCode     NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),

    -- Where and what they were posted as
    Department       NVARCHAR(200) NOT NULL,    -- e.g. "Hisar Division"
    Location         NVARCHAR(200) NOT NULL,    -- e.g. "Hisar"
    Designation      NVARCHAR(200) NOT NULL,    -- e.g. "Superintending Engineer"

    -- When this posting was active
    PostingFrom      DATE NOT NULL,             -- e.g. 2024-04-01
    PostingTo        DATE NOT NULL,             -- e.g. 2024-09-30

    -- ACR year this posting falls under
    ACRYear          INT NOT NULL,              -- e.g. 2024

    CreatedAt        DATETIME DEFAULT GETDATE(),

    -- One posting record per employee per department per period
    CONSTRAINT UQ_Posting UNIQUE (EmployeeCode, Department, PostingFrom)
)
```

> **Why a separate Postings table?**
> Posting info (department, location, period) is factual employment data — it belongs separately from the ACR workflow data. One posting row = one real-world assignment. The `OfficerProfiles` table then links to it, creating one ACR for that posting.

---

### Table 3: `OfficerProfiles` ← UPDATED (links to Postings, not directly to year)
```sql
CREATE TABLE OfficerProfiles (
    ProfileId           INT PRIMARY KEY IDENTITY,

    -- Link to the specific posting this ACR covers
    PostingId           INT FOREIGN KEY REFERENCES Postings(PostingId),

    -- The four people involved in this ACR cycle
    OfficerCode         NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    ReportingAuthCode   NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    ReviewingAuthCode   NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    AcceptingAuthCode   NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    CCACode             NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),

    -- Officer general info entered by CCA (applies to this ACR only)
    DateOfBirth         DATE,
    Qualification       NVARCHAR(500),
    PostingHistory      NVARCHAR(MAX),           -- Overall career posting history summary
    MedicalRecordPath   NVARCHAR(500),
    PropertyReturnDone  BIT DEFAULT 0,

    -- Workflow state
    Status              NVARCHAR(50) DEFAULT 'PendingOfficer',
    CreatedAt           DATETIME DEFAULT GETDATE(),

    -- One ACR per posting — a posting can only have one ACR
    CONSTRAINT UQ_ACR_Per_Posting UNIQUE (PostingId)
)
```

> The old `UNIQUE (OfficerCode, ACRYear)` is gone. Now the constraint is `UNIQUE (PostingId)` — one ACR per posting. Since a posting already uniquely identifies the officer, department, and period, this correctly allows multiple ACRs per officer per year (one per posting).

---

### Table 4: `OTPLog`
```sql
CREATE TABLE OTPLog (
    OTPId        INT PRIMARY KEY IDENTITY,
    EmployeeCode NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    OTPCode      NVARCHAR(10) NOT NULL,
    CreatedAt    DATETIME DEFAULT GETDATE(),
    ExpiresAt    DATETIME NOT NULL,             -- CreatedAt + 5 minutes
    IsUsed       BIT DEFAULT 0
)
```

---

### Table 5: `AuthTokens`
```sql
CREATE TABLE AuthTokens (
    TokenId      INT PRIMARY KEY IDENTITY,
    EmployeeCode NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    Token        NVARCHAR(MAX) NOT NULL,
    CreatedAt    DATETIME DEFAULT GETDATE(),
    ExpiresAt    DATETIME NOT NULL,             -- CreatedAt + 24 hours
    IsRevoked    BIT DEFAULT 0
)
```

---

### Table 6: `SelfAppraisal` (Section II)
```sql
CREATE TABLE SelfAppraisal (
    AppraisalId        INT PRIMARY KEY IDENTITY,
    ProfileId          INT FOREIGN KEY REFERENCES OfficerProfiles(ProfileId),
    DutiesPerformed    NVARCHAR(MAX),
    Achievements       NVARCHAR(MAX),
    MajorContributions NVARCHAR(MAX),
    TrainingsUndergone NVARCHAR(MAX),
    AwardsReceived     NVARCHAR(MAX),
    LeaveDetails       NVARCHAR(MAX),
    PropertyDeclared   BIT DEFAULT 0,
    MedicalCompliance  BIT DEFAULT 0,
    DocumentPath       NVARCHAR(500),
    SubmittedAt        DATETIME
)
```

---

### Table 7: `ReportingAssessment` (Section III)
```sql
CREATE TABLE ReportingAssessment (
    AssessmentId        INT PRIMARY KEY IDENTITY,
    ProfileId           INT FOREIGN KEY REFERENCES OfficerProfiles(ProfileId),
    WorkOutputGrade     INT,                    -- 1 to 10
    PersonalAttrGrade   INT,                    -- 1 to 10
    FunctionalCompGrade INT,                    -- 1 to 10
    IntegrityAssessment NVARCHAR(MAX),
    OverallGrade        INT,
    Remarks             NVARCHAR(MAX),
    DocumentPath        NVARCHAR(500),
    SubmittedAt         DATETIME
)
```

---

### Table 8: `ReviewingAssessment` (Section IV)
```sql
CREATE TABLE ReviewingAssessment (
    ReviewId    INT PRIMARY KEY IDENTITY,
    ProfileId   INT FOREIGN KEY REFERENCES OfficerProfiles(ProfileId),
    AgreeWithRA BIT,
    FinalGrade  INT,
    Remarks     NVARCHAR(MAX),
    SubmittedAt DATETIME
)
```

---

### Table 9: `AcceptingDecision` (Section V)
```sql
CREATE TABLE AcceptingDecision (
    DecisionId       INT PRIMARY KEY IDENTITY,
    ProfileId        INT FOREIGN KEY REFERENCES OfficerProfiles(ProfileId),
    FinalRemarks     NVARCHAR(MAX),
    ConflictResolved BIT DEFAULT 0,
    FinalGrade       INT,
    IsApproved       BIT,
    DecisionAt       DATETIME
)
```

---

### Table 10: `AuditLog`
```sql
CREATE TABLE AuditLog (
    LogId        INT PRIMARY KEY IDENTITY,
    EmployeeCode NVARCHAR(50) FOREIGN KEY REFERENCES Users(EmployeeCode),
    Action       NVARCHAR(500),
    TableName    NVARCHAR(100),
    RecordId     INT,
    LoggedAt     DATETIME DEFAULT GETDATE()
)
```

---

## How Tables Relate — The Full Picture

```
Users
  │
  ├──< Postings (one employee can have many postings)
  │         │
  │         └──< OfficerProfiles (one ACR per posting)
  │                     │
  │                     ├──< SelfAppraisal       (Section II)
  │                     ├──< ReportingAssessment (Section III)
  │                     ├──< ReviewingAssessment (Section IV)
  │                     └──< AcceptingDecision   (Section V)
  │
  ├──< OTPLog
  ├──< AuthTokens
  └──< AuditLog
```

---

## How to Get All Data for One Complete ACR — The Big JOIN Query

```sql
SELECT
    -- Posting info
    p.PostingId,
    p.Department,
    p.Location,
    p.Designation,
    p.PostingFrom,
    p.PostingTo,
    p.ACRYear,

    -- ACR metadata
    op.ProfileId,
    op.Status,
    op.DateOfBirth,
    op.Qualification,
    op.PostingHistory,
    op.PropertyReturnDone,
    op.MedicalRecordPath,
    op.CreatedAt           AS ACRCreatedAt,

    -- The Officer being evaluated
    op.OfficerCode,
    u_off.FullName         AS OfficerName,
    u_off.Email            AS OfficerEmail,

    -- Reporting Authority
    op.ReportingAuthCode,
    u_ra.FullName          AS ReportingAuthName,

    -- Reviewing Authority
    op.ReviewingAuthCode,
    u_rva.FullName         AS ReviewingAuthName,

    -- Accepting Authority
    op.AcceptingAuthCode,
    u_aa.FullName          AS AcceptingAuthName,

    -- Section II: Self Appraisal
    sa.DutiesPerformed,
    sa.Achievements,
    sa.MajorContributions,
    sa.TrainingsUndergone,
    sa.AwardsReceived,
    sa.LeaveDetails,
    sa.PropertyDeclared,
    sa.MedicalCompliance,
    sa.SubmittedAt         AS SelfAppraisalDate,

    -- Section III: Reporting Assessment
    ra.WorkOutputGrade,
    ra.PersonalAttrGrade,
    ra.FunctionalCompGrade,
    ra.IntegrityAssessment,
    ra.OverallGrade        AS RAOverallGrade,
    ra.Remarks             AS RARemarks,
    ra.SubmittedAt         AS RASubmittedAt,

    -- Section IV: Reviewing Assessment
    rv.AgreeWithRA,
    rv.FinalGrade          AS RvAFinalGrade,
    rv.Remarks             AS RvARemarks,
    rv.SubmittedAt         AS RvASubmittedAt,

    -- Section V: Final Decision
    ad.FinalRemarks,
    ad.FinalGrade,
    ad.IsApproved,
    ad.DecisionAt

FROM OfficerProfiles op

-- Get the posting details this ACR is for
INNER JOIN Postings p       ON op.PostingId         = p.PostingId

-- Join Users 4 times, one alias per role
INNER JOIN Users u_off  ON op.OfficerCode       = u_off.EmployeeCode
INNER JOIN Users u_ra   ON op.ReportingAuthCode  = u_ra.EmployeeCode
INNER JOIN Users u_rva  ON op.ReviewingAuthCode  = u_rva.EmployeeCode
INNER JOIN Users u_aa   ON op.AcceptingAuthCode  = u_aa.EmployeeCode

-- LEFT JOIN for sections — they may not exist yet if ACR is in progress
LEFT JOIN SelfAppraisal       sa ON op.ProfileId = sa.ProfileId
LEFT JOIN ReportingAssessment ra ON op.ProfileId = ra.ProfileId
LEFT JOIN ReviewingAssessment rv ON op.ProfileId = rv.ProfileId
LEFT JOIN AcceptingDecision   ad ON op.ProfileId = ad.ProfileId

WHERE op.ProfileId = @ProfileId
```

---

## Dashboard Queries — How Each Person Sees Their Queue

When an Employee logs in, 4 queries run on their EmployeeCode. Results are grouped by ACRYear on the dashboard so the person sees a clear year-wise list of all their tasks.

```sql
-- 1. Their OWN pending ACRs (as Officer) — grouped by year, one card per posting
SELECT
    op.ProfileId,
    p.ACRYear,
    p.Department,
    p.Location,
    p.PostingFrom,
    p.PostingTo,
    op.Status,
    'YourACR' AS TaskType,
    '' AS OfficerName
FROM OfficerProfiles op
INNER JOIN Postings p ON op.PostingId = p.PostingId
WHERE op.OfficerCode = @EmployeeCode
  AND op.Status = 'PendingOfficer'

-- 2. Subordinates waiting for their assessment (as Reporting Authority)
SELECT
    op.ProfileId,
    p.ACRYear,
    p.Department,
    p.Location,
    p.PostingFrom,
    p.PostingTo,
    op.Status,
    'AssessNow' AS TaskType,
    u.FullName AS OfficerName
FROM OfficerProfiles op
INNER JOIN Postings p ON op.PostingId = p.PostingId
INNER JOIN Users u    ON op.OfficerCode = u.EmployeeCode
WHERE op.ReportingAuthCode = @EmployeeCode
  AND op.Status = 'PendingReporting'

-- 3. Assessments waiting for their review (as Reviewing Authority)
SELECT
    op.ProfileId,
    p.ACRYear,
    p.Department,
    p.Location,
    p.PostingFrom,
    p.PostingTo,
    op.Status,
    'ReviewNow' AS TaskType,
    u.FullName AS OfficerName
FROM OfficerProfiles op
INNER JOIN Postings p ON op.PostingId = p.PostingId
INNER JOIN Users u    ON op.OfficerCode = u.EmployeeCode
WHERE op.ReviewingAuthCode = @EmployeeCode
  AND op.Status = 'PendingReviewing'

-- 4. Waiting for their final decision (as Accepting Authority)
SELECT
    op.ProfileId,
    p.ACRYear,
    p.Department,
    p.Location,
    p.PostingFrom,
    p.PostingTo,
    op.Status,
    'DecideNow' AS TaskType,
    u.FullName AS OfficerName
FROM OfficerProfiles op
INNER JOIN Postings p ON op.PostingId = p.PostingId
INNER JOIN Users u    ON op.OfficerCode = u.EmployeeCode
WHERE op.AcceptingAuthCode = @EmployeeCode
  AND op.Status = 'PendingAccepting'
```

### What the dashboard looks like for Ramesh (EMP001) with 2 postings in 2024:

```
ACR Year 2024
─────────────────────────────────────────────────────────
YOUR ACRs (as Officer)
  ► Hisar Division  |  01-Apr-2024 to 30-Sep-2024  |  [Fill Self-Appraisal]
  ► Sirsa Division  |  01-Oct-2024 to 31-Mar-2025  |  Waiting for CCA to complete setup

AS REPORTING AUTHORITY (Subordinates to assess)
  ► Kumar Singh  |  Rohtak Division  |  2024  |  [Assess Now]

AS REVIEWING AUTHORITY
  (nothing pending)
─────────────────────────────────────────────────────────
```

---

## CCA Workflow — Creating an ACR for a Posting

When CCA creates a new ACR, the form collects two things in sequence:

**Step 1 — Posting Details (creates a row in `Postings`):**
- Select Employee (dropdown of all active Employees)
- Department / Division
- Location
- Designation during this posting
- Posting From date
- Posting To date
- ACR Year (auto-suggested based on dates)

**Step 2 — ACR Setup (creates a row in `OfficerProfiles`):**
- Date of Birth
- Qualification
- Posting History (career summary text)
- Medical record upload
- Property return compliance (checkbox)
- Select Reporting Authority (dropdown of Employees — should be manager during THAT posting period)
- Select Reviewing Authority
- Select Accepting Authority

On submit → insert `Postings` row → insert `OfficerProfiles` row → Status = `'PendingOfficer'` → Officer's dashboard updates immediately.

---

## Status Flow in `OfficerProfiles.Status`

```
CCA creates the ACR for a specific posting
      ↓
"PendingOfficer"    →  Officer submits SelfAppraisal    →  becomes "PendingReporting"
      ↓
"PendingReporting"  →  RA submits Assessment            →  becomes "PendingReviewing"
      ↓
"PendingReviewing"  →  RvA submits Review               →  becomes "PendingAccepting"
      ↓
"PendingAccepting"  →  AA approves or rejects           →  becomes "Approved" or "Rejected"
```

Each posting-ACR moves through this independently. Ramesh's Hisar ACR can be at "PendingReviewing" while his Sirsa ACR is still at "PendingOfficer".

---

## Security Guard — Verify Identity Before Every Form Action

```csharp
// Example: ACRController.cs → SubmitReporting()
string loggedInCode = Session["EmployeeCode"].ToString();
var profile = db.QuerySingleOrDefault(
    "SELECT op.*, p.Department, p.PostingFrom, p.PostingTo " +
    "FROM OfficerProfiles op " +
    "INNER JOIN Postings p ON op.PostingId = p.PostingId " +
    "WHERE op.ProfileId = @id", new { id = profileId });

if (profile == null)
    return HttpNotFound();

if (profile.ReportingAuthCode != loggedInCode)
    return new HttpStatusCodeResult(403, "Forbidden");

if (profile.Status != "PendingReporting")
    return RedirectToAction("Dashboard", new { error = "This step is not active yet" });

// Safe — save and advance status
```

---

## Project Structure in Visual Studio 2019

```
ACRPortal (ASP.NET MVC Project)
│
├── Controllers/
│   ├── AuthController.cs          ← Login, OTP verify, Logout
│   ├── AdminController.cs         ← Create/manage user accounts
│   ├── CCAController.cs           ← Create Postings + ACR cycles
│   ├── DashboardController.cs     ← Unified Employee dashboard (4 queries)
│   └── ACRController.cs           ← Sections II, III, IV, V + ViewACR
│
├── Models/
│   ├── User.cs
│   ├── Posting.cs                 ← NEW
│   ├── OfficerProfile.cs
│   ├── SelfAppraisal.cs
│   ├── ReportingAssessment.cs
│   ├── ReviewingAssessment.cs
│   ├── AcceptingDecision.cs
│   └── ACRFullViewModel.cs        ← Maps the big JOIN query for display/PDF
│
├── Services/
│   ├── AuthService.cs
│   ├── OTPService.cs
│   └── FileUploadService.cs
│
├── Filters/
│   └── JwtAuthFilter.cs
│
├── Views/
│   ├── Auth/
│   │   ├── Login.cshtml
│   │   └── VerifyOTP.cshtml
│   ├── Admin/
│   │   └── Dashboard.cshtml
│   ├── CCA/
│   │   └── CreateACR.cshtml       ← Two-step form: Posting details + ACR setup
│   └── ACR/
│       ├── Dashboard.cshtml       ← Grouped by year, one card per posting
│       ├── SelfAppraisal.cshtml   ← Shows posting period/dept at top for context
│       ├── Reporting.cshtml
│       ├── Reviewing.cshtml
│       ├── Accepting.cshtml
│       └── ViewACR.cshtml         ← Full ACR including posting details
│
└── Web.config
```

---

## How Each Technology Is Used

| Technology | Used For |
|---|---|
| **ASP.NET MVC (.NET Framework 4.7.2)** | All pages, controllers, routing |
| **C#** | Business logic, token handling, OTP generation |
| **SQL Server (SSMS)** | All data storage |
| **Dapper (NuGet)** | Clean SQL queries with parameter mapping |
| **JWT** | Single 24-hr auth token |
| **HTML5 + Bootstrap 4 + JS** | Frontend forms and dashboards |
| **SMTP (System.Net.Mail)** | Send OTP via email |
| **BCrypt.Net (NuGet)** | Hash passwords before storing |
| **iTextSharp (NuGet)** | Export completed ACR as PDF |

---

## NuGet Packages to Install

```
Install-Package System.IdentityModel.Tokens.Jwt
Install-Package Microsoft.IdentityModel.Tokens
Install-Package BCrypt.Net-Next
Install-Package Dapper
Install-Package iTextSharp
```

---

## Quick Build Order

1. Create SQL DB in SSMS → run all CREATE TABLE scripts
2. Set up MVC project in VS 2019 → connection string in Web.config
3. Build Auth (Login → OTP → JWT) — test completely before moving on
4. Build Admin panel → create test accounts (1 Admin, 1 CCA, 5 Employees)
5. Build CCA → two-step CreateACR form (Postings insert + OfficerProfiles insert)
6. Build unified Employee Dashboard (4 queries, grouped by year, one card per posting)
7. Build Section II (Self-Appraisal) — show posting dept/period at top of form
8. Build Section III (Reporting Assessment)
9. Build Section IV (Reviewing)
10. Build Section V (Final Decision)
11. Build ViewACR page using the big JOIN query (includes Postings data)
12. Add PDF export using iTextSharp
