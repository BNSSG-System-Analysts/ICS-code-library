## ---- ISR_function

### more information and guidance about how to use this function can be found in the Git repo:
### https://github.com/BNSSG-PHM/ISR.git

#these two variables are used in the chart titles / subtitles
proj_title <- "ISR demo" #amend as necessary
isr_chart_date <- "April 2018 to February 2024" #amend as necessary, you may have a date range for activity or a single date for prevalence

calculate_isr <- function(data, subgroup_column, events_column, title_column) {
  data <- data %>%
    select(subgroup = !!(sym(subgroup_column)), age_band, sex, people, events = !!sym(events_column))
  
  bnssg <- data %>%
    group_by(age_band, sex) %>%
    summarise(
      bnssg_people = sum(people),
      bnssg_events = sum(events)
    ) %>% ungroup
  
  data <- data %>%
    left_join(bnssg, by =c ("age_band", "sex")) %>%
    mutate(bnssg_rate = (bnssg_events / bnssg_people)*1000) %>%
    mutate(expected = (people*bnssg_rate)/1000)
  
  isr <- data %>%
    group_by(subgroup) %>%
    summarise(
      actual = sum(events),
      population = sum(people),
      expected = sum(expected)
    ) %>% ungroup() %>%
    #mutate(ISR = round((actual / expected) * 100, 2)) %>%
    mutate(ISR = round(ifelse(actual == 0, 0, actual / expected) * 100, 2)) %>%
    mutate(var_isr = actual/expected^2) %>%
      mutate(
      Upper_95_CI = ISR + (((ISR / ifelse(sqrt(actual) == 0, NA, sqrt(actual))) * 1.96) * ifelse(sqrt(actual) == 0, 0, 1)),
      Lower_95_CI = ISR - (((ISR / ifelse(sqrt(actual) == 0, NA, sqrt(actual))) * 1.96) * ifelse(sqrt(actual) == 0, 0, 1))
    ) %>%
    mutate(
      Upper_95_CI = round(Upper_95_CI, 2),
      Lower_95_CI = round(Lower_95_CI, 2)
    ) %>%
    mutate(Significance = if_else(Upper_95_CI > 100 & Lower_95_CI > 100, 'Y',
                                  if_else(Upper_95_CI < 100 & Lower_95_CI < 100, 'Y', 'N')))
  
  isr$subgroup <- factor(isr$subgroup)
  
  axis_title <- subgroup_column
  
  isr_plot <- ggplot(isr,aes(reorder(subgroup, ISR), ISR)) + 
    bnssgtheme() +
    geom_bar(aes(fill = Significance), stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = Lower_95_CI, ymax = Upper_95_CI), width = 0.5, colour="black", size= 0.5) + 
    theme(axis.ticks.y = element_blank()) +
    geom_text(aes(label = str_wrap(round(ISR,0), width = 10), y = Lower_95_CI - 7), 
              position = position_dodge(width = 0.9), hjust = 0, size=4, family = "sans") +
    labs(y = "Age / sex ISR (BNSSG = 100)", fill = "Significant") +  # Include fill legend title here
    xlab(axis_title)+
    scale_fill_manual(values = c("N" = "#999999", "Y" = "#8AC0E5")) +
    guides(fill = guide_legend(nrow = 1)) +
    geom_hline(yintercept = 100, linetype = "solid", color = "#003087", linewidth= 0.2) +
    coord_flip() +
    ylim(0, max(isr$Upper_95_CI) + 10) +
    theme(legend.title=element_text(size = 12, family = "sans"))+
    labs(title = paste0(title_column," ISRs, BNSSG, ", isr_chart_date),
         subtitle = proj_title) 
  
  isr_plot2 <- ggplot(isr, aes(subgroup, ISR)) + 
    bnssgtheme() +
    geom_bar(aes(fill = Significance), stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = Lower_95_CI, ymax = Upper_95_CI), width = 0.5, colour="black", size= 0.5) + 
    theme(axis.ticks.y = element_blank()) +
    geom_text(aes(label = str_wrap(round(ISR,0), width = 10), y = Lower_95_CI - 7), 
              position = position_dodge(width = 0.9), hjust = 0, size=4, family = "sans") +
    labs(x =  axis_title, y = "Age / sex ISR (BNSSG = 100)", fill = "Significant") +  # Include fill legend title here
    scale_fill_manual(values = c("N" = "#999999", "Y" = "#8AC0E5")) +
    guides(fill = guide_legend(nrow = 1)) +
    geom_hline(yintercept = 100, linetype = "solid", color = "#003087", linewidth= 0.2) +
    coord_flip() +
    ylim(0, max(isr$Upper_95_CI) + 10) +
    theme(legend.title=element_text(size = 12, family = "sans"))+
    labs(title = paste0(title_column," ISRs, BNSSG, ", isr_chart_date),
         subtitle = proj_title) 
  # Assigning names to the plot and dataframe
  plot_name <- paste0(subgroup_column, "_", events_column, "_ISR_plot")
  plot_name2 <- paste0(subgroup_column, "_", events_column, "_ISR_plot2")
  tbl_name <- paste0(subgroup_column, "_", events_column, "_ISR_tbl")
  
  assign(plot_name, isr_plot, envir = .GlobalEnv)
  assign(plot_name2, isr_plot2, envir = .GlobalEnv)
  assign(tbl_name, isr, envir = .GlobalEnv)
  
  return(invisible(NULL))  # Returning invisible NULL to suppress printing of plot and dataframe
}

