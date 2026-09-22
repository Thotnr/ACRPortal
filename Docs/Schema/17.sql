USE [ACRPortal]
GO

-- =============================================================================
-- Migration 17: Add decrypted_password and current_otp to users
--
-- decrypted_password — stores the plaintext password alongside password_hash,
-- written every time a password is set (signup, admin create user, change
-- password, reset password).
-- current_otp — stores the plaintext OTP for the last OTP issued to this user
-- (login or password-reset), cleared once that OTP is verified.
--
-- Safe to re-run: both ALTERs are guarded with IF NOT EXISTS.
-- =============================================================================

PRINT '=== Migration 17 started ===';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.users')
      AND  name      = 'decrypted_password'
)
BEGIN
    ALTER TABLE dbo.users ADD [decrypted_password] VARCHAR(MAX) NULL;
    PRINT 'Added users.decrypted_password';
END
ELSE
    PRINT 'users.decrypted_password already exists — skipped';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.users')
      AND  name      = 'current_otp'
)
BEGIN
    ALTER TABLE dbo.users ADD [current_otp] VARCHAR(20) NULL;
    PRINT 'Added users.current_otp';
END
ELSE
    PRINT 'users.current_otp already exists — skipped';
GO

PRINT '=== Migration 17 complete ===';
GO
