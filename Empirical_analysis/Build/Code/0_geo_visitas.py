import pandas as pd
import os, shutil, subprocess, sys
import numpy as np
import math

## Set path
try: os.chdir(r'C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp')
except: pass
try: os.chdir(r'/home/andres/google-drive/mides/Empirical_analysis/Build/Temp')
except: pass


## Cargo base de datos visitas y de datos geos enviados por Guillermo del MIDES
datosGeo = pd.read_csv('..\Input\pedido_lihuen\producto_1_enmascarado.csv', sep=';')    
datosGeo = datosGeo.rename(columns={'latitud': 'latitudGeo', 'longitud': 'longitudGeo'}).drop(columns=['flowid'])

for i in range(datosGeo.shape[0]):
    datosGeo['latitudGeo'][i] = datosGeo['latitudGeo'][i].replace(',', '.')
    datosGeo['longitudGeo'][i] = datosGeo['longitudGeo'][i].replace(',', '.')
    print(str(i) + ' in ' + str(datosGeo.shape[0]))

datosGeo['latitudGeo'] = datosGeo['latitudGeo'].astype(float)
datosGeo['longitudGeo'] = datosGeo['longitudGeo'].astype(float)

localidadesINE = pd.read_excel('..\Input\Tabla de Localidades Censales año 2011.xlsx')
departamentos = pd.DataFrame({'departamento':[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],
                              'nomDpto':['MONTEVIDEO','ARTIGAS', 'CANELONES', 'CERRO LARGO', 'COLONIA', 'DURAZNO',
                                         'FLORES', 'FLORIDA', 'LAVALLEJA', 'MALDONADO', 'PAYSANDU', 'RIO NEGRO', 'RIVERA',
                                         'ROCHA','SALTO', 'SAN JOSE', 'SORIANO', 'TACUAREMBO','TREINTA Y TRES']})

datosGeoVisitas = pd.read_csv('..\Input\Visitas_Hogares_Muestra_enmascarado.csv', encoding='latin_1').filter(items=['flowcorrelativeid', 'template', 
                             'codigo_geo','x', 'y','departamento', 'localidad', 'direccionnombre','direccionnumero',
                             'bis', 'apto','entrecalles1', 'entrecalles2', 'manzana', 'solar',
                             'torre','bloque', 'codigopostal','seccionjudicial', 'padron',
                             'complejohabitacional', 'direccionkm','observaciones',
                             'fecha_visita', 'fechavisita', 'origen', 'icc', 'motivo',
                             'idprograma', 'asistente_de_campo_ced_id', 'asistente_de_campo_nom_id',
                             'latitudoriginal', 'longitudoriginal', 'latitud', 'longitud'])

## Merge datos geo que pasó Guillermo en base de visitas
datosGeoMerged = datosGeoVisitas.merge(datosGeo, how='left', on='flowcorrelativeid', validate='one_to_one')

# Variable calidadGeo es: 1= Geo data pasada por Guillermo del MIDES, 0 = ROOFTOP, -1 = RANGE_INTERPOLATED, -2 = GEOMETRIC_CENTER, -3 = APPROXIMATE, -99 = sin dato
datosGeoMerged['calidadGeo'] = -99
datosGeoMerged['calidadGeo'] = datosGeoMerged['calidadGeo'].mask(datosGeoMerged['latitudGeo'].notna(), 1)

## Añado nombre de localidad en base a tablas del INE y variable "localidad" de la base de visitas MIDES
datosGeoMerged = datosGeoMerged.merge(localidadesINE.filter(['NOMBRE_LOC','CODLOC']), how='left', left_on='localidad', right_on='CODLOC')

## Añado nombre de departamento
datosGeoMerged = datosGeoMerged.merge(departamentos, how='left', left_on='departamento', right_on='departamento')

## Me quedo con flowcorrelativeid para los que precisamos direcciones (son 70.378)
datosSinGeo = datosGeoMerged[datosGeoMerged['latitudGeo'].isna()==True]

## Pongo flowcorrelativeid para los que precisamos direcciones en el formato necesario: 6 columns: ID, address, city, state, postal code, country 
datosParaGeo = pd.DataFrame({'ID': datosSinGeo['flowcorrelativeid'], 'address': datosSinGeo['direccionnumero'].astype('str') + ' ' + datosSinGeo['direccionnombre'], 'city': datosSinGeo['NOMBRE_LOC'], 'state': datosSinGeo['nomDpto'], 'postal code': datosSinGeo['codigopostal']}).reset_index().drop(columns=['index'])
datosParaGeo['country'] = ['uruguay' for i in range(datosParaGeo.shape[0])]
datosParaGeo['postal code'] = datosParaGeo['postal code'].astype(str)

