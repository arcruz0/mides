* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos completos de AFAM

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Build/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp"

* Macros
global vars_afam categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo

*** Primero voy a cargar, editar y guardar temporalmente en dta las bases de AFAM para posteriormente mergarlas con la base de personas

* Intepreto que variable monto_sol toma un valor igual al monto que cobra esa personas por AFAM. monto_hogar es la suma de monto_sol entre todos
* los integrantes del hogar (con definición de hogar acorde a BPS), y se pone un valor solamente para el jefe de hogar (resto del hogar tiene missing en
* dicha variable). Son casi idénticas igual salvo contados casos.

** 2012
import delimited ../Input/2012_AFAM_enmascarado/2012_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in
replace cobro = 0 if cobro == 2

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

ds nrodocumentoDAES month periodo, not

forvalues i = 49/60 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* cobro* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2012.dta, replace

** 2013_1
import delimited ../Input/2013_1_AFAM_enmascarado/2013_1_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in_str01
rename indice_in_str01 indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Clean variables
gen monto_sol2=real(monto_sol)
gen monto_hogar2=real(monto_hogar)
drop monto_sol monto_hogar
rename monto_sol2 monto_sol
rename monto_hogar2 monto_hogar

gen integromenores2=real(integromenores)
drop integromenores
rename integromenores2 integromenores

gen complementoliceales2=real(complementoliceales)
drop complementoliceales
rename complementoliceales2 complementoliceales

gen integrodiscapacitados2=real(integrodiscapacitados)
drop integrodiscapacitados
rename integrodiscapacitados2 integrodiscapacitados


ds nrodocumentoDAES month periodo, not

forvalues i = 61/66 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2013_1.dta, replace

** 2013_2
import delimited ../Input/2013_2_AFAM_enmascarado/2013_2_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Clean variables
gen monto_sol2=real(monto_sol)
gen monto_hogar2=real(monto_hogar)
drop monto_sol monto_hogar
rename monto_sol2 monto_sol
rename monto_hogar2 monto_hogar

gen integromenores2=real(integromenores)
drop integromenores
rename integromenores2 integromenores

gen complementoliceales2=real(complementoliceales)
drop complementoliceales
rename complementoliceales2 complementoliceales

gen integrodiscapacitados2=real(integrodiscapacitados)
drop integrodiscapacitados
rename integrodiscapacitados2 integrodiscapacitados


ds nrodocumentoDAES month periodo, not

forvalues i = 67/72 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2013_2.dta, replace

** 2014
import delimited ../Input/2014_AFAM_enmascarado/2014_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Clean variables
gen monto_sol2=real(monto_sol)
gen monto_hogar2=real(monto_hogar)
drop monto_sol monto_hogar
rename monto_sol2 monto_sol
rename monto_hogar2 monto_hogar

gen integromenores2=real(integromenores)
drop integromenores
rename integromenores2 integromenores

gen complementoliceales2=real(complementoliceales)
drop complementoliceales
rename complementoliceales2 complementoliceales

gen integrodiscapacitados2=real(integrodiscapacitados)
drop integrodiscapacitados
rename integrodiscapacitados2 integrodiscapacitados


ds nrodocumentoDAES month periodo, not

forvalues i = 73/84 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2014.dta, replace

** 2015_1
import delimited ../Input/2015_1_AFAM_enmascarado/2015_1_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

* Clean variables
gen monto_sol2=real(monto_sol)
gen monto_hogar2=real(monto_hogar)
drop monto_sol monto_hogar
rename monto_sol2 monto_sol
rename monto_hogar2 monto_hogar

gen integromenores2=real(integromenores)
drop integromenores
rename integromenores2 integromenores

gen complementoliceales2=real(complementoliceales)
drop complementoliceales
rename complementoliceales2 complementoliceales

gen integrodiscapacitados2=real(integrodiscapacitados)
drop integrodiscapacitados
rename integrodiscapacitados2 integrodiscapacitados


ds nrodocumentoDAES month periodo, not

forvalues i = 85/87 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2015_1.dta, replace

** 2015_2
import delimited ../Input/2015_2_AFAM_enmascarado/2015_2_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc


ds nrodocumentoDAES month periodo, not

forvalues i = 88/96 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2015_2.dta, replace

** 2016
import delimited ../Input/2016_AFAM_enmascarado/2016_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

ds nrodocumentoDAES month periodo, not

forvalues i = 97/108 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* cobro* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2016.dta, replace

** 2017
import delimited ../Input/2017_AFAM_enmascarado/2017_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

ds nrodocumentoDAES month periodo, not

forvalues i = 109/120 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* cobro* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2017.dta, replace

** 2018
import delimited ../Input/2018_AFAM_enmascarado/2018_AFAM_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES
keep nrodocumentoDAES year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

ds nrodocumentoDAES month periodo, not

