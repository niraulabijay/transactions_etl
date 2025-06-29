USE LUCIDEX;
GO

CREATE OR ALTER VIEW ETL.cube_product_category
AS
SELECT * FROM ETL.dim_product_category

GO
SELECT * FROM ETL.cube_product_category

GO
CREATE OR ALTER VIEW ETL.cube_customer_type
AS
SELECT * FROM ETL.dim_customer_type

GO

CREATE OR ALTER VIEW ETL.cube_store_region
AS
SELECT * FROM ETL.dim_store_region

GO

CREATE OR ALTER VIEW ETL.cube_custom_mapping
AS
SELECT * FROM ETL.dim_custom_mapping

GO
SELECT * FROM ETL.cube_custom_mapping
GO

CREATE OR ALTER VIEW ETL.cube_fact_transactions
AS
SELECT * FROM ETL.fact_transactions

GO
SELECT * FROM ETL.cube_fact_transactions


