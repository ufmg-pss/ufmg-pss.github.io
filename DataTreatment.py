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
import os
from tweepy.streaming import StreamListener, json
import datetime
import json
import os.path
import pandas as pd
import re
from googletrans import Translator
from shapely.geometry import Point # Point class
from shapely.geometry import shape


# CONSTANTES

PAR_LIST = ['text','id_str', 'lat','lon', 'created_at'] #parametres that will be user to save in CSV format
SAVE_PAR = ['text','id_str', 'lat','lon', 'created_at', 'screen_name']

# =======================================================================================================================
#   FUNCTIONS
# =======================================================================================================================

def fix_bounding_box(df,bound_boxes):    #Verifica se os tweets estão dentro do bounding box especificado na coleta
    #Seleciono os dataframes que estão dentro do meu bounding box
    df = df[df['lon'] > bound_boxes[0]]
    df = df[df['lon'] < bound_boxes[2]]
    df = df[df['lat'] > bound_boxes[1]]
    df = df[df['lat'] < bound_boxes[3]]
    return df

# PREPARAÇÃO DE DADOS
#Função para tratar data-hora
def to_datetime_format(tweetString):   #Converte o campo created_at de string para formato datetime
    Data = datetime.datetime.strptime(tweetString, '%a %b %d %H:%M:%S %z %Y')
    #Modulo para encontrar a hora local de determinada região
    return Data

def text_filter(texto): #Responsável por remover os emojis do texto
    RE_EMOJI = re.compile('[\U00010000-\U0010ffff]', flags=re.UNICODE)
    novo_texto = RE_EMOJI.sub(r'', texto)
    return novo_texto

def translate(texto,lang):   #Traduz o texto da lingua especificada para o inglês
    #LIMITE PERMITIDO PELA API É DE 15 MIL CARACTERES
    texto_filtrado = text_filter(texto)
    gs = Translator()

    if (lang == 'en'):
        return texto_filtrado
    else:
        return (gs.translate((texto_filtrado)).text)

#função para traduzir para o Inglês
def translate_for_english(lista, lang):    #Chama a função para tradução
    #print(row['text'])
    translated = translate(lista[0], lang)
    return translated

def convert_for_dictionary(ArquivoJSON):
    data = ArquivoJSON.readlines()
    new_data = []
    #Lista dentro de uma lista
    for row in data:
        new_data.append(json.loads(row))
    return new_data

def verify_period(period,row):
    if (to_datetime_format(row['created_at']) > period [0] and to_datetime_format(row['created_at']) < period[1]):
           return True
    else:
        return False

#Ele drecebe o pontoe verifica, dentro do shapefile, o local onde está o incident
def verificaLocal(row, all_shapes, all_records, bound_boxes):

    if ((row['coordinates'] is not None) or (row['geo'] is not None)):
        if(row['coordinates'] is not None):
            point = (row['coordinates']['coordinates'][0],row['coordinates']['coordinates'][1])
        else:
            point = (row['geo']['coordinates'][1], row['geo']['coordinates'][0])

        for i in range(len(all_shapes)):
            boundary = all_shapes[i]
            if Point(point).within(shape(boundary)):    #Verifica se a variável ponto esta dentro do shape
                #cidade = str(all_records[i][3])
                if (all_records[i][1] == 'Manhattan'):   #verifica se esta dentro de Manhattan
                    region_label = 'Manhattan'
                    print(region_label)
                    return region_label
                else:
                    return None
        else:
            return None
    else:
        return None

def contains_fields(linha, ListaKeys):
    for key in ListaKeys:
        if (key not in linha or linha[key]==None):
            return 0
    return 1

def coordinates_2_latlon(row):
    if row ['coordinates'] is not None:
        row['lat'] = row['coordinates']['coordinates'][1]
        row['lon'] = row['coordinates']['coordinates'][0]
    else:
        row['lat'] = row['geo']['coordinates'][0]
        row['lon'] = row['geo']['coordinates'][1]

