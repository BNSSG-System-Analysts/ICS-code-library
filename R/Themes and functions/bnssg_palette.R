## Colour Functions ####

bnssg_colours <- c(
  `white`           = "#FFFFFF",
  `midnight_blue`   = "#1C1F62",
  `dark_violet`     = "#D091FD",
  `royal_blue`      = "#045EDA",
  `grass_green`     = "#008247",
  `brilliant_purple`= "#8F00B6",
  `vivid_blue`      = "#049FC1",
  `lime_green`      = "#9EF101",
  `teal`            = "#73D4D3")

bnssg_cols <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (bnssg_colours)
  
  bnssg_colours[cols]
}


##Set colour 'names'scheme' names:
bnssg_palettes <- list(
  "main"  = bnssg_cols("midnight_blue", "dark_violet", "royal_blue", "grass_green", "brilliant_purple",
                       "vivid_blue", "lime_green", "teal"),
  "blpkgrn" = c("#1C1F62", "#045EDA", "#0DCFFA", "#D091FD", "#8F00B6", "#008080", "#35FFA4", "#9EF101"),
  "blgrn" = c("#1C1F62", "#045EDA", "#0DCFFA", "#E5FFB5", "#005730"  ),
  "blpk" = c("#1C1F62","#045EDA","#0DCFFA","#D091FD", "#8F00B6"),
  "pkgrn" = c("#D091FD","#8F00B6", "#008080", "#9EF101","#005730"),
  "blue_3" = c("#1C1F62","#045EDA", "#0DCFFA"),
  "blue_5" = c("#1C1F62","#045EDA", "#0DCFFA", "#888BDD","#0346A3"),
  "pink_5" = c("#420272", "#8F00B6", "#F3C4FF", "#E06CFF", "#CD11FF"),
  "pink_3"= c("#420272", "#8F00B6", "#F3C4FF"),
  "green_5" = c("#003B3D", "#008247","#E5FFB5","#00AD5F","#54B7B7"),
  "green_3" = c("#003B3D", "#008247","#E5FFB5"),
  "mapcol" = c("#1C1F62", "#045EDA", "#0DCFFA","grey")
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