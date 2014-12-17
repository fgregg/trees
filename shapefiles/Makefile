MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

tracts.zip :
	wget -O $@ "https://data.cityofchicago.org/api/geospatial/5jrd-6zik?method=export&format=Original"

blocks.zip :
	wget -O $@ "https://data.cityofchicago.org/api/geospatial/mfzt-js4n?method=export&format=Original"

.INTERMEDIATE : original_blocks.shp
original_blocks.shp : blocks.zip
	unzip $<
	rename 's/CensusBlockTIGER2010/$(basename $@)/' *.*

.INTERMEDIATE : original_tracts.shp
original_tracts.shp : tracts.zip
	unzip $<
	rename 's/CensusTractsTIGER2010/$(basename $@)/' *.*

%.shp : original_%.shp
	ogr2ogr -s_srs EPSG:3435 -t_srs EPSG:4326 -f "ESRI Shapefile" $@ $<

load_% : %.shp
	shp2pgsql -I -s 4326 -d $< $(basename $<) | psql

.PHONY : all
all : load_tracts load_blocks

.PHONY : clean
clean :
	rm *.shx *.sbx *.dbf *.prj *.sbn *.xml
