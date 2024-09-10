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
# META     }
# META   }
# META }

# PARAMETERS CELL ********************

lakehousepath = 'abfss://19c6bfff-2379-4076-82d9-61473192f32e@msit-onelake.dfs.fabric.microsoft.com/f98b83cd-7a4e-4be0-bd36-723764c3615a'
inputfolder = 'scenario1-validatecsv/bronze'
filename = 'customer1'
tablename = 'customer'
keyfields = "['number']"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

outputpath = f'{lakehousepath}/Tables/{tablename}'
inputpath = f'{lakehousepath}/Files/{inputfolder}/{filename}'

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from delta.tables import *
from pyspark.sql.functions import *

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

keylist = eval(keyfields)
df2 = spark.read.parquet(inputpath)
# display(df2)
print(keylist)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

if keyfields != None:
    mergekey = ''
    keycount = 0
    for key in keylist:
        mergekey = mergekey + f't.{key} = s.{key} AND '
    mergeKeyExpr = mergekey.rstrip(' AND')
    print(mergeKeyExpr)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# Check if table already exists and table should be upserted as indicated by the merge key, do an upsert and return how many rows were inserted and update; if it does not exist or is a full load, overwrite existing table return how many rows were inserted

# CELL ********************

if DeltaTable.isDeltaTable(spark,outputpath) and mergeKeyExpr is not None:
    deltaTable = DeltaTable.forPath(spark,outputpath)
    deltaTable.alias("t").merge(
        df2.alias("s"),
        mergeKeyExpr
    ).whenMatchedUpdateAll().whenNotMatchedInsertAll().execute()
    history = deltaTable.history(1).select("operationMetrics")
    operationMetrics = history.collect()[0]["operationMetrics"]
    numInserted = operationMetrics["numTargetRowsInserted"]
    numUpdated = operationMetrics["numTargetRowsUpdated"]
else:
    df2.write.format("delta").mode("overwrite").save(outputpath)
    numInserted = df2.count()
    numUpdated = 0
print(numInserted)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

result = "numInserted="+str(numInserted)+  "|numUpdated="+str(numUpdated)
mssparkutils.notebook.exit(str(result))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
