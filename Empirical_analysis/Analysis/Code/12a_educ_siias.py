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

### Load data
try:
    directory = 'C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp'
    os.chdir(directory) # Set current directory
    print('Script corrido en computadora de Alejandro')
except: pass
try:
    directory = '/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Analysis/Temp'
    os.chdir(directory) # Set current directory
    print('Script corrido en computadora de Lihuen')
except: pass
try:
    directory = '/home/andres/gdrive/mides/Empirical_analysis/Analysis/Temp'
    os.chdir(directory) # Set current directory
    print('Script corrido en computadora de Andres')
except: pass

df=dict()
df['hogaresEducSIIAS']=pd.read_csv('../Input/MIDES/visitas_hogares_educ_siias.csv')
df['personasEducSIIAS']=pd.read_csv('../Input/MIDES/visitas_personas_educ_siias.csv')
df['personas']=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
df['hogaresTUS']=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
df['personasEducSIIAS']=df['personasEducSIIAS'].merge(df['hogaresTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')
df['personasEducSIIAS']=df['personasEducSIIAS'].merge(df['personas'].filter(items=['flowcorrelativeid', 'nrodocumentoSIIAS', 'edad_visita', 'sexo', 'parentesco', 'situacionlaboral', 'nivelmasaltoalcanzado', 'asiste', 'fechanacimiento']), left_on=['flowcorrelativeid', 'nrodocumentoSIIAS'], right_on=['flowcorrelativeid', 'nrodocumentoSIIAS'])
periodoMesYear = pd.read_csv('../Input/periodo_mes_year.csv')

### Dictionaries
afamThreshold={'mdeo': 0.22488131, 'int': 0.25648701}
tus1Threshold={'mdeo': 0.62260002, 'int': 0.70024848}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
mesesLags=['3','6','9','12','18','24']

### Variables over which to loop when creating binscatters
initialTUS = ['all', 0, 1, 2]
outcomes = ['zeroEstudiaCEIPCES', 'masEstudiaCEIPCES18','masEstudiaCEIPCES24', 'masEstudiaCEIPCES36', 'masEstudiaCEIPCES48', 'masEnAnosEducCorrectos18', 'masEnAnosEducCorrectos24', 'masEnAnosEducCorrectos36', 'masEnAnosEducCorrectos48']
vOtherConditions = ['menores','menores12','menores1215','menores12zeroEstudiaCEIPCES', 'menores15zeroEstudiaCEIPCES']


### Generate variables

## Relativas al threshold
df['personasEducSIIAS']['zero']=0
df['personasEducSIIAS']['iccMenosThreshold0'] = df['personasEducSIIAS']['icc'] - df['personasEducSIIAS']['umbral_afam']
df['personasEducSIIAS']['iccMenosThreshold1'] = df['personasEducSIIAS']['icc'] - df['personasEducSIIAS']['umbral_nuevo_tus']
df['personasEducSIIAS']['iccMenosThreshold2'] = df['personasEducSIIAS']['icc'] - df['personasEducSIIAS']['umbral_nuevo_tus_dup']
df['personasEducSIIAS']['iccMenosThresholdAll'] = np.NaN
df['personasEducSIIAS']['iccMenosThresholdAll'] = df['personasEducSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasEducSIIAS']['iccMenosThreshold0'])<abs(df['personasEducSIIAS']['iccMenosThreshold1'])) & (abs(df['personasEducSIIAS']['iccMenosThreshold0'])<abs(df['personasEducSIIAS']['iccMenosThreshold2'])), df['personasEducSIIAS']['iccMenosThreshold0'])
df['personasEducSIIAS']['iccMenosThresholdAll'] = df['personasEducSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasEducSIIAS']['iccMenosThreshold1'])<abs(df['personasEducSIIAS']['iccMenosThreshold2'])) & (abs(df['personasEducSIIAS']['iccMenosThreshold1'])<abs(df['personasEducSIIAS']['iccMenosThreshold0'])), df['personasEducSIIAS']['iccMenosThreshold1'])
df['personasEducSIIAS']['iccMenosThresholdAll'] = df['personasEducSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasEducSIIAS']['iccMenosThreshold2'])<abs(df['personasEducSIIAS']['iccMenosThreshold1'])) & (abs(df['personasEducSIIAS']['iccMenosThreshold2'])<abs(df['personasEducSIIAS']['iccMenosThreshold0'])), df['personasEducSIIAS']['iccMenosThreshold2'])
df['personasEducSIIAS']['lessICC1'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['iccMenosThreshold1']<0, 1)
df['personasEducSIIAS']['moreICC1'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['iccMenosThreshold1']>0, 1)
df['personasEducSIIAS']['lessICC2'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['iccMenosThreshold2']<0, 1)
df['personasEducSIIAS']['moreICC2'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['iccMenosThreshold2']>0, 1)


