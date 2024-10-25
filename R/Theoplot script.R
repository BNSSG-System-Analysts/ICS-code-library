#rm(list = ls())
#use an activity data frame like this example:
#https://github.com/BNSSG-PHM/code-and-template-library/blob/main/SQL/swd_activity_ecds.sql

#your activity data frame needs to one one row per activity (not aggregated) and have the following columns:
#nhs_number
#a point of delivery field - in the below this is called "specific_POD", so easiest to stick to that (or just change this script)
#an arrival date field - in the below this is called "arr_date"
#an departure date field - in the below this is called "dep_date"
#optional: a date field which is your index event date e.g. date of intervention or date of incident

#in the below example, my data frame is called "swd_activity", amend as necessary

library(tidyverse)
library(tidyr)
library(dplyr)

#load the BNSSG theme and BNSSG colour palettes in your normal way

#Create an "index event" date.  This could be the same date for all rows, or another field in your data frame e.g. date of intervention which will vary between rows
#option 1:in this example a single date for all rows has been chosen, stick to this date format
#swd_activity <- swd_activity %>% mutate(index_event = "2023-01-05")
#OR
#option 2:in this example date field for all rows has been chosen, check date format is YYYY-MM-DD
swd_activity <- swd_activity %>% mutate(index_event = earliest_fall)

theoplot_title <- "Example cohort activity, your date range, system wide dataset" #this is for your chart title later on
proj_title <- "Example theoplot" #this is for your chart title later on


theoplot_data <- swd_activity %>% arrange(nhs_number, specific_POD, arr_date)

#check on POD names, you will have to change the POD column name in this script if it is not called "specific_POD" in your activity data frame
unique(theoplot_data$specific_POD)

#change this list to keep the ones you want in the theoplot)
included_PODs <- c("opfollow_up","ipelective","op","opprocedure", "primary_care_contact_GP","opfirst","ipnon_elective","community",
                   "ae","999","111","aemissing_unknown","aefollow_up","aefirst")

theoplot_data <- theoplot_data %>% filter(specific_POD %in% included_PODs)

# Mutate the dataset to change specific_POD values to group outpatients together (if desired / needed)
#also make sure the arrival and departure dates are date only (not time) to prevent rounding issues
theoplot_data <- theoplot_data %>%
  mutate(specific_POD = ifelse(grepl("^op", specific_POD), "outpatient", specific_POD)) %>%
  mutate(specific_POD = ifelse(grepl("^ae", specific_POD), "ae", specific_POD)) %>%
  mutate(arr_date = as.Date(arr_date)) %>%
  mutate(dep_date = as.Date(dep_date))

# Add a row number column to prevent R thinking there are duplicates
theoplot_data$row_number <- seq_len(nrow(theoplot_data))

# Add a person number for anonymous labeling:
theoplot_data$instance_id <- dense_rank(theoplot_data$nhs_number)


# rename specific_POD or your alternative  POD column as 'POD'
theoplot_data <- theoplot_data %>%
  mutate(POD = specific_POD)

#This bit calculates length of stay, update inpatient POD names in the following if necessary so they match your data
#unique(theoplot_data$POD)
theoplot_data <- mutate(theoplot_data,
               LOS = if_else(specific_POD %in% c('ipnon_elective', 'ipelective'),
                             as.integer(as.Date(dep_date) - as.Date(arr_date)) + 1, 1),
               interval_index_activity = as.integer(as.Date(arr_date) - as.Date(index_event)))


#Ordering ready for the Theoplot
theoplot_data <- theoplot_data %>%
  arrange(nhs_number, arr_date) %>%
  group_by(nhs_number, POD, month = lubridate::month(arr_date)) %>%
  mutate(
    activity_num = dense_rank(arr_date), #activity number starts at 1 for each POD for each person
    PODactivity_num = dense_rank(arr_date), #POD activity starts at 1 and counts every activity sequentially (ignores if POD changes)
    POD_Month_activity_num = dense_rank(arr_date),
    LAG_arr_date = lag(arr_date)
  ) %>%
  ungroup() %>%
  mutate(contact = 1)
# library(writexl)
# write_xlsx(theoplot_data, "theoplot_data.xlsx")
# getwd()

##---- theoplot

#rename the PODs so that are they nice labels for the chart
#check your POD labels and amend if necessary
#unique(theoplot_data$POD)

