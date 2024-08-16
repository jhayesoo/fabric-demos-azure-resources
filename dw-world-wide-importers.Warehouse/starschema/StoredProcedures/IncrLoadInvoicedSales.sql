-- DROP PROCEDURE [starschema].[IncrLoadInvoicedSales];

CREATE PROC [starschema].[IncrLoadInvoicedSales]
@StartDate DATETIME,
@EndDate DATETIME
AS
BEGIN

SET NOCOUNT ON;

DECLARE @UpdateCount INT, @InsertCount INT
-- exec [starschema].[IncrLoadInvoicedSales] null, null 

IF @StartDate IS NULL
BEGIN
    SELECT @StartDate = isnull(MAX(LastUpdated),'2013-01-01') 
    FROM [starschema].[InvoicedSales]
END;

IF @EndDate IS NULL
BEGIN
    SET @EndDate = '9999-12-31'
END    

UPDATE target
SET target.InvoiceDate = source.InvoiceDate,
            target.CustomerID = source.CustomerID,
            target.StockItemID = source.StockItemID,
            target.SalespersonPersonID = source.SalespersonPersonID,
            target.ExtendedPrice = source.ExtendedPrice,
            target.Quantity = source.Quantity,
            target.GrossProfit = source.GrossProfit,
            target.TaxAmount = source.TaxAmount,
            target.LastUpdated = source.LastUpdated
FROM [starschema].[InvoicedSales] AS target
    INNER JOIN [wwiViews].[InvoicedSales] AS source
    ON (target.InvoiceID = source.InvoiceID AND target.InvoiceLineID = source.InvoiceLineID)
    WHERE source.LastUpdated BETWEEN @StartDate and @EndDate;

 SELECT @UpdateCount = @@ROWCOUNT   

INSERT INTO [starschema].[InvoicedSales] (InvoiceID, InvoiceLineID, InvoiceDate, CustomerID, StockItemID, SalespersonPersonID, 
            ExtendedPrice, Quantity,GrossProfit,TaxAmount, LastUpdated)
    SELECT source.InvoiceID, source.InvoiceLineID, source.InvoiceDate, source.CustomerID, source.StockItemID, source.SalespersonPersonID,
            source.ExtendedPrice, source.Quantity, source.GrossProfit, source.TaxAmount,source.LastUpdated
    FROM [wwiViews].[InvoicedSales] AS source
    LEFT JOIN [starschema].[InvoicedSales] AS target
    ON (target.InvoiceID = source.InvoiceID AND target.InvoiceLineID = source.InvoiceLineID)
    WHERE target.InvoiceID IS NULL AND target.InvoiceLineID IS NULL AND source.LastUpdated  BETWEEN @StartDate and @EndDate


SELECT @InsertCount = @@ROWCOUNT  

SELECT @UpdateCount as UpdateCount, @InsertCount as InsertCount, @StartDate as MaxDate   

END