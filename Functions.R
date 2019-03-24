
# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session.
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(c('syuzhet'))

addEmotions <- function(dataframe_input) {

  cl <- makeCluster(4) # create clusters to process in parallel # or detect_cores() - 1

  text_emotions <- get_nrc_sentiment(dataframe_input$text, cl = cl)  #add t to each tweet

  stopCluster(cl) #stop the clusters

  df_with_emotions <- cbind(dataframe_input,text_emotions) #bind df and t

  #Synthesis of emotion (good or bad) from tweeter
  df_with_emotions$emotion_synthesis <- df_with_emotions$positive - df_with_emotions$negative

  return(df_with_emotions)
}

boundingBoxingPartition <- function(bounding_box,x){ #default = 10
  bounding_list <- list()
  k=1
  gapLat <- (bounding_box[4] - bounding_box[2])/x
  gapLong <- (bounding_box[3] - bounding_box[1])/x
  for (i in (seq(x)-1)){ #percorre a latitude
    for (j in (seq(x)-1)){ #percorre a longitude
      bounding_list[[k]] <- c(bounding_box[1]+ (gapLong*j), bounding_box[2] + (gapLat *i), bounding_box[1] + (gapLong*(j+1)), bounding_box[2] + (gapLat * (i+1)),j+1,i+1)
      k = k+1    
    }
  }
  return (bounding_list)
}

fixBoundboxTwitter <- function(twitter_data,bound_boxes){   #Verifica se os tweets estão dentro do bounding box especificado na coleta
  #Seleciono os dataframes que estão dentro do meu bounding box
  
  twitter_data <- twitter_data[twitter_data['long'] > bound_boxes[1],]
  twitter_data <- twitter_data[twitter_data['long'] < bound_boxes[3],]
  twitter_data <- twitter_data[twitter_data['lat'] > bound_boxes[2],]
  twitter_data <- twitter_data[twitter_data['lat'] < bound_boxes[4],]
  twitter_data['section_x'] <- bound_boxes[5]
  twitter_data['section_y'] <- bound_boxes[6]
  return (twitter_data)
}


filterAndLabelSection <- function(twitter_data, bounding_box, x){
  bounding_list <- boundingBoxingPartition(bounding_box,x)#creating bounding list
  df_twitter <- data.frame()
  for (i in seq(x*x)){  #atribui secao aos meus tweets
    result = fix_boundbox_twitter(twitter_data,bounding_list[[i]])
    df_twitter <- rbind(df_twitter, result)
  }
  return(df_twitter)
}


