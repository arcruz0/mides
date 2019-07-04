import os

try:
    os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Alejandro')
except: pass
try:
    os.chdir('/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Lihuen')
except: pass
try:
    os.chdir('/home/andres/gdrive/mides/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Andres')
except: pass
