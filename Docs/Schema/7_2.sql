USE [ACRPortal]
GO

-- =============================================================================
-- Migration 7 Fix: Drop default constraint on property_return_done
-- before dropping the column.
--
-- The column [property_return_done] BIT NOT NULL DEFAULT 0 was created with
-- an auto-named default constraint (DF__acr_cycle__prope__...). SQL Server
-- will not let you drop a column that has a constraint attached — the
-- constraint must be dropped first.
--
-- This script finds the constraint name dynamically so it works regardless
-- of the auto-generated suffix on the constraint name.
-- =============================================================================

DECLARE @constraintName NVARCHAR(256);

SELECT @constraintName = dc.name
FROM   sys.default_constraints dc
JOIN   sys.columns c
       ON  dc.parent_object_id = c.object_id
       AND dc.parent_column_id = c.column_id
WHERE  c.object_id = OBJECT_ID('dbo.acr_cycles')
  AND  c.name      = 'property_return_done';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.acr_cycles DROP CONSTRAINT ' + @constraintName);
    PRINT 'Dropped default constraint: ' + @constraintName;
END
GO

-- Now the column can be dropped safely
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE  object_id = OBJECT_ID('dbo.acr_cycles')
      AND  name      = 'property_return_done'
)
BEGIN
    ALTER TABLE dbo.acr_cycles DROP COLUMN property_return_done;
    PRINT 'Dropped column property_return_done.';
END
GO

PRINT 'Migration 7 fix complete.';
GO
