import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

### Cargo bases de datos
dfPersonasAFAM = pd.read_csv('../Input/MIDES/visitas_personas_AFAM.csv')
dfHogaresAFAM = pd.read_csv('../Input/MIDES/visitas_hogares_AFAM.csv')
dfHogaresTUS = pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
dfPersonasVars = pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')

### Me quedo con base de aquellos entre -0.2 y +0.2 del primer umbral de TUS
dfPersonasAFAM['iccNormPrimerTus'] = dfPersonasAFAM['icc'] - dfPersonasAFAM['umbral_nuevo_tus']
dfPersonasAFAM = dfPersonasAFAM.merge(dfPersonasVars.filter(items=['flowcorrelativeid', 'nrodocumento', 'edad_visita', 'parentesco', 'sexo']), how='left', on=['flowcorrelativeid', 'nrodocumento'])
dfRestringida = dfPersonasAFAM[(dfPersonasAFAM['iccNormPrimerTus']>-0.2) & (dfPersonasAFAM['iccNormPrimerTus']<0.2)]

### Genero variables adicionales

# Dummy si ocupado
dfRestringida['zeroFormallyEmployed'] = dfRestringida['zerocategoriaocupbps'].mask((dfRestringida['zerocategoriaocupbps']!= 0) & (dfRestringida['zerocategoriaocupbps'].isna()== False), 1)

for i in range(1,25):
    dfRestringida['masFormallyEmployed' + str(i)] = dfRestringida['mascategoriaocupbps' + str(i)].mask((dfRestringida['mascategoriaocupbps' + str(i)]!= 0) & (dfRestringida['mascategoriaocupbps' + str(i)].isna()== False), 1)

for i in range(1,25):
    dfRestringida['menosFormallyEmployed' + str(i)] = dfRestringida['menoscategoriaocupbps' + str(i)].mask((dfRestringida['menoscategoriaocupbps' + str(i)]!= 0) & (dfRestringida['mascategoriaocupbps' + str(i)].isna()== False), 1)

# Dummy si trabajo domestico
dfRestringida['zeroDomesticWork'] = dfRestringida['zerocategoriaocupbps'].mask((dfRestringida['zerocategoriaocupbps']== 48), 1)
dfRestringida['zeroDomesticWork'] = dfRestringida['zeroDomesticWork'].mask((dfRestringida['zerocategoriaocupbps']!= 48) & (dfRestringida['zerocategoriaocupbps'].isna()== False), 0)

for i in range(1,25):
    dfRestringida['masDomesticWork' + str(i)] = dfRestringida['mascategoriaocupbps' + str(i)].mask((dfRestringida['mascategoriaocupbps' + str(i)]== 48), 1)
    dfRestringida['masDomesticWork' + str(i)] = dfRestringida['masDomesticWork' + str(i)].mask((dfRestringida['mascategoriaocupbps' + str(i)]!= 48) & (dfRestringida['mascategoriaocupbps' + str(i)].isna()== False), 0)

for i in range(1,25):
    dfRestringida['menosDomesticWork' + str(i)] = dfRestringida['menoscategoriaocupbps' + str(i)].mask((dfRestringida['menoscategoriaocupbps' + str(i)]== 48), 1)
    dfRestringida['menosDomesticWork' + str(i)] = dfRestringida['menosDomesticWork' + str(i)].mask((dfRestringida['menoscategoriaocupbps' + str(i)]!= 48) & (dfRestringida['menoscategoriaocupbps' + str(i)].isna()== False), 0)


# Ingreso total registrado en BPS (solo para quienes reciben AFAM en el mes)

### Gráficos
## Gráficos mostrando qué sucede 6 meses antes, en el mes de la visita, y 24 meses posteriores a la visita (para visitas ocurridas en 2014-2015)

# Probabilidad de estar formally employed
xAxis = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ,12 ,13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
ySuperaOIgualTUS1 = np.ones(len(xAxis))
yNoSuperaOIgualTUS1 = np.ones(len(xAxis)) 

