#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: incident Description for R
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME WITH SENTIMENT
#OUTPUT: DESCRIPTION ANALYSIS
parameters_list =c('text','id_str','lat','lon','created_at','emotion_synthesis')
  
twitterDescription <- function (df_emotion,place,initial_time_description_per_hour,final_time_description_per_hour,save_csv = TRUE){
  
  if(save_csv == TRUE){
    write.csv(df_emotion[parameters_list],file = paste('Data',place,"tweets_sentiment.csv",sep = '/' ), row.names = FALSE)
  }
  command_text = paste("python3.5" ,"twitterDescription.py",sep = ' ')
  command_text = paste (command_text, place, sep = ' ') #[1]
  command_text = paste (command_text, initial_time_description_per_hour, sep = ' ') #[2]
  command_text = paste (command_text, final_time_description_per_hour, sep = ' ') #[3]
  command_text_per_hour = paste (command_text, 1, sep = ' ') #[3] 1  - Descricao por hora
  command_text_per_hour = paste (command_text_per_hour, 0, sep = ' ') #[3] 2 - Descricao por emocao
  
  command_text_per_hour = paste (command_text_per_hour, " | tee Results/",place, "/SpacialTemporal/descriptionPerHour.txt",sep = "")
  
  system(command = command_text_per_hour,show.output.on.console = TRUE)
  
  
  
  command_text = paste("python3.5" ,"twitterDescription.py",sep = ' ')
  command_text = paste (command_text, place, sep = ' ') #[1]
  command_text = paste (command_text, initial_time_description_per_hour, sep = ' ') #[2]
  command_text = paste (command_text, final_time_description_per_hour, sep = ' ') #[3]
  command_text_per_emotion = paste (command_text, 0, sep = ' ') #[3] 1  - Descricao por hora
  command_text_per_emotion = paste (command_text_per_emotion, 1, sep = ' ') #[3] 2 - Descricao por emocao
  
  
  command_text_per_emotion = paste (command_text_per_emotion, " | tee Results/",place, "/SpacialTemporal/descriptionPerEmotion.txt",sep = "")
  
  
  
  system(command = command_text_per_emotion,show.output.on.console = TRUE)
  
  
  
  
}
