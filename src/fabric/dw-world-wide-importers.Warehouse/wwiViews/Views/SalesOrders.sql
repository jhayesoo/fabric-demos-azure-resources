CREATE VIEW [wwiViews].[SalesOrders] AS (SELECT     
             O.[OrderID]
            ,[OrderLineID]
            ,[CustomerID]
            ,[StockItemID]
            ,[SalespersonPersonID]
            ,[OrderDate]
            ,[Quantity]
            ,[Quantity] * [UnitPrice] as ExtendedPrice
            ,case when  O.[LastEditedWhen] >= L.[LastEditedWhen] then O.LastEditedWhen else L.[LastEditedWhen] end as LastUpdated
FROM [mirrored_world_wide_importers].[dbo].[Sales_Orders] O
 inner join [mirrored_world_wide_importers].[dbo].[Sales_OrderLines] L
 on O.OrderID = L.OrderID)