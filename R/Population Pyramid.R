#Run Setup first!!!

#install.packages(c('cowplot'))
# Load packages
library(ggplot2)
library(tidyverse)
library(cowplot)
library(dplyr)
##########################################################################################


#Get data for bars 
con_string <-c(
  "driver={SQL Server};server=xsw-000-sp09;
                database=MODELLING_SQL_AREA;
                trusted_connection=true")

con<- RODBC::odbcDriverConnect(con_string,rows_at_time = 1)

dataall <- " SET NOCOUNT ON


declare @Date  date

--Find the latest population date to select the PDS population by
set @Date = (Select max([period])From [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Datasets_Population_2011_12_onwards])

--Population for LSOA and each Locality
Select 

CASE WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 < 5 THEN '00 to 04'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 5 AND 9 THEN '05 to 09'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 10 AND 14 THEN '10 to 14'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 15 AND 19 THEN '15 to 19'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 20 AND 24 THEN '20 to 24'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 25 AND 29 THEN '25 to 29'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 30 AND 34 THEN '30 to 34'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 35 AND 39 THEN '35 to 39'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 40 AND 44 THEN '40 to 44'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 45 AND 49 THEN '45 to 49'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 50 AND 54 THEN '50 to 54'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 55 AND 59 THEN '55 to 59'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 60 AND 64 THEN '60 to 64'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 65 AND 69 THEN '65 to 69'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 70 AND 74 THEN '70 to 74'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 75 AND 79 THEN '75 to 79'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 80 AND 84 THEN '80 to 84'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 85 AND 89 THEN '85 to 89'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 >= 90 THEN '90+'
		ELSE 'No Age'
	END AS [ageband]

,a.[Gender_description] as [sex]

,0 as mh_cohort
,Case when [LSOA] = 'E01033361' then 'Bedminster West (039F)' else gp.Locality_Name end as 'cohort'
,count([Pseudo_NHS_Number]) as people

from Analyst_SQL_Area.[dbo].[tbl_BNSSG_Datasets_Combined_PDS] a
	 left join [Analyst_SQL_Area].[dbo].[tbl_BNSSG_Lookups_GP] gp on a.[GP_Practice_Code] = gp.[Practice_Code]

WHERE a.[Gender_description] in ('Male','Female') AND
	[Start_Date] <= @date and ([End_Date] >@Date or end_date is null) 

	and ( CCG_Of_Registration = '15C' )

  Group by
    CASE WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 < 5 THEN '00 to 04'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 5 AND 9 THEN '05 to 09'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 10 AND 14 THEN '10 to 14'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 15 AND 19 THEN '15 to 19'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 20 AND 24 THEN '20 to 24'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 25 AND 29 THEN '25 to 29'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 30 AND 34 THEN '30 to 34'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 35 AND 39 THEN '35 to 39'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 40 AND 44 THEN '40 to 44'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 45 AND 49 THEN '45 to 49'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 50 AND 54 THEN '50 to 54'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 55 AND 59 THEN '55 to 59'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 60 AND 64 THEN '60 to 64'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 65 AND 69 THEN '65 to 69'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 70 AND 74 THEN '70 to 74'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 75 AND 79 THEN '75 to 79'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 80 AND 84 THEN '80 to 84'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 85 AND 89 THEN '85 to 89'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 >= 90 THEN '90+'
		ELSE 'No Age'
	END 
,a.[Gender_description]
,Case when [LSOA] = 'E01033361' then 'Bedminster West (039F)' else gp.Locality_Name end



Union ALL

--BNSSG total population for comparator
Select 

CASE WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 < 5 THEN '00 to 04'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 5 AND 9 THEN '05 to 09'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 10 AND 14 THEN '10 to 14'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 15 AND 19 THEN '15 to 19'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 20 AND 24 THEN '20 to 24'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 25 AND 29 THEN '25 to 29'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 30 AND 34 THEN '30 to 34'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 35 AND 39 THEN '35 to 39'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 40 AND 44 THEN '40 to 44'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 45 AND 49 THEN '45 to 49'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 50 AND 54 THEN '50 to 54'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 55 AND 59 THEN '55 to 59'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 60 AND 64 THEN '60 to 64'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 65 AND 69 THEN '65 to 69'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 70 AND 74 THEN '70 to 74'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 75 AND 79 THEN '75 to 79'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 80 AND 84 THEN '80 to 84'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 85 AND 89 THEN '85 to 89'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 >= 90 THEN '90+'
		ELSE 'No Age'
	END AS [Age_group]

,a.[Gender_description]

,0 as mh_cohort
,'BNSSG' as 'cohort'
,count([Pseudo_NHS_Number]) as People

from Analyst_SQL_Area.[dbo].[tbl_BNSSG_Datasets_Combined_PDS] a

WHERE a.[Gender_description] in ('Male','Female') AND
	[Start_Date] <= @date and ([End_Date] >@Date or end_date is null) 

	and ( CCG_Of_Registration = '15C' )

  Group by
    CASE WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 < 5 THEN '00 to 04'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 5 AND 9 THEN '05 to 09'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 10 AND 14 THEN '10 to 14'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 15 AND 19 THEN '15 to 19'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 20 AND 24 THEN '20 to 24'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 25 AND 29 THEN '25 to 29'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 30 AND 34 THEN '30 to 34'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 35 AND 39 THEN '35 to 39'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 40 AND 44 THEN '40 to 44'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 45 AND 49 THEN '45 to 49'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 50 AND 54 THEN '50 to 54'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 55 AND 59 THEN '55 to 59'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 60 AND 64 THEN '60 to 64'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 65 AND 69 THEN '65 to 69'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 70 AND 74 THEN '70 to 74'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 75 AND 79 THEN '75 to 79'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 80 AND 84 THEN '80 to 84'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 BETWEEN 85 AND 89 THEN '85 to 89'
		WHEN (CONVERT(int,CONVERT(char(8),cast(concat(datepart(year, @date),'-',datepart(month,getdate()),'-01') as date),112))-CONVERT(char(8),[Derived_Year_Month_Of_Birth],112))/10000 >= 90 THEN '90+'
		ELSE 'No Age'
	END 
,a.[Gender_description]
"

#current mismatch in attribute periods due to lsoa issues in SWD PC attributes

dataset <-RODBC::sqlQuery(con,dataall)
on.exit(odbcClose(db.connex))
close(con)
rm(con)

#save r datafile
#save(dataset,file=paste0('C:/Annes offline R/community connectors/dataset','.RData'))



#summarise the all dataset to aggregate it to correct level for graph for total population

#LSOA
# Summarise the dataset to get the total population for each age band
total_LSOA_pop <- dataset %>%
  filter(cohort == 'Bedminster West (039F)' & ageband != 'No Age') %>%
  summarise(total_LSOA_sumpop = sum(people)) %>%
  pull(total_LSOA_sumpop)

# Summarise the dataset to get the population for each sex and age band
dataset_lsoa_sex <- dataset %>%
  filter(cohort == 'Bedminster West (039F)' & ageband != 'No Age') %>%
  group_by(sex, ageband) %>%
  summarise(lsoa_sumpop = sum(people))

dat_lsoa <- dataset_lsoa_sex %>%
  mutate(lsoa_popperc = case_when(
    sex == 'Male' ~ round(lsoa_sumpop / total_LSOA_pop * 100, 2),
    TRUE ~ -round(lsoa_sumpop / total_LSOA_pop * 100, 2)
  ),
  signal = case_when(
    sex == 'Male' ~ 1,
    TRUE ~ -1
  ))

#SB
total_SB_pop <- dataset %>%
  filter(cohort == 'South Bristol' & ageband != 'No Age') %>%
  summarise(total_SB_sumpop = sum(people)) %>%
  pull(total_SB_sumpop)

dataset_SB_sex <- dataset %>%
  filter(cohort == 'South Bristol' & ageband != 'No Age') %>%
  group_by(sex, ageband) %>%
  summarise(SB_sumpop = sum(people))

dat_SB <- dataset_SB_sex %>%
  mutate(SB_popperc = case_when(
    sex == 'Male' ~ round(SB_sumpop / total_SB_pop * 100, 2),
    TRUE ~ -round(SB_sumpop / total_SB_pop * 100, 2)
  ),
  signal = case_when(
    sex == 'Male' ~ 1,
    TRUE ~ -1
  ))

#bnssg

total_BNSSG_pop <- dataset %>%
  filter(cohort == 'BNSSG' & ageband != 'No Age') %>%
  summarise(total_B_sumpop = sum(people)) %>%
  pull(total_B_sumpop)

dataset_BNSSG_sex <- dataset %>%
  filter(cohort == 'BNSSG' & ageband != 'No Age') %>%
  group_by(sex, ageband) %>%
  summarise(B_sumpop = sum(people))

dat_BNSSG <- dataset_BNSSG_sex %>%
  mutate(BNSSG_popperc = case_when(
    sex == 'Male' ~ round(B_sumpop / total_BNSSG_pop * 100, 2),
    TRUE ~ -round(B_sumpop / total_BNSSG_pop * 100, 2)
  ),
  signal = case_when(
    sex == 'Male' ~ 1,
    TRUE ~ -1
  ))



##################################################################################################
#Need ageband to be a factor for ordered plotting
levels(dat_lsoa$ageband)
dat_lsoa$ageband <- factor(dat_lsoa$ageband, ordered = TRUE, levels = c("00 to 04","05 to 09","10 to 14","15 to 19","20 to 24","25 to 29", 
                                                                        "30 to 34","35 to 39", "40 to 44","45 to 49", "50 to 54","55 to 59", 
                                                                        "60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89", "90+"))

levels(dat_BNSSG$ageband)
dat_all$ageband <- factor(dat_all$ageband, ordered = TRUE, levels = c("00 to 04","05 to 09","10 to 14","15 to 19","20 to 24","25 to 29", 
                                                                      "30 to 34","35 to 39", "40 to 44","45 to 49", "50 to 54","55 to 59", 
                                                                      "60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89", "90+"))
levels(dat_SB$ageband)
dat_SB$ageband <- factor(dat_SB$ageband, ordered = TRUE, levels = c("00 to 04","05 to 09","10 to 14","15 to 19","20 to 24","25 to 29", 
                                                                      "30 to 34","35 to 39", "40 to 44","45 to 49", "50 to 54","55 to 59", 
                                                                      "60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89", "90+"))



# Plotting
pop_plot_BNSSG <- ggplot(dat_lsoa)+
  geom_bar(aes(x=ageband,y=lsoa_popperc,fill=sex),stat='identity')+
  #below is the female line
  geom_line(data = dat_BNSSG %>% filter(sex == "Female"), 
            mapping = aes(x=ageband,y=BNSSG_popperc), color = "black",group = 1, linewidth = 1.0)+
  #below is the male line
  geom_line(data = dat_BNSSG %>% filter(sex == "Male"), 
            mapping = aes(x=ageband,y=BNSSG_popperc), color = "black",group = 1, linewidth = 1.0)+
  geom_text(aes(x=ageband,y=lsoa_popperc + signal * 1.05,
                label = paste0(round(abs(lsoa_popperc),1), "%")))+    #use to add labels to bars
  coord_flip()+
  scale_fill_manual(name='',values=c("#853358","#B3B3B3"))+
  scale_color_manual(name='',values=c("#853358","#B3B3B3"))+
  scale_y_continuous(breaks=seq(-50,50,1),
                     labels=function(x){abs(x)})+
  labs(x='',y='Population (%)',
       title='Bedmister West (039F) LSOA population v BNSSG registered population',
       subtitle=paste('Registered population as at the 1st July 2024,\nBlack line shows % BNSSG population for comparison'), #\n inserts a text wrap
       caption=' ')+
  cowplot::theme_cowplot()+
  bnssgtheme()+
  #Changes the size of the text on the axis to be different for the standard set in BNSSGtheme()
  theme(plot.title = element_text(size = 12),
        axis.text.x = element_text(size = 9),  # Adjust the size value as needed
        axis.text.y = element_text(size = 10),  # Adjust the size value as needed
        legend.text = element_text(size = 10),
        )  

# Save the plot as a PNG file
ggsave("C:/Annes offline R/community connectors/02 Data_Images/population plot_perc.png", plot = pop_plot_BNSSG, width = 6, height = 6, dpi = 300)
#The above code will save the plot as plot.png with a width of 10 inches, a height of 6 inches, 
#and a resolution of 300 DPI. Adjust the dimensions and DPI as needed.


################################################################################
# Plotting Locality
pop_plot_SB <- ggplot(dat_lsoa)+
  geom_bar(aes(x=ageband,y=lsoa_popperc,fill=sex),stat='identity')+
  #below is the female line
  geom_line(data = dat_SB %>% filter(sex == "Female"), 
            mapping = aes(x=ageband,y=SB_popperc), color = "black",group = 1, linewidth = 1.0)+
  #below is the male line
  geom_line(data = dat_SB %>% filter(sex == "Male"), 
            mapping = aes(x=ageband,y=SB_popperc), color = "black",group = 1, linewidth = 1.0)+
  geom_text(aes(x=ageband,y=lsoa_popperc + signal * 1.05,
                label = paste0(round(abs(lsoa_popperc),1), "%")))+    #use to add labels to bars
  coord_flip()+
  scale_fill_manual(name='',values=c("#853358","#B3B3B3"))+
  scale_color_manual(name='',values=c("#853358","#B3B3B3"))+
  scale_y_continuous(breaks=seq(-50,50,1),
                     labels=function(x){abs(x)})+
  labs(x='',y='Population (%)',
       title='Bedmister West (039F) LSOA population v South Bristol Locality registered population',
       subtitle=paste('Registered population as at the 1st July 2024,\nBlack line shows % South Bristol Locality population for comparison'), #\n inserts a text wrap
       caption=' ')+
  cowplot::theme_cowplot()+
  bnssgtheme()+
  #Changes the size of the text on the axis to be different for the standard set in BNSSGtheme()
  theme(plot.title = element_text(size = 12),
    axis.text.x = element_text(size = 9), # Adjust the size value as needed
    axis.text.y = element_text(size = 10),  # Adjust the size value as needed
    legend.text = element_text(size = 10)
  )

# Save the plot as a PNG file
ggsave("C:/Annes offline R/community connectors/02 Data_Images/population plot SB perc.png", plot = pop_plot_SB, width = 6, height = 6, dpi = 300)
#The above code will save the plot as plot.png with a width of 10 inches, a height of 6 inches, 
#and a resolution of 300 DPI. Adjust the dimensions and DPI as needed.

