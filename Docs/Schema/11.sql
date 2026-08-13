USE [ACRPortal]
GO

-- =============================================================================
-- Migration 11: Performance Indexes
-- Derived from query patterns in all Infrastructure Adapter classes.
-- Safe to re-run: every CREATE INDEX is guarded with IF NOT EXISTS.
-- =============================================================================

PRINT '=== Migration 11: Performance Indexes started ===';
GO

-- =============================================================================
-- dbo.users
-- =============================================================================

-- Auth: GetUserByLoginId — login by login_id (already has UQ, so a covering
-- index adding the most-read columns avoids a key lookup on every login)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_login_id_cover' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_login_id_cover
        ON dbo.users (login_id)
        INCLUDE (user_id, password_hash, display_name, user_status, system_role);
GO

-- AdminAdapter.GetAllUsers — role + status filter (most common list query)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_role_status' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_role_status
        ON dbo.users (system_role, user_status)
        INCLUDE (user_id, login_id, display_name, dsg_id, zone_id, division_id, created_at, manager_id);
GO

-- AdminAdapter.GetAllUsers — dsg_id filter
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_dsg_id' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_dsg_id
        ON dbo.users (dsg_id)
        INCLUDE (user_id, login_id, display_name, system_role, user_status);
GO

-- AdminAdapter.GetAllUsers — zone_id filter
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_zone_id' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_zone_id
        ON dbo.users (zone_id)
        INCLUDE (user_id, login_id, display_name, system_role, user_status);
GO

-- AdminAdapter.GetAllUsers — division_id filter
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_division_id' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_division_id
        ON dbo.users (division_id)
        INCLUDE (user_id, login_id, display_name, system_role, user_status);
GO

-- AdminAdapter.IsValidManager / CcaAdapter.GetAuthoritySuggestions — manager chain lookup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_users_manager_id' AND object_id = OBJECT_ID('dbo.users'))
    CREATE NONCLUSTERED INDEX idx_users_manager_id
        ON dbo.users (manager_id)
        INCLUDE (user_id, login_id, display_name, system_role, user_status);
GO

-- =============================================================================
-- dbo.user_identities
-- =============================================================================

-- AdminAdapter.GetAllUsers / GetUserById — join on user_id + identity_type + is_primary
-- (already has UQ on identity_type+identity_value; this covers the user-side join)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_user_identities_user_type_primary' AND object_id = OBJECT_ID('dbo.user_identities'))
    CREATE NONCLUSTERED INDEX idx_user_identities_user_type_primary
        ON dbo.user_identities (user_id, identity_type, is_primary)
        INCLUDE (identity_value);
GO

-- =============================================================================
-- dbo.sessions
-- =============================================================================

-- AuthAdapter.IsSessionActive — session_id lookup already on PK;
-- index for DeactivateOldSessions (UPDATE WHERE user_id + status = ACTIVE)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_sessions_user_status' AND object_id = OBJECT_ID('dbo.sessions'))
    CREATE NONCLUSTERED INDEX idx_sessions_user_status
        ON dbo.sessions (user_id, status)
        INCLUDE (expires_at, revoked_at);
GO

-- =============================================================================
-- dbo.otp_challenges
-- =============================================================================

-- AuthAdapter — CountRecentOtpAttempts: identity_value + created_at range scan
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_otp_identity_created' AND object_id = OBJECT_ID('dbo.otp_challenges'))
    CREATE NONCLUSTERED INDEX idx_otp_identity_created
        ON dbo.otp_challenges (identity_value, created_at);
GO

-- AuthAdapter — GetOtp: identity_value + otp_hash + status + expires_at
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_otp_verify' AND object_id = OBJECT_ID('dbo.otp_challenges'))
    CREATE NONCLUSTERED INDEX idx_otp_verify
        ON dbo.otp_challenges (identity_value, otp_hash, status, expires_at)
        INCLUDE (otp_id);
GO

-- =============================================================================
-- dbo.acr_cycles
-- =============================================================================

-- OfficerAdapter.GetMyAcrs — officer_user_id + status filter + created_at sort
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_officer_status_created' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_officer_status_created
        ON dbo.acr_cycles (officer_user_id, status, created_at DESC)
        INCLUDE (form_type, department, location, designation, posting_from, posting_to, acr_year);
GO

-- ReportingAdapter.GetMyReportingQueue — reporting_user_id OR ra2_user_id + status
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_reporting_user_status' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_reporting_user_status
        ON dbo.acr_cycles (reporting_user_id, status, created_at DESC)
        INCLUDE (ra2_user_id, form_type, department, location, posting_from, posting_to, acr_year, designation);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_ra2_user_status' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_ra2_user_status
        ON dbo.acr_cycles (ra2_user_id, status, created_at DESC)
        INCLUDE (reporting_user_id, form_type, department, location, posting_from, posting_to, acr_year, designation);
GO

-- ReviewingAdapter.GetMyReviewingQueue — reviewing_user_id + status
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_reviewing_user_status' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_reviewing_user_status
        ON dbo.acr_cycles (reviewing_user_id, status, created_at DESC)
        INCLUDE (form_type, department, location, posting_from, posting_to, acr_year, designation);
