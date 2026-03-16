USE [ACRPortal]
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tbDsg') AND name = 'form_type'
)
    ALTER TABLE dbo.tbDsg ADD [form_type] VARCHAR(5) NULL;
GO

UPDATE dbo.tbDsg SET [form_type] = 'A1a' WHERE [form_type] IS NULL;
GO

ALTER TABLE dbo.tbDsg ALTER COLUMN [form_type] VARCHAR(5) NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_tbDsg_form_type' AND parent_object_id = OBJECT_ID('dbo.tbDsg'))
    ALTER TABLE dbo.tbDsg DROP CONSTRAINT CK_tbDsg_form_type;
GO

ALTER TABLE dbo.tbDsg ADD CONSTRAINT CK_tbDsg_form_type
    CHECK (form_type IN ('A1a', 'A1b', 'A2'));
GO

PRINT 'Migration 5 completed successfully.';
GO