MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

chicago-tree-data.zip :
	wget -O $@ "https://s3.amazonaws.com/datamade-trees/chicago-tree-data.zip"

.INTERMEDIATE : citywide_canopy.shp
citywide_canopy.shp : chicago-tree-data.zip
	unzip $< chicago-tree-data/"$(basename $@).zip"
	unzip chicago-tree-data/$(basename $@).zip

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

load_canopy : citywide_canopy.shp 
	shp2pgsql -I -s 4326 -d $< canopy | psql

.PHONY : all
all : load_tracts load_blocks load_canopy

.PHONY : clean
clean :
	rm -rf chicago-tree-data
	rm *.shx *.sbx *.dbf *.prj *.sbn *.xml

