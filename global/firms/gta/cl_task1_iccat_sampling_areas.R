setwd("D:/Documents/DEV/fdiwg/fdi-codelists")

require(sf)
require(plyr)

gpkg_path = "D:/Downloads/iccat_gis.gpkg"
layers = sf::st_layers(gpkg_path)
iccat_sampling_area_layers = layers$name[layers$name != "iccatarea"]
iccat_sampling_areas = do.call("rbind.fill", lapply(iccat_sampling_area_layers, function(x){
	sf::st_read(gpkg_path, x)
}))

#visualize
iccat_sampling_areas_sf = sf::st_sf(iccat_sampling_areas, sf_column_name = "geom")

#standardize
iccat_sampling_areas_sf$geom_wkt = sf::st_as_text(iccat_sampling_areas_sf$geom)
iccat_sampling_areas_sf = as.data.frame(iccat_sampling_areas_sf)
iccat_sampling_areas_sf$code = iccat_sampling_areas_sf$sareacod
iccat_sampling_areas_sf$uri = NA
iccat_sampling_areas_sf$label = iccat_sampling_areas_sf$code
iccat_sampling_areas_sf$definition = NA
iccat_sampling_areas_sf$geom = NULL

readr::write_csv(iccat_sampling_areas_sf, "global/firms/gta/cl_task1_iccat_sampling_areas.csv")