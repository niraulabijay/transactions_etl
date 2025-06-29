TRUNCATE TABLE [LUCIDEX].[ETL].[dim_product_category_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_product_category_staging]
FROM 'C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_product_category.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_customer_type_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_customer_type_staging]
FROM 'C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_customer_type.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_store_region_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_store_region_staging]
FROM 'C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_store_region.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[dim_custom_mapping_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[dim_custom_mapping_staging]
FROM 'C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\dim_custom_mapping.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

TRUNCATE TABLE [LUCIDEX].[ETL].[fact_transactions_staging];
GO
BULK INSERT [LUCIDEX].[ETL].[fact_transactions_staging]
FROM 'C:\Users\nirau\Documents\SQL\transactions_etl\pyspark\output_csv\fact_transactions.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO