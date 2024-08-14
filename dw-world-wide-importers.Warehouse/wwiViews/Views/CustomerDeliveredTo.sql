CREATE VIEW [wwiViews].[CustomerDeliveredTo] AS (SELECT DATEDIFF(yy,[AccountOpenedDate], GETDATE()) as YearsCustomer
             ,C.[BuyingGroupID]
            ,isnull([BuyingGroupName],'Undefined') as BuyingGroupName
            ,[CreditLimit]
            ,[CustomerCategoryID]
            ,[CustomerID]
            ,[CustomerName]
            ,[DeliveryCityID]
            ,[CityName] as DeliveryCity
            ,[StateProvinceName] as DeliveryStateProvince
            ,CountryName as DeliveryCountry
            ,Region
            ,Subregion
            ,Continent
            ,[SalesTerritory]
            ,[DeliveryPostalCode]
            ,[IsOnCreditHold]
            ,[PaymentDays]
            ,SUBSTRING([PhoneNumber],2,3) as AreaCode
FROM [mirrored_world_wide_importers].[dbo].[Sales_Customers] C
left outer join [mirrored_world_wide_importers].[dbo].[Sales_BuyingGroups] BG
on C.BuyingGroupID = BG.BuyingGroupID
inner join [mirrored_world_wide_importers].[dbo].[Application_Cities] CI
on C.DeliveryCityID = CI.[CityID]
inner join [mirrored_world_wide_importers].[dbo].[Application_StateProvinces] S
on CI.StateProvinceID = S.StateProvinceID
inner join [mirrored_world_wide_importers].[dbo].Application_Countries CO 
on S.CountryID = CO.CountryID
)