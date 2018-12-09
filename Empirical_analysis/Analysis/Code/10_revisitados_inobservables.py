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
df = pd.read_csv('vars_personas_revisitadas.csv')

# Defino numero de bins y cosas asi
bins=10


### Defino muestra de winners and losers en primera visita (entre los que inicialmente UCT=0)

# Con bandwith de 0.15
df['winnerOne015'] = 0
df['winnerOne015'] = df['winnerOne015'].mask((df['iccNormPrimerTusOne']>=0) & (df['iccNormPrimerTusOne']<0.15) & (df['hogarZerocobraTusOne']==0), 1)

df['loserOne015'] = 0
df['loserOne015'] = df['loserOne015'].mask((df['iccNormPrimerTusOne']<0) & (df['iccNormPrimerTusOne']>-0.15) & (df['hogarZerocobraTusOne']==0), 1)

df['loserOrWinnerOne015'] = df['winnerOne015'] + df['loserOne015']

### Balance para chequear winners and losers son iguales en todos los observables

### Impacto de perder/ganar transferencia en segunda visita para winners and losers

## First stage en tercera visita
xLinspace=np.arange(-0.2, 0.2, 0.04)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogarZerocobraTusThree'][(df['iccNormPrimerTusTwo']>=xLinspace[i]) & (df['iccNormPrimerTusTwo']<xLinspace[i+1]) & (df['loserOrWinnerOne015']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with UCT during 3rd visit')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title('UCT during 3rd visit')
plt.savefig('../Output/hogarZerocobraTusThree.pdf')
plt.show()

## Revisitas
xLinspace=np.arange(-0.2, 0.2, 0.04)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['DpedidoRevisitedTwo'][(df['iccNormPrimerTusTwo']>=xLinspace[i]) & (df['iccNormPrimerTusTwo']<xLinspace[i+1]) & (df['loserOrWinnerOne015']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on a "requested" visit after 2nd visit')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title('Perc. revisited on a "requested" visit after 2nd visit')
plt.savefig('../Output/DpedidoRevisitedTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.04)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['revisitedPorGovTwo'][(df['iccNormPrimerTusTwo']>=xLinspace[i]) & (df['iccNormPrimerTusTwo']<xLinspace[i+1]) & (df['loserOrWinnerOne015']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on a "non-requested" visit after 2nd visit')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title('Perc. revisited on a "non-requested" visit after 2nd visit')
plt.savefig('../Output/revisitedPorGovTwo.pdf')
plt.show()

## Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)
xLinspace=np.arange(-0.2, 0.2, 0.04)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['sinalimentosThree'][(df['iccNormPrimerTusTwo']>=xLinspace[i]) & (df['iccNormPrimerTusTwo']<xLinspace[i+1]) & (df['loserOrWinnerOne015']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title('Perc. of households with "No Food" during 3rd visit')
plt.savefig('../Output/sinalimentosthree.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.04)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['menornocomioThree'][(df['iccNormPrimerTusTwo']>=xLinspace[i]) & (df['iccNormPrimerTusTwo']<xLinspace[i+1]) & (df['loserOrWinnerOne015']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Minors')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title('Perc. of households with "No Food for Minors" during 3rd visit')
plt.savefig('../Output/menornocomioThree.pdf')
plt.show()