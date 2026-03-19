USE [ACRPortal]
GO

-- =============================================================================
-- Migration 7: Complete APAR Form Field Coverage
-- Run after migrations 1-6.
--
-- What this migration does:
--   A) dbo.acr_cycles   — adds 5 missing Section I fields + splits qualification
--                          + changes property_return_done (BIT) to property_return_date (DATE)
--   B) dbo.self_appraisals — adds 2 missing date fields + fixes auditor_compliance type
--   C) dbo.reporting_assessments — adds disagree-details text for RA1 & RA2,
--                                   and confirms all RA2 narrative columns exist
--   D) dbo.reviewing_assessments — adds disagree_details + missing narrative columns
--   E) dbo.accepting_decisions   — adds disagree_details
--
-- Safe to re-run: every ALTER is guarded with IF NOT EXISTS / IF EXISTS.
-- =============================================================================

PRINT '=== Migration 7 started ===';
GO

-- =============================================================================
-- A. dbo.acr_cycles
-- =============================================================================

-- -------------------------------------------------------------------------
-- A1. Section I: Date of Joining in the Nigam (Sr. 5 on form)
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'date_joining_nigam'
)
    ALTER TABLE dbo.acr_cycles ADD [date_joining_nigam] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- A2. Section I: Date of Joining to Present Rank/Post (Sr. 6)
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'date_joining_present_rank'
)
    ALTER TABLE dbo.acr_cycles ADD [date_joining_present_rank] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- A3. Section I: Date of Joining to Present Station/Office (Sr. 7)
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'date_joining_present_station'
)
    ALTER TABLE dbo.acr_cycles ADD [date_joining_present_station] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- A4. Section I: Departmental Exam Passed (Sr. 8) — free text, filled by CCA
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'departmental_exam_passed'
)
    ALTER TABLE dbo.acr_cycles ADD [departmental_exam_passed] NVARCHAR(500) NULL;
GO

-- -------------------------------------------------------------------------
-- A5. Section I: Date of last prescribed medical examination (Sr. 11)
--     Distinct from the Officer's self-declared medical_compliance in
--     self_appraisals — this is the CCA-filled date in the header.
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'last_medical_exam_date'
)
    ALTER TABLE dbo.acr_cycles ADD [last_medical_exam_date] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- A6. Split the concatenated [qualification] column into two separate columns.
--
--     Current state:  [qualification] NVARCHAR(500) NULL
--                     CcaAdapter stores "academic | technical" combined.
--
--     New state:      [academic_qualification]  NVARCHAR(500) NULL
--                     [technical_qualification] NVARCHAR(500) NULL
--                     [qualification] column is then dropped.
--
--     NOTE: After this migration, CcaAdapter must be updated to write to
--     the two new columns instead of the combined [qualification] column.
-- -------------------------------------------------------------------------

-- Step A6a: Add the two new columns
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'academic_qualification'
)
    ALTER TABLE dbo.acr_cycles ADD [academic_qualification] NVARCHAR(500) NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'technical_qualification'
)
    ALTER TABLE dbo.acr_cycles ADD [technical_qualification] NVARCHAR(500) NULL;
GO

-- Step A6b: Migrate data from the old combined column if it still exists
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'qualification'
)
BEGIN
    UPDATE dbo.acr_cycles
    SET
        academic_qualification  = CASE
            WHEN CHARINDEX(' | ', qualification) > 0
                THEN LEFT(qualification, CHARINDEX(' | ', qualification) - 1)
            WHEN qualification IS NOT NULL
                THEN qualification
            ELSE NULL
        END,
        technical_qualification = CASE
            WHEN CHARINDEX(' | ', qualification) > 0
                THEN SUBSTRING(qualification, CHARINDEX(' | ', qualification) + 3, 500)
            ELSE NULL
        END
    WHERE qualification IS NOT NULL
      AND (academic_qualification IS NULL AND technical_qualification IS NULL);
END
GO

-- Step A6c: Drop the old combined column
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'qualification'
)
    ALTER TABLE dbo.acr_cycles DROP COLUMN qualification;
GO

