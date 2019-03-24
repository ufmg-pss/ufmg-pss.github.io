#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Spatial Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: SPATIAL ANALYSIS

spatialAnalysis <- function(df, dirSpatial,return_plot = FALSE){

  # Step 2: Spatial Analysis ------------------------------------------------
  
  #Tweet plot off all tweets
  png(file=paste(dirSpatial,"/tweetSpatialGeral.png",sep = ""),width = 800, height = 600)
  #png(file="ImagesAnalysis/tweetSpacialGeral.png")
  tweets_geral <- ggmap(map, extend = 'device') 
  tweets_geral <- tweets_geral + geom_point(size = 0.5,aes(x = lon, y = lat), colour = 'gold',data = df,na.rm = T) 
  tweets_geral <- tweets_geral + theme(legend.position="top")
  tweets_geral <- tweets_geral + xlab("lon") + ylab("lat") 
  tweets_geral <- tweets_geral + theme(legend.position="none")
  tweets_geral <- tweets_geral + ggtitle('Tweet Spacial Point') 
  plot(tweets_geral)  #plot incident type in a map
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatial,"/tweetSpatialGeral.png\n",sep = ""))
  
  
  # Tweets density on map
  png(file=paste(dirSpatial,"/tweetDensity.png",sep = ""),width = 800, height = 600)
  
  tweets_density <- ggmap(map,  extent = "panel") 
  tweets_density <- tweets_density + geom_density2d(data = df, aes(x = lon, y = lat))
  tweets_density <- tweets_density + stat_density2d(data = df, aes(x = lon, y = lat, fill = ..level.., alpha= ..level..),size = 0.5, bins = 30, alpha=0.5, geom = 'polygon') 
  tweets_density <- tweets_density + scale_fill_gradient(low = "green", high = "red",position = 'top', name = "Level")
  tweets_density <- tweets_density #+ scale_alpha( guide = FALSE, range = c(0.4, 0.8)) 
  tweets_density <- tweets_density + ggtitle('Tweets Spatial Density') 
  tweets_density <- tweets_density +  theme(legend.title = element_text(size=12, color = "black", face="bold"),
  legend.justification=c(1,0),legend.position=c(1, 0),legend.background = element_rect(fill = alpha('grey', 0.7)),legend.key = element_blank())

    
  plot(tweets_density)  #tweets density
  dev.off()
  
  cat(paste("Great, file generated: ",dirSpatial,"/tweetDensity.png\n",sep = ""))
  
  
  if(return_plot == TRUE){
    storage_plot_list = list()
    storage_plot_list[[1]] = tweets_geral
    storage_plot_list[[2]] = tweets_density
    return(storage_plot_list)
  }
}
