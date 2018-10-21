* Objective: Limpiar bases de visitas y tener un archivo con todas las variables
*            de visitas a nivel de hogar y otro de personas

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

* Load base hogares
import delimited ..\Input\Visitas_Hogares_Muestra_enmascarado.csv, clear

* Cleaning base hogares
tostring fechavisita, generate(fecha_string)
generate year = substr(fecha_string, 1, 4)
generate month = substr(fecha_string, 5, 2)
destring year, replace
destring month, replace
drop fecha_string
generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Saving base hogares preliminarmente
save visitas_hogares_vars.dta, replace

* Load base personas
import delimited ..\Input\Visitas_Personas_Muestra_enmascarado.csv, clear

* Cleaning base personas
tostring fechavisita, generate(fecha_string)
generate year = substr(fecha_string, 1, 4)
generate month = substr(fecha_string, 5, 2)
destring year, replace
destring month, replace
drop fecha_string
generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Generar variables a nivel de hogar
global varsIng ingtotalessintransferencias ingafam ingafamotro ingjubypendiscapacidad ingjubypeninvalidez ingjubypenasistenciavejez ingjubypencajabancaria ingjubypencajaprofesional ingjubypencajanotarial ingjubypencajamilitar ingjubypencajapolicial ingotrosbeneficios ingtarjetaalimentaria

foreach var in $varsIng {
egen hog`var'= total(`var'), by(flowcorrelativeid)
}

* Merge con datos de hogares que sí o sí quiero tenger en base de personas
merge m:1 flowcorrelativeid using visitas_hogares_vars, keep (master matched) keepusing(umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam template departamento localidad)
drop _merge

* Saving base personas final
export delimited using ..\Output\visitas_personas_vars.csv, replace
save ..\Output\visitas_personas_vars.dta, replace

collapse (mean) hogingtotalessintransferencias hogingafam hogingafamotro hogingjubypendiscapacidad hogingjubypeninvalidez hogingjubypenasistenciavejez hogingjubypencajabancaria hogingjubypencajaprofesional hogingjubypencajanotarial hogingjubypencajamilitar hogingjubypencajapolicial hogingotrosbeneficios hogingtarjetaalimentaria, by(flowcorrelativeid)
save visitas_personas_vars.dta, replace

* Merge base hogares con datos de personas que quiero tener en base de hogares
use visitas_hogares_vars.dta, clear
merge 1:1 flowcorrelativeid using visitas_personas_vars.dta, keep (master matched) keepusing(hogingtotalessintransferencias hogingafam hogingafamotro hogingjubypendiscapacidad hogingjubypeninvalidez hogingjubypenasistenciavejez hogingjubypencajabancaria hogingjubypencajaprofesional hogingjubypencajanotarial hogingjubypencajamilitar hogingjubypencajapolicial hogingotrosbeneficios hogingtarjetaalimentaria)
drop _merge

* Saving base de hogares final
export delimited using ..\Output\visitas_hogares_vars.csv, replace
save ..\Output\visitas_hogares_vars.dta, replace
