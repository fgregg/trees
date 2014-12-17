MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

shapefile :
	$(MAKE) -C shapefiles

points :
	$(MAKE) -C point_data

census :
	$(MAKE) -C census_data

populated_tracts :
	psql -c "CREATE TABLE populated_tract AS \
		 (SELECT geoid10, \
		 	 ST_INTERSECTION(tracts.geom, bl.merge_geom) AS geom \
		  FROM tracts, \
		  (SELECT ST_UNION(blocks.geom) AS merge_geom \
		   FROM blocks INNER JOIN block_pop \
		   USING (tract_bloc) \
                   WHERE pop > 10 \
		   GROUP BY blocks.tractce10) \
		  AS bl \
		  WHERE ST_INTERSECTS(tracts.geom, bl.merge_geom))"

populated_canopy :
	psql -c "CREATE TABLE populated_canopy AS \
		 (SELECT geoid10, \
			 ST_INTERSECTION(populated_tract.geom, \
					 canopy.geom) AS geom \
		  FROM populated_tract, canopy \
		  WHERE ST_INTERSECTS(populated_tract.geom, canopy.geom))" 

all : shapefile points census populated_tracts populated_canopy
