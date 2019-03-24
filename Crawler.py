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


import numpy as np
import os
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener, json
import time as tm
import json
from datetime import date
# the regular imports, as well as this:
from urllib3.exceptions import ProtocolError


# =======================================================================================================================
#   FUNCTIONS
# =======================================================================================================================


#COLETA DE DADOS
time = 0    # constane that will wait the time


def creating_folders(dataFolder):
    if (os.path.isdir(dataFolder) == False):
        os.makedirs(dataFolder)

#Recebe o twitter e faz uma filtragem bruta dos meus dados
def basic_filter(new_data):
    if ('retweeted_status') in new_data:
        if (new_data['retweeted_status'] == None):
            new_data.pop('retweeted_status')
        else:
            dic = {'retweeted_status_id': new_data['retweeted_status']['id_str']}
            new_data.update(dic)
            new_data.pop('retweeted_status')



    if ('id') in new_data:
        del (new_data['id'])

    if ('contributors') in new_data:
        del (new_data['contributors'])

    if ('possibly_sensitive') in new_data:
        del (new_data['possibly_sensitive'])

    if ('truncated') in new_data:
        del (new_data['truncated'])

    if ('in_reply_to_status_id') in new_data:
        del (new_data['in_reply_to_status_id'])

    if ('in_reply_to_status_id') in new_data['user']:
        del (new_data['user']['contributors_enabled'])

    if ('is_translator') in new_data['user']:
        del (new_data['user']['is_translator'])

    if ('profile_background_color') in new_data['user']:
        del (new_data['user']['profile_background_color'])

    if ('profile_background_image_url') in new_data['user']:
        del (new_data['user']['profile_background_image_url'])

    if ('profile_background_image_url_https') in new_data['user']:
        del (new_data['user']['profile_background_image_url_https'])

    if ('default_profile_image') in new_data['user']:
        del (new_data['user']['default_profile_image'])

    if ('default_profile_image') in new_data['user']:
        del (new_data['user']['default_profile_image'])

    if ('profile_link_color') in new_data['user']:
        del (new_data['user']['profile_link_color'])

    if ('profile_sidebar_border_color') in new_data['user']:
        del (new_data['user']['profile_sidebar_border_color'])

    if ('profile_sidebar_fill_color') in new_data['user']:
        del (new_data['user']['profile_sidebar_fill_color'])

    if ('profile_text_color') in new_data['user']:
        del (new_data['user']['profile_text_color'])

    if ('profile_use_background_image') in new_data['user']:
        del (new_data['user']['profile_use_background_image'])

    if ('profile_image_url_https') in new_data['user']:
        del (new_data['user']['profile_image_url_https'])

    if ('profile_image_url') in new_data['user']:
        del (new_data['user']['profile_image_url'])

    if ('default_profile_image') in new_data['user']:
        del (new_data['user']['default_profile_image'])

    if ('profile_background_tile') in new_data['user']:
        del (new_data['user']['profile_background_tile'])

    if ('notifications') in new_data['user']:
        del (new_data['user']['notifications'])

    if ('default_profile') in new_data['user']:
        del (new_data['user']['default_profile'])

    if ('is_quote_status') in new_data['user']:
        del (new_data['user']['is_quote_status'])

    if ('is_quote_status') in new_data:
        del (new_data['is_quote_status'])

    if ('quoted_status_id') in new_data['user']:
        del (new_data['user']['is_quote_status'])

    if ('display_text_range') in new_data['user']:
        del (new_data['user']['is_quote_status'])

    if ('quoted_status_permalink') in new_data['user']:
        del (new_data['user']['is_quote_status'])

    if ('contributors_enabled') in new_data['user']:
        del (new_data['user']['contributors_enabled'])

    if ('quoted_status_id_str') in new_data['user']:
        del (new_data['user']['is_quote_status'])

    if ('filter_level') in new_data:
        del (new_data['filter_level'])

    if ('quote_count') in new_data['user']:
        del (new_data['user']['quote_count'])

    if ('filter_level') in new_data['user']:
        del (new_data['user']['filter_level'])


def error_handler(e,bound_boxes, track, dir,ckey,csecret,atoken,asecret,initial_colect_time,final_colect_time,time):       #error_handler = 1 min / 3 min  / 5 min
    print( 'O erro encontrado é:' + str(e))
    if (time == 7):
        time = 1
    tm.sleep(time * 60)   # wait for 60 seconds and call coleta_streaming again
    coleta_streaming(bound_boxes, track, dir,ckey,csecret,atoken,asecret,initial_colect_time,final_colect_time, time +2)

    # Chamo novamente minha função de coleta (streaming)


#Abre o Streaming e faz a coleta de dados (Input: Tweet  Output: Arquivo.txt )
def coleta_streaming(bound_boxes, track, dir,ckey,csecret,atoken,asecret,initial_colect_time,final_colect_time = 1, time = 1, language = 'en'):

    creating_folders(dir) # aqui criamos a pasta caso nao exista

    #Extendo a minha classelistenar para coleta de dados
    class listener(StreamListener):
        def on_data(self, data):
            if(final_colect_time > tm.time()):
                try:
                    with open(dir+ date.today().isoformat() +  '.txt', 'a') as f:
                        #with open(date.isocalendar() + '.txt', 'a') as f:
                        # Recebo em Json
                        # Converto para Dict
                        new_data = json.loads(data)
                        if ((new_data['place'] is not None or new_data['coordinates'] is not None or new_data['geo'])):    #save tweets with or without geolocation
                            # filtro (Pode ser outra função dentro da minha classe)
                            basic_filter(new_data)
                            #print(len(new_data))
                            # Salva como Json no Disco
                            new_data = (json.dumps(new_data))
                            print(new_data)
                            f.write(new_data)
                            f.write('\n')
                            f.close()
                except BaseException as e:
                    error_handler(e,bound_boxes,track,dir,ckey,csecret,atoken,asecret,initial_colect_time,final_colect_time, time)
                    print("Error on_data : %s" % str(e))
                return True
            else:
                print("Final time:" + tm.asctime(tm.localtime(final_colect_time)))
                return False

        def on_error(self, status):
            print(status)

    boxes = np.hstack(bound_boxes)

    #try:
    #   Configurando a autenticação do meu Streaming
    auth = OAuthHandler(ckey, csecret)
    auth.set_access_token(atoken, asecret)
    print("Streaming...")
    print("Data inicial de coleta: " + tm.asctime(tm.localtime(initial_colect_time)))
    twitterStream = Stream(auth, listener())
    #print("fim da coleta de dados")
    try:
        twitterStream.filter(track=[track], locations=list(boxes), languages=[language])
    except BaseException as err:
        error_handler(err, bound_boxes, track, dir, ckey, csecret, atoken, asecret, initial_colect_time,final_colect_time, time)

