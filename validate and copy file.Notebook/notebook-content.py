# Fabric notebook source

# METADATA ********************

# META {
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "f98b83cd-7a4e-4be0-bd36-723764c3615a",
# META       "default_lakehouse_name": "analyticsinabox1",
# META       "default_lakehouse_workspace_id": "19c6bfff-2379-4076-82d9-61473192f32e"
# META     }
# META   }
# META }

# PARAMETERS CELL ********************

# Files/landingzone/files
# landingzonepath = 'abfss://landingzone@adlsdatadrivensynapse.dfs.core.windows.net/'
lakehousepath = 'abfss://19c6bfff-2379-4076-82d9-61473192f32e@msit-onelake.dfs.fabric.microsoft.com/f98b83cd-7a4e-4be0-bd36-723764c3615a'
filename = 'customer1.csv'
outputfilename = 'customer1'
metadatafilename = 'customer_meta.csv'
filefolder = 'scenario1-validatecsv/landingzone/files'
metadatafolder = 'scenario1-validatecsv/landingzone/metadata'
outputfolder = 'scenario1-validatecsv/bronze'
fileformat = 'customer'

# CELL ********************

# Import pandas and pyarrow
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

#filename = f'{file}.{filetype}'
print(filename)

# CELL ********************

inputfilepath = f'{lakehousepath}/Files/{filefolder}/'
metadatapath = f'{lakehousepath}/Files/{metadatafolder}/'
outputpath =  f'{lakehousepath}/Files/{outputfolder}/'

# CELL ********************

# Read the text file and the meta data file
print(f'{inputfilepath}{filename}')
data = pd.read_csv(f'{inputfilepath}{filename}')
meta = pd.read_csv(f'{metadatapath}{metadatafilename}')

# only get the column names for the file formattype that was input
meta = meta.loc[meta['formatname'] == fileformat]
print(data.dtypes)
print(meta)


# CELL ********************

print(list(meta['columname']))
print(outputpath)
print(fileformat)

# CELL ********************

keyfields = meta.loc[meta['iskeyfield'] == 1, 'columname'].tolist()
print(keyfields)

# CELL ********************

haserror = 0
# Check if the column names and datatypes match
if list(data.columns) != list(meta["columname"]):
    # Issue an error
    result = "Error: Column names do not match."
    haserror = 1
else:
    if list(data.dtypes) != list(meta["datatype"]):
        # Issue an error
        result = "Error: Datatypes do not match."
        haserror = 1
    else:
        if keyfields != '':
            checkdups = data.groupby(keyfields).size().reset_index(name='count')
            print(checkdups)
            if checkdups['count'].max() > 1:
                dups = checkdups[checkdups['count'] > 1]
                print(dups)
                haserror = 1
                (dups.to_csv(f'{lakehousepath}/Files/processed/error_duplicate_key_values/duplicaterecords_{filename}',
                mode='w',index=False))
                result = 'Error: Duplicate key values'

if haserror == 0:       
   # Write the data to parquet
   # print(inputfilepath)
    print(filename)
    df = spark.read.csv(f"{inputfilepath}{filename}", header=True, inferSchema=True)
    print(f'File is: {inputfilepath}{filename}')
    display(df)
    df.write.mode("overwrite").format("parquet").save(f"{outputpath}{outputfilename}")
    result = f"Data written to parquet successfully. Key fields are:{keyfields} "

mssparkutils.notebook.exit(str(result))
