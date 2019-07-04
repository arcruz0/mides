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

### Load data
df=dict()
df['hogaresSIIAS']=pd.read_csv('../Input/MIDES/BPS_SIIAS_hogares.csv')
df['personasSIIAS']=pd.read_csv('../Input/MIDES/BPS_SIIAS_personas.csv')
df['personas']=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
df['hogaresTUS']=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
df['personasSIIAS']=df['personasSIIAS'].merge(df['hogaresTUS'].filter(items=['flowcorrelativeid', 'hogarZerocobraTus', 'hogarZerotusDoble','hogarMascobraTus3', 'hogarMastusDoble3', 'hogarMascobraTus6', 'hogarMastusDoble6', 'hogarMascobraTus9', 'hogarMastusDoble9', 'hogarMascobraTus12', 'hogarMastusDoble12', 'hogarMascobraTus18', 'hogarMastusDoble18', 'hogarMascobraTus24', 'hogarMastusDoble24']), left_on='flowcorrelativeid', right_on='flowcorrelativeid')
df['personasSIIAS']=df['personasSIIAS'].merge(df['personas'].filter(items=['flowcorrelativeid', 'nrodocumentoSIIAS', 'edad_visita', 'sexo', 'parentesco', 'situacionlaboral', 'nivelmasaltoalcanzado']), left_on=['flowcorrelativeid', 'nrodocumentoSIIAS'], right_on=['flowcorrelativeid', 'nrodocumentoSIIAS'])

### Load data from Stata to create plots with its results in Python

### Dictionaries
afamThreshold={'mdeo': 0.22488131, 'int': 0.25648701}
tus1Threshold={'mdeo': 0.62260002, 'int': 0.70024848}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
mesesLags=['3','6','9','12','18','24']

### Generate variables
df['personasSIIAS']['iccMenosThreshold0'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_afam']
df['personasSIIAS']['iccMenosThreshold1'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus']
df['personasSIIAS']['iccMenosThreshold2'] = df['personasSIIAS']['icc'] - df['personasSIIAS']['umbral_nuevo_tus_dup']
df['personasSIIAS']['iccMenosThresholdAll'] = np.NaN
df['personasSIIAS']['iccMenosThresholdAll'] = df['personasSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasSIIAS']['iccMenosThreshold0'])<abs(df['personasSIIAS']['iccMenosThreshold1'])) & (abs(df['personasSIIAS']['iccMenosThreshold0'])<abs(df['personasSIIAS']['iccMenosThreshold2'])), df['personasSIIAS']['iccMenosThreshold0'])
df['personasSIIAS']['iccMenosThresholdAll'] = df['personasSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasSIIAS']['iccMenosThreshold1'])<abs(df['personasSIIAS']['iccMenosThreshold2'])) & (abs(df['personasSIIAS']['iccMenosThreshold1'])<abs(df['personasSIIAS']['iccMenosThreshold0'])), df['personasSIIAS']['iccMenosThreshold1'])
df['personasSIIAS']['iccMenosThresholdAll'] = df['personasSIIAS']['iccMenosThresholdAll'].mask((abs(df['personasSIIAS']['iccMenosThreshold2'])<abs(df['personasSIIAS']['iccMenosThreshold1'])) & (abs(df['personasSIIAS']['iccMenosThreshold2'])<abs(df['personasSIIAS']['iccMenosThreshold0'])), df['personasSIIAS']['iccMenosThreshold2'])
df['personasSIIAS']['hogarZeroCuantasTus'] = df['personasSIIAS']['hogarZerocobraTus'] + df['personasSIIAS']['hogarZerotusDoble'].fillna(value=0)


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

df['personasSIIAS']['adultos2164NoOcupados0'] = df['personasSIIAS']['all0'].mask((df['personasSIIAS']['zeroocupadoSIIAS']==0) & (df['personasSIIAS']['edad_visita']>=21) & (df['personasSIIAS']['edad_visita']<=64) , other=1)
df['personasSIIAS']['adultos2164SiOcupados0'] = df['personasSIIAS']['all0'].mask((df['personasSIIAS']['zeroocupadoSIIAS']==1) & (df['personasSIIAS']['edad_visita']>=21) & (df['personasSIIAS']['edad_visita']<=64) , other=1)

## Variables pooling data on ocupados
for start in [12,24]:
    for end in [24, 36, 48, 60]:
        df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)] = 0
        for val in range(start,end+1):
            df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)] = df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)] + df['personasSIIAS']['masocupadoSIIAS' + str(val)]
        df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)] = df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)]/len(range(start,end+1))
        df['personasSIIAS']['siempremasocupadoSIIAS' + str(start) + 'a' + str(end)] = df['personasSIIAS']['all0'].mask(df['personasSIIAS']['masocupadoSIIAS' + str(start) + 'a' + str(end)]==1, 1)


# Create number of TUS by household
for ms in mesesLags:
    df['personasSIIAS']['hogarCuantasTusMas' + ms] = df['personasSIIAS']['hogarMascobraTus'+ ms] + df['personasSIIAS']['hogarMastusDoble'+ ms].fillna(value=0)


### Parameters for figures
varsRDD = ['zeroocupadoSIIAS', 'menosocupadoSIIAS3','masocupadoSIIAS12','masocupadoSIIAS18', 'masocupadoSIIAS24', 'masocupadoSIIAS36', 'masocupadoSIIAS48', 'masocupadoSIIAS60']
varsRunning = ['iccMenosThreshold1']
subsets = ['adultos','adultosHombre','adultosMujer','adultos2060', 'adultos3060', 'adultos1864Mujer', 'adultos2060Hombre', 'adultosJefeHombre',
           'adultosJefeMujer', 'adultosZeroOcupados']
