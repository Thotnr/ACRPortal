USE [ACRPortal]
GO

-- =============================================================================
-- Migration : Auto-Advance Stored Procedure + SQL Server Agent Job
--
-- PART 1 — usp_AutoAdvanceAcrSteps
--   Runs every day. For each ACR step (except Accepting), if the deadline
--   has passed and the step is still incomplete, the procedure:
--     1. Inserts a placeholder "skipped" row in the relevant section table.
--     2. Advances acr_cycles.status to the next step.
--
-- Step deadlines (30 days from when the step became active):
--
--   PENDING_OFFICER   → deadline = acr_cycles.submitted_at + 30 days
--                        Clock starts when CCA submits the ACR.
--
--   PENDING_REPORTING → deadline = self_appraisals.submitted_at + 30 days
--                        (submitted_at is set to skip-time if officer was skipped)
--                        For A1b: BOTH RA1 and RA2 must submit within 30 days.
--                        If either has not submitted, both unsubmitted RAs are
--                        treated as skipped and the step advances together.
--
--   PENDING_REVIEWING → deadline = ra_step_end + 30 days
--                        ra_step_end = later of ra1_submitted_at / ra2_submitted_at
--                        (for A1a/A2 only ra1_submitted_at matters)
--
--   PENDING_ACCEPTING → NOT auto-advanced. The Accepting Authority must
--                        submit their final decision manually. This is the
--                        final human sign-off and cannot be skipped by the system.
--
-- PART 2 — SQL Server Agent Job
--   Creates a job named "ACR Auto-Advance Daily" that runs the procedure
--   every day at 02:00 AM.
--   Prerequisites: SQL Server Agent service must be running (not on Express).
--                  The login used by the Agent must have EXECUTE rights
--                  on usp_AutoAdvanceAcrSteps.
-- =============================================================================

-- =============================================================================
-- PART 1: Stored Procedure
-- =============================================================================

