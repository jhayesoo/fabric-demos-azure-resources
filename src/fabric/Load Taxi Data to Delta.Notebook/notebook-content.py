# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# CELL ********************

# ## 1 - Load Taxi Data

# ##### **Step 1 - Load Data from Taxi Data to create a Delta Table with 6.5 Billion Rows**

# NYC Taxi Data info
blob_account_name = "azureopendatastorage"
blob_container_name = "nyctlc"
blob_relative_path = "yellow"
blob_sas_token = "r"

# Fabric parameters

delta_path = 'abfss://19c6bfff-2379-4076-82d9-61473192f32e@msit-onelake.dfs.fabric.microsoft.com/f98b83cd-7a4e-4be0-bd36-723764c3615a/Tables'

from pyspark.sql.functions import col, concat,add_months, expr
from pyspark.sql import SparkSession

import delta
from delta import *

# Allow SPARK to read from Blob remotely
wasbs_path = 'wasbs://%s@%s.blob.core.windows.net/%s' % (blob_container_name, blob_account_name, blob_relative_path)
spark.conf.set(
  'fs.azure.sas.%s.%s.blob.core.windows.net' % (blob_container_name, blob_account_name),
  blob_sas_token)
print('Remote blob path: ' + wasbs_path)

# SPARK read parquet, note that it won't load any data yet by now
df = spark.read.parquet(wasbs_path).limit(10)
print('Register the DataFrame as a SQL temporary view: source')
df.createOrReplaceTempView('source')

# Display top 10 rows
print('Displaying top 10 rows: ')
display(spark.sql('SELECT * FROM source LIMIT 10'))

# get count of records

display(spark.sql('SELECT COUNT(*) FROM source'))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# 1,571,671,152

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
table_name = f'{delta_path}/Tables/taxitrips2'
# write the first 1.5 billion records
df.write.format("delta").mode("overwrite").save(table_name)

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
