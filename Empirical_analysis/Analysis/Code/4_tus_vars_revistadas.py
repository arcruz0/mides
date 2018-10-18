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
df = pd.read_csv('../Input/visitas_personas_otras_vars.csv')

# Merge con base hogares para agregar variables de hogares que quiera, en especial variable template

# Elimino personas que no fueron re-vistadas censalmente



### Asistencia a la escuela (asiste)

### Bienes durables ()

### Situación laboral 

### Toma medicación

### Self-reported income de varios tipos

### Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)

### Regularizado agua y UTE (aguacorriente, redelectrica)

### Residuos cuadra y aguas contaminadas (residuoscuadra, aguascontaminadas)