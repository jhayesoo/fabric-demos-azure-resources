# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "f98b83cd-7a4e-4be0-bd36-723764c3615a",
# META       "default_lakehouse_name": "analyticsinabox1",
# META       "default_lakehouse_workspace_id": "19c6bfff-2379-4076-82d9-61473192f32e"
# META     },
# META     "environment": {
# META       "environmentId": "6a8408ff-0ea3-4d99-aeaf-3cab3e02cdd0",
# META       "workspaceId": "19c6bfff-2379-4076-82d9-61473192f32e"
# META     }
# META   }
# META }

# MARKDOWN ********************

# ##### **Step 1 - Load Data from Taxi Data to create a Delta Table with 6.5 Billion Rows**
# 
# Here's more on loading the Taxi Data : https://learn.microsoft.com/en-us/azure/open-datasets/dataset-taxi-yellow?tabs=pyspark#azure-databricks

# PARAMETERS CELL ********************

# NYC Taxi Data info
blob_account_name = "azureopendatastorage"
blob_container_name = "nyctlc"
blob_relative_path = "yellow"
blob_sas_token = "r"

# Fabric parameters

delta_path = 'abfss://19c6bfff-2379-4076-82d9-61473192f32e@msit-onelake.dfs.fabric.microsoft.com/f98b83cd-7a4e-4be0-bd36-723764c3615a/Tables'

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, concat,add_months, expr
from pyspark.sql import SparkSession

import delta
from delta import *

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Allow SPARK to read from Blob remotely
wasbs_path = 'wasbs://%s@%s.blob.core.windows.net/%s' % (blob_container_name, blob_account_name, blob_relative_path)
spark.conf.set(
  'fs.azure.sas.%s.%s.blob.core.windows.net' % (blob_container_name, blob_account_name),
  blob_sas_token)
print('Remote blob path: ' + wasbs_path)

# SPARK read parquet, note that it won't load any data yet by now
df = spark.read.parquet(wasbs_path)
print('Register the DataFrame as a SQL temporary view: source')
df.createOrReplaceTempView('source')

# Display top 10 rows
print('Displaying top 10 rows: ')
display(spark.sql('SELECT * FROM source LIMIT 10'))


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# get count of records

display(spark.sql('SELECT COUNT(*) FROM source'))

# 1,571,671,152


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# only project certain columns and change longitude and latitude columns to string

df = df.select(
    col('vendorID'),
    col('tpepPickupDateTime'),
    col('tpepDropoffDateTime'),
    col('startLon').cast('string').alias('startLongitude'),
    col('startLat').cast('string').alias('startLatitude'),
    col('endLon').cast('string').alias('endLongitude'),
    col('endLat').cast('string').alias('endLatitude'),
    col('paymentType'),
    col('puYear'),
    col('puMonth')
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

table_name = f'{delta_path}/Tables/taxitrips'

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# write the first 1.5 billion records
df.write.format("delta").mode("overwrite").save(table_name)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

for x in range(3):
 # add another year to the dataframe data fields and write another 1.5 billion records and 3 times
  df = df.withColumn("tpepPickupDateTime", expr("tpepPickupDateTime + interval 1 year"))
  df = df.withColumn("tpepDropoffDateTime", expr("tpepDropoffDateTime + interval 1 year"))
  df = df.withColumn("puYear", col("puYear") + 1)
  df.write.format("delta").mode("append").save(table_name)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ##### **Step 2 - Optimize the Taxi data table**

# CELL ********************

delta_table = DeltaTable.forPath(spark, table_name)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

(delta_table
 .optimize()
 .executeCompaction()
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

(
    delta_table
    .optimize()
    .executeZOrderBy("puYear", "puMonth")
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ##### **Step 3** - Create Dimension tables
# Create dimension over columns we will want to filter on in our report, vendorID, puYear and puMonth

# CELL ********************

# read from Delta table to get all 6b rows
df = spark.read.format("delta").load(table_name)
print(df.count())


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# create vendor table
dimdf = df.select("vendorid").distinct()
dimdf.sort(dimdf.vendorid.asc())
dimdf.write.format("delta").mode("overwrite").save(f'{delta_path}/vendors')

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# create year table
dimdf = df.select("puYear").distinct()
dimdf.sort(dimdf.puYear.asc())
dimdf.write.format("delta").mode("overwrite").save(f'{delta_path}/years')

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# create month table
dimdf = df.select("puMonth").distinct()
dimdf.sort(dimdf.puMonth.asc())
dimdf.write.format("delta").mode("overwrite").save(f'{delta_path}/months')

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
