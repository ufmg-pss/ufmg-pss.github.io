#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Frequent User Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: FREQUENT USER ANALYSIS

mostFrequentUserTemporalSpatialRouteAnalysis<- function(df,dirFrequentAccount,sample_most_frequent_user,initial_time_plot_trace = NULL,final_time_plot_trace= NULL,caracterization_routes= TRUE,return_plot = FALSE){

# Step 0 ------------------------------------------------------------------


  if (is.null(initial_time_plot_trace)) {
    initial_time_plot_trace = min(df$created_at)
  }

  if (is.null(final_time_plot_trace)){
    final_time_plot_trace = max(df$created_at)
  }



  df_trace_user <- df
  df_trace_user <- df_trace_user[, c('screen_name','lat','lon','created_at')]

  #colnames(df_trace_user)[3] <- 'lon'

  #Month
  month_label = c("Jan","Feb.","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec")

  #Week
  weekdays_label <-c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat')

  #create df temporal attributions

  #Hours
  df_trace_user$hours <- as.numeric(format(df_trace_user$created_at, '%H'))

  #Weekday
  df_trace_user$weekday <- as.numeric(format(df_trace_user$created_at, '%w')) # Agora eu defino ele numérico

  #Month
  df_trace_user$month <- as.numeric(format(df_trace_user$created_at, '%m'))

  #Defening temporal  variable as factor
  df_trace_user$weekday <-factor(df_trace_user$weekday, levels = c(0,1,2,3,4,5,6), labels = c('Sun','Mon','Tues','Wed','Thurs','Fri','Sat'))
  df_trace_user$month <-factor(df_trace_user$month, levels = c(1:12), labels = month_label)


  # Step 4: Caracterization Routes ------------------------------------------
  ### Catacterize the tweets Routes in the specific range of collect data (it's not a historical tool)


  #Sort by screen_name and time

  df_trace_user <- df_trace_user %>%
    arrange(screen_name, created_at) %>%
    group_by(screen_name) %>%
    mutate(id = row_number())

  user_for_select <-  names(sort(table(df_trace_user$screen_name),decreasing = TRUE)[1:sample_most_frequent_user])

  #fused_data <- add_emotions(fused_data)

  ########mudar data final e inicial

  df_trace_user <- df_trace_user[df_trace_user$created_at > initial_time_plot_trace & df_trace_user$created_at < final_time_plot_trace,]

  df_trace_user <- df_trace_user[order(df_trace_user$screen_name,df_trace_user$created_at),]

  df_trace_user <- df_trace_user[df_trace_user$screen_name %in%user_for_select,]

  df_trace_user$id <- seq(1,nrow(df_trace_user)) #adjusting id in seq

  png(file=paste(dirFrequentAccounts,"/tweetMostFrequentUserRoutes.png",sep = ""), width = 800, height = 600)
  user_trace <- ggmap(map)
  #%in% is for vector comparision
  user_trace <- user_trace + geom_path(data = df_trace_user, size = 1, aes(color = 'green'),lineend = "round")
  user_trace <- user_trace + geom_label(data = df_trace_user,size = 2,  col = "#E41A1C", aes(label = id))
  user_trace <-  user_trace + theme(legend.position="none")
  user_trace <- user_trace + facet_wrap(~screen_name, nrow = 1)
  user_trace <- user_trace + theme(axis.text.x = element_text(angle=65, hjust = 1))

  plot(user_trace)

  dev.off()

  cat(paste("Great, file generated: ",dirFrequentAccounts,"/tweetMostFrequentUserRoutes.png\n",sep = ""))


  png(file=paste(dirFrequentAccounts,"/DensityFrequentUserHour.png",sep = ""), width = 1800, height = 1200)

  frequent_user_hour_density <-ggplot(df_trace_user)
  frequent_user_hour_density <-frequent_user_hour_density +  geom_density(aes(x = hours, fill = screen_name,alpha = 0.5) )
  frequent_user_hour_density <-frequent_user_hour_density + labs(fill = "Frequent User", alpha = NULL )
  frequent_user_hour_density <-frequent_user_hour_density+ guides(alpha = FALSE)
  frequent_user_hour_density <-frequent_user_hour_density + ggtitle("Density Frequent User in Hour")
  plot(frequent_user_hour_density)

  dev.off()
  cat(paste("Great, file generated: ",dirFrequentAccounts,"/DensityFrequentUserHour.png\n",sep = ""))

  png(file=paste(dirFrequentAccounts,"/DensityFrequentUserWeekday.png",sep = ""), width = 1800, height = 1200)

  frequent_user_weekday_density <-ggplot(df_trace_user)
  frequent_user_weekday_density <-frequent_user_weekday_density +  geom_density(aes(x = weekday, fill = screen_name,alpha = 0.8) )
  frequent_user_weekday_density <-frequent_user_weekday_density + labs(fill = "Frequent User", alpha = NULL )
  frequent_user_weekday_density <-frequent_user_weekday_density + guides(alpha = FALSE)
  frequent_user_weekday_density <-frequent_user_weekday_density + ggtitle("Density Frequent User in Week")
  frequent_user_weekday_density <- frequent_user_weekday_density + theme(axis.text.x = element_text(angle=65, hjust = 1))

  plot(frequent_user_weekday_density)

  dev.off()
  cat(paste("Great, file generated: ",dirFrequentAccounts,"/DensityFrequentUserWeekday.png\n",sep = ""))

  png(file=paste(dirFrequentAccounts,"/DensityFrequentUserMonth.png",sep = ""), width = 1800, height = 1200)

  frequent_user_month_density <-ggplot(df_trace_user)
  frequent_user_month_density <-frequent_user_month_density +  geom_density(aes(x = month, fill = screen_name,alpha = 0.8) )
  frequent_user_month_density <-frequent_user_month_density + labs(fill = "Frequent User", alpha = NULL )
  frequent_user_month_density <-frequent_user_month_density + guides(alpha = FALSE)
  frequent_user_month_density <-frequent_user_month_density + ggtitle("Density Frequent User in Hour")
  plot(frequent_user_month_density)
  dev.off()
  cat(paste("Great, file generated: ",dirFrequentAccounts,"/DensityFrequentUserMonth.png\n",sep = ""))


  if (return_plot == TRUE){
    storage_plot_list = list()
    storage_plot_list[[1]] = user_trace
    storage_plot_list[[2]] = frequent_user_hour_density
    storage_plot_list[[3]] = frequent_user_weekday_density
    storage_plot_list[[4]] = frequent_user_month_density
    return(storage_plot_list)
  }


}
