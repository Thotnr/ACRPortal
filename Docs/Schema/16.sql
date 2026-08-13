USE [ACRPortal]
GO

-- =============================================================================
-- Migration 16: Allow duplicate phone/email across users
--
-- Drops UQ_Identity (UNIQUE on user_identities(identity_type, identity_value)).
-- Previously this blocked two different users from having the same phone
-- number or email registered. All login/OTP/password-reset lookups key off
-- users.login_id (never a reverse phone/email -> user lookup), so removing
-- this constraint does not affect the existing auth flow — users are still
-- told apart by login_id / display_name, not by phone or email.
--
-- Safe to re-run: guarded with IF EXISTS.
-- =============================================================================

PRINT '=== Migration 16 started ===';
GO

IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE  name             = 'UQ_Identity'
      AND  parent_object_id = OBJECT_ID('dbo.user_identities')
)
BEGIN
    ALTER TABLE dbo.user_identities DROP CONSTRAINT UQ_Identity;
    PRINT 'Dropped UQ_Identity — phone/email are no longer unique across users';
END
ELSE
    PRINT 'UQ_Identity already absent — skipped';
GO

PRINT '=== Migration 16 complete ===';
GO