for i in range(datosParaGeo.shape[0]):
    if datosParaGeo['postal code'][i] == '0.0':
       datosParaGeo['postal code'][i] = ''
    datosParaGeo['postal code'][i] = datosParaGeo['postal code'][i].replace('.0', '')
    if isinstance(datosParaGeo['address'][i], float) == True: 
        datosParaGeo['address'][i] = ''
    elif isinstance(datosParaGeo['address'][i], str) == True: 
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('nan ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('s/n ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('S/N ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('SN ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('S/NRO. ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace(' PASAJE AL FONDO ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace(' AL FONDO ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace(' al fondo ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace(' ATRAS ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace(' ARRIBA ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('AL FONDO ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('al fondo ', '')
        datosParaGeo['address'][i] = datosParaGeo['address'][i].replace('.0', '')
    print('Counter: ' + str(i) + ' of ' + str(datosParaGeo.shape[0]-1))


datosParaGeo.to_csv('addresses_visitas_raw.txt', header=False, index=None, sep='\t')

## Base con resumen de datos geo disponibles
resultadoGeo = pd.Series({'Visitas Totales': datosGeoVisitas.shape[0], 'Visitas con geo de Guillermo': datosGeoMerged.count()['latitud']})


#Program by Fei Carnes, 2016-2018
#Last updated by Wendy Guan, 10/4/2018
step = 0
import sys, urllib, base64, hashlib, hmac, json, unicodedata, time
import urllib.parse
import urllib.request

#This script uses the Google Maps for work geocoding service, allowing for geocoding up to 100,000 addresses per day.
#It works with Python version 3
#Setup:  1)Save this script into the same folder your input addresses are in.
#        2)Format your input addresses into a tab-delimited text file without headers with 6 columns: ID, address, city, state, postal code, country.
#        3)Change "google_geocoding_sample.txt" below to the name of your input file name.
inputfile = r"addresses_visitas_raw.txt"
#        4)Open a command prompt, and change directories into the folder where this file is.  At the command
#        prompt, type in:  google_geocoding_for_work_python_3.py  The script will run, geocoding each input address, and
#        outputting the results into a file named "google_geocoding_output.txt".
#        Updated by Jeff Blossom, 5/23/2016
#        Updated by Devika Kakkar, 8/11/2016
outputfile = r"google_geocoding_output.txt"

google_url = "https://maps.googleapis.com"
geocoding_endpoint = "/maps/api/geocode/json?"
key = "AIzaSyDn8sOeCvdJL-e31EN5xHEpnbiQDdvAuJ0"

#to get an API key visit https://gis.harvard.edu/Google-Maps-API-Premium 
channel = ""

field1 = "ID"
field2 = "In_Address"
field3 = "In_City"
field4 = "In_State"
field4a = "In_postal_code"
field5 = "In_Country"
field6 = "Address_Matched"
field7 = "City_Matched"
field8 = "State_Matched"
field8a = "Postal_Code_Matched"
field9 = "Country_Matched"
field10 = "Location_Type"
field11 = "Latitude"
field12 = "Longitude"


f_in = open(inputfile, 'r')
f_out = open(outputfile, 'w')
f_out.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (field1, field2, field3, field4, field4a, field5, field6, field7, field8, field8a, field9, field10, field11, field12))
for line in f_in:
   fields = line.strip().replace("\"", "").split('\t')
   address = "%s+%s,%s,%s,%s" % (fields[2], fields[1], fields[3], fields[4],fields[5])
   address = address.replace("n/a", "").replace(" ", "+")
   values = { }
   values['address'] = address
   data= urllib.parse.urlencode(values)
   #Generate valid signature
   encodedParams = data
   #decode the private key into its binary format
   signedurl = google_url + geocoding_endpoint + encodedParams + "&key=" + key
   response = urllib.request.urlopen(signedurl)
   the_page = response.read()
   response.close
   json_str = the_page.decode()
   data_json = json.loads(json_str)
   city_name = "N/A"
   admin1 = "N/A"
   country = "N/A"
   streetNum = "N/A"
   street = "N/A"
   postal_code = "N/A"
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "locality" in component["types"]:
            city_name = component["long_name"]
      if city_name != "N/A":
         break
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "administrative_area_level_1" in component["types"]:
            admin1 = component["long_name"]
      if admin1 != "N/A":
         break
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "postal_code" in component["types"]:
            postal_code = component["long_name"]
      if postal_code!= "N/A":
         break
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "country" in component["types"]:
            country = component["long_name"]
      if country != "N/A":
         break
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "street_number" in component["types"]:
            streetNum = component["long_name"]
      if streetNum != "N/A":
         break
   for i in range(len(data_json["results"])):
      for component in data_json["results"][i]["address_components"]:
         if "route" in component["types"]:
            street = component["long_name"]
      if street != "N/A":
         break
   p_city = city_name
   p_admin1 = admin1
   p_country = country
   p_address = streetNum + " " + street
   p_postal_code = postal_code
 #  print("City_matched", p_city, "state matched", p_admin1, "Country matched", p_country, "Address matched", p_address, "Postal code matched", p_postal_code) 
   step = step + 1
   print("Processing" + "  " + "ID "+ fields[0] + ' step ' + str(step))
   try:
      f_out.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], p_address, p_city, p_admin1 , p_postal_code, p_country, data_json["results"][0]["geometry"]["location_type"], data_json["results"][0]["geometry"]["location"]["lat"], data_json["results"][0]["geometry"]["location"]["lng"]))
   #except: continue
   except: f_out.write("%s\t%s\t%s\t%s\t%s\t%s\n" % (fields[0], fields[1], fields[2], fields[3], fields[4], "not found"))
   time.sleep(.4)
   #print data.read()

print ("Finished geocoding")
f_out.flush()
f_in.close()
f_out.close()


## Cargo direcciones obtenidas via Google
geoGoogle = pd.read_table('google_geocoding_output.txt')
geoGoogle = geoGoogle.rename(columns={'latitude': 'latitudGeo', 'longitude': 'longitudGeo'])

datosGeoMerged = datosGeoMerged.merge(geoGoogle, left_on = 'flowcorrelativeid', right_on='flowcorrelativeid', how='right', validate='1:1')

# Corrigo variable calidadGeo: 1= Geo data pasada por Guillermo del MIDES, 0 = ROOFTOP, -1 = RANGE_INTERPOLATED, -2 = GEOMETRIC_CENTER, -3 = APPROXIMATE, -99 = sin dato
datosGeoMerged['calidadGeo'] = datosGeoMerged['calidadGeo'].mask(datosGeoMerged['location_type']=='ROOFTOP', 0)
datosGeoMerged['calidadGeo'] = datosGeoMerged['calidadGeo'].mask(datosGeoMerged['location_type']=='RANGE_INTERPOLATED', -1)
datosGeoMerged['calidadGeo'] = datosGeoMerged['calidadGeo'].mask(datosGeoMerged['location_type']=='GEOMETRIC_CENTER', -2)
datosGeoMerged['calidadGeo'] = datosGeoMerged['calidadGeo'].mask(datosGeoMerged['location_type']=='APPROXIMATE', -3)

## Exporto archivo con flowcorrelativeid, latitud/longitud, nombre departamento, nombre localidad, calidad de latitud/longitud
datosParaExport = datosGeoMerged.filter(items=['flowcorrelativeid', 'latitudGeo', 'longitudGeo', 'NOMBRE_LOC', 'nomDpto', 'calidadGeo']).rename(columns={'NOMBRE_LOC': 'nomLoc'})
datosParaExport.to_csv('geo_visitas.csv', header=True, index=None, sep='\t')
subprocess.call(["C:\Program Files (x86)\Stata15\StataMP-64.exe", "do", r"C:\Alejandro\Research\Commodities_in_LAC\Empirical_analysis\Build\Code\arcgis_build2.do"])
subprocess.call(["C:\Program Files (x86)\Stata15\StataMP-64.exe", "gen a = 1"])

## Actualizo base con resumen de datos geo disponibles
resultadoGeo['Datos geo obtenidos via google'] = geoGoogle[(geoGoogle['Latitude'].isna()==False) & (geoGoogle['Longitude'].isna()==False)]
resultadoGeo['Visitas Tot sin datos Geo MIDES'] = resultadoGeo['Visitas Totales'] - resultadoGeo['Visitas con geo de Guillermo']
resultadoGeo['Visitas Tot sin datos Geo MIDES ni Google'] = resultadoGeo['Visitas Totales'] - resultadoGeo['Visitas con geo de Guillermo'] - resultadoGeo['Datos geo obtenidos via google']


