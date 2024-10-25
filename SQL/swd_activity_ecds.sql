SET NOCOUNT ON

--This script takes **kept** activity only from SWD with the exception of A&E.  A&E is added from ECDS & Sirona data flows instead, and unioned on separately
--Prescriptions are excluded

DECLARE @act_start DATETIME
SET @act_start = '20230101' -- activity start 

DECLARE @act_end DATETIME
SET @act_end = '20230110' -- activity end 


;


select swd.[source_id]
,swd.[source_id_name]
,swd.[nhs_number],  1 as 'activity'
,swd.[spec_l1b]
,(swd.[Cost1]) as 'cost'
,swd.[arr_date]
,swd.[dep_date]
,swd.[pod_l1] as 'main_POD'
,case when swd.[pod_l1] IN ('primary_care_prescription', 'community', '111', '999') then swd.[pod_l1] 
when swd.[pod_l1] like '%primary_care_contact%' and swd.[pod_l2a] = 'gp' then 'primary_care_contact_GP'
when swd.[pod_l1] like '%primary_care_contact%' and swd.[pod_l2a] <> 'gp' then 'primary_care_contact_other'
--when swd.[pod_l2a] like '%ae%' then 'ae'
when swd.[pod_l1] in ('Mental_Health','Mental Health') and swd.[pod_l2a] IN ('op') and swd.[attend_code] in ('5','6') and swd.[pod_l2b] = 'IAPT'
then 'IAPT'
else concat(swd.[pod_l2a],swd.[pod_l2b]) end as 'specific_POD'

from [MODELLING_SQL_AREA].[dbo].[swd_activity] swd

where 
swd.[arr_date] >= @act_start and swd.[arr_date] <= @act_end 
and swd.[pod_l1] <> 'primary_care_prescription'
and (swd.[attend_code] NOT IN ('did not attend', '1','7','2','3','4','0') OR swd.[attend_code] IS NULL)
and NOT (swd.[pod_l1] IN ('mental_health')  and swd.[pod_l2a] IN ('op') and swd.[attend_code] IS NULL)  
and NOT (swd.[pod_l1] IN ('mental_health')  and swd.[pod_l2a] IN ('ip') and swd.[pod_l2b] IN ('missing_unknown'))
and NOT (swd.[pod_l1] IN ('secondary') and swd.[pod_l2a] IN ('op') and swd.[pod_l2b] IN ('other'))
and NOT (swd.[pod_l1] IN ('secondary') and swd.[pod_l2a] IN ('ip') and swd.[pod_l2b] IN (''))
and NOT (swd.[pod_l1] = 'secondary' and swd.[pod_l2a] like '%ae%') 

--ecds activity unioned on
UNION ALL
select
ecds.[Attendance_Unique_Identifier] as source_id
,'ecds' as source_id_name
,ecds.[nhs_number]
,1 as 'activity'
,'ecds' as 'spec_l1b'
,0 as 'cost'
,ecds.[Arrival_Date] as 'arr_date'
,ecds.[Departure_Date] as 'dep_date'
,'secondary' as 'main_POD'
,'ae' as 'specific_POD'

from Analyst_SQL_AREA.[dbo].[tbl_BNSSG_ECDS] ecds
WHERE	1=1
		and ISNULL(nhs_number,'') NOT IN ('9000219621','')
		and [Arrival_Date] between @act_start and @act_end
		and left([Organisation_Code_Commissioner],3) in ('15C','QUY','11T', '5M8','11H', '5QJ', '12A', '5A3')
		and [Attendance_Unique_Identifier] IS NOT NULL

--Sirona activity unioned on
UNION ALL
select
cast(sirona.[CCG_process_ID] as char) as source_id
,'sirona' as source_id_name
,sirona.[nhs_number]
,1 as 'activity'
,'sirona' as 'spec_l1b'
,0 as 'cost'
,sirona.[Attendance_Date] as 'arr_date'
,NULL as 'dep_date'
,'secondary' as 'main_POD'
,'ae' as 'specific_POD'

from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Sirona_Urgent_Care] sirona
LEFT JOIN analyst_SQL_AREA.[dbo].[tbl_BNSSG_Lookups_GP] gp ON sirona.[Practice_Code] = gp.[Practice_Code]
WHERE ISNULL(NHS_Number,'') <> ''	
		and cast(Attendance_Date as date) between @act_start and @act_end
		and ([Practice_CCG] IN ('BNSSG','NHS Bristol, North Somerset and South Gloucestershire CCG','NHS Bristol, North Somerset and South Gloucestershire Integrated Care Board')
			OR GP.[Practice_Code] is not null)



