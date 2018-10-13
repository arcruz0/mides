import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
#from ggplot import *
#import binscatter

# Umbral AFAM:              .22488131 (Mdeo) y .25648701 (Interior)
# Umbral TUS:               .62260002 (Mdeo) y .70024848 (Interior)
# Umbral TUS duplicado:     .7568     (Mdeo) y .81       (Interior)

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
df=pd.read_csv('../Input/visitas_hogares_TUS.csv')

### Create additional variables
# Create running variable for One TUS
df['iccMenosThreshold1'] = df['icc'] - df['umbral_nuevo_tus']

## Create number of TUS by household
df['hogarCuantasTusMas12'] = df['hogarMascobraTus12'] + df['hogarMastusDoble12'].fillna(value=0)
df['hogarCuantasTusMas6'] = df['hogarMascobraTus6'] + df['hogarMastusDoble6'].fillna(value=0)
df['hogarCuantasTusMas3'] = df['hogarMascobraTus3'] + df['hogarMastusDoble3'].fillna(value=0)

# Plot RD con recibir TUS (simple o doble) para Montevideo
xLinspace=np.arange(0.00260002, 1, 0.01)  # It will give me the first value of every bin
yBins=np.ones((100,1))                    # The share of household with TUS in every bin

for i in range(99):
    yBins[i]=df['hogarMascobraTus12'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==0.62260002)].mean()

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

# Plot RD con recibir TUS (simple o doble) para Interior
xLinspace=np.arange(0.00024848, 1, 0.01)  # It will give me the first value of every bin
yBins=np.ones((100,1))                    # The share of household with TUS in every bin

for i in range(99):
    yBins[i]=df['hogarMascobraTus12'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==0.70024848)].mean()

plt.figure()
#plt.axvline(x=0.22488131, color='orange', linestyle='dashed')   # AFAM threshold for Montevideo
#plt.axvline(x=0.62260002, color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
#plt.axvline(x=0.7568, color='orange', linestyle='dashed')       # Second TUS threshold for Montevideo
plt.axvline(x=0.25648701, color='red', linestyle='dashed')   # AFAM threshold for Interior
plt.axvline(x=0.70024848, color='red', linestyle='dashed')   # First TUS threshold for Interior
plt.axvline(x=.81, color='red', linestyle='dashed')       # Second TUS threshold for Interior
plt.scatter(xLinspace[:-1],  yBins[:-1], color='darkslateblue')
plt.ylabel('Percentage that gets TUS 12 months after the visit')
plt.xlabel('ICC')
plt.title("Percentage of households getting TUS 12 months after the visit")
plt.savefig('../Output/cobraTusMdeo.png')
plt.show()

# Plot RD de perder o duplicar la transferencia para aquellos que recibian 1 a la fecha de la visita (Mdeo)
xLinspace=np.arange(0.00260002, 1, 0.01)  # It will give me the first value of every bin
yBins=np.ones((100,1))                    # The share of household with TUS in every bin

for i in range(99):
    yBins[i]=df['hogarCuantasTusMas12'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==0.62260002) & (df['hogarZerocobraTus']==1)].mean()

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

# Plot RD de perder o duplicar la transferencia para aquellos que recibian 1 a la fecha de la visita (Interior)
xLinspace=np.arange(0.00024848, 1, 0.01)  # It will give me the first value of every bin
yBins=np.ones((100,1))                    # The share of household with TUS in every bin

for i in range(99):
    yBins[i]=df['hogarCuantasTusMas12'][(df['icc']>=xLinspace[i]) & (df['icc']<xLinspace[i+1]) & (df['umbral_nuevo_tus']==0.70024848) & (df['hogarZerocobraTus']==1)].mean()

plt.figure()
#plt.axvline(x=0.22488131, color='orange', linestyle='dashed')   # AFAM threshold for Montevideo
#plt.axvline(x=0.62260002, color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
#plt.axvline(x=0.7568, color='orange', linestyle='dashed')       # Second TUS threshold for Montevideo
plt.axvline(x=0.25648701, color='red', linestyle='dashed')   # AFAM threshold for Interior
plt.axvline(x=0.70024848, color='red', linestyle='dashed')   # First TUS threshold for Interior
plt.axvline(x=.81, color='red', linestyle='dashed')       # Second TUS threshold for Interior
plt.scatter(xLinspace[:-1],  yBins[:-1], color='darkslateblue')
plt.ylabel('Percentage that gets TUS 12 months after the visit')
plt.xlabel('ICC')
plt.title("Percentage of households getting TUS 12 months after the visit")
plt.savefig('../Output/cobraTusMdeo.png')
plt.show()