## Edad y sexo
df['personasEducSIIAS']['menores'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['edad_visita']<=17, other=1)
df['personasEducSIIAS']['menores12'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['edad_visita']<=12, other=1)
df['personasEducSIIAS']['menores15'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['edad_visita']<=15, other=1)

df['personasEducSIIAS']['menores1215'] = df['personasEducSIIAS']['zero'].mask((df['personasEducSIIAS']['edad_visita']<=15) & (df['personasEducSIIAS']['edad_visita']>=12) , other=1)
df['personasEducSIIAS']['menores1317'] = df['personasEducSIIAS']['zero'].mask((df['personasEducSIIAS']['edad_visita']<=17) & (df['personasEducSIIAS']['edad_visita']>=13) , other=1)
df['personasEducSIIAS']['menores1115'] = df['personasEducSIIAS']['zero'].mask((df['personasEducSIIAS']['edad_visita']<=15) & (df['personasEducSIIAS']['edad_visita']>=11) , other=1)

# Relativas al TUS
df['personasEducSIIAS']['hogarZeroCuantasTus'] = df['personasEducSIIAS']['hogarZerocobraTus'] + df['personasEducSIIAS']['hogarZerotusDoble'].fillna(value=0)
df['personasEducSIIAS']['hogarNoCobraTUSEn0'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['hogarZeroCuantasTus']==0, 1)
df['personasEducSIIAS']['hogarCobra1TUSEn0'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['hogarZeroCuantasTus']==1, 1)
df['personasEducSIIAS']['hogarCobra2TUSEn0'] = df['personasEducSIIAS']['zero'].mask(df['personasEducSIIAS']['hogarZeroCuantasTus']==2, 1)

## Asistencia a la educacion

## Número de años de educación completos que individuo debería tener acorde a su edad y momento del año (momento de visita, +- meses luego de visita)
# Primaria: 1er año - 6/7 años, 2do - 7/8, 3ro - 8/9, 4to - 9/10, 5to - 10/11, 6to - 11/12
# Secundaria Ciclo Básico: 1er - 12/13, 2do - 13/14, 3ro - 14/15
# Secundaria Bachillerato: 4to - 15/16, 5to - 16/17, 6to - 17/18

## Genero variable que indica el year en el momento +1 de la visita, +2, etc
for i in range(1,49):
    df['personasEducSIIAS']['periodoChanged'] = df['personasEducSIIAS']['periodo'] + i
    df['personasEducSIIAS']['mas' + 'year' + str(i)] = df['personasEducSIIAS'].filter(items=['periodoChanged', 'mes']).merge(periodoMesYear.filter(items=['periodo', 'year']), left_on='periodoChanged', right_on='periodo', how='left')['year'].astype('Int64')

for i in range(1,25):
    df['personasEducSIIAS']['periodoChanged'] = df['personasEducSIIAS']['periodo'] - i
    df['personasEducSIIAS']['menos' + 'year' + str(i)] = df['personasEducSIIAS'].filter(items=['periodoChanged', 'mes']).merge(periodoMesYear.filter(items=['periodo', 'year']), left_on='periodoChanged', right_on='periodo', how='left')['year'].astype('Int64')

# Calculo edad del individuo al 30 de abril del año en el año de la visita. Considero que si individuo tiene por ej 8 años a esa fecha, entonces debería estar en 3ro de escuela (y cumpliría 9 años durante el año lectivo) 
df['personasEducSIIAS']['yearNacimiento'] = df['personasEducSIIAS']['fechanacimiento'].astype(str).str.slice(stop=4).astype(int)
df['personasEducSIIAS']['mesNacimiento'] = df['personasEducSIIAS']['fechanacimiento'].astype(str).str.slice(start=4,stop=6).astype(int)
  
