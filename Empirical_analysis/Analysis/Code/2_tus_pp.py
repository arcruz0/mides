import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
#from ggplot import *


# Umbral AFAM:              .22488131 (Mdeo) y .25648701 (Interior)
# Umbral TUS:               .62260002 (Mdeo) y .70024848 (Interior)
# Umbral TUS duplicado:     .7568     (Mdeo) y .81       (Interior)

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
df=pd.read_csv('../Input/visitas_personas_otras_vars.csv')

# 2013 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 70)
xLinspace=np.arange(0.02260002, 1, 0.06)  # It will give me the first value of every bin
yBins=np.ones((17,1))                    # The share of household with TUS in every bin

for i in range(16):
    yBins[i] = df['pp2016'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) \
               & (df['umbral_nuevo_tus']==0.62260002) & (df['habilitado2016']==1) \
               & (df['hogarzerocobratus']==1) & (df['periodo']>=94) & (df['periodo']<=100)].mean()

plt.figure()
plt.axvline(x=0.22488131, color='orange', linestyle='dashed')   # AFAM threshold for Montevideo
plt.axvline(x=0.62260002, color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
#plt.axvline(x=0.7568, color='orange', linestyle='dashed')       # Second TUS threshold for Montevideo
#plt.axvline(x=0.25648701, color='red', linestyle='dashed')   # AFAM threshold for Interior
#plt.axvline(x=0.70024848, color='red', linestyle='dashed')   # First TUS threshold for Interior
#plt.axvline(x=.81, color='red', linestyle='dashed')       # Second TUS threshold for Interior
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='darkslateblue')
plt.ylabel('Percentage that gets TUS 12 months after the visit')
plt.xlabel('ICC')
plt.title("Percentage of households getting TUS 12 months after the visit")
plt.savefig('../Output/cobraTusMdeo.png')
plt.show()
