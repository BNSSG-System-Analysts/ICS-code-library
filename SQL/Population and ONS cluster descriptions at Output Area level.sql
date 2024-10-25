

SELECT
       case when (CONVERT(int,CONVERT(char(8),cast('2023-06-01' as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000  >= 95 then '95+' 
		else [Analyst_SQL_Area].[dbo].[fn_BNSSG_Age_5yr] ((CONVERT(int,CONVERT(char(8),cast('2023-06-01' as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000) end AS [Age_group]
      ,N.[LSOA11NM]
	  ,N.[LSOA11_local_name]
	  ,M.[IMD_Decile_19]
	  ,[Supergroup Name]
	  ,[Group Name]
	  ,[Subgroup Name]
	  ,COUNT (*) AS People
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS] PDS
	
	  LEFT JOIN [mODELLING_SQL_Area].[dbo].[LSOA_Local_Names] N ON PDS.LSOA=N.[LSOA_2011]
	  LEFT JOIN [Analyst_SQL_Area].[dbo].[tbl_BNSSG_LSOA_Combined_Metrics] M ON PDS.lsoa=M.[LSOA11CD]
	  LEFT JOIN ABI.[Lard].[vw_Postcode_PSD_Lookup] psd on pds.[Pseudo_Postcode] = psd.[AIMTC_Postcode_Key]
	  LEFT Join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_OacClustersAndNames] c on psd.[Output_Area_At_2011] = c.[Output Area Code]
  WHERE 
	  [IsCurrent_Flag] = 1 
	  and [IsLatest_Flag] = 1
	  and [CCG_Of_Registration] = '15C'

  GROUP BY 
	  case when (CONVERT(int,CONVERT(char(8),cast('2023-06-01' as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000  >= 95 then '95+' 
		else [Analyst_SQL_Area].[dbo].[fn_BNSSG_Age_5yr] ((CONVERT(int,CONVERT(char(8),cast('2023-06-01' as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000) end 
      ,N.[LSOA11NM]
	  ,N.[LSOA11_local_name]
	  ,M.[IMD_Decile_19]
	  ,[Supergroup Name]
	  ,[Group Name]
	  ,[Subgroup Name]

--short version for use with SWD at a point in time:
SELECT [Pseudo_NHS_Number]
	  ,[Supergroup Name]
	  ,[Group Name]
	  ,[Subgroup Name]

  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS] PDS
	  LEFT JOIN ABI.[Lard].[vw_Postcode_PSD_Lookup] psd on pds.[Pseudo_Postcode] = psd.[AIMTC_Postcode_Key]
	  LEFT Join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_OacClustersAndNames] c on psd.[Output_Area_At_2011] = c.[Output Area Code]
  WHERE --[IsLatest_Flag] = 1
   pds.[start_date] <= '2024-01-01' and (pds.[end_date] > '2024-01-01' or pds.[end_date] is NULL)
   and [CCG_Of_Registration] = '15C'
