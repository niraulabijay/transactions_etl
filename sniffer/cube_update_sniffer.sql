USE LUCIDEX;
GO

CREATE SCHEMA ETL;
GO

-- DROP TABLE [ETL].cube_tracker;
CREATE TABLE [ETL].cube_tracker (
	ModelName VARCHAR(100),
	LastUpdateDate DATETIME,
	LastRefreshDate DATETIME DEFAULT('1901-01-01')
);
SELECT * FROM ETL.cube_tracker;

GO


-- Stored procedure to update last update date in cube_tracker table.
CREATE OR ALTER PROC ETL.sp_DetectCubeTableUpdate (@ModelName Varchar(100))
AS
BEGIN
	UPDATE [LUCIDEX].[ETL].[cube_tracker] SET
		LastUpdateDate = getDate()
	WHERE ModelName = @ModelName;
	IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO [LUCIDEX].[ETL].[cube_tracker] (ModelName, LastUpdateDate)
        VALUES ('TransactionModel', GETDATE())      
    END
END


GO
-----------------------------------------------------------------------------------
/*
* Create triggers to update cube_tracker table.
*/

-- DROP TRIGGER ETL.trig_dim_product_category
CREATE TRIGGER ETL.trig_dim_product_category ON ETL.dim_product_category
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	EXEC [LUCIDEX].[ETL].sp_DetectCubeTableUpdate @ModelName='TransactionModel';
END

GO

CREATE TRIGGER ETL.trig_fact_transactions ON ETL.fact_transactions
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	EXEC [LUCIDEX].[ETL].sp_DetectCubeTableUpdate @ModelName='TransactionModel';
END


------------------------------------------------------------------------------------

/*
Test Query to use in sniffer job
*/

-- STEP 1:
DECLARE @lastUpdateDate DATETIME = (SELECT LastUpdateDate FROM [LUCIDEX].[ETL].cube_tracker); 
DECLARE @lastrefreshDate DATETIME = (SELECT LastRefreshDate FROM [LUCIDEX].[ETL].cube_tracker); 

IF @lastUpdateDate > @lastrefreshDate
BEGIN
	PRINT 'Data was updated. Proceed with tableau update'
END
ELSE
BEGIN
	RAISERROR('No update',16,1);
END
GO

-- STEP 2, run job to refresh model

EXEC msdb.dbo.sp_start_job N'transaction_tabular_model_update'
GO

-- STEP 3: update the refresh date

UPDATE [LUCIDEX].[ETL].[cube_tracker] 
	SET LastRefreshDate = GETDATE()
	WHERE ModelName = 'TransactionModel'

-- SELECT * FROM ETL.cube_tracker;