

#6)  Objective: Checkear base CNV-SIIAS y generar dos archivos (hogares y personas) con datos 
#mínimos de las visitas y datos CNV
#Code:      Code/6_cnv_siias
#Input:     Output/visitas_hogares_vars.csv
#Output/visitas_personas_vars.csv
#Input/SIIAS/CNV (todos los 11 archivos)
#Output:    Output/visitas_hogares_cnv_siias.csv
#Output/visitas_personas_cnv_siias.csv
#Temp/check_CNV.tex


setwd ("/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Input/2008_2009_AFAM_enmascarado")
library(dplyr)
library (data.table)


afam0809<- read.csv ("2008_2009_AFAM_enmascarado.csv", sep = ",") 


afam0809<- afam0809 %>% 
  select  ( "idnucleo" , "persidpersona", "cobro", "categori","estadobe", 
               "persidgenerante", "fechanacimiento", 
               "sexo", "categoriape", "nrodocumento", "year", "month")
save(afam0809, file = "afam0809.Rda")


# 2010 --------------------------------------------------------------------


setwd ("../2010_AFAM_enmascarado")

afam10<- read.csv ("2010_AFAM_enmascarado.csv", sep = ",") %>%  select ("idnucleo","persidpersona",
"cobro_IB", "categoriabeneficiario_IB","estadobeneficiario_IB", 
"persidgenerante","fechanacimiento",
"sexo","categoriape", "nrodocumento", "year", "month")

save (afam10, file = "afam_2010.Rda")



# 2011 --------------------------------------------------------------------

setwd ("../2011_AFAM_enmascarado")

afam11<- read.csv ("2011_1_AFAM_enmascarado.csv", sep = ",") 

afam11 <- afam11 %>%  select ("idnucleo","persidpersona",
             "cobro_IB", "categoriabeneficiario_IB","estadobeneficiario_IB", 
             "persidgenerante","fechanacimiento",
             "sexo","categoriape", "nrodocumento", "year", "month")


save (afam11, file = "afam_2011_1.Rda")


afam11_2<- read.csv ("2011_2_AFAM_enmascarado.csv", sep = ",")  %>%  select ("idnucleo","persidpersona",
                              "cobro_IB", "categoriabeneficiario_IB","estadobeneficiario_IB", 
                              "persidgenerante","fechanacimiento",
                              "sexo","categoriape", "nrodocumento", "year", "month")


save (afam11_2, file = "afam_2011_2.Rda")



# 2012 --------------------------------------------------------------------




setwd ("../2012_AFAM_enmascarado")
afam12<- read.csv ("2012_AFAM_enmascarado.csv", sep = ",") 

afam12<- afam12 %>%  select ("idnucleo","persidpersona","cobro", "categoriabeneficiario","estadobeneficiario", 
                                        "persidgenerante","fechanacimiento",
                                        "sexo","categoriape", "nrodocumento", "year", "month")

save(afam12, file = "afam_2012.Rda")


# 2013 --------------------------------------------------------------------




setwd ("../2013_AFAM_enmascarado")
afam13_1<- read.csv ("2013_1_AFAM_enmascarado.csv", sep = ",") %>%  select ("idnucleo","persidpersona","cobro", "categoriabeneficiario","estadobeneficiario", 
                                                                          "persidgenerante","fechanacimiento",
                                                                          "sexo","categoriape", "nrodocumento", "year", "month")
save(afam13_1, file = "afam_2013_1.Rda")




setwd ("../2013_AFAM_enmascarado")
afam13_2<- read.csv ("2013_2_AFAM_enmascarado.csv", sep = ",") %>%  select ("idnucleo","persidpersona","cobro", "categoriabeneficiario","estadobeneficiario", 
                                                                            "persidgenerante","fechanacimiento",
                                                                            "sexo","categoriape", "nrodocumento", "year", "month")
save(afam13_2, file = "afam_2013_2.Rda")



Try this

df %>% select(noquote(order(colnames(df))))
or just

df[,order(colnames(df))]
