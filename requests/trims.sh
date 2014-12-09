wget -O trim_requests.csv https://data.cityofchicago.org/api/views/uxic-zsuj/rows.csv?accessType=DOWNLOAD

ogr2ogr -f "PostgreSQL" -lco GEOMETRY_NAME=geom -lco FID=gid PG:"host=localhost dbname=fgregg password=buddah" trim_requests.vrt -nln trim_requests

ALTER TABLE requests ALTER COLUMN "completion date" TYPE DATE USING to_date(NULLIF("completion date", ''), 'MM/DD/YYYY');
ALTER TABLE requests ALTER COLUMN "creation date" TYPE DATE USING to_date(NULLIF("creation date", ''), 'MM/DD/YYYY');

