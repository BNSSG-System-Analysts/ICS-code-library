#the data frame wider_determ can be created using the SQL script in the library called "ons oa cluster descriptions.sql"

wider_determ_data <- mpi %>%
  select(nhs_number, lsoa11CD, patient_group) %>%
  #filter(patient_group %in% c("Seg 4 or 5, 75+", "Seg 1-3, 65+", "Seg 5, complex lives")) %>%
  left_join(wider_determ, by = c("lsoa11CD" = "LSOA11CD")) %>%
  filter(!is.na(Local_Authority))

YPLLI <- wider_determ_data %>% group_by(patient_group) %>% 
  summarise(`Years of potential life lost` = round(mean(Years_of_potential_life_lost_indicator),0)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Years of potential life lost") %>%
  mutate(Polarity = "Low is good", Indicator = "Years of potential life lost")

takeways <- wider_determ_data %>% group_by(patient_group) %>% 
  filter(!is.na(FSA_Takeaway_Sandwich_Bar_Count)) %>%
  summarise(`Take away count` = round(mean(FSA_Takeaway_Sandwich_Bar_Count),1)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Take away count") %>%
  mutate(Polarity = "Low is good", Indicator = "Take away count")

education_16 <- wider_determ_data %>% group_by(patient_group) %>% 
  filter(!is.na(Staying_on_in_education_post_16_indicator)) %>%
  summarise(`Education 16+` = round(mean(Staying_on_in_education_post_16_indicator),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Education 16+") %>%
  mutate(Polarity = "Low is good", Indicator = "Education 16+")

eng_lang <- wider_determ_data %>% group_by(patient_group) %>% 
  filter(!is.na(Adult_skills_and_English_language_proficiency_indicator)) %>%
  summarise(`Adult skills & English Language` = round(mean(Adult_skills_and_English_language_proficiency_indicator),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Adult skills & English Language") %>%
  mutate(Polarity = "Low is good", Indicator = "Adult skills & English Language")

employment <- wider_determ_data %>% group_by(patient_group) %>% 
  filter(!is.na(Employment_Decile)) %>%
  summarise(`Average employment decile` = round(mean(Employment_Decile),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Average employment decile") %>%
  mutate(Polarity = "High is good", Indicator = "Average employment decile")

dist_gp_surg <- wider_determ_data %>% group_by(patient_group) %>% 
  filter(!is.na(Road_distance_to_a_GP_surgery_indicator)) %>%
  summarise(`Distance to GP surgery` = round(mean(Road_distance_to_a_GP_surgery_indicator),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Distance to GP surgery") %>%
  mutate(Polarity = "Low is good", Indicator = "Distance to GP surgery")

wider_determ_bnssg_data <- mpi %>%
  select(nhs_number, lsoa11CD, patient_group) %>%
  #filter(patient_group %in% c("Seg 4 or 5, 75+", "Seg 1-3, 65+", "Seg 5, complex lives")) %>%
  left_join(wider_determ_bnssg, by = c("lsoa11CD" = "LSOA11CD")) %>%
  filter(!is.na(local_authority))

time_ae <- wider_determ_bnssg_data%>% group_by(patient_group) %>% 
  filter(!is.na(travel_time_to_ae)) %>%
  summarise(`Travel time to A&E` = round(mean(travel_time_to_ae),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Travel time to A&E") %>%
  mutate(Polarity = "Low is good", Indicator = "Travel time to A&E")

time_miu <- wider_determ_bnssg_data%>% group_by(patient_group) %>% 
  filter(!is.na(travel_time_to_miu)) %>%
  summarise(`Travel time to MIU` = round(mean(travel_time_to_miu),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Travel time to MIU") %>%
  mutate(Polarity = "Low is good", Indicator = "Travel time to MIU")

house_overcrowd <- wider_determ_bnssg_data %>% group_by(patient_group) %>% 
  filter(!is.na(household_overcrowding_indicator)) %>%
  summarise(`Household overcrowding` = round(mean(household_overcrowding_indicator),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Household overcrowding") %>%
  mutate(Polarity = "Low is good", Indicator = "Household overcrowding")

homelessness <- wider_determ_bnssg_data %>% group_by(patient_group) %>% 
  filter(!is.na(homelessness_indicator_rate_per_1000_households)) %>%
  summarise(`Homelessness` = round(mean(homelessness_indicator_rate_per_1000_households),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Homelessness") %>%
 mutate(Polarity = "Low is good", Indicator = "Homelessness")

fuel_pov <- wider_determ_bnssg_data %>% group_by(patient_group) %>% 
  filter(!is.na(estimated_number_of_fuel_poor_households)) %>%
  summarise(`Fuel poverty` = round(mean(estimated_number_of_fuel_poor_households),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Fuel poverty") %>%
 mutate(Polarity = "Low is good", Indicator = "Fuel poverty")

poor_housing <- wider_determ_bnssg_data %>% group_by(patient_group) %>% 
  filter(!is.na(housing_in_poor_condition_indicator)) %>%
  summarise(`Poor condition housing` = round(mean(housing_in_poor_condition_indicator),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Poor condition housing") %>%
  mutate(Polarity = "Low is good", Indicator = "Poor condition housing")

outdoors <- wider_determ_bnssg_data %>% group_by(patient_group) %>% 
  filter(!is.na(outdoors_sub_domain_decile)) %>%
  summarise(`Outdoors subdomain decile` = round(mean(outdoors_sub_domain_decile),2)) %>% ungroup %>%
  pivot_wider(names_from = "patient_group", values_from = "Outdoors subdomain decile") %>%
  mutate(Polarity = "High is good", Indicator = "Outdoors subdomain decile")

wider_determ_summary <-
  rbind(YPLLI, takeways, education_16, eng_lang, employment, dist_gp_surg, time_ae, time_miu, 
        house_overcrowd, homelessness, fuel_pov, poor_housing,outdoors) %>%
      select("Indicator", "Polarity", everything())


# Function to create a color scale for a row
get_color_scale <- function(x, color = "#D093B6", reverse = FALSE) {
  scaled <- rescale(x, to = c(0, 1))
  if (reverse) {
    scaled <- 1 - scaled
  }
  colors <- col_numeric(palette = c("white", color), domain = c(0, 1))(scaled)
  return(colors)
}

# Create the gt table
wider_determ_summary_gt <- wider_determ_summary %>% 
  gt() %>% 
  tab_header(
    title = md("**Wider determinants, BNSSG, 2023**"),
    subtitle = "Average of patient group"
  ) %>%
  tab_footnote(proj_title) %>%
  tab_style(
    style = list(
      cell_text(font = "sans-serif")
    ),
    locations = cells_body()
  ) %>%
  tab_style(
    style = cell_text(color = "#003087"),
    locations = cells_title()
  ) %>%
  tab_style(
    style = list(
      cell_text(size = "10px"),
      cell_text(color = "#003087")
    ),
    locations = cells_footnotes()
  ) %>%
  tab_options(
    table.font.size = 14,
    heading.title.font.size = 18,
    heading.title.font.weight = "bold"
  )

# Apply conditional formatting for each row individually
for (i in 1:nrow(wider_determ_summary)) {
  row_data <- as.numeric(wider_determ_summary[i, 3:10])
  
  # Reverse the scale for rows 5 and 13
  if (i == 5 || i == 13) {
    row_colors <- get_color_scale(row_data, reverse = TRUE)
  } else {
    row_colors <- get_color_scale(row_data)
  }
  
  for (j in 1:length(row_colors)) {
    wider_determ_summary_gt <- wider_determ_summary_gt %>%
      tab_style(
        style = cell_fill(color = row_colors[j]),
        locations = cells_body(
          columns = j + 2,  # Adjusting the column index for gt table
          rows = i
        )
      )
  }
}

# Display the table
wider_determ_summary_gt



# Define the path 
path <- "C:/Sarah's off line folder/Git/UrgentCareSystemStrategy/02 Data_Images/"

# Save the plot
gtsave(wider_determ_summary_gt, "wider_determ_summary_gt.png", path = path)
