#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Temporal Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: TEMPORAL ANALYSIS

lapply(c('ggplot2'), library, character.only = TRUE) #load libraries


temporalAnalysis <- function(df,dirTemporal, return_plot = FALSE){
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
  
  #Definition of labels
  df$weekday <-factor(df$weekday, levels = c(0,1,2,3,4,5,6), labels = c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat'))
  df$month <-factor(df$month, levels = c(1:12), labels = month_label)
  

  # Step 1: Temporal Analysis -----------------------------------------------
  
  # Breaks estabelece o espaço entre as barras de plot ( quando eu coloco -0.5 segnifica um espaço de metade da minha barra (a marcação vai para o centro), e os intervalos que eu quero é de 0 a sete)
  #Tweets in Times of Day
  ## Frequency of tweets in the hour of day
  storage_plot_list = list()
  
  png(file=paste(dirTemporal,"/tweetHours.png",sep = ""), width = 900, height = 700)
  
  hourHist <- ggplot(df, aes(hours))
  hourHist <- hourHist + geom_bar(aes(fill='red'), width = 0.7)
  #hourHist <- hourHist + theme(axis.text.x = element_text(angle=65)) 
  hourHist <- hourHist + guides(fill= FALSE)
  hourHist <- hourHist + labs(title="Histogram of Tweets in Times of Day") 
  hourHist <- hourHist +  scale_x_continuous(breaks = c(0:23))
  hourHist <- hourHist +  ylab(label = 'Frequency') + xlab(label = 'Hours')
  plot(hourHist)
  
  dev.off()
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetHours.png\n",sep = ""))
  
  #Density of Tweets in Hour
  png(file=paste(dirTemporal,"/tweetDensityHours.png",sep = ""), width = 900, height = 700)
  
  tweet_density_hours <- ggplot(df, aes(hours))
  tweet_density_hours <- tweet_density_hours + geom_density(alpha=0.6, fill = 'red' ) 
  tweet_density_hours <- tweet_density_hours +  labs(title="Hours of day", x="Hours", y = 'Tweets Density')
  tweet_density_hours <- tweet_density_hours + scale_x_continuous(breaks = round(seq(min(df$hours), max(df$hours), by = 1),1))
  tweet_density_hours <- tweet_density_hours 
  plot(tweet_density_hours)
  
  dev.off()
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetDensityHours.png\n",sep = ""))
  
  
  #Tweets in week
  png(file=paste(dirTemporal,"/tweetWeek.png",sep = ""), width = 900, height = 700)
 
  weekdayHist <- ggplot(df, aes(weekday))
  weekdayHist <- weekdayHist + geom_bar(aes(fill='red'), width = 0.9)
  #weekdayHist <- weekdayHist + theme(axis.text.x = element_text(angle=65)) 
  weekdayHist <- weekdayHist + guides(fill= FALSE)
  weekdayHist <- weekdayHist + labs(title="Histogram of Tweets in Weekday") 
  weekdayHist <- weekdayHist +  scale_x_discrete( labels = weekdays_label)
  weekdayHist <- weekdayHist +  ylab(label = 'Frequency') + xlab(label = 'Weekday')
  plot(weekdayHist)
  
  
  dev.off()
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetWeek.png\n",sep = ""))
  
  png(file=paste(dirTemporal,"/tweetDensityWeek.png",sep = ""), width = 800, height = 600)
  
  tweet_density_week <-ggplot(df) 
  tweet_density_week <-tweet_density_week +  geom_density(aes(x = weekday, fill = 'red') )
  tweet_density_week <-tweet_density_week + labs(fill = "Frequent User", alpha = NULL )
  tweet_density_week <-tweet_density_week + guides(fill = FALSE)
  tweet_density_week <-tweet_density_week + ggtitle("Tweet Density in Week")
  plot(tweet_density_week)
  dev.off()
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetDensityWeek.png\n",sep = ""))
  # Breaks estabelece o espaço entre as barras de plot ( quando eu coloco -0.5 segnifica um espaço de metade da minha barra (a marcação vai para o centro), e os intervalos que eu quero é de 0 a sete)
  
  
  # Tweets in a month
  ## Frequency of tweets during the month of year
  
  png(file=paste(dirTemporal,"/tweetMonth.png",sep = ""), width = 800, height = 600)
  
  monthHist <- ggplot(df, aes(month))
  monthHist <- monthHist + geom_bar(aes(fill='red'), width = 0.9)
  #monthHist <- monthHist + theme(axis.text.x = element_text(angle=65)) 
  monthHist <- monthHist + guides(fill= FALSE)
  monthHist <- monthHist + labs(title="Histogram of Tweets in Weekday") 
  #monthHist <- monthHist +  scale_x_discrete(labels = month_label,breaks= 1:12)
  monthHist <- monthHist +  ylab(label = 'Frequency') + xlab(label = 'Month')
  plot(monthHist)
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetMonth.png\n",sep = ""))
  
  
  png(file=paste(dirTemporal,"/tweetDensityMonth.png",sep = ""), width = 800, height = 600)
  
  tweet_density_month <-ggplot(df) 
  tweet_density_month <-tweet_density_month +  geom_density(aes(x = month, fill = 'red') )
  tweet_density_month <-tweet_density_month + labs(fill = "Frequent User", alpha = NULL )
  tweet_density_month <-tweet_density_month + guides(fill = FALSE)
  tweet_density_month <-tweet_density_month + ggtitle("Month Density in Week")
  plot(tweet_density_month)
  dev.off()
  
  cat(paste("Great, file generated: ",dirTemporal,"/tweetDensityMonth.png\n",sep = ""))
  
  
  dev.off()
  
  if (return_plot == TRUE){
  #cat(paste("Great, file generated: ",dirTemporal,"/tweetMonth.png\n",sep = ""))
    storage_plot_list[[1]] = hourHist
    storage_plot_list[[2]] = tweet_density_hours
    storage_plot_list[[3]] = weekdayHist
    storage_plot_list[[4]] = tweet_density_week
    storage_plot_list[[5]] = monthHist
    storage_plot_list[[6]] = tweet_density_month
    return(storage_plot_list)
  }
    
}