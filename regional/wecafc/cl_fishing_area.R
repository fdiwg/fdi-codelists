#setwd("D:/Documents/DEV/fdiwg/fdi-codelists/regional/wecafc")
require(ows4R)
require(readr)

WFS = WFSClient$new(url = "https://www.fao.org/fishery/geoserver/wfs", serviceVersion = "1.0.0", logger = "INFO")
sf.areas = WFS$getFeatures("fifao:FAO_AREAS_ERASE_LOWRES", cql_filter = URLencode("(F_AREA = '31' AND F_CODE NOT IN('31')) OR F_CODE IN('41.1','41.1.1','41.1.2','41.1.4')"))
wecafc_fishing_areas = data.frame(
	code = sf.areas$F_CODE,
	uri = NA,
	label = sf.areas$F_NAME,
	definition = NA,
	stringsAsFactors = FALSE
)
wecafc_fishing_areas = wecafc_fishing_areas[order(wecafc_fishing_areas$code),]
readr::write_csv(wecafc_fishing_areas, "cl_fishing_area.csv")