# La idea de este script es generar un archivo único para las bases (limpias) de 
## políticas sociales

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(purrr)
library(glue)

# Función que carga dt y añade año del archivo:

f_fread_add_anio <- function(input, anio_archivo){
  message(glue("Cargando base año {anio_archivo}"))
  datos <- fread(input)
  datos[, anio_archivo := anio_archivo]
  return(datos)
}

# Función que carga las bases y las une:

f_fread_list <- function(archivos){
  message("Cargando bases en una lista")
  map2(.x = archivos, .y = 2008:2018, 
       .f = f_fread_add_anio)
}

# Cargar bases en una lista:

v_archivos <- list.files(here("Build", "Temp", "ps_limpio/"), 
                         full.names = T) # archivos 2008-2018

lista_ps_2008_2018 <- f_fread_list(v_archivos) # generar lista

# Escribir el archivo completo:

fwrite(lista_ps_2008_2018[[1]], 
       here("Build", "Temp", "ps_limpio/ps_limpio_completo.csv")) # 2008

walk2(.x = lista_ps_2008_2018[2:11], .y = 2009:2018, # añadir 2009-2018
      .f = ~{
        message(glue("Escribiendo {.y}"))
        fwrite(.x, here("Build", "Temp", 
                        "ps_limpio/ps_limpio_completo.csv"), append = T)
      })

walk(.x = v_archivos, .f = file.remove) # eliminar archivos temp 2008-2018 (ahorrar espacio)
