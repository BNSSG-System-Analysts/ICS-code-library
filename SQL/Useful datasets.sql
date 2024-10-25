


--Population
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Combined_PDS] -- Patient level, slowly changing dimension, choose record active at a point in time or use 'iscurrent' and 'islatest' flags to find current record. Contains records for everyone, even if they have died or moved out of BNSSG.  'IsCurrent' means currently registered and 'IsLatest' means its the most recent record.  Some issues where there are gaps between records that should be continuous, raised with Data Engineering to fix.
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Population_2011_12_onwards] --Historic data back to 2011, 5 year age bands by practice
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Population_2011_12_onwards_alt_age_group]--Historic data back to 2011, 5 year age bands by practice split into 0-17 and 18+

--A&E
Select top 100 * from [Analyst_SQL_AREA].[dbo].[tbl_BNSSG_ECDS] --weekly A&E data has more detail than the SUS monthly version which they talk about retiring
Select top 100 * from [ABI].[dbo].[AE_SEM_001] --Monthly A&E data and is currently used in the SWD activity table
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Sirona_Urgent_Care] --miu data not yet submitted to ECDS

--Ambulance
Select top 100 * from [Analyst_SQL_AREA].[dbo].[vw_BNSSG_Datasets_UrgentCare_Ambulance] --Ambulance data, is based on incident location, need population PDS to get persons home LSOA and link to a geographicla lookup for IMD etc.  Contains a partial postcode ans Ward of incident.

--Admissions
Select top 100 * from [ABI].[dbo].[vw_APC_SEM_001] --Episode level admissions data. Includes elective and Non-elective.  Need to use admission method to split.
Select top 100 * from [ABI].[dbo].[vw_APC_SEM_Spell_001] --Spell level admissions data. Includes elective and Non-elective.  Need to use admission method to split
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_NEL_SPELLS_Standard_Script] --Our view of [vw_APC_SEM_Spell_001] which has all the codes converted to descriptions and pre-determined flags for falls etc.  Is just non-elective.  This is the one we use most.

Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Elective_SPELLS_Standard_Script] --Elective version.

--Outpatients
Select top 100 * from [ABI].[dbo].[vw_OP_SEM_001] --All outpatient attendances.  Not much detail about why, mostly specialty and some procedure codes where done.

--Adult Social Care
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_Adult_Social_Care_CLD]
--S:\Finance\Shared Area\BNSSG - BI\5 Team\4 Training Resources\Analyst huddles\Huddle materials\Adult Social Care_Client level data
--*****Strongly encourage engagement****** with Local Authorities as there are anomalies in the data that tey can explain.  LA's operate in different ways and this affects the consistency of the data between LA's.  It is not always comparable

-- 111
Select top 100 * from [ANALYST_SQL_AREA].[dbo].[tbl_BNSSG_Datasets_111_UEC_PLD] --111 calls, source is Severnside (Brisdoc & CareUk). Uses SD and SG codes to determine clinical context or issue and clinical need.
Select top 100 * from [Analyst_SQL_Area].[dbo].[111MH_Codes] --the codes used to define mental health activity within the 111 dataset.

--111 specific lookups - need to create them:
select distinct([Symptom_Discriminator_Code]) as [Symptom_Discriminator_Code]      ,[Symptom_Discriminator_Description] 
INTO #Sympt_Discrim_Code
FROM [UK_Health_Dimensions].[UEC_Analytics_Model].[Symptom_Groups_SCD]

select distinct([Symptom_Group_Code]) as [Symptom_Group_Code]  ,[Symptom_Group_Description] 
INTO #Sympt_Grp_Codes
FROM [UK_Health_Dimensions].[UEC_Analytics_Model].[Symptom_Groups_SCD]

select distinct([SG_SD_Combined_Code]) as [SG_SD_Combined_Code] ,Concat([Symptom_Group_Description],'_',[Symptom_Discriminator_Description]) as Group_Discriminator_Codes 
Into #SYMPT_Grp
FROM [UK_Health_Dimensions].[UEC_Analytics_Model].[Symptom_Groups_SCD]

select a.* into #KC_Lookup from [UK_Health_Dimensions].[NHS_111].[Dx_Code_Mapping] a join ( select [Kc_Look_Up], max(created_date) as created_date from [UK_Health_Dimensions].[NHS_111].[Dx_Code_Mapping]  group by [Kc_Look_Up]) b on a.Kc_Look_Up = b.Kc_Look_Up and a.Created_Date = b.created_date



