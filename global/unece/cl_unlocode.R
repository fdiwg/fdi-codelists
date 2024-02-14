setwd("D:/Documents/DEV/fdiwg/fdi-codelists/global/unece")

require(readr)
require(sf)
sf::sf_use_s2(FALSE)

tmp = tempfile(fileext = ".zip")
download.file("https://service.unece.org/trade/locode/loc232csv.zip", destfile = tmp)
zip::unzip(tmp)

data_files = list.files(pattern = "CodeListPart")
cl = do.call("rbind", lapply(data_files, function(data_file){
	df = readr::read_csv(data_file)
	colnames(df) = c("Ch","LOCODE_part1","LOCODE_part2","Name","NameWoDiacritics","SubDiv","Function","Status","Date","IATA","Coordinates","Remarks")
	return(df)
}))

#filtering
cl = cl[!is.na(cl$LOCODE_part2),] #remove country groups
cl = cl[!is.na(cl$Name),] #remove NA
cl = cl[startsWith(cl$Function,"1"),] #ports only

#harmonize
cl$Ch = NULL
cl$LOCODE = paste(cl$LOCODE_part1,cl$LOCODE_part2)
cl$LOCODE_part1 = NULL
cl$LOCODE_part2 = NULL

#TODO spatial part
process_geom <- function(coords){
  if(is.na(coords)) return(NA)
  coords = unlist(strsplit(coords, " "))
  #lat
  lat.deg = as.numeric(substr(coords[1],1,2))
  lat.min = as.numeric(substr(coords[1],3,4))/60
  lat.dir = substr(coords[1], 5,5)
  lat.pt = lat.deg + lat.min
  if(lat.dir == "S") lat.pt = -lat.pt
  #lon
  lon.deg = as.numeric(substr(coords[2],1,3))
  lon.min = as.numeric(substr(coords[2],4,5))/60
  lon.dir = substr(coords[2], 6,6)
  lon.pt = lon.deg + lon.min
  if(lon.dir == "W") lon.pt = -lon.pt
  sf::st_point(c(lon.pt, lat.pt))
}

cl = sf::st_sf(
  data.frame(
  	code = cl$LOCODE,
  	uri = NA,
  	label = cl$Name,
  	definition = NA
  ),
  geom = do.call(sf::st_sfc, lapply(cl$Coordinates, process_geom))
)
sf::st_crs(cl) = 4326

sf::st_write(cl, "cl_unlocode.csv")
sf::st_write(cl, "cl_unlocode.gpkg")


