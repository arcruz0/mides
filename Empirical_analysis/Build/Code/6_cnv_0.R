#6)  Objective: Checkear base CNV-SIIAS y generar dos archivos (hogares y personas) con datos 
#mínimos de las visitas y datos CNV
#Code:      Code/6_cnv_siias
#Input:     Output/visitas_hogares_vars.csv
#Output/visitas_personas_vars.csv
#Input/SIIAS/CNV (todos los 11 archivos)
#Output:    Output/visitas_hogares_cnv_siias.csv
#Output/visitas_personas_cnv_siias.csv
#Temp/check_CNV.tex



###############################################################################################
# Objetivo 6_cnv_0. Identificar las madres de los niños cnv

###############################################################################################

rm(list = ls())

library(dplyr)

setwd("C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Input/SIIAS/CNV")
###


# Load data cnv---------------------------------------------------------------


cnv08<- read.csv("2008_CNV_enmascarado.csv")
cnv09<- read.csv("2009_CNV_enmascarado.csv")

cnv10<- read.csv("2010_CNV_enmascarado.csv")
cnv11<- read.csv("2011_CNV_enmascarado.csv")

cnv12<- read.csv("2012_CNV_enmascarado.csv")
cnv13<- read.csv("2013_CNV_enmascarado.csv")


cnv14<- read.csv("2014_CNV_enmascarado.csv")
cnv15<- read.csv("2015_CNV_enmascarado.csv")

cnv16<- read.csv("2016_CNV_enmascarado.csv")
cnv17<- read.csv("2017_CNV_enmascarado.csv")
cnv18<- read.csv("2018_CNV_enmascarado.csv")


cnv<- rbind( cnv08, cnv09, cnv10, cnv11, cnv12, cnv13,
             cnv14, cnv15, cnv16, cnv17, cnv18)

rm( cnv08, cnv09, cnv10, cnv11, cnv12, cnv13,
     cnv14, cnv15, cnv16, cnv17, cnv18)



# equivalencias daes siias ------------------------------------------------
getwd()
setwd ("../../Anonimizadores_equivalencias")

equiv1 <- read.csv("Parte1.csv", sep= ";")
equiv2 <- read.csv("Parte2.csv", sep= ";")

equiv<- rbind(equiv1, equiv2)
rm(equiv1,equiv2)




# merge CNV with key SIIAS-DAE --------------------------------------------

equiv<- equiv %>% 
  rename( nro_documento_DAES= nrodocumentoDAES,
          nro_documento_SIIAS= nro_documentoSIIAS  )


cnv<- cnv %>% 
  left_join(equiv, c( "documento_niÃ.o" = "nro_documento_SIIAS"  ))

head(cnv)

rm(equiv)


# load afam ---------------------------------------------------------------


setwd ("C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Input")




afam15 <-  read.csv ("2015_1_AFAM_enmascarado/2015_1_AFAM_enmascarado.csv", sep = ",") %>% 
  select ("idnucleo","persidpersona","cobro", "categoriabeneficiario","estadobeneficiario", 
                      "persidgenerante","fechanacimiento",
                      "sexo","categoriape", "nrodocumento", "year", "month")



afam15_2 <-  read.csv ("2015_2_AFAM_enmascarado/2015_2_AFAM_enmascarado.csv", sep = ",") %>% 
  select ("idnucleo","persidpersona","cobro", "categoriabeneficiario","estadobeneficiario", 
          "persidgenerante","fechanacimiento",
          "sexo","categoriape", "nrodocumento", "year", "month")

afam2015<- rbind(afam15, afam15_2)

rm(afam15, afam15_2)


# al niño le pego el id de la familia -------------------------------------


afam2015cnv<- afam2015 %>%
  left_join (cnv, c ( "nrodocumento" = "nro_documento_DAES"))


afam2015cnv<- afam2015cnv %>% 
      group_by(idnucleo) %>% filter(any(!is.na(documento_niÃ.o)))



library(data.table)

aux<- setDT(afam2015cnv)[, if(any(!is.na(documento_niño))) .SD, by = .(idnucleo)]


#al cruzarlo con AFAM para traer id_nucleo, quedaron 12 filas por niño
temp_cnv_w_idnucleo<- unique(temp_cnv_w_idnucleo, by = "documento_niño")

save(temp_cnv_w_idnucleo, file = "cnv_all.Rda")

rm(cnv)


#  pegar TODA LA FAMILIA AFAM al nacido -----------------------------------

##Check column names temp_cnv_w_idnucleo
names(temp_cnv_w_idnucleo)

##borro el documento del niño que no pega con AFAMM (formato SIIAS)
temp_cnv_w_idnucleo$documento_niño<- NULL

cnv<- temp_cnv_w_idnucleo %>% 
      left_join(afam2015, by= "nrodocumento")



# Traigo todas las afams --------------------------------------------------


#2008-2009
getwd()
setwd ("../2008_2009_AFAM_enmascarado")

load("afam0809.Rda")

cnv<- cnv %>% 
  left_join(afam0809, by= "nrodocumento")

rm(afam0809)

#2010

setwd ("../2010_AFAM_enmascarado")
load("afam_2010.Rda")

cnv<- cnv %>% 
  left_join(afam0809, by= "nrodocumento")
