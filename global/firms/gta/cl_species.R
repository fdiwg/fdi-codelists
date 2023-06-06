require(readr)
asfis = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/cwp/cl_asfis_species.csv")
gta_list = readr::read_csv("GTA_SPECIES_LIST_DRAFT.csv")
gta_asfis = asfis[asfis$code %in% gta_list$`ASFIS code`,]
readr::write_csv(gta_asfis, "cl_species.csv")