-- -------------------------------------------------------------------------
-- A7. Replace property_return_done (BIT) with property_return_date (DATE)
--
--     The form (Section I, Sr. 10) asks for the DATE of filing the property
--     return, not just a yes/no flag.
--
--     Migration plan:
--       - Add new DATE column
--       - Existing rows where BIT = 1 get NULL (date unknown; was never stored)
--       - Drop the BIT column
--
--     NOTE: CcaAdapter must be updated — @propReturn (BIT) becomes
--     @propertyReturnDate (DATE, nullable).
-- -------------------------------------------------------------------------

-- Step A7a: Add the new DATE column
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'property_return_date'
)
    ALTER TABLE dbo.acr_cycles ADD [property_return_date] DATE NULL;
GO

-- Step A7b: Drop the old BIT column
--   (No data to migrate — if BIT was 1, we don't know the actual date)
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'property_return_done'
)
    ALTER TABLE dbo.acr_cycles DROP COLUMN property_return_done;
GO

PRINT 'Section A (acr_cycles) complete.';
GO

-- =============================================================================
-- B. dbo.self_appraisals
-- =============================================================================

-- -------------------------------------------------------------------------
-- B1. Declaration: date on which property return was filed (YES/NO + date on form)
--     The existing [property_declared] BIT captures yes/no.
--     This adds the actual date.
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'property_declared_date'
)
    ALTER TABLE dbo.self_appraisals ADD [property_declared_date] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- B2. Declaration: date of medical check-up (YES/NO + date on form)
--     The existing [medical_compliance] BIT captures yes/no.
--     This adds the actual date.
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'medical_compliance_date'
)
    ALTER TABLE dbo.self_appraisals ADD [medical_compliance_date] DATE NULL;
GO

-- -------------------------------------------------------------------------
-- B3. Fix auditor_compliance: NVARCHAR(MAX) → BIT
--
--     The form (A-1(b) only, Section II, Item 6) is a YES/NO field:
--     "Whether he/she has produced information/documents to Auditors?"
--     Stored as NVARCHAR(MAX) in Migration 4 — incorrect type.
--
--     Since this column was added in Migration 4 and has no production data
--     yet (the officer form isn't live), we drop and re-add as BIT NULL.
--     NULL = not applicable (A-1(a) and A-2 officers don't fill this).
-- -------------------------------------------------------------------------
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'auditor_compliance'
      AND system_type_id = TYPE_ID('nvarchar')
)
BEGIN
    ALTER TABLE dbo.self_appraisals DROP COLUMN auditor_compliance;
    ALTER TABLE dbo.self_appraisals ADD [auditor_compliance] BIT NULL;
END
GO

PRINT 'Section B (self_appraisals) complete.';
GO

-- =============================================================================
-- C. dbo.reporting_assessments
-- =============================================================================

-- -------------------------------------------------------------------------
-- C1. RA1 disagree details
--     Form Section III, Item 1: "If no, please give details"
--     (text box next to the agree_with_self YES/NO)
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_disagree_details'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra1_disagree_details] NVARCHAR(MAX) NULL;
GO

-- -------------------------------------------------------------------------
-- C2. RA2 narrative columns (A-1(b) only)
--     Migration 4 added all RA2 grading columns (ra2_work_*, ra2_attr_*,
--     ra2_comp_*) but the narrative text fields were not added.
-- -------------------------------------------------------------------------

-- RA2 agree with self-assessment (YES/NO)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_agree_with_self'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_agree_with_self] BIT NULL;
GO

-- RA2 disagree details text
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_disagree_details'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_disagree_details] NVARCHAR(MAX) NULL;
GO

-- RA2 integrity comment
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_integrity_comments'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_integrity_comments] NVARCHAR(MAX) NULL;
GO

-- RA2 comments/remarks
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_remarks'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_remarks] NVARCHAR(MAX) NULL;
GO

-- RA2 overall grade (avg of 15 items, 2 decimal places)
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_overall_grade'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_overall_grade] DECIMAL(4,2) NULL;
GO

-- RA2 submitted timestamp
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_submitted_at'
)
    ALTER TABLE dbo.reporting_assessments ADD [ra2_submitted_at] DATETIME NULL;
GO

PRINT 'Section C (reporting_assessments) complete.';
GO

-- =============================================================================
-- D. dbo.reviewing_assessments
-- =============================================================================
-- Baseline (Migration 1): agree_with_ra BIT, final_grade INT, remarks NVARCHAR(MAX),
--                          document_path, submitted_at
-- The RvA numerical grades (attr/comp/work) are stored in reporting_assessments
-- with rva_* prefix (Migration 4 design decision — shared grid table).
-- What's missing here are the narrative fields the form requires.

