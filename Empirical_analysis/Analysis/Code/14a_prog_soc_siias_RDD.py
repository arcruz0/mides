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

### Load data
df=dict()
df['personas']=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
df['hogaresTUS']=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')

allVarsCargar = ['bps_afam_ley_benef', 'bps_afam_ley_atrib', 'bps_pens_vejez', 'bps_sol_habit_am',
                 'mvotma_rubv', 'inau_t_comp', 'inau_disc_t_comp' ,'inau_caif', 'inau_club_niños', 'inau_ctros_juveniles',
                 'mid_asist_vejez', 'mides_canasta_serv', 'mides_jer', 'mides_cercanias', 'mides_ucc',
                 'mides_uy_trab', 'mides_monotributo', 'mides_inda_snc', 'mides_inda_paec', 'mides_inda_panrn']

varsCargar = allVarsCargar

for var in varsCargar:
    df['personas' + var]=pd.read_csv('../Input/MIDES/visitas_personas_' + var + '.csv')
    df['personas' + var]=df['personas' + var].merge(df['hogaresTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')
    df['personas' + var]=df['personas' + var].merge(df['personas'].filter(items=['flowcorrelativeid', 'nrodocumentoSIIAS', 'edad_visita', 'sexo', 'parentesco', 'situacionlaboral', 'nivelmasaltoalcanzado', 'asiste', 'fechanacimiento']), left_on=['flowcorrelativeid', 'nrodocumentoSIIAS'], right_on=['flowcorrelativeid', 'nrodocumentoSIIAS'])

    ### Variables over which to loop when creating binscatters
    initialTUS = ['all', 0, 1, 2]
    outcomes = ['zero' + var, 'mas' + var + '18', 'mas' + var + '24', 'mas' + var + '36', 'mas' + var + '48']
    vOtherConditions = ['menores','hombresAdultos62','mujeresAdultos62','adultos70', 'jefe', 'menores1215', 'adultos1864']
    
    ### Genero variables
    # Relativas al ICC
    df['personas' + var]['iccMenosThreshold0'] = df['personas' + var]['icc'] - df['personas' + var]['umbral_afam']
    df['personas' + var]['iccMenosThreshold1'] = df['personas' + var]['icc'] - df['personas' + var]['umbral_nuevo_tus']
    df['personas' + var]['iccMenosThreshold2'] = df['personas' + var]['icc'] - df['personas' + var]['umbral_nuevo_tus_dup']
    df['personas' + var]['iccMenosThresholdAll'] = np.NaN
    df['personas' + var]['iccMenosThresholdAll'] = df['personas' + var]['iccMenosThresholdAll'].mask((abs(df['personas' + var]['iccMenosThreshold0'])<abs(df['personas' + var]['iccMenosThreshold1'])) & (abs(df['personas' + var]['iccMenosThreshold0'])<abs(df['personas' + var]['iccMenosThreshold2'])), df['personas' + var]['iccMenosThreshold0'])
    df['personas' + var]['iccMenosThresholdAll'] = df['personas' + var]['iccMenosThresholdAll'].mask((abs(df['personas' + var]['iccMenosThreshold1'])<abs(df['personas' + var]['iccMenosThreshold2'])) & (abs(df['personas' + var]['iccMenosThreshold1'])<abs(df['personas' + var]['iccMenosThreshold0'])), df['personas' + var]['iccMenosThreshold1'])
    df['personas' + var]['iccMenosThresholdAll'] = df['personas' + var]['iccMenosThresholdAll'].mask((abs(df['personas' + var]['iccMenosThreshold2'])<abs(df['personas' + var]['iccMenosThreshold1'])) & (abs(df['personas' + var]['iccMenosThreshold2'])<abs(df['personas' + var]['iccMenosThreshold0'])), df['personas' + var]['iccMenosThreshold2'])

    # Edad y sexo
    df['personas' + var]['zero']=0
    df['personas' + var]['menores'] = df['personas' + var]['zero'].mask(df['personas' + var]['edad_visita']<=17, other=1)
    df['personas' + var]['mujeres'] = df['personas' + var]['zero'].mask(df['personas' + var]['sexo']==2, other=1)
    df['personas' + var]['hombres'] = df['personas' + var]['zero'].mask(df['personas' + var]['sexo']==1, other=1)
    df['personas' + var]['hombresAdultos'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==1) & (df['personas' + var]['edad_visita']>=18), other=1)
    df['personas' + var]['mujeresAdultos'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==2) & (df['personas' + var]['edad_visita']>=18), other=1)
    df['personas' + var]['adultos'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=18), other=1)
    df['personas' + var]['adultos68'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=68), other=1)
    df['personas' + var]['hombresAdultos68'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==1) & (df['personas' + var]['edad_visita']>=68), other=1)
    df['personas' + var]['adultos1864'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=18) & (df['personas' + var]['edad_visita']<=64), other=1)
    
    df['personas' + var]['adultos62'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=62), other=1)
    df['personas' + var]['hombresAdultos62'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==1) & (df['personas' + var]['edad_visita']>=62), other=1)
    df['personas' + var]['mujeresAdultos62'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==2) & (df['personas' + var]['edad_visita']>=62), other=1)
    
    df['personas' + var]['adultos64'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=64), other=1)
    df['personas' + var]['hombresAdultos64'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==1) & (df['personas' + var]['edad_visita']>=64), other=1)
    df['personas' + var]['mujeresAdultos64'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==2) & (df['personas' + var]['edad_visita']>=64), other=1)
    
    df['personas' + var]['adultos70'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>=70), other=1)
    df['personas' + var]['hombresAdultos70'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==1) & (df['personas' + var]['edad_visita']>=70), other=1)
    df['personas' + var]['mujeresAdultos70'] = df['personas' + var]['zero'].mask((df['personas' + var]['sexo']==2) & (df['personas' + var]['edad_visita']>=70), other=1)
    
    
    df['personas' + var]['jefe'] = df['personas' + var]['zero'].mask(df['personas' + var]['parentesco']==1, other=1)
    df['personas' + var]['jefeMujer'] = df['personas' + var]['zero'].mask((df['personas' + var]['parentesco']==1) & (df['personas' + var]['sexo']==2), other=1)
    df['personas' + var]['jefeHombre'] = df['personas' + var]['zero'].mask((df['personas' + var]['parentesco']==1) & (df['personas' + var]['sexo']==1), other=1)   
    df['personas' + var]['menores12'] = df['personas' + var]['zero'].mask(df['personas' + var]['edad_visita']<=12, other=1)
    df['personas' + var]['menores14'] = df['personas' + var]['zero'].mask(df['personas' + var]['edad_visita']<=14, other=1)
    df['personas' + var]['menores15'] = df['personas' + var]['zero'].mask(df['personas' + var]['edad_visita']<=15, other=1)
    df['personas' + var]['menores1215'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=15) & (df['personas' + var]['edad_visita']>=12) , other=1)
    df['personas' + var]['menores1317'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['edad_visita']>=13) , other=1)
    df['personas' + var]['menores1115'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=15) & (df['personas' + var]['edad_visita']>=11) , other=1)

    ## Trabajo
    df['personas' + var]['cuentaPropistaOPatron'] = df['personas' + var]['zero'].mask((df['personas' + var]['situacionlaboral']==4) | (df['personas' + var]['situacionlaboral']==5), other=1)

    # Relativas al TUS
    df['personas' + var]['hogarZeroCuantasTus'] = df['personas' + var]['hogarZerocobraTus'] + df['personas' + var]['hogarZerotusDoble'].fillna(value=0)

    # Relativas a TUS y otras cosas
    df['personas' + var]['menoresLessTUS1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']<0), other=1)
    df['personas' + var]['menoresMoreTUS1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']>0), other=1)
    df['personas' + var]['adultosLessTUS1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']<0), other=1)
    df['personas' + var]['adultosMoreTUS1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']>0), other=1)
    
    df['personas' + var]['adultosMoreTUS1Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']>0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)
    df['personas' + var]['adultosLessTUS1Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)
    
    df['personas' + var]['adultosMoreTUS1Initial1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']>0) & (df['personas' + var]['hogarZeroCuantasTus']==1), other=1)
    df['personas' + var]['adultosLessTUS1Initial1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==1), other=1)
    
    df['personas' + var]['adultosLessTUS1Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==2), other=1)
    df['personas' + var]['adultosMoreTUS2Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold2']>0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)
    
    df['personas' + var]['adultosLessTUS1Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==2), other=1)
    df['personas' + var]['adultosMoreTUS2Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']>17) & (df['personas' + var]['iccMenosThreshold2']>0) & (df['personas' + var]['hogarZeroCuantasTus']==2), other=1)
    
    
    df['personas' + var]['menoresMoreTUS1Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']>0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)
    df['personas' + var]['menoresLessTUS1Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)
    
    df['personas' + var]['menoresMoreTUS1Initial1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']>0) & (df['personas' + var]['hogarZeroCuantasTus']==1), other=1)
    df['personas' + var]['menoresLessTUS1Initial1'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==1), other=1)
    
    df['personas' + var]['menoresLessTUS1Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==2), other=1)
    df['personas' + var]['menoresMoreTUS2Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold2']>0) & (df['personas' + var]['hogarZeroCuantasTus']==2), other=1)
    
    df['personas' + var]['menoresMoreTUS2Initial0'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold2']>0) & (df['personas' + var]['hogarZeroCuantasTus']==0), other=1)

    df['personas' + var]['menores025LessTUS1Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold1']<0) & (df['personas' + var]['hogarZeroCuantasTus']==2) & (df['personas' + var]['iccMenosThreshold1']>-0.25), other=1)
    df['personas' + var]['menores025MoreTUS2Initial2'] = df['personas' + var]['zero'].mask((df['personas' + var]['edad_visita']<=17) & (df['personas' + var]['iccMenosThreshold2']>0) & (df['personas' + var]['hogarZeroCuantasTus']==2) & (df['personas' + var]['iccMenosThreshold1']>-0.25), other=1)
    
    ### Tener una idea de población en cada programa
    # numeroEnZero=dict()
    # numeroEnZero[var]=df['personas' + var]['zero' + var].value_counts()
    
    ### Binscatters to see impact on programas sociales
    for initTUS in initialTUS:
        for out in outcomes:
            for region in ['all', 'mdeo', 'int']:
                for iccMenosThres in ['1', '2', 'All']:
                    for otherConds in vOtherConditions:
                        graphsRDD.fBinscatterSymmetricRDD(df['personas' + var], xBounds=0.2, nBins=30, running='iccMenosThreshold' + iccMenosThres, 
                                         rg=region, ylabel=out, xlabel='Vulnerability Index-Threshold', 
                                         title=out, 
                                         outcome=out,
                                         initialTUS=initTUS,
                                         threshold=0, size=20,
                                         savefig= str(initTUS) + out + region + iccMenosThres + otherConds + '.pdf',
                                         otherConditions=otherConds)
        
    # Limpio memoria
    df['personas' + var] = 0

