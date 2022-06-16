library(sf)
# library(raster)
library(av)
library(tmap)    # for static and interactive maps
library(ggplot2) # tidyverse data visualization package

source("src/load_data.R")
source("src/oblasts.R")


ukraine <- read_sf("data/ukraine.geojson")


sirens_map <- data.frame(colors = NULL, shapeISO = NULL)
# Tuesday, March 15, 2022 12:00:01 AM GMT+02:00
sirens_from <- 1647295200
# Wednesday, June 15, 2022 0:00:01 GMT+03:00
sirens_to <- 1655240400
# frames: 4414
sirens_step <- 30 * 60
# sirens less than 10 minutes will not be shown
sirens_offset <- 10 * 60


# initial data
# for (oblast in oblasts){
#   color <- "white"
#
#   if(oblast[["shapeISO"]] %in% c("UA-65", "UA-09", "UA-43", "UA-40")){
#     color <- "black"
#   }
#
#   sirens_map <- rbind(sirens_map, data.frame(time=sirens_from, colors=c(color), shapeISO=c(oblast[["shapeISO"]])))
# }

# current_time <- sirens_from
# while(current_time < sirens_to){
#   current_time <- current_time + sirens_step
#
#   for (oblast in oblasts){
#     color <- "white"
#
#     if(oblast[["shapeISO"]] %in% c("UA-65", "UA-09", "UA-43", "UA-40")){
#       color <- "black"
#     } else {
#       # determining whether the siren is active
#
#       for(siren in all_sirens)
#
#     }
#
#     sirens_map <- rbind(sirens_map, data.frame(time=sirens_from, colors=c(color), shapeISO=c(oblast[["shapeISO"]])))
#   }
#
# }

for (siren in all_sirens) {
  region <- siren[["region"]]

  oblast_iso <- ""

  for (oblast in oblasts) {
    if (oblast[["name"]] == region) {
      oblast_iso <- oblast[["shapeISO"]]
      break
    }
  }

  # find all standardized times [sirens_step + offset] that match and populate them as red

  start <- siren[["start"]]
  start_rounded <- ((start - sirens_offset) %/% sirens_step) * sirens_step
  end <- siren[["end"]]
  end_rounded <- ((end + sirens_offset) %/% sirens_step) * sirens_step

  timer <- start_rounded
  while (timer <= end_rounded) {
    if (timer >= sirens_from && timer <= sirens_to) {
      sirens_map <- rbind(sirens_map, data.frame(time = timer, colors = "red", shapeISO = oblast_iso))
    }

    timer <- timer + sirens_step
  }

}


sirens_map_filler <- data.frame(colors = NULL, shapeISO = NULL)
timer <- sirens_from

# to-do finish this
# to-do it does not look good :()
while (timer <= sirens_to) {
  # added_oblasts = c()
  #
  # for(i in 1:nrow(sirens_map)){
  #   record <- sirens_map[i, ]
  #   # todo remove 1st frame data & do not check for color
  #   if (record[["time"]] == timer && record[["colors"]] == "red"){
  #     added_oblasts <- c(added_oblasts, record[["shapeISO"]])
  #   }
  # }

  for (oblast in oblasts) {
    if (oblast[["shapeISO"]] %in% c("UA-65", "UA-09", "UA-43", "UA-40")) {
      sirens_map_filler <- rbind(sirens_map_filler, data.frame(time = timer, colors = "black", shapeISO = (oblast[["shapeISO"]])))
    }
  }

  timer <- timer + sirens_step
}

sirens_map <- rbind(sirens_map, sirens_map_filler)
ukraine_sirens <- merge(ukraine, sirens_map, by = "shapeISO")


tmap_mode("view")

# https://sodp.org.uk/how-to-create-animated-maps-in-r/
tm <- tm_shape(ukraine_sirens) +
  tm_borders() +
  tm_polygons(col = "colors", palette = "cat") +
  tm_layout(legend.outside = FALSE) +
  tm_facets(along = "time", as.layers = TRUE, drop.empty.facets = FALSE, showNA = TRUE, textNA = "Missing Name", drop.NA.facets = F)
# tm_fill("colors")
# tm_text("shapeName", size="AREA")+
# tm_facets(along = "year", free.coords = FALSE)

tmap_animation(tm, "vid.mp4", fps = 10, width = 850, height = 578, framerate = 24)

