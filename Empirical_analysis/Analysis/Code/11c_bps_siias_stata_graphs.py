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

bps_afam=pd.read_excel(r'C:\Alejandro\Research\MIDES\Presentations\grafs_for_presentation.xlsx')
bps_afam_sorted=bps_afam.sort_index(ascending=False)

### DID Figures
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