--CSDS
Select top 100 * from  Analyst_SQL_Area.dbo.tbl_BNSSG_Datasets_CSDS_Referrals 
--Specific CDSD lookup
Select Main_Code_Text, Main_Description from [UK_Health_Dimensions].[Data_Dictionary].[Service_Or_Team_Type_Referred_To_For_Community_Care_SCD] where Effective_To IS NULL)

--Births and Deaths
Select top 100 * from  [ABI].[Civil_Registration].[Mortality]  --be aware of delays/time lag especially for deaths involving drugs, suicide or serious injury etc as these are subject to coroners inquests and data is often delayed. 
Select top 100 * from  [Civil_Registration].[Births]
Select top 100 * from  [ABI].[Civil_Registration].[Data_Dictionary] --description of fields


--MSDS maternity
--MHSDS mental health

--D2A discharge to assess
 Select top 100 * from  [Analyst_SQL_Area].dbo.[vw_BNSSG_D2A_Dashboard_ARB] --join on.nhs_number and DischargeDate.  Current source is from the trusts, will be coming from CSDS soon


--Lookup tables

--Geographical
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_lookups_LSOA_ward_2020] --LSOA, Ward and Local Authority
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_lookups_Postcode_OA_LSOA] --Postcode key, OA, LSOA, MSOA and LA
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_OacClustersAndNames] --ONS area description names by LSOA and Output area.  Need to join to Postcode PSD lookup for output area codes
Select top 100 * from [Analyst_SQL_Area].[dbo].[LSOA_Locality]  --LSOA to Locality boundaries (Geographical residence)
Select top 100 * from [Analyst_SQL_Area].[dbo].tbl_BNSSG_LSOA_Combined_Metrics --All wider determinants by LSOA but only for LSOAs in BNSSG
Select top 100 * from [Analyst_SQL_Area].[dbo].tbl_LSOA_Combined_Metrics--All wider determinants by LSOA for Englan, but not all fields available in the BNSSG version as some data is only available locally
Select top 100 * from [ABI].[Lard].[vw_Postcode_PSD_Lookup] --We are not allowed postcode so have a pseudoynmised key instead.  Links to OA, LSOA, MSOA and Ward.
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Projects_CMHP_Priority_Neighbourhoods] --this table uses BNSSG IMD scores and creates a local IMD decile - Now known as 'Local Deprivation'

--GP Lookup (to account for mergers)
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] -- Practice to PCN and Locality.  Match on Practice code, use merged practice code

--Ethnicity
Select top 100 * from [Analyst_SQL_Area].[dbo].tbl_BNSSG_Lookups_Ethnicity -- SUS ethnicity
Select top 100 * from [Analyst_SQL_Area].[dbo].[swd_ethnicity_groupings]-- Same as in the modelling area, combination of SUS, Primary Care and any other versions.  Has higher level groupings and is best one to use.

--Dataset code lookups
Select top 100 * from [ABI].[Lard].[vw_AdmissionMethod_Lookup]  --Use with Admissions for Episodes or spells
Select top 100 * from [ABI].[Lard].[vw_AdmissionSource_Lookup]  --Use with Admissions for Episodes or spells
Select top 100 * from [ABI].[Lard].[vw_AE_AttendanceDisposal_Lookup]  --Use with Old A&E Sem file.  ECDS is pre-done
Select top 100 * from [ABI].[Lard].[vw_DateTime_Lookup] 
Select top 100 * from [ABI].[Lard].[vw_DischargeDestination_Lookup] --Use with Admissions for Episodes or spells
Select top 100 * from [ABI].[Lard].[vw_DischargeMethod_Lookup] --Use with Admissions for Episodes or spells
Select top 100 * from [ABI].[Lard].[vw_HRG_Lookup]  --Use with any SuS dataset that has HRG code
Select top 100 * from [ABI].[Lard].[vw_ICD10_Lookup]  --Use with any SuS dataset that has ICD10 (diagnosis) codes
Select top 100 * from [ABI].[Lard].[vw_OPCS_Lookup] --Use with any SuS dataset that has OPCS (procedure) codes
Select top 100 * from [ABI].[Lard].[vw_TreatmentFunction_lookup]--Use with any SuS dataset that has TFC (treatment function) codes.  Similar to specality codes maybe a few extra groups.
Select top 100 * from [ABI].[Lard].[vw_Organisation_Lookup] --ODS codes.  May also need to use the ones in UK health dimensions database.
Select top 100 * from [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_Programme_Budget_Codes] --usefull for grouping codes
--[UK_Health_Dimensions]
--An enormous list of lookups.  Need to apply a filter to be able to find anything!

