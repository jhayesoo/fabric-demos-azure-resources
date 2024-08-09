DROP TABLE IF EXISTS [metadata].[MirroredWWItoDW]

GO

CREATE TABLE [metadata].[MirroredWWItoDW](
	[pipelinename] [varchar](100) NOT NULL,
	[sourceschema] [varchar](50) NOT NULL,
	[sourcetable] [varchar](50) NOT NULL,
	[sourcestartdate] [datetime2](6) NULL,
	[sourceenddate] [datetime2](6) NULL,
	[sinkschema] [varchar](100) NULL,
	[sinktable] [varchar](100) NULL,
	[loadtype] [varchar](15) NOT NULL,
	[storedprocschema] [varchar](50) NULL,
	[storedprocname] [varchar](50) NULL,
	[skipload] [bit] NOT NULL,
	[batchloaddatetime] [datetime2](6) NULL,
	[loadstatus] [varchar](15) NULL,
	[rowsupdated] [int] NULL,
	[rowsinserted] [int] NULL,
	[sinkmaxdatetime] [datetime2](6) NULL,
	[pipelinestarttime] [datetime2](6) NULL,
	[pipelineendtime] [datetime2](6) NULL
) 

GO

INSERT INTO [metadata].[MirroredWWItoDW]
([pipelinename], [sourceschema], [sourcetable], [sinkschema], [sinktable], [loadtype], [storedprocschema], [storedprocname], [skipload])
SELECT
'orchestrator Load WWI to DW','wwiViews','vCustomerDeliveredTo','Gold','Customer','full',NULL,NULL,0
UNION SELECT
'orchestrator Load WWI to DW','wwiViews','vInvoicedSales','Gold','InvoicedSales','incremental','Gold','IncrLoadInvoicedSales',0
UNION SELECT
'orchestrator Load WWI to DW','wwiViews','vProducts','Gold','Products','full',NULL,NULL,0
UNION SELECT
'orchestrator Load WWI to DW','wwiViews','vSalesperson','Gold','Salesperson','full',NULL,NULL,0
UNION SELECT
'orchestrator Load WWI to DW','wwiViews','vCalendar','Gold','Calendar','full',NULL,NULL,0
UNION SELECT
'orchestrator Load WWI to DW','wwiViews','vSalesOrders','Gold','SalesOrders','incremental','Gold','IncrLoadSalesOrders',0

