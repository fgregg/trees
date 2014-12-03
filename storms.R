library(rgeos)
library(rgdal)
library(stringr)

calls <- read.csv("requests/311_Service_Requests_-_Tree_Debris.csv")

calls <- calls[!is.na(calls$Longitude),]
calls <- SpatialPointsDataFrame(calls[, c("Longitude", "Latitude")], calls)

tracts <- readOGR("tracts", "wgs84")

tract_count <- colSums(gContains(tracts, calls, byid=TRUE))
tract_count <- data.frame(geoid=tracts$GEOID10,
                          calls=tract_count)

tract_cover <- read.csv("tract_coverage.csv")


tract_population <- read.csv("acs2012_5yr_B01001_14000US17031810400.csv")
tract_population$geoid <- str_split_fixed(tract_population$geoid, "US", 2)[, 2]

over_18 <- (tract_population[, 3]
            - rowSums(tract_population[, c(7,9,11,13,55,57,59,61)]))
over_18 <- data.frame(geoid=tract_population$geoid, over_18=over_18)

tract_data <- merge(tract_count, tract_cover, by="geoid")
tract_data <- merge(tract_data, over_18, by="geoid")

tract_data <- tract_data[-c(517, 683, 755, 160),]
tract_data <- tract_data[tract_data$over_18 > 0,]

plot(log(calls) ~ I(log(canopy_coverage * over_18)), data=tract_data)

model <- glm(calls ~ 1, data=tract_data, family="poisson")

# Note that these are deviance residuals
write.csv(data.frame(geoid=tract_data$geoid, resid=-resid(model)),
          file = "resid.csv",
          row.names = FALSE)
