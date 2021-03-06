MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

### Download files
.INTERMEDIATE : orig_block_population.csv 
orig_block_population.csv :
	wget -O $@ "https://data.cityofchicago.org/api/views/5yjb-v3mj/rows.csv?accessType=DOWNLOAD"

.INTERMEDIATE : block_population.csv
block_population.csv : orig_block_population.csv
	awk -F , 'NR == 1 {print} NR > 1 { printf "%010i,%i\n" , $$1 , $$2 }' \
		$< > $@

.INTERMEDIATE : under_18.zip
under_18.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B09001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : poverty_status.zip
poverty_status.zip : 
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B17001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : public_assistance.zip
public_assistance.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B19057&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : household_type.zip
household_type.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B11001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : employment.zip
employment.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B23025&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : race.zip
race.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B02001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : latino_origin.zip
latino_origin.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B03001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : origin.zip
origin.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B05002&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : mobility.zip
mobility.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B07001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

.INTERMEDIATE : tenure.zip
tenure.zip :
	wget -O $@ "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B25003&geo_ids=16000US1714000,140|16000US1714000&format=csv"

### Extract CSVs from zips
%.csv : %.zip 
	unzip -cq $< "*.csv" > $@

### Dice out necessary columns
.INTERMEDIATE : below_poverty.csv poverty_status.csv
below_poverty.csv : poverty_status.csv
	csvcut -c "1,3,\
		   B17001002 - Income in the past 12 months below poverty level:"\
		$^ > $@

.INTERMEDIATE : on_public_assistance.csv public_assistance.csv
on_public_assistance.csv : public_assistance.csv
	csvcut -c "1,3,\
	           B19057002 - With public assistance income"\
		$^ > $@

.INTERMEDIATE : single_mother.csv household_type.csv
single_mother.csv : household_type.csv
	csvcut -c '1,5,13'\
		$^ > $@

.INTERMEDIATE : unemployed.csv employment.csv
unemployed.csv : employment.csv
	csvcut -c '1,7,11'\
		$^ > $@

.INTERMEDIATE : black.csv race.csv
black.csv : race.csv
	csvcut -c '1,3,7'\
		$^ > $@

.INTERMEDIATE : latino.csv latino_origin.csv
latino.csv : latino_origin.csv
	csvcut -c '1,3,7'\
		$^ > $@

.INTERMEDIATE : foreign_born.csv origin.csv
foreign_born.csv : origin.csv
	csvcut -c '1,3,19'\
		$^ > $@

.INTERMEDIATE : one_year_mobility.csv mobility.csv
one_year_mobility.csv : mobility.csv
	csvcut -c '1,3,B07001017 - Same house 1 year ago:'\
		$^ > $@

.INTERMEDIATE : home_ownership.csv tenure.csv
home_ownership.csv : tenure.csv
	csvcut -c '1,3,5'\
		$^ > $@

.INTERMEDIATE : children.csv under_18.csv
children.csv : under_18.csv
	csvcut -c '1,3'\
		$^ > $@ 

### Join Tables
all_measures.csv : below_poverty.csv on_public_assistance.csv\
		   single_mother.csv unemployed.csv black.csv latino.csv\
                   foreign_born.csv one_year_mobility.csv home_ownership.csv\
		   children.csv
	csvjoin -c "geoid" $^ |\
	csvcut -C 4,7,10,13,16,19,22,25,28 > $@

load_block_pop : block_population.csv
	psql -c "CREATE TABLE block_pop (tract_bloc CHARACTER(10), pop INTEGER)"
	psql -c "COPY block_pop FROM '$(realpath $<)' DELIMITER ',' CSV HEADER"

.PHONY : all
all : all_measures.csv load_block_pop

.PHONY : clean
clean :
	psql -c "DROP TABLE block_pop"
