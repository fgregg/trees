trees
=====

Estimating 311 Engagement with Trees

Setting up db
```bash
shp2pgsql -I -s 4326 -d ~/Downloads/chicago-tree-data/citywide_canopy.shp canopy | psql

ogr2ogr -s_srs EPSG:3435 -t_srs EPSG:4326  -f "ESRI Shapefile" wgs84.shp CensusTractsTIGER2010.shp
shp2pgsql -I -s 4326 -d wgs84.shp CensusTractsTIGER2010 | psql
```

Creating tract coverage 
```sql
COPY (SELECT geoid10, SUM(st_area(st_transform(st_intersection(tract.geom, canopy.geom), 4326)::geography)) AS canopy_area, st_area(st_transform(tract.geom, 4326)::geography) as tract_area FROM censustractstiger2010 as tract, canopy WHERE st_intersects(tract.geom, canopy.geom) GROUP BY tract.gid) to '/tmp/tract_coverage.csv' WITH CSV;
```
