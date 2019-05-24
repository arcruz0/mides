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

bps_afam=pd.read_excel(r'C:\Alejandro\Research\MIDES\Presentations\grafs_for_presentation.xlsx')
bps_afam_sorted=bps_afam.sort_index(ascending=False)
ocupados0 = pd.read_excel(r'C:\Alejandro\Research\MIDES\Presentations\grafs_informalidad.xlsx')
ocupados_sorted0=ocupados0.sort_index(ascending=False)
ocupados1 = pd.read_excel(r'C:\Alejandro\Research\MIDES\Presentations\grafs_informalidad1.xlsx')
ocupados_sorted1=ocupados1.sort_index(ascending=False)

## BPS AFAM Asignaciones para trabajadores

plt.figure()    
plt.scatter(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['coef_ganar'], color='green')
plt.plot(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['5_lci_ganar'], linestyle='dashed', color='grey')
plt.plot(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['5_uci_ganar'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (12) estimates')
plt.savefig('../Output/DIDbpsGanar.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['coef_perder'], color='red')
plt.plot(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['5_lci_perder'], linestyle='dashed', color='grey')
plt.plot(list(range(-12,0))+list(range(1,31)), bps_afam_sorted['5_uci_perder'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (12) estimates')
plt.savefig('../Output/DIDbpsPerder.pdf')
plt.show()

### Ocupados 0
plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['coef_ganar'], color='green')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_lci_ganar'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_uci_ganar'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID0ocupadosSIIASGanar.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['coef_super_ganar'], color='green')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_lci_super_ganar'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_uci_super_ganar'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID0ocupadosSIIASSuperGanar.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['coef_perder'], color='red')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_lci_perder'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_uci_perder'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID0ocupadosSIIASPerder.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['coef_super_perder'], color='red')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_lci_super_perder'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted0['5_uci_super_perder'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID0ocupadosSIIASSuperPerder.pdf')
plt.show()


### Ocupados 1
plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['coef_ganar'], color='green')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_lci_ganar'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_uci_ganar'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID1ocupadosSIIASGanar.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['coef_super_ganar'], color='green')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_lci_super_ganar'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_uci_super_ganar'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID1ocupadosSIIASSuperGanar.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['coef_perder'], color='red')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_lci_perder'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_uci_perder'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID1ocupadosSIIASPerder.pdf')
plt.show()

plt.figure()    
plt.scatter(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['coef_super_perder'], color='red')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_lci_super_perder'], linestyle='dashed', color='grey')
plt.plot(list(range(-11,0))+list(range(1,31)), ocupados_sorted1['5_uci_super_perder'], linestyle='dashed', color='grey')
#plt.scatter(xAxis, yGroup2, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.ylabel('DID coefficient')
plt.xlabel('Months before/after visit')
plt.title('DID leads (30) and lags (11) estimates')
plt.savefig('../Output/DID1ocupadosSIIASSuperPerder.pdf')
plt.show()


## Rolling RDD para edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 y separado en: todos, aquellos q no cobraban TUS, aquellos q sí cobraban

cuantosGruposRDD = [10, 11, 12, 13]
indexX = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
stataRD=dict()
for group in cuantosGruposRDD:
    stataRD[group] = pd.read_excel('../Output/mGroup' + str(group) + '.xls', names=indexX, header=None)


# Everyone
plt.figure()
#plt.scatter(indexX, stataRD[10].iloc[0], color='cadetblue', s=10)
plt.plot(indexX, stataRD[10].iloc[0], color='cadetblue')
plt.plot(indexX, stataRD[10].iloc[4], linestyle='dashed', color='grey')
plt.plot(indexX, stataRD[10].iloc[5], linestyle='dashed', color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.title('FRDD Estimate: Perc. formally employed')
plt.ylabel('FRDD Estimate')
plt.xlabel('Months after/before visit')
plt.savefig('../Output/RDDDynamicAll.pdf')
plt.show() 

# Those losing
plt.figure()
#plt.scatter(indexX, stataRD[10].iloc[0], color='cadetblue', s=10)
plt.plot(indexX, stataRD[13].iloc[0], color='red')
plt.plot(indexX, stataRD[13].iloc[4], linestyle='dashed', color='grey')
plt.plot(indexX, stataRD[13].iloc[5], linestyle='dashed', color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.title('FRDD Estimate: Perc. formally employed')
plt.ylabel('FRDD Estimate')
plt.xlabel('Months after/before visit')
plt.savefig('../Output/RDDDynamicPerder.pdf')
plt.show() 

# Those gaining
plt.figure()
#plt.scatter(indexX, stataRD[10].iloc[0], color='cadetblue', s=10)
plt.plot(indexX, stataRD[11].iloc[0], color='green')
plt.plot(indexX, stataRD[11].iloc[4], linestyle='dashed', color='grey')
plt.plot(indexX, stataRD[11].iloc[5], linestyle='dashed', color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.axhline(y=0, color='black')
plt.title('FRDD Estimate: Perc. formally employed')
plt.ylabel('FRDD Estimate')
plt.xlabel('Months after/before visit')
plt.savefig('../Output/RDDDynamicGanar.pdf')
plt.show() 
