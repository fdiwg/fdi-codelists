setwd("D:/Documents/DEV/fdiwg/fdi-codelists")

require(ows4R)
require(jsonlite)
require(httr)

WFS_FAO = WFSClient$new(
	url = "https://www.fao.org/fishery/geoserver/wfs",
	serviceVersion = "1.0.0",
	logger = "DEBUG"
)

#read task1 ICCAT areas
iccat_layers = sf::st_layers("./global/firms/gta/ICCAT_main_areas.gpkg")
iccat_layers = iccat_layers$name[startsWith(iccat_layers$name, "ICCAT area")]

cl_nc_iccat_areas = do.call("rbind", lapply(iccat_layers, function(iccat_layer){
	sf::st_read("./global/firms/gta/ICCAT_main_areas.gpkg", layer = iccat_layer)
}))

cl_nc_iccat_areas$code = cl_nc_iccat_areas$CODE
cl_nc_iccat_areas$uri = NA
cl_nc_iccat_areas$label = cl_nc_iccat_areas$NAME_EN
cl_nc_iccat_areas$definition = NA
cl_nc_iccat_areas = cl_nc_iccat_areas[,c("code", "uri", "label", "definition")]
sf::st_geometry(cl_nc_iccat_areas) = "geom_wkt"
cl_nc_iccat_areas = as.data.frame(cl_nc_iccat_areas)
cl_nc_iccat_areas$geom_wkt = as(sf::st_as_text(cl_nc_iccat_areas$geom_wkt), "character")

#read task1 IOTC areas
cl_nc_iotc_areas = readr::read_csv("global/firms/gta/cl_nc_iotc_areas.csv") %>% as.data.frame()

#for IATTC, CCSBT, WCPFC, IOTC, we grab the competence areas
rfb_comp_areas = WFS_FAO$getFeatures("fifao:RFB_COMP_CLIP", cql_filter = URLencode("RFB IN('WCPFC','IOTC')"))
rfb_comp_areas = do.call("rbind", lapply(unique(rfb_comp_areas$RFB), function(rfb){
	rfbarea = cbind(RFB = rfb, sf::st_sf(geom = sf::st_union(rfb_comp_areas[rfb_comp_areas$RFB == rfb,])))
	return(rfbarea)
}))

rfb_vocab = jsonlite::read_json("https://www.fao.org/figis/monikerj/figismapdata?format=jsonp")
rfb_vocab = do.call("rbind", lapply(rfb_vocab$rfbs$rfb, function(rfb){
	data.frame(
		code = rfb$name, 
		uri = rfb$descriptor$link, 
		label = rfb$descriptor$title,
		definition = NA
	)
}))
rfb_comp_areas = merge(rfb_comp_areas, rfb_vocab, by.x = "RFB", by.y = "code")
rfb_comp_areas$geom_wkt = as(sf::st_as_text(rfb_comp_areas$geometry), "character")
rfb_comp_areas = as.data.frame(rfb_comp_areas)
rfb_comp_areas$geometry = NULL
colnames(rfb_comp_areas)[colnames(rfb_comp_areas)=="RFB"] = "code"
rfb_comp_areas = rfb_comp_areas[,c("code", "uri", "label", "definition", "geom_wkt")]

#Areas in support of CCSBT NC
wcpo = WFS_FAO$getFeatures("fifao:PAC_TUNA_REP", cql_filter = URLencode("REP_AREA = 'WCPO'"))
continent = WFS_FAO$getFeatures("fifao:UN_CONTINENT2")
wcpo_erased = sf::st_difference(wcpo, continent)
WCPO = data.frame(
	code = "WCPO",
	uri = NA,
	label = "Western and Central Pacific Ocean",
	definition = "Western and Central Pacific Ocean",
	geom_wkt = as(sf::st_as_text(sf::st_union(wcpo_erased)), "character")
)
#Areas in support of IATTC
epo = WFS_FAO$getFeatures("fifao:PAC_TUNA_REP", cql_filter = URLencode("REP_AREA ='EPO'"))
epo_erased = sf::st_difference(epo, continent)
EPO = data.frame(
	code = "EPO",
	uri = NA,
	label = "Eastern Pacific Ocean",
	definition = "Eastern Pacific Ocean",
	geom_wkt = as(sf::st_as_text(sf::st_union(epo_erased)), "character")
)

#export cl_nc_areas.csv
cl_nc_areas = rbind(
	cl_nc_iccat_areas,
	cl_nc_iotc_areas,
	rfb_comp_areas,
	WCPO,
	EPO
)
readr::write_csv(cl_nc_areas, "global/firms/gta/cl_nc_areas.csv")