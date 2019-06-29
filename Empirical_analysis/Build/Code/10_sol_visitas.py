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
os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp') # Set current directory
df=dict()

df['personas']=pd.read_csv('../Output/visitas_personas_vars.csv')
df['hogares']=pd.read_csv('../Output/visitas_hogares_vars.csv')
df['sol_visitas'] = pd.read_csv('../Input/pedido_lihuen/producto_3_enmascarado.csv', encoding='latin_1', sep=';')
df['sol_terminadas_visitas'] = pd.read_csv('../Input/pedido_lihuen/producto_2_enmascarado.csv', encoding='latin_1', sep=';')



## Genero variables en base de solicitud de visitas
df['sol_visitas']['solicito']=1
df['sol_visitas']['yearSolicitud']=df['sol_visitas']['SVisFechaCreacion'].str.slice(0,4).astype(int)
df['sol_visitas']['mesSolicitud']=df['sol_visitas']['SVisFechaCreacion'].str.slice(5,7).astype(int)
df['sol_visitas']['diaSolicitud']=df['sol_visitas']['SVisFechaCreacion'].str.slice(8,10).astype(int)
df['sol_visitas']['periodoSolicitud'] = (df['sol_visitas']['yearSolicitud']-2008)*12 + df['sol_visitas']['mesSolicitud']

# Merge data frames
varsToKepp = ['solicito', 'yearSolicitud', 'mesSolicitud', 'diaSolicitud', 'periodoSolicitud', 'MSViNombre', 'nrodocumento', 
              'flowcorrelativid', 'origen', 'resultado_visita']
              
df['personasConSol'] = df['personas'].merge(df['sol_visitas'].filter(items=varsToKepp), how='left', left_on='nrodocumentoSIIAS', right_on='nrodocumento')
df['hogaresConSol'] = df['hogares'].merge(df['sol_visitas'].filter(items=varsToKepp), how='left', left_on='flowcorrelativeid', right_on='flowcorrelativid')


### Genero variables en bases merged
## Hogares
df['hogaresConSol']['solicitaPostVisita'] = 0
df['hogaresConSol']['solicitaPostVisita'] = df['hogaresConSol']['solicitaPostVisita'].mask((df['hogaresConSol']['solicito']==1) & (df['hogaresConSol']['periodo']<df['hogaresConSol']['periodoSolicitud']), 1)

df['hogaresConSol']['iccMenosThreshold0'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_afam']
df['hogaresConSol']['iccMenosThreshold1'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus']
df['hogaresConSol']['iccMenosThreshold2'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus_dup']

## Personas
df['personasConSol']['solicitaPostVisita'] = 0
df['personasConSol']['solicitaPostVisita'] = df['personasConSol']['solicitaPostVisita'].mask((df['personasConSol']['solicito']==1) & (df['personasConSol']['periodo']<df['personasConSol']['periodoSolicitud']), 1)

df['personasConSol']['iccMenosThreshold0'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_afam']
df['personasConSol']['iccMenosThreshold1'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus']
df['personasConSol']['iccMenosThreshold2'] = df['personasConSol']['icc'] - df['personasConSol']['umbral_nuevo_tus_dup']

## Export bases en csv para luego cargar en Analysis
df['personasConSol'].to_csv('../Output/sol_visitas_personas.csv')