# Define the path 
path <- "C:/Sarah's off line folder/Git/UrgentCareSystemStrategy/02 Data_Images/"

# Save the plot
gtsave(gt_ISR_convey, "perc_missing_amb_wait_table.png", path = path)


#example gt table
gt_ISR_convey <- gt(Patient_group_events_ISR_tbl) %>% cols_width(
  `Patient Group` ~ px(170),
  everything() ~px(100)) %>%
  cols_align(align = "right") %>%
  cols_align(align = "left",
             columns = `Patient Group`) %>%
  tab_header(title = md("**Ambulance conveyance ISRs, BNSSG, 2023**"),
             subtitle = "Indirectly standardised for age and sex against BNSSG population") %>%
  tab_footnote(proj_title) %>%
  tab_style(
    style = list(
      "font-family" = "sans-serif"
    ),
    locations = cells_body()
  ) %>%
  tab_style(
    style = list(
      cell_text(color = "#003087")
    ),
    locations = cells_title()
  ) %>%
tab_style(
    style = list(
      cell_text(size = "8px"),
      cell_text(color = "#003087")
    ),
    locations = cells_footnotes()
  ) %>%
  tab_options(
    table.font.size = 14,
    heading.title.font.size = 18,
    heading.title.font.weight = "bold"
  )

