-- Increase designation description length to avoid truncation while saving
-- longer descriptions from the Designation Master screen.

ALTER TABLE dbo.tbDsg
ALTER COLUMN dsgDesc VARCHAR(200) NULL;
