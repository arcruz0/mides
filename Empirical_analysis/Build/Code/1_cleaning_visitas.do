* Objective: Limpiar bases de visitas y tener un archivo con todas las variables
*            de visitas a nivel de hogar y otro de personas

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Build/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp"

** Load base Geo para merge
import delimited geo_visitas.csv, clear case(preserve)
save geo_visitas.dta, replace
clear all

** Armo base de anonimizadores equivalencias para merge
import delimited ../Input/Anonimizadores_equivalencias/Parte1.csv, delimiter(";") varnames(1) case(preserve) clear
rename nro_documentoSIIAS nrodocumentoSIIAS
save part1_anonim.dta, replace
clear all

import delimited ../Input/Anonimizadores_equivalencias/Parte2.csv, delimiter(";") varnames(1) case(preserve) clear
rename nro_documentoSIIAS nrodocumentoSIIAS
append using part1_anonim.dta
save anonim_equivalencias.dta, replace
clear all

** Load base hogares
import delimited ../Input/Visitas_Hogares_Muestra_enmascarado.csv, clear case(preserve)

** Merge base hogares con datos Geo
merge 1:1 flowcorrelativeid using geo_visitas.dta, keep (master match)
drop _merge

** Cleaning base hogares
tostring fechavisita, generate(fecha_string)
generate year = substr(fecha_string, 1, 4)
generate month = substr(fecha_string, 5, 2)
destring year, replace
destring month, replace
drop fecha_string
generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

** Saving base hogares preliminarmente
save visitas_hogares_vars.dta, replace

** Load base personas
import delimited ../Input/Visitas_Personas_Muestra_enmascarado.csv, clear case(preserve)

** Merge con anonimizadores equivalentes
rename nrodocumento nrodocumentoDAES
merge m:1 nrodocumentoDAES using anonim_equivalencias.dta, keep(master match)
drop _merge


** Cleaning base personas
tostring fechavisita, generate(fecha_string)
generate year = substr(fecha_string, 1, 4)
generate month = substr(fecha_string, 5, 2)
destring year, replace
destring month, replace
drop fecha_string
generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* parentesco
replace parentesco = . if parentesco == 0

* edad_visita
replace edad_visita = . if (edad_visita == -35) | (edad_visita == -2) | (edad_visita == -1) | (edad_visita > 117)

* sexo
replace sexo = . if sexo == 0

* asiste
replace asiste=. if asiste==0

* ingtotalessintransferencias (trim largest 1%)
replace ingtotalessintransferencias = . if ingtotalessintransferencias > 20000

* ingafam (trim largest 1%)
replace ingafam  = . if ingafam > 3200

* ingtarjetaalimentaria (trim largest 1%)
replace ingtarjetaalimentaria  = . if ingtarjetaalimentaria > 2800

* situacionlaboral
replace situacionlaboral =. if (situacionlaboral == 99 | situacionlaboral==0)

** Generar variables a nivel de hogar

* Primero genero algunas variables que voy a querer tener a nivel de hogar respecto a número de integrantes
gen miembros = 1
gen miembrosMenores = 0
replace miembrosMenores = 1 if edad_visita<18 & edad_visita!=.

gen miembrosMenores10 = 0
replace miembrosMenores10 = 1 if edad_visita<10 & edad_visita!=.

gen miembrosMenores5 = 0
replace miembrosMenores5 = 1 if edad_visita<5 & edad_visita!=.

gen miembrosMenores3 = 0
replace miembrosMenores3 = 1 if edad_visita<3 & edad_visita!=.

gen miembrosMenores2 = 0
replace miembrosMenores2 = 1 if edad_visita<2 & edad_visita!=.

gen miembrosMenores1 = 0
replace miembrosMenores1 = 1 if edad_visita<1 & edad_visita!=.

* Las genero por hogar
global varsIng ingtotalessintransferencias ingafam ingafamotro ingjubypendiscapacidad ingjubypeninvalidez ingjubypenasistenciavejez ingjubypencajabancaria ingjubypencajaprofesional ingjubypencajanotarial ingjubypencajamilitar ingjubypencajapolicial ingotrosbeneficios ingtarjetaalimentaria

foreach var in $varsIng miembros miembrosMenores10 miembrosMenores5 miembrosMenores3 miembrosMenores2 miembrosMenores1 miembrosMenores {
gegen hog`var'= total(`var'), by(flowcorrelativeid)
}

drop miembros miembrosMenores10 miembrosMenores5 miembrosMenores3 miembrosMenores2 miembrosMenores1 miembrosMenores

* Variables del clima educativo a nivel del hogar
gen añosEducAdults = .
replace añosEducAdults = años_educ if edad_visita>= 18 & edad_visita!=.

gen añosEducAdults25 = .
replace añosEducAdults25 = años_educ if edad_visita>= 25 & edad_visita!=.

gen añosEducMinors = .
replace añosEducMinors = años_educ if edad_visita< 18 & edad_visita!=.


gegen hogAnosEduc = mean(años_educ), by(flowcorrelativeid)
gegen hogAnosEducAdults = mean(añosEducAdults), by(flowcorrelativeid)
gegen hogAnosEducAdults25 = mean(añosEducAdults25), by(flowcorrelativeid)
gegen hogAnosEducMinors= mean(añosEducMinors), by(flowcorrelativeid)

rename años_educ anosEduc
drop añosEducAdults añosEducMinors añosEducAdults25

* Merge con datos de hogares que sí o sí quiero tener en base de personas
merge m:1 flowcorrelativeid using visitas_hogares_vars, keep (master matched) keepusing(umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam template departamento localidad latitudGeo longitudGeo calidadGeo)
drop _merge

* Saving base personas final
export delimited using ../Output/visitas_personas_vars.csv, replace
save ../Output/visitas_personas_vars.dta, replace

gcollapse (mean) hogingtotalessintransferencias hogingafam hogingafamotro hogingjubypendiscapacidad hogingjubypeninvalidez hogingjubypenasistenciavejez hogingjubypencajabancaria hogingjubypencajaprofesional hogingjubypencajanotarial hogingjubypencajamilitar hogingjubypencajapolicial hogingotrosbeneficios hogingtarjetaalimentaria hogAnosEduc hogAnosEducAdults hogAnosEducAdults25 hogAnosEducMinors hogmiembros hogmiembrosMenores10 hogmiembrosMenores5 hogmiembrosMenores3 hogmiembrosMenores2 hogmiembrosMenores1 hogmiembrosMenores, by(flowcorrelativeid)
save visitas_personas_vars.dta, replace

* Merge base hogares con datos de personas que quiero tener en base de hogares
use visitas_hogares_vars.dta, clear
merge 1:1 flowcorrelativeid using visitas_personas_vars.dta, keep (master matched) keepusing(hogingtotalessintransferencias hogingafam hogingafamotro hogingjubypendiscapacidad hogingjubypeninvalidez hogingjubypenasistenciavejez hogingjubypencajabancaria hogingjubypencajaprofesional hogingjubypencajanotarial hogingjubypencajamilitar hogingjubypencajapolicial hogingotrosbeneficios hogingtarjetaalimentaria hogAnosEduc hogAnosEducAdults hogAnosEducAdults25 hogAnosEducMinors hogmiembros hogmiembrosMenores10 hogmiembrosMenores5 hogmiembrosMenores3 hogmiembrosMenores2 hogmiembrosMenores1 hogmiembrosMenores)
drop _merge

* Saving base de hogares final
export delimited using ../Output/visitas_hogares_vars.csv, replace
save ../Output/visitas_hogares_vars.dta, replace
