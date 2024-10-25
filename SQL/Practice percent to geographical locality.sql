--Omits anyone without an LSOA in PDS (main population source from NHS E)
-- Recodes any LSOA outside of BNSSG as Out of Area (LSOA of residence)
--Removed small numbers (<5) and removed Henbury and Southmead as the practice has technically closed

With cte_base as (
  SELECT count(*) as people,
  g.[Merged_Practice_Code],
  g.[local_practice_name],
  case when d.[Locality_Name] is null then 'Out of Area' else d.[Locality_Name] end as [Geog_Locality_Name],
  a.[lsoa],
  e.[Local_Authority]
   
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS] a --to find reg pop by postcode key
  left join [Analyst_SQL_Area].[dbo].[LSOA_Locality] d on a.[lsoa] = d.[LSOA_Code] --lsoa from population to locality of address.  
  left join [Analyst_SQL_Area].[dbo].[tbl_LSOA_Combined_Metrics] e on a.lsoa = e.[LSOA11CD]
  left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] g on a.gp_practice_code = g.practice_code
  where
     [IsLatest_Flag] = 1
  and [IsCurrent_Flag] = 1
  and [CCG_Of_Registration] = '15C'
  and a.[lsoa] is not null
 
  Group by
	  g.[Merged_Practice_Code],
  g.[local_practice_name],
  case when d.[Locality_Name] is null then 'Out of Area' else d.[Locality_Name] end ,
  a.[lsoa],
  e.[Local_Authority]
 ),

cte_lcode as (
	 --Number of people by [Geog_Locality_Name]
select [Merged_Practice_Code],sum(people) as people
from cte_Base 
group by  [Merged_Practice_Code]

),

	   --Number of people by practice and Locality
cte_PCLOC as (
select [Merged_Practice_Code],
	  [local_practice_name],
	  [Geog_Locality_Name],
	  sum(people) as people

from cte_Base 
group by  [Merged_Practice_Code],
	  [local_practice_name],
	  [Geog_Locality_Name]

),

--Calculate percentages and allocate rownumbers ready to produce final table
cte_OP as (

SELECT 
    a.[Merged_Practice_Code],
	a.[local_practice_name],
    a.[Geog_Locality_Name],
    a.people as [People_in_Practice_by_GeogLocality],
    b.people as [People_in_Practice],
	SUM(CAST(a.people AS DECIMAL(10, 2)) / CAST(b.people AS DECIMAL(10, 2)) * 100) AS [Perc_Loc],
    ROW_NUMBER() OVER (PARTITION BY a.[Merged_Practice_Code] ORDER BY CAST(a.people AS DECIMAL(10, 2)) / CAST(b.people AS DECIMAL(10, 2)) * 100 DESC) AS rn

FROM 
    cte_PCLOC a
LEFT JOIN  cte_lcode b ON  a.[Merged_Practice_Code] = b.[Merged_Practice_Code]

left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] g on a.[Merged_Practice_Code] = g.practice_code 
WHERE g.[CloseDate] is null and practice_code <> 'L81067'
GROUP BY 
    a.[Merged_Practice_Code],
	a.[local_practice_name],
    a.[Geog_Locality_Name],
    a.people,
    b.people
)


--Final table
SELECT 
    [Merged_Practice_Code] as [Practice Code],
	[local_practice_name] as [Practice Name],
    MAX(CASE WHEN rn = 1 THEN [Geog_Locality_Name] ELSE NULL END) AS [Locality 1],
    MAX(CASE WHEN rn = 1 THEN [People_in_Practice_by_GeogLocality] ELSE NULL END) AS [People in Practice and Locality 1],
    MAX(CASE WHEN rn = 1 THEN [People_in_Practice] ELSE NULL END) AS [People in Practice_1],
    ROUND(MAX(CASE WHEN rn = 1 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage in Practice and Locality 1],

    MAX(CASE WHEN rn = 2 THEN [Geog_Locality_Name] ELSE NULL END) AS [Locality 2],
    MAX(CASE WHEN rn = 2 THEN [People_in_Practice_by_GeogLocality] ELSE NULL END) AS [People in Practice and Locality 2],
    MAX(CASE WHEN rn = 2 THEN [People_in_Practice] ELSE NULL END) AS [People in Practice 2],
    ROUND(MAX(CASE WHEN rn = 2 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage in Practice and Locality 2],
    
    MAX(CASE WHEN rn = 3 THEN [Geog_Locality_Name] ELSE NULL END) AS [Locality 3],
    MAX(CASE WHEN rn = 3 THEN [People_in_Practice_by_GeogLocality] ELSE NULL END) AS [People in Practice and Locality 3],
    MAX(CASE WHEN rn = 3 THEN [People_in_Practice] ELSE NULL END) AS [People in Practice 3],
    ROUND(MAX(CASE WHEN rn = 3 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage in Practice and Locality 3]
FROM 
    cte_OP
GROUP BY 
    [Merged_Practice_Code],
	[local_practice_name]
ORDER BY 
    [Merged_Practice_Code];