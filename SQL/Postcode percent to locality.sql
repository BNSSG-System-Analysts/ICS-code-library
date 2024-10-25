  --No postcode to locality lookups available.  Will omit anyone with an LSOA that falls outside the BNSSG boundary so that people who are registered in BNSSG but whos registered address is anywhere in the UK.
-- Postcodes that fall within BNSSG are still retained and allocated on size to locality.  E.g BS14 has 1977 people registered but not resident, Postcode is still assigned to South Bristol.  BS27 and BS28 are not BNSSG postcodes and are alinged with Somerset ICB, all are registered and not resident.  BS39 is BANES

  With cte_base as (
  SELECT count(*) as people,
  rtrim(b.postcode_area) as postcode_area,
  b.Local_Authority_District,
  d.[Locality_Name],
  a.[lsoa],
  e.[Local_Authority]
       
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS] a --to find reg pop by postcode key
  left join [ABI].[dbo].[tbl_BNSSG_Postcode_pseudo] b on a.Pseudo_postcode = b.AIMTC_Postcode_Key --to get postcode sector from postcode key
  left join [Analyst_SQL_Area].[dbo].[LSOA_Locality] d on a.[lsoa] = d.[LSOA_Code] --lsoa from population to locality of address.  
  left join [dbo].[tbl_LSOA_Combined_Metrics] e on a.lsoa = e.[LSOA11CD]
  where
     [IsLatest_Flag] = 1
  and [IsCurrent_Flag] = 1
  and [CCG_Of_Registration] = '15C'
  and b.postcode_area is not null
  and e.[Local_Authority] in ('Bristol, City of','North Somerset', 'South Gloucestershire')  

  Group by
	  b.postcode_area,
	  b.Local_Authority_District,
	  d.[Locality_Name],
	  a.[lsoa],
	  e.[Local_Authority]
 ),

 cte_pcode as (
	 --Number of people by postcode
select postcode_area,sum(people) as people

from cte_Base 
group by  postcode_area

),

	   --Number of people by postcode and Locality
cte_PCLOC as (
select postcode_area,
	  [Locality_Name],
	  sum(people) as people

from cte_Base 
group by  postcode_area,
	  [Locality_Name]

),

--Calculate percentages and allocate rownumbers ready to produce final table
cte_OP as (

SELECT 
    a.postcode_area,
    a.[Locality_Name],
    a.people as [People_in_PC_Loc],
    b.people as [People_in_PC],
	SUM(CAST(a.people AS DECIMAL(10, 2)) / CAST(b.people AS DECIMAL(10, 2)) * 100) AS [Perc_Loc],
    ROW_NUMBER() OVER (PARTITION BY a.postcode_area ORDER BY ROUND(SUM(CAST(a.people AS DEC(10, 2)) / CAST(b.people AS DEC(10, 2)) * 100), 1) DESC) AS rn

FROM 
    cte_PCLOC a
LEFT JOIN 
    cte_Pcode b 
ON 
    a.postcode_area = b.postcode_area
GROUP BY 
    a.postcode_area,
    a.[Locality_Name],
    a.people,
    b.people


)

--Final table
SELECT 
    Postcode_area,
    MAX(CASE WHEN rn = 1 THEN [Locality_Name] ELSE NULL END) AS Locality_1,
    MAX(CASE WHEN rn = 1 THEN [People_in_PC_Loc] ELSE NULL END) AS [People_in_Postcode and Locality_1],
    MAX(CASE WHEN rn = 1 THEN [People_in_PC] ELSE NULL END) AS [People_in_Postcode_1],
    ROUND(MAX(CASE WHEN rn = 1 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage_in_Postcode and Locality_1],

    MAX(CASE WHEN rn = 2 THEN [Locality_Name] ELSE NULL END) AS Locality_2,
    MAX(CASE WHEN rn = 2 THEN [People_in_PC_Loc] ELSE NULL END) AS [People_in_Postcode and Locality_2],
    MAX(CASE WHEN rn = 2 THEN [People_in_PC] ELSE NULL END) AS [People_in_PostcodeC_2],
    ROUND(MAX(CASE WHEN rn = 2 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage_in_Postcode and Locality_2],
    
    MAX(CASE WHEN rn = 3 THEN [Locality_Name] ELSE NULL END) AS Locality_3,
    MAX(CASE WHEN rn = 3 THEN [People_in_PC_Loc] ELSE NULL END) AS [People_in_Postcode and Locality_3],
    MAX(CASE WHEN rn = 3 THEN [People_in_PC] ELSE NULL END) AS [People_in_Postcode_3],
    ROUND(MAX(CASE WHEN rn = 3 THEN [Perc_Loc] ELSE NULL END),2) AS [Percentage_in_Postcode and Locality_3]
FROM 
    cte_OP
GROUP BY 
    postcode_area
ORDER BY 
    postcode_area;