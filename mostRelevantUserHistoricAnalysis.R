#!/usr/bin/env Rscript
#############################################
## Project: Twitter Crawler Tools
## Script purpose: Historic Analysis of dataframe
## Date: 03/02/2019
## Author: Igor Araújo
#############################################

#INPUT: DATAFRAME
#OUTPUT: HISTORIC ANALYSIS FROM TWEETS OF MOST RELEVANT USER


mostRelevantUserHistoricAnalysis <- function(dirHistoricFrequentUser,dirFrequentAccounts,sample_most_frequent_user,time_zone,return_plot = FALSE){
  # Step 5: Most Relevant Accounts Analysis ---------------------------------

  dir_fusion_name <- dir(dirHistoricFrequentUser, pattern = "*.csv")

  fused_data <- do.call("rbind", lapply(dir_fusion_name, function(x) {
    dat <- read.csv(paste(dirHistoricFrequentUser,x,sep = '' ), stringsAsFactors = FALSE , header=TRUE)
    dat$created_at <- strptime(dat$created_at, "%Y-%m-%d %H:%M:%S", tz="GMT") - time_zone*3600
    dat$screen_name <- tools::file_path_sans_ext(basename(x))
    dat
  }))

  colnames(fused_data)[5] <- 'time'


  # #Sort by screen_name and time
  fused_data <- fused_data[order(fused_data$screen_name,fused_data$time),]
  #
  fused_data <- fused_data %>%
    arrange(screen_name, time) %>%
    group_by(screen_name) %>%
    mutate(id = row_number())


  # Most Retweeted Accounts
  retweeted_account <- fused_data[fused_data$retweet_count != 0, c("screen_name","retweet_count")]
  #retweeted_account$totalretweets <-

  
  if(nrow(retweeted_account) != 0){
    #retweeted_account <- count(retweeted_account,)
    retweeted_account <- aggregate(retweet_count ~ screen_name, data = retweeted_account, sum)
  
    #Reoording in Decrescent way
    retweeted_account <- retweeted_account[order(retweeted_account$retweet_count,decreasing = TRUE),]
  
    png(file=paste(dirFrequentAccounts,"/MostRetweetedAccount.png",sep = ""), width = 800, height = 600)
  
    Most_retweeted_account <- ggplot(data=retweeted_account, aes(x= reorder(screen_name, -retweet_count), y=retweet_count))
    Most_retweeted_account <- Most_retweeted_account +  geom_bar(stat="identity")
    Most_retweeted_account <- Most_retweeted_account +  theme_bw()
    Most_retweeted_account <- Most_retweeted_account +  theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 8))
    Most_retweeted_account <- Most_retweeted_account +  scale_size_continuous(range = c(3,10))
    Most_retweeted_account <- Most_retweeted_account + labs(title = "Most Retweeted Accounts", x = "Accounts", y = "Retweets")
    Most_retweeted_account <- Most_retweeted_account + geom_col(colour="black", position="dodge", fill = 'red')
    plot(Most_retweeted_account)
    dev.off()
  
    cat(paste("Great, file generated: ",dirFrequentAccounts,"/MostRetweetedAccount.png\n",sep = ""))
  }else{
    cat("There isn't enough data for retweeted analysis ranking\n")
  }

  #Most Favorite Accounts
  most_favorited <- fused_data[fused_data$favorite_count != 0, c("screen_name","favorite_count")]

  
  if(nrow(most_favorited) != 0){
    most_favorited <- aggregate(favorite_count ~ screen_name, data = most_favorited, FUN = sum)
  
    most_favorited <- most_favorited[order(most_favorited$favorite_count,decreasing = TRUE), ]
  
    #Reoording in Decrescent way
  
    png(file=paste(dirFrequentAccounts,"/MostFavoritedAccount.png",sep = ""), width = 800, height = 600)
    Most_favorite_account <- ggplot(data=most_favorited, aes(x= reorder(screen_name, -favorite_count), y=favorite_count))
    Most_favorite_account <- Most_favorite_account + geom_bar(stat="identity")
    Most_favorite_account <- Most_favorite_account + theme(legend.direction="horizontal")
    Most_favorite_account <- Most_favorite_account + theme_bw()
    Most_favorite_account <- Most_favorite_account + theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 8))
    Most_favorite_account <- Most_favorite_account + scale_size_continuous(range = c(3,10))
    Most_favorite_account <- Most_favorite_account + labs(title = "Most Favorite Accounts", x = "Accounts", y = "Favorites")
    Most_favorite_account <- Most_favorite_account + geom_col(colour="black", position="dodge", fill = 'blue')
    plot(Most_favorite_account)
    dev.off()
  
    cat(paste("Great, file generated: ",dirFrequentAccounts,"/MostFavoritedAccount.png\n",sep = ""))
  }else{
    cat("There isn't enough data for favourite analysis ranking\n")
    
  }

  # Most Relevant Account

  relevant_account <- fused_data[fused_data$favorite_count != 0 |fused_data$retweet_count != 0 , c("screen_name","favorite_count","retweet_count")]
  
  if(nrow(relevant_account) != 0){
    relevant_account_wit_total_3_1 <- aggregate( retweet_count ~ screen_name ,data = relevant_account, sum)
    relevant_account_wit_total_3_2 <- aggregate( favorite_count ~ screen_name ,data = relevant_account, sum)
    relevant_account_wit_total_3 <- merge(relevant_account_wit_total_3_1,relevant_account_wit_total_3_2, by=c("screen_name"))
    relevant_account_wit_total_3 <- melt(relevant_account_wit_total_3, id=c("screen_name"))
  
    #change variables names
    relevant_account_wit_total_3$variable <- factor(relevant_account_wit_total_3$variable, levels=c("retweet_count", "favorite_count"), labels=c("Retweet Count", "Favorite Count"))
  
    png(file=paste(dirFrequentAccounts,"/Most_Relevant_Accounts.png",sep = ""), width = 800, height = 600)
    Most_Relevant_accounts <- ggplot(data=relevant_account_wit_total_3, aes(x= reorder(screen_name, -value), y=value, group=variable , fill=variable))
    Most_Relevant_accounts <- Most_Relevant_accounts + geom_bar(stat="identity")
    Most_Relevant_accounts <- Most_Relevant_accounts +  theme(axis.text.x = element_text(angle = 45, hjust = 1,size = 8))
    Most_Relevant_accounts <- Most_Relevant_accounts +  labs(title = "Most Relevant Accounts", x = "Accounts", y = "Value ")
    Most_Relevant_accounts <- Most_Relevant_accounts +  guides(fill = guide_legend(title = "Variables", title.position = "top"))
    plot(Most_Relevant_accounts)
    dev.off()
  
    cat(paste("Great, file generated: ",dirFrequentAccounts,"/Most_Relevant_Accounts.png\n",sep = ""))
  }else{
    cat("There isn't enough data for most relevant data analysis analysis ranking\n")
  }

  if(return_plot == TRUE){
    storage_plot_list = list()
    storage_plot_list[[1]] = Most_retweeted_account
    storage_plot_list[[2]] = Most_favorite_account
    storage_plot_list[[3]] = Most_Relevant_accounts
    return(storage_plot_list)
  }
}