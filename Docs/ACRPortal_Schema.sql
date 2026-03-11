-- =============================================================================
-- ACRPortal — Complete Database Schema
-- Run this on a fresh / empty ACRPortal database.
-- Compatible with SQL Server 2012+ (Express or full edition).
-- =============================================================================

USE [ACRPortal]
GO

-- =============================================================================
-- SECTION 1: CORE USER TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- users
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[users] (
    [user_id]            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [display_name]       VARCHAR(150)     NULL,
    [user_status]        VARCHAR(30)      NOT NULL DEFAULT 'PENDING',
    [system_role]        VARCHAR(30)      NOT NULL DEFAULT 'EMPLOYEE',
    [login_id]           VARCHAR(50)      NOT NULL,
    [password_hash]      VARCHAR(MAX)     NOT NULL,
    [password_salt]      VARCHAR(MAX)     NULL,
    [dsg_id]             INT              NULL,         -- FK → tbDsg.dsgId (added after tbDsg)
    [reset_token]        VARCHAR(255)     NULL,
    [reset_token_expiry] DATETIME         NULL,
    [created_at]         DATETIME         NOT NULL DEFAULT GETDATE(),
    [updated_at]         DATETIME         NOT NULL DEFAULT GETDATE(),
    [invited_by_user_id] UNIQUEIDENTIFIER NULL,
    [first_activated_at] DATETIME         NULL,
    [last_login_at]      DATETIME         NULL,

    CONSTRAINT PK_users          PRIMARY KEY (user_id),
    CONSTRAINT UQ_users_login_id UNIQUE      (login_id),
    CONSTRAINT CK_users_role     CHECK (system_role IN ('ADMIN', 'CCA', 'EMPLOYEE')),
    CONSTRAINT CK_users_status   CHECK (user_status IN ('PENDING', 'ACTIVE', 'INACTIVE'))
);
GO

-- self-referencing FK for invited_by — added after table exists
ALTER TABLE [dbo].[users]
    ADD CONSTRAINT FK_users_invited_by
    FOREIGN KEY (invited_by_user_id) REFERENCES [dbo].[users](user_id);
GO

-- -----------------------------------------------------------------------------
-- user_identities  (email / phone contact records per user)
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[user_identities] (
    [identity_id]    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [user_id]        UNIQUEIDENTIFIER NOT NULL,
    [identity_type]  VARCHAR(20)      NOT NULL,   -- 'EMAIL' | 'PHONE'
    [identity_value] VARCHAR(255)     NOT NULL,
    [is_primary]     BIT              NOT NULL DEFAULT 0,
    [is_verified]    BIT              NOT NULL DEFAULT 0,
    [verified_at]    DATETIME         NULL,
    [created_at]     DATETIME         NOT NULL DEFAULT GETDATE(),
    [updated_at]     DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_user_identities PRIMARY KEY (identity_id),
    CONSTRAINT UQ_Identity        UNIQUE      (identity_type, identity_value),
    CONSTRAINT FK_identity_user   FOREIGN KEY (user_id) REFERENCES [dbo].[users](user_id) ON DELETE CASCADE
);
GO

-- -----------------------------------------------------------------------------
-- devices
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[devices] (
    [device_id]          UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [user_id]            UNIQUEIDENTIFIER NOT NULL,
    [device_fingerprint] VARCHAR(255)     NOT NULL,
    [platform]           VARCHAR(30)      NULL,
    [device_name]        VARCHAR(100)     NULL,
    [created_at]         DATETIME         NOT NULL DEFAULT GETDATE(),
    [last_seen_at]       DATETIME         NULL,

    CONSTRAINT PK_devices   PRIMARY KEY (device_id),
    CONSTRAINT UQ_UserDevice UNIQUE      (user_id, device_fingerprint),
    CONSTRAINT FK_device_user FOREIGN KEY (user_id) REFERENCES [dbo].[users](user_id) ON DELETE CASCADE
);
GO

