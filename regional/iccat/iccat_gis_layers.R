
#original file on the web
#https://www.iccat.int/Documents/Gis/ICCAT_gis.rar

iccat_gis_gpkg = "D:/Downloads/ICCAT_gis/ICCAT_gis.gpkg"
iccat_layers = sf::st_layers(iccat_gis_gpkg)

iccat_sa_layers = iccat_layers[regexpr("sampling_areas", iccat_layers$name)>0,]

iccat_sa = do.call("rbind", lapply(iccat_sa_layers$name, function(l){
  sfl = sf::st_read(iccat_gis_gpkg, layer = l)
  if("stock_oth" %in% colnames(sfl)) sfl$stock = sfl$stock_oth
  sfl = sfl[,c("CODE","NAME_EN","NAME_ES","NAME_FR","stock")]
  return(sfl)
}))
sf::st_write(iccat_sa, file.path("regional/iccat", "iccat_sampling_areas.gpkg"))

iccat_stock_layers = iccat_layers[regexpr("stock_areas", iccat_layers$name)>0,]
iccat_stocks = do.call("rbind", lapply(iccat_stock_layers$name, function(l){
  sfl = sf::st_read(iccat_gis_gpkg, layer = l)
  if(l == "other_species_stock_areas"){
    sfl$NAME_EN = sfl$CODE
    sfl$NAME_ES = sfl$CODE
    sfl$NAME_FR = sfl$CODE
  }
  sfl = sfl[,c("CODE","NAME_EN","NAME_ES","NAME_FR")]
  return(sfl)
}))
sf::st_write(iccat_stocks, file.path("regional/iccat", "iccat_stocks.gpkg"))

setwd("../fdi-mappings/regional-to-regional/iccat")

iccat_sa$geom = NULL
sa_to_stock = unique(iccat_sa[,c("CODE","stock")])
sa_to_stock = data.frame(
	src_code = sa_to_stock$CODE,
	trg_code = sa_to_stock$stock,
	src_codingsystem = "iccat_sampling_areas",
	trg_codingsystem = "iccat_stocks",
	stringsAsFactors = F
)
readr::write_csv(sa_to_stock, "codelist_mapping_iccat_sampling_areas_iccat_stocks.csv")