#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Emotion Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: EMOTION ANALYSIS

library('dplyr')
source('Functions.R')
source("twitterDescription.R")

emotionAnalysis <- function(df,dirSpacialTemporal,place,initial_time_description_per_hour=1,final_time_description_per_hour=10, load_df = 0, return_plot = FALSE, twitter_description = FALSE){
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

    #Defening temporal  variable as factor
    df$weekday <-factor(df$weekday, levels = c(0,1,2,3,4,5,6), labels = c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat'))
    df$month <-factor(df$month, levels = c(1:12), labels = month_label)


    #df_emotion <- addEmotions(df [, c('id_str','text','created_at','lat','lon','weekday','hours','month')])

    if (load_df){

      df_emotion <- read.csv('Data/Manhattan/tweets_sentiment.csv',stringsAsFactors = FALSE)
      df_emotion$created_at <- strptime(df_emotion$created_at, "%Y-%m-%d %H:%M:%S", tz="GMT")


      #Hours
      df_emotion$hours <- as.numeric(format(df_emotion$created_at, '%H'))

      #Weekday
      df_emotion$weekday <- as.numeric(format(df_emotion$created_at, '%w')) # Agora eu defino ele numérico

      #Month
      df_emotion$month <- as.numeric(format(df_emotion$created_at, '%m'))

      #Defening temporal  variable as factor
      df_emotion$weekday <-factor(df_emotion$weekday, levels = c(0,1,2,3,4,5,6), labels = c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat'))
      df_emotion$month <-factor(df_emotion$month, levels = c(1:12), labels = month_label)
    }
    else
      df_emotion <- addEmotions(df [, c('id_str','text','created_at','lat','lon','weekday','hours','month')])


    if(twitter_description){
      twitterDescription(df_emotion,place,initial_time_description_per_hour,final_time_description_per_hour, save_csv = TRUE)
    }

    #df_emotion <- df_emotion [, c('lat','lon','emotion_synthesis')]


    #Geral Emotion Analysis
    png(file=paste(dirSpatialTemporal,"/emotionSpatialGeral.png",sep = ""),width = 800, height = 600)

    emotion_spacial_geral <- ggmap(map)
    emotion_spacial_geral <- emotion_spacial_geral %+% df_emotion
    emotion_spacial_geral <- emotion_spacial_geral +  aes(x = lon, y = lat, z = df_emotion$emotion_synthesis)
    emotion_spacial_geral <- emotion_spacial_geral + stat_summary2d(fun = median, alpha = 0.7)
    emotion_spacial_geral <- emotion_spacial_geral + scale_fill_gradientn(name = "Sentiment Scale", colours = c('red','grey','green'), space = "Lab")
    emotion_spacial_geral <- emotion_spacial_geral + labs(title = "Sentiment Analysis",x = "lon", y = "lat")
    emotion_spacial_geral <- emotion_spacial_geral + coord_map()
    plot(emotion_spacial_geral)

    dev.off()
    cat(paste("Great, file generated: ",dirSpatialTemporal,"/emotionSpatialGeral.png\n",sep = ""))


    #Hours Emotion Analysis
    png(file=paste(dirSpatialTemporal,"/emotionSpatialHours.png",sep = ""), width = 800, height = 600)

    emotion_spacial_hours <- ggmap(map)
    emotion_spacial_hours <- emotion_spacial_hours %+% df_emotion
    emotion_spacial_hours <- emotion_spacial_hours +  aes(x = lon, y = lat, z = df_emotion$emotion_synthesis)
    emotion_spacial_hours <- emotion_spacial_hours + stat_summary2d(fun = median, alpha = 0.7)
    emotion_spacial_hours <- emotion_spacial_hours + scale_fill_gradientn(name = "Sentiment Scale", colours = c('red','grey','green'), space = "Lab")
    emotion_spacial_hours <- emotion_spacial_hours + labs(title = "Sentiment Analysis",x = "lon", y = "lat")
    emotion_spacial_hours <- emotion_spacial_hours + coord_map()
    emotion_spacial_hours <- emotion_spacial_hours + facet_wrap(~ hours,nrow = 4)
    emotion_spacial_hours <- emotion_spacial_hours + theme(axis.text.x = element_text(angle=65, hjust = 1))

    plot(emotion_spacial_hours)

    dev.off()
    cat(paste("Great, file generated: ",dirSpatialTemporal,"/emotionSpatialHours.png\n",sep = ""))


    #Week Emotion Analysis
    png(file=paste(dirSpatialTemporal,"/emotionSpatialWeek.png",sep = ""), width = 800, height = 600)

    emotion_spacial_week <- ggmap(map)
    emotion_spacial_week <- emotion_spacial_week %+% df_emotion
    emotion_spacial_week <- emotion_spacial_week +  aes(x = lon, y = lat, z = df_emotion$emotion_synthesis)
    emotion_spacial_week <- emotion_spacial_week + stat_summary2d(fun = median, alpha = 0.7)
    emotion_spacial_week <- emotion_spacial_week + scale_fill_gradientn(name = "Sentiment Scale", colours = c('red','grey','green'), space = "Lab")
    emotion_spacial_week <- emotion_spacial_week + labs(title = "Sentiment Analysis",x = "lon", y = "lat")
    emotion_spacial_week <- emotion_spacial_week + coord_map()
    emotion_spacial_week <- emotion_spacial_week + facet_wrap(~ weekday, nrow = 2)
    emotion_spacial_week <- emotion_spacial_week + theme(axis.text.x = element_text(angle=65, hjust = 1))

    plot(emotion_spacial_week)

    dev.off()
    cat(paste("Great, file generated: ",dirSpatialTemporal,"/emotionSpatialWeek.png\n",sep = ""))

    #Month Emotion Analysis
    png(file=paste(dirSpatialTemporal,"/emotionSpatialMonth.png",sep = ""),width = 800, height = 600)

    emotion_spacial_month <- ggmap(map)
    emotion_spacial_month <- emotion_spacial_month %+% df_emotion
    emotion_spacial_month <- emotion_spacial_month +  aes(x = lon, y = lat, z = df_emotion$emotion_synthesis)
    emotion_spacial_month <- emotion_spacial_month + stat_summary2d(fun = median, alpha = 0.7)
    emotion_spacial_month <- emotion_spacial_month + scale_fill_gradientn(name = "Sentiment Scale", colours = c('red','grey','green'), space = "Lab")
    emotion_spacial_month <- emotion_spacial_month + labs(title = "Sentiment Analysis",x = "lon", y = "lat")
    emotion_spacial_month <- emotion_spacial_month + coord_map()
    emotion_spacial_month <- emotion_spacial_month + facet_wrap(~ month, nrow = 1)
    emotion_spacial_month <- emotion_spacial_month + theme(axis.text.x = element_text(angle=85, hjust = 1))

    plot(emotion_spacial_month)

    dev.off()
    cat(paste("Great, file generated: ",dirSpatialTemporal,"/emotionSpatialMonth.png\n",sep = ""))

    if(return_plot == TRUE){
      storage_plot_list = list()
      storage_plot_list[[1]] = emotion_spacial_geral
      storage_plot_list[[2]] = emotion_spacial_hours
      storage_plot_list[[3]] = emotion_spacial_week
      storage_plot_list[[4]] = emotion_spacial_month
      return(storage_plot_list)
    }

}
