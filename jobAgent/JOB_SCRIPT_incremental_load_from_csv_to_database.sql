USE [msdb]
GO

/****** Object:  Job [load_transaction_data_from_csv]    Script Date: 6/28/2025 5:16:04 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/28/2025 5:16:04 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'load_transaction_data_from_csv', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'Bizzay\nirau', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [load_dimensions_facts_into_staging]    Script Date: 6/28/2025 5:16:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'load_dimensions_facts_into_staging', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'TRUNCATE TABLE [LUCIDEX].[ETL].[dim_product_category_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_product_category_staging]
FROM ''C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_product_category.csv''
WITH (
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''\n'',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_customer_type_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_customer_type_staging]
FROM ''C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_customer_type.csv''
WITH (
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''\n'',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_store_region_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_store_region_staging]
FROM ''C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_store_region.csv''
WITH (
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''\n'',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_custom_mapping_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_custom_mapping_staging]
FROM ''C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_custom_mapping.csv''
WITH (
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''\n'',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[fact_transactions_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[fact_transactions_staging]
FROM ''C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\fact_transactions.csv''
WITH (
    FIELDTERMINATOR = '','',
    ROWTERMINATOR = ''\n'',
    FIRSTROW = 2
);
GO', 
		@database_name=N'LUCIDEX', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [load_staging_to_dimensions_facts]    Script Date: 6/28/2025 5:16:04 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'load_staging_to_dimensions_facts', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BEGIN TRANSACTION;

BEGIN TRY
	-- merge product category
    MERGE [ETL].[dim_product_category] AS target
    USING [ETL].[dim_product_category_staging] AS source
    ON target.ProductCategoryKey = source.ProductCategoryKey
    WHEN MATCHED
		THEN UPDATE SET
        target.ProductCategory = source.ProductCategory,
		target.CategoryGroup = source.CategoryGroup
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (ProductCategory, CategoryGroup, ProductCategoryKey)
        VALUES (source.ProductCategory, source.CategoryGroup, source.ProductCategoryKey);

	-- merge customer type
    MERGE [ETL].[dim_customer_type] AS target
    USING [ETL].[dim_customer_type_staging] AS source
    ON target.CustomerTypeKey = source.CustomerTypeKey
    WHEN MATCHED
		THEN UPDATE SET
        target.CustomerType = source.CustomerType,
		target.Segment = source.Segment
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (CustomerType, Segment, CustomerTypeKey)
        VALUES (source.CustomerType, source.Segment, source.CustomerTypeKey);

	-- merge store region
    MERGE [ETL].[dim_store_region] AS target
    USING [ETL].[dim_store_region_staging] AS source
    ON target.StoreRegionKey = source.StoreRegionKey
    WHEN MATCHED
		THEN UPDATE SET
        target.StoreRegion = source.StoreRegion,
		target.Territory = source.Territory
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (StoreRegion, Territory, StoreRegionKey)
        VALUES (source.StoreRegion, source.Territory, source.StoreRegionKey);

	-- merge custom mapping
    MERGE [ETL].[dim_custom_mapping] AS target
    USING [ETL].[dim_custom_mapping_staging] AS source
    ON target.CustomMappingKey = source.CustomMappingKey
    WHEN MATCHED
		THEN UPDATE SET
        target.ProductCategory = source.ProductCategory,
		target.StoreRegion = source.StoreRegion,
		target.CustomerType = source.CustomerType,
		target.MappingLabel = source.MappingLabel,
		target.[Priority] = source.[Priority]
    WHEN NOT MATCHED BY TARGET
        THEN INSERT (ProductCategory, StoreRegion, CustomerType, MappingLabel, [Priority], CustomMappingKey)
        VALUES (source.ProductCategory, source.StoreRegion, source.CustomerType, source.MappingLabel,source.[Priority], source.CustomMappingKey);
    
	--merge fact data
	MERGE [ETL].[fact_transactions] as target
	USING [ETL].[fact_transactions_staging] as source
	ON target.TransactionID = source.TransactionID AND
	   target.ProductCategoryKey = source.ProductCategoryKey AND
	   target.StoreRegionKey = source.StoreRegionKey AND
	   target.CustomerTypeKey = source.CustomerTypeKey
	WHEN MATCHED
		THEN UPDATE SET
			target.Amount = source.Amount,
			target.CustomMappingKey = source.CustomMappingKey
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (TransactionID, Amount, ProductCategoryKey, StoreRegionKey, CustomerTypeKey, CustomMappingKey)
		VALUES (source.TransactionID, source.Amount, source.ProductCategoryKey, source.StoreRegionKey, source.CustomerTypeKey, source.CustomMappingKey);
		

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH', 
		@database_name=N'LUCIDEX', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


