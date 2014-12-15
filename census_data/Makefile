all_measures.csv : below_poverty.csv on_public_assistance.csv\
		   single_mother.csv unemployed.csv black.csv latino.csv\
                   foreign_born.csv one_year_mobility.csv home_ownership.csv
	csvjoin -c "geoid" below_poverty.csv on_public_assistance.csv\
			   single_mother.csv unemployed.csv black.csv\
			   latino.csv foreign_born.csv one_year_mobility.csv\
			   home_ownership.csv |\
	csvcut -C 4,7,10,13,16,19,22,25 > all_measures.csv

build_files = poverty_status.* public_assistance.* household_type.*\
              employment.* race.* latino_origin.* below_poverty.*\
	      origin.* mobility.* tenure.*\
	      on_public_assistance.* single_mother.* unemployed.*\
              black.* latino.* foreign_born.* one_year_mobility.*\
              home_ownership.*

.PHONY : clean
clean :
	rm $(build_files)

define UNZIP
$(shell unzip -cq $1.zip "*.csv" > $1.csv)
endef

below_poverty.csv : poverty_status.csv
	csvcut -c "1,3,\
		   B17001002 - Income in the past 12 months below poverty level:"\
		poverty_status.csv > below_poverty.csv

poverty_status.csv : poverty_status.zip
	$(call UNZIP, poverty_status)

poverty_status.zip : 
	wget -O poverty_status.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B17001&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch poverty_status.zip


on_public_assistance.csv : public_assistance.csv
	csvcut -c "1,3,\
	           B19057002 - With public assistance income"\
		public_assistance.csv > on_public_assistance.csv

public_assistance.csv : public_assistance.zip 
	$(call UNZIP, public_assistance)

public_assistance.zip :
	wget -O public_assistance.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B19057&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch public_assistance.zip

single_mother.csv : household_type.csv
	csvcut -c '1,5,13'\
		household_type.csv > single_mother.csv

household_type.csv : household_type.zip
	$(call UNZIP, household_type)

household_type.zip :
	wget -O household_type.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B11001&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch household_type.zip


employment.zip :
	wget -O employment.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B23025&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch employment.zip

employment.csv : employment.zip
	$(call UNZIP, employment)

unemployed.csv : employment.csv
	csvcut -c '1,7,11'\
		employment.csv > unemployed.csv

black.csv : race.csv
	csvcut -c '1,3,7'\
		race.csv > black.csv

race.csv : race.zip
	$(call UNZIP, race)

race.zip :
	wget -O race.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B02001&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch race.zip


latino.csv : latino_origin.csv
	csvcut -c '1,3,7'\
		latino_origin.csv > latino.csv

latino_origin.csv : latino_origin.zip
	$(call UNZIP, latino_origin)

latino_origin.zip :
	wget -O latino_origin.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B03001&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch latino_origin.zip


origin.zip :
	wget -O origin.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B05002&geo_ids=16000US1714000,140|16000US1714000&format=csv"
	touch origin.zip

origin.csv : origin.zip
	$(call UNZIP, origin)

foreign_born.csv : origin.csv
	csvcut -c '1,3,19'\
		origin.csv > foreign_born.csv

mobility.zip :
	wget -O mobility.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B07001&geo_ids=16000US1714000,140|16000US1714000&format=csv"

mobility.csv : mobility.zip
	$(call UNZIP, mobility)

one_year_mobility.csv : mobility.csv
	csvcut -c '1,3,B07001017 - Same house 1 year ago:'\
		mobility.csv > one_year_mobility.csv

tenure.zip :
	wget -O tenure.zip "http://api.censusreporter.org/1.0/data/download/latest?table_ids=B25003&geo_ids=16000US1714000,140|16000US1714000&format=csv"

tenure.csv : tenure.zip
	$(call UNZIP, tenure)

home_ownership.csv : tenure.csv
	csvcut -c '1,3,5'\
		tenure.csv > home_ownership.csv



