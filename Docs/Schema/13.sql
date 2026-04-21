USE [ACRPortal]
GO

-- =============================================================================
-- Migration 13: Auto-Advance Schema Changes
--
-- Adds the columns needed to support the daily auto-advance job:
--
--   A) acr_cycles.submitted_at
--        Timestamp when CCA formally submitted the ACR (DRAFT → PENDING_OFFICER).
--        This is the clock-start for the Officer step.
--        Cannot use created_at because CCA may save as DRAFT first.
--
--   B) is_skipped BIT on each of the four section tables.
--        When the daily job auto-advances a step it inserts a placeholder row
--        with all content NULL and is_skipped = 1.
--        The UI reads this flag to display "Forwarded by system".
--
-- Safe to re-run: every ALTER is guarded with IF NOT EXISTS.
-- =============================================================================

PRINT '=== Migration 13 started ===';
GO

-- =============================================================================
-- A. acr_cycles.submitted_at
--    Set when status transitions DRAFT → PENDING_OFFICER.
--    For ACRs that skipped DRAFT (SaveAsDraft = false), the application layer
--    should set this equal to created_at at insert time.
-- =============================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.acr_cycles')
      AND  name      = 'submitted_at'
)
BEGIN
    ALTER TABLE dbo.acr_cycles ADD [submitted_at] DATETIME NULL;
    PRINT 'Added acr_cycles.submitted_at';
END
ELSE
    PRINT 'acr_cycles.submitted_at already exists — skipped';
GO

-- Back-fill: rows already in PENDING_OFFICER or beyond that were created
-- without a draft step can use created_at as a reasonable approximation.
-- Rows still in DRAFT are intentionally left NULL (not yet submitted).
UPDATE dbo.acr_cycles
SET    submitted_at = created_at
WHERE  submitted_at IS NULL
  AND  status <> 'DRAFT';
GO

PRINT 'Back-filled acr_cycles.submitted_at for non-DRAFT rows.';
GO

-- =============================================================================
-- B. is_skipped on each section table
-- =============================================================================

-- B1. self_appraisals
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.self_appraisals')
      AND  name      = 'is_skipped'
)
BEGIN
    ALTER TABLE dbo.self_appraisals ADD [is_skipped] BIT NOT NULL DEFAULT 0;
    PRINT 'Added self_appraisals.is_skipped';
END
ELSE
    PRINT 'self_appraisals.is_skipped already exists — skipped';
GO

-- B2. reporting_assessments
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.reporting_assessments')
      AND  name      = 'is_skipped'
)
BEGIN
    ALTER TABLE dbo.reporting_assessments ADD [is_skipped] BIT NOT NULL DEFAULT 0;
    PRINT 'Added reporting_assessments.is_skipped';
END
ELSE
    PRINT 'reporting_assessments.is_skipped already exists — skipped';
GO

-- B3. reviewing_assessments
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.reviewing_assessments')
      AND  name      = 'is_skipped'
)
BEGIN
    ALTER TABLE dbo.reviewing_assessments ADD [is_skipped] BIT NOT NULL DEFAULT 0;
    PRINT 'Added reviewing_assessments.is_skipped';
END
ELSE
    PRINT 'reviewing_assessments.is_skipped already exists — skipped';
GO

-- B4. accepting_decisions
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.accepting_decisions')
      AND  name      = 'is_skipped'
)
BEGIN
    ALTER TABLE dbo.accepting_decisions ADD [is_skipped] BIT NOT NULL DEFAULT 0;
    PRINT 'Added accepting_decisions.is_skipped';
END
ELSE
    PRINT 'accepting_decisions.is_skipped already exists — skipped';
GO

PRINT '=== Migration 13 complete ===';
GO