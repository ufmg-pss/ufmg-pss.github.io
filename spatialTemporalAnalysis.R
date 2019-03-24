#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Spatial Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: SPATIALTEMPORAL ANALYSIS

ipak('dplyr')

source('Functions.R')

spatialTemporalAnalysis <- function(df, place,dirSpatialTemporal, return_plot = FALSE){
  # Step 0: Contants --------------------------------------------------------
  
  #Month
  month_label = c("Jan","Feb.","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec")
  
  #Week
  weekdays_label <-c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat')
  
  #create df temporal attributions
  
  #Hours
  df$hours <- as.numeric(format(df$created_at, '%H'))
  
  #Weekday
  df$weekday <- as.numeric(format(df$created_at, '%w')) # Agora eu defino ele numérico
  
  #Month
  df$month <- as.numeric(format(df$created_at, '%m'))
  
  
  # Step 3: SpatialTemporal -------------------------------------------------
  
  
  #Defening temporal  variable as factor
  df$weekday <-factor(df$weekday, levels = c(0,1,2,3,4,5,6), labels = c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat'))
  df$month <-factor(df$month, levels = c(1:12), labels = month_label)
  
  ##Simply plot all tweets in a map based on bounding box area with hour frequency
  png(file=paste(dirSpatialTemporal,"/tweetSpatialHours.png",sep = ""), width = 800, height = 600)
  tweets_spacial_in_hour <- ggmap(map, extend = 'device') 
  tweets_spacial_in_hour <- tweets_spacial_in_hour + geom_point(aes(x = lon, y = lat), size = 0.3, data = df,  alpha = .5,  na.rm = T,  colour="red")
  tweets_spacial_in_hour <- tweets_spacial_in_hour + facet_wrap(~hours, nrow = 4)
  tweets_spacial_in_hour <- tweets_spacial_in_hour + ggtitle('Spatial Tweets per Hour') 
  tweets_spacial_in_hour <- tweets_spacial_in_hour + theme(axis.text.x = element_text(angle=65, hjust = 1)) 
  
  
  plot(tweets_spacial_in_hour)  #todos os tweets plotados juntos
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialHours.png\n",sep = ""))
  
  
  #Spacial Hour Density
  png(file=paste(dirSpatialTemporal,"/tweetSpatialHoursDensity.png",sep = ""), width = 800, height = 600)
  tweets_spacial_in_hour_density <- ggmap(map, extend = 'device') 
  tweets_spacial_in_hour_density <- tweets_spacial_in_hour_density + stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha=..level..), size = 8, bins = 30, alpha=0.8, data = df, geom = "polygon")
  tweets_spacial_in_hour_density <- tweets_spacial_in_hour_density + scale_fill_gradient(low="blue", high = "orange")
  tweets_spacial_in_hour_density <- tweets_spacial_in_hour_density + facet_wrap(~hours, nrow = 4)
  tweets_spacial_in_hour_density <- tweets_spacial_in_hour_density + ggtitle('Spatial Tweets Density per Hour') 
  tweets_spacial_in_hour_density <- tweets_spacial_in_hour_density + theme(axis.text.x = element_text(angle=65, hjust = 1)) 
    
  plot(tweets_spacial_in_hour_density)  #todos os tweets plotados juntos
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialHoursDensity.png\n",sep = ""))

  
  # Tweets on map with week frequency
  ##Simply plot all tweets in a map based on bounding box area with week frequency
  png(file=paste(dirSpatialTemporal,"/tweetSpatialWeeks.png",sep = ""), width = 800, height = 600)
  tweets_spacial_in_week <- ggmap(map, extend = 'device') 
  tweets_spacial_in_week <- tweets_spacial_in_week + geom_point(aes(x = lon, y = lat), size = 1, data = df,  alpha = .5,  na.rm = T,  colour="red")
  tweets_spacial_in_week <- tweets_spacial_in_week + facet_wrap(~weekday, nrow = 2) 
  tweets_spacial_in_week <- tweets_spacial_in_week + ggtitle('Spatial Tweets per Week') 
  tweets_spacial_in_week <- tweets_spacial_in_week + theme(axis.text.x = element_text(angle=65, hjust = 1)) 
  
  plot(tweets_spacial_in_week) 
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialWeeks.png\n",sep = ""))
  
  
  
  #Spacial Week Density
  png(file=paste(dirSpatialTemporal,"/tweetSpatialWeekdayDensity.png",sep = ""), width = 800, height = 600)
  
  tweets_spacial_in_week_density <- ggmap(map, extend = 'device') 
  tweets_spacial_in_week_density <- tweets_spacial_in_week_density + stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha=..level..), size = 8, bins = 30, alpha=0.8, data = df, geom = "polygon")
  tweets_spacial_in_week_density <- tweets_spacial_in_week_density + scale_fill_gradient(low="blue", high = "orange")
  tweets_spacial_in_week_density <- tweets_spacial_in_week_density + facet_wrap(~weekday, nrow = 2)
  tweets_spacial_in_week_density <- tweets_spacial_in_week_density + ggtitle('Spatial Tweets Density per Weekday') 
  tweets_spacial_in_week_density <- tweets_spacial_in_week_density + theme(axis.text.x = element_text(angle=80, hjust = 1)) 
  
  
  plot(tweets_spacial_in_week_density)  #todos os tweets plotados juntos
  
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialWeekdayDensity.png\n",sep = ""))
  
  # Tweets on map with month frequency
  ##Simply plot all tweets in a map based on bounding box area with hour frequency
  png(file=paste(dirSpatialTemporal,"/tweetSpatialMonth.png",sep = ""), width = 800, height = 600)
  tweets_spacial_in_month <- ggmap(map, extend = 'device') 
  tweets_spacial_in_month <- tweets_spacial_in_month + geom_point(aes(x = lon, y = lat), size = 0.5, data = df,  alpha = .5,  na.rm = T,  colour="red")
  tweets_spacial_in_month <- tweets_spacial_in_month + facet_wrap(~month, nrow = 2)
  tweets_spacial_in_month <- tweets_spacial_in_month + ggtitle('Spatial Tweets per Month') 
  tweets_spacial_in_month <- tweets_spacial_in_month + theme(axis.text.x = element_text(angle=80, hjust = 1)) 
  
  plot(tweets_spacial_in_month)  #todos os tweets plotados juntos
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialMonth.png\n",sep = ""))
  
  #Spacial Month Density
  png(file=paste(dirSpatialTemporal,"/tweetSpatialMonthDensity.png",sep = ""), width = 800, height = 600)
  tweets_spacial_in_month_density <- ggmap(map, extend = 'device') 
  tweets_spacial_in_month_density <- tweets_spacial_in_month_density + stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha=..level..), size = 8, bins = 30, alpha=0.8, data = df, geom = "polygon")
  tweets_spacial_in_month_density <- tweets_spacial_in_month_density + scale_fill_gradient(low="blue", high = "orange")
  tweets_spacial_in_month_density <- tweets_spacial_in_month_density + facet_wrap(~month, nrow = 2)
  tweets_spacial_in_month_density <- tweets_spacial_in_month_density + ggtitle('Spatial Tweets Density per Month') 
  tweets_spacial_in_month_density <- tweets_spacial_in_month_density + theme(axis.text.x = element_text(angle=80, hjust = 1)) 
  
  plot(tweets_spacial_in_month_density)  #todos os tweets plotados juntos
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatialTemporal,"/tweetSpatialMonthDensity.png\n",sep = ""))
  
  
  if(return_plot == TRUE){
    storage_plot_list = list()
    storage_plot_list[[1]] = tweets_spacial_in_hour
    storage_plot_list[[2]] = tweets_spacial_in_hour_density
    storage_plot_list[[3]] = tweets_spacial_in_week
    storage_plot_list[[4]] = tweets_spacial_in_week_density
    storage_plot_list[[5]] = tweets_spacial_in_month
    storage_plot_list[[6]] = tweets_spacial_in_month_density
    return(storage_plot_list)
  }
  
  
 
}

