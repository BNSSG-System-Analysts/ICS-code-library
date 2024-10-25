SELECT [pcd7]
      ,[pcd8]
      ,p.[oa11cd]
      ,p.[lsoa11cd]
      ,a.[LSOA11_local_name]
      ,a.[2019_Ward_Name]
      ,p.[msoa11cd]
      ,m.[MSOA11CD_LN]
      ,[Locality]
  
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_lookups_Postcode_OA_LSOA] p
  left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_OA_Locality] l on p.[oa11cd] = l.[oa11cd]
  left join [Analyst_SQL_Area].[dbo].[tbl_LSOA_Combined_Metrics] m on p.[lsoa11cd] = m.[lsoa11cd]
  left join [Modelling_SQL_Area].[dbo].[LSOA_Local_Names] a on  p.[lsoa11cd] = a.LSOA_2011

  WHERE m.[Local_Authority] like 'Bristol%' OR
  m.[Local_Authority] like 'North Somerset%' OR
  m.[Local_Authority] like 'South Gloucester%' 
