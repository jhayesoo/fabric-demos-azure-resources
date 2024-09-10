-- DROP PROCEDURE [starschema].[IncrLoadSalesOrders];

CREATE PROC [starschema].[IncrLoadSalesOrders]

@StartDate DATETIME,
@EndDate DATETIME
AS
BEGIN

SET NOCOUNT ON;

DECLARE @UpdateCount INT, @InsertCount INT
-- exec [starschema].[IncrLoadSalesOrders] null, null 

IF @StartDate IS NULL
BEGIN
    SELECT @StartDate = isnull(MAX(LastUpdated),'2013-01-01') 
    FROM [starschema].[SalesOrders]
END;

IF @EndDate IS NULL
BEGIN
    SET @EndDate = '9999-12-31'
END  

UPDATE target
SET target.OrderDate = source.OrderDate,
            target.CustomerID = source.CustomerID,
            target.StockItemID = source.StockItemID,
            target.SalespersonPersonID = source.SalespersonPersonID,
            target.ExtendedPrice = source.ExtendedPrice,
            target.Quantity = source.Quantity,
            target.LastUpdated = source.LastUpdated
FROM [starschema].[SalesOrders] AS target
    INNER JOIN [wwiViews].[SalesOrders] AS source
    ON (target.OrderID = source.OrderID AND target.OrderLineID = source.OrderLineID)
    WHERE source.LastUpdated BETWEEN @StartDate and @EndDate;

SELECT @UpdateCount = @@ROWCOUNT   

INSERT INTO [starschema].[SalesOrders] (OrderID, OrderLineID, OrderDate, CustomerID, StockItemID, SalespersonPersonID, 
            ExtendedPrice, Quantity, LastUpdated)
    SELECT source.OrderID, source.OrderLineID, source.OrderDate, source.CustomerID, source.StockItemID, source.SalespersonPersonID,
            source.ExtendedPrice, source.Quantity, source.LastUpdated
    FROM [wwiViews].[SalesOrders] AS source
    LEFT JOIN [starschema].[SalesOrders] AS target
    ON (target.OrderID = source.OrderID AND target.OrderLineID = source.OrderLineID)
    WHERE target.OrderID IS NULL AND target.OrderLineID IS NULL AND source.LastUpdated BETWEEN @StartDate and @EndDate;

SELECT @InsertCount = @@ROWCOUNT  

SELECT @UpdateCount as UpdateCount, @InsertCount as InsertCount, @StartDate as MaxDate   
END