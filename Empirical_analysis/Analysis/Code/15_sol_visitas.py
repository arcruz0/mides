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
sys.path.insert(0,'C:\\Alejandro\Research\\MIDES\\Empirical_analysis\\Analysis\\Code\\Functions_and_classes_Python')
import graphsRDD
import graphsDID
reload(graphsRDD)
reload(graphsDID)

### Load data
os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
df=dict()

df['personasConSol'] = pd.read_csv('../Input/MIDES/sol_visitas_personas.csv')
df['personasTUS']=pd.read_csv('../Input/MIDES/visitas_personas_TUS.csv')
df['personasConSol']=df['personasConSol'].merge(df['personasTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')


## Genero variables

## Relativas al threshold
df['personasConSol']['zero']=0
df['personasConSol']['iccMenosThreshold0'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_afam']
df['personasConSol']['iccMenosThreshold1'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus']
df['personasConSol']['iccMenosThreshold2'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus_dup']
df['personasConSol']['iccMenosThresholdAll'] = np.NaN
df['personasConSol']['iccMenosThresholdAll'] = df['personasConSol']['iccMenosThresholdAll'].mask((abs(df['personasConSol']['iccMenosThreshold0'])<abs(df['personasConSol']['iccMenosThreshold1'])) & (abs(df['personasConSol']['iccMenosThreshold0'])<abs(df['personasConSol']['iccMenosThreshold2'])), df['personasConSol']['iccMenosThreshold0'])
df['personasConSol']['iccMenosThresholdAll'] = df['personasConSol']['iccMenosThresholdAll'].mask((abs(df['personasConSol']['iccMenosThreshold1'])<abs(df['personasConSol']['iccMenosThreshold2'])) & (abs(df['personasConSol']['iccMenosThreshold1'])<abs(df['personasConSol']['iccMenosThreshold0'])), df['personasConSol']['iccMenosThreshold1'])
df['personasConSol']['iccMenosThresholdAll'] = df['personasConSol']['iccMenosThresholdAll'].mask((abs(df['personasConSol']['iccMenosThreshold2'])<abs(df['personasConSol']['iccMenosThreshold1'])) & (abs(df['personasConSol']['iccMenosThreshold2'])<abs(df['personasConSol']['iccMenosThreshold0'])), df['personasConSol']['iccMenosThreshold2'])

## Edad y sexo
df['personasConSol']['adults'] = df['personasConSol']['zero'].mask(df['personasConSol']['edad_visita']>=18, other=1)
df['personasConSol']['adultsJefe'] = df['personasConSol']['zero'].mask((df['personasConSol']['edad_visita']>=18) & (df['personasConSol']['parentesco']==1), other=1)
df['personasConSol']['adultsHombre'] = df['personasConSol']['zero'].mask((df['personasConSol']['edad_visita']>=18) & (df['personasConSol']['sexo']==1), other=1)
df['personasConSol']['adultsMujer'] = df['personasConSol']['zero'].mask((df['personasConSol']['edad_visita']>=18) & (df['personasConSol']['sexo']==2), other=1)

## Relativo a TUS
df['personasConSol']['hogarZeroCuantasTus'] = df['personasConSol']['hogarZerocobraTus'] + df['personasConSol']['hogarZerotusDoble'].fillna(value=0)

## Relativo a year
df['personasConSol']['y2015OMas'] = df['personasConSol']['zero'].mask(df['personasConSol']['year']>=2015, other=1)
df['personasConSol']['y2016OMas'] = df['personasConSol']['zero'].mask(df['personasConSol']['year']>=2016, other=1)
df['personasConSol']['y2017OMas'] = df['personasConSol']['zero'].mask(df['personasConSol']['year']>=2017, other=1)

### Gráficos
graphsRDD.fBinscatterSymmetricRDD(df['personasConSol'], xBounds=0.2, nBins=50, running='iccMenosThreshold1', 
                 rg='all', ylabel='solicitaPostVisita', xlabel='Vulnerability Index-TUS1', 
                 title='solicitaPostVisita', 
                 outcome='solicitaPostVisita',
                 initialTUS='all',
                 threshold=0, size=10,
                 savefig='../Output/solicitaPostVisitaAll.pdf',
                 otherConditions='y2017OMas')

graphsRDD.fBinscatterSymmetricRDD(df['personasConSol'], xBounds=0.2, nBins=50, running='iccMenosThreshold1', 
                 rg='all', ylabel='solicitaPostVisita', xlabel='Vulnerability Index-TUS1', 
                 title='solicitaPostVisita', 
                 outcome='solicitaPostVisita',
                 initialTUS=0,
                 threshold=0, size=10,
                 savefig='../Output/solicitaPostVisita0.pdf',
                 otherConditions='y2017OMas')


graphsRDD.fBinscatterSymmetricRDD(df['personasConSol'], xBounds=0.2, nBins=50, running='iccMenosThreshold1', 
                 rg='all', ylabel='solicitaPostVisita', xlabel='Vulnerability Index-TUS1', 
                 title='solicitaPostVisita', 
                 outcome='solicitaPostVisita',
                 initialTUS=1,
                 threshold=0, size=10,
                 savefig='../Output/solicitaPostVisita1.pdf',
                 otherConditions='y2016OMas')