trees
=====

Estimating 311 Engagement with Trees

Setting up db
```bash
shp2pgsql -I -s 4326 -d ~/Downloads/chicago-tree-data/citywide_canopy.shp canopy | psql

ogr2ogr -s_srs EPSG:3435 -t_srs EPSG:4326  -f "ESRI Shapefile" wgs84.shp CensusTractsTIGER2010.shp
shp2pgsql -I -s 4326 -d wgs84.shp CensusTractsTIGER2010 | psql

ogr2ogr -s_srs EPSG:3435 -t_srs EPSG:4326  -f "ESRI Shapefile" blocks.shp CensusBlockTIGER2010.shp

gr2ogr -f 'ESRI Shapefile' zoning.shp Zoning_Nov2012.kmz 
ogr2ogr -s_srs EPSG:3435 -t_srs EPSG:4326  -f "ESRI Shapefile" zoning.shp Zoning_nov2012.shp

ogr2ogr -f "PostgreSQL" -lco GEOMETRY_NAME=geom -lco FID=gid PG:"host=localhost dbname=DBNAME password=PASSWORD" 311_Service_Requests_-_Tree_Debris.vrt -nln requests
ALTER TABLE requests ALTER COLUMN "completion date" TYPE DATE USING to_date(NULLIF("completion date", ''), 'MM/DD/YYYY');
ALTER TABLE requests ALTER COLUMN "creation date" TYPE DATE USING to_date(NULLIF("creation date", ''), 'MM/DD/YYYY');

CREATE TABLE populated_tract AS (SELECT geoid10, ST_INTERSECTION(tract.geom, bl.merge_geom) AS geom FROM censustractstiger2010 AS tract, (SELECT ST_UNION(blocks.geom) AS merge_geom FROM blocks, block_pop WHERE blocks.tract_bloc::bigint = block_pop.tract_bloc::bigint AND pop > 10 GROUP BY blocks.tractce10) AS bl WHERE ST_INTERSECTS(tract.geom, bl.merge_geom));

CREATE TABLE populated_canopy AS (select geoid10, ST_INTERSECTION(populated_tract.geom, canopy.geom) as geom FROM populated_tract, canopy WHERE ST_INTERSECTS(populated_tract.geom, canopy.geom));

```

Creating tract coverage 
```sql
COPY (SELECT geoid10, SUM(st_area(st_transform(st_intersection(tract.geom, canopy.geom), 4326)::geography)) AS canopy_area, st_area(st_transform(tract.geom, 4326)::geography) as tract_area FROM censustractstiger2010 as tract, canopy WHERE st_intersects(tract.geom, canopy.geom) GROUP BY tract.gid) to '/tmp/tract_coverage.csv' WITH CSV;
```
