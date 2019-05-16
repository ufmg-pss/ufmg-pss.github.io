#!/usr/bin/python3
# -*- coding: utf-8 -*-
#############################################
## Project: PPS - Participatory Social Sense
## Script purpose: create folder for to save images analysis
## Date: 03/02/2019
## Author: Igor and Paulo H. L. Rettore
#############################################


# =======================================================================================================================
#   LIBRARIES
# =======================================================================================================================
import pandas as pd
import os
import datetime
import os.path
import tweepy

DIR_SAVE_TRACE_USER = "Data/Traces"


# =======================================================================================================================
#   FUNCTIONS
# =======================================================================================================================


def to_datetime_format(tweetString):   #Converte o campo time de string para formato datetime
    Data = datetime.datetime.strptime(tweetString, '%Y-%m-%d %H:%M:%S')
    #Modulo para encontrar a hora local de determinada região
    return Data


def filter_tweets_with_lat_lon (alltweets):
    tweets_with_lat_lon = []

    for tweet in alltweets:
        if ((tweet.geo is not None) or (tweet.coordinates is not None)):
            tweets_with_lat_lon.append(tweet)

    return tweets_with_lat_lon


#Function to cut the dataframe temporaly
def temporalCut(tweets,initial_time_historic,final_time_historic):

    tracestweets = pd.DataFrame(tweets, columns=['id_str', 'lat', 'lon', 'created_at'])

    #convert to type date
    initial_time_historic = to_datetime_format(initial_time_historic)
    final_time_historic = to_datetime_format(final_time_historic)

    tracestweets = tracestweets[tracestweets['created_at'] > initial_time_historic]
    tracestweets = tracestweets[tracestweets['created_at']< final_time_historic]
    return tracestweets


def get_all_tweets(screen_name, place, api):
    root_dir = 'Data/' + place + "/"
    #Twitter only allows access to a users most recent 3240 tweets with this method
    # 	#authorize twitter, initialize tweepy


    #initialize a list to hold all the tweepy Tweets
    alltweets = []

    #make initial request for most recent tweets (200 is the jjkjjhjjjjjame,count=200)
    new_tweets = api.user_timeline(screen_name=screen_name, count=200)

    #save most recent tweets
    alltweets.extend(new_tweets)

    #save the id of the oldest tweet less one
    oldest = alltweets[-1].id - 1

    #keep grabbing tweets until there are no tweets left to grab
    while len(new_tweets) > 0:
        # print ("getting tweets before %s" % (oldest))

        #all subsiquent requests use the max_id param to prevent duplicates
        new_tweets = api.user_timeline(screen_name = screen_name,count=200,max_id=oldest)

        #save most recent tweets
        alltweets.extend(new_tweets)

        #update the id of the oldest tweet less one
        oldest = alltweets[-1].id - 1

        print("...%s tweets downloaded so far" % (len(alltweets)))


    tweets_with_lat_lon = filter_tweets_with_lat_lon(alltweets)
    print ("...%s tweets with geolocations" % (len(tweets_with_lat_lon)))  #just tweets with geolocations



    #transform the tweepy tweets into a 2D array that will populate the csv
    outtweets = [[tweet.text.encode("utf-8"),tweet.id_str, tweet.geo['coordinates'][0],tweet.geo['coordinates'][1],tweet.created_at,tweet.retweet_count ,tweet.favorite_count] for tweet in tweets_with_lat_lon]

    if not os.path.exists(root_dir + 'HistoryFrequentUser'):
        os.makedirs(root_dir + 'HistoryFrequentUser')

    if (len(outtweets) == 0):
        print("Getting out of function...")
        return(0)

    #transfor in dataframe
    outtweets = pd.DataFrame(outtweets, columns=['text','id_str', 'lat', 'lon', 'created_at','retweet_count','favorite_count'])

    dir_name = str('Data/' + place + '/HistoryFrequentUser/' + '%s_tweets.csv' % screen_name)
    outtweets.to_csv(dir_name, sep=",", index = False)

    return(1)



def merge_csv_file (root_dir):
    root_dir_user_trace = root_dir + 'HistoryFrequentUser/'
    df = pd.DataFrame()
    for dirName, subdirList, fileList in os.walk(root_dir_user_trace):
        for file_ in fileList:
            if (file_.endswith(".csv")):
                file_df = pd.read_csv(root_dir_user_trace+ file_)
                file_df['screen_name'] = file_
                df = df.append(file_df)

    #save user trace .csv
    df.to_csv(root_dir + "user_trace.csv", index=False)
    print("The process has just merged trace user files...")


def user_tweets_from_csv(place, bound_box, number_user_tarce,RemoveOriginal,api):
        root_dir = 'Data/' + place + "/"
        data_frame_user = pd.read_csv(root_dir + "tweets_gerados.csv" )
        data_frame_user = data_frame_user.groupby(['screen_name']).size().reset_index(name='counts').sort_values('counts',ascending=False)
        user_list = data_frame_user.iloc[0:number_user_tarce ]
        for screen_name in user_list['screen_name']:
                print("Getting tweets from : " + screen_name)
                try:
                    get_all_tweets(screen_name, place, api)
                except tweepy.TweepError:
                    print("Failed to run the command on that user, Skipping...")
                






