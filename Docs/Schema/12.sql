USE [ACRPortal]
GO

PRINT '=== Migration 12: self_appraisals tri-state compliance fields ===';
GO

IF OBJECT_ID('dbo.self_appraisals', 'U') IS NULL
BEGIN
    PRINT 'Table dbo.self_appraisals does not exist. Skipping migration 12.';
    RETURN;
END
GO

BEGIN TRY
    BEGIN TRAN;

    DECLARE @propertyType NVARCHAR(128);
    DECLARE @medicalType NVARCHAR(128);
    DECLARE @sql NVARCHAR(MAX);

    SELECT @propertyType = t.name
    FROM sys.columns c
    JOIN sys.types t
        ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.self_appraisals')
      AND c.name = 'property_declared';

    SELECT @medicalType = t.name
    FROM sys.columns c
    JOIN sys.types t
        ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.self_appraisals')
      AND c.name = 'medical_compliance';

    -------------------------------------------------------------------------
    -- 1. Drop dependent index if present
    -------------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'idx_self_appraisals_acr_cover'
    )
    BEGIN
        DROP INDEX idx_self_appraisals_acr_cover ON dbo.self_appraisals;
        PRINT 'Dropped index idx_self_appraisals_acr_cover';
    END

    -------------------------------------------------------------------------
    -- 2. Drop default constraints on target columns, regardless of name
    -------------------------------------------------------------------------
    SELECT @sql = NULL;

    SELECT @sql = @sql +
        N'ALTER TABLE dbo.self_appraisals DROP CONSTRAINT [' + dc.name + N'];' + CHAR(13) + CHAR(10)
    FROM sys.default_constraints dc
    JOIN sys.columns c
        ON c.object_id = dc.parent_object_id
       AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.self_appraisals')
      AND c.name IN ('property_declared', 'medical_compliance');

    IF @sql IS NOT NULL AND LEN(@sql) > 0
    BEGIN
        EXEC sp_executesql @sql;
        PRINT 'Dropped existing default constraints on target columns';
    END

    -------------------------------------------------------------------------
    -- 3. Drop check constraints if present
    -------------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'CK_self_appraisals_property_declared'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        DROP CONSTRAINT CK_self_appraisals_property_declared;
        PRINT 'Dropped CK_self_appraisals_property_declared';
    END

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'CK_self_appraisals_medical_compliance'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        DROP CONSTRAINT CK_self_appraisals_medical_compliance;
        PRINT 'Dropped CK_self_appraisals_medical_compliance';
    END

    -------------------------------------------------------------------------
    -- 4. Alter columns only if still not varchar
    -------------------------------------------------------------------------
    IF @propertyType IS NOT NULL AND @propertyType <> 'varchar'
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ALTER COLUMN property_declared VARCHAR(3) NOT NULL;

        PRINT 'Altered property_declared to VARCHAR(3)';
    END
    ELSE
    BEGIN
        PRINT 'property_declared already compatible';
    END

    IF @medicalType IS NOT NULL AND @medicalType <> 'varchar'
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ALTER COLUMN medical_compliance VARCHAR(3) NOT NULL;

        PRINT 'Altered medical_compliance to VARCHAR(3)';
    END
    ELSE
    BEGIN
        PRINT 'medical_compliance already compatible';
    END

    -------------------------------------------------------------------------
    -- 5. Normalize existing data
    -------------------------------------------------------------------------
    UPDATE dbo.self_appraisals
    SET property_declared =
        CASE UPPER(LTRIM(RTRIM(ISNULL(property_declared, ''))))
            WHEN '1' THEN 'Yes'
            WHEN '0' THEN 'No'
            WHEN 'TRUE' THEN 'Yes'
            WHEN 'FALSE' THEN 'No'
            WHEN 'Y' THEN 'Yes'
            WHEN 'N' THEN 'No'
            WHEN 'YES' THEN 'Yes'
            WHEN 'NO' THEN 'No'
            WHEN 'NA' THEN 'NA'
            WHEN 'N/A' THEN 'NA'
            ELSE 'No'
        END,
        medical_compliance =
        CASE UPPER(LTRIM(RTRIM(ISNULL(medical_compliance, ''))))
            WHEN '1' THEN 'Yes'
            WHEN '0' THEN 'No'
            WHEN 'TRUE' THEN 'Yes'
            WHEN 'FALSE' THEN 'No'
            WHEN 'Y' THEN 'Yes'
            WHEN 'N' THEN 'No'
            WHEN 'YES' THEN 'Yes'
            WHEN 'NO' THEN 'No'
            WHEN 'NA' THEN 'NA'
            WHEN 'N/A' THEN 'NA'
            ELSE 'No'
        END;

    PRINT 'Normalized data in self_appraisals';

    -------------------------------------------------------------------------
    -- 6. Re-add defaults
    -------------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1
        FROM sys.default_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'DF_self_appraisals_property_declared'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ADD CONSTRAINT DF_self_appraisals_property_declared
        DEFAULT ('No') FOR property_declared;

        PRINT 'Added DF_self_appraisals_property_declared';
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.default_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'DF_self_appraisals_medical_compliance'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ADD CONSTRAINT DF_self_appraisals_medical_compliance
        DEFAULT ('No') FOR medical_compliance;

        PRINT 'Added DF_self_appraisals_medical_compliance';
    END

    -------------------------------------------------------------------------
    -- 7. Re-add check constraints
    -------------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'CK_self_appraisals_property_declared'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ADD CONSTRAINT CK_self_appraisals_property_declared
        CHECK (property_declared IN ('Yes', 'No', 'NA'));

        PRINT 'Added CK_self_appraisals_property_declared';
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'CK_self_appraisals_medical_compliance'
    )
    BEGIN
        ALTER TABLE dbo.self_appraisals
        ADD CONSTRAINT CK_self_appraisals_medical_compliance
        CHECK (medical_compliance IN ('Yes', 'No', 'NA'));

        PRINT 'Added CK_self_appraisals_medical_compliance';
    END

    -------------------------------------------------------------------------
    -- 8. Recreate covering index from migration 11
    -------------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.self_appraisals')
          AND name = 'idx_self_appraisals_acr_cover'
    )
    BEGIN
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

        PRINT 'Recreated idx_self_appraisals_acr_cover';
    END

    COMMIT TRAN;
    PRINT '=== Migration 12 complete successfully ===';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT '=== Migration 12 failed ===';
    PRINT ERROR_MESSAGE();
    THROW;
END CATCH
GO