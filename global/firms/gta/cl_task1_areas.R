setwd("D:/Documents/DEV/fdiwg/fdi-codelists")

require(ows4R)
require(jsonlite)
require(httr)

#read task1 ICCAT areas
#sampling areas
cl_task1_iccat_sampling_areas = readr::read_csv("global/firms/gta/cl_task1_iccat_sampling_areas.csv")
cl_task1_iccat_sampling_areas = cl_task1_iccat_sampling_areas[,c("code", "uri", "label", "definition", "geom_wkt")]
#stock areas
#TODO we miss these stock areas in the legacy task1 areas codelist: "ANE" "ANW" "ASE" "ASW" "AT" !!!
cl_task1_iccat_stock_areas = readr::read_csv("global/firms/gta/cl_task1_iccat_stock_areas.csv") 

#read task1 IOTC areas
cl_task1_iotc_areas = readr::read_csv("global/firms/gta/cl_task1_iotc_areas.csv")

#for IATTC, CCSBT, WCPFC, we grab the competence areas
WFS_FAO = WFSClient$new(
    url = "https://www.fao.org/fishery/geoserver/fifao/wfs",
    serviceVersion = "1.0.0",
    logger = "INFO"
)
rfb_comp_areas = WFS_FAO$getFeatures("fifao:RFB_COMP_CLIP", cql_filter = URLencode("RFB IN('CCSBT','IATTC','WCPFC')"))

rfb_vocab = httr::content(httr::GET("https://www.fao.org/figis/monikerj/figismapdata?format=jsonp"))
rfb_vocab = do.call("rbind", lapply(rfb_vocab$rfbs$rfb, function(rfb){
	data.frame(
		code = rfb$name, 
		uri = rfb$descriptor$link, 
		label = rfb$descriptor$title,
		definition = NA
	)
}))
rfb_comp_areas = merge(rfb_comp_areas, rfb_vocab, by.x = "RFB", by.y = "code")
rfb_comp_areas$geom_wkt = sf::st_as_text(rfb_comp_areas$geometry)
rfb_comp_areas = as.data.frame(rfb_comp_areas)
rfb_comp_areas$geometry = NULL
colnames(rfb_comp_areas)[colnames(rfb_comp_areas)=="RFB"] = "code"
rfb_comp_areas = rfb_comp_areas[,c("code", "uri", "label", "definition", "geom_wkt")]

#export cl_task1_areas.csv
cl_task1_areas = rbind(
	cbind(cl_task1_iccat_sampling_areas, tablesource = "cl_task1_iccat_sampling_areas"),
	cbind(cl_task1_iccat_stock_areas, tablesource = "cl_task1_iccat_stock_areas"),
	cbind(cl_task1_iotc_areas, tablesource = "cl_task1_iotc_areas"),
	cbind(rfb_comp_areas, tablesource = "rfb_comp")
)
readr::write_csv(cl_task1_areas, "global/firms/gta/cl_task1_areas.csv")