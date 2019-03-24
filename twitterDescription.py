#!/usr/bin/python3
# -*- coding: utf-8 -*-
##################################################
## Project: PPS - Participatory Social Sense
## Script purpose: incident grouping process
## Date: 03/02/2019
## Authors: Igor and Paulo H. L. Rettore
##################################################

# =======================================================================================================================
#   LIBRARIES
# =======================================================================================================================

import re
import sys
import nltk
from nltk.corpus import stopwords
import re
import indicoio
from nltk.stem import WordNetLemmatizer
import os
indicoio.config.api_key = 'b3ce830aabed72e9e3c708af8c2b29ff'
from nltk.tokenize import RegexpTokenizer
import pandas as pd
from multiprocessing import Process
import warnings
warnings.filterwarnings("ignore")
import multiprocessing
import numpy as np


# =======================================================================================================================
#   FUNCTIONS
# =======================================================================================================================
def sumarization(data_type, type):
    # data_type = data[data['incident_type'] == type]

    # data_original = data_type
    data_type['formated_text'] = ''
    data_type = data_type.reset_index()
    data_type = data_type.drop('index', 1)
    # data_type = to.frame(data_type)
    for index, row in data_type.iterrows():
        raw = row[['text']]
        # raw.lower()
        raw = raw['text'].lower()
        # COLOCAR UM FILTRO DE TEXTO AQUI PARA RETIRARA AS PALAVRAS MAIS ATRAPALHADAS
        # keep only words and removing http
        regex = re.compile(r'[^a-zA-Z\s]:', flags=re.UNICODE)
        raw = regex.sub(r'', raw)
        raw = re.sub(r"http\S+", "", raw)
        raw = re.sub("\d+", "", raw)
        ##############################################################################################################
        # TOKENIZATION/ LEMMANIZATION AND REMOVING STOP WORDS
        tokenizer = RegexpTokenizer(r'\w+')
        tokens = tokenizer.tokenize(raw)
        tagged = nltk.pos_tag(tokens)
        wnl = nltk.WordNetLemmatizer()
        # filtered_words = [wnl.lemmatize(w) for w in tokens if w not in stopwords.words('english')]
        sentence = ' '.join(tokens)
        # data_type.iloc[index]['formated_text'] = sentence
        data_type.loc[index, 'formated_text'] = sentence
    formated_data_text = ""

    # print(filtered_words)

    for p, sentence in data_type.iterrows():
        formated_data_text += sentence['formated_text']

    # sentence_list = list(data_type['text'])

    # conto a frequência de palavras
    stopwords = nltk.corpus.stopwords.words('english')
    word_frequencies = {}
    for word in nltk.word_tokenize(formated_data_text):
        if word not in stopwords:
            if word not in word_frequencies.keys():
                word_frequencies[word] = 1
            else:
                word_frequencies[word] += 1

    # sentence_scores = {}

    # remover os duplicados
    data_type = data_type.drop_duplicates(['formated_text'], keep='first')
    data_type['score'] = None
    data_type = data_type.reset_index()
    data_type = data_type.drop('index', 1)

    soma = 0

    for index, sent in data_type.iterrows():
        soma = 0
        for word in sent['formated_text'].split(' '):
            if word in word_frequencies.keys():
                if len(sent['formated_text'].split(' ')) < 30:
                    soma += word_frequencies[word]
        data_type.loc[index, 'score'] = soma

    data_type = data_type.sort_values('score', ascending=False)
    # reindex
    data_type = data_type.reset_index()
    data_type = data_type.drop('index', 1)

    # summary_sentences = heapq.nlargest(10, sentence_scores, key=sentence_scores.get)

    # summary = '\n'.join(summary_sentences)
    summary_sentences = list(data_type.loc[1:10, ]['text'])
    summary = '\n'.join(summary_sentences)

    return summary
    #
    # print('#####################################################################################################')
    # print('The summary for ' + str(type))
    # print(type)
    # print(summary)
    # print('#####################################################################################################')


def tweetDescriptionPerHour(data_main, hour_list, return_dict):
    for hour in hour_list:
        data_main_select_per_hour = data_main[data_main['hour'] == hour]
        return_dict[hour] = sumarization(data_main_select_per_hour,'Hour :'+ str(hour))

def tweetDescriptionByEmotion(data_main, emotionList,return_dict):
    for emotion in emotionList:
        data_main_select_per_emotion = data_main[data_main['emotion_synthesis'] == emotion]
        return_dict[emotion] = sumarization(data_main_select_per_emotion,'Emotion Scale: ' + str(emotion))


    #sumarization(data_main_select_per_hour, hour)

def multiprocessedDescriptionHour(place,hour_list,threads= 4):
    data_main = pd.read_csv('Data/' + place + '/tweets_sentiment.csv', parse_dates=['created_at'])  # CSV criado na etapa anterior contendo os tweets com seus lat-long
    data_main['hour'] = data_main.created_at.apply(lambda x: x.hour)
    hour_section = np.array_split(hour_list, threads)

    #Variables to handle with diferents process
    manager = multiprocessing.Manager()
    return_dict = manager.dict()
    processes = []
    #Collect the process
    for hours in hour_section:
            p = Process(target=tweetDescriptionPerHour, args=(data_main[data_main['hour'].isin(list(hours))],hours, return_dict))
            processes.append(p)

    # Start the processes
    for p in processes:
        p.start()

    # Ensure all processes have finished execution
    for p in processes:
        p.join()


    for hour in hour_list:
        print('#####################################################################################################')
        print('The summary for hour:' + str(hour) )
        print(return_dict[hour])
        print('#####################################################################################################')




def multiprocessedDescriptionSentiment(place, threads=4):
    data_main = pd.read_csv('Data/' + place + '/tweets_sentiment.csv', parse_dates=['created_at'])  # CSV criado na etapa anterior contendo os tweets com seus lat-long
    data_main['hour'] = data_main.created_at.apply(lambda x: x.hour)
    emotionList = list(data_main['emotion_synthesis'].unique())
    emotion_section = np.array_split(emotionList, threads)

    manager = multiprocessing.Manager()
    return_dict = manager.dict()


    processes = []

    # Collect the process
    for emotions in emotion_section:
        p = Process(target=tweetDescriptionByEmotion,args=(data_main[data_main['emotion_synthesis'].isin(list(emotions))], emotions,return_dict))
        processes.append(p)

    # Start the processes
    for p in processes:
        p.start()

    # Ensure all processes have finished execution
    for p in processes:
        p.join()

    for emotion in sorted(emotionList):
        print(
            '#####################################################################################################')
        print('The summary for emotion scale:' + str(emotion))
        print(return_dict[emotion])
        print(
            '#####################################################################################################')


if __name__ == '__main__':

    place = sys.argv[1]
    # place = 'Manhattan'
    initial_description_per_hour = int (sys.argv[2])
    final_description_per_hour = int(sys.argv[3])
    hour_description = int(sys.argv[4])
    # hour_description = False
    # emotion_description = True
    #
    emotion_description = int(sys.argv[5])
    hour_list = range(initial_description_per_hour, final_description_per_hour)

    # hour_list = range(1, 3)
    if (hour_description == True):
           multiprocessedDescriptionHour(place,hour_list,threads= 4)

    if (emotion_description == True):
        multiprocessedDescriptionSentiment(place,threads= 4)





