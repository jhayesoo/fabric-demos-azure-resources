CREATE TABLE [starschema].[Customer] (

	[YearsCustomer] int NULL, 
	[BuyingGroupID] int NULL, 
	[BuyingGroupName] varchar(8000) NULL, 
	[CreditLimit] decimal(18,2) NULL, 
	[CustomerCategoryID] int NULL, 
	[CustomerID] int NULL, 
	[CustomerName] varchar(8000) NULL, 
	[DeliveryCityID] int NULL, 
	[DeliveryCity] varchar(8000) NULL, 
	[DeliveryStateProvince] varchar(8000) NULL, 
	[DeliveryCountry] varchar(8000) NULL, 
	[Region] varchar(8000) NULL, 
	[Subregion] varchar(8000) NULL, 
	[Continent] varchar(8000) NULL, 
	[SalesTerritory] varchar(8000) NULL, 
	[DeliveryPostalCode] varchar(8000) NULL, 
	[IsOnCreditHold] bit NULL, 
	[PaymentDays] int NULL, 
	[AreaCode] varchar(24) NULL
);

