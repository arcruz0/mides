#!python2
### Import system modules
# Ejecutar via python asi: ir a command prompt y poner: C:\Python27\ArcGIS10.6\python.exe C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Code\7_mapa_visitas.py
import arcpy, arcgisscripting, os, shutil, stat, sys, gc, arcinfo, shutil
import pandas as pd
import os, shutil
#import gc
#gc.collect()


### Set the current folder
os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

### Armo las dos bases que voy a querer cargar: con visitas como unidad de medida y con
### hogares como unidad de medida

df = pd.read_csv('..\Input\MIDES\visitas_hogares_TUS.csv')
dataPorVisitaGIS = df.filter(items = ['flowcorrelativeid', 'latitudGeo', 'longitudGeo', 
                                      'departamento', 'localidad', 'calidadGeo', 'year', 
                                      'mes', 'periodo', 'hogarIndexTotCambios12', 'hogarIndexCambios12',
                                      'hogarIndexTotCambios6', 'hogarIndexCambios6'])
dataPorVisitaGIS.to_csv('dataPorVisitaGIS.txt', header=True, index=None, sep='\t')

##### Mapa con hogares como unidad de observación

### Load data from input folder to temp folder
shutil.copy("C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Input/mapa_visitas_empty.mxd", "C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp/mapa_visitas_analysis.mxd")
shutil.rmtree("C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp/URY_adm.gdb", ignore_errors= True)
shutil.copytree("C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Input/URY_adm.gdb", "C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp/URY_adm.gdb", symlinks=False, ignore=None)

### I set the map in which I will be working on
mxd = arcpy.mapping.MapDocument("mapa_visitas_analysis.mxd")
#mxd

### Save the data frame name or path in a variable called 'df'
dfArcGIS = arcpy.mapping.ListDataFrames(mxd)[0]
print dfArcGIS

### Set the default folder and settings that tools used in ArcGIS will use
arcpy.env.workspace = "C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp"
arcpy.env.overwriteOutput = True                                                # This option lets tools overwrite files
arcpy.env.cartographicCoordinateSystem = arcpy.SpatialReference(4326)           # Given that my shapefiles are in the geographic coordinate system GCS_WGS_1984, I will make sure it is set that way
arcpy.env.addOutputsToMap = True                                                # When tools create tables for example, you need to set this option ON to show these tables in the ArcGIS map

### Load shapefiles to dataframe in ArcGIS

## Map countrie's area 0, area 1 and area 2 shapefiles with their boundaries (this shows them in the map but actually doesn't load them as layers, I have to do that separately (if you do it interactively in ArcGIS, it performs these two steps at the same time)
addLayer = arcpy.mapping.Layer("URY_adm.gdb\URY_adm0")
arcpy.mapping.AddLayer(dfArcGIS, addLayer)
arcpy.MakeFeatureLayer_management("URY_adm.gdb\URY_adm0", "URY_adm0")  # Preciso cargar el shapefile como layer, estas dos lineas hacen eso

addLayer = arcpy.mapping.Layer("URY_adm.gdb\URY_adm1")
arcpy.mapping.AddLayer(dfArcGIS, addLayer)
arcpy.MakeFeatureLayer_management("URY_adm.gdb\URY_adm1", "URY_adm1")  # Preciso cargar el shapefile como layer, estas dos lineas hacen eso

addLayer = arcpy.mapping.Layer("URY_adm.gdb\URY_adm2")
arcpy.mapping.AddLayer(dfArcGIS, addLayer)
arcpy.MakeFeatureLayer_management("URY_adm.gdb\URY_adm2", "URY_adm2")  # Preciso cargar el shapefile como layer, estas dos lineas hacen eso

### Load geocoding de visitas and save them in a layer file
arcpy.MakeXYEventLayer_management(table="dataPorVisitaGIS.txt", in_x_field="longitudGeo", in_y_field="latitudGeo", out_layer="geocoding_Layer", spatial_reference="GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]];-400 -400 1000000000;-100000 10000;-100000 10000;8.98315284119522E-09;0.001;0.001;IsHighPrecision", in_z_field="")
addLayer = arcpy.mapping.Layer("dataPorVisitaGIS_Layer")
arcpy.mapping.AddLayer(dfArcGIS, addLayer)

## Poner distintos colores segun se gano, perdio, mantuvo situacion de TUS
# arcpy.mapping.ListLayers(mxd, "geocoding_Layer").symbologyType == "UNIQUE_VALUES"
# arcpy.mapping.ListLayers(mxd, "geocoding_Layer").symbology.valueField = "hogarIndexTotCambios12"
# arcpy.mapping.ListLayers(mxd, "geocoding_Layer").symbology.addAllValues()

### Save map with all layers and export it to a picture
mxd.save()
arcpy.mapping.ExportToEMF(mxd, r"C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp/map_MIDES_visits.emf")

print "All country data building finished"

