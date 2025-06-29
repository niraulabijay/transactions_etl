#Full ETL for transactions:

1. Transform raw csv data into clean dimensions and facts using Pyspark.
2. Export dataframes from pyspark into csv.
3. Import csv to SQL server using SQL server Jobs.
4. Create tableau model using Tableau Editor.
5. Deploy model into SSAS, and automate refresh using Job Agent.
6. Create sniffer to detect changes in fact/dimension and trigger refresh in SSAS database.
7. Utilize power BI to create meaningful analytics.