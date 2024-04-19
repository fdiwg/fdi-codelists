require(ows4R)

FAO_WFS = ows4R::WFSClient$new(
	url = "https://www.fao.org/fishery/geoserver/cwp/wfs",
	serviceVersion = "1.0.0",
	logger = "INFO"
)

grid_layers = FAO_WFS$getFeatureTypes(T)

#grids (non-erased)
grids = grid_layers[!endsWith(grid_layers$name, "erased"),]$name
grids = grids[regexpr("min", grids)<0]
cl_areal_grid = do.call("rbind", lapply(grids, function(x){FAO_WFS$getFeatures(x)}))
cl_areal_grid$gml_id = NULL
cl_areal_grid = cbind(
	data.frame(
		code = cl_areal_grid$CWP_CODE,
		uri = NA,
		label = cl_areal_grid$CWP_CODE,
		definition = NA
	),
	cl_areal_grid
)
cl_areal_grid$geom_wkt = sf::st_as_text(cl_areal_grid$the_geom)
cl_areal_grid = as.data.frame(cl_areal_grid)
cl_areal_grid$the_geom = NULL
sf::st_write(cl_areal_grid, "cl_areal_grid.csv")

cl_area_grid_nogeom = readr::read_csv("cl_areal_grid.csv")
cl_area_grid_nogeom = cl_area_grid_nogeom[,1:4]
readr::write_csv(cl_area_grid_nogeom, "cl_areal_grid_nogeom.csv")

#erased grids
grids_erased = grid_layers[endsWith(grid_layers$name, "erased"),]$name
cl_areal_grid_erased = do.call("rbind", lapply(grids_erased, function(x){FAO_WFS$getFeatures(x)}))
cl_areal_grid_erased$gml_id = NULL
cl_areal_grid_erased = cbind(
	data.frame(
		code = cl_areal_grid_erased$CWP_CODE,
		uri = NA,
		label = cl_areal_grid_erased$CWP_CODE,
		definition = NA
	),
	cl_areal_grid_erased
)
cl_areal_grid_erased$geom_wkt = sf::st_as_text(cl_areal_grid_erased$the_geom)
cl_areal_grid_erased = as.data.frame(cl_areal_grid_erased)
cl_areal_grid_erased$the_geom = NULL
sf::st_write(cl_areal_grid_erased, "cl_areal_grid_erased.csv")

cl_area_grid_erased_nogeom = readr::read_csv("cl_areal_grid_erased.csv")
cl_area_grid_erased_nogeom = cl_area_grid_erased_nogeom[,1:4]
readr::write_csv(cl_area_grid_erased_nogeom, "cl_areal_grid_erased_nogeom.csv")