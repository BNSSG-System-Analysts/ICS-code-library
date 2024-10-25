
select gp.parentorgcode as [organisation_code]
	  ,gp.orgcode as [organisation_sitecode] --Branch code
	  ,gpl.merged_practice_name as [practice_name]
	  ,gp.latitude as practice_latitude
	  ,gp.longitude as practice_longitude
	  ,gpl.locality_name
	  ,gpl.PrimaryCareNetwork
	  ,gp.postcode as [practice_postcode]
	  ,gp.locationType
	  ,gpl.[local_practice_name] --short names may change as currently out for discussion
      ,gpl.[local_pcn_name]
      ,gpl.[local_locality_name]
	  ,lsoa.[pcd7]
	  ,lsoa.[pcd8]
      ,lsoa.[pcds]
      ,lsoa.[dointr]
      ,lsoa.[doterm]
      ,lsoa.[oa11cd]
      ,lsoa.[lsoa11cd]
      ,lsoa.[msoa11cd]
      ,lsoa.[ladcd]
      ,lsoa.[lsoa11nm]
	  ,loc.[LSOA11_local_name]
      ,lsoa.[msoa11nm]
      ,lsoa.[ladnm]
	  from [ANALYST_SQL_AREA].[GIS].[tbl_BNSSG_GP] gp
	  left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_lookups_Postcode_OA_LSOA] lsoa on REPLACE(gp.postcode, ' ', '')  = REPLACE(lsoa.[pcd7], ' ', '')
	  left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] gpl on gp.parentorgcode = gpl.practice_code
	  left join [Modelling_SQL_Area].[dbo].[LSOA_Local_Names] loc on lsoa.[lsoa11cd] = [LSOA_2011]