-- -------------------------------------------------------------------------
-- D1. Disagree details
--     Form Section IV, Item 2: "In case of difference of opinion, details/
--     reasons for the same may be given."
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reviewing_assessments') AND name = 'disagree_details'
)
    ALTER TABLE dbo.reviewing_assessments ADD [disagree_details] NVARCHAR(MAX) NULL;
GO

-- -------------------------------------------------------------------------
-- D2. Rename existing columns to match form language for clarity
--     [agree_with_ra] is correct — keep as is.
--     [final_grade] is the RvA overall grade (1-10) — keep as is.
--     [remarks] maps to "Comments of Reviewing Authority (if any)" — keep as is.
--
--     The [final_grade] INT NOT NULL is a problem: it was created NOT NULL
--     in Migration 1 but is functionally nullable (not filled until submitted).
--     Change to nullable so drafts don't require a grade.
-- -------------------------------------------------------------------------
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.reviewing_assessments')
      AND name = 'final_grade'
      AND is_nullable = 0
)
BEGIN
    -- Drop the CHECK constraint first
    IF EXISTS (
        SELECT 1 FROM sys.check_constraints
        WHERE name = 'CK_reviewing_grade'
          AND parent_object_id = OBJECT_ID('dbo.reviewing_assessments')
    )
        ALTER TABLE dbo.reviewing_assessments DROP CONSTRAINT CK_reviewing_grade;

    ALTER TABLE dbo.reviewing_assessments ALTER COLUMN [final_grade] DECIMAL(4,2) NULL;

    -- Re-add CHECK constraint (now on DECIMAL column, allowing NULL)
    ALTER TABLE dbo.reviewing_assessments ADD CONSTRAINT CK_reviewing_grade
        CHECK (final_grade IS NULL OR (final_grade >= 1 AND final_grade <= 10));
END
GO

PRINT 'Section D (reviewing_assessments) complete.';
GO

-- =============================================================================
-- E. dbo.accepting_decisions
-- =============================================================================
-- Baseline (Migration 1): agree_with_previous BIT, conflict_resolved BIT,
--                          final_grade INT NOT NULL, final_remarks NVARCHAR(MAX),
--                          document_path, is_approved BIT NOT NULL, decided_at

-- -------------------------------------------------------------------------
-- E1. Disagree details
--     Form Section V, Item 2: "In case of difference of opinion, details/
--     reasons for the same may be given."
-- -------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.accepting_decisions') AND name = 'disagree_details'
)
    ALTER TABLE dbo.accepting_decisions ADD [disagree_details] NVARCHAR(MAX) NULL;
GO

-- -------------------------------------------------------------------------
-- E2. Make final_grade nullable (same reason as reviewing_assessments above —
--     drafts should not require a grade to be saved)
-- -------------------------------------------------------------------------
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.accepting_decisions')
      AND name = 'final_grade'
      AND is_nullable = 0
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM sys.check_constraints
        WHERE name = 'CK_accepting_grade'
          AND parent_object_id = OBJECT_ID('dbo.accepting_decisions')
    )
        ALTER TABLE dbo.accepting_decisions DROP CONSTRAINT CK_accepting_grade;

    ALTER TABLE dbo.accepting_decisions ALTER COLUMN [final_grade] DECIMAL(4,2) NULL;

    ALTER TABLE dbo.accepting_decisions ADD CONSTRAINT CK_accepting_grade
        CHECK (final_grade IS NULL OR (final_grade >= 1 AND final_grade <= 10));
END
GO

-- -------------------------------------------------------------------------
-- E3. Make is_approved nullable
--     Currently BIT NOT NULL DEFAULT 0 — but "not yet decided" is a valid
--     state during draft. NULL means pending; 1 = approved; 0 = rejected.
-- -------------------------------------------------------------------------
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.accepting_decisions')
      AND name = 'is_approved'
      AND is_nullable = 0
)
    ALTER TABLE dbo.accepting_decisions ALTER COLUMN [is_approved] BIT NULL;
GO

PRINT 'Section E (accepting_decisions) complete.';
GO

PRINT '=== Migration 7 complete ===';
GO
