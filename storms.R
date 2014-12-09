library(RPostgreSQL)
library(xts)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname='fgregg')

requests <- dbGetQuery(con,
    "
    SELECT * FROM requests
    ")

daily_counts <- table(requests$"creation date")

daily_counts <- xts::xts(daily_counts, as.Date(names(daily_counts)))

plot(daily_counts)

more_than_yesterday <- daily_counts - lag(daily_counts, 1)

storms <- more_than_yesterday[more_than_yesterday > 200]
plot(storms)

write.zoo(storms,
          "storms.csv",
          sep=',')


