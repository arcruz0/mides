import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy

# Own modules with functions and classes
sys.path.insert(0,'C:\\Alejandro\Research\\MIDES\\Empirical_analysis\\Analysis\\Code\\Functions_and_classes_Python')
import graphsRDD
import graphsDID
reload(graphsRDD)
reload(graphsDID)

### Load data
os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
df=dict()
df['hogaresSIIAS']=pd.read_csv('../Input/MIDES/visitas_hogares_educ_siias.csv')
df['personasSIIAS']=pd.read_csv('../Input/MIDES/visitas_personas_educ_siias.csv')
df['personas']=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
df['hogaresTUS']=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
df['personasSIIAS']=df['personasSIIAS'].merge(df['hogaresTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')
df['personasSIIAS']=df['personasSIIAS'].merge(df['personas'].filter(items=['flowcorrelativeid', 'nrodocumentoSIIAS', 'edad_visita', 'sexo', 'parentesco', 'situacionlaboral', 'nivelmasaltoalcanzado', 'asiste']), left_on=['flowcorrelativeid', 'nrodocumentoSIIAS'], right_on=['flowcorrelativeid', 'nrodocumentoSIIAS'])

### Dictionaries
afamThreshold={'mdeo': 0.22488131, 'int': 0.25648701}
tus1Threshold={'mdeo': 0.62260002, 'int': 0.70024848}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
mesesLags=['3','6','9','12','18','24']

### Generate variables
df['personasSIIAS']['iccMenosThreshold0'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_afam']
df['personasSIIAS']['iccMenosThreshold1'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus']
df['personasSIIAS']['iccMenosThreshold2'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus_dup']

df['personasSIIAS']['menores'] = 1
df['personasSIIAS']['menores'] = df['personasSIIAS']['menores'].mask(df['personasSIIAS']['edad_visita']>18, other=0)
df['personasSIIAS']['menores1215'] = df['personasSIIAS']['menores'].mask(df['personasSIIAS']['edad_visita']>15, other=0)
df['personasSIIAS']['menores1215'] = df['personasSIIAS']['menores1215'].mask(df['personasSIIAS']['edad_visita']<12, other=0)

### Binscatters to see impact on schooling
graphsRDD.fBinscatterSymmetricRDD(df['personasSIIAS'], xBounds=0.2, nBins=20, running='iccMenosThreshold0', 
                 rg='all', ylabel='ylabel is', xlabel='Vulnerability Index-TUS1', 
                 title='Mean number of ocupados', 
                 outcome='masenCEIP24',
                 initialTUS='all',
                 threshold=0,
                 savefig='../Output/algo.pdf',
                 otherConditions='menores')
