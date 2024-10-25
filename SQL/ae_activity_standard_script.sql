DECLARE @StartDate as date
SET @StartDate = '20230101' -- activity start 

DECLARE @EndDate as date
SET @EndDate = '20231231' -- activity end to fit with Winter opt out

DECLARE @opt varchar(100)
SET @opt = 'PHM_231114_01' -- need to update this when it has been to opt out, currently using Winter 23/24

DECLARE @att_per DATETIME
SET @att_per = '2024-01-01' -- fits with activity end
;

with CTE_all as(

SELECT ed.nhs_number
	,ed.[Attendance_Unique_Identifier] --this is source_ID in the SWD
	,case when Department_Type =  '01' then 'Major ED'
		  when Department_Type =  '02' then 'Mono-specialty'
		  else 'MIU / UTC' end as 'Provider_Type'
	,case when [Acuity_Desc] IN ('Non-urgent level emergency care','Standard level emergency care') THEN 'Minor'
		  when [Acuity_Desc] IN ('Immediate resuscitation level emergency care','Urgent level emergency care','Very urgent level emergency care') THEN 'Major'
		  else 'Unkown'
		  end as 'Acuity - Major_Minor'
	,case when left(ed.[Organisation_Code_Provider],3) = 'RA3' THEN 'Weston'
		  when ed.[Site] = 'RA7C2' then 'Weston'
		  when left(ed.[Organisation_Code_Provider],3) = 'RA7' THEN 'UHB'
		  when left(ed.[Organisation_Code_Provider],3) = 'RVJ' THEN 'NBT'else 'Other' end AS ED_provider
			--,[Organisation_Code_Provider] 

	,[Arrival_Date] AS 'ED Arrival Date'
	,datepart(hour,[Arrival_Time]) AS ED_Arrival_hour
	,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime) as [Arrival_date_time]
	,cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime) as [Assessment_date_time]
	,cast([Investigation_Date_1] as datetime)+ cast([Investigation_Time_1] as datetime) as [Investigation_date_time]
	,cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime) as [Treatment_date_time]
	,cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime) as [DecisionAdmit_date_time]
	,cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime) As [Departure date_time]
	
	,Initial_Assessment_Time_Since_Arrival
	,Seen_For_Treatment_Time_Since_Arrival
	,Decision_To_Admit_Time_Since_Arrival
	,Departure_Time_Since_Arrival
	
	,Treatment_Function_Code as 'TFC_of_admission'

	,case when Arrival_Time >= '18:00:00' or Arrival_Time < '08:00:00' 
			or DayOfTheWeek_Description IN ('Saturday', 'Sunday') 
			or BankHoliday_Flag = 1
		  then 1 else 0 end as 'ooh_indicator'

	,DayOfTheWeek_Description as 'day'

	--,datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) as [Duration_Minutes]
	--,datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime))/60 as [Duration_Hours]

	--,datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime)) as [Duration_Arr_Assessment]
	--,datediff(minute,cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime),cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime)) as [Duration_Ass_Treatment]
	--,datediff(minute,cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime),cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime)) as [Duration_Treat_DTA]
	--,datediff(minute,cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) as [Duration_DTA_Admission]

	,Case when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) END as [Duration_Minutes]
	,Case when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime))/60 END as [Duration_Hours]

	,Case when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime)) END as [Duration_Arr_Assessment]
	,Case when datediff(minute,cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime),cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Initial_Assessment_Date] as datetime)+ cast([Initial_Assessment_Time] as datetime),cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime)) END as [Duration_Ass_Treatment]
	,Case when datediff(minute,cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime),cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Seen_For_Treatment_Date] as datetime)+ cast([Seen_For_Treatment_Time] as datetime),cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime)) END as [Duration_Treat_DTA]
	,Case when datediff(minute,cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) < 0 THEN 0 ELSE datediff(minute,cast([Decision_To_Admit_Date] as datetime)+ cast([Decision_To_Admit_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) END as [Duration_DTA_Admission]


	,Case when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) < 240 then '< 4 hours'
		  when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) between 240 and 359 then '4 to 6 hours'
		  when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) between 360 and 479 then '6 to 8 hours'
		  when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) between 480 and 599 then '8 to 10 hours'	
		  when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) between 600 and 719 then '10 to 12 Hours'	
		  when datediff(minute,cast([Arrival_Date] as datetime)+ cast([Arrival_Time] as datetime),cast([Departure_Date] as datetime)+ cast([Departure_Time] as datetime)) > 719  then '12+ hours'	
		  else 'Unknown' end as [Duration_Band]
	,[Acuity_Desc]
	,[Alcohol_Drug_Involvements_1_Desc]
	,case when [Alcohol_Drug_Involvements_1_Desc] is null then 'No' 
	 when [Alcohol_Drug_Involvements_1_Desc] like '%Alcohol%' then 'Alcohol' else 'Drug' end as 'Flag_Alcohol_Drug_Involvement'
	 ,[Injury_Place_Desc]
	 ,[Investigation_Code_1_Desc]
	 ,[treatment_code_1_Desc]
	 ,[Health_Resource_Group]
	 ,[Final_Price]
	 ,ed.[Destination_Desc] AS ED_Destination_Desc

	--Case when 	ed.[Destination_Desc] in ('Discharge to ward','Emergency department discharge to emergency department short stay ward') then 'Admitted' 
	--	when ed.[Destination_Desc] is null then 'Unknown' else 'Other' end as [Destination_category],

	,case when  Destination_Desc IS NULL and Discharge_Status_Desc like '%streamed%' then 'Streamed to another service after initial assessment'
		  when  Destination_Desc IS NULL and (Discharge_Status_Desc like '%Dead%' or Discharge_Status_Desc like '%died%') then 'Admission to the mortuary'
		  when  Destination_Desc IS NULL and Discharge_Status_Desc like '%Left%' then 'Left before treatment completed'
		  when  Destination_Desc IS NULL and Discharge_Status_Desc like '%Streamed to another service %' then 'Discharged to another unit, ward or service in the hospital'
		  when  Destination_Desc like '%Emergency department discharge to%' or Destination_Desc like '%ward%' then 'Discharged to another unit, ward or service in the hospital'
		  when Destination_Desc like '%nursing%' or Destination_Desc like '%residential%' or Destination_Desc like '%hospital at home%' then 'Discharged to nursing / residential / H@H'
		  when Destination_Desc like '%police%' then 'Patient discharge, to legal custody'
		  when Destination_Desc IS NULL and AEattendanceDisposal = '03' then 'Discharge to home'
		  else Destination_Desc end as Destination_Desc

	,case when ed.[Arrival_Mode_Desc] IN ('Arrival by emergency road ambulance','Arrival by helicopter air ambulance') THEN 'Arrival by emergency ambulance'
		  when ed.[Arrival_Mode_Desc] IN ('Arrival by own transport','Arrival by public transport') THEN 'Walk in' ELSE 'Other' END AS  ED_Arrival_Mode_Desc
	
	,ed.chief_complaint_desc AS [Chief_Complaint]
	,ed.[Activity_Type_Desc] AS [Activity_Type]
	,ed.injury_mechanism_desc AS [Injury_Mechanism]
	,ed.[Diagnoses_Code_1_Desc] AS [Primary_Diagnosis]
	,[Diagnoses_Code_2_Desc]
	,[Diagnoses_Code_3_Desc] ,[Diagnoses_Code_4_Desc] , [Diagnoses_Code_5_Desc]
	

	,case when [Referred_To_Service] = '306136006' then 'Yes'
          when [Referred_To_Service_1] = '306136006' then 'Yes'
          when [Referred_To_Service_2] = '306136006' then 'Yes'
          else 'No'
          end as 'Referred to PL'
    ,case when [Referred_To_Service] in ('306136006','183524004','61801003','380241000000107','202291000000107','38670004') then 'Yes'
          when [Referred_To_Service_1] in ('306136006','183524004','61801003','380241000000107','202291000000107','38670004')  then 'Yes'
          when [Referred_To_Service_2] in ('306136006','183524004','61801003','380241000000107','202291000000107','38670004')  then 'Yes'
          else 'No'
          end as 'Mental Health Referral'

	,case when concat(Referred_To_Service_1_Desc,Referred_To_Service_2_Desc) like '%mental%' 
		or concat(Referred_To_Service_1_Desc,Referred_To_Service_2_Desc) like '%psych%'
		or Chief_Complaint_Desc = '%Self-Injur%' 
		or Chief_Complaint_Desc like '%Suicid%' 
		or Chief_Complaint_Desc like '%Depres%' 
		or Chief_Complaint_Desc like '%Anxiety%' 
		or Chief_Complaint_Desc like '%Behaviour%'
		or Chief_Complaint_Desc like '%Hallucinations%' 
		or Chief_Complaint_Desc like '%delusions%'
		or Chief_Complaint_Desc like '%Substance misuse%'

		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%Dementia%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%Delirium%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%Personality disorder%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%eating disorder%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%anxiety%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%depres%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%delusion%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%bipolar%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%schizophrenia%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%psychotic disorder%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%somatoform pain disorder%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%dissociative disorder%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%factitious disorder%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%Paracetamol overdose%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%non-steroidal anti-inflammatory overdose%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%overdose of antidepressant drug%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%Benzodiazepine overdose%'
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%overdose of opiate%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%self harm%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%adjustment disorder%' 
		or concat(Diagnoses_Code_1_Desc,Diagnoses_Code_2_Desc,Diagnoses_Code_3_Desc,Diagnoses_Code_4_Desc,Diagnoses_Code_5_Desc) like '%sedative overdose%' 

		or Injury_Intent_Desc = 'Self inflicted injury' then 'Yes'  else 'No' end as [Mental_Health_In_ED]
		  
		  ,[Discharge_Follow_Up_Desc]
		  ,[Referred_To_Service_1_Desc]
  		  ,[Referred_To_Service_2_Desc]

