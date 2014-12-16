library(rgeos)
library(rgdal)
library(stringr)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname='fgregg')

storm_days <- read.csv("storms.csv", header=FALSE)

trim_requests <- dbGetQuery(con,
    paste("
          SELECT geoid10, COALESCE(all_count.cnt, 0) AS trim_call
          FROM populated_tract LEFT JOIN 
          (SELECT geoid10, COUNT(*) AS cnt
           FROM trim_requests, populated_tract
           WHERE ST_INTERSECTS(trim_requests.geom, populated_tract.geom)
           AND \"creation date\" IN ('",
           paste(storm_days[,1], sep="", collapse="', '"),
           "')
           GROUP BY geoid10)
          AS all_count USING (geoid10)"
          , sep=""))


populated_canopy_area <- dbGetQuery(con,
    "
    SELECT geoid10, SUM(st_area(geom::geography)) as canopy_area
    FROM populated_canopy
    GROUP BY geoid10
    ")

populated_tract_area <- dbGetQuery(con,
    "
    SELECT geoid10, st_area(geom::geography) as tract_area
    FROM populated_tract
    ")

tract_population <- read.csv("acs2012_5yr_B01001_14000US17031810400.csv")
tract_population$geoid <- str_split_fixed(tract_population$geoid, "US", 2)[, 2]

over_18 <- (tract_population[, 3]
            - rowSums(tract_population[, c(7,9,11,13,55,57,59,61)]))
over_18 <- data.frame(geoid10=tract_population$geoid, over_18=over_18)

tract <- merge(trim_requests, populated_canopy_area, by="geoid10")
tract <- merge(tract, populated_tract_area, by="geoid10")
tract <- merge(tract, over_18, by="geoid10")

tract$percent_covered <- tract$canopy_area/tract$tract_area

plot(log(trim_call) ~ log(canopy_area),
     data=tract,
     ylim=c(0, 8),
     xlim=c(6, 14))
abline(-6.6, 1, col="red")

plot(I(log(trim_call) - log(canopy_area)) ~ log(over_18), data=tract)

model <- glm(trim_call ~ log(over_18), offset=log(canopy_area),
             data=tract, family="poisson")






base_rateXexpression = exp(log(tract$trim_call)
                          - log(tract$over_18)
                          - log(tract$percent_covered))

# assuming that tract_level expressiveness is log normal
tree_debris_rate = exp(mean(log(base_rateXexpression)))

expression = base_rateXexpression/tree_debris_rate

# Note that these are deviance residuals http://people.bath.ac.uk/sw283/mgcv/tampere/glm.pdf
write.csv(data.frame(geoid10=tract$geoid,
                     resid=resid(model),
                     expression=log(expression),
                     callsXtree = tract$trim_call/tract$canopy_area,
                     covered=tract$percent_covered),
          file = "resid.csv",
          row.names = FALSE)

write.csv(data.frame(geoid=tract$geoid, calls=tract$trim_call),
          file = "calls.csv",
          row.names = FALSE)