-- -----------------------------------------------------------------------------
-- sessions
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[sessions] (
    [session_id]         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [user_id]            UNIQUEIDENTIFIER NOT NULL,
    [device_id]          UNIQUEIDENTIFIER NULL,
    [session_token_hash] VARCHAR(MAX)     NULL,
    [issued_at]          DATETIME         NOT NULL DEFAULT GETDATE(),
    [expires_at]         DATETIME         NOT NULL,
    [revoked_at]         DATETIME         NULL,
    [last_activity_at]   DATETIME         NULL,
    [ip_address]         VARCHAR(45)      NULL,
    [user_agent]         NVARCHAR(MAX)    NULL,
    [status]             VARCHAR(20)      NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT PK_sessions        PRIMARY KEY (session_id),
    CONSTRAINT FK_session_user    FOREIGN KEY (user_id)    REFERENCES [dbo].[users](user_id)   ON DELETE CASCADE,
    CONSTRAINT FK_session_device  FOREIGN KEY (device_id)  REFERENCES [dbo].[devices](device_id)
);
GO

-- -----------------------------------------------------------------------------
-- otp_challenges
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[otp_challenges] (
    [otp_id]         UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [identity_type]  VARCHAR(20)      NOT NULL,
    [identity_value] VARCHAR(255)     NOT NULL,
    [purpose]        VARCHAR(30)      NOT NULL,
    [otp_hash]       VARCHAR(255)     NOT NULL,
    [expires_at]     DATETIME         NOT NULL,
    [status]         VARCHAR(20)      NOT NULL DEFAULT 'ISSUED',
    [attempts]       INT              NOT NULL DEFAULT 0,
    [max_attempts]   INT              NOT NULL DEFAULT 5,
    [ip_address]     VARCHAR(45)      NULL,
    [user_agent]     NVARCHAR(MAX)    NULL,
    [created_at]     DATETIME         NOT NULL DEFAULT GETDATE(),
    [verified_at]    DATETIME         NULL,

    CONSTRAINT PK_otp_challenges PRIMARY KEY (otp_id)
);
GO

CREATE NONCLUSTERED INDEX [idx_otp_lookup]
    ON [dbo].[otp_challenges] (identity_type, identity_value, purpose, status);
GO

CREATE NONCLUSTERED INDEX [idx_sessions_user_active]
    ON [dbo].[sessions] (user_id, status, expires_at);
GO

-- =============================================================================
-- SECTION 2: MASTER / LOOKUP TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tbDsg — Designation master
-- dsgId is IDENTITY starting at 1001.
-- dsg (short code) must be unique. Name uniqueness = UQ_tbDsg_code.
-- dsgIsActive is BIT (1 = active, 0 = inactive).
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[tbDsg] (
    [dsgId]       INT         NOT NULL IDENTITY(1001,1),
    [dsg]         VARCHAR(20) NOT NULL,
    [dsgDesc]     VARCHAR(50) NULL,
    [dsgLevel]    INT         NOT NULL,
    [dsgIsActive] BIT         NOT NULL DEFAULT 1,
    [created_at]  DATETIME    NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_tbDsg      PRIMARY KEY (dsgId),
    CONSTRAINT UQ_tbDsg_code UNIQUE      (dsg)
);
GO

-- Now that tbDsg exists, wire the FK from users.dsg_id
ALTER TABLE [dbo].[users]
    ADD CONSTRAINT FK_users_tbDsg
    FOREIGN KEY (dsg_id) REFERENCES [dbo].[tbDsg](dsgId);
GO

-- -----------------------------------------------------------------------------
-- State
-- SNID   = IDENTITY PK (internal, never exposed in APIs)
-- State_ID = caller-assigned business key (unique)
-- State    = name (unique)
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[State] (
    [SNID]       INT          NOT NULL IDENTITY(1,1),
    [Country_ID] INT          NOT NULL DEFAULT 1,
    [State_ID]   INT          NOT NULL,
    [State]      VARCHAR(200) NOT NULL,
    [created_at] DATETIME     NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_State      PRIMARY KEY (SNID),
    CONSTRAINT UQ_State_ID   UNIQUE      (State_ID),
    CONSTRAINT UQ_State_Name UNIQUE      (State)
);
GO