,nel.[LOS], nel.[AIMTC_ProviderSpell_Start_Date], nel.[HospitalProviderSpellNumber]
,nel.WardCodeatEpisodeStartDate

--this line is for removing "duplicates" in the next stage - sometimes there are multiple admissions on the same day.  This choses the last admission
,row_number() over(partition by ed.[nhs_number], ed.[Attendance_Unique_Identifier] order by ed.[Arrival_Date], nel.[AIMTC_ProviderSpell_Start_Date] desc) as 'last' 

FROM Analyst_SQL_AREA.[dbo].[tbl_BNSSG_ECDS] ed
left join [ABI].[Lard].[tbl_DateTime_Lookup] b on Initial_Assessment_Date = b.[Date]

left join 
	(select AIMTC_Pseudo_NHS, AEattendanceDisposal,[UniqueCDSidentifier]
	from [ABI].[dbo].[vw_AE_SEM_001]
	where	1=1
	and ISNULL(AIMTC_Pseudo_NHS,'') NOT IN ('9000219621','')
	and ArrivalDate >= @StartDate and ArrivalDate <= @EndDate
	and left([AIMTC_OrganisationCode_CodeofCommissioner],3) in ('15C','QUY','11T', '5M8','11H', '5QJ', '12A', '5A3')
	group by AIMTC_Pseudo_NHS, AEattendanceDisposal,[UniqueCDSidentifier]
		) sus
