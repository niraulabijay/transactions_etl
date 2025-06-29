USE LUCIDEX;
BEGIN TRANSACTION;

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

	-- SELECT * FROM ETL.dim_product_category
	-- TRUNCATE TABLE ETL.dim_product_category

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
END CATCH

GO

SELECT * FROM ETL.fact_transactions