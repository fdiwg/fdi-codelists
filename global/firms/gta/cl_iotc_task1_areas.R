setwd("D:/Documents/DEV/fdiwg/fdi-codelists")
require(ows4R)

WFS_FAO = WFSClient$new(
	url = "https://www.fao.org/fishery/geoserver/fifao/wfs",
	serviceVersion = "1.0.0",
	logger = "INFO"
)
fao_major_areas = WFS$getFeatures("fifao:FAO_AREAS", cql_filter = URLencode("F_CODE IN('51','57')"))
fao_major_areas$code = paste0("F", fao_major_areas$F_CODE)
fao_major_areas$uri = NA
fao_major_areas$label = fao_major_areas$NAME_EN
fao_major_areas$definition = NA
fao_major_areas$geom_wkt = sf::st_as_text(fao_major_areas$the_geom)
fao_major_areas = as.data.frame(fao_major_areas[,c("code", "uri", "label", "definition", "geom_wkt")])
fao_major_areas$the_geom = NULL

readr::write_csv(fao_major_areas, "global/firms/gta/cl_iotc_task1_areas.csv")