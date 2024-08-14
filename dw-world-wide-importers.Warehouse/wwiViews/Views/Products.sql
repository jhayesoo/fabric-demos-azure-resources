CREATE VIEW [wwiViews].[Products] AS (SELECT       isnull( [Brand],'No Brand') as Brand
            ,[ColorName]
            ,[LeadTimeDays]
            ,[StockItemID]
            ,[StockItemName]
            ,S.[SupplierID]
            ,[SupplierName]
FROM [mirrored_world_wide_importers].[dbo].[Warehouse_StockItems] P
inner join [mirrored_world_wide_importers].[dbo].[Purchasing_Suppliers] S 
on S.SupplierID = P.SupplierID
inner join [mirrored_world_wide_importers].[dbo].[Warehouse_Colors] C
on P.ColorID = C.ColorID)