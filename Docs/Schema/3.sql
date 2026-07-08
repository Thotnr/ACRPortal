-- =============================================================================
-- Migration 3: Add manager_id to dbo.users
-- Run against an existing ACRPortal database.
-- =============================================================================

USE [ACRPortal]
GO

-- -----------------------------------------------------------------------------
-- STEP 1: Add manager_id column (stores the manager's login_id)
-- VARCHAR(50) to match dbo.users.login_id
-- -----------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.users') AND name = 'manager_id'
)
BEGIN
    ALTER TABLE dbo.users ADD [manager_id] VARCHAR(50) NULL;
END
GO

-- -----------------------------------------------------------------------------
-- STEP 2: Add FK referencing users.login_id — no cascade (deliberate)
-- Deactivating or deleting a manager must not cascade to their reports.
-- Requires login_id to have a UNIQUE constraint (UQ_users_login_id already exists).
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_users_manager')
    ALTER TABLE dbo.users ADD CONSTRAINT FK_users_manager
        FOREIGN KEY (manager_id) REFERENCES dbo.users(login_id);
GO

PRINT 'Migration 3 complete: manager_id (VARCHAR login_id) added to dbo.users.';
GO