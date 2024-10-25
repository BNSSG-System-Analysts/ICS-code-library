rm(list = ls())
#run R script from Git
#note the Git path needs to be the RAW path,, it will be personal to you
source(
"https://raw.githubusercontent.com/BNSSG-PHM/code-and-template-library/main/R%20and%20Quarto/ISR%20function.R?token=GHSAT0AAAAAACGM6K46QAENPPAVOIOBIWFEZRLNDXA"  
)



#run SQL script from Git
#note the Git path needs to be the RAW path, it will be personal to you
url <- "https://raw.githubusercontent.com/BNSSG-PHM/code-and-template-library/main/SQL/swd_activity_ecds.sql?token=GHSAT0AAAAAACGM6K46PFBNBLNP5GTJPW6UZRLNAPQ"


con_string <- c("driver={SQL Server};server=xsw-000-sp09.xswhealth.nhs.uk;
                             database=Modelling_SQL_AREA;
                    trusted_connection=true")
con <-  RODBC::odbcDriverConnect(con_string, rows_at_time = 1)

dataframe <- RODBC::sqlQuery(con,query = readr::read_file(url),stringsAsFactors = FALSE)

close(con)
rm(con)

