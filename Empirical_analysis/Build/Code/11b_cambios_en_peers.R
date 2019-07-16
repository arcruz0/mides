# La idea de este script es identificar los cambios en los peers de c/ hogar.

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(dplyr)
library(stringr)
library(tidyr) # versión con funciones pivot_*()
library(purrr)
library(glue)

# Cargar las primeras 100 observaciones de la base -----------------------------

df_tus_sm <- fread(file  = here("Build", "Output", "visitas_hogares_TUS.csv"),
                   nrows = 100)

# Cargar la base con la columnas que necesitamos  ------------------------------

cols <- c(1,
          grep("(^fechavisita$)|(^hogarcuantTus)|(^hogarcuantTusDoble)",   
               names(df_tus_sm)))

df_tus_cambios <- fread(here("Build", "Output", "visitas_hogares_TUS.csv"),
                        select = cols)
df_tus_cambios <- cbind(df_tus_cambios, 
                        fread(here("Build", "Output", "visitas_hogares_vars.csv"),
                              select = c("latitudGeo", "longitudGeo")))

df_tus_cambios[!is.na(latitudGeo), rowNumberGeolocalizados := .I]
df_tus_cambios[, rowNumber := .I]
df_tus_cambios <- df_tus_cambios[, !c("latitudGeo", "longitudGeo")]

# Pasar la base de wide a long con tidyr ---------------------------------------

## Specs de la base:

spec_df_tus_cambios <- pivot_longer_spec(
    data = df_tus_cambios,
    cols =  starts_with("hogarcuant"),
    names_to = "periodo"
  ) %>% 
  mutate(.value    = if_else(str_detect(.name, "hogarcuantTus\\d"), 
                             "qTus", 
                             "qTusDoble"),
         periodo   = str_extract(periodo, "\\d+") %>% as.integer())

## Hacer el cambio y volver a data table:

m_df_tus_cambios <- pivot_longer(data = df_tus_cambios, 
                                 spec = spec_df_tus_cambios)
m_df_tus_cambios <- as.data.table(m_df_tus_cambios)

## Generar los lags (diferencias con el mes anterior) en ambas variables, por
## observación:

m_df_tus_cambios[,
                 lag_qTus := c(NA_integer_, diff(qTus)), 
                 by = flowcorrelativeid]

m_df_tus_cambios[,
                 lag_qTusDoble := c(NA_integer_, diff(qTusDoble)), 
                 by = flowcorrelativeid]

# Robustez: no considerar cambios si se revierte de inmediato ------------------

# qTus:

## Generar pares:
dt_pairs_lag_qTus <- data.table(m_df_tus_cambios$lag_qTus[-length(m_df_tus_cambios$lag_qTus)], 
                                m_df_tus_cambios$lag_qTus[-1]) 

## Generar variable lógica para cuando el par sea de -1 y 1:
dt_pairs_lag_qTus[, d := (V1 == -1 & V2 == 1) | (V1 == 1 & V2 == -1)]

## Para cada serie de TRUEs, pasar el último T a F si es que la longitud de la
## serie es impar (pues esto significa que el cambio después se mantuvo):

dt_pairs_lag_qTus[, pos := rowid(rleid(d))*d]
dt_pairs_lag_qTus[, grupo := rleid(d)]
dt_pairs_lag_qTus[, pos_max_grupo := max(pos), by = grupo]

dt_pairs_lag_qTus[d == T & pos_max_grupo > 1 & pos == pos_max_grupo & pos %% 2 != 0,
                  d := F]

## Pasar dichos lags a 0:

m_df_tus_cambios_rob <- copy(m_df_tus_cambios)

m_df_tus_cambios_rob[
  sort(unique(c(which(dt_pairs_lag_qTus$d), 
                which(dt_pairs_lag_qTus$d) + 1))), 
  lag_qTus := 0]

# qTusDoble:

## Generar pares:
dt_pairs_lag_qTusDoble <- data.table(m_df_tus_cambios$lag_qTusDoble[-length(m_df_tus_cambios$lag_qTusDoble)], 
                                m_df_tus_cambios$lag_qTusDoble[-1]) 

## Generar variable lógica para cuando el par sea de -1 y 1:
dt_pairs_lag_qTusDoble[, d := (V1 == -1 & V2 == 1) | (V1 == 1 & V2 == -1)]

## Para cada serie de TRUEs, pasar el último T a F si es que la longitud de la serie
## es impar (pues esto significa que el cambio después se mantuvo):

dt_pairs_lag_qTusDoble[, pos := rowid(rleid(d))*d]
dt_pairs_lag_qTusDoble[, grupo := rleid(d)]
dt_pairs_lag_qTusDoble[, pos_max_grupo := max(pos), by = grupo]

dt_pairs_lag_qTusDoble[d == T & pos == pos_max_grupo & pos %% 2 != 0,
                       d := F]

## Pasar dichos lags a 0:

m_df_tus_cambios_rob[
  sort(unique(c(which(dt_pairs_lag_qTusDoble$d), 
                which(dt_pairs_lag_qTusDoble$d) + 1))), 
  lag_qTusDoble := 0]

