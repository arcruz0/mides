* Objective: Checkear base CNV-SIIAS y generar dos archivos (hogares y personas) con datos 
*            mínimos de las visitas y datos CNV

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Build/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp"

* Macros
global years 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo

*** Cargo todos los datos CNV en un mismo .dta que luego haré merge con base visita de personas

** Armo un archivo por base de CNV
foreach yr in $years {
	import delimited ../Input/SIIAS/CNV/`yr'_CNV_enmascarado.csv, clear case(preserve)
	save CNV_`yr'.dta, replace
}

** Merge todos los archivos de CNV
clear all
foreach yr in $years {
	append using CNV_`yr'.dta
}

** Varios chequeos de la base

* Check: Cuántos individuos aparecen más de una vez?
duplicates tag documento_niÃo, generate(id_nino)
tab id_nino
list ïfecha_dato documento_niÃo peso_al_nacer if id_nino==1
**** CAMBIAR ESTO LUEGO: POR AHORA SE ELIMINAN OBSERVACIONES CON CÉDULAS REPETIDAS
drop if id_nino==1

* Check: outliers en valores de alguna variable?
summarize peso_al_nacer cantidad_consultas_prenatales semana_gestacion

** Corrijo outliers
replace cantidad_consultas_prenatales=. if cantidad_consultas_prenatales>=99

** Renombro variables
rename documento_niÃo nrodocumentoSIIAS
rename ïfecha_dato fecha_dato

** Preparo base para merge con base de visitas
drop fecha_dato id_nino

save CNV_merged.dta, replace
clear all

use ../Output/visitas_personas_vars.dta, clear
keep $varsKeep nrodocumentoDAES nrodocumentoSIIAS
merge m:1 nrodocumentoSIIAS using CNV_merged.dta, keep (master match)
drop _merge

export delimited using ../Output/visitas_personas_cnv_siias.csv, replace
