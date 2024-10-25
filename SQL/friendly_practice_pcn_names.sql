USE [Analyst_SQL_Area]

DROP VIEW IF EXISTS [dbo].[vw_BNSSG_Lookups_GP]

GO


CREATE VIEW [dbo].[vw_BNSSG_Lookups_GP] AS

select *,
CASE 
        -- Do not modify if the practice name is '168 Medical Group' or 'The Family Practice'
        WHEN Merged_Practice_Name = '168 Medical Group' then '168 Medical Group'
		WHEN Merged_Practice_Name = 'The Family Practice' THEN 'The Family Practice'
        ELSE
[Analyst_SQL_Area].[dbo].[ConvertToTitleCase](
    LTRIM(RTRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(		
														REPLACE(	
															REPLACE(Merged_Practice_Name, 'MEDICAL PRACTICE', ''),
													'PRIMARY CARE CENTRE', ''),
												'SURGERY', ''),
											 'FAMILY PRACTICE', ''),
										'MEDICAL CENTRE', ''),
									'HEALTH CENTRE', ''),
								'HEALTHCARE', ''),
							'GROUP PRACTICE', ''),
						'MEDICAL GROUP', ''),
					'HEALTH GROUP', ''),
				'MEDICAL', ''),
			'COMMUNITY PRACTICE', ''),
        'SERVICE', ''),
                'VALLEY PRACTICE', 'VALLEY')
    )) 
	) END AS 'short_practice_name'

, case 
when PrimaryCareNetwork = '4PCN (BNSSG) PCN' then '4PCN'
when PrimaryCareNetwork = 'AFFINITY (BNSSG) PCN' then 'Affinity'
when PrimaryCareNetwork = 'BRIDGE VIEW PCN' then 'Bridge View'
when PrimaryCareNetwork = 'BRISTOL INNER CITY PCN' then 'BIC'
when PrimaryCareNetwork = 'CONCORD MENDIP PCN' then 'Concord Mendip'
when PrimaryCareNetwork = 'CONNEXUS PCN' then 'Connexus'
when PrimaryCareNetwork = 'FABB (FISHPONDS, AIR BALLOON & BEECHWOOD) PCN' then 'FABB'
when PrimaryCareNetwork = 'FOSS (FIRECLAY & OLD SCHOOL SURGERY) PCN' then 'FOSS'
when PrimaryCareNetwork = 'GORDANO VALLEY PCN' then 'Gordano Valley'
when PrimaryCareNetwork = 'HEALTHWEST PCN' then 'Healthwest'
when PrimaryCareNetwork = 'MENDIP VALE PCN' then 'Mendip Vale'
when PrimaryCareNetwork = 'NETWORK 4 (BNSSG) PCN' then 'Network 4'
when PrimaryCareNetwork = 'NORTHERN ARC PCN' then 'Northern Arc'
when PrimaryCareNetwork = 'PHOENIX (BNSSG) PCN' then 'Phoenix'
when PrimaryCareNetwork = 'PIER HEALTH PCN' then 'Pier Health'
when PrimaryCareNetwork = 'SEVERNVALE PCN' then 'Severnvale'
when PrimaryCareNetwork = 'STOKES PCN' then 'Stokes'
when PrimaryCareNetwork = 'SWIFT PCN' then 'Swift'
when PrimaryCareNetwork = 'TYNTESFIELD PCN' then 'Tyntesfield'
when PrimaryCareNetwork = 'YATE & FRAMPTON PCN' then 'Yate & Frampton'
else PrimaryCareNetwork end as 'short_pcn_name'
,

case when Locality_name = 'Inner City & East' then 'ICE'
when Locality_name = 'North & West' then 'N&W'
when Locality_name = 'South Bristol' then 'S.Bris'
when Locality_name = 'South Gloucestershire' then 'S.Glos'
when Locality_name = 'Weston Worle & Villages' then 'WW&V'
else Locality_Name end as 'short_locality_name'



FROM analyst_SQL_AREA.[dbo].[tbl_BNSSG_Lookups_GP]
GO


