left join  [Analyst_SQL_Area].[dbo].tbl_BNSSG_Datasets_Combined_PDS  p
on ed.nhs_number = p.[Pseudo_NHS_Number] and  (p.start_date <= [Arrival_Date] and (p.end_date>= [Arrival_Date] or p.end_date is NULL))

--AS advice is not to go too far back because when the source switched from NHAIS to PDS the data wasn’t great for a while.  
--The total numbers are ok but the start and end dates were not complete.  
--AS has been using population from mid-2022 and her checks found the numbers matched pretty well, not sure about before 2022.  