#Input: Campos de Desejo
#Output : Dicionário com campos selecionas
#Seleciona Campos: text, id_tweet,lat,lon,label(cidade_pais)
def select_fields(row,tranlate):
    return_list = []
    coordinates_2_latlon(row)
    lang = row['lang']
    for key in PAR_LIST:    #para os campos que estao contidos na lista, eu adiciono
        return_list.append(row[key])

    return_list.append(row['user']['screen_name'])

    return_list[4] = to_datetime_format(return_list[4])  # convertendo para o padrao  OBS: PODE MUDAR DEPENDENDO DA ENTRADA DO USUARIO

    if tranlate:
        return_list[0] = translate_for_english(return_list, lang)

    return return_list


def select_tweets_inside_bounding_box(dir, bound_box):
    header = 0;
    for dirName, subdirList, fileList in os.walk(dir, topdown=True):
        print('Found directory: %s' % dirName)
        for file in fileList:
            if file.endswith(".csv"):
                df = pd.read_csv(dirName + file, parse_dates=['created_at'],dtype={'incidentID': str})
                print('Tamanho inicial e:' + str(len(df)))
                print('Open: '  + dirName + file  )
                df_fixed = fix_bounding_box(df, bound_box)
                #####################################
                #Funcao para verificar o shapefile
                #####################################
                print('Tamanho final e: ' + str(len(df_fixed)))
                df_fixed.to_csv('Data/tweets_gerados.csv', index= False)

def join_csv_files_filtering_bounding_box(FOLDER,bound_box,RemoveOriginal):
    dirName = list(os.walk(FOLDER))[0][0]
    fileList = list(os.walk(FOLDER))[0][2]
    df_final = pd.DataFrame(columns=SAVE_PAR)
    print('Found directory: %s' % dirName)
    for fname in fileList:
        if (fname.endswith(".csv")):   #checking .csv

            df_fixed = fix_bounding_box(pd.read_csv(dirName + fname), bound_box)
            df_fixed = df_fixed[SAVE_PAR]
            df_final = [df_final, df_fixed]
            df_final = pd.concat(df_final)#, sort=False)    #concatenated
            if(RemoveOriginal == True):
                os.remove(dirName + fname)
    df_final.to_csv(dirName + "tweets_gerados.csv", sep = ",",index=False)    #esta salvando errado

print("Great, we joined the csv files into a one csv")

def delete_csv_file (file_path):
    for dirName, subdirList, fileList in os.walk(file_path, topdown=True):
        dirName = list(os.walk(file_path))[0][0]
        fileList = list(os.walk(file_path))[0][2]
        for fname in fileList:
            if fname.endswith(".csv"):
                print('\t%s' %fname + " was deleted...")
                os.remove(file_path + fname)


def json_2_csv(file_path, bound_boxes,translate= None, period = None,shape_local=None):   #Conveto todo os arquivos de tweeets pra cvs
    delete_csv_file(file_path) #delete the csv file if it exist
    for dirName, subdirList, fileList in os.walk(file_path, topdown=True):
        print('Found directory: %s' % dirName)
        for fname in fileList:
            if fname.endswith(".txt"):
                print('\t%s' % fname)
                with open(dirName +fname,'r') as file:
                    print('Creating a csv file...')

                    camp_list = []

                    for line in file:
                        row = json.loads(line)
                        #lang = row['lang']
                        if("geo" in row):
                            if (row['geo'] != None):   #elimino tweets sem geolocalizacao
                                camp_list.append(select_fields(row,False))
                        elif("coordinates" in row):
                            if (row['coordinates'] != None):   #elimino tweets sem geolocalizacao
                                camp_list.append(select_fields(row,False))

                    file_name = dirName + str(fname).replace(".txt", ".csv")
                    df_Twitter = pd.DataFrame(camp_list, columns=SAVE_PAR)

                    df_Twitter.to_csv(file_name, sep=",")

                    print("Great, we converted the tweet data to csv file")
