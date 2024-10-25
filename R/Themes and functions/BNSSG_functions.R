bnssgtheme <- function(base_size = 12, base_family = "sans",base_colour = "black"){theme_bw() %+replace% theme(
  axis.title.x = element_text(size = 16, color = '#1C1F62', face = 'bold', family = "sans", margin = margin(t = 0, r = 20, b = 0, l = 0)), #x Axis Titles
  axis.title.y = element_text(size = 16, color = '#1C1F62', angle = 90, face = 'bold', family = "sans", margin = margin(t = 0, r = 20, b = 0, l = 0)), #y Axis Titles
  axis.text = element_text(size = 12,  family = "sans", color = 'black'), #Axis text
  panel.border = element_blank(), #remove plot border
  panel.grid.major.x = element_blank(), #no major vertical lines
  panel.grid.major.y = element_line(linetype = 'dotted', linewidth = 1), #dotted major horizontal lines
  panel.grid.minor = element_blank(), #no minor lines
  legend.position = "top", #legend on top
  legend.location = "plot", #suggested by Seb via FB to align legend to new title position
  legend.justification='left', #legend left
  legend.direction='horizontal', #legend to be horizontal
  legend.title = element_blank(), #No legend title
  legend.text = element_text(size = 12, family = "sans",),
  legend.key.size = unit(0.3, "cm"),
  plot.title = element_text(size = 16, color = '#1C1F62', face="bold", margin = margin(b = 10, t=10), hjust=0),
  plot.title.position = "plot", #suggested by via FB to align title to left of Y acis labels
  plot.subtitle = element_text(size = 10, margin = margin(b = 10), hjust=0),
    # Customize facet title appearance
  strip.background = element_blank(),  # Set background to white
  strip.text = element_text(face = "bold", family = "sans", size = 12)  # Set font to Arial 12 for facet titles
  ) 
}


#### Colour Palette ####

##Sets the main colour palette:
bnssgcols <- c(`white` = "#FFFFFF",`midnight blue` = "#1C1F62",
               `dark Violet` = "#8605E4",`royal blue` = "#075EDB",
               `grass green` = "#00AE5F",`brilliant purple` = "#E16CFF",
               `vivid blue` = "#10CFFB",`lime green` = "#BFFF46",
               `red` = "#CC1166",`orange` = "#F6B200", `teal` = "#008080")

##Tells R Where to look for color codes, from the name
bnssg_cols <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (bnssgcols)
  
  bnssgcols[cols]
}

##Set colour 'names'scheme' names:
bnssg_palettes <- list(
  "main"  = bnssg_cols("midnight blue","royal blue","dark violet","brilliant purple",
                       "lime green","grass green","teal"),
  "pgb" = bnssg_cols("midnight blue","brilliant purple","grass green",
                     "royal blue"),
  "bgg" = bnssg_cols("midnight blue","grass green","lime green"),
  "midnight_blue" = c("#1C1F62","#C3C5EE","#888BDD","#4C51CC","#15174A","#0E1031"),
  "dark_violet" = c("#8504E3","#E7C8FE","#D091FD","#B85AFC","#6403AA","#420272"),
  "royal_blue" = c("#045EDA","#C6DEFE","#8EBDFD","#559BFC","#0346A3","#022F6D"),
  "grass_green" = c("#00AD5F","#BCFFE1","#78FFC2","#35FFA4","#008247","#005730"),
  "brilliant_purple" = c("#E06CFF","#F9E2FF","#F3C4FF","#ECA7FF","#CD11FF","#8F00B6"),
  "vivid_blue" = c("#0DCFFA","#CFF5FE","#9EECFD","#6EE2FC","#049FC1","#036A81"),
  "lime_green" = c("#BEFE45","#F2FFDA","#E5FFB5","#D8FE8F","#9EF101","#69A101")
)

##Function so that the colours can be found from the scheme name
bnssg_pal <- function(palette, reverse = FALSE, ...) {
  pal <- bnssg_palettes[[palette]]
  
  if (reverse) pal <- rev(pal)
  
  colorRampPalette(pal, ...)
}

#' Color scale constructor for BNSSG colors
#'
#' @param palette Character name of palette in bnssg_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_color_gradientn(), used respectively when discrete is TRUE or FALSE
#'
scale_colour_bnssg <- function(palette = "main", discrete = FALSE, reverse = FALSE, ...) {
  pal <- bnssg_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("color", paste0("bnssg_", palette), palette = pal, ...)
  } else {
    scale_colour_gradientn(colors = pal(256), ...)
  }
}

#' Fill scale constructor for BNSSG colors
#'
#' @param palette Character name of palette in bnssg_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_fill_gradientn(), used respectively when discrete is TRUE or FALSE
#'
scale_fill_bnssg <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- bnssg_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("fill", paste0("bnssg_", palette), palette = pal, ...)
  } else {
    scale_fill_gradientn(colours = pal(256), ...)
  }
}