## Comprobar trayectoria de obs n° 7:
View(m_df_tus_cambios[rowNumber == 7,])
View(m_df_tus_cambios_rob[rowNumber == 7,])



# Procedimiento para un caso ---------------------------------------------------

## Función que registra los cambios de los vecinos en cierto período 
## (ganancias o pérdidas, nivel hogares o tarjetas):

f_qCambios <- function(x, direccion, cantidad_de){
  if (length(x) == sum(is.na(x))) {
    return(NA_integer_)
  }
  
  if (cantidad_de == "hogares"){
    x <- case_when(
      x > 0 ~ 1, x < 0 ~ -1, x == 0 ~ 0
    )
  }
  
  if (direccion == "ganancias"){
    x <- x[x > 0]
  } else if (direccion == "perdidas"){
    x <- x[x < 0]
  }
  as.integer(abs(sum(x, na.rm = T)))
}

## Testeo de la función:

v_ej <- c(2, 1, -2) # este serían los cambios de 3 vecinos en un período dado

f_qCambios(v_ej, direccion = "ganancias", cantidad_de = "hogares")  # 2
f_qCambios(v_ej, direccion = "ganancias", cantidad_de = "tarjetas") # 3
f_qCambios(v_ej, direccion = "perdidas", cantidad_de = "hogares")   # 1
f_qCambios(v_ej, direccion = "perdidas", cantidad_de = "tarjetas")  # 2

## La función no tendrá problemas con el primer período (que tiene solo NAs en cambios):

f_qCambios(c(NA, NA, NA), direccion = "perdidas", cantidad_de = "tarjetas") # NA


## Utilicemos esto para la observación n°1 de las geolocalizadas, con los vecinos
## siendo los cinco hogares más cercanos:

## Cargar vecinos:

vecinos_5n <- readr::read_rds(here("Build", "Temp", "11a_vecinos_5n.rds"))

vecinos_obs1_5n <- vecinos_5n[[1]]

## Aplicar la función antes creada:

df_vecinos_obs1_5n <- m_df_tus_cambios[rowNumberGeolocalizados %in% vecinos_obs1_5n,]

res_q_obs1_5n <- df_vecinos_obs1_5n[
  , 
  .(vec_sum_qTus                  = sum(qTus, na.rm = T), 
    vec_sum_qTusDoble             = sum(qTusDoble, na.rm = T),
    vec_qGanaronTus               = f_qCambios(lag_qTus, "ganancias", "hogares"),
    vec_qPerdieronTus             = f_qCambios(lag_qTus, "perdidas", "hogares"),
    vec_qTarjetasGanadasTus       = f_qCambios(lag_qTus, "ganancias", "tarjetas"),
    vec_qTarjetasPerdidasTus      = f_qCambios(lag_qTus, "perdidas", "tarjetas"),
    vec_qGanaronTusDoble          = f_qCambios(lag_qTusDoble, "ganancias", "hogares"),
    vec_qPerdieronTusDoble        = f_qCambios(lag_qTusDoble, "perdidas", "hogares"),
    vec_qTarjetasGanadasTusDoble  = f_qCambios(lag_qTusDoble, "ganancias", "tarjetas"),
    vec_qTarjetasPerdidasTusDoble = f_qCambios(lag_qTusDoble, "perdidas", "tarjetas")
    ),
  by = periodo]

res_q_obs1_5n[, rowNumberGeolocalizados := 1]
setcolorder(res_q_obs1_5n, c("rowNumberGeolocalizados", "periodo"))

head(res_q_obs1_5n) # tenemos la base en formato long, unidad de análisis: obs-período

## Pasemos esto a formato wide:

tipo_vecino <- "5n"
q_vecinos <- 5L


m_res_q_obs1_5n <- dcast(
  data      = res_q_obs1_5n, 
  formula   = rowNumberGeolocalizados ~ periodo, 
  value.var = str_subset(names(res_q_obs1_5n), "^vec_")
  )

setnames(m_res_q_obs1_5n,
         old = names(m_res_q_obs1_5n),
         new = str_replace(names(m_res_q_obs1_5n), "vec_", glue("vec{tipo_vecino}_")))


m_res_q_obs1_5n[[glue("vec{tipo_vecino}_qVecinos")]] <- q_vecinos

setcolorder(m_res_q_obs1_5n, c("rowNumberGeolocalizados", 
                               glue("vec{tipo_vecino}_qVecinos")))


# Utilización de este procedimiento para toda la base --------------------------

## Función que hace todo lo anterior para una observación dada y un tipo de 
## vecino dado (con o sin robustez):

v_periodos <- unique(m_df_tus_cambios$periodo)

f_sum_na_if_full_na <- function(x, ...){
  if (sum(is.na(x)) == length(x)){
    return(NA)
  }
  sum(x, ...)
}

