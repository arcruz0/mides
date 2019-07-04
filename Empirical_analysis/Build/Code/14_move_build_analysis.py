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

    

# Move files from Build/Output to Analysis/Input/MIDES
shutil.rmtree("../Input/MIDES", ignore_errors= True)
shutil.copytree("../../Build/Output", "../Input/MIDES", symlinks=False, ignore=None)

