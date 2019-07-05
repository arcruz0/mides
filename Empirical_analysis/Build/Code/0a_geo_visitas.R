# La idea de este script es armar un archivo con flowcorrelativeid, 
## latitud/longitud y departamento (entre otras variables) en base a datos 
## proporcionados por el departamento Geo del MIDES 

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Build.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(stringr)

# Cargo base de datos visitas

datosGeo <- fread(here("Input", "pedido_lihuen/producto_1_enmascarado.csv"), 
                  dec = ",") # interpreta "," como el separador decimal

setnames(datosGeo, c("latitud", "longitud"), c("latitudGeo", "longitudGeo"))
datosGeo[, flowid := NULL]

# Cargo/genero datos para localidades/departamentos

localidades_ine <- foreign::read.dbf(
  here("Input", "Tabla_de_Localidades_Censales_año_2011.dbf")
) %>% 
  as.data.table()
localidades_ine <- localidades_ine[, list(NOMBRE_LOC, CODLOC)]

departamentos <- data.table(
  departamento = 1:19,
  nomDpto = c('MONTEVIDEO','ARTIGAS', 'CANELONES', 'CERRO LARGO', 'COLONIA', 
              'DURAZNO', 'FLORES', 'FLORIDA', 'LAVALLEJA', 'MALDONADO', 
              'PAYSANDU', 'RIO NEGRO', 'RIVERA', 'ROCHA','SALTO', 'SAN JOSE', 
              'SORIANO', 'TACUAREMBO','TREINTA Y TRES')
)

# Cargo datos geos enviados por Guillermo del MIDES

datosGeoVisitas <- fread(
  here("Input", "Visitas_Hogares_Muestra_enmascarado.csv"),
  select = c('flowcorrelativeid', 'template', 'codigo_geo','x', 'y',
             'departamento', 'localidad', 'direccionnombre','direccionnumero',
             'bis', 'apto','entrecalles1', 'entrecalles2', 'manzana', 'solar',
             'torre','bloque', 'codigopostal','seccionjudicial', 'padron',
             'complejohabitacional', 'direccionkm','observaciones',
             'fecha_visita', 'fechavisita', 'origen', 'icc', 'motivo',
             'idprograma', 'asistente_de_campo_ced_id', 
             'asistente_de_campo_nom_id',
             'latitudoriginal', 'longitudoriginal', 'latitud', 'longitud')
)


# Merge datos geo que pasó Guillermo en base de visitas

datosGeoMerged <- datosGeo[datosGeoVisitas, on = "flowcorrelativeid"]

# Añado nombre de localidad en base a tablas del INE y variable "localidad" 
## de la base de visitas MIDES

datosGeoMerged <- merge(datosGeoMerged, localidades_ine, all.x = T, 
                        by.x = "localidad", by.y = "CODLOC")

# Añado nombre de departamento

datosGeoMerged <- merge(datosGeoMerged, departamentos, all.x = T,
                        by = "departamento")

# Guardo base temporalmente

fwrite(datosGeoMerged, here("Temp", "0a_datos_geo_visitas.csv"))
