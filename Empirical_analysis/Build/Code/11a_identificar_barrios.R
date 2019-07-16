# La idea de este script es identificar los vecinos geográficos en la base,
## de acuerdo a criterios de radio (100, 250, 500 y 1000m) y k-vecinos
## (5, 8 y 12).

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table)
setDTthreads(threads = 4)
library(stringr)
library(purrr)
library(ggplot2)
library(sf)
library(nngeo) # vecinos k-nearest


# Cargar base de hogares -------------------------------------------------------

df_h_sm <- fread(file   = here("Build", "Output", "visitas_hogares_vars.csv"),
                 nrows  = 100)

df_h <- fread(file = here("Build", "Output", "visitas_hogares_vars.csv"),
              select = c("flowcorrelativeid", "latitud",
                         "longitud", "asistente_de_campo_nom_id",
                         "supervisor_ced_id",
                         "direccionnombre", "direccionnumero"))

# Cargar base de hogares TUS ---------------------------------------------------

df_tus_sm <- fread(file  = here("Build", "Output", "visitas_hogares_TUS.csv"),
                   nrows = 100)

df_tus <- fread(file   = here("Build", "Output", "visitas_hogares_TUS.csv"),
                select = c("flowcorrelativeid", 
                           "departamento", "localidad",
                           "latitudGeo", "longitudGeo", "fechavisita",
                           "template"))




# Crear base para encontrar barrios --------------------------------------------

df_para_barrios <- cbind(df_tus, df_h[, .(asistente_de_campo_nom_id,
                                          supervisor_ced_id,
                                          direccionnombre,
                                          direccionnumero)])

## Cuando la columna "template" esté vacía, pasar a NA: 

df_para_barrios[str_detect(template, "^$"), template := NA_character_] # edita

df_para_barrios[, .N, by = template] # resumen

## Añadir columna con número de fila (rowNumber):

df_para_barrios[, rowNumber := .I] # edita
setcolorder(df_para_barrios, c(12, 1:11)) # edita



# Vecinos según radios de distancias -----------------------------------------------------

df_geolocalizados <- df_para_barrios[!is.na(longitudGeo) & !is.na(latitudGeo),]

df_geolocalizados[, rowNumberGeolocalizados := .I]

## Objeto sf sin proyectar:

sf_geolocalizados_sinp <- st_as_sf(df_geolocalizados[, .(rowNumberGeolocalizados,
                                                         rowNumber, 
                                                         longitudGeo,
                                                         latitudGeo)], 
                                   coords = c("longitudGeo", "latitudGeo"), 
                                   crs = 4326)

## Objeto sf según la proyección de Uruguay:

sf_geolocalizados <- sf_geolocalizados_sinp %>% 
  # https://www.gub.uy/infraestructura-datos-espaciales/sites/infraestructura-datos-espaciales/files/2019-04/Sistema_Referencia_Proyecciones.pdf
  st_transform(5382)

## Círculos de X metros de radio:

buffer_100m <- st_buffer(sf_geolocalizados, 100)
buffer_250m <- st_buffer(sf_geolocalizados, 250) 
buffer_500m <- st_buffer(sf_geolocalizados, 500) 
buffer_1000m <- st_buffer(sf_geolocalizados, 1000) 

## Puntos que caen en c/ círculo:

vecinos_100m  <- st_intersects(buffer_100m,
                               sf_geolocalizados)

vecinos_250m  <- st_intersects(buffer_250m, 
                               sf_geolocalizados)

vecinos_500m  <- st_intersects(buffer_500m, 
                               sf_geolocalizados)

vecinos_1000m <- st_intersects(buffer_1000m,
                               sf_geolocalizados)

## Tienen sentido los vecinos que tiene c/ hogar, según la especificación de mts:

length(vecinos_100m[[1]])
length(vecinos_250m[[1]])
length(vecinos_500m[[1]])
length(vecinos_1000m[[1]])

## Hay algo pendiente, que es eliminar, para c/ hogar, la idea de que es vecino
## de sí mismo. Aquí va:

vecinos_100m <- map2(
  .x = vecinos_100m, .y = 1:length(vecinos_100m),
  .f = ~ .x[!.x %in% .y]
)

vecinos_250m <- map2(
  .x = vecinos_250m, .y = 1:length(vecinos_250m),
  .f = ~ .x[!.x %in% .y]
)

vecinos_500m <- map2(
  .x = vecinos_500m, .y = 1:length(vecinos_500m),
  .f = ~ .x[!.x %in% .y]
)

vecinos_1000m <- map2(
  .x = vecinos_1000m, .y = 1:length(vecinos_1000m),
  .f = ~ .x[!.x %in% .y]
)

## Guardar estos vecinos temporalmente:

readr::write_rds(vecinos_100m, here("Build", "Temp", "11a_vecinos_100m.rds"))
readr::write_rds(vecinos_250m, here("Build", "Temp", "11a_vecinos_250m.rds"))
readr::write_rds(vecinos_500m, here("Build", "Temp", "11a_vecinos_500m.rds"))
readr::write_rds(vecinos_1000m, here("Build", "Temp", "11a_vecinos_1000m.rds"))

rm(list = ls(pattern = "vecinos_\\d+m"))



# Vecinos según k-nearest ------------------------------------------------------

## Las ids que quedarán son el número de fila en "sf_geolocalizados"

vecinos_5n <- st_nn(sf_geolocalizados, 
                    sf_geolocalizados, 
                    k = 6) %>% 
  # eliminar "vecino de sí mismo":
  map2(
    .x = ., .y = 1:length(.),
    .f = ~ .x[!.x %in% .y]
  )

vecinos_8n <- st_nn(sf_geolocalizados, 
                    sf_geolocalizados, 
                    k = 9) %>% 
  # eliminar "vecino de sí mismo":
  map2(
    .x = ., .y = 1:length(.),
    .f = ~ .x[!.x %in% .y]
  )

vecinos_12n <- st_nn(sf_geolocalizados, 
                     sf_geolocalizados, 
                     k = 13) %>% 
  # eliminar "vecino de sí mismo":
  map2(
    .x = ., .y = 1:length(.),
    .f = ~ .x[!.x %in% .y]
  )

readr::write_rds(vecinos_5n, here("Build", "Temp", "11a_vecinos_5n.rds"))
readr::write_rds(vecinos_8n, here("Build", "Temp", "11a_vecinos_8n.rds"))
readr::write_rds(vecinos_12n, here("Build", "Temp", "11a_vecinos_12n.rds"))

rm(list = ls(pattern = "vecinos_\\d+n"))



# Barrios censales -------------------------------------------------------------

df_visitados <- df_para_barrios[template == "Censo", 
                                !c("latitudGeo", "longitudGeo", "template")]

## Clasificación a: mismo dep, fecha de visita y supervisor

barrios_censales_a <- df_visitados[!is.na(supervisor_ced_id), .N,
                                   by = c("departamento",
                                          "fechavisita", "supervisor_ced_id")]
barrios_censales_a[, v_barrios_censales_a := .I]

( total_barrios_a <- barrios_censales_a[, .N] )

( p_clas_a <- ggplot(barrios_censales_a, aes(x = N)) +
  geom_bar() +
  labs(x = "Número de hogares en el barrio", y = "Barrios",
       title = "Distribución de número de hogares en los barrios",
       subtitle = "(barrios según clasificación a)",
       caption = glue::glue("Total de barrios: {total_barrios_a}")) )

ggsave(plot = p_clas_a, filename = "figs/fig_clas_a.png",
       height = 6, width = 8)