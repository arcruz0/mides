# La idea de este script es unir la información de las políticas sociales
## a la de las visitas.

################################################################################

# El script funciona teniendo abierto el RStudio Project
## mides/Empirical_analysis/Empirical_analysis.Rproj
library(here)

# Paquetes

library(data.table); setDTthreads(threads = 4)
library(stringr)
library(dplyr)

f_periodo <- function(anio, mes){
  return((anio - 2008) * 12 + mes)
}

f_dicotomizar <- function(x){
  purrr::map_int(x,
                 ~ {
                   if (.x > 0){
                     1L
                   } else {
                     0L
                   }
                 })
}


# Cargar bases -----------------------------------------------------------------

# Cada visita y su período correspondiente:
df_hogares_vars <- fread(file = here("Build", "Output", 
                                     "visitas_hogares_vars.csv"),
                         select = c("flowcorrelativeid", "fechavisita"))

df_hogares_vars[, 
               ':='(anio = as.numeric(str_sub(fechavisita, 1, 4)),
                    mes  = as.numeric(str_sub(fechavisita, 6, 7))),
               by = .(g = 1:nrow(df_hogares_vars))]

df_hogares_vars[,
               periodo := f_periodo(anio, mes),
               by = .(g = 1:nrow(df_hogares_vars))]

df_hogares_vars <- df_hogares_vars[, !c("fechavisita", "anio", "mes")]

# Las personas y el hogar al que pertenecen:
dt_ids_visitas_y_personas <- fread(
  here("Build", "Output", "visitas_personas_vars.csv"),
  select = c("flowcorrelativeid", "nrodocumentoSIIAS")
)

# La base wide de políticas sociales:
dt_ps <- fread(here("Build", "Temp", "ps_limpio", "ps_limpio_completo.csv"))
setnames(dt_ps, "nro_documento", "nrodocumentoSIIAS")
setcolorder(dt_ps, c("nrodocumentoSIIAS", "anio_archivo"))

length(unique(dt_ps$nrodocumentoSIIAS)) == nrow(dt_ps) # hay una fila por persona



# Uniones de bases -------------------------------------------------------------

# Añadir los hogares a c/ persona:
dt_ps <- merge(dt_ps, dt_ids_visitas_y_personas, all.x = TRUE, 
                by = "nrodocumentoSIIAS")

# Colapsar la base a nivel hogar (sumar todas las personas correspondientes al hogar):
dt_ps <- dt_ps %>% 
  group_by(flowcorrelativeid) %>% 
  summarize_at(vars(mides_jer_61:mides_ucc_129),
               sum) %>% 
  as.data.table() # tenemos políticas sociales a nivel hogar

# Añadir el período y filtrar, solo nos interesan visitas iguales o anteriores
## al período 129:
dt_ps <- df_hogares_vars[dt_ps, on = "flowcorrelativeid"][periodo <= 129,]

# Crear una base long y limpiarla ----------------------------------------------

names(dt_ps) <- names(dt_ps) %>% str_remove("mides_")
dt_ps_long <- melt(dt_ps, 
                   id.vars       = c("flowcorrelativeid", "periodo"),
                   measure.vars  = patterns("_"),
                   variable.name = "programa_periodo_q",
                   value.name    = "q_beneficiarios")

dt_ps_long[, c("programa", "periodo_q") := tstrsplit(programa_periodo_q, 
                                                     "_", 
                                                     fixed = T)]
dt_ps_long[, periodo_q := as.numeric(periodo_q)]
dt_ps_long <- dt_ps_long[, !c("programa_periodo_q")]

setcolorder(dt_ps_long, 
            c("flowcorrelativeid", "periodo", "programa", "periodo_q"))

dt_ps_long <- dt_ps_long[order(flowcorrelativeid, periodo)] # ordenar según per.

dt_ps_long[, dif_per := periodo_q - periodo, # calcular la diferencia en períodos
           by = .(g = 1:nrow(dt_ps_long))]

# Este es el rango máximo de las ventanas:
dt_ps_long <- dt_ps_long[between(dif_per, -12, 2),] # filtrar antes la base


# Ventana 0 --------------------------------------------------------------------

# Si tenía políticas sociales el mes de la visita

dt_ps_long_ventana0 <- dt_ps_long[dif_per == 0 & q_beneficiarios > 0] %>% 
  select(-c(periodo, periodo_q, dif_per)) %>% 
  tidyr::pivot_wider(names_from = programa, values_from = q_beneficiarios, 
                     values_fill = list(q_beneficiarios = 0))  %>%
  magrittr::set_colnames(c("flowcorrelative_id", str_c("ventana0_", names(.)[2:4]))) %>% 
  mutate_at(vars(-flowcorrelative_id), f_dicotomizar) %>% 
  as.data.table()

dt_ps_long_ventana0[, 
         ventana0_cualquier_ps := f_dicotomizar(
           sum(ventana0_cercanias, ventana0_jer, ventana0_ucc)
         ),
         by = .(g = 1:nrow(dt_ps_long_ventana0))]

# Ventana 1 --------------------------------------------------------------------

# Si tenía políticas sociales el mes de la visita (+/- 1)

