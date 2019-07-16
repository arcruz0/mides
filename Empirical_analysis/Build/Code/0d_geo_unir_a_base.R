# La idea de este script es unir las geolocalizaciones que vienen del MIDES
## con las generadas con Google Maps

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(readr)
library(dplyr)

# Cargar base con geolocalizaciones originales ---------------------------------

df_tus <- fread(file   = here("Build", "Temp", "0a_datos_geo_visitas.csv"),
                select = c("flowcorrelativeid", "latitudGeo", "longitudGeo",
                           "nomDpto", "NOMBRE_LOC"))
setnames(df_tus, "NOMBRE_LOC", "nomLoc")

# Cargar base con geocoding de Google ------------------------------------------

df_gc_limpio <- read_rds(here("Build", "Temp", "0c_df_gc_limpio.rds"))

# calidadGeo: 
#  1  = Geo data pasada por Guillermo del MIDES, 
#  0  = ROOFTOP, 
# -1  = RANGE_INTERPOLATED, 
# -2  = GEOMETRIC_CENTER,
# -3  = APPROXIMATE,
# -99 = Sin dato

df_gc_limpio2 <- df_gc_limpio %>% 
  mutate(calidadGeo = case_when(
    loctype == "approximate"        ~ -3L,
    loctype == "geometric_center"   ~ -2L,
    loctype == "range_interpolated" ~ -1L,
    loctype == "rooftop"            ~  0L,
    TRUE ~ NA_integer_
  )) %>% 
  select(-gmaps_query, -type, -loctype) %>% 
  as.data.table()

# Unir las bases y quedarnos con cualquiera de las dos geolocalizaciones -------

df_tus_con_gc <- df_gc_limpio2[df_tus, on = "flowcorrelativeid"]

df_tus_con_gc[is.na(calidadGeo) & !is.na(latitudGeo), calidadGeo := 1L]
df_tus_con_gc[is.na(calidadGeo) & is.na(latitudGeo), calidadGeo := -99L]

# Quedarse con la geolocalización que corresponda:

df_tus_con_gc[data.table::between(calidadGeo, -3, 0), latitud_final := lat_gmaps]
df_tus_con_gc[calidadGeo == 1, latitud_final := latitudGeo]

df_tus_con_gc[data.table::between(calidadGeo, -3, 0), longitud_final := lon_gmaps]
df_tus_con_gc[calidadGeo == 1, longitud_final := longitudGeo]

df_tus_con_gc <- df_tus_con_gc[, list(flowcorrelativeid, latitud_final, longitud_final,
                                      nomLoc, nomDpto,
                                      calidadGeo)]
setnames(df_tus_con_gc, 
         c("latitud_final", "longitud_final"), 
         c("latitudGeo", "longitudGeo"))


# Conteo de cada tipo de geolocalización ---------------------------------------

count(df_tus_con_gc, calidadGeo, sort = T) %>% as.data.table()

#    calidadGeo      n
# 1:          1 185389
# 2:        -99  27177
# 3:         -1  16507
# 4:         -2  15501
# 5:         -3   6245
# 6:          0   4948

# Guardar archivo .csv ---------------------------------------------------------

fwrite(df_tus_con_gc, file = here("Build", "Temp", "0d_geo_visitas.csv"))