## Edad al 30 de abril en año de visita y en otros años 
df['personasEducSIIAS']['zeroEdad30Abril'] = np.NaN
df['personasEducSIIAS']['zeroEdad30Abril']=df['personasEducSIIAS']['zeroEdad30Abril'].mask((df['personasEducSIIAS']['mesNacimiento']>=5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['year'] - df['personasEducSIIAS']['yearNacimiento'] - 1)
df['personasEducSIIAS']['zeroEdad30Abril']=df['personasEducSIIAS']['zeroEdad30Abril'].mask((df['personasEducSIIAS']['mesNacimiento']<5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['year'] - df['personasEducSIIAS']['yearNacimiento'])

# MAS
for i in range(1,49):
    df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(i)] = np.NaN
    df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(i)]=df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(i)].mask((df['personasEducSIIAS']['mesNacimiento']>=5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['mas' + 'year' + str(i)] - df['personasEducSIIAS']['yearNacimiento'] - 1)
    df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(i)]=df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(i)].mask((df['personasEducSIIAS']['mesNacimiento']<5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['mas' + 'year' + str(i)] - df['personasEducSIIAS']['yearNacimiento'])

# MENOS
for i in range(1,25):
    df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(i)] = np.NaN
    df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(i)]=df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(i)].mask((df['personasEducSIIAS']['mesNacimiento']>=5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['menos' + 'year' + str(i)] - df['personasEducSIIAS']['yearNacimiento'] - 1)
    df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(i)]=df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(i)].mask((df['personasEducSIIAS']['mesNacimiento']<5) & (df['personasEducSIIAS']['mesNacimiento'].isna()==False), df['personasEducSIIAS']['menos' + 'year' + str(i)] - df['personasEducSIIAS']['yearNacimiento'])
 
# Calculo año en el que debería estar cursando el individuo en cada período o que debería tener completos

## Periodo 0
df['personasEducSIIAS']['zeroEnAnosEducDeberia'] = np.NaN
for i in [1,2,3,4,5,6,7,8,9,10,11,12]:
    df['personasEducSIIAS']['zeroEnAnosEducDeberia'] = df['personasEducSIIAS']['zeroEnAnosEducDeberia'].mask(df['personasEducSIIAS']['zeroEdad30Abril']==5+i, i)  # Debe estar en 1ro de primaria en el momento de la visita si en el año de la visita tiene 6 años al 30 de abril

df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'] = np.NaN
for i in [1,2,3,4,5,6]:
    df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'] = df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'].mask((df['personasEducSIIAS']['zeroenCEIP']==1) & ((df['personasEducSIIAS']['zerocodGradoEscolar']==i) | (df['personasEducSIIAS']['zerocodGradoEscolar']==float(str(1 + i/10)))), i)

df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'] = df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'].mask((df['personasEducSIIAS']['zeroenCEIP']==1) & (df['personasEducSIIAS']['zerocodGradoEscolar']==2.1), 7)
df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'] = df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'].mask((df['personasEducSIIAS']['zeroenCEIP']==1) & (df['personasEducSIIAS']['zerocodGradoEscolar']==2.2), 8)
df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'] = df['personasEducSIIAS']['zeroEnAnosEducEstaCEIP'].mask((df['personasEducSIIAS']['zeroenCEIP']==1) & (df['personasEducSIIAS']['zerocodGradoEscolar']==2.3), 9) 

df['personasEducSIIAS']['zeroEnAnosEducEstaCES'] = np.NaN
for i in [1,2,3,4,5,6]:
    df['personasEducSIIAS']['zeroEnAnosEducEstaCES'] = df['personasEducSIIAS']['zeroEnAnosEducEstaCES'].mask((df['personasEducSIIAS']['zeroenCES']==1) & (df['personasEducSIIAS']['zerogrado_liceo']==i), 6+i)

df['personasEducSIIAS']['zeroEnAnosEducEsta'] = df['personasEducSIIAS'].filter(items=['zeroEnAnosEducEstaCEIP','zeroEnAnosEducEstaCES']).max(axis=1)

# Genero variable dummy si esta en año correcto o superior y otra dummy si estudia
df['personasEducSIIAS']['zeroEnAnosEducCorrectos'] = 0
df['personasEducSIIAS']['zeroEnAnosEducCorrectos'] = df['personasEducSIIAS']['zeroEnAnosEducCorrectos'].mask(df['personasEducSIIAS']['zeroEnAnosEducEsta']>=df['personasEducSIIAS']['zeroEnAnosEducDeberia'], 1)

