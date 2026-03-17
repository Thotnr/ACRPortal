USE [ACRPortal]
GO

-- =============================================================================
-- Migration 6: Add DRAFT status to dbo.acr_cycles
-- Purpose:
--   Allows CCA to save an ACR setup as draft before submitting it to the Officer step.
-- =============================================================================

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_acr_status'
      AND parent_object_id = OBJECT_ID('dbo.acr_cycles')
)
    ALTER TABLE dbo.acr_cycles DROP CONSTRAINT CK_acr_status;
GO

ALTER TABLE dbo.acr_cycles ADD CONSTRAINT CK_acr_status CHECK (status IN (
    'DRAFT',
    'PENDING_OFFICER',
    'PENDING_REPORTING',
    'PENDING_REPORTING2',
    'PENDING_REVIEWING',
    'PENDING_ACCEPTING',
    'APPROVED',
    'REJECTED'
));
GO

PRINT 'Migration 6 complete: DRAFT added to acr_cycles.status.';
GO