-- -----------------------------------------------------------------------------
-- Zone
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[Zone] (
    [ZID]        INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]    INT           NOT NULL,
    [Zone]       NVARCHAR(255) NOT NULL,
    [created_at] DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Zone      PRIMARY KEY (ZID),
    CONSTRAINT UQ_Zone_ID   UNIQUE      (Zone_ID),
    CONSTRAINT UQ_Zone_Name UNIQUE      (Zone)
);
GO

-- -----------------------------------------------------------------------------
-- Circle — child of Zone
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[Circle] (
    [CID]        INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]    INT           NOT NULL,
    [Circle_ID]  INT           NOT NULL,
    [Circle]     NVARCHAR(255) NOT NULL,
    [created_at] DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Circle        PRIMARY KEY (CID),
    CONSTRAINT UQ_Circle_ID     UNIQUE      (Circle_ID),
    CONSTRAINT UQ_Circle_Name   UNIQUE      (Circle),
    CONSTRAINT FK_Circle_Zone   FOREIGN KEY (Zone_ID) REFERENCES [dbo].[Zone](Zone_ID)
);
GO

-- -----------------------------------------------------------------------------
-- Division — child of Circle
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[Division] (
    [DID]         INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]     INT           NOT NULL,
    [Circle_ID]   INT           NOT NULL,
    [Division_ID] INT           NOT NULL,
    [Division]    NVARCHAR(255) NOT NULL,
    [created_at]  DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_Division        PRIMARY KEY (DID),
    CONSTRAINT UQ_Division_ID     UNIQUE      (Division_ID),
    CONSTRAINT UQ_Division_Name   UNIQUE      (Division),
    CONSTRAINT FK_Division_Zone   FOREIGN KEY (Zone_ID)   REFERENCES [dbo].[Zone](Zone_ID),
    CONSTRAINT FK_Division_Circle FOREIGN KEY (Circle_ID) REFERENCES [dbo].[Circle](Circle_ID)
);
GO

-- -----------------------------------------------------------------------------
-- SubDivision — child of Division
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[SubDivision] (
    [SID]           INT           NOT NULL IDENTITY(1,1),
    [Zone_ID]       INT           NOT NULL,
    [Circle_ID]     INT           NOT NULL,
    [Division_ID]   INT           NOT NULL,
    [SubDivisionID] INT           NOT NULL,
    [SubDivision]   NVARCHAR(255) NOT NULL,
    [created_at]    DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_SubDivision       PRIMARY KEY (SID),
    CONSTRAINT UQ_SubDivision_ID    UNIQUE      (SubDivisionID),
    CONSTRAINT UQ_SubDivision_Name  UNIQUE      (SubDivision),
    CONSTRAINT FK_SubDiv_Zone       FOREIGN KEY (Zone_ID)     REFERENCES [dbo].[Zone](Zone_ID),
    CONSTRAINT FK_SubDiv_Circle     FOREIGN KEY (Circle_ID)   REFERENCES [dbo].[Circle](Circle_ID),
    CONSTRAINT FK_SubDiv_Division   FOREIGN KEY (Division_ID) REFERENCES [dbo].[Division](Division_ID)
);
GO

-- =============================================================================
-- SECTION 3: ACR WORKFLOW TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- postings — one row per officer per deployment period
-- UQ_posting_unique ensures one ACR per officer per department per start date
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[postings] (
    [posting_id]      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [officer_user_id] UNIQUEIDENTIFIER NOT NULL,
    [department]      NVARCHAR(200)    NOT NULL,
    [location]        NVARCHAR(200)    NOT NULL,
    [designation]     NVARCHAR(200)    NOT NULL,
    [posting_from]    DATE             NOT NULL,
    [posting_to]      DATE             NOT NULL,
    [acr_year]        INT              NOT NULL,
    [created_at]      DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_postings       PRIMARY KEY (posting_id),
    CONSTRAINT FK_postings_user  FOREIGN KEY (officer_user_id) REFERENCES [dbo].[users](user_id) ON DELETE CASCADE,
    CONSTRAINT UQ_posting_unique UNIQUE      (officer_user_id, department, posting_from)
);
GO

