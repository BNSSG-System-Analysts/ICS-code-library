#In the Quarto document:
  
  ```{r, fig.width=9, fig.height = 6}
girafe(ggobj = chart_seg_imd,
       options = list(
         opts_tooltip(css= "font-family: Arial; padding:3pt; color:white; background-color:#003087; border-radius:5px")))
```



#In the R script, note the interactive() line
  chart_seg_imd <- seg_imd %>% 
  ggplot(aes(x = segment, y = imd_quintile, fill = `% population`,
             tooltip = paste("% population: ", `% population`, "\nPopulation: ", population))) +
  geom_tile_interactive() +
  scale_fill_bnssg(palette = "blue", reverse=TRUE, discrete = FALSE) +
  bnssgtheme() +
  theme(legend.title=element_text(size = 12, family = "sans"),
        legend.key.width = unit(1.5, "cm"),
        axis.text = element_text(size = 8,  family = "sans", color = 'black'))+
  # Adjust the width of the legend key +
  labs(title = paste0("% of ",ltc_name," CMS segment and IMD quintile, \nBNSSG, ",attribute_date),
       x = "CMS Segment",   # Add x-axis title
       y = "IMD Quintile") +  # Add y-axis title
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5,vjust=0.5),
        panel.grid.major.y = element_line(color = "grey90", size = 0.2,linetype = 'solid'),  # Add grey grid lines
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey90", size = 0.2),  # Add grey grid lines
        panel.grid.minor.x = element_blank())+
  labs(subtitle = proj_title)
