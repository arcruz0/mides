import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
#from ggplot import *

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

# Cargo base de personas y elimino variables que no interesan
df = pd.read_csv('ale.csv')

# Defino numero de bins y cosas asi
bins=20
# Merge con base hogares para agregar variables de hogares que quiera, en especial variable template

# Elimino personas que no fueron re-vistadas censalmente



### Asistencia a la escuela (asiste)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['asisteEscuelaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['edad_visitaTwo']<18)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Attends school')
plt.xlabel('VI - First threshold')
plt.title('Perc. of children (<18) attending school during 2nd visit')
plt.savefig('../Output/asisteEscuela.png')
plt.show()


### Bienes durables ()

### Situación laboral 

### Toma medicación

### Self-reported income de varios tipos

### Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['sinalimentosTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food')
plt.xlabel('VI - First threshold')
plt.title('Perc. of households with "No Food" during 2nd visit')
plt.savefig('../Output/sinalimentos.png')
plt.show()


xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['adultonocomioTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Adults')
plt.xlabel('VI - First threshold')
plt.title('Perc. of households with "No Food for Adults" during 2nd visit')
plt.savefig('../Output/adultonocomio.png')
plt.show()


xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['menornocomioTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Minors')
plt.xlabel('VI - First threshold')
plt.title('Perc. of households with "No Food for Minors" during 2nd visit')
plt.savefig('../Output/menornocomio.png')
plt.show()


xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('VI - First threshold')
plt.title('Perc. of households with Domestic Violence situations during 2nd visit')
plt.savefig('../Output/vd.png')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdMujerTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('VI - First threshold')
plt.title('Perc. of households with Domestic Violence situations during 2nd visit')
plt.savefig('../Output/vd.png')
plt.show()


xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['embarazadaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hombreOne']==0) & (df['edad_visitaTwo']<40)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Pregnant')
plt.xlabel('VI - First threshold')
plt.title('Perc. of pregnants during 2nd visit')
plt.savefig('../Output/embarazada.png')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['canastaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hombreOne']==0) & (df['edad_visitaTwo']<40)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Pregnant')
plt.xlabel('VI - First threshold')
plt.title('Perc. of pregnants during 2nd visit')
plt.savefig('../Output/embarazada.png')
plt.show()


xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetelefonocelularTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hombreOne']==0) & (df['edad_visitaTwo']<40)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Pregnant')
plt.xlabel('VI - First threshold')
plt.title('Perc. of pregnants during 2nd visit')
plt.savefig('../Output/indocumentados.png')
plt.show()



### Regularizado agua y UTE (aguacorriente, redelectrica)

### Residuos cuadra y aguas contaminadas (residuoscuadra, aguascontaminadas)