on ed.[CDS_Unique_Identifier] = sus.[UniqueCDSidentifier]
and ed.NHS_Number = sus.AIMTC_Pseudo_NHS

left join -- this is the NEL spells to get the LOS - you can add more fields if you need them
(select [AIMTC_Pseudo_NHS], [LOS], [AIMTC_ProviderSpell_Start_Date], [HospitalProviderSpellNumber],[WardCodeatEpisodeStartDate]
		from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_NEL_SPELLS_Standard_Script]
		where [AIMTC_ProviderSpell_Start_Date] between @Startdate and @EndDate
		group by [AIMTC_Pseudo_NHS], [LOS], [AIMTC_ProviderSpell_Start_Date],[HospitalProviderSpellNumber],[WardCodeatEpisodeStartDate]) nel
		on ed.nhs_number = nel.[AIMTC_Pseudo_NHS]
		and (
		ed.Departure_Date = nel.[AIMTC_ProviderSpell_Start_Date] -- ArrivalDate is before or equal to ProviderSpell_Start_Date
		or ed.Departure_Date = DATEADD(day, -1, nel.[AIMTC_ProviderSpell_Start_Date]) -- Up to 1 day afterwards
)

WHERE	1=1
		and ISNULL(nhs_number,'') NOT IN ('9000219621','')
		and [Arrival_Date] between @Startdate and @EndDate
		and left([Organisation_Code_Commissioner],3) in ('15C','QUY','11T', '5M8','11H', '5QJ', '12A', '5A3')
		and [Attendance_Unique_Identifier] IS NOT NULL