dfRestringida['condition1'] = 0
dfRestringida['condition1'] = dfRestringida['condition1'].mask((dfRestringida['year']<=2015) & (dfRestringida['year']>=2014) & (dfRestringida['edad_visita']>24) & (dfRestringida['edad_visita']<64) & (dfRestringida['menosFormallyEmployed12'].isna() == False) & (dfRestringida['masFormallyEmployed12'].isna() == False) & (dfRestringida['zeroFormallyEmployed'].isna() == False) & (dfRestringida['masFormallyEmployed6'].isna() == False) & (dfRestringida['menosFormallyEmployed6'].isna() == False) & (dfRestringida['sexo']==1), 1)

for i in [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]:
    ySuperaOIgualTUS1[12 - i] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['menosFormallyEmployed' + str(i)].mean()
    yNoSuperaOIgualTUS1[12 - i] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['menosFormallyEmployed' + str(i)].mean()

ySuperaOIgualTUS1[12] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['zeroFormallyEmployed'].mean()
yNoSuperaOIgualTUS1[12] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['zeroFormallyEmployed'].mean()


for i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]:
    ySuperaOIgualTUS1[12 + i] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['masFormallyEmployed' + str(i)].mean()
    yNoSuperaOIgualTUS1[12 + i] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['masFormallyEmployed' + str(i)].mean()

plt.figure()    
plt.scatter(xAxis, ySuperaOIgualTUS1, color='red')
plt.scatter(xAxis, yNoSuperaOIgualTUS1, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.ylabel('Perc. formally employed')
plt.xlabel('Months before/after the visit')
plt.title('Perc. formally employed')
plt.savefig('../Output/FormallyEmployed.pdf')
plt.show()

# Probabilidad de trabajo doméstico
xAxis = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ,12 ,13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
ySuperaOIgualTUS1 = np.ones(len(xAxis))
yNoSuperaOIgualTUS1 = np.ones(len(xAxis)) 

dfRestringida['condition1'] = 0
dfRestringida['condition1'] = dfRestringida['condition1'].mask((dfRestringida['year']<=2015) & (dfRestringida['year']>=2014) & (dfRestringida['edad_visita']>24) & (dfRestringida['edad_visita']<64) & (dfRestringida['menosDomesticWork12'].isna() == False) & (dfRestringida['masDomesticWork12'].isna() == False) & (dfRestringida['zeroDomesticWork'].isna() == False) & (dfRestringida['masDomesticWork6'].isna() == False) & (dfRestringida['menosDomesticWork6'].isna() == False) & (dfRestringida['sexo']==2), 1)

for i in [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]:
    ySuperaOIgualTUS1[12 - i] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['menosDomesticWork' + str(i)].mean()
    yNoSuperaOIgualTUS1[12 - i] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['menosDomesticWork' + str(i)].mean()

ySuperaOIgualTUS1[12] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['zeroDomesticWork'].mean()
yNoSuperaOIgualTUS1[12] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['zeroDomesticWork'].mean()


for i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]:
    ySuperaOIgualTUS1[12 + i] = dfRestringida[(dfRestringida['iccNormPrimerTus']>=0) & (dfRestringida['condition1']==1)]['masDomesticWork' + str(i)].mean()
    yNoSuperaOIgualTUS1[12 + i] = dfRestringida[(dfRestringida['iccNormPrimerTus']<0) & (dfRestringida['condition1']==1)]['masDomesticWork' + str(i)].mean()

plt.figure()    
plt.scatter(xAxis, ySuperaOIgualTUS1, color='red')
plt.scatter(xAxis, yNoSuperaOIgualTUS1, color='grey')
plt.axvline(x=0, color='orange', linestyle='dashed')
plt.ylabel('Perc. DomesticWork')
plt.xlabel('Months before/after the visit')
plt.title('Perc. DomesticWork')
plt.savefig('../Output/DomesticWork.pdf')
plt.show()