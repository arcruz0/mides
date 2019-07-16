# La idea de este script es limpiar la geolocalización de Google Maps,
## asignando la calidad y eliminando los puntos que no correspondan a Uruguay

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(purrr)
library(tibble)
library(readr)
library(sf)
library(ggplot2)
library(rnaturalearth)
library(dplyr)

# Cargar archivos creados en scripts anteriores:

gc_lista <- read_rds(here("Build", "Temp", "0b_gc_lista.rds"))

df_queries <- read_rds(here("Build", "Temp", "0b_df_por_geolocalizar2.rds"))


# Integrar los datos de la lista al data frame con los queries -----------------

# Reciclado de la forma que tiene por debajo ggmap para pasar de la lista al df
# (https://github.com/dkahle/ggmap/blob/master/R/geocode.R)
NULLtoNA <- function (x) {
  if (is.null(x)) return(NA) else x
}

f_gc_a_df <- function(geo_result){
  null_tibble <- tibble(
    lon = NA, lat = NA, type = NA, loctype = NA, north = NA, south = NA,
    east = NA, west = NA
  )
  
  if (length(geo_result) == 1){
    if (geo_result == "NULL_EN_FUNCION"){
      return(null_tibble)
    }
  }
  
  if (sum(dim(geo_result)) == 3){
    return(null_tibble)
  }
  
  g <- geo_result$results[[1]]
  with(g, {
    tibble(
      "lon" = NULLtoNA(geometry$location$lng),
      "lat" = NULLtoNA(geometry$location$lat),
      "type" = tolower(NULLtoNA(types[1])),
      "loctype" = tolower(NULLtoNA(geometry$location_type)),
      "north" = NULLtoNA(geometry$viewport$northeast$lat),
      "south" = NULLtoNA(geometry$viewport$southwest$lat),
      "east" = NULLtoNA(geometry$viewport$northeast$lng),
      "west" = NULLtoNA(geometry$viewport$southwest$lng)
    )
  })
}

df_gc <- map2_dfr(gc_lista, 1:length(gc_lista), 
                  ~ {
                    message(glue::glue("{.y}/{length(gc_lista)}"))
                    f_gc_a_df(.x) 
                  }) %>% 
  as.data.table()

df_queries_con_gc <- cbind(df_queries, df_gc)


# Fijarse que los puntos entren en Uruguay -------------------------------------

# Cargar shape de Uruguay:

sf_uruguay <- ne_countries(country = "Uruguay", returnclass = "sf")  %>% 
  # https://www.gub.uy/infraestructura-datos-espaciales/sites/infraestructura-datos-espaciales/files/2019-04/Sistema_Referencia_Proyecciones.pdf
  st_transform(5382)

# Pasar las direcciones a un objeto geográfico sf (simple features):

sf_direcciones <- st_as_sf(df_queries_con_gc[!is.na(lon) & !is.na(lat),], 
                           coords = c("lon", "lat"), 
                           crs = 4326, agr = "constant", remove = F)  %>% 
  # https://www.gub.uy/infraestructura-datos-espaciales/sites/infraestructura-datos-espaciales/files/2019-04/Sistema_Referencia_Proyecciones.pdf
  st_transform(5382)

# Crear las intersecciones en una variable dummy:

sf_direcciones$d_uruguay <- st_is_within_distance(sf_uruguay, sf_direcciones, 
                                                  sparse = F, dist = 10000) %>% 
  as.vector() %>% 
  as.integer()

# Filtrar para solo quedarnos con las que caen en Uruguay.

df_gc_limpio <- sf_direcciones %>% 
  filter(d_uruguay == 1) %>% 
  # perder la clase de sf
  as.data.table() %>% 
  # solo tener variables de interés
  select(flowcorrelativeid, lon_gmaps = lon, lat_gmaps = lat, 
         gmaps_query, type, loctype)

# Guardar archivo temporal

write_rds(df_gc_limpio, here("Build", "Temp", "0c_df_gc_limpio.rds"))
