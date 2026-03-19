USE [ACRPortal]
GO

-- =============================================================================
-- Migration 8: Remove PENDING_REPORTING2 from acr_cycles status constraint
-- Purpose:
--   RA1 and RA2 now fill their assessment concurrently under a single
--   PENDING_REPORTING status. The workflow advances to PENDING_REVIEWING
--   only when BOTH have submitted. PENDING_REPORTING2 is no longer used.
-- =============================================================================

-- Update any rows currently stuck in PENDING_REPORTING2 back to PENDING_REPORTING
-- (safety net — should be zero rows on a fresh install)
UPDATE dbo.acr_cycles
SET    status     = 'PENDING_REPORTING',
       updated_at = GETDATE()
WHERE  status = 'PENDING_REPORTING2';
GO

-- Drop and recreate the CHECK constraint without PENDING_REPORTING2
IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE  name = 'CK_acr_status'
      AND  parent_object_id = OBJECT_ID('dbo.acr_cycles')
)
    ALTER TABLE dbo.acr_cycles DROP CONSTRAINT CK_acr_status;
GO

ALTER TABLE dbo.acr_cycles ADD CONSTRAINT CK_acr_status CHECK (status IN (
    'DRAFT',
    'PENDING_OFFICER',
    'PENDING_REPORTING',
    'PENDING_REVIEWING',
    'PENDING_ACCEPTING',
    'APPROVED',
    'REJECTED'
));
GO

PRINT 'Migration 8 complete: PENDING_REPORTING2 removed from acr_cycles status constraint.';
GO
