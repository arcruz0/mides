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

# AFAM 2013 se suspendió pagó a partir de julio 2013 y se anunició en junio (https://www.bps.gub.uy/6652/comunicado_de_asignaciones_familiares.html)
# AFAM 2014 se suspendió a partir de julio 2014 y se anunció en julio mismo (https://www.bps.gub.uy/7968/suspension-de-asignaciones-familiares-por-inasistencias-injustificadas.html)
# AFAM 2015 se anunción en octubre de 2015 y se suspende pago a partir de enero 2016 (https://www.bps.gub.uy/10041/comunicado-de-prensa-sobre-asignaciones-familiares.html)
# AFAM 2016
# AFAM 2017
# AFAM 2018 se anunció en junio 2018 y se suspende a partir de setiembre de 2018 (https://www.bps.gub.uy/14981/control-de-estudios-de-beneficiarios-de-asignaciones-familiares.html)

# Este decreto reglamentó un poco la quita por motivo de educación https://www.impo.com.uy/bases/decretos/239-2015

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory
dfVars=pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
dfSusp=pd.read_csv('../Input/MIDES/visitas_personas_PPySusp.csv')
dfSusp2 = dfSusp.merge(dfVars.filter(items=['flowcorrelativeid', 'nrodocumento', 'departamento', 'asiste', 'edad_visita']), on=['flowcorrelativeid', 'nrodocumento'], how='left')
dfHogTUS=pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')

dfSusp2 = dfSusp2.merge(dfHogTUS.filter(items=['flowcorrelativeid', 'hogarMascobraTus1', 'hogarMascobraTus3', 'hogarMascobraTus6', 'hogarMascobraTus9', 'hogarMascobraTus12', 'hogarZerocobraTus', 'hogarcobraTus54', 'hogarcobraTus55', 'hogarcobraTus56', 'hogarcobraTus57', 'hogarcobraTus58', 'hogarcobraTus59', 'hogarcobraTus60', 'hogarcobraTus61', 'hogarcobraTus62', 'hogarcobraTus63', 'hogarcobraTus64', 'hogarcobraTus65', 'hogarcobraTus66', 'hogarcobraTus67', 'hogarcobraTus68', 'hogarcobraTus69', 'hogarcobraTus70', 'hogarcobraTus71', 'hogarcobraTus72', 'hogarcobraTus73', 'hogarcobraTus74']), on=['flowcorrelativeid'], how='left')


### Macros
region = ['mdeo', 'int']

### Dictionaries
afamThreshold={'mdeo': 0.22488130, 'int': 0.25648700}
tus1Threshold={'mdeo': 0.62260001, 'int': 0.70024847}
tus2Threshold={'mdeo': 0.7568, 'int': 0.81}
xLinspaceStart={'mdeo': 0.42260001, 'int': 0.50024847}
xLinspaceEnd={'mdeo': 0.82260001, 'int': 0.90024847}
xLinspaceStep={'mdeo': 0.02, 'int': 0.02}
binsRegion={'mdeo': int(round((xLinspaceEnd['mdeo']-xLinspaceStart['mdeo'])/xLinspaceStep['mdeo'])), 'int': int(round((xLinspaceEnd['int']-xLinspaceStart['int'])/xLinspaceStep['int']))}
colorsRegion={'mdeo': 'darkslateblue', 'int': 'red'}
montevideo={'mdeo': 1, 'int': 0}

### Generate variables
dfSusp2['suspPost2013Cuantas'] = dfSusp2['susp2013'] + dfSusp2['susp2014'] + dfSusp2['susp2015'] + dfSusp2['susp2016'] + dfSusp2['susp2017'] + dfSusp2['susp2018']
dfSusp2['suspPost2014Cuantas'] = dfSusp2['susp2014'] + dfSusp2['susp2015'] + dfSusp2['susp2016'] + dfSusp2['susp2017'] + dfSusp2['susp2018']
dfSusp2['suspPost2015Cuantas'] = dfSusp2['susp2015'] + dfSusp2['susp2016'] + dfSusp2['susp2017'] + dfSusp2['susp2018']
dfSusp2['suspPost2016Cuantas'] = dfSusp2['susp2016'] + dfSusp2['susp2017'] + dfSusp2['susp2018']
dfSusp2['suspPost2017Cuantas'] = dfSusp2['susp2017'] + dfSusp2['susp2018']

