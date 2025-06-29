/* 
Creating staging table to load data into from csv before adding it to dimensions and facts
*/

USE LUCIDEX;
GO

SELECT * INTO [ETL].[dim_custom_mapping_staging]
FROM [ETL].[dim_custom_mapping] WHERE 1=0;

GO

SELECT * INTO [ETL].[dim_customer_type_staging]
FROM [ETL].[dim_customer_type] WHERE 1=0;

GO

SELECT * INTO [ETL].[dim_product_category_staging]
FROM [ETL].[dim_product_category] WHERE 1=0;

GO

SELECT * INTO [ETL].[dim_store_region_staging]
FROM [ETL].[dim_store_region] WHERE 1=0;

GO

SELECT * INTO [ETL].[fact_transactions_staging]
FROM [ETL].[fact_transactions] WHERE 1=0;