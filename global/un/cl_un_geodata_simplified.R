sf = sf::st_read("https://geoportal.un.org/arcgis/sharing/rest/content/items/d7caaff3ef4b4f7c82689b7c4694ad92/data")
sf::st_write(sf, "cl_un_geodata_simplified.csv")
sf::st_write(sf, "cl_un_geodata_simplified.gpkg")