-- -----------------------------------------------------------------------------
-- acr_cycles — one ACR cycle per posting
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[acr_cycles] (
    [acr_id]                  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [posting_id]              UNIQUEIDENTIFIER NOT NULL,
    [officer_user_id]         UNIQUEIDENTIFIER NOT NULL,
    [reporting_user_id]       UNIQUEIDENTIFIER NOT NULL,
    [reviewing_user_id]       UNIQUEIDENTIFIER NOT NULL,
    [accepting_user_id]       UNIQUEIDENTIFIER NOT NULL,
    [cca_user_id]             UNIQUEIDENTIFIER NOT NULL,
    [date_of_birth]           DATE             NULL,
    [qualification]           NVARCHAR(500)    NULL,
    [career_posting_summary]  NVARCHAR(MAX)    NULL,
    [medical_record_path]     NVARCHAR(500)    NULL,
    [property_return_done]    BIT              NOT NULL DEFAULT 0,
    [status]                  VARCHAR(30)      NOT NULL DEFAULT 'PENDING_OFFICER',
    [created_at]              DATETIME         NOT NULL DEFAULT GETDATE(),
    [updated_at]              DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_acr_cycles      PRIMARY KEY (acr_id),
    CONSTRAINT UQ_acr_per_posting UNIQUE      (posting_id),
    CONSTRAINT FK_acr_posting     FOREIGN KEY (posting_id)        REFERENCES [dbo].[postings](posting_id) ON DELETE CASCADE,
    CONSTRAINT FK_acr_officer     FOREIGN KEY (officer_user_id)   REFERENCES [dbo].[users](user_id),
    CONSTRAINT FK_acr_reporting   FOREIGN KEY (reporting_user_id) REFERENCES [dbo].[users](user_id),
    CONSTRAINT FK_acr_reviewing   FOREIGN KEY (reviewing_user_id) REFERENCES [dbo].[users](user_id),
    CONSTRAINT FK_acr_accepting   FOREIGN KEY (accepting_user_id) REFERENCES [dbo].[users](user_id),
    CONSTRAINT FK_acr_cca         FOREIGN KEY (cca_user_id)       REFERENCES [dbo].[users](user_id),
    CONSTRAINT CK_acr_status      CHECK (status IN (
        'PENDING_OFFICER', 'PENDING_REPORTING', 'PENDING_REVIEWING',
        'PENDING_ACCEPTING', 'APPROVED', 'REJECTED'
    ))
);
GO

-- -----------------------------------------------------------------------------
-- self_appraisals — Section I, filled by officer
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[self_appraisals] (
    [appraisal_id]        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [acr_id]              UNIQUEIDENTIFIER NOT NULL,
    [duties_performed]    NVARCHAR(MAX)    NULL,
    [achievements]        NVARCHAR(MAX)    NULL,
    [major_contributions] NVARCHAR(MAX)    NULL,
    [trainings_undergone] NVARCHAR(MAX)    NULL,
    [awards_received]     NVARCHAR(MAX)    NULL,
    [leave_details]       NVARCHAR(MAX)    NULL,
    [property_declared]   BIT              NOT NULL DEFAULT 0,
    [medical_compliance]  BIT              NOT NULL DEFAULT 0,
    [document_path]       NVARCHAR(500)    NULL,
    [submitted_at]        DATETIME         NULL,
    [created_at]          DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_self_appraisals     PRIMARY KEY (appraisal_id),
    CONSTRAINT UQ_self_one_per_acr    UNIQUE      (acr_id),
    CONSTRAINT FK_self_acr            FOREIGN KEY (acr_id) REFERENCES [dbo].[acr_cycles](acr_id) ON DELETE CASCADE
);
GO

