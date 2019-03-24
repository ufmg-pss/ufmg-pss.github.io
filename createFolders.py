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
import os.path


def createFolders (place):

    if not os.path.exists('Data/'):  # create directory
        os.makedirs('Data/')
        print("Created directory : Data/")

    subdirPlace =  'Results' + '/' + place

    subdir = ['Results', subdirPlace, subdirPlace + '/' + 'Temporal', subdirPlace + '/' + 'Spacial',subdirPlace + '/' + 'SpacialTemporal' ]

    subdir.append(subdirPlace + '/' + 'SpacialTemporal' + '/FrequentUser')

    for i in range(len(subdir)):
        if not os.path.exists(subdir[i]):  # create directory
            os.makedirs(subdir[i])
            print("Created directory :" + subdir[i])
