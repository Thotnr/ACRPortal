-- =============================================================================
-- Migration: User Master Data Fields
-- Run against an existing ACRPortal database.
-- Adds geography + designation columns to dbo.users,
-- and removes dbo.postings (folding its fields into dbo.acr_cycles).
-- =============================================================================

USE [ACRPortal]
GO

-- -----------------------------------------------------------------------------
-- STEP 1: Add master-data columns to dbo.users
-- (dsg_id already exists — only add if you are on a database that doesn't have it yet)
-- -----------------------------------------------------------------------------

-- Designation (already present on newer schema — guard with IF NOT EXISTS)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.users') AND name = 'dsg_id'
)
BEGIN
    ALTER TABLE dbo.users ADD [dsg_id] INT NULL;
END
GO

-- Geography columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'state_id')
    ALTER TABLE dbo.users ADD [state_id] INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'zone_id')
    ALTER TABLE dbo.users ADD [zone_id] INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'circle_id')
    ALTER TABLE dbo.users ADD [circle_id] INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'division_id')
    ALTER TABLE dbo.users ADD [division_id] INT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'sub_division_id')
    ALTER TABLE dbo.users ADD [sub_division_id] INT NULL;
GO

-- -----------------------------------------------------------------------------
-- STEP 2: Add FK constraints (only after the master tables already exist)
-- Each is guarded so re-running is safe.
-- -----------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_tbDsg')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_tbDsg
        FOREIGN KEY (dsg_id) REFERENCES dbo.tbDsg(dsgId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_state')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_state
        FOREIGN KEY (state_id) REFERENCES dbo.State(State_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_zone')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_zone
        FOREIGN KEY (zone_id) REFERENCES dbo.Zone(Zone_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_circle')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_circle
        FOREIGN KEY (circle_id) REFERENCES dbo.Circle(Circle_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_division')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_division
        FOREIGN KEY (division_id) REFERENCES dbo.Division(Division_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_subdivision')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_subdivision
        FOREIGN KEY (sub_division_id) REFERENCES dbo.SubDivision(SubDivisionID);
GO

-- -----------------------------------------------------------------------------
-- STEP 3: Fold postings into acr_cycles, drop postings table
-- Only run if postings table still exists.
-- -----------------------------------------------------------------------------

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'acr_cycles' AND schema_id = SCHEMA_ID('dbo'))
   AND EXISTS (SELECT 1 FROM sys.tables WHERE name = 'postings' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- 3a. Add posting columns directly onto acr_cycles
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'department')
        ALTER TABLE dbo.acr_cycles ADD [department]   NVARCHAR(200) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'location')
        ALTER TABLE dbo.acr_cycles ADD [location]     NVARCHAR(200) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'designation')
        ALTER TABLE dbo.acr_cycles ADD [designation]  NVARCHAR(200) NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'posting_from')
        ALTER TABLE dbo.acr_cycles ADD [posting_from] DATE NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'posting_to')
        ALTER TABLE dbo.acr_cycles ADD [posting_to]   DATE NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'acr_year')
        ALTER TABLE dbo.acr_cycles ADD [acr_year]     INT NULL;



    -- 3c. Now make the new columns NOT NULL (data is filled)
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [department]   NVARCHAR(200) NOT NULL;
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [location]     NVARCHAR(200) NOT NULL;
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [designation]  NVARCHAR(200) NOT NULL;
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [posting_from] DATE          NOT NULL;
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [posting_to]   DATE          NOT NULL;
    ALTER TABLE dbo.acr_cycles ALTER COLUMN [acr_year]     INT           NOT NULL;

    -- 3d. Drop old FK + unique constraint that reference posting_id
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_acr_posting')
        ALTER TABLE dbo.acr_cycles DROP CONSTRAINT FK_acr_posting;

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_acr_per_posting' AND object_id = OBJECT_ID('dbo.acr_cycles'))
        ALTER TABLE dbo.acr_cycles DROP CONSTRAINT UQ_acr_per_posting;

    -- 3e. Drop posting_id column
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'posting_id')
        ALTER TABLE dbo.acr_cycles DROP COLUMN posting_id;

    -- 3f. Add new uniqueness constraint directly on acr_cycles
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_acr_unique' AND object_id = OBJECT_ID('dbo.acr_cycles'))
        ALTER TABLE dbo.acr_cycles ADD CONSTRAINT UQ_acr_unique
            UNIQUE (officer_user_id, department, posting_from);

    -- 3g. Drop postings table (FK from acr_cycles already removed above)
    DROP TABLE dbo.postings;
END
GO

PRINT 'Migration_UserMasterData completed successfully.';
GO