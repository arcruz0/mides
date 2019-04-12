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
df['hogaresSIIAS']=pd.read_csv('../Input/MIDES/BPS_SIIAS_hogares.csv')
df['personasSIIAS']=pd.read_csv('../Input/MIDES/BPS_SIIAS_personas.csv')
df['personas']=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
df['hogaresTUS']=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
df['personasSIIAS']=df['personasSIIAS'].merge(df['hogaresTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')
df['personasSIIAS']=df['personasSIIAS'].merge(df['personas'].filter(items=['flowcorrelativeid', 'nrodocumentoSIIAS', 'edad_visita', 'sexo', 'parentesco', 'situacionlaboral', 'nivelmasaltoalcanzado']), left_on=['flowcorrelativeid', 'nrodocumentoSIIAS'], right_on=['flowcorrelativeid', 'nrodocumentoSIIAS'])

### Dictionaries
afamThreshold={'mdeo': 0.22488131, 'int': 0.25648701}
tus1Threshold={'mdeo': 0.62260002, 'int': 0.70024848}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
mesesLags=['3','6','9','12','18','24']

### Generate variables
df['personasSIIAS']['iccMenosThreshold0'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_afam']
df['personasSIIAS']['iccMenosThreshold1'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus']
df['personasSIIAS']['iccMenosThreshold2'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus_dup']

df['personasSIIAS']['adultos'] = 1
df['personasSIIAS']['all0'] = 0
df['personasSIIAS']['adultos'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['edad_visita']<18, other=0)
df['personasSIIAS']['adultosHombre'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['sexo']==2, other=0)
df['personasSIIAS']['adultosMujer'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['sexo']==1, other=0)
df['personasSIIAS']['adultosJefe'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['parentesco']!=1, other=0)
df['personasSIIAS']['adultosJefeHombre'] = df['personasSIIAS']['adultosJefe'].mask(df['personasSIIAS']['sexo']==2, other=0)
df['personasSIIAS']['adultosJefeMujer'] = df['personasSIIAS']['adultosJefe'].mask(df['personasSIIAS']['sexo']==1, other=0)
df['personasSIIAS']['adultosZeroOcupados'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['zeroocupadoSIIAS']==0, other=0)

df['personasSIIAS']['adultos1864Mujer'] = df['personasSIIAS']['all0'].mask((df['personasSIIAS']['sexo']==2) & (df['personasSIIAS']['edad_visita']>=18) & (df['personasSIIAS']['edad_visita']<=64) , other=1)


df['personasSIIAS']['adultos2060'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['edad_visita']<20, other=0)
df['personasSIIAS']['adultos2060'] = df['personasSIIAS']['adultos2060'].mask(df['personasSIIAS']['edad_visita']>60, other=0)
df['personasSIIAS']['adultos2060Hombre'] = df['personasSIIAS']['adultos2060'].mask(df['personasSIIAS']['sexo']==2, other=0)

df['personasSIIAS']['adultos3060'] = df['personasSIIAS']['adultos'].mask(df['personasSIIAS']['edad_visita']<30, other=0)
df['personasSIIAS']['adultos3060'] = df['personasSIIAS']['adultos3060'].mask(df['personasSIIAS']['edad_visita']>60, other=0)
df['personasSIIAS']['adultos3060Hombre'] = df['personasSIIAS']['adultos3060'].mask(df['personasSIIAS']['sexo']==2, other=0)

df['personasSIIAS']['adultosICCTUS1LessInitial1'] = 0
df['personasSIIAS']['adultosICCTUS1LessInitial1'] = df['personasSIIAS']['adultosICCTUS1LessInitial1'].mask((df['personasSIIAS']['edad_visita']>18) & (df['personasSIIAS']['iccMenosThreshold1']<0) & (df['personasSIIAS']['hogarZeroCuantasTus']==0),1)
df['personasSIIAS']['adultosICCTUS1MoreInitial1'] = 0
df['personasSIIAS']['adultosICCTUS1MoreInitial1'] = df['personasSIIAS']['adultosICCTUS1LessInitial1'].mask((df['personasSIIAS']['edad_visita']>18) & (df['personasSIIAS']['iccMenosThreshold1']>=0) & (df['personasSIIAS']['hogarZeroCuantasTus']==0),1)

df['personasSIIAS']['adultosMujeresICCTUS1LessInitial1'] = 0
df['personasSIIAS']['adultosMujeresICCTUS1LessInitial1'] = df['personasSIIAS']['adultosICCTUS1LessInitial1'].mask((df['personasSIIAS']['edad_visita']>18) & (df['personasSIIAS']['iccMenosThreshold1']<0) & (df['personasSIIAS']['hogarZeroCuantasTus']==0) & (df['personasSIIAS']['sexo']==2),1)
df['personasSIIAS']['adultosMujeresICCTUS1MoreInitial1'] = 0
df['personasSIIAS']['adultosMujeresICCTUS1MoreInitial1'] = df['personasSIIAS']['adultosICCTUS1LessInitial1'].mask((df['personasSIIAS']['edad_visita']>18) & (df['personasSIIAS']['iccMenosThreshold1']>=0) & (df['personasSIIAS']['hogarZeroCuantasTus']==0) & (df['personasSIIAS']['sexo']==2),1)


# Create number of TUS by household
for ms in mesesLags:
    df['personasSIIAS']['hogarCuantasTusMas' + ms] = df['personasSIIAS']['hogarMascobraTus'+ ms] + df['personasSIIAS']['hogarMastusDoble'+ ms].fillna(value=0)

df['personasSIIAS']['hogarZeroCuantasTus'] = df['personasSIIAS']['hogarZerocobraTus'] + df['personasSIIAS']['hogarZerotusDoble'].fillna(value=0)

##### RDD #####
### Binscatters to see impact on formal employment
graphsRDD.fBinscatterSymmetricRDD(df['personasSIIAS'], xBounds=0.2, nBins=30, running='iccMenosThreshold0', 
                 rg='all', ylabel='ylabel is', xlabel='Vulnerability Index-TUS1', 
                 title='Mean number of ocupados', 
                 outcome='masocupadoSIIAS24',
                 initialTUS='all',
                 threshold=0,
                 savefig='../Output/algo.pdf',
                 otherConditions='adultos1864Mujer')


##### DID #####
graphsDID.fBinscatterEventDif2Groups(df['personasSIIAS'], menosPeriods=12, masPeriods=24, 
                 group1='adultosMujeresICCTUS1LessInitial1', group2='adultosMujeresICCTUS1MoreInitial1', ylabel='ylabel is', xlabel='Months before/after the visit', 
                 title='Mean Y before/after visit', 
                 outcome='ocupadoSIIAS',
                 savefig='../Output/algo.pdf')

graphsDID.fBinscatterEvent2Groups(df['personasSIIAS'], menosPeriods=12, masPeriods=24, 
                 group1='adultosMujeresICCTUS1LessInitial1', group2='adultosMujeresICCTUS1MoreInitial1', ylabel='ylabel is', xlabel='Months before/after the visit', 
                 title='Mean Y before/after visit', 
                 outcome='ocupadoSIIAS',
                 savefig='../Output/algo.pdf')

xAxis = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ,12 ,13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
yGroup1 = np.ones(len(xAxis))
yGroup2 = np.ones(len(xAxis)) 

for i in [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]:
    yGroup1[12 - i] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']>=0) & (df['personasSIIAS']['adultos']==1)]['menosocupadoSIIAS' + str(i)].mean()
    yGroup2[12 - i] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']<0) & (df['personasSIIAS']['adultos']==1)]['menosocupadoSIIAS' + str(i)].mean()

yGroup1[12] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']>=0) & (df['personasSIIAS']['adultos']==1)]['zeroocupadoSIIAS'].mean()
yGroup2[12] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']<0) & (df['personasSIIAS']['adultos']==1)]['zeroocupadoSIIAS'].mean()


for i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]:
    yGroup1[12 + i] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']>=0) & (df['personasSIIAS']['adultos']==1)]['masocupadoSIIAS' + str(i)].mean()
    yGroup2[12 + i] = df['personasSIIAS'][(df['personasSIIAS']['iccMenosThreshold1']<0) & (df['personasSIIAS']['adultos']==1)]['masocupadoSIIAS' + str(i)].mean()

plt.figure()    
plt.scatter(xAxis, yGroup1, color='red')
plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.ylabel('Perc. formally employed')
plt.xlabel('Months before/after the visit')
plt.title('Perc. formally employed')
plt.savefig('../Output/FormallyEmployed.pdf')
plt.show()