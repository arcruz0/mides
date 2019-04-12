import pandas as pd
import os, shutil

### Set the current folder
os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

### Preparo archivo de geocoding de addressess con variables adicionales que quiera para ilustrar cosas en el mapa (ej: si visita asociada a pérdida de TUS, etc)

# Cargo geocoding, variables de visitas que precise y hago merge
geodata = pd.read_csv('../../Build/Output/geocoding/geocoding.txt', sep='\t', encoding='latin1')
geodata = geodata.rename(index=str, columns={"ID": "flowcorrelativeid"})
visitasGeocoding = pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
geodata = geodata.merge(visitasGeocoding.filter(items=['flowcorrelativeid', 'hogarIndexTotCambios12', 'hogarIndexCambios12', 'hogarIndexTotCambios6', 'hogarIndexCambios6']), on=['flowcorrelativeid'], how='left')

# Data cleaning de geocoding

# Save geocoded data to be loaded in ArcGIS
geodata.to_csv('geodata_cleaned.txt', header=list(geodata), index=None, sep='\t')
