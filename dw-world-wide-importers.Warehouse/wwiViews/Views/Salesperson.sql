CREATE VIEW [wwiViews].[Salesperson] AS (SELECT [PersonID], [FullName]        
FROM [mirrored_world_wide_importers].[dbo].[Application_People]
WHERE [IsSalesperson] = 1)