GO

-- AcceptingAdapter.GetMyAcceptingQueue — accepting_user_id + status
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_accepting_user_status' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_accepting_user_status
        ON dbo.acr_cycles (accepting_user_id, status, created_at DESC)
        INCLUDE (form_type, department, location, posting_from, posting_to, acr_year, officer_user_id, designation);
GO

-- CcaAdapter.GetCcaAcrs — cca_user_id + status
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_cca_user_status' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_cca_user_status
        ON dbo.acr_cycles (cca_user_id, status, created_at DESC)
        INCLUDE (officer_user_id, form_type, department, location, posting_from, posting_to, acr_year, designation);
GO

-- AdminAdapter.GetAllAcrs — status filter + created_at sort (no user scope)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_status_created' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_status_created
        ON dbo.acr_cycles (status, created_at DESC)
        INCLUDE (officer_user_id, form_type, department, location, posting_from, posting_to, acr_year, designation);
GO

-- DashboardAdapter.GetSummary — cca_user_id aggregate scan
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_cca_status_agg' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_cca_status_agg
        ON dbo.acr_cycles (cca_user_id, status);
GO

-- CcaAdapter.IsAcrDuplicate — duplicate check
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_officer_posting_from' AND object_id = OBJECT_ID('dbo.acr_cycles'))
    CREATE NONCLUSTERED INDEX idx_acr_officer_posting_from
        ON dbo.acr_cycles (officer_user_id, posting_from)
        INCLUDE (acr_id);
GO

-- =============================================================================
-- dbo.self_appraisals
-- =============================================================================

-- All detail adapters join self_appraisals ON acr_id; UQ already exists,
-- a covering index avoids a key lookup when reading appraisal content
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_self_appraisals_acr_cover' AND object_id = OBJECT_ID('dbo.self_appraisals'))
    CREATE NONCLUSTERED INDEX idx_self_appraisals_acr_cover
        ON dbo.self_appraisals (acr_id)
        INCLUDE (
            appraisal_id, submitted_at,
            leave_details, duties_description,
            targets_set, targets_achieved, shortfall_reasons,
            major_achievements, membership_bodies, training_details,
            awards_honours, auditor_compliance,
            property_declared, property_declared_date,
            medical_compliance, medical_compliance_date
        );
GO

-- =============================================================================
-- dbo.reporting_assessments
-- =============================================================================

-- All detail adapters join reporting_assessments ON acr_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_reporting_assessments_acr' AND object_id = OBJECT_ID('dbo.reporting_assessments'))
    CREATE NONCLUSTERED INDEX idx_reporting_assessments_acr
        ON dbo.reporting_assessments (acr_id)
        INCLUDE (
            assessment_id,
            ra1_submitted_at, ra2_submitted_at
        );
GO

-- =============================================================================
-- dbo.reviewing_assessments
-- =============================================================================

-- Detail adapters join reviewing_assessments ON acr_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_reviewing_assessments_acr' AND object_id = OBJECT_ID('dbo.reviewing_assessments'))
    CREATE NONCLUSTERED INDEX idx_reviewing_assessments_acr
        ON dbo.reviewing_assessments (acr_id)
        INCLUDE (review_id, submitted_at, agree_with_ra, disagree_details, remarks, final_grade);
GO

-- =============================================================================
-- dbo.accepting_decisions
-- =============================================================================

-- Detail adapters + AcceptingAdapter.GetMyAcceptingQueue join on acr_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_accepting_decisions_acr' AND object_id = OBJECT_ID('dbo.accepting_decisions'))
    CREATE NONCLUSTERED INDEX idx_accepting_decisions_acr
        ON dbo.accepting_decisions (acr_id)
        INCLUDE (decision_id, decided_at, agree_with_previous, disagree_details,
                 conflict_resolved, final_grade, final_remarks, is_approved);
GO

-- =============================================================================
-- dbo.acr_documents
-- =============================================================================

-- DocumentAdapter.GetDocuments — acr_id (+ optional section filter)
-- idx_acr_documents_acr_section already created in Migration 9.
-- Add a covering index for the common full-document fetch
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_acr_documents_acr_section_cover' AND object_id = OBJECT_ID('dbo.acr_documents'))
    CREATE NONCLUSTERED INDEX idx_acr_documents_acr_section_cover
        ON dbo.acr_documents (acr_id, section, uploaded_at ASC)
        INCLUDE (document_id, document_type, file_url, file_name);
GO

-- =============================================================================
-- dbo.tbDsg
-- =============================================================================

-- All adapters join tbDsg ON dsgDesc = ac.designation (text equality join)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_tbDsg_dsgDesc' AND object_id = OBJECT_ID('dbo.tbDsg'))
    CREATE NONCLUSTERED INDEX idx_tbDsg_dsgDesc
        ON dbo.tbDsg (dsgDesc)
        INCLUDE (dsgId, dsg, dsgLevel, dsgIsActive, form_type);
GO

PRINT '=== Migration 11: Performance Indexes complete ===';
GO
