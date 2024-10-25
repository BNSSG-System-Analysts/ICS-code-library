
-- you can use the R script "wider_determinants.R" in the Library to make a summary table from this data
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
   order by pds.[Pseudo_NHS_Number] 