forvalues i = 121/127 {
	foreach var in `r(varlist)' {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

drop year month categoriape categoriaocupbps ingresototal ingresosnucleo integromenores complementoliceales integrodiscapacitados cobro monto_sol monto_hogar indice_in
gcollapse (mean) categoriape* categoriaocupbps* ingresototal* ingresosnucleo* integromenores* complementoliceales* integrodiscapacitados* cobro* monto_sol* monto_hogar* indice_in*, by(nrodocumentoDAES)
save afam2018.dta, replace

*** Load base visitas de personas y me quedo solamente con algunas variables
import delimited ../Output/visitas_personas_vars.csv, clear case(preserve)
keep flowcorrelativeid nrodocumentoDAES nrodocumentoSIIAS fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo

* Agrego variables de base 2012
merge m:1 nrodocumentoDAES using afam2012.dta, keep(master matched)
drop _merge

* Agrego variables de base 2013
merge m:1 nrodocumentoDAES using afam2013_1.dta, keep(master matched)
drop _merge

merge m:1 nrodocumentoDAES using afam2013_2.dta, keep(master matched)
drop _merge

* Agrego variables de base 2014
merge m:1 nrodocumentoDAES using afam2014.dta, keep(master matched)
drop _merge

* Agrego variables de base 2015
merge m:1 nrodocumentoDAES using afam2015_1.dta, keep(master matched)
drop _merge

merge m:1 nrodocumentoDAES using afam2015_2.dta, keep(master matched)
drop _merge

* Agrego variables de base 2016
merge m:1 nrodocumentoDAES using afam2016.dta, keep(master matched)
drop _merge

* Agrego variables de base 2017
merge m:1 nrodocumentoDAES using afam2017.dta, keep(master matched)
drop _merge

* Agrego variables de base 2018
merge m:1 nrodocumentoDAES using afam2018.dta, keep(master matched)
drop _merge

* Genero variables de si individuo cobra AFAM en el mes
forvalues j = 49/127 {
	gen cobraAFAM`j' = 0
	replace cobraAFAM`j' = 1 if monto_sol`j'!=. & monto_sol`j'>0
}

* Cambio missing por zeros para variables que me interesan
forvalues i = 49/127 {
	foreach var in monto_sol monto_hogar integromenores complementoliceales integrodiscapacitados {
		replace `var'`i'=0 if `var'`i' == .
		}
}

* Genero variables meses antes o después o durante visita
* Genero 49 variables por variable: osea 49 variables del tipo categoriape según +- fecha visita
forvalues i = 1/24 {
	foreach var in $vars_afam cobraAFAM {
		generate mas`var'`i'=.
			forvalues j = 49/127 { 
				cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
		}
		}
}

forvalues i = 1/24 {
	foreach var in $vars_afam cobraAFAM {
		generate menos`var'`i'=.
			forvalues j = 49/127 { 
				cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
		}
		}
}

foreach var in $vars_afam cobraAFAM {
	generate zero`var'=.
		forvalues j = 49/127 { 
				cap replace zero`var' = `var'`j' if periodo == `j'
}
}

* Genero variables a nivel de hogar medidas como +- fecha de visita
foreach var in monto_sol monto_hogar ingresototal {
		gegen hogarZero`var' = total(zero`var'), by(flowcorrelativeid)
}

forvalues i = 1/24 {
	foreach var in monto_sol monto_hogar ingresototal {
		gegen hogarMenos`var'`i' = total(menos`var'`i'), by(flowcorrelativeid)
		gegen hogarMas`var'`i' = total(mas`var'`i'), by(flowcorrelativeid)
}
}

foreach var in cobraAFAM {
		gegen hogarZero`var' = max(zero`var'), by(flowcorrelativeid)
}

forvalues i = 1/24 {
	foreach var in cobraAFAM {
		gegen hogarMenos`var'`i' = max(menos`var'`i'), by(flowcorrelativeid)
		gegen hogarMas`var'`i' = max(mas`var'`i'), by(flowcorrelativeid)
}
}

* Guardo base a nivel de personas (en csv y dta)
export delimited using ../Output/visitas_personas_AFAM.csv, replace
save ../Output/visitas_personas_AFAM.dta, replace

* Guardo base personas en dta para merge
gcollapse (mean) hogar*, by(flowcorrelativeid)
save pers_AFAM_para_merge.dta, replace

*** Load base hogares
import delimited ../Output/visitas_hogares_vars.csv, clear case(preserve)
keep $varsKeep

* Paso datos de AFAM de base personas a Hogares
merge 1:1 flowcorrelativeid using pers_AFAM_para_merge, keep(master matched) keepusing(hogar*)
drop _merge

* Guardo base hogares en csv y dta para exportar
export delimited using ../Output/visitas_hogares_AFAM.csv, replace
save ../Output/visitas_hogares_AFAM.dta, replace


