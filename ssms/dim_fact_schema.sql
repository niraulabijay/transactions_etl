USE LUCIDEX;
GO
CREATE SCHEMA ETL;
GO

CREATE TABLE ETL.dim_product_category(
	ProductCategory VARCHAR(100),
	CategoryGroup VARCHAR(100),
	ProductCategoryKey INT NOT NULL PRIMARY KEY
);

GO

CREATE TABLE ETL.dim_store_region(
	StoreRegion VARCHAR(100),
	Territory VARCHAR(100),
	StoreRegionKey INT NOT NULL PRIMARY KEY
);

GO

CREATE TABLE ETL.dim_customer_type(
	CustomerType VARCHAR(100),
	Segment VARCHAR(100),
	CustomerTypeKey INT NOT NULL PRIMARY KEY
);

GO

-- DROP TABLE ETL.dim_customer_mapping

CREATE TABLE ETL.dim_custom_mapping(
	ProductCategory VARCHAR(100),
	StoreRegion VARCHAR(100),
	CustomerType VARCHAR(100),
	MappingLabel VARCHAR(100),
	[Priority] INT,
	CustomMappingKey INT NOT NULL PRIMARY KEY
);

GO

CREATE TABLE ETL.fact_transactions(
	TransactionID INT,
	Amount INT,
	ProductCategoryKey INT FOREIGN KEY REFERENCES ETL.dim_product_category(ProductCategoryKey),
	StoreRegionKey INT FOREIGN KEY REFERENCES ETL.dim_store_region(StoreRegionKey),
	CustomerTypeKey INT FOREIGN KEY REFERENCES ETL.dim_customer_type(CustomerTypeKey),
	CustomMappingKey INT FOREIGN KEY REFERENCES ETL.dim_custom_mapping(CustomMappingKey)
);