f_calc_cambios_en_vecinos <- function(rown_geo, obj_vecinos, rob = F){
  vecinos <- obj_vecinos[[rown_geo]]
  
  tipo_vecino <- deparse(substitute(obj_vecinos)) %>% str_remove("vecinos_")
  q_vecinos <- length(vecinos)
  
  if (q_vecinos == 0){
    df_vecinos_obs <- data.table(periodo = v_periodos)
    
    df_vecinos_obs[, 
                   ':='(flowcorrelativeid = NA_character_, fechavisita = NA_character_,
                        rowNumberGeolocalizados = NA_integer_, rowNumber = NA_integer_, 
                        qTus = NA_integer_, qTusDoble = NA_integer_,
                        lag_qTus = NA_integer_, lag_qTusDoble = NA_integer_)]
  } else {
    # obtener datos de vecinos
    if (rob == T){
      df_vecinos_obs <- m_df_tus_cambios_rob[rowNumberGeolocalizados %in% vecinos,]
    } else {
      df_vecinos_obs <- m_df_tus_cambios[rowNumberGeolocalizados %in% vecinos,]
    }
  }
  
  # Cálculos de agregación para los vecinos
  
  res_vecinos_obs <- df_vecinos_obs[
    , 
    .(vec_sum_qTus                  = f_sum_na_if_full_na(qTus, na.rm = T), 
      vec_sum_qTusDoble             = f_sum_na_if_full_na(qTusDoble, na.rm = T),
      vec_qGanaronTus               = f_qCambios(lag_qTus, "ganancias", "hogares"),
      vec_qPerdieronTus             = f_qCambios(lag_qTus, "perdidas", "hogares"),
      vec_qTarjetasGanadasTus       = f_qCambios(lag_qTus, "ganancias", "tarjetas"),
      vec_qTarjetasPerdidasTus      = f_qCambios(lag_qTus, "perdidas", "tarjetas"),
      vec_qGanaronTusDoble          = f_qCambios(lag_qTusDoble, "ganancias", "hogares"),
      vec_qPerdieronTusDoble        = f_qCambios(lag_qTusDoble, "perdidas", "hogares"),
      vec_qTarjetasGanadasTusDoble  = f_qCambios(lag_qTusDoble, "ganancias", "tarjetas"),
      vec_qTarjetasPerdidasTusDoble = f_qCambios(lag_qTusDoble, "perdidas", "tarjetas")
    ),
    by = periodo]
  
  res_vecinos_obs[, rowNumberGeolocalizados := rown_geo]
  setcolorder(res_vecinos_obs, c("rowNumberGeolocalizados", "periodo"))
  
  # A wide:
  
  m_res_vecinos_obs <- dcast(res_vecinos_obs, rowNumberGeolocalizados ~ periodo, 
                             value.var = str_subset(names(res_vecinos_obs), "^vec_"))
  
  setnames(m_res_vecinos_obs,
           old = names(m_res_vecinos_obs),
           new = str_replace(names(m_res_vecinos_obs), "vec_", glue("vec{tipo_vecino}_")))
  
  # Añadir n de vecinos y poner como 2da columna:
  
  m_res_vecinos_obs[[glue("vec{tipo_vecino}_qVecinos")]] <- q_vecinos
  
  setcolorder(m_res_vecinos_obs, c("rowNumberGeolocalizados", 
                                   glue("vec{tipo_vecino}_qVecinos")))
  
  return(m_res_vecinos_obs)
}


# Procesamiento: a distribuir en los servidores --------------------------------

## Vecinos 100m

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_100m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_100m.rds"))

## Vecinos 100m (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_100m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_100m_rob.rds"))



## Vecinos 250m

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_250m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_250m.rds"))

## Vecinos 250m (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_250m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_250m_rob.rds"))



## Vecinos 500m

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_500m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_500m.rds"))

## Vecinos 500m (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_500m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_500m_rob.rds"))




## Vecinos 1000m

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_1000m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_1000m.rds"))

## Vecinos 1000m (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_1000m.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_1000m_rob.rds"))



## Vecinos 5n

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_5n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_5n.rds"))

## Vecinos 5n (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_5n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_5n_rob.rds"))



## Vecinos 8n

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_8n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_8n.rds"))

## Vecinos 8n (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_8n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_8n_rob.rds"))



## Vecinos 12n

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_12n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = F))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_12n.rds"))

## Vecinos 12n (robusto)

vecinos <- readr::read_rds(here("Build", "Temp", "11a_vecinos_12n.rds"))

names_df <- names(f_calc_cambios_en_vecinos(1, vecinos))

l_obj <- length(vecinos)

df_procesado <- data.table(matrix(rep(NA_integer_, l_obj * 1002), 
                                  nrow = l_obj, ncol = 1002))

for (i in 1:l_obj){
  set(df_procesado, i = i, j = 1:1002,
      value = f_calc_cambios_en_vecinos(i, vecinos, rob = T))
}
setnames(df_procesado, old = names(df_procesado), new = names_df)

readr::write_rds(df_procesado, here("Build", "Temp", "11b_cambios_peers_12n_rob.rds"))