-- -----------------------------------------------------------------------------
-- reporting_assessments — Section II/III, filled by Reporting Authority
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[reporting_assessments] (
    [assessment_id]        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [acr_id]               UNIQUEIDENTIFIER NOT NULL,
    [agree_with_self]      BIT              NULL,
    [work_output_grade]    INT              NOT NULL,
    [personal_attr_grade]  INT              NOT NULL,
    [functional_comp_grade] INT             NOT NULL,
    [integrity_comments]   NVARCHAR(MAX)    NULL,
    [overall_grade]        INT              NOT NULL,
    [remarks]              NVARCHAR(MAX)    NULL,
    [document_path]        NVARCHAR(500)    NULL,
    [submitted_at]         DATETIME         NULL,

    CONSTRAINT PK_reporting              PRIMARY KEY (assessment_id),
    CONSTRAINT UQ_reporting_one_per_acr  UNIQUE      (acr_id),
    CONSTRAINT FK_reporting_acr          FOREIGN KEY (acr_id) REFERENCES [dbo].[acr_cycles](acr_id) ON DELETE CASCADE,
    CONSTRAINT CK_reporting_grades       CHECK (
        work_output_grade    BETWEEN 1 AND 10 AND
        personal_attr_grade  BETWEEN 1 AND 10 AND
        functional_comp_grade BETWEEN 1 AND 10 AND
        overall_grade        BETWEEN 1 AND 10
    )
);
GO

-- -----------------------------------------------------------------------------
-- reviewing_assessments — Section IV, filled by Reviewing Authority
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[reviewing_assessments] (
    [review_id]       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [acr_id]          UNIQUEIDENTIFIER NOT NULL,
    [agree_with_ra]   BIT              NULL,
    [final_grade]     INT              NOT NULL,
    [remarks]         NVARCHAR(MAX)    NULL,
    [document_path]   NVARCHAR(500)    NULL,
    [submitted_at]    DATETIME         NULL,

    CONSTRAINT PK_reviewing             PRIMARY KEY (review_id),
    CONSTRAINT UQ_reviewing_one_per_acr UNIQUE      (acr_id),
    CONSTRAINT FK_reviewing_acr         FOREIGN KEY (acr_id) REFERENCES [dbo].[acr_cycles](acr_id) ON DELETE CASCADE,
    CONSTRAINT CK_reviewing_grade       CHECK (final_grade BETWEEN 1 AND 10)
);
GO

-- -----------------------------------------------------------------------------
-- accepting_decisions — Section V, filled by Accepting Authority
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[accepting_decisions] (
    [decision_id]        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [acr_id]             UNIQUEIDENTIFIER NOT NULL,
    [agree_with_previous] BIT             NULL,
    [conflict_resolved]  BIT              NOT NULL DEFAULT 0,
    [final_grade]        INT              NOT NULL,
    [final_remarks]      NVARCHAR(MAX)    NULL,
    [document_path]      NVARCHAR(500)    NULL,
    [is_approved]        BIT              NOT NULL,
    [decided_at]         DATETIME         NULL,

    CONSTRAINT PK_accepting             PRIMARY KEY (decision_id),
    CONSTRAINT UQ_accepting_one_per_acr UNIQUE      (acr_id),
    CONSTRAINT FK_accepting_acr         FOREIGN KEY (acr_id) REFERENCES [dbo].[acr_cycles](acr_id) ON DELETE CASCADE,
    CONSTRAINT CK_accepting_grade       CHECK (final_grade BETWEEN 1 AND 10)
);
GO

-- -----------------------------------------------------------------------------
-- audit_logs
-- -----------------------------------------------------------------------------
CREATE TABLE [dbo].[audit_logs] (
    [audit_id]   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [user_id]    UNIQUEIDENTIFIER NOT NULL,
    [acr_id]     UNIQUEIDENTIFIER NULL,
    [action]     NVARCHAR(500)    NOT NULL,
    [table_name] NVARCHAR(100)    NOT NULL,
    [record_id]  UNIQUEIDENTIFIER NULL,
    [ip_address] VARCHAR(45)      NULL,
    [user_agent] NVARCHAR(MAX)    NULL,
    [created_at] DATETIME         NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_audit      PRIMARY KEY (audit_id),
    CONSTRAINT FK_audit_user FOREIGN KEY (user_id) REFERENCES [dbo].[users](user_id)
);
GO

-- =============================================================================
-- DONE
-- Tables created (in dependency order):
--   users, user_identities, devices, sessions, otp_challenges
--   tbDsg
--   State, Zone, Circle, Division, SubDivision
--   postings, acr_cycles
--   self_appraisals, reporting_assessments, reviewing_assessments, accepting_decisions
--   audit_logs
-- =============================================================================
PRINT 'ACRPortal schema created successfully.';
GO
