USE [ACRPortal]
GO

-- =============================================================================
-- Migration 9: Multi-document upload architecture
--
-- Replaces the single document_path / document_url column pattern spread
-- across self_appraisals, reporting_assessments, reviewing_assessments, and
-- accepting_decisions with a single normalised dbo.acr_documents table.
--
-- Also adds medical_report support for the CCA section (acr_cycles).
--
-- The frontend uploads files directly to storage and sends back a URL.
-- The backend stores that URL here — no file bytes are handled server-side.
--
-- Section values:
--   CCA      — medical report attached by CCA in Section I
--   OFFICER  — supporting documents attached by Officer in Section II
--   RA1      — documents attached by Reporting Authority 1 in Section III
--   RA2      — documents attached by Reporting Authority 2 in Section III (A1b only)
--   RVA      — documents attached by Reviewing Authority in Section IV
--   AA       — documents attached by Accepting Authority in Section V
--
-- Safe to re-run: all DROP COLUMN steps are guarded with IF EXISTS.
-- =============================================================================

PRINT '=== Migration 9 started ===';
GO

-- =============================================================================
-- STEP 1: Create dbo.acr_documents
-- =============================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE  object_id = OBJECT_ID('dbo.acr_documents')
)
BEGIN
    CREATE TABLE [dbo].[acr_documents] (
        [document_id]   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [acr_id]        UNIQUEIDENTIFIER NOT NULL,
        [section]       VARCHAR(10)      NOT NULL,   -- CCA | OFFICER | RA1 | RA2 | RVA | AA
        [document_type] VARCHAR(100)     NULL,        -- e.g. MEDICAL_REPORT | TRAINING_CERT | AWARD_LETTER | SUPPORTING_DOC
        [file_url]      NVARCHAR(2000)   NOT NULL,
        [file_name]     NVARCHAR(500)    NULL,        -- original filename for display
        [uploaded_at]   DATETIME         NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_acr_documents         PRIMARY KEY (document_id),
        CONSTRAINT FK_acr_documents_acr     FOREIGN KEY (acr_id)
            REFERENCES dbo.acr_cycles(acr_id) ON DELETE CASCADE,
        CONSTRAINT CK_acr_documents_section CHECK (section IN ('CCA','OFFICER','RA1','RA2','RVA','AA'))
    );

    -- Index for the most common lookup: all documents for a given ACR + section
    CREATE NONCLUSTERED INDEX idx_acr_documents_acr_section
        ON dbo.acr_documents (acr_id, section);

    PRINT 'Created dbo.acr_documents';
END
ELSE
    PRINT 'dbo.acr_documents already exists — skipped';
GO

-- =============================================================================
-- STEP 2: Drop old single document_path columns
--
-- Each table had a single document_path VARCHAR(500) from Migration 1.
-- These are replaced by dbo.acr_documents rows.
-- All guards check IF EXISTS so re-running is safe.
-- =============================================================================

-- 2a. self_appraisals.document_path
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'document_path'
)
BEGIN
    ALTER TABLE dbo.self_appraisals DROP COLUMN document_path;
    PRINT 'Dropped self_appraisals.document_path';
END
GO

-- 2b. reporting_assessments.document_path
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'document_path'
)
BEGIN
    ALTER TABLE dbo.reporting_assessments DROP COLUMN document_path;
    PRINT 'Dropped reporting_assessments.document_path';
END
GO

-- 2c. reviewing_assessments.document_path
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.reviewing_assessments') AND name = 'document_path'
)
BEGIN
    ALTER TABLE dbo.reviewing_assessments DROP COLUMN document_path;
    PRINT 'Dropped reviewing_assessments.document_path';
END
GO

-- 2d. accepting_decisions.document_path
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.accepting_decisions') AND name = 'document_path'
)
BEGIN
    ALTER TABLE dbo.accepting_decisions DROP COLUMN document_path;
    PRINT 'Dropped accepting_decisions.document_path';
END
GO

PRINT '=== Migration 9 complete ===';
GO