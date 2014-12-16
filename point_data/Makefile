MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

homicides.csv : 
	wget -O $@ "https://data.cityofchicago.org/api/views/at5g-yf63/rows.csv?accessType=DOWNLOAD"

trim_requests.csv :
	wget -O $@ "https://data.cityofchicago.org/api/views/uxic-zsuj/rows.csv?accessType=DOWNLOAD"

%.vrt : %.csv
	@echo \
	\<OGRVRTDataSource\>\
	  \<OGRVRTLayer name=\"$(basename $@)\"\>\
	    \<SrcDataSource\>$<\</SrcDataSource\>\
	    \<GeometryType\>wkbPoint\</GeometryType\>\
	    \<LayerSRS\>WGS84\</LayerSRS\>\
	    \<GeometryField encoding=\"PointFromColumns\" x=\"Longitude\" y=\"Latitude\"/\>\
	  \</OGRVRTLayer\>\
	\</OGRVRTDataSource\> > $@


.INTERMEDIATE : load_homicides load_trim_requests
load_% : %.vrt
	ogr2ogr -f "PostgreSQL" -lco GEOMETRY_NAME=geom -lco FID=gid \
	PG:"host=localhost dbname=$(PG_USER) password=$(PG_PASSWORD)" \
	$< -nln $(basename $<)
	@touch $@


.PHONY : all
all : load_homicides load_trim_requests
	psql -c "ALTER TABLE homicides ALTER COLUMN \"date\" TYPE DATE USING to_date(NULLIF(\"date\", ''), 'MM/DD/YYYY')"
	psql -c "ALTER TABLE trim_requests ALTER COLUMN \"completion date\" TYPE DATE USING to_date(NULLIF(\"completion date\", ''), 'MM/DD/YYYY')"
	psql -c "ALTER TABLE trim_requests ALTER COLUMN \"creation date\" TYPE DATE USING to_date(NULLIF(\"creation date\", ''), 'MM/DD/YYYY')"


.PHONY : clean
clean :
	psql -c "DROP TABLE homicides"
	psql -c "DROP TABLE trim_requests"