df['personasEducSIIAS']['zeroEstudiaCEIPCES'] = 0
df['personasEducSIIAS']['zeroEstudiaCEIPCES'] = df['personasEducSIIAS']['zeroEstudiaCEIPCES'].mask(((df['personasEducSIIAS']['zeroenCEIP']==1) |  (df['personasEducSIIAS']['zeroenCES']==1)), 1) 

## Periodo MÁS
for j in range (1,49):
    df['personasEducSIIAS']['mas' + 'EnAnosEducDeberia' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6,7,8,9,10,11,12]:
        df['personasEducSIIAS']['mas' + 'EnAnosEducDeberia' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducDeberia' + str(j)].mask(df['personasEducSIIAS']['mas' + 'Edad30Abril' + str(j)]==5+i, i)  # Debe estar en 1ro de primaria en el momento de la visita si en el año de la visita tiene 6 años al 30 de abril

    df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6]:
        df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['mas' + 'enCEIP' + str(j)]==1) & ((df['personasEducSIIAS']['mas' + 'codGradoEscolar' + str(j)]==i) | (df['personasEducSIIAS']['mas' + 'codGradoEscolar' + str(j)]==float(str(1 + i/10)))), i)

    df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['mas' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['mas' + 'codGradoEscolar' + str(j)]==2.1), 7)
    df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['mas' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['mas' + 'codGradoEscolar' + str(j)]==2.2), 8)
    df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['mas' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['mas' + 'codGradoEscolar' + str(j)]==2.3), 9) 

    df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCES' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6]:
        df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCES' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducEstaCES' + str(j)].mask((df['personasEducSIIAS']['mas' + 'enCES' + str(j)]==1) & (df['personasEducSIIAS']['mas' + 'grado_liceo' + str(j)]==i), 6+i)

    df['personasEducSIIAS']['mas' + 'EnAnosEducEsta' + str(j)] = df['personasEducSIIAS'].filter(items=['mas' + 'EnAnosEducEstaCEIP' + str(j),'mas' + 'EnAnosEducEstaCES' + str(j)]).max(axis=1)

    df['personasEducSIIAS']['mas' + 'EnAnosEducCorrectos' + str(j)] = 0
    df['personasEducSIIAS']['mas' + 'EnAnosEducCorrectos' + str(j)] = df['personasEducSIIAS']['mas' + 'EnAnosEducCorrectos' + str(j)].mask(df['personasEducSIIAS']['mas' + 'EnAnosEducEsta' + str(j)]>=df['personasEducSIIAS']['mas' + 'EnAnosEducDeberia' + str(j)], 1)
    df['personasEducSIIAS']['mas' + 'EstudiaCEIPCES' + str(j)] = 0
    df['personasEducSIIAS']['mas' + 'EstudiaCEIPCES' + str(j)] = df['personasEducSIIAS']['mas' + 'EstudiaCEIPCES' + str(j)].mask(((df['personasEducSIIAS']['mas' + 'enCEIP' + str(j)]==1) |  (df['personasEducSIIAS']['mas' + 'enCES' + str(j)]==1)), 1) 

## Período MENOS
for j in range (1,25):
    df['personasEducSIIAS']['menos' + 'EnAnosEducDeberia' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6,7,8,9,10,11,12]:
        df['personasEducSIIAS']['menos' + 'EnAnosEducDeberia' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducDeberia' + str(j)].mask(df['personasEducSIIAS']['menos' + 'Edad30Abril' + str(j)]==5+i, i)  # Debe estar en 1ro de primaria en el momento de la visita si en el año de la visita tiene 6 años al 30 de abril

for j in range (1,25):
    df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6]:
        df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['menos' + 'enCEIP' + str(j)]==1) & ((df['personasEducSIIAS']['menos' + 'codGradoEscolar' + str(j)]==i) | (df['personasEducSIIAS']['menos' + 'codGradoEscolar' + str(j)]==float(str(1 + i/10)))), i)

    df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['menos' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['menos' + 'codGradoEscolar' + str(j)]==2.1), 7)
    df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['menos' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['menos' + 'codGradoEscolar' + str(j)]==2.2), 8)
    df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCEIP' + str(j)].mask((df['personasEducSIIAS']['menos' + 'enCEIP' + str(j)]==1) & (df['personasEducSIIAS']['menos' + 'codGradoEscolar' + str(j)]==2.3), 9) 

