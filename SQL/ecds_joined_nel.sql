DECLARE @StartDate as date
SET @StartDate = '20230101' 

DECLARE @EndDate as date
SET @EndDate = '20231231' 

drop table if exists #temp

SELECT ed.nhs_number ,ed.[Attendance_Unique_Identifier], ed.[Arrival_Date], ed.Departure_Date
--this bit gives some idea of disposal method, which has poor completion in ECDS so is suplemented here with SUS data
,case when  ed.[Destination_Desc] IS NULL and ed.[Discharge_Status_Desc] like '%streamed%' then 'Streamed to another service after initial assessment'
when  ed.[Destination_Desc] IS NULL and (ed.[Discharge_Status_Desc] like '%Dead%' or ed.[Discharge_Status_Desc] like '%died%') then 'Admission to the mortuary'
when  ed.[Destination_Desc] IS NULL and ed.[Discharge_Status_Desc] like '%Left%' then 'Left before treatment completed'
when  ed.[Destination_Desc] IS NULL and ed.[Discharge_Status_Desc] like '%Streamed to another service %' then 'Discharged to another unit, ward or service in the hospital'
when  ed.[Destination_Desc] like '%Emergency department discharge to%' or ed.[Destination_Desc] like '%ward%' then 'Discharged to another unit, ward or service in the hospital'
when ed.[Destination_Desc] like '%nursing%' or ed.[Destination_Desc] like '%residential%' or ed.[Destination_Desc] like '%hospital at home%' then 'Discharged to nursing / residential / H@H'
when ed.[Destination_Desc] like '%police%' then 'Patient discharge, to legal custody'
when ed.[Destination_Desc] IS NULL and sus.[AEattendanceDisposal] = '03' then 'Discharge to home'
else ed.[Destination_Desc] end as Destination_Desc

,nel.[LOS], nel.[AIMTC_ProviderSpell_Start_Date], nel.[HospitalProviderSpellNumber]

--this line is for removing "duplicates" in the next stage - sometimes there are multiple admissions on the same day.  This choses the last admission
,row_number() over(partition by ed.[nhs_number], ed.[Attendance_Unique_Identifier] order by ed.[Arrival_Date], nel.[AIMTC_ProviderSpell_Start_Date] desc) as 'last' 

INTO #temp

FROM Analyst_SQL_AREA.[dbo].[tbl_BNSSG_ECDS] ed
left join --this is the SUS data to supplement the disposal method field which is badly completed in ecds
(select [AIMTC_Pseudo_NHS], [AEattendanceDisposal],[UniqueCDSidentifier]
		from [ABI].[dbo].[vw_AE_SEM_001]
		where	1=1
		and ISNULL(AIMTC_Pseudo_NHS,'') NOT IN ('9000219621','')
		and [ArrivalDate] >= @StartDate and ArrivalDate <= @EndDate
		and left([AIMTC_OrganisationCode_CodeofCommissioner],3) in ('15C','QUY','11T', '5M8','11H', '5QJ', '12A', '5A3')
		group by [AIMTC_Pseudo_NHS], [AEattendanceDisposal],[UniqueCDSidentifier]
		) sus
		on ed.[CDS_Unique_Identifier] = sus.[UniqueCDSidentifier] and ed.NHS_Number = sus.AIMTC_Pseudo_NHS

left join -- this is the NEL spells to get the LOS - you can add more fields if you need them
(select [AIMTC_Pseudo_NHS], [LOS], [AIMTC_ProviderSpell_Start_Date], [HospitalProviderSpellNumber]
		from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_NEL_SPELLS_Standard_Script]
		where [AIMTC_ProviderSpell_Start_Date] between @Startdate and @EndDate
		group by [AIMTC_Pseudo_NHS], [LOS], [AIMTC_ProviderSpell_Start_Date],[HospitalProviderSpellNumber]) nel
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


Select *
from #temp
where [last] = 1