IF OBJECT_ID('dbo.usp_AutoAdvanceAcrSteps', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AutoAdvanceAcrSteps;
GO

CREATE PROCEDURE dbo.usp_AutoAdvanceAcrSteps
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now          DATETIME = GETDATE();
    DECLARE @DeadlineDays INT      = 30;

    -- Counters for the summary log
    DECLARE @OfficerSkipped   INT = 0;
    DECLARE @ReportingSkipped INT = 0;
    DECLARE @ReviewingSkipped INT = 0;

    -- =========================================================================
    -- STEP 1: Skip Officer self-appraisal
    --
    -- Condition: status = 'PENDING_OFFICER'
    --            AND acr_cycles.submitted_at + 30 days < NOW
    --
    -- Two sub-cases:
    --   1a. No self_appraisals row exists yet — insert a skipped placeholder.
    --   1b. A draft row exists (submitted_at IS NULL) — mark it as skipped.
    --       Draft content the officer may have entered is preserved.
    -- =========================================================================

    -- 1a. Insert skipped row where no self_appraisals row exists at all
    INSERT INTO dbo.self_appraisals (
        acr_id,
        is_skipped,
        submitted_at,
        created_at
    )
    SELECT
        ac.acr_id,
        1,      -- is_skipped
        @Now,   -- treat skip-time as submitted_at so downstream clock works
        @Now
    FROM dbo.acr_cycles ac
    WHERE ac.status       = 'PENDING_OFFICER'
      AND ac.submitted_at IS NOT NULL
      AND DATEADD(DAY, @DeadlineDays, ac.submitted_at) < @Now
      AND NOT EXISTS (
            SELECT 1 FROM dbo.self_appraisals sa
            WHERE sa.acr_id = ac.acr_id
          );

    -- 1b. Update existing draft rows (submitted_at IS NULL) to mark as skipped
    UPDATE sa
    SET    sa.is_skipped   = 1,
           sa.submitted_at = @Now
    FROM   dbo.self_appraisals sa
    INNER JOIN dbo.acr_cycles  ac ON ac.acr_id = sa.acr_id
    WHERE  ac.status        = 'PENDING_OFFICER'
      AND  ac.submitted_at  IS NOT NULL
      AND  DATEADD(DAY, @DeadlineDays, ac.submitted_at) < @Now
      AND  sa.submitted_at  IS NULL;

    -- 1c. Advance status for all affected ACRs
    UPDATE ac
    SET    ac.status     = 'PENDING_REPORTING',
           ac.updated_at = @Now
    FROM   dbo.acr_cycles      ac
    INNER JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
    WHERE  ac.status       = 'PENDING_OFFICER'
      AND  ac.submitted_at IS NOT NULL
      AND  DATEADD(DAY, @DeadlineDays, ac.submitted_at) < @Now
      AND  sa.is_skipped   = 1
      AND  sa.submitted_at IS NOT NULL;

    SET @OfficerSkipped = @@ROWCOUNT;

    -- =========================================================================
    -- STEP 2: Skip Reporting assessment(s)
    --
    -- Clock starts from self_appraisals.submitted_at (= skip-time if Step 1
    -- ran for this ACR today).
    --
    -- A1a / A2 (single RA):
    --   2a. No reporting_assessments row — insert skipped placeholder.
    --   2b. Draft row exists (ra1_submitted_at IS NULL) — mark as skipped.
    --
    -- A1b (two RAs, must both submit):
    --   2c. No reporting_assessments row — insert skipped placeholder with
    --       both ra1_submitted_at and ra2_submitted_at set to @Now.
    --   2d. Row exists but at least one RA has not submitted — fill in the
    --       missing submitted_at(s) and mark is_skipped = 1.
    --
    -- 2e. Advance status for all form types where reporting is now resolved.
    -- =========================================================================

    -- 2a. A1a / A2: no row at all
    INSERT INTO dbo.reporting_assessments (
        acr_id,
        is_skipped,
        ra1_submitted_at
    )
    SELECT
        ac.acr_id,
        1,
        @Now
    FROM dbo.acr_cycles      ac
    INNER JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
    WHERE ac.status    = 'PENDING_REPORTING'
      AND ac.form_type IN ('A1a', 'A2')
      AND sa.submitted_at IS NOT NULL
      AND DATEADD(DAY, @DeadlineDays, sa.submitted_at) < @Now
      AND NOT EXISTS (
            SELECT 1 FROM dbo.reporting_assessments ra
            WHERE ra.acr_id = ac.acr_id
          );

    -- 2b. A1a / A2: draft row exists
    UPDATE ra
    SET    ra.is_skipped       = 1,
           ra.ra1_submitted_at = @Now
    FROM   dbo.reporting_assessments ra
    INNER JOIN dbo.acr_cycles        ac ON ac.acr_id = ra.acr_id
    INNER JOIN dbo.self_appraisals   sa ON sa.acr_id = ac.acr_id
    WHERE  ac.status           = 'PENDING_REPORTING'
      AND  ac.form_type        IN ('A1a', 'A2')
      AND  sa.submitted_at     IS NOT NULL
      AND  DATEADD(DAY, @DeadlineDays, sa.submitted_at) < @Now
      AND  ra.ra1_submitted_at IS NULL;

    -- 2c. A1b: no row at all
    INSERT INTO dbo.reporting_assessments (
        acr_id,
        is_skipped,
        ra1_submitted_at,
        ra2_submitted_at
    )
    SELECT
        ac.acr_id,
        1,
        @Now,
        @Now
    FROM dbo.acr_cycles      ac
    INNER JOIN dbo.self_appraisals sa ON sa.acr_id = ac.acr_id
    WHERE ac.status     = 'PENDING_REPORTING'
      AND ac.form_type  = 'A1b'
      AND sa.submitted_at IS NOT NULL
      AND DATEADD(DAY, @DeadlineDays, sa.submitted_at) < @Now
      AND NOT EXISTS (
            SELECT 1 FROM dbo.reporting_assessments ra
            WHERE ra.acr_id = ac.acr_id
          );

    -- 2d. A1b: row exists but at least one RA has not submitted
    UPDATE ra
    SET    ra.is_skipped      = 1,
           ra.ra1_submitted_at = CASE WHEN ra.ra1_submitted_at IS NULL THEN @Now ELSE ra.ra1_submitted_at END,
           ra.ra2_submitted_at = CASE WHEN ra.ra2_submitted_at IS NULL THEN @Now ELSE ra.ra2_submitted_at END
    FROM   dbo.reporting_assessments ra
    INNER JOIN dbo.acr_cycles        ac ON ac.acr_id = ra.acr_id
    INNER JOIN dbo.self_appraisals   sa ON sa.acr_id = ac.acr_id
    WHERE  ac.status         = 'PENDING_REPORTING'
      AND  ac.form_type      = 'A1b'
      AND  sa.submitted_at   IS NOT NULL
      AND  DATEADD(DAY, @DeadlineDays, sa.submitted_at) < @Now
      AND  (ra.ra1_submitted_at IS NULL OR ra.ra2_submitted_at IS NULL);

    -- 2e. Advance status for all form types
    UPDATE ac
    SET    ac.status     = 'PENDING_REVIEWING',
           ac.updated_at = @Now
    FROM   dbo.acr_cycles             ac
    INNER JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
    WHERE  ac.status      = 'PENDING_REPORTING'
      AND  ra.is_skipped  = 1
      AND  ra.ra1_submitted_at IS NOT NULL
      AND (ac.form_type IN ('A1a','A2') OR ra.ra2_submitted_at IS NOT NULL);

    SET @ReportingSkipped = @@ROWCOUNT;

    -- =========================================================================
    -- STEP 3: Skip Reviewing assessment
    --
    -- Clock start = the later of ra1_submitted_at / ra2_submitted_at
    -- (for A1a/A2 only ra1_submitted_at matters).
    --
    -- 3a. No reviewing_assessments row — insert skipped placeholder.
    -- 3b. Draft row exists (submitted_at IS NULL) — mark as skipped.
    -- 3c. Advance status to PENDING_ACCEPTING.
    -- =========================================================================

    -- 3a. No row at all
    INSERT INTO dbo.reviewing_assessments (
        acr_id,
        is_skipped,
        submitted_at
    )
    SELECT
        ac.acr_id,
        1,
        @Now
    FROM dbo.acr_cycles             ac
    INNER JOIN dbo.reporting_assessments ra ON ra.acr_id = ac.acr_id
    WHERE ac.status = 'PENDING_REVIEWING'
      AND (
            -- A1a / A2: use ra1_submitted_at
            (ac.form_type IN ('A1a','A2')
             AND ra.ra1_submitted_at IS NOT NULL
             AND DATEADD(DAY, @DeadlineDays, ra.ra1_submitted_at) < @Now)
            OR
            -- A1b: use the later of the two timestamps
            (ac.form_type = 'A1b'
             AND ra.ra1_submitted_at IS NOT NULL
             AND ra.ra2_submitted_at IS NOT NULL
             AND DATEADD(DAY, @DeadlineDays,
                    CASE WHEN ra.ra2_submitted_at > ra.ra1_submitted_at
                         THEN ra.ra2_submitted_at
                         ELSE ra.ra1_submitted_at END) < @Now)
          )
      AND NOT EXISTS (
            SELECT 1 FROM dbo.reviewing_assessments rv
            WHERE rv.acr_id = ac.acr_id
          );

    -- 3b. Draft row exists (submitted_at IS NULL)
    UPDATE rv
    SET    rv.is_skipped  = 1,
           rv.submitted_at = @Now
    FROM   dbo.reviewing_assessments rv
    INNER JOIN dbo.acr_cycles             ac ON ac.acr_id = rv.acr_id
    INNER JOIN dbo.reporting_assessments  ra ON ra.acr_id = ac.acr_id
    WHERE  ac.status        = 'PENDING_REVIEWING'
      AND  rv.submitted_at  IS NULL
      AND  (
             (ac.form_type IN ('A1a','A2')
              AND ra.ra1_submitted_at IS NOT NULL
              AND DATEADD(DAY, @DeadlineDays, ra.ra1_submitted_at) < @Now)
             OR
             (ac.form_type = 'A1b'
              AND ra.ra1_submitted_at IS NOT NULL
              AND ra.ra2_submitted_at IS NOT NULL
              AND DATEADD(DAY, @DeadlineDays,
                     CASE WHEN ra.ra2_submitted_at > ra.ra1_submitted_at
                          THEN ra.ra2_submitted_at
                          ELSE ra.ra1_submitted_at END) < @Now)
           );

    -- 3c. Advance status to PENDING_ACCEPTING
    UPDATE ac
    SET    ac.status     = 'PENDING_ACCEPTING',
           ac.updated_at = @Now
    FROM   dbo.acr_cycles              ac
    INNER JOIN dbo.reviewing_assessments rv ON rv.acr_id = ac.acr_id
    WHERE  ac.status      = 'PENDING_REVIEWING'
      AND  rv.is_skipped  = 1
      AND  rv.submitted_at IS NOT NULL;

    SET @ReviewingSkipped = @@ROWCOUNT;

    -- =========================================================================
    -- NOTE: PENDING_ACCEPTING is intentionally NOT auto-advanced.
    -- The Accepting Authority must submit their final decision manually.
    -- =========================================================================

    -- =========================================================================
    -- Summary log (visible in SQL Server Agent job history)
    -- =========================================================================
    PRINT 'usp_AutoAdvanceAcrSteps completed at ' + CONVERT(VARCHAR, @Now, 120);
    PRINT '  Officer steps skipped   : ' + CAST(@OfficerSkipped   AS VARCHAR);
    PRINT '  Reporting steps skipped : ' + CAST(@ReportingSkipped AS VARCHAR);
    PRINT '  Reviewing steps skipped : ' + CAST(@ReviewingSkipped AS VARCHAR);
    PRINT '  Accepting step          : manual only — not touched by this job.';

END
GO

PRINT 'Stored procedure usp_AutoAdvanceAcrSteps created.';
GO

-- =============================================================================
-- PART 2: SQL Server Agent Job
--
-- Creates a job named "ACR Auto-Advance Daily" that runs the procedure
-- every day at 02:00 AM.
--
-- PREREQUISITES:
--   1. SQL Server Agent service must be running (not available on Express).
--   2. Run this block connected as a sysadmin or member of SQLAgentOperatorRole.
--   3. If the job already exists (re-running migration), it is dropped and recreated.
-- =============================================================================

USE [msdb]
GO

-- Drop job if it already exists (safe re-run)
IF EXISTS (
    SELECT 1 FROM msdb.dbo.sysjobs
    WHERE  name = N'ACR Auto-Advance Daily'
)
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name              = N'ACR Auto-Advance Daily',
        @delete_unused_schedule = 1;
    PRINT 'Existing job dropped.';
END
GO

-- -----------------------------------------------------------------------
-- Create the job
-- -----------------------------------------------------------------------
DECLARE @jobId UNIQUEIDENTIFIER;

EXEC msdb.dbo.sp_add_job
    @job_name              = N'ACR Auto-Advance Daily',
    @enabled               = 1,
    @description           = N'Auto-advances stale ACR steps (Officer, Reporting, Reviewing) after 30 days. Accepting step is manual only.',
    @notify_level_eventlog = 2,   -- log on failure
    @job_id                = @jobId OUTPUT;

-- -----------------------------------------------------------------------
-- Add the single job step
-- -----------------------------------------------------------------------
EXEC msdb.dbo.sp_add_jobstep
    @job_id            = @jobId,
    @step_name         = N'Run usp_AutoAdvanceAcrSteps',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @command           = N'EXEC [ACRPortal].[dbo].[usp_AutoAdvanceAcrSteps];',
    @database_name     = N'ACRPortal',
    @on_success_action = 1,   -- Quit with success
    @on_fail_action    = 2,   -- Quit with failure
    @retry_attempts    = 1,
    @retry_interval    = 5;   -- minutes between retries

-- -----------------------------------------------------------------------
-- Schedule: daily at 02:00 AM
-- freq_type     = 4  → daily
-- freq_interval = 1  → every 1 day
-- active_start_time = 20000 → 02:00:00 AM (HHMMSS)
-- -----------------------------------------------------------------------
EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'ACR Daily 2AM',
    @freq_type         = 4,
    @freq_interval     = 1,
    @active_start_time = 20000;

EXEC msdb.dbo.sp_attach_schedule
    @job_id        = @jobId,
    @schedule_name = N'ACR Daily 2AM';

-- -----------------------------------------------------------------------
-- Assign to the local server
-- -----------------------------------------------------------------------
EXEC msdb.dbo.sp_add_jobserver
    @job_id      = @jobId,
    @server_name = N'(local)';

PRINT 'SQL Server Agent job "ACR Auto-Advance Daily" created — runs daily at 02:00 AM.';
GO

-- =============================================================================
-- VERIFICATION QUERIES
-- Run these after deployment to confirm everything is in place.
-- =============================================================================

-- Confirm the job exists and is enabled
SELECT
    j.name,
    j.enabled,
    j.description,
    s.next_run_date,
    s.next_run_time
FROM msdb.dbo.sysjobs        j
JOIN msdb.dbo.sysjobschedules js ON js.job_id     = j.job_id
JOIN msdb.dbo.sysschedules    s  ON s.schedule_id = js.schedule_id
WHERE j.name = N'ACR Auto-Advance Daily';
GO

-- Confirm new columns from Migration 12 are present
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME  IN ('acr_cycles','self_appraisals','reporting_assessments',
                      'reviewing_assessments','accepting_decisions')
  AND COLUMN_NAME IN ('submitted_at','is_skipped')
ORDER BY TABLE_NAME, COLUMN_NAME;
GO