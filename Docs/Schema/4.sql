USE [ACRPortal]
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'form_type'
)
    ALTER TABLE dbo.acr_cycles ADD [form_type] VARCHAR(5) NULL;
GO

UPDATE dbo.acr_cycles SET [form_type] = 'A1a' WHERE [form_type] IS NULL;
GO

ALTER TABLE dbo.acr_cycles ALTER COLUMN [form_type] VARCHAR(5) NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_acr_form_type' AND parent_object_id = OBJECT_ID('dbo.acr_cycles'))
    ALTER TABLE dbo.acr_cycles DROP CONSTRAINT CK_acr_form_type;
GO

ALTER TABLE dbo.acr_cycles ADD CONSTRAINT CK_acr_form_type
    CHECK (form_type IN ('A1a', 'A1b', 'A2'));
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.acr_cycles') AND name = 'ra2_user_id'
)
    ALTER TABLE dbo.acr_cycles ADD [ra2_user_id] UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_acr_reporting2')
    ALTER TABLE dbo.acr_cycles ADD CONSTRAINT FK_acr_reporting2
        FOREIGN KEY (ra2_user_id) REFERENCES dbo.users(user_id);
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_acr_status' AND parent_object_id = OBJECT_ID('dbo.acr_cycles'))
    ALTER TABLE dbo.acr_cycles DROP CONSTRAINT CK_acr_status;
GO

ALTER TABLE dbo.acr_cycles ADD CONSTRAINT CK_acr_status CHECK (status IN (
    'PENDING_OFFICER',
    'PENDING_REPORTING',
    'PENDING_REPORTING2',
    'PENDING_REVIEWING',
    'PENDING_ACCEPTING',
    'APPROVED',
    'REJECTED'
));
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'duties_performed')
    ALTER TABLE dbo.self_appraisals DROP COLUMN duties_performed;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'achievements')
    ALTER TABLE dbo.self_appraisals DROP COLUMN achievements;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'major_contributions')
    ALTER TABLE dbo.self_appraisals DROP COLUMN major_contributions;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'duties_description')
    ALTER TABLE dbo.self_appraisals ADD [duties_description] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'targets_set')
    ALTER TABLE dbo.self_appraisals ADD [targets_set] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'targets_achieved')
    ALTER TABLE dbo.self_appraisals ADD [targets_achieved] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'shortfall_reasons')
    ALTER TABLE dbo.self_appraisals ADD [shortfall_reasons] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'major_achievements')
    ALTER TABLE dbo.self_appraisals ADD [major_achievements] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'membership_bodies')
    ALTER TABLE dbo.self_appraisals ADD [membership_bodies] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'training_details')
    ALTER TABLE dbo.self_appraisals ADD [training_details] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'awards_honours')
    ALTER TABLE dbo.self_appraisals ADD [awards_honours] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'property_return_date')
    ALTER TABLE dbo.self_appraisals ADD [property_return_date] DATE NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.self_appraisals') AND name = 'auditor_compliance')
    ALTER TABLE dbo.self_appraisals ADD [auditor_compliance] NVARCHAR(MAX) NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'work_output_grade')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_reporting_grades' AND parent_object_id = OBJECT_ID('dbo.reporting_assessments'))
        ALTER TABLE dbo.reporting_assessments DROP CONSTRAINT CK_reporting_grades;
    ALTER TABLE dbo.reporting_assessments DROP COLUMN work_output_grade;
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'personal_attr_grade')
    ALTER TABLE dbo.reporting_assessments DROP COLUMN personal_attr_grade;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'functional_comp_grade')
    ALTER TABLE dbo.reporting_assessments DROP COLUMN functional_comp_grade;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'overall_grade')
    ALTER TABLE dbo.reporting_assessments DROP COLUMN overall_grade;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'agree_with_self')
    EXEC sp_rename 'dbo.reporting_assessments.agree_with_self', 'ra1_agree_with_self', 'COLUMN';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'integrity_comments')
    EXEC sp_rename 'dbo.reporting_assessments.integrity_comments', 'ra1_integrity_comments', 'COLUMN';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'remarks')
    EXEC sp_rename 'dbo.reporting_assessments.remarks', 'ra1_remarks', 'COLUMN';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'submitted_at')
    EXEC sp_rename 'dbo.reporting_assessments.submitted_at', 'ra1_submitted_at', 'COLUMN';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_work_targets')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_work_targets] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_work_quality')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_work_quality] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_work_exceptional')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_work_exceptional] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_work_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_work_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_attitude')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_attitude] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_responsibility')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_responsibility] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_stability')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_stability] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_communication')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_communication] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_moral_courage')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_moral_courage] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_leadership')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_leadership] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_timeliness')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_timeliness] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_attr_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_attr_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_knowledge')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_knowledge] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_planning')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_planning] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_decision')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_decision] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_initiative')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_initiative] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_teamwork')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_teamwork] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_comp_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_comp_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_overall_grade')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_overall_grade] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra1_disagree_details')
    ALTER TABLE dbo.reporting_assessments ADD [ra1_disagree_details] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_agree_with_self')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_agree_with_self] BIT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_disagree_details')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_disagree_details] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_work_targets')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_work_targets] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_work_quality')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_work_quality] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_work_exceptional')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_work_exceptional] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_work_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_work_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_attitude')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_attitude] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_responsibility')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_responsibility] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_stability')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_stability] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_communication')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_communication] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_moral_courage')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_moral_courage] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_leadership')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_leadership] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_timeliness')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_timeliness] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_attr_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_attr_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_knowledge')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_knowledge] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_planning')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_planning] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_decision')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_decision] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_initiative')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_initiative] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_teamwork')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_teamwork] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_comp_overall')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_comp_overall] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_integrity_comments')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_integrity_comments] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_overall_grade')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_overall_grade] DECIMAL(4,2) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_remarks')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_remarks] NVARCHAR(MAX) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'ra2_submitted_at')
    ALTER TABLE dbo.reporting_assessments ADD [ra2_submitted_at] DATETIME NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_work_targets')
    ALTER TABLE dbo.reporting_assessments ADD [rva_work_targets] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_work_quality')
    ALTER TABLE dbo.reporting_assessments ADD [rva_work_quality] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_work_exceptional')
    ALTER TABLE dbo.reporting_assessments ADD [rva_work_exceptional] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_attitude')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_attitude] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_responsibility')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_responsibility] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_stability')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_stability] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_communication')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_communication] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_moral_courage')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_moral_courage] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_leadership')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_leadership] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_attr_timeliness')
    ALTER TABLE dbo.reporting_assessments ADD [rva_attr_timeliness] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_comp_knowledge')
    ALTER TABLE dbo.reporting_assessments ADD [rva_comp_knowledge] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_comp_planning')
    ALTER TABLE dbo.reporting_assessments ADD [rva_comp_planning] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_comp_decision')
    ALTER TABLE dbo.reporting_assessments ADD [rva_comp_decision] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_comp_initiative')
    ALTER TABLE dbo.reporting_assessments ADD [rva_comp_initiative] TINYINT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.reporting_assessments') AND name = 'rva_comp_teamwork')
    ALTER TABLE dbo.reporting_assessments ADD [rva_comp_teamwork] TINYINT NULL;
GO

PRINT 'Migration 4 completed successfully.';
GO