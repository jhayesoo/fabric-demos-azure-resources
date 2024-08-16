CREATE TABLE [starschema].[InvoicedSales] (

	[InvoiceID] int NULL, 
	[InvoiceLineID] int NULL, 
	[CustomerID] int NULL, 
	[StockItemID] int NULL, 
	[SalespersonPersonID] int NULL, 
	[InvoiceDate] date NULL, 
	[LastUpdated] datetime2(6) NULL, 
	[Quantity] int NULL, 
	[ExtendedPrice] decimal(18,2) NULL, 
	[GrossProfit] decimal(18,2) NULL, 
	[TaxAmount] decimal(18,2) NULL
);