UNION ALL
--Sirona

SELECT 	 ed.nhs_number
	,cast(CCG_process_ID as char) as [Attendance_Unique_Identifier] 
	,'MIU / UTC' as [Provider_Type]
	,'Minor' AS 'Acuity - Major_Minor'
	,[location] as  ED_provider
	
	,Attendance_Date AS 'ED Arrival Date'
	,datepart(hour,[Attendance_Time]) AS ED_Arrival_hour
	,cast(Attendance_Date as datetime)+ cast([Attendance_Time] as datetime) as [Arrival date_time]
	,NULL as [Assessment_date_time]
	,NULL as [Investigation_date_time]
	,NULL as [Treatment_date_time]
	,NULL as [DecisionAdmit_date_time]
	,NULL as [Departure date_time]
	,NULL as Initial_Assessment_Time_Since_Arrival
	,NULL as Seen_For_Treatment_Time_Since_Arrival
	,NULL as Decision_To_Admit_Time_Since_Arrival
	,NULL as Departure_Time_Since_Arrival
	,NULL as 'TFC_of_admission'
	
	,case when [Attendance_Time] >= '18:00:00' or [Attendance_Time] < '08:00:00' 
		or DayOfTheWeek_Description IN ('Saturday', 'Sunday') 
		or BankHoliday_Flag = 1
		then 1 else 0 end as 'ooh_indicator'

	,DayOfTheWeek_Description as 'day'

	,NULL as [Duration_Minutes]
	,NULL as [Duration_Hours]
	,NULL as [Duration_Arr_Assessment]
	,NULL as [Duration_Ass_Treatment]
	,NULL as [Duration_Treat_DTA]
	,NULL as [Duration_DTA_Admission]

	,'MIU - Not recorded' as  [Duration_Band]
	,Latest_Priority as  [Acuity_Desc]
	,NULL as  [Alcohol_Drug_Involvements_1_Desc]
	,'Unknown' as 'Flag_Alcohol_Drug_Involvement' 
	,'Unknown' as  [Injury_Place_Desc]
	,'Unknown' as [Investigation_Code_1_Desc]

	,NULL as   [treatment_code_1_Desc]
	,NULL as   [Health_Resource_Group]
	,0 [Final_Price]
	,'MIU - Other' as ED_Destination_Desc
	,'Other' as [Destination_category]
	,'Walk in' AS  ED_Arrival_Mode_Desc
	,Case_type AS [Chief_Complaint]
	,'Unknown' as [Activity_Type]
	,'Unknown' AS [Injury_Mechanism]
	,'Unknown' AS [Primary_Diagnosis]
	,'Unknown'
	,'Unknown' 
	,'Unknown' 
	,'Unknown'
	,'Unknown' 
	,'Unknown'
	,'Unknown' as [Mental_Health_In_ED]
	,'Unknown' as [Discharge_Follow_Up_Desc]
	,'Unknown' as [Referred_To_Service_1_Desc]
  	,'Unknown' as [Referred_To_Service_2_Desc]
	,NULL as [LOS]
	,NULL as [AIMTC_ProviderSpell_Start_Date]
	,NULL as [HospitalProviderSpellNumber]
	,NULL as WardCodeatEpisodeStartDate
	,1 as 'last'

FROM [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Sirona_Urgent_Care] ed

	LEFT JOIN analyst_SQL_AREA.[dbo].[tbl_BNSSG_Lookups_GP] GP ON ed.[Practice_Code] = GP.[Practice_Code]

	left join  [Analyst_SQL_Area].[dbo].tbl_BNSSG_Datasets_Combined_PDS  p
	on ed.nhs_number = p.[Pseudo_NHS_Number] and  (p.start_date <= [Attendance_Date] and (p.end_date>= [Attendance_Date] or p.end_date is NULL))

	left join [ABI].[Lard].[tbl_DateTime_Lookup] b on Attendance_Date = b.[Date]

WHERE ISNULL(NHS_Number,'') <> ''	
and cast(Attendance_Date as date) between @StartDate and @EndDate
)

select * from CTE_all where [last] = 1
