USE [ACRPortal]
GO



ALTER TABLE [dbo].[tbDsg]
ADD CONSTRAINT UQ_tbDsg_dsgDesc UNIQUE ([dsgDesc]);
