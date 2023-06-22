setwd("D:/Documents/DEV/fdiwg/fdi-codelists")

download.file("https://data.iotc.org/reference/1.0.0/domain/admin/shapefiles/IOTC_MAIN_AREAS_1.0.0_SHP.zip", destfile = "IOTC_MAIN_AREAS_1.0.0_SHP.zip", mode = "wb")
zipr::unzip("IOTC_MAIN_AREAS_1.0.0_SHP.zip")

sf::sf_use_s2(FALSE)
iotc_areas = sf::st_read("IOTC_MAIN_AREAS_1.0.0.shp")

iotc_areas$code = iotc_areas$CODE
iotc_areas$uri = NA
iotc_areas$label = iotc_areas$NAME_EN
iotc_areas$definition = NA
iotc_areas$geom_wkt = sf::st_as_text(iotc_areas$geometry)
iotc_areas = as.data.frame(iotc_areas[,c("code", "uri", "label", "definition", "geom_wkt")])
iotc_areas$geometry = NULL

readr::write_csv(iotc_areas, "global/firms/gta/cl_task1_iotc_areas.csv")