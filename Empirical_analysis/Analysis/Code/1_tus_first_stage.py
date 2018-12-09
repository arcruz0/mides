import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
#from ggplot import *
#import binscatter

# Umbral AFAM:              .22488131 (Mdeo) y .25648701 (Interior)
# Umbral TUS:               .62260002 (Mdeo) y .70024848 (Interior)
# Umbral TUS duplicado:     .7568     (Mdeo) y .81       (Interior)

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
df=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')


### Macros
mesesLags = ['12','9','6','3','1']
region = ['mdeo', 'int']
years = [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018]

### Dictionaries
afamThreshold={'mdeo': 0.22488131, 'int': 0.25648701}
tus1Threshold={'mdeo': 0.62260002, 'int': 0.70024848}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
xLinspaceStart={'mdeo': 0.00260002, 'int': 0.00024848}
xLinspaceEnd={'mdeo': 1, 'int': 1}
xLinspaceStep={'mdeo': 0.005, 'int': 0.01}
binsRegion={'mdeo': 200, 'int': 100}
colorsRegion={'mdeo': 'darkslateblue', 'int': 'red'}

### Create additional variables
# Create running variable for One TUS
df['iccMenosThreshold1'] = df['icc'] - df['umbral_nuevo_tus']

## Create number of TUS by household
for ms in mesesLags:
    df['hogarCuantasTusMas' + ms] = df['hogarMascobraTus'+ ms] + df['hogarMastusDoble'+ ms].fillna(value=0)

### First stage para todos
for rg in region:
    for ms in mesesLags:
        xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
        yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
        
        for i in range(binsRegion[rg]-1):
            yBins[i]=df['hogarCuantasTusMas' + ms][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg]) & (df['year']>2012)].mean()
        
        plt.figure()
        plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
        plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
        plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
        plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color=colorsRegion[rg])
        plt.ylabel('Mean # UCT, ' + ms + ' months after visit')
        plt.ylim(-0.05,2.05) 
        plt.xlabel('Vulnerability Index')
        plt.title('Mean number of UCT by binned VI, ' + ms + ' months after visit')
        plt.savefig('../Output/' + rg + '_tus' + ms + '.pdf')
        plt.show()

### First stage para quienes no recibian TUS al momento de la visita   
for rg in region:
    for ms in mesesLags:
        xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
        yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
        
        for i in range(binsRegion[rg]-1):
            yBins[i]=df['hogarCuantasTusMas' + ms][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg])  & (df['hogarZerocobraTus']==0)].mean()
        
        plt.figure()
        plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
        plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
        plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
        plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color=colorsRegion[rg])
        plt.ylabel('Mean # UCT, ' + ms + ' months after visit')
        plt.ylim(-0.05,2.05)           
        plt.xlabel('Vulnerability Index')
        plt.title('Mean number of UCT by binned VI, ' + ms + ' months after visit')
        plt.savefig('../Output/' + rg + '_noTus_tus' + ms + '.pdf')
        plt.show()


### First stage para quienes recibian 1 TUS (no doble) al momento de la visita
for rg in region:
    for ms in mesesLags:
        xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
        yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
        
        for i in range(binsRegion[rg]-1):
            yBins[i]=df['hogarCuantasTusMas' + ms][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg])  & (df['hogarZerocobraTus']==1) & (df['hogarZerotusDoble']==0)].mean()
        
        plt.figure()
        plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
        plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
        plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
        plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='green')
        plt.ylabel('Mean # UCT, ' + ms + ' months after visit')
        plt.ylim(-0.05,2.05)            
        plt.xlabel('Vulnerability Index')
        plt.title('Mean number of UCT by binned VI, ' + ms + ' months after visit')
        plt.savefig('../Output/' + rg + '_si1Tus_tus' + ms + '.pdf')
        plt.show()


### First stage para quienes recibian TUS duplicada al momento de la visita
for rg in region:
    for ms in mesesLags:
        xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
        yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
        
        for i in range(binsRegion[rg]-1):
            yBins[i]=df['hogarCuantasTusMas' + ms][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg])  & (df['hogarZerocobraTus']==1) & (df['hogarZerotusDoble']==1)].mean()
        
        plt.figure()
        plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
        plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
        plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
        plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color=colorsRegion[rg])
        plt.ylabel('Mean # UCT, ' + ms + ' months after visit')
        plt.ylim(-0.05,2.05) 
        plt.xlabel('Vulnerability Index')
        plt.title('Mean number of UCT by binned VI, ' + ms + ' months after visit')
        plt.savefig('../Output/' + rg + '_si2Tus_tus' + ms + '.pdf')
        plt.show()

### First stage by year of visit
for rg in region:     
    for ms in mesesLags:
        for yr in years:
            xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
            yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
            
            for i in range(binsRegion[rg]-1):
                yBins[i]=df['hogarCuantasTusMas' + ms][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg]) & (df['year']== yr)].mean()
            
            plt.figure()
            plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
            plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
            plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
            plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color=colorsRegion[rg])
            plt.ylabel('Mean # UCT, ' + ms + ' months after visit')
            plt.ylim(-0.05,2.05)            
            plt.xlabel('Vulnerability Index')
            plt.title('Mean number of UCT by binned VI, ' + ms + ' months after visit')
            plt.savefig('../Output/' + rg + '_' + str(yr) + '_tus' + ms + '.pdf')
            plt.show()

# Histograma de visitas
for rg in region:
    xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
    yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
        
    for i in range(binsRegion[rg]-1):
        yBins[i]=df[(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==tus1Threshold[rg])]['icc'].size
        
    plt.figure()
    plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold
    plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold
    plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold
    plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2, np.log(yBins[:-1]+1), color=colorsRegion[rg])
    plt.ylabel('Log # Household-visits (2011-2018)')
    plt.xlabel('Vulnerability Index')
    plt.title('Distribution of visits by Vulnerability Index')
    plt.savefig('../Output/' + rg + 'distrib.pdf')
    plt.show()