theoplot_data <- theoplot_data %>% 
  filter (theoplot_data$POD != "other primary care") %>%
  mutate(POD = case_when(
    POD == "ipnon_elective"      ~ "Non elective admitted",
    POD == "ae"            ~ "A&E attendance",
    POD == "999"            ~ "999",
    POD == "111"            ~ "111",
    POD == "primary_care_contact_GP"         ~ "GP appointment",
    POD == "community"      ~ "Community",
    POD == "ipelective" ~ "Elective admitted",
    POD == "outpatient"     ~ "Outpatient",
    TRUE                    ~ POD  # Keep the original value if it doesn't match any of the conditions
  )) %>%
  mutate(instance_id=factor(instance_id,levels=(unique(instance_id)))) 
#unique(theoplot_data$POD)

#the next line alters the start point of the inpatient tiles (geom_tile centres the tile which does not look correct), 
#so the spell starts in the correct place (it is moved on by half the length of the tile)
#double check your POD names unique(theoplot_data$POD)
theoplot_data$xaxisplot <- ifelse(theoplot_data$POD %in% c("Elective admitted", "Non elective admitted"),
                                  (theoplot_data$interval_index_activity + (theoplot_data$LOS/2)),
                                  theoplot_data$interval_index_activity)


#plotting order - change this so that the most important to you is number 1 as this is plotted last and therefore "on top"
theoplot_data$orderPOD <- sapply(theoplot_data$POD, switch,
                                 "Non elective admitted" = 1,
                                 "A&E attendance"       = 2,
                                 "999"                  = 3,
                                 "111"                 = 4,
                                 "GP appointment"      = 5,
                                 "Community"           = 6,
                                 "Elective admitted"   = 7,
                                 "Outpatient"          = 8)


theoplot_data <- theoplot_data %>%  mutate(POD=factor(POD,levels=(unique(POD)))) 

#the next section generates the random sample of instances
#10 is the number of people sampled - change this to pull back a smaller or larger sample
theo_samples<-theoplot_data %>%
  distinct(instance_id) %>%
  sample_n(20, replace=T) 


#this section is the inpatient events only (they are plotted separately as tiles with no "jitter")
#check your POD names
nojit2 <- theoplot_data %>% 
  filter(instance_id %in% theo_samples$instance_id) %>% 
  #add the filter below if you want to focus on a set of dates nearer to your index event
  #filter(between(xaxisplot, -10, 10)) %>%
  filter(POD %in% c("Elective admitted", "Non elective admitted")) %>%
  arrange(instance_id, arr_date)

#this section is everything except the inpatient events (they are plotted as points with "jitter" to deal with overlaps)
#check your POD names
jit2<- theoplot_data %>% 
  filter(instance_id %in% theo_samples$instance_id) %>% 
  #add the filter below if you want to focus on a set of dates nearer to your index event
  #filter(between(xaxisplot, -10, 10)) %>%
  filter (!(POD %in% c("Elective admitted", "Non elective admitted"))) %>%
  arrange(instance_id, arr_date)

# Create the plot
theoplot_plot <- ggplot() +
  geom_tile(data = nojit2, aes(x = xaxisplot, y = instance_id, fill = POD, width = LOS), height = 0.75) +
  geom_point(data = jit2, aes(x = xaxisplot, y = instance_id, color = POD), size = 2) +
  scale_fill_manual(values = c(
    "Non elective admitted" = "#853358",
    "Elective admitted" = "#333333"
  ), drop = FALSE) +
  scale_color_manual(values = c(
    "A&E attendance" = "red",
    "999" = "#8AC0E5",
    "111" = "#2472AA",
    "GP appointment" = "#003087",
    "Community" = "#8d488d",
    "Outpatient" = "#95A5A6"
  ), drop = FALSE) +
  scale_y_discrete() +
  theme_bw() +
  bnssgtheme()+
  theme(axis.text.x = element_blank())+
  theme(axis.text.y = element_blank())+
  theme(axis.ticks.y = element_blank())+
  labs(title = theoplot_title,
       subtitle = proj_title)  +
  labs(x = "Time (days) ->  ", y = "Each horizontal line is a person", fill = "") +
  labs(color = "Legend Title") +
  guides(
    fill = guide_legend(override.aes = list(shape = 22), title = NULL),
    colour = guide_legend(override.aes = list(shape = 16), title = NULL)
  )


