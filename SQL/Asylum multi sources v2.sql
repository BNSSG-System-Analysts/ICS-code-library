
with mpi as
(
select distinct nhs_number from 
[MODELLING_SQL_AREA].[dbo].[primary_care_supplemental]
where [sup_metric_17] IS NOT NULL
and nhs_number IS NOT NULL
UNION ALL
SELECT distinct
[DERIVED_PSEUDO_NHS] as nhs_number
FROM [ABI].[CSDS].[CYP101_Referral] A
INNER JOIN (SELECT distinct
			UNIQUE_SERVICE_REQUEST_IDENTIFIER
			FROM [ABI].[CSDS].[CYP102_Service_Type_Referred_To] a
			WHERE a.[SERVICE_OR_TEAM_TYPE_REFERRED_TO_COMMUNITY_CARE] = '28'
			and a.ORGANISATION_IDENTIFIER_CODE_OF_PROVIDER = 'nlx'
			) b  ON A.[UNIQUE_SERVICE_REQUEST_IDENTIFIER] = b.UNIQUE_SERVICE_REQUEST_IDENTIFIER

WHERE A.[SOURCE_OF_REFERRAL_FOR_COMMUNITY] = '18'
AND isnull(A.Derived_Pseudo_NHS,'') <> ''
UNION ALL 
SELECT  distinct [Pseudo_NHS_Number] as NHS_Number
FROM Analyst_SQL_Area.[dbo].[tbl_BNSSG_Datasets_Haven_Cohort]
WHERE isnull([Pseudo_NHS_Number],'') <> ''
UNION ALL
select distinct NHS_Number
FROM [Analyst_SQL_Area].[dbo].[tbl_Adult_Social_Care_CLD]
where Primary_Support_Reason = 'Social Support: Asylum Seeker Support'
and NHS_Number IS NOT NULL
UNION ALL
select distinct a.nhs_number
from 
(
select 
NHSNumber as nhs_number
FROM [ABI].[MHSDS].[MHS001MPI] t1
  inner join [ABI].[MHSDS].[MHS101Referral] t2 on t1.RecordNumber = t2.RecordNumber and t2.SourceOfReferralMH = 'm1'

  UNION ALL

select 
NHSNumber as nhs_number
FROM [ABI].[MHSDS].[MHS001MPI] t1
  inner join [ABI].[MHSDS].[MHS102ServiceTypeReferredTo] t2 on t1.RecordNumber = t2.RecordNumber and t2.[ServTeamTypeRefToMH] = 'D04'

  ) a

)

select 
distinct(m.nhs_number) as 'All',
case 
	when a.nhs_number is not null then 1
	else 0 
end as 'Primary care', 
case 
	when b.nhs_number is not null then 1
	else 0 
end as 'Sirona', 
case 
	when c.NHS_Number is not null then 1
	else 0 
end as 'Haven',
case 
	when d.NHS_Number is not null then 1
	else 0 
end as 'Social care',
case 
	when e.nhs_number is not null then 1
	else 0 
end as 'Mental health'

from mpi m

left Join 

(select distinct nhs_number from 
[MODELLING_SQL_AREA].[dbo].[primary_care_supplemental]
where [sup_metric_17] IS NOT NULL
and nhs_number IS NOT NULL) a
on m.nhs_number = a.nhs_number


left join

(
SELECT distinct
[DERIVED_PSEUDO_NHS] as nhs_number
FROM [ABI].[CSDS].[CYP101_Referral] A
INNER JOIN (SELECT distinct
			UNIQUE_SERVICE_REQUEST_IDENTIFIER
			FROM [ABI].[CSDS].[CYP102_Service_Type_Referred_To] a
			WHERE a.[SERVICE_OR_TEAM_TYPE_REFERRED_TO_COMMUNITY_CARE] = '28'
			and a.ORGANISATION_IDENTIFIER_CODE_OF_PROVIDER = 'nlx'
			) b  ON A.[UNIQUE_SERVICE_REQUEST_IDENTIFIER] = b.UNIQUE_SERVICE_REQUEST_IDENTIFIER

WHERE A.[SOURCE_OF_REFERRAL_FOR_COMMUNITY] = '18'
AND isnull(A.Derived_Pseudo_NHS,'') <> ''

)b

on m.nhs_number = b.nhs_number

left join (
SELECT  distinct [Pseudo_NHS_Number] as NHS_Number
FROM Analyst_SQL_Area.[dbo].[tbl_BNSSG_Datasets_Haven_Cohort]
WHERE isnull([Pseudo_NHS_Number],'') <> '') c

on m.nhs_number = c.NHS_Number

left join

(select distinct NHS_Number
FROM [Analyst_SQL_Area].[dbo].[tbl_Adult_Social_Care_CLD]
where Primary_Support_Reason = 'Social Support: Asylum Seeker Support'
and NHS_Number IS NOT NULL) d

on m.nhs_number = d.NHS_Number

left join 

(select distinct a.nhs_number
from 
(
select 
NHSNumber as nhs_number
FROM [ABI].[MHSDS].[MHS001MPI] t1
  inner join [ABI].[MHSDS].[MHS101Referral] t2 on t1.RecordNumber = t2.RecordNumber and t2.SourceOfReferralMH = 'm1'

  UNION ALL

select 
NHSNumber as nhs_number
FROM [ABI].[MHSDS].[MHS001MPI] t1
  inner join [ABI].[MHSDS].[MHS102ServiceTypeReferredTo] t2 on t1.RecordNumber = t2.RecordNumber and t2.[ServTeamTypeRefToMH] = 'D04'

  )a) e

on m.nhs_number = e.nhs_number