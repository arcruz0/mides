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

* Saving base hogares
export delimited using ..\Output\visitas_hogares_vars.csv, replace
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

* Merge con datos de hogares que sí o sí quiero tengo base de personas
merge m:1 flowcorrelativeid using visitas_hogares_vars, keep (master matched) keepusing(umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam)
drop _merge

* Saving base personas
export delimited using ..\Output\visitas_personas_vars.csv, replace