dfSusp2['suspPost2013'] = dfSusp2['suspPost2013Cuantas'].where(dfSusp2['suspPost2013Cuantas']==0, 1)
dfSusp2['suspPost2014'] = dfSusp2['suspPost2014Cuantas'].where(dfSusp2['suspPost2014Cuantas']==0, 1)
dfSusp2['suspPost2015'] = dfSusp2['suspPost2015Cuantas'].where(dfSusp2['suspPost2015Cuantas']==0, 1)
dfSusp2['suspPost2016'] = dfSusp2['suspPost2016Cuantas'].where(dfSusp2['suspPost2016Cuantas']==0, 1)
dfSusp2['suspPost2017'] = dfSusp2['suspPost2017Cuantas'].where(dfSusp2['suspPost2017Cuantas']==0, 1)

dfSusp2['susp20132014'] = dfSusp2[['susp2013','susp2014']].max(axis=1)
dfSusp2['susp20142015'] = dfSusp2[['susp2014','susp2015']].max(axis=1)
dfSusp2['susp20152016'] = dfSusp2[['susp2015','susp2016']].max(axis=1)

dfSusp2['montevideo'] = dfSusp2['departamento_x'].where(dfSusp2['departamento_x']==1, 0)
dfSusp2['iccMenosThreshold1'] = dfSusp2['icc'] - dfSusp2['umbral_nuevo_tus']

### Graphs

# Por region
for rg in region:
    xLinspace=np.arange(xLinspaceStart[rg], xLinspaceEnd[rg], xLinspaceStep[rg])  # It will give me the first value of every bin
    yBins=np.ones((binsRegion[rg],1))                    # The share of household with TUS in every bin
    
    for i in range(binsRegion[rg]-1):
        yBins[i] = dfSusp2['susp2014'][(dfSusp2['icc']>=xLinspace[i]) & (dfSusp2['icc']<xLinspace[i+1]) \
                   & (dfSusp2['montevideo']==montevideo[rg]) & (dfSusp2['year']==2013) \
                   & (dfSusp2['edad_visita']>13) & (dfSusp2['edad_visita']<17)].mean()
    
    plt.figure()
    #plt.axvline(x=afamThreshold[rg], color='orange', linestyle='dashed')   # AFAM threshold for Montevideo
    plt.axvline(x=tus1Threshold[rg], color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
    plt.axvline(x=tus2Threshold[rg], color='orange', linestyle='dashed')       # Second TUS threshold for Montevideo

    plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='darkslateblue')
    plt.ylabel('Suspended 2014')
    plt.xlabel('ICC')
    plt.title("Suspended 2014")
    plt.savefig('../Output/cobraTusMdeo.png')
    plt.show()

# Mdeo e interior juntos y solo primer umbral de TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((20,1))                    # The share of household with TUS in every bin
    
for i in range(20-1):
    yBins[i] = dfSusp2['susp20132014'][(dfSusp2['iccMenosThreshold1']>=xLinspace[i]) & (dfSusp2['iccMenosThreshold1']<xLinspace[i+1]) \
                 & (dfSusp2['year']<2014) & (dfSusp2['edad_visita']>10) & (dfSusp2['edad_visita']<18) & (dfSusp2['hogarZerocobraTus']==1)].mean()
    
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')   # First TUS threshold for Montevideo
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='darkslateblue')
plt.ylabel('Suspended 2014')
plt.xlabel('ICC')
plt.title("Suspended 2014")
plt.savefig('../Output/cobraTusMdeo.png')
plt.show()