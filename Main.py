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

import createFolders
import DataTreatment
import Crawler
import configparser
import tweepy
import time as tm
import UserTrace
import os.path

if __name__ == '__main__':

    #READ CONFIG FILE

    # Read configuration file

    config = configparser.ConfigParser()  # cria objeto do tipo config parser

    config.read("Config.ini")

    #Program Settings

    data_collect = int(config['ProgramSettings']['DataCollect'])
    data_treatment = int(config['ProgramSettings']['DataTreatment'])
    data_analysis = int(config['ProgramSettings']['DataAnalysis'])


    # Twitter Keys
    ckey = config['TwitterKeys']['ConsumerKey']

    csecret = config['TwitterKeys']['ConsumerSecret']

    # Chave para mexer somente com meu usuário

    atoken = config['TwitterKeys']['AcessToken']

    asecret = config['TwitterKeys']['AcessSecret']


    # Collections Sections

    bound_boxing = config['CollectionSettings']['BoundingBoxes']

    bound_boxing = bound_boxing.split(',')

    bound_boxing = [float(i) for i in bound_boxing]

    place = config['CollectionSettings']['Place']

    track = config['CollectionSettings']['Track']

    hours_of_colect = float(config['CollectionSettings']['HoursOfCollect'])

    time_zone = config['CollectionSettings']['TimeZone']

    lang = config['CollectionSettings']['Language']

    # Plot Settings


    temporal_analysis = config['PlotSettings']['TemporalAnalysis']

    spatial_analysis = config['PlotSettings']['SpatialAnalysis']

    spatial_temporal_analysis = config['PlotSettings']['SpatialTemporalAnalysis']

    emotion_sysnthesis = config['PlotSettings']['EmotionSynthesis']

    twitter_description = config['PlotSettings']['TwitterDescription']

    initial_time_description_per_hour = config['PlotSettings']['InitialTimeDescriptionPerHour']

    final_time_description_per_hour = config['PlotSettings']['FinalTimeDescriptionPerHour']

    number_most_frequent_user = int(config['PlotSettings']['NumberMostFrequentUserAnalysis'])

    frequent_user_analysis = config['PlotSettings']['FrequentUserAnalysis']

    save_trace = config['PlotSettings']['SaveTraceCSV']

    initial_time_plot_trace = config['PlotSettings']['InitialTimeForPlotTrace']

    final_time_plot_trace = config['PlotSettings']['FinalTimeForPlotTrace']

    history_analysis = config['PlotSettings']['HistoryAnalysis']


    # Initialize Variables

    initial_colect_time = tm.time()

    final_colect_time = initial_colect_time + 3600 * hours_of_colect

    root_dir = 'Data/' + place + "/"

    auth = tweepy.OAuthHandler(ckey, csecret)   #autorization for validation

    api = tweepy.API(auth, wait_on_rate_limit=True) #initialize api

    # Create Directry to saving data

    createFolders.createFolders(place)

    if (data_collect):
        Crawler.coleta_streaming(bound_boxing,track, root_dir , ckey,csecret,atoken,asecret,initial_colect_time,final_colect_time, language=lang)   #Função para coleta de dados do twitter

    # ########################################################### PROCESS USER TWITTER #####################################################
    if (data_treatment):
        DataTreatment.json_2_csv(root_dir,bound_boxing)    #Tranformar o arquivo JSON em um arqui CSV e salvalo em root_dir
        DataTreatment.join_csv_files_filtering_bounding_box(root_dir ,bound_boxing,True)
        UserTrace.user_tweets_from_csv(place,bound_boxing,number_most_frequent_user,False,api)
    # # ########################################################### TWEETS ANALYSIS ##################################################################

    # os.system("Rscript Characterization.R " + "Data/" + place + "/tweets_gerados.csv " + config['Settings']['BoundingBoxes'] + " " )

    # Constrcting parameters
    if(data_analysis):
        text_terminal = "Rscript Characterization.R " + " " + place  # [1]
        text_terminal = text_terminal + " " + config['CollectionSettings']['BoundingBoxes']  # [2]
        text_terminal = text_terminal + " " + time_zone  #[3]
        text_terminal = text_terminal + " " + temporal_analysis #[4]
        text_terminal = text_terminal + " " + spatial_analysis #[5]
        text_terminal = text_terminal + " " + spatial_temporal_analysis #[6]
        text_terminal = text_terminal + " " + emotion_sysnthesis #[7]
        text_terminal = text_terminal + " " + twitter_description #[8]
        text_terminal = text_terminal + " " + initial_time_description_per_hour  #[9]
        text_terminal = text_terminal + " " + final_time_description_per_hour  #[10]
        text_terminal = text_terminal + " " + frequent_user_analysis #[11]
        text_terminal = text_terminal + " " + str(number_most_frequent_user)  #[12]
        text_terminal = text_terminal + " " + initial_time_plot_trace  #[13]
        text_terminal = text_terminal + " " + final_time_plot_trace  #[14]
        text_terminal = text_terminal + " " + history_analysis #[15]


        os.system(text_terminal)
    # os.system("Rscript Characterization.R " + " " + place + " " + config['CollectionSettings']['BoundingBoxes'] + " " +time_zone  + " " + trace_analysis + " " + sample_user_trace + " " + hours_of_colect + " " + sample_most_frequenty_user)
    print("The process has just finished...")
