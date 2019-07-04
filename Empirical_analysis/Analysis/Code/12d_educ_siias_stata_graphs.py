import os, shutil, sys
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
from imp import reload

# Own modules with functions and classes
sys.path.insert(0,'C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Code/Functions_and_classes_Python')
sys.path.insert(0,'/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Analysis/Code/Functions_and_classes_Python')
sys.path.insert(0,'/home/andres/gdrive/mides/Empirical_analysis/Analysis/Code/Functions_and_classes_Python')
import graphsRDD
#reload(graphsRDD)

### Set working directory
try:
    os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
    print('Script corrido en computadora de Alejandro')
except: pass
try:
    os.chdir('/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Analysis/Temp') # Set current directory
    print('Script corrido en computadora de Lihuen')
except: pass
try:
    os.chdir('/home/andres/gdrive/mides/Empirical_analysis/Analysis/Temp') # Set current directory
    print('Script corrido en computadora de Andres')
except: pass

### Load results from Stata
outcomeVars = ['EstudiaCEIPCES', 'AnosAtrasados']
specs =[1,2,3,4]
lagsN=[6,12]
leadsN = [36, 48]
resultsStata = dict()
for var in outcomeVars:
    resultsStata[var]=dict()
for var in outcomeVars:
    for spec in specs:
        resultsStata[var][spec] =dict()
        for lagN in lagsN:
            resultsStata[var][spec][lagN] =dict()
            for leadN in leadsN:
                resultsStata[var][spec][lagN][leadN]=pd.read_csv('DIDla' + str(lagN) + 'le' + str(leadN) + var + str(spec) + '.csv', sep='\t')

### Define colors and styles for different specifications
colorSpecs = dict()
colorSpecs[1] = ['red', 'grey']
colorSpecs[2] = ['green', 'grey']
colorSpecs[3] = colorSpecs[2]
colorSpecs[4] = colorSpecs[1]

### Create confidence intervals
for var in outcomeVars:
    for spec in specs:
        for lagN in lagsN:
            for leadN in leadsN:
                resultsStata[var][spec][lagN][leadN]['lci5'] = resultsStata[var][spec][lagN][leadN]['Beta'] - 1.96 * resultsStata[var][spec][lagN][leadN]['SE']
                resultsStata[var][spec][lagN][leadN]['uci5'] = resultsStata[var][spec][lagN][leadN]['Beta'] + 1.96 * resultsStata[var][spec][lagN][leadN]['SE']
                resultsStata[var][spec][lagN][leadN]['lci10'] = resultsStata[var][spec][lagN][leadN]['Beta'] - 1.645 * resultsStata[var][spec][lagN][leadN]['SE']
                resultsStata[var][spec][lagN][leadN]['uci10'] = resultsStata[var][spec][lagN][leadN]['Beta'] + 1.645 * resultsStata[var][spec][lagN][leadN]['SE']

  
### DID Figures
for var in outcomeVars:
    for spec in specs:
        for lagN in lagsN:
            for leadN in leadsN:
                plt.figure()    
                plt.scatter(list(range(-lagN +1,1))+list(range(1,leadN +1)), resultsStata[var][spec][lagN][leadN].iloc[::-1]['Beta'], color=colorSpecs[spec][0])
                plt.plot(list(range(-lagN +1,1))+list(range(1,leadN +1)), resultsStata[var][spec][lagN][leadN].iloc[::-1]['lci5'], linestyle='dashed', color=colorSpecs[spec][1])
                plt.plot(list(range(-lagN +1,1))+list(range(1,leadN +1)), resultsStata[var][spec][lagN][leadN].iloc[::-1]['uci5'], linestyle='dashed', color=colorSpecs[spec][1])
                #plt.scatter(xAxis, yGroup2, color='grey')
                plt.axvline(x=0, color='orange', linestyle='dashed')
                plt.axhline(y=0, color='black')
                plt.ylabel('DID coefficient')
                plt.xlabel('Months before/after visit')
                plt.title('DID leads (' + str(leadN) +') and lags (' + str(lagN) + ') estimates')
                plt.savefig('DIDla' + str(lagN) + 'le' + str(leadN) + var + str(spec) + '.pdf')
                plt.show()
                
        