for j in range (1,25):
    df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCES' + str(j)] = np.NaN
    for i in [1,2,3,4,5,6]:
        df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCES' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducEstaCES' + str(j)].mask((df['personasEducSIIAS']['menos' + 'enCES' + str(j)]==1) & (df['personasEducSIIAS']['menos' + 'grado_liceo' + str(j)]==i), 6+i)

    df['personasEducSIIAS']['menos' + 'EnAnosEducEsta' + str(j)] = df['personasEducSIIAS'].filter(items=['menos' + 'EnAnosEducEstaCEIP' + str(j),'menos' + 'EnAnosEducEstaCES' + str(j)]).max(axis=1)

for j in range (1,25):
    df['personasEducSIIAS']['menos' + 'EnAnosEducCorrectos' + str(j)] = 0
    df['personasEducSIIAS']['menos' + 'EnAnosEducCorrectos' + str(j)] = df['personasEducSIIAS']['menos' + 'EnAnosEducCorrectos' + str(j)].mask(df['personasEducSIIAS']['menos' + 'EnAnosEducEsta' + str(j)]>=df['personasEducSIIAS']['menos' + 'EnAnosEducDeberia' + str(j)], 1)
    df['personasEducSIIAS']['menos' + 'EstudiaCEIPCES' + str(j)] = 0
    df['personasEducSIIAS']['menos' + 'EstudiaCEIPCES' + str(j)] = df['personasEducSIIAS']['menos' + 'EstudiaCEIPCES' + str(j)].mask(((df['personasEducSIIAS']['menos' + 'enCEIP' + str(j)]==1) |  (df['personasEducSIIAS']['menos' + 'enCES' + str(j)]==1)), 1) 


df['personasEducSIIAS']['menores12zeroEstudiaCEIPCES'] = df['personasEducSIIAS']['menores12'] * df['personasEducSIIAS']['zeroEstudiaCEIPCES']
df['personasEducSIIAS']['menores15zeroEstudiaCEIPCES'] = df['personasEducSIIAS']['menores15'] * df['personasEducSIIAS']['zeroEstudiaCEIPCES']
df['personasEducSIIAS']['menores12LessICC1'] = df['personasEducSIIAS']['menores12'] * df['personasEducSIIAS']['zeroEstudiaCEIPCES']


# 4 grupos
df['personasEducSIIAS']['menores12LessICC1NoCobraEn0'] = df['personasEducSIIAS']['menores12'] * df['personasEducSIIAS']['lessICC1'] * df['personasEducSIIAS']['hogarNoCobraTUSEn0'] 
df['personasEducSIIAS']['menores12MoreICC2NoCobraEn0'] = df['personasEducSIIAS']['menores12'] * df['personasEducSIIAS']['moreICC2'] * df['personasEducSIIAS']['hogarNoCobraTUSEn0'] 


### Clean data before generatting binscatters

### Binscatters to see impact on schooling
for initTUS in initialTUS:
    for out in outcomes:
        for region in ['all', 'mdeo', 'int']:
            for iccMenosThres in ['1', '2', 'All']:
                for otherConds in vOtherConditions:
                    graphsRDD.fBinscatterSymmetricRDD(df['personasEducSIIAS'], xBounds=0.2, nBins=30, running='iccMenosThreshold' + iccMenosThres, 
                                     rg=region, ylabel=out, xlabel='Vulnerability Index-Threshold', 
                                     title=out, 
                                     outcome=out,
                                     initialTUS=initTUS,
                                     threshold=0, size=20,
                                     savefig= str(initTUS) + out + region + iccMenosThres + otherConds + '.pdf',
                                     otherConditions=otherConds)

graphsDID.fBinscatterEvent2Groups(df['personasEducSIIAS'], menosPeriods=12, masPeriods=30, 
                 group1='menores12LessICC1NoCobraEn0', group2='menores12MoreICC2NoCobraEn0', ylabel='ylabel is', xlabel='Months before/after the visit', 
                 title='Mean Y before/after visit', 
                 outcome='EstudiaCEIPCES',
                 savefig='../Output/EstudiaCEIPCES.pdf')

