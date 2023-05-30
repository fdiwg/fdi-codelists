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
colnames(iccat_sampling_areas)[colnames(iccat_sampling_areas) == "geom"] = "geom_wkt"
iccat_sampling_areas$code = iccat_sampling_areas$sareacod
iccat_sampling_areas$uri = NA
iccat_sampling_areas$label = iccat_sampling_areas$code
iccat_sampling_areas$definition = NA

sf::st_write(iccat_sampling_areas, "global/firms/gta/cl_iccat_sampling_areas.csv")