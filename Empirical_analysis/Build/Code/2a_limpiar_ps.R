# La idea de este script es limpiar los archivos de programas sociales y
## pasarlos a wide

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Build.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(stringr)
library(purrr)
library(glue)

f_periodo <- function(anio, mes){
  return((anio - 2008) * 12 + mes)
}

# Limpiar y guardar datos PS 2009 ----------------------------------------------

datos_2009 <- fread(here("Input", "SIIAS/Programas_Sociales/2009_PS_enmascarado.csv"), 
                    select = c("nro_documento", "fecha_dato", 
                               "mides_jer", "mides_cercanias", "mides_ucc"))



## Crear período a partir de fecha:

table(datos_2009$fecha_dato)
fechas <- unique(datos_2009$fecha_dato)

table(str_extract(fechas, "^.{4}"))

datos_2009[, 
           ':='(anio = as.numeric(str_sub(fecha_dato, 1, 4)),
                mes  = as.numeric(str_sub(fecha_dato, 6, 7))),
           by = .(g = 1:nrow(datos_2009))]

datos_2009[,
           periodo := f_periodo(anio, mes),
           by = .(g = 1:nrow(datos_2009))]

datos_2009 <- datos_2009[periodo >= f_periodo(2013, 1),] # ene 2013 en adelante
datos_2009[periodo < f_periodo(2015, 7), # asignar NA antes de jul 2015 en ucc
           mides_ucc := NA_integer_]     # (después los vamos a eliminar)



## Limpiar y ordenar variables:

datos_2009 <- datos_2009[, !c("fecha_dato", "anio", "mes")]

setcolorder(datos_2009, c("nro_documento", "periodo"))



## Pasar a wide:

### Hay un par de documentos que no tienen los 69 períodos esperados:

datos_2009[, doc_n_periodos := .N, by = nro_documento]
datos_2009[, .N, by = doc_n_periodos]

### Los que tienen 138 son meros duplicados, al menos para las variables que
### tenemos aquí:

nrow(datos_2009[doc_n_periodos == 138]) /
  nrow(unique(datos_2009[doc_n_periodos == 138]))

### El único documento con 128 también tiene un par de duplicados (no en todos 
### los períodos):

nrow(unique(datos_2009[doc_n_periodos == 128]))

### Por tanto, simplemente podemos eliminar duplicados en la base:

datos_2009 <- unique(datos_2009)

### Ahora podemos pasar la base a wide:

datos_2009_wide <- dcast(datos_2009, nro_documento ~ periodo, 
                         value.var = c("mides_jer", "mides_cercanias", "mides_ucc"))

### Eliminar variables UCC en períodos donde no hay info (antes de jul 2015):

v_nombres_no_ucc <- str_c("mides_ucc_", f_periodo(2013, 1):f_periodo(2015, 6))

set(x = datos_2009_wide, j = v_nombres_no_ucc, value = NULL)


## Guardar csv en Temp/ps_limpio

fwrite(datos_2009_wide, 
       file = here("Temp", "ps_limpio/ps_limpio_2009.csv"))

# Función que generaliza -------------------------------------------------------

f_limpiar_ps <- function(archivo, anio_archivo){
  message(glue("Procesando {anio_archivo}"))
  datos <- fread(archivo, 
                 select = c("nro_documento", "fecha_dato", 
                            "mides_jer", "mides_cercanias", "mides_ucc"))
  
  message("--Creando variable de período")
  
  datos[, 
        ':='(anio = as.numeric(str_sub(fecha_dato, 1, 4)),
             mes  = as.numeric(str_sub(fecha_dato, 6, 7))),
        by = .(g = 1:nrow(datos))]
  
  datos[,
        periodo := f_periodo(anio, mes),
        by = .(g = 1:nrow(datos))]
  
  message("--Limpiando y ordenando base")
  
  datos <- datos[periodo >= f_periodo(2013, 1),] # solo ene 2013 en adelante
  datos[periodo < f_periodo(2015, 7), # asignar NA antes de jul 2015 en ucc
        mides_ucc := NA_integer_]     # (después los vamos a eliminar)
  
  datos <- datos[, !c("fecha_dato", "anio", "mes")]
  
  setcolorder(datos, c("nro_documento", "periodo"))
  
  message("--Eliminando duplicados (si hubiese)")
  
  datos <- unique(datos)
  
  message("--Pasando base a wide")
  
  datos_wide <- dcast(datos, nro_documento ~ periodo, 
                      value.var = c("mides_jer", "mides_cercanias", "mides_ucc"))
  
  ### Eliminar variables UCC en períodos donde no hay info (antes de jul 2015):
  
  v_nombres_no_ucc <- str_c("mides_ucc_", f_periodo(2013, 1):f_periodo(2015, 6))
  
  set(x = datos_wide, j = v_nombres_no_ucc, value = NULL)
  
  message("--Guardando archivo")
  
  fwrite(datos_wide, 
         file = here("Temp", glue("ps_limpio/ps_limpio_{anio_archivo}.csv")))
}

# Iteración para los demás años ------------------------------------------------

v_archivos <- list.files(here("Input", "SIIAS/Programas_Sociales"),
                         full.names = T)

walk2(.x = v_archivos, .y = as.character(c(2008, 2010:2018)),
      .f = f_limpiar_ps)
