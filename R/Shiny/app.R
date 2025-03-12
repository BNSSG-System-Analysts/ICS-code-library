### BNSSG BASIC SHINY APP TEMPLATE ###

## Set up ----

# packages
library(tidyverse) #data manipulation
library(janitor) #clean_names and round_half_up
library(readxl) #import excel spreadsheets
library(sf) #import geography files (shapes)
library(leaflet) #for mapping
library(here) #project directory working
library(shiny) #create shiny app
library(bslib) #modern UI toolkit for shiny based on bootstrap
library(DT) #tables

# colour palette
palette <- c("#1C1F62", "#D091FD", "#045EDA", "#008247", 
             "#8F00B6", "#049FC1", "#9EF101", "#73D4D3")

# set BNSSG bslib theme
bnssg_theme <- bs_theme(
  
  # high level theming
  version = 5, # bootstrap v5 required to use bslib components (like cards etc.)
  bg = "white", # make background white
  fg = "#222", # make foreground darkgrey/black
  primary = palette[1], #main colour for buttons, etc
  secondary = palette[3],  
  bootswatch = "shiny", # use default shiny theme
  base_font = "Arial",
  
) %>% 
  
  # lower level theming
  bs_add_rules(
    list(
      # header/text styling 
      "h1 {font-size:30px; font-weight: bold; color: #1C1F62;}",
      "h2 {font-size:26px; font-weight: bold; color: #1C1F62;}",
      "h3 {font-size:18px; font-weight: bold; color: #1C1F62;}",
      "h4 {font-size:14px; font-weight: bold; color: #1C1F62;}",
      # tab header settings
      ".navbar-nav .nav-link {font-size: 16px;}",
      ".navbar-nav .nav-link.active {color: #1C1F62;}",
      # logo position in navigation bar
      ".navbar .navbar-brand {
        display: flex;
        align-items: center;
        padding: 0 !important;
        height: 100%;
      }
      .navbar .navbar-brand img {
        height: 70px;
        margin-right: 10px;
      }"
    )
  )


# load dummy data for map and R dataset mtcars
dummy_map_data <- tibble(variable = c("Option 1", "Option 2", "Option 3"),
                         lat = c(51.54224, 51.52900, 51.45457),
                         long = c(-2.411816, -2.499227, -2.433032))

data("mtcars")

   
## App layout (ie. user interface) ----
ui <- page_navbar(
  
  id = "nav",# id used for jumping between tabs
  
  # add BNSSG theme created in set up
  theme = bnssg_theme,
  
  # Format logo in Navbar
  
  # then add logo with link to HT website
  title = div(
    tags$a(
      img(
        src = "ht_logo.png",
        href = "https://bnssghealthiertogether.org.uk/",
        target = "_blank"
      )
    ),
    style = "background-color: white;" # Keeps white background
  ),
  
  # browser title
  window_title = "Name for browser tab",
  
  # browser icon
  header = tags$head(tags$link(rel = "shortcut icon", href = "ht_logo_cut.png") 
  ),
  
  # Home tab
  nav_panel("Home",
            icon = icon("home"),
            h1("Name of your app"),
            h2("Intro"),
            p("Background and context added here"),
            h2("How to use this tool"),
            p("Some explanations here"),
            h2("Contact")
  ),
  
  # Contents tab
  nav_panel("Tab 1",
            icon = icon("map"),
            
            # column layout to easily modify width of "cards"
            layout_columns(
              
              # Card with input selection
              card(
                
                h2("Select your inputs"),
                
                selectInput("myinputname", 
                            label = "Example drop-down",
                            choices = c("Option 1", "Option 2", "Option 3"))
                
              ),
              
              # Card with tabs and visuals
              card(
                
                h2("Select your data view"),
                
                navset_card_underline(
                  
                  nav_panel("Map",
                            leafletOutput("mymap", height = 600)),
                  
                  nav_panel("Table",
                            DTOutput('mytable'))
                )
                
              ),
              
              # width of each card - full width is 12
              col_widths = c(4, 8)
              
            )
            
  ),
  
  # footer with BNSSG colour (option to add text and other logos in here)
  footer = div(
    style = paste("background-color:", palette[1], "; padding: 10px 0; text-align: right; height: 70px;"))
  
)
  


## Server logic ----
server <- function(input, output) {

  # create a reactive datasets based on inputs selected
  mapdat <- reactive({

      dummy_map_data %>%
        filter(variable == input$myinputname)

  })
  
  # create a map
  output$mymap <- renderLeaflet({
    
    leaflet() %>%
      
      addProviderTiles(provider =  providers$CartoDB.Voyager) %>% 
      
      addMarkers(data = mapdat(),
                 lat = ~lat, 
                 lng = ~long,
      )
    
  })
  
  # create a table
  output$mytable <- renderDT({mtcars})
  
}

# Run the application 
shinyApp(ui = ui, server = server)
