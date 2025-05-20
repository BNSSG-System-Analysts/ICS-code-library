SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @StartDate as date
SET @StartDate = '20230401' -- activity start 

DECLARE @EndDate as date
SET @EndDate = '20240331' 

DECLARE @dq_start DATETIME
SET @dq_start = '2020-04-01' -- for Sirona data - DO NOT AMEND as data prior to this not ok to use
;

with mpi as (
select distinct nhs_number 
from

(
--ECDS
select nhs_number
from
[Analyst_SQL_AREA].[dbo].[tbl_BNSSG_ECDS]
where  [Postcode] = '2425135' and 
([accommodation_status_desc] IN ('Sleeping in night shelter', 'Homeless', 'Sofa surfer - person of no fixed abode')
or [accommodation_status] IN ('224231004','32911000','381751000000106'))
and [Arrival_Date] between @Startdate and @EndDate
and nhs_number IS NOT NULL

UNION ALL

--APC
select AIMTC_Pseudo_NHS as nhs_number
from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_APC_SPELLS_Standard_Script]
where AIMTC_Postcode_Key = '2425135'
and DischargeDate_FromHospitalProviderSpell between @Startdate and @EndDate
and AIMTC_Pseudo_NHS IS NOT NULL

UNION ALL

--Sirona
select NHS_Number_Key as nhs_number
from Analyst_SQL_Area.dbo.tbl_BNSSG_Datasets_CSDS_Referrals r
left join (Select Main_Code_Text, Main_Description from [UK_Health_Dimensions].[Data_Dictionary].[Service_Or_Team_Type_Referred_To_For_Community_Care_SCD] 
			where Effective_To IS NULL)t
on r.Service_Team_Referred_To_Code = t.Main_Code_Text
left Join  [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] g on r.GP_Practice_Code = g.Practice_Code
left Join  [abi].[Lard].[vw_DateTime_Lookup] dt on Referral_Received_Date = dt.[Date]
where Commissioner_Code = '15C'
and Referral_Received_Date between @StartDate and @EndDate
and  Referral_Received_Date >= @dq_start
and [Service_Agreement_Line_ID] = '16'
and  [NHS_Number_Key] is not null 

UNION ALL

--PDS postcode
SELECT [Pseudo_NHS_Number] as nhs_number
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS]
  where [Pseudo_Postcode] = '2425135'
   and [CCG_Of_Registration] = '15C'
  AND [Start_Date] <= @EndDate and ([End_Date] >= @StartDate or [End_Date] is null)  

  UNION ALL

--PDS practice
SELECT [Pseudo_NHS_Number] as nhs_number
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS]
  where [GP_Practice_Code] = 'Y02873'
  AND [Start_Date] <= @EndDate and ([End_Date] >= @StartDate or [End_Date] is null) 
  
  UNION ALL

--SWD
Select distinct nhs_number
from [MODELLING_SQL_AREA].[dbo].[primary_care_attributes]
where [homeless] IS NOT NULL
and [attribute_period] >= @StartDate
and [attribute_period] <= @EndDate

) a
)

select 
a.NHS_Number as 'ECDS',
b.nhs_number as 'APC',
c.nhs_number as 'Sirona',
d.nhs_number as 'PDS',
e.nhs_number as 'SWD'


from mpi m

left join 
(select distinct nhs_number
from
[Analyst_SQL_AREA].[dbo].[tbl_BNSSG_ECDS]
where  [Postcode] = '2425135' and 
([accommodation_status_desc] IN ('Sleeping in night shelter', 'Homeless', 'Sofa surfer - person of no fixed abode')
or [accommodation_status] IN ('224231004','32911000','381751000000106'))
and [Arrival_Date] between @Startdate and @EndDate
and nhs_number IS NOT NULL) a
on m.NHS_Number = a.NHS_Number

left join
(select distinct AIMTC_Pseudo_NHS as nhs_number
from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_APC_SPELLS_Standard_Script]
where AIMTC_Postcode_Key = '2425135'
and DischargeDate_FromHospitalProviderSpell between @Startdate and @EndDate
and AIMTC_Pseudo_NHS IS NOT NULL) b
on m.NHS_Number = b.nhs_number

left join
(select distinct NHS_Number_Key as nhs_number
from Analyst_SQL_Area.dbo.tbl_BNSSG_Datasets_CSDS_Referrals r
left join (Select Main_Code_Text, Main_Description from [UK_Health_Dimensions].[Data_Dictionary].[Service_Or_Team_Type_Referred_To_For_Community_Care_SCD] 
			where Effective_To IS NULL)t
on r.Service_Team_Referred_To_Code = t.Main_Code_Text
left Join  [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] g on r.GP_Practice_Code = g.Practice_Code
left Join  [abi].[Lard].[vw_DateTime_Lookup] dt on Referral_Received_Date = dt.[Date]
where Commissioner_Code = '15C'
and Referral_Received_Date between @StartDate and @EndDate
and  Referral_Received_Date >= @dq_start
and [Service_Agreement_Line_ID] = '16'
and  [NHS_Number_Key] is not null )c
on m.NHS_Number = c.nhs_number

left join
(select distinct nhs_number from 
(SELECT distinct [Pseudo_NHS_Number] as nhs_number
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS]
  where [Pseudo_Postcode] = '2425135'
   and [CCG_Of_Registration] = '15C'
  AND [Start_Date] <= @EndDate and ([End_Date] >= @StartDate or [End_Date] is null) 
  UNION ALL 
  SELECT distinct [Pseudo_NHS_Number] as nhs_number
  FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS]
  where [GP_Practice_Code] = 'Y02873'
  AND [Start_Date] <= @EndDate and ([End_Date] >= @StartDate or [End_Date] is null)  
  
   ) d) d
  on m.NHS_Number = d.nhs_number

left join
(Select distinct nhs_number
from [MODELLING_SQL_AREA].[dbo].[primary_care_attributes]
where [homeless] IS NOT NULL
and [attribute_period] >= @StartDate
and [attribute_period] <= @EndDate) e
on m.NHS_Number = e.nhs_number