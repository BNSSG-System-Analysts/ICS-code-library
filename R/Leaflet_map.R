## ---- map
library(leaflet)

mapdata <- MPI_data %>% filter(cohort=="Cohort") %>% 
  group_by(lsoa11CD, imd_decile) %>% summarise(pop= sum(people)) %>% 
  ungroup() %>%
  filter(pop> 9) 

mapdata[, 2:2] <- lapply(mapdata[, 2:2], function(x) ifelse(is.na(x), 0, x)) 

markers <- gp_locations %>% select(practice_name,practice_latitude, practice_longitude) %>% 
    rename("marker" = "practice_name",
         "lat" = "practice_latitude",
         "long" = "practice_longitude")

# Import shape files - for example LSOA
lsoa_shp <-lsoa_shape %>%
st_transform('+proj=longlat +datum=WGS84') %>% 
filter(rowSums(sapply(c("South Gloucestershire", "Bristol", "North Somerset"), function(pattern) grepl(pattern, lsoa11nm))) > 0)
  
names(lsoa_shp) <- tolower(names(lsoa_shp))
names(mapdata) <- tolower(names(mapdata))

#trim white space (the join failed otherwise)
lsoa_shp$lsoa11cd <- trimws(lsoa_shp$lsoa11cd)
mapdata$lsoa11cd <- trimws(mapdata$lsoa11cd)

# Join shapes and data
lsoa_shp_data <- lsoa_shp %>% left_join(mapdata, by = "lsoa11cd")
lsoa_shp_data <- lsoa_shp_data %>%
  mutate(across(8:8, ~ifelse(is.na(.), 0, .))) %>%
  rename("population"="pop")

lsoa_shp_data$population[is.na(lsoa_shp_data$population)] <- 0

lsoa_shp_data <- lsoa_shp_data %>% filter(population >0)

lsoa_shp_data_imd1 <- lsoa_shp_data %>% filter (imd_decile %in% c(1,2))

cols_val1 <- colorNumeric(
  palette = bnssg_palettes[["mapcol"]], 
  domain = lsoa_shp_data$population,
  reverse = TRUE
)

# Calculate the bounding box of your shapefile
bbox <- st_bbox(lsoa_shp)
lat_mid <- as.numeric((bbox[2]+bbox[4])/2)
long_mid <- as.numeric((bbox[1]+bbox[3])/2)

map1 <- leaflet() %>%
  
  # can use default leaflet tiles or specify provider 
  addProviderTiles(provider = providers$CartoDB.Voyager) %>%
  
  # add LSOA shapes with colour coding
  addPolygons(data = lsoa_shp_data,
              fillColor = ~ifelse(population == 0, "transparent", cols_val1(population)),
              color = "black",
              stroke = T,
              weight = 1,
              fillOpacity = 0.8,
              
              #option to highlight area when hovering over it
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = T),
              
              #pop-up text
              popup = paste0("LSOA: ", lsoa_shp_data$lsoa11cd,
                             "<br> Value: ", lsoa_shp_data$population,
                             "<br>LA: ", lsoa_shp_data$lsoa11nmw)
              
  ) %>% 
  
  # add LSOA shapes with colour coding
  addPolygons(data = lsoa_shp_data_imd1,
              fillColor = ~ifelse(population == 0, "transparent", cols_val1(population)),
              color = "#C00079",
              stroke = T,
              weight = 1.3,
              fillOpacity = 0.6,
              
              #option to highlight area when hovering over it
              highlightOptions = highlightOptions(color = "white",
                                                  weight = 2,
                                                  bringToFront = T),
              
              #pop-up text
              popup = paste0("LSOA: ", lsoa_shp_data_imd1$lsoa11cd,
                             "<br> Value: ", lsoa_shp_data_imd1$population,
                             "<br>LA: ", lsoa_shp_data_imd1$lsoa11nmw),
              
              group = "IMD Quintile 1 LSOAs"
              
  ) %>% 
  
  # add legend for heat map
  addLegend("topleft", 
            pal = cols_val1, 
            values = lsoa_shp_data$population,
            title = "Number",
            opacity = 0.8) %>%
  #setView (lng = mean(lsoa_shp_data$st_areasha), lat = mean(lsoa_shp_data$st_lengths), zoom = 02)
  setView (lng = long_mid, lat = lat_mid, zoom = 10.4) %>%
  addMarkers(data = markers,
             lat = ~lat, 
             lng = ~long, 
             popup = ~marker,
             label = ~marker,
             clusterOptions = markerClusterOptions()
  )


# Create an HTML widget for the subtitle
subtitle_html <- HTML(
  '<div style="position: relative; bottom: 20px; right: 10px; 
  font-family: Arial, sans-serif; font-size: 12px; font-weight: normal; color: #003087; z-index: 99999;">', "Missing SWD data, 01/10/23", '</div>'
)

# Add the custom HTML subtitle to the map
map1 <- htmlwidgets::prependContent(map1, subtitle_html)

#######

