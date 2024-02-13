setwd("D:/Documents/DEV/fdiwg/fdi-codelists/global/unece")

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

cl = data.frame(
	code = cl$LOCODE,
	uri = NA,
	label = cl$Name,
	definition = NA
)

readr::write_csv(cl, "cl_unlocode.csv")


