CREATE VIEW [wwiViews].[InvoicedSales] AS (SELECT       I.[InvoiceID]
            ,[InvoiceLineID]
            ,[CustomerID]
            ,[StockItemID]
            ,[SalespersonPersonID]
            ,[InvoiceDate]
            , Case when I.[LastEditedWhen] > L.LastEditedWhen then I.LastEditedWhen else L.LastEditedWhen end as LastUpdated
            ,[Quantity]
            ,[ExtendedPrice]
            ,[LineProfit] as GrossProfit
            ,[TaxAmount]
FROM [mirrored_world_wide_importers].[dbo].[Sales_Invoices] I 
inner join [mirrored_world_wide_importers].[dbo].[Sales_InvoiceLines] L
on I.InvoiceID = L.InvoiceID)