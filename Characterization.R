#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: features extraction
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#Clear Workspace
rm(list = ls())

#Setting traceback error
options(error=traceback)

# Initialize Functions ----------------------------------------------------
#Script about the characterization of tweetes and incidents fusion

source("Functions.R")

#source("mostRelevantUserHistoricAnalysis.R")

#library declarations

ipak(c('ggplot2','mapproj','gridExtra','ggmap','RCurl','cetcolor','BBmisc','tidyverse','RColorBrewer','dplyr','reshape',"SnowballC","parallel","syuzhet","viridis","ggthemes","scales",'grid'))


# STEP: 0 -----------------------------------------------------------------
## load paths, input data, and libraries

args = commandArgs (trailingOnly = TRUE) #receveing the command arguments args[1] - place name args[2] - bounding box

place <- args[1]

bounding_box <-args[2] #bounding-box of the input region

#Shift in the data hour because of the diferent time zone. The time_zone is used to tranform to local data
time_zone <- as.numeric(args[3])

temporal_analysis <- as.numeric(args[4])

spatial_analysis <- as.numeric(args[5])

spatial_temporal_analysis <- as.numeric(args[6])

emotion_synthesis <- as.numeric(args[7])

twitter_description <- as.numeric(args[8])

initial_time_description_per_hour <- args[9]

final_time_description_per_hour <- args[10]

frequent_user_analysis <- as.numeric(args[11])

number_most_frequent_user <- args[12]

if (!args[13] == "NULL"){
  initial_time_plot_trace <- strptime(args[13], "%Y-%m-%d %H:%M:%S", tz = "GMT")
}else{
  initial_time_plot_trace <- NULL
}
initial_time_plot_trace
if (!args[14] == "NULL"){
  final_time_plot_trace <- strptime(args[14], "%Y-%m-%d %H:%M:%S", tz = "GMT")
}else{
  final_time_plot_trace <- NULL
}

final_time_plot_trace
cat('\n')
#User taht will be plot in graph for sample

history_analysis <- as.numeric(args[15])

#Directory of tweets
DIR_TWITTER <- paste( "Data/", place,"/tweets_gerados.csv",sep = '')

#RADIUS <- 0.1 #size of the radius of the incident
df  <- read.csv(DIR_TWITTER, sep = ",", stringsAsFactors = FALSE) #stringAsFactors
df$created_at <- strptime(df$created_at, "%Y-%m-%d %H:%M:%S", tz="GMT") - time_zone*3600

bounding_box <-as.list(strsplit(bounding_box, ",")[[1]])
bounding_box <- as.numeric(bounding_box)

# Download and save map image and R object
dirFileMap <- paste( "Data/", place, "/", "egy-map.rda",sep = '')

if (!file.exists(dirFileMap)){
  map <- get_map(bounding_box, source = 'stamen', maptype = 'toner')
  #egy.map <- get_map(location=c(lon=30, lat=26), zoom=6, maptype="terrain", filename="~/Desktop/ggmapTemp")
  save(map, file= dirFileMap)
}else{
  # Restart R or RStudio before running the code below
  cat("Map already exist. Loading it...\n")
  load(dirFileMap)
  ls()
  #map <- ggmap(map)
}

# read in all the traffic files, appending the path before the filename
# Step 1: Temporal Analysis -----------------------------------------------
  if(temporal_analysis){
    source("temporalAnalysis.R")
    dirTemporal <- paste("Results/",place,"/Temporal",sep = '')
    temporalAnalysis(df,dirTemporal)
  }
# Step 2: Spatial Analysis ------------------------------------------------
  if(spatial_analysis){
    source("spatialAnalysis.R")
    dirSpatial <- paste("Results/",place,"/Spacial",sep = '')
    spatialAnalysis(df,dirSpatial)
  }
# Step 3: SpatialTemporal -------------------------------------------------
  if(spatial_temporal_analysis){
    source("spatialTemporalAnalysis.R")
    dirSpatialTemporal <- paste("Results/",place,"/SpacialTemporal",sep = '')
    spatialTemporalAnalysis(df, place,dirSpatialTemporal)
  }
  #Analysis Spatial Temporal consiser the emotion
  if(emotion_synthesis){
    source("emotionAnalysis.R")
    emotionAnalysis(df,dirSpatialTemporal,place,initial_time_description_per_hour, final_time_description_per_hour, twitter_description = twitter_description,load_df = 0)

  }

  if (frequent_user_analysis){
    #Analysis of most frequent user
    dirFrequentAccounts <- paste("Results/",place,"/SpacialTemporal/FrequentUser",sep = '')
    source("mostFrequentUserRouteAnalysis.R")
    mostFrequentUserTemporalSpatialRouteAnalysis(df,dirFrequentAccount,number_most_frequent_user,initial_time_plot_trace,final_time_plot_trace,frequent_user_analysis)
  }
  #Historic analysis
  #This function analysis the las month historical analysis, finding that accounts
  #that are more contribuited for

  if(history_analysis){
    source("mostRelevantUserHistoricAnalysis.R")
    dirHistoricFrequentUser <- paste("Data/", place, "/HistoryFrequentUser/", sep = "")
    mostRelevantUserHistoricAnalysis(dirHistoricFrequentUser,dirFrequentAccounts, number_most_frequent_user, time_zone)
  }
