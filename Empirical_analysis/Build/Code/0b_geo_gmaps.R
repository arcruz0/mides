# La idea de este script es añadir la geolocalización con Google Maps

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Build.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(stringr)
library(readxl)

# Generar la base con filas por geolocalizar --------------------

df_direcciones <- fread(file = here("Temp", "0a_datos_geo_visitas.csv"),
                        select = c("flowcorrelativeid", 
                                   "departamento", "localidad",
                                   "latitudGeo", "longitudGeo",
                                   "direccionnombre", "direccionnumero", 
                                   "direccionkm"
                        ))

df_por_geolocalizar <- df_direcciones[is.na(latitudGeo) & direccionnombre != "",]

df_por_geolocalizar[, 
                    direccionnumero := str_remove(
                      direccionnumero,
                      pattern = regex("(pasaje al fondo)|(al fondo)|(arriba)|(atras)", 
                                      ignore_case = T)
                    ),
                    by = 1:nrow(df_por_geolocalizar)
                    ]

# Añadir nombres de departamentos y localidades --------------------------------

## Cargar base tipo codebook:

# http://www.ine.gub.uy/c/document_library/get_file?uuid=220c14ae-7d92-4737-8e9d-9bb2991c40f1&groupId=10181
localidades_completo <- read_excel(
  here("Input", "Localidades_y_codigos_NUEVO_XLS.xls"), 
  range = "A5:G1253",  
  col_names = c(
    "departamento_nombre", "departamento",
    "localidad_min", "localidad_nombre", 
    "vigente", "vigente_hasta", "localidad"
  )) %>% 
  tidyr::fill(departamento_nombre) %>% 
  dplyr::filter(!is.na(departamento)) %>% 
  dplyr::mutate(departamento_nombre = str_to_title(departamento_nombre),
                localidad = str_remove(localidad, "^0") %>% as.numeric()) %>% 
  dplyr::select(localidad, localidad_nombre, departamento_nombre)

localidades_completo <- as.data.table(localidades_completo)

## Hacer merge:

df_por_geolocalizar2 <- localidades_completo[df_por_geolocalizar, on = "localidad"]

setcolorder(df_por_geolocalizar2, "flowcorrelativeid")

## Arreglar el siguiente missing:

df_por_geolocalizar2[is.na(localidad_nombre),] %>% 
  .$localidad %>% 
  table() # número 16899

## Según http://pronadis.mides.gub.uy/mides/guiarecurso/templates/recurso_puertas.jsp?contentid=31022&channel=innova.front&site=1&departamentos=16&localidades=16899
## es "Ciudad del Plata", en el departamento de San José. Arreglar:

df_por_geolocalizar2[is.na(localidad_nombre), 
                     ':='(localidad_nombre    = "Ciudad del Plata", 
                          departamento_nombre = "San José")]

# Generar query para Google Maps -----------------------------------------------
df_por_geolocalizar2[,
                     gmaps_query := str_c(
                       str_c(direccionnombre, direccionnumero, sep = " "),
                       localidad_nombre, departamento_nombre,
                       "Uruguay",
                       sep = ", "), 
                     by = 1:nrow(df_por_geolocalizar2)]

readr::write_rds(df_por_geolocalizar2, here("Temp", "0b_df_por_geolocalizar2.rds"))

# Geocode ----------------------------------------------------------------------

register_google("KEY-ALEJANDRO-ANONIMIZADA", write = F) # cargar API key

p_geocode <- possibly(geocode, "NULL_EN_FUNCION")

l <- length(df_por_geolocalizar2$gmaps_query)

gc_lista <- map2(.x = df_por_geolocalizar2$gmaps_query, 
                 .y = 1:l,
                 .f = ~ {
                   message(glue("{.y}/{l}"))
                   Sys.sleep(0.5)
                   p_geocode(.x, output = "all")
                 })

readr::write_rds(gc_lista, here("Temp", "0b_gc_lista.rds"))