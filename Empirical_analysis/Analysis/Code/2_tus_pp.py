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
df=pd.read_csv('../Input/visitas_hogares_otras_vars.csv')

# Plot second stage de perder o duplicar la transferencia para aquellos que recibian 1 a la fecha de la visita en votacion PP 2013 (Mdeo)
xLinspace=np.arange(0.00260002, 1, 0.02)  # It will give me the first value of every bin
yBins=np.ones((50,1))                    # The share of household with TUS in every bin

for i in range(49):
    yBins[i]=df['hogar_voto2013'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==0.62260002) & (df['year']<=2013)].mean()

plt.figure()
plt.axvline(x=0.22488131, color='orange', linestyle='dashed')   # AFAM threshold for Montevideo
plt.axvline(x=0.62260002, color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
plt.axvline(x=0.7568, color='orange', linestyle='dashed')       # Second TUS threshold for Montevideo
#plt.axvline(x=0.25648701, color='red', linestyle='dashed')   # AFAM threshold for Interior
#plt.axvline(x=0.70024848, color='red', linestyle='dashed')   # First TUS threshold for Interior
#plt.axvline(x=.81, color='red', linestyle='dashed')       # Second TUS threshold for Interior
plt.scatter(xLinspace[:-1],  yBins[:-1], color='darkslateblue')
plt.ylabel('Percentage that gets TUS 12 months after the visit')
plt.xlabel('ICC')
plt.title("Percentage of households getting TUS 12 months after the visit")
plt.savefig('../Output/cobraTusMdeo.png')
plt.show()
