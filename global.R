library(zipcode)
library(data.table)
library(rworldmap)
library(rworldxtra)
library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# clear workspace
rm(list = ls())

# load zipcode data from zipcode package
data(zipcode)

# read in file with schools by conferences -- get data from https://www.dropbox.com/s/1j8z3yvo30fhqlt/colleges_fixed.csv?dl=0
colleges <- read.csv("/Users/user/Documents/R/projects/colleges_fixed.csv", header = TRUE,
                     stringsAsFactors = FALSE)

# add leading zero to ZIP codes
colleges$zip <- clean.zipcodes(colleges$zip)

# merge latitude, longitude information with schools' ZIP codes
zip_lat_long <- data.table(zip = zipcode$zip, 
                           latitude = zipcode$latitude, longitude = zipcode$longitude)

colleges <- data.table(merge(x = colleges, y = zip_lat_long, by = "zip"), key = "conf")

# mean lat/long location by conference
locByConf <- colleges[, list(conf = conf, 
                             meanLatitude = mean(latitude), 
                             meanLongitude = mean(longitude)), 
                      by = key(colleges)]

# how far is each college from its conference's centroid?
# use z-distribution because the dataset is entire population of Division I football teams
# absLongLat -- what is a school's outlyingness in terms of latitude *and* longitude?
colleges <- colleges[,list(team = team, nickname = nickname, city = city, state = state,
                           conf = conf, latitude = latitude, longitude = longitude,
                           zLatitude = (latitude-mean(latitude))/sd(latitude),
                           zLongitude = (longitude-mean(longitude))/sd(longitude),
                           absLongLat = abs((latitude-mean(latitude))/sd(latitude))+abs((longitude-mean(longitude))/sd(longitude))),
                     by = key(colleges)]  

# mean lat-long z-score of each conference -- which conference is the most spread-out?
confDispersion <- colleges[,list(meanLatitude = mean(latitude),
                                 meanLongitude = mean(longitude), 
                                 avgZScore = mean(absLongLat)), by = conf]

# function to show a map containing schools from a given conference
showConferenceMap <- function(conference){
  dat <- colleges[conf == conference]
  map <- getMap(resolution = "low")
  pl <- plot(map, xlim = c(-125,-65), ylim = c(30,40), asp = 1)
  show <- points(dat$longitude, dat$latitude, col = "red", cex = .5) + title(conference)
  return(show)
}

# K-Means algorithm for placing the schools where they should be
KMeansTab <- data.frame(colleges$team, colleges$latitude, colleges$longitude)
colnames(KMeansTab)[1:3] <- c("team","latitude","longitude")

KMeansGrouping <- function(k){
  alg <- kmeans(KMeansTab[c(2, 3)], centers = k)
  KmeansRes <- data.table(cbind(KMeansTab, cluster = alg$cluster), key = "team")
  
  setkey(colleges, "team")       # set key for nested join
  collegesKMeans <- colleges[KmeansRes[, c(1, 4), with = FALSE]]
  setkey(colleges, "conf")       # set back to conf
  
  return(collegesKMeans)
}

# Only useful for output from KMeansGrouping()
getConfDispersion <- function(data){
  dispersion <- data[,list(meanLatitude = mean(latitude),
                           meanLongitude = mean(longitude), avgZScore = mean(absLongLat)), by = cluster]
  return(dispersion)
}

# Is there a meaningful number of conferences that minimizes the distances between schools better than the current system?
# Short answer: Sometimes. It depends on the random clusters R's K-Means algorithm kicks out in each iteration.
minZ = mean(confDispersion$avgZScore)

for(i in 5:20){
  # create i conferences and assign each team to one conference
  out <- KMeansGrouping(i)
  # dispersion of those i conferences
  disp <- getConfDispersion(out)
  # can the dispersion of the KMeans-generated conferences beat what we see now?
  if(mean(disp$avgZScore) < minZ){
    minZ = mean(disp$avgZScore)
    numCluster = i
    print(numCluster)
    print(minZ)
  }
}
