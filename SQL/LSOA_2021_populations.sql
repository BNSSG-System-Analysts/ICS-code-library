SELECT 
  a.*
  ,
  b.[LSOA_2021]
 
FROM [Analyst_SQL_Area].[dbo].tbl_BNSSG_Datasets_Combined_PDS a
LEFT JOIN [ABI].[dbo].[tbl_BNSSG_Postcode_pseudo] b on a.Pseudo_Postcode = b.[AIMTC_Postcode_Key]

where IsCurrent_Flag = 1

--another possibly useful table is [Analyst_SQL_Area].dbo.[LSOA11CD_LSOA21CD_Mapping]