startingTUS=[0,1,'all']
regiones=['mdeo', 'int', 'all']
menosPeriodsDID = [6,12]
masPeriodsDID = [12, 24, 36, 48, 54, 60]
groupsDID = [('adultosICCTUS1LessInitial1', 'adultosICCTUS1MoreInitial1'), ('adultosMujeresICCTUS1LessInitial1', 'adultosMujeresICCTUS1MoreInitial1')]

##### RDD #####
### Binscatters to see impact on formal employment
bpsSIIASRDD = open('../Output/bpsSIIASRDD.tex', 'w')

for var in varsRDD:
    for reg in regiones:
        for run in varsRunning:
            for cond in subsets:
                for start in startingTUS:
                    if var=='zeroocupadoSIIAS':
                        tit='0'
                    elif var=='masocupadoSIIAS6':
                        tit='6'
                    else:
                        tit = var[-2:]
            
                    graphsRDD.fBinscatterSymmetricRDD(df['personasSIIAS'], xBounds=0.2, nBins=30, running=run, 
                                     rg=reg, ylabel=var, xlabel=run, 
                                     title='Prob. of formal employment ' + tit + ' months after visit', 
                                     outcome=var,
                                     initialTUS=start,
                                     threshold=0,
                                     savefig='../Output/' + var + '_' + reg + '_' + run + '_' + cond + '_' + str(start) + '.pdf',
                                     otherConditions=cond)

                bpsSIIASRDD.write('\\begin{figure}[H] \n')
                bpsSIIASRDD.write('\centering \n')
                bpsSIIASRDD.write('\caption{' + var + reg + start + cond + '} \n')
                bpsSIIASRDD.write('\includegraphics[width=105mm]{' + var + '_' + reg + '_' + run + '_' + cond + '_' + str(start) + '.pdf' + '} \n')
                bpsSIIASRDD.write('\label{' + var + '_' + reg + '_' + run + '_' + cond + str(start) + '} \n')
                bpsSIIASRDD.write('\end{figure}\n')

bpsSIIASRDD.close()


##### DID #####
bpsSIIASDID = open('../Output/bpsSIIASDID.tex', 'w')

for menos in menosPeriodsDID:
    for mas in masPeriodsDID:
        for group in groupsDID:
            graphsDID.fBinscatterEvent2Groups(df['personasSIIAS'], menosPeriods=menos, masPeriods=mas, 
                             group1=group[0], 
                             group2=group[1], 
                             ylabel='Prob. of formal employment before/after visit', 
                             xlabel='Months before/after the visit', 
                             title='Prob. of formal employment before/after visit', 
                             outcome='ocupadoSIIAS',
                             savefig='../Output/DIDocupadoSIIAS_' + str(menos) + '_' + str(mas) + '_' + group[0] + '_' + group[1] + '.pdf')


            bpsSIIASDID.write('\\begin{figure}[H] \n')
            bpsSIIASDID.write('\centering \n')
            bpsSIIASDID.write('\caption{Prob. of formal employment before/after visit for ' + group[0] + ' (red) and ' + group[1] + ' grey} \n')
            bpsSIIASDID.write('\includegraphics[width=105mm]{DIDocupadoSIIAS_' + str(menos) + '_' + str(mas) + '_' + group[0] + '_' + group[1] + '.pdf' + '} \n')
            bpsSIIASDID.write('\label{' + var + '_' + reg + '_' + run + '_' + cond + str(start) + '} \n')
            bpsSIIASDID.write('\end{figure}\n')

bpsSIIASDID.close()


### Plots con resultados de Stata de RD estimates plots
cuantosGruposRDD = [1, 2, 3, 4, 5, 6, 7, 8, 9]
indexX = [-24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
stataRD=dict()
for group in cuantosGruposRDD:
    stataRD[group] = pd.read_excel('../Output/mGroup' + str(group) + '.xls', names=[-24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60], header=None)

plt.figure()
plt.scatter(indexX, stataRD[2].iloc[0], color='green', s=10)
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black', linestyle='dashed')
plt.ylabel('RD estimate sobre lag prob. ocupado')
plt.legend()
plt.show() 
   
### Plots con resultados de Stata de DID estimates
graphsRDD.fBinscatterSymmetricRDD(df['personasSIIAS'], xBounds=0.2, nBins=30, running='iccMenosThreshold1', 
                                     rg='int', ylabel='Perc. employed', xlabel='Vulnerability Index - First threshold', 
                                     title='Perc. formally employed 24 months after visit', 
                                     outcome='masocupadoSIIAS24a48',
                                     initialTUS=1,
                                     threshold=0, size=14,
                                     savefig='../Output/grafPaperOcupadosRDD.pdf',
                                     otherConditions='adultos')


## Hago plot de robustness de resultados del RDD
robustness = pd.read_csv('../Output/robustness.csv')

plt.figure()
#plt.scatter(indexX, stataRD[10].iloc[0], color='cadetblue', s=10)
plt.plot(robustness['band'], robustness['coeff'], color='red')
plt.plot(robustness['band'], robustness['lci'], linestyle='dashed', color='grey')
plt.plot(robustness['band'], robustness['uci'], linestyle='dashed', color='grey')
plt.axvline(x=0.145, color='green', linestyle='dashed')
plt.axvline(x=0.135, color='brown', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.title('FRDD Estimate: Perc. formally employed after 3 yrs')
plt.ylabel('FRDD Estimate')
plt.xlabel('Bandwith')
plt.savefig('../Output/RDDrobustness.pdf')
plt.show() 
