require(readr)
asfis = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/cwp/cl_asfis_species.csv")

#species targeted for GTA level 0
gta_list = readr::read_csv("GTA_SPECIES_LIST_DRAFT.csv")
gta_asfis_level0 = asfis[asfis$code %in% gta_list$`ASFIS code`,]
readr::write_csv(gta_asfis_level0, "cl_species_level0.csv")

#species targeted for GTA level 1
gta_asfis_level1 = asfis[asfis$code %in% c("BET","SKJ","YFT","ALB","BFT","PBF","SBF","SWO"),]
readr::write_csv(gta_asfis_level1, "cl_species_level1.csv")
