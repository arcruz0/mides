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