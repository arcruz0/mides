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

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

# Move files from Build/Output to Analysis/Input/MIDES
shutil.rmtree("../Input/MIDES", ignore_errors= True)
shutil.copytree("../../Build/Output", "../Input/MIDES", symlinks=False, ignore=None)

