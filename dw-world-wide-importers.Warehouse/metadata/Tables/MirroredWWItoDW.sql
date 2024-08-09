CREATE TABLE [metadata].[MirroredWWItoDW] (

	[pipelinename] varchar(100) NOT NULL, 
	[sourceschema] varchar(50) NOT NULL, 
	[sourcetable] varchar(50) NOT NULL, 
	[sourcestartdate] datetime2(6) NULL, 
	[sourceenddate] datetime2(6) NULL, 
	[sinkschema] varchar(100) NULL, 
	[sinktable] varchar(100) NULL, 
	[loadtype] varchar(15) NOT NULL, 
	[storedprocschema] varchar(50) NULL, 
	[storedprocname] varchar(50) NULL, 
	[skipload] bit NOT NULL, 
	[batchloaddatetime] datetime2(6) NULL, 
	[loadstatus] varchar(15) NULL, 
	[rowsupdated] int NULL, 
	[rowsinserted] int NULL, 
	[sinkmaxdatetime] datetime2(6) NULL, 
	[pipelinestarttime] datetime2(6) NULL, 
	[pipelineendtime] datetime2(6) NULL
);

