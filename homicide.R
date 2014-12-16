library(RPostgreSQL)
library(stringr)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname='fgregg')

census <- read.csv("census_data/all_measures.csv")
census$geoid10 <- str_split_fixed(census$geoid, "US", 2)[, 2]
census$population <-census$B02001001...Total.

census_rates <- census[,seq(3, 19, 2)]/census[,seq(2, 19, 2)]
census_rates$children <- census[,20]/census$population
names(census_rates) <- c("in_poverty", "public_assistance",
                         "single_mother", "unemployed", "black",
                         "hispanic", "foreign_born", "same_house",
                         "owner_occupied", "under_18")
census_rates$geoid10 <- census$geoid10

factors <- fa(r=cor(census_rates[, 1:10], use="pairwise"),
              nfactors=3, rotate="oblimin", fm="pa",
              oblique.scores=TRUE)

scores <- apply(loadings(factors), 2,
                function(x) {rowSums(x * census_rates)})
scores <- as.data.frame(scores)
names(scores) <- c("disadvantage", "immigrant", "stability")
scores$geoid10 <- census$geoid10

expressiveness <- read.csv("resid.csv")

homicides <- dbGetQuery(con,
    paste("
          SELECT geoid10, COALESCE(all_count.cnt, 0) AS homicide_count
          FROM populated_tract LEFT JOIN 
          (SELECT geoid10, COUNT(*) AS cnt
           FROM homicides, populated_tract
           WHERE ST_INTERSECTS(homicides.geom, populated_tract.geom)
           GROUP BY geoid10)
          AS all_count USING (geoid10)"
          , sep=""))

all_data <- merge(homicides, scores, by="geoid10")
all_data <- merge(all_data, expressiveness, by="geoid10")
all_data <- merge(all_data, census_rates, by="geoid10")
all_data <- merge(all_data, census[, c("geoid10", "population")], by="geoid10")

model1 <- glm(homicide_count ~ (disadvantage + immigrant
                                + stability + resid),
              offset=log(population),
              data=all_data, family="poisson")
                                
model2 <- glm(homicide_count ~ (in_poverty + public_assistance + single_mother
                                + unemployed + black + hispanic + foreign_born
                                + same_house + I(scale(resid))
                                + owner_occupied + under_18),
              offset=log(population),
              data=all_data, family="poisson")


