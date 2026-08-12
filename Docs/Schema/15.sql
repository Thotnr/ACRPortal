USE [ACRPortal]
GO

-- =============================================================================
-- Migration 15: Account lockout after repeated failed login attempts
--
-- Adds dbo.users.failed_login_count — incremented on a wrong password or a
-- wrong login OTP, reset to 0 on a fully successful login (password + OTP).
-- Once it reaches the threshold enforced in AuthService (5), LoginStep1
-- blocks the account entirely until an admin resets the counter via
-- POST api/admin/users/{userId}/unlock.
--
-- Safe to re-run: the ALTER is guarded with IF NOT EXISTS.
-- =============================================================================

PRINT '=== Migration 15 started ===';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.users')
      AND  name      = 'failed_login_count'
)
BEGIN
    ALTER TABLE dbo.users ADD [failed_login_count] INT NOT NULL DEFAULT 0;
    PRINT 'Added users.failed_login_count';
END
ELSE
    PRINT 'users.failed_login_count already exists — skipped';
GO

PRINT '=== Migration 15 complete ===';
GO