dt_ps_long_ventana1 <- dt_ps_long[between(dif_per, -1, 1) & q_beneficiarios > 0] %>% 
  group_by(flowcorrelativeid, programa) %>% 
  summarize(q_beneficiarios = sum(q_beneficiarios)) %>% 
  tidyr::pivot_wider(names_from = programa, values_from = q_beneficiarios, 
                     values_fill = list(q_beneficiarios = 0)) %>%
  magrittr::set_colnames(c("flowcorrelative_id", str_c("ventana1_", names(.)[2:4]))) %>% 
  mutate_at(vars(-flowcorrelative_id), f_dicotomizar) %>% 
  as.data.table()

dt_ps_long_ventana1[, 
                    ventana1_cualquier_ps := f_dicotomizar(
                      sum(ventana1_cercanias, ventana1_jer, ventana1_ucc)
                    ),
                    by = .(g = 1:nrow(dt_ps_long_ventana1))]

# Ventana 2 --------------------------------------------------------------------

# Si tenía políticas sociales el mes de la visita (+/- 2)

dt_ps_long_ventana2 <- dt_ps_long[between(dif_per, -2, 2) & q_beneficiarios > 0] %>% 
  group_by(flowcorrelativeid, programa) %>% 
  summarize(q_beneficiarios = sum(q_beneficiarios)) %>% 
  tidyr::pivot_wider(names_from = programa, values_from = q_beneficiarios, 
                     values_fill = list(q_beneficiarios = 0)) %>%
  magrittr::set_colnames(c("flowcorrelative_id", 
                           str_c("ventana2_", names(.)[2:4]))) %>% 
  mutate_at(vars(-flowcorrelative_id), f_dicotomizar) %>% 
  as.data.table()

dt_ps_long_ventana2[, 
                    ventana2_cualquier_ps := f_dicotomizar(
                      sum(ventana2_cercanias, ventana2_jer, ventana2_ucc)
                    ),
                    by = .(g = 1:nrow(dt_ps_long_ventana2))]

# Ventana 12 atrás / 2 después ------------------------------------------------- 

# Si tenía pols sociales el mes de la visita (o -12/+2)

dt_ps_long_ventana12atras2dsps <- dt_ps_long[between(dif_per, -12, 0) & 
                                          q_beneficiarios > 0]  %>% 
  group_by(flowcorrelativeid, programa) %>% 
  summarize(q_beneficiarios = sum(q_beneficiarios)) %>% 
  tidyr::pivot_wider(names_from = programa, values_from = q_beneficiarios, 
                     values_fill = list(q_beneficiarios = 0)) %>%
  magrittr::set_colnames(c("flowcorrelative_id", 
                           str_c("ventana12atras2dsps_", names(.)[2:4]))) %>%
  mutate_at(vars(-flowcorrelative_id), f_dicotomizar) %>% 
  as.data.table()

dt_ps_long_ventana12atras2dsps[, 
                    ventana12atras2dsps_cualquier_ps := f_dicotomizar(
                      sum(ventana12atras2dsps_cercanias, 
                          ventana12atras2dsps_jer, 
                          ventana12atras2dsps_ucc)
                    ),
                    by = .(g = 1:nrow(dt_ps_long_ventana12atras2dsps))]


dt_ps_long_ventana0

dt_hogares_app <- merge(
  df_hogares_vars[, list(flowcorrelativeid)],
  dt_ps_long_ventana0[, list(flowcorrelative_id, ventana0_cualquier_ps)], 
  all.x = T, by.x = "flowcorrelativeid", by.y = "flowcorrelative_id"
)
dt_hogares_app[is.na(ventana0_cualquier_ps), ventana0_cualquier_ps := 0]

dt_hogares_app <- merge(
  dt_hogares_app,
  dt_ps_long_ventana1[, list(flowcorrelative_id, ventana1_cualquier_ps)], 
  all.x = T, by.x = "flowcorrelativeid", by.y = "flowcorrelative_id"
)
dt_hogares_app[is.na(ventana1_cualquier_ps), ventana1_cualquier_ps := 0]

dt_hogares_app <- merge(
  dt_hogares_app,
  dt_ps_long_ventana2[, list(flowcorrelative_id, ventana2_cualquier_ps)], 
  all.x = T, by.x = "flowcorrelativeid", by.y = "flowcorrelative_id"
)
dt_hogares_app[is.na(ventana2_cualquier_ps), ventana2_cualquier_ps := 0]

dt_hogares_app <- merge(
  dt_hogares_app,
  dt_ps_long_ventana12atras2dsps[, list(flowcorrelative_id, 
                                        ventana12atras2dsps_cualquier_ps)], 
  all.x = T, by.x = "flowcorrelativeid", by.y = "flowcorrelative_id"
  )
dt_hogares_app[is.na(ventana12atras2dsps_cualquier_ps), 
               ventana12atras2dsps_cualquier_ps := 0]

dt_hogares_vars_comp <- fread(file = here("Build", "Output", 
                                          "visitas_hogares_vars.csv"))

dt_hogares_vars_comp <- cbind(dt_hogares_vars_comp, 
                              dt_hogares_app[, !c("flowcorrelativeid")])

fwrite(x = dt_hogares_vars_comp,
       file = here("Build", "Output", 
                   "visitas_hogares_vars.csv"))
