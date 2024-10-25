bnssgtheme <- function(base_size = 12, base_family = "sans",base_colour = "black"){theme_bw() %+replace% theme(
  axis.title.x = element_text(size = 16, color = '#003087', face = 'bold', family = "sans", margin = margin(t = 0, r = 20, b = 0, l = 0)), #x Axis Titles
  axis.title.y = element_text(size = 16, color = '#003087', angle = 90, face = 'bold', family = "sans", margin = margin(t = 0, r = 20, b = 0, l = 0)), #y Axis Titles
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
  plot.title = element_text(size = 16, color = '#003087', face="bold", margin = margin(b = 10, t=10), hjust=0),
  plot.title.position = "plot", #suggested by via FB to align title to left of Y acis labels
  plot.subtitle = element_text(size = 10, margin = margin(b = 10), hjust=0),
    # Customize facet title appearance
  strip.background = element_blank(),  # Set background to white
  strip.text = element_text(face = "bold", family = "sans", size = 12)  # Set font to Arial 12 for facet titles
  ) 
}


## Colour Functions ####

bnssg_colours <- c(
  `white`           = "#FFFFFF",
  `light grey`      = "#999999",
  `light pink`      = "#D093B6",
  `mid pink`        = "#8d488d",
  `light blue`      = "#8AC0E5",
  `dark pink`       = "#853358",
  `mid blue`        = "#2472AA",
  `dark blue`       = "#003087",
  `dark grey`       = "#333333")

bnssg_cols <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (bnssg_colours)
  
  bnssg_colours[cols]
}


##Set colour 'names'scheme' names:
bnssg_palettes <- list(
  "main"  = bnssg_cols("light grey", "light pink", "mid pink", "light blue", "dark pink",
                       "mid blue", "dark blue", "dark grey"),
  "pgb" = bnssg_cols("dark pink", "mid pink", "light pink", "light grey", "light blue", "mid blue", "dark blue"),
  "pgblite" = bnssg_cols("dark pink", "light grey", "dark blue"),
  "pink" = bnssg_cols("dark pink", "mid pink", "light pink"),
  "blue" = bnssg_cols("dark blue", "mid blue", "light blue"),
  "mapcol" = bnssg_cols("dark blue", "mid blue", "light blue","light grey","white") #added by SH as useful for leaflet maps
)

##Function so that the colours can be found from the scheme name
bnssg_pal <- function(palette, reverse = FALSE, ...) {
  pal <- bnssg_palettes[[palette]]
  
  if (reverse) pal <- rev(pal)
  
  colorRampPalette(pal, ...)
}

#' Color scale constructor for BNSSG colors
#'
#' @param palette Character name of palette in drsimonj_palettes
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_color_gradientn(), used respectively when discrete is TRUE or FALSE
#'
scale_color_bnssg <- function(palette = "main", discrete = FALSE, reverse = FALSE, ...) {
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
