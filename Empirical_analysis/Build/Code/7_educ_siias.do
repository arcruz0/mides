* Objective: Checkear base Educ-SIIAS y generar dos archivos (hogares y personas) 
*            con datos mínimos de las visitas y datos SIIAS-Educacion

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

* Macros
global years 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
global vars_educ_siias codGradoEscolar enCEIP enCES enCETP cod_departamento_escuela numero_escuela grado_liceo cod_liceo grado_cetp cod_reparticion cod_nivel
global vars_educ_siias_CEIP enCEIP codGradoEscolar cod_departamento_escuela numero_escuela
global vars_educ_siias_CES enCES grado_liceo cod_liceo
global vars_educ_siias_CETP enCETP grado_cetp cod_reparticion cod_nivel
global varsCEIPLags enCEIP codGradoEscolar
global varsCESLags enCES grado_liceo
global varsCETPLags enCETP grado_cetp cod_nivel
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo
global periodosCES 40 48 52 60 64 72 76 78 81 84 88 90 93 96 100 102 105 108 111 112 113 114 115 116 117 118 119 120 123 124 125 126 127 128 129
global periodosCETP 28 33 40 45 48 52 57 60 64 69 72 76 81 84 88 93 96 100 105 108 111 112 113 114 115 116 117 118 119 120 123 124 125 126 127 128 129

*** Cargo todos los datos CEIP-SIIAS en un mismo .dta que luego haré merge con base visita de personas

** Armo un archivo por base de CEIP-SIIAS
foreach yr in $years {
	import delimited ..\Input\SIIAS\Educacion\\`yr'_CEIP_enmascarado.csv, clear case(preserve)
	save CEIP_SIIAS_`yr'.dta, replace
}

** Merge todos los archivos de CEIP-SIIAS
clear all
foreach yr in $years {
	append using CEIP_SIIAS_`yr'.dta
}

** Renombro variables
rename documento nrodocumentoSIIAS
replace fecha_dato = ïfecha_dato if fecha_dato == ""

** Varios chequeos de la base

* Check: Cuántos individuos aparecen más de una vez?
duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_nino)
tab id_nino
list fecha_dato nrodocumentoSIIAS cod_departamento_escuela cod_grado_escolar if id_nino==1
**** CAMBIAR ESTO LUEGO: POR AHORA SE ELIMINAN OBSERVACIONES CON CÉDULAS-FECHAS REPETIDAS
drop if id_nino==1


** Corrijo outliers
drop ïfecha_dato
replace cod_departamento_escuela=. if cod_departamento_escuela == -2
replace numero_escuela=. if numero_escuela==-2 // En codiguera dice que número -2 corresponde a dato incorrecto
replace numero_escuela=. if numero_escuela==-1 // En codiguera dice que número -2 corresponde a dato no especificado
*replace cod_grado_escolar="" if cod_grado_escolar=="-1" // En codiguera dice que -1 es dato no especificado
*replace cod_grado_escolar="" if cod_grado_escolar=="99"	// En codiguera dice que 99 es Otras


** Modifico variable de cod_grado_escolar para que sea numeric en vez de string
/*
1	Primaria 1:				1
2	Primaria 2:				2
3	Primaria 3:				3
4	Primaria 4:				4
5	Primaria 5:				5
6	Primaria 6:				6
99	Otras:					99
EE1	Especial 1:				1.1
EE2	Especial 2:				1.2
EE3	Especial 3:				1.3
EE4	Especial 4:				1.4
EE5	Especial 5:				1.5
EE6	Especial 6:				1.6
MB1	Media Básica 1:			2.1
MB2	Media Básica 2:			2.2
MB3	Media Básica 3:			2.3
NI0	Inicial 0:				0.0
NI1	Inicial 1:				0.1
NI2	Inicial 2:				0.2
NI3	Inicial 3:				0.3
NI4	Inicial 4:				0.4
NI5	Inicial 5:				0.5
-2	Dato incorrecto:		-2	
-1	Dato no especificado: 	-1
*/

gen codGradoEscolar = .
replace codGradoEscolar = 1 if cod_grado_escolar=="1"
replace codGradoEscolar = 2 if cod_grado_escolar=="2"
replace codGradoEscolar = 3 if cod_grado_escolar=="3"
replace codGradoEscolar = 4 if cod_grado_escolar=="4"
replace codGradoEscolar = 5 if cod_grado_escolar=="5"
replace codGradoEscolar = 6 if cod_grado_escolar=="6"
replace codGradoEscolar = 99 if cod_grado_escolar=="99"
replace codGradoEscolar = 1.1 if cod_grado_escolar=="EE1"
replace codGradoEscolar = 1.2 if cod_grado_escolar=="EE2"
replace codGradoEscolar = 1.3 if cod_grado_escolar=="EE3"
replace codGradoEscolar = 1.4 if cod_grado_escolar=="EE4"
replace codGradoEscolar = 1.5 if cod_grado_escolar=="EE5"
replace codGradoEscolar = 1.6 if cod_grado_escolar=="EE6"
replace codGradoEscolar = 2.1 if cod_grado_escolar=="MB1"
replace codGradoEscolar = 2.2 if cod_grado_escolar=="MB2"
replace codGradoEscolar = 2.3 if cod_grado_escolar=="MB3"
replace codGradoEscolar = 0.0 if cod_grado_escolar=="NI0"
replace codGradoEscolar = 0.1 if cod_grado_escolar=="NI1"
replace codGradoEscolar = 0.2 if cod_grado_escolar=="NI2"
replace codGradoEscolar = 0.3 if cod_grado_escolar=="NI3"
replace codGradoEscolar = 0.4 if cod_grado_escolar=="NI4"
replace codGradoEscolar = 0.5 if cod_grado_escolar=="NI5"
replace codGradoEscolar = -2 if cod_grado_escolar=="-2"
replace codGradoEscolar = -1 if cod_grado_escolar=="-1"

drop cod_grado_escolar

* Genero variable de si individuo está en base CEIP y guardo base
gen enCEIP = 1
save CEIP_SIIAS_merged.dta, replace

*** Cargo todos los datos CES-SIIAS en un mismo .dta que luego haré merge con base visita de personas

** Armo un archivo por base de CES-SIIAS
foreach yr in $years {
	import delimited ..\Input\SIIAS\Educacion\\`yr'_CES_enmascarado.csv, clear case(preserve)
	save CES_SIIAS_`yr'.dta, replace
}

** Merge todos los archivos de CES-SIIAS
clear all
foreach yr in $years {
	append using CES_SIIAS_`yr'.dta
}

** Renombro variables
rename documento nrodocumentoSIIAS
rename ïfecha_dato fecha_dato
rename grado grado_liceo

** Varios chequeos de la base

* Check: Cuántos individuos aparecen más de una vez?
duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_nino)
tab id_nino
list fecha_dato nrodocumentoSIIAS grado_liceo cod_liceo if id_nino==1
**** CAMBIAR ESTO LUEGO: POR AHORA SE ELIMINAN OBSERVACIONES CON CÉDULAS-FECHAS REPETIDAS
drop if id_nino!=0

* Check: Hay outliers en la base?
tab grado_liceo
tab cod_liceo

** Corrijo outliers
replace grado_liceo=. if grado_liceo==0
replace cod_liceo=. if cod_liceo == -2 // En codiguera dice que número -2 corresponde a dato incorrecto
replace cod_liceo=. if cod_liceo == -1 // En codiguera dice que número -1 corresponde a dato no especificado

* Genero variable de si individuo está en base CES
gen enCES = 1
save CES_SIIAS_merged.dta, replace

*** Cargo todos los datos CETP-SIIAS en un mismo .dta que luego haré merge con base visita de personas

** Armo un archivo por base de CETP-SIIAS
foreach yr in $years {
	import delimited ..\Input\SIIAS\Educacion\\`yr'_CETP_enmascarado.csv, clear case(preserve)
	save CETP_SIIAS_`yr'.dta, replace
}

** Merge todos los archivos de CETP-SIIAS
clear all
foreach yr in $years {
	append using CETP_SIIAS_`yr'.dta
}

** Renombro variables
rename documento nrodocumentoSIIAS
rename ïfecha_dato fecha_dato
rename grado grado_cetp
** Varios chequeos de la base

* Check: Cuántos individuos aparecen más de una vez?
duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_nino)
tab id_nino
list fecha_dato nrodocumentoSIIAS grado_cetp cod_nivel cod_reparticion if id_nino!=0
**** CAMBIAR ESTO LUEGO: POR AHORA SE ELIMINAN OBSERVACIONES CON CÉDULAS-FECHAS REPETIDAS
drop if id_nino!=0

* Check: Hay outliers en la base?
*** GRADO 0 TIENE SENTIDO PARA CETP??
tab grado_cetp
tab cod_nivel
tab cod_reparticion

** Corrijo outliers
replace grado_cetp=. if grado_cetp==-2
replace cod_reparticion=. if cod_reparticion == -2 // En codiguera dice que número -2 corresponde a dato incorrecto
replace cod_reparticion=. if cod_reparticion == -1 // En codiguera dice que número -1 corresponde a dato no especificado

* Genero variable de si individuo está en base CETP
gen enCETP = 1
save CETP_SIIAS_merged.dta, replace

*** Merge bases CEIP, CES, CETP
merge 1:1 nrodocumentoSIIAS fecha_dato using CEIP_SIIAS_merged.dta
drop _merge
merge 1:1 nrodocumentoSIIAS fecha_dato using CES_SIIAS_merged.dta
drop _merge
drop id_nino

gen year = substr(fecha_dato, 1, 4)
generate month = substr(fecha_dato, 6, 2)
destring year, replace
destring month, replace
generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc
drop fecha_dato

*** Genero 102 variables por variable como máximo: osea 110 variables del tipo enCEIP según el período
* Períodos van de 28 (abr-2010) hasta 129 (set-2018) que es último dato disponible de Educacion-SIIAS (abr-2010 es 1er dato disponible)

** CEIP: hay datos mensuales para cada mes desde marzo 2013 a setiembre 2018 (periodo 63 al 129) excepto en periodos:
*73, 74, 85, 86, 97, 98, 109, 110, 121, 122 (enero-febrero de 2014, 2015, 2016, 2017 y 2018) 
forvalues i = 63/129 {
	if `i'!=73 & `i'!=74 & `i'!=85 & `i'!=86 & `i'!=97 & `i'!=98 & `i'!=109 & `i'!=110 & `i'!=121 & `i'!=122 {
		foreach var in $vars_educ_siias_CEIP {
			generate `var'`i'=.
			replace `var'`i'=`var' if periodo == `i'
			}
			}
}

** CES: hay datos salteados desde abril-2011 (40) hasta set-2018 (129): abril y dic para 2011-2013;
* abril, jun, set, dic para 2014-2016; mar-dic 2017 y mar-set 2018.
foreach i in $periodosCES {
	foreach var in $vars_educ_siias_CES {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

** CETP: hay datos salteados desde abril-2010 (28) hasta set-2018 (129): abril y set para 2010; 
* abr, set, dic 2011; abr, set, dic 2012; abr, set, dic 2013; abr, set, dic 2014;
* abr, set, dic 2015; abr, set, dic 2016; mar-dic 2017; mar-set 2018  
foreach i in $periodosCETP {
	foreach var in $vars_educ_siias_CETP {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}


** Colapso data para que haya solamente una observación por cédula
drop $vars_educ_siias
gcollapse (mean) codGradoEscolar* enCEIP* enCES* enCETP* cod_departamento_escuela* numero_escuela* grado_liceo* cod_liceo* grado_cetp* cod_reparticion* cod_nivel*, by(nrodocumentoSIIAS)
save educSIIAS_para_merge.dta, replace

*** Load base personas
import delimited ..\Output\visitas_personas_vars.csv, clear case(preserve)
keep $varsKeep nrodocumentoDAES nrodocumentoSIIAS

* Merge base personas con datos de Educ-SIIAS
merge m:1 nrodocumentoSIIAS using educSIIAS_para_merge, keep(master matched)
drop _merge

* Cambio missing por zeros de datos merged desde Educ-SIIAS para variables que corresponda
forvalues i = 28/129 {
	foreach var in enCEIP enCES enCETP {
			cap replace `var'`i' = 0 if `var'`i' ==.
}
}

* Cambio missing por -999 (mi código de "No aplica" que es distitno de 0 o missing) cuando corresponda.
* Por qué es distinto de missing? porque missing puede dar idea de que, por ej, no tenemos informacion de la escuela del individuo
* (aunque fuera a la escuela)
forvalues i = 28/129 {
	foreach var in cod_departamento_escuela numero_escuela grado_liceo cod_liceo grado_cetp cod_reparticion cod_nivel {
			cap replace `var'`i' = -999 if `var'`i' ==.
}
}

*** Genero 49 variables por variable: osea 49 variables del tipo enCEIP como +- fecha de visita
* (para algunas fechas pongo dato del mes anterior si hay missing value para cierto mes-año) (en realidad creo algunas más post visita; 5 años)

** CEIP
	forvalues i = 1/60 {
		foreach var in $varsCEIPLags {
			generate mas`var'`i'=.
				forvalues j = 63/129 {
					local j1 = `j' - 1
					local j2 = `j' - 2
					if (`j' == 73 | `j' == 85 | `j' == 97 | `j' == 109 | `j' == 121) {
						replace mas`var'`i' = `var'`j1' if periodo == `j' - `i'
						}
					else if (`j' == 74 | `j' == 86 | `j' == 98 | `j' == 110 | `j' == 122) {
						replace mas`var'`i' = `var'`j2' if periodo == `j' - `i'
						}
					else {
						cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
						}
			}
			}
	}

	forvalues i = 1/24 {
		foreach var in $varsCEIPLags {
			generate menos`var'`i'=.
				forvalues j = 63/129 {
					local j1 = `j' - 1
					local j2 = `j' - 2
					if (`j' == 73 | `j' == 85 | `j' == 97 | `j' == 109 | `j' == 121) {
						replace menos`var'`i' = `var'`j1' if periodo == `j' + `i'
						}
					else if (`j' == 74 | `j' == 86 | `j' == 98 | `j' == 110 | `j' == 122) {
						replace menos`var'`i' = `var'`j2' if periodo == `j' + `i'
						}
					else {
						cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
						}
			}
			}
	}


		foreach var in $varsCEIPLags {
			generate zero`var'=.
				forvalues j = 63/129 {
					local j1 = `j' - 1
					local j2 = `j' - 2
					if (`j' == 73 | `j' == 85 | `j' == 97 | `j' == 109 | `j' == 121) {
						replace zero`var' = `var'`j1' if periodo == `j'
						}
					else if (`j' == 74 | `j' == 86 | `j' == 98 | `j' == 110 | `j' == 122) {
						replace zero`var' = `var'`j2' if periodo == `j'
						}
					else {
						cap replace zero`var' = `var'`j' if periodo == `j'
						}
			}
			}


** CES: Para 2011, 2012 y 2013 (solo datos en abr y dic) asumo que ene-mar siempre tienen valor de abril pasado;
* may-nov siempre tienen valor de dic pasado. En 2014 y 2016 (abril, jun, set y dic) asumo ene-mar son iguales a abril, may es jun, jul-ago es set y oct-nov es dic; 
* 2017 y 2018 estudiantes asumo ene-feb es igual a valor de marzo	
	forvalues i = 1/60 {
		foreach var in  $varsCESLags {
			generate mas`var'`i'=.
				forvalues j = 40/129 {
					* may-nov 2011: 41-47
					if (`j' >= 41 & `j' <= 47) {
						replace mas`var'`i' = `var'48 if periodo == `j' - `i'
						}
					* ene-mar 2012: 49-51
					else if (`j' == 49 | `j' == 50 | `j' == 51) {
						replace mas`var'`i' = `var'52 if periodo == `j' - `i'
						}
					* may-nov 2012: 53-59
					else if (`j' >= 53 & `j' <= 59) {
						replace mas`var'`i' = `var'60 if periodo == `j' - `i'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace mas`var'`i' = `var'64 if periodo == `j' - `i'
						}
					* may-nov 2013: 65-71
					else if (`j' >= 65 & `j' <= 71) {
						replace mas`var'`i' = `var'72 if periodo == `j' - `i'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace mas`var'`i' = `var'76 if periodo == `j' - `i'
						}
					* may 2014: 77
					else if (`j' == 77) {
						replace mas`var'`i' = `var'78 if periodo == `j' - `i'
						}
					* jul-ago 2014: 79-80
					else if (`j' >= 79 & `j' <= 80) {
						replace mas`var'`i' = `var'81 if periodo == `j' - `i'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace mas`var'`i' = `var'84 if periodo == `j' - `i'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace mas`var'`i' = `var'88 if periodo == `j' - `i'
						}
					* may 2015: 89
					else if (`j' == 89) {
						replace mas`var'`i' = `var'90 if periodo == `j' - `i'
						}
					* jul-ago 2015: 91-92
					else if (`j' >= 91 & `j' <= 92) {
						replace mas`var'`i' = `var'93 if periodo == `j' - `i'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace mas`var'`i' = `var'96 if periodo == `j' - `i'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace mas`var'`i' = `var'100 if periodo == `j' - `i'
						}
					* may 2016: 101
					else if (`j' == 101) {
						replace mas`var'`i' = `var'102 if periodo == `j' - `i'
						}
					* jul-ago 2016: 103-104
					else if (`j' >= 103 & `j' <= 104) {
						replace mas`var'`i' = `var'105 if periodo == `j' - `i'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace mas`var'`i' = `var'108 if periodo == `j' - `i'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace mas`var'`i' = `var'111 if periodo == `j' - `i'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace mas`var'`i' = `var'123 if periodo == `j' - `i'
						}
					else {
						cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
						}
			}
			}
	}

	forvalues i = 1/24 {
		foreach var in $varsCESLags {
			generate menos`var'`i'=.
				forvalues j = 40/129 {
					* may-nov 2011: 41-47
					if (`j' >= 41 & `j' <= 47) {
						replace menos`var'`i' = `var'48 if periodo == `j' + `i'
						}
					* ene-mar 2012: 49-51
					else if (`j' == 49 | `j' == 50 | `j' == 51) {
						replace menos`var'`i' = `var'52 if periodo == `j' + `i'
						}
					* may-nov 2012: 53-59
					else if (`j' >= 53 & `j' <= 59) {
						replace menos`var'`i' = `var'60 if periodo == `j' + `i'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace menos`var'`i' = `var'64 if periodo == `j' + `i'
						}
					* may-nov 2013: 65-71
					else if (`j' >= 65 & `j' <= 71) {
						replace menos`var'`i' = `var'72 if periodo == `j' + `i'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace menos`var'`i' = `var'76 if periodo == `j' + `i'
						}
					* may 2014: 77
					else if (`j' == 77) {
						replace menos`var'`i' = `var'78 if periodo == `j' + `i'
						}
					* jul-ago 2014: 79-80
					else if (`j' >= 79 & `j' <= 80) {
						replace menos`var'`i' = `var'81 if periodo == `j' + `i'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace menos`var'`i' = `var'84 if periodo == `j' + `i'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace menos`var'`i' = `var'88 if periodo == `j' + `i'
						}
					* may 2015: 89
					else if (`j' == 89) {
						replace menos`var'`i' = `var'90 if periodo == `j' + `i'
						}
					* jul-ago 2015: 91-92
					else if (`j' >= 91 & `j' <= 92) {
						replace menos`var'`i' = `var'93 if periodo == `j' + `i'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace menos`var'`i' = `var'96 if periodo == `j' + `i'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace menos`var'`i' = `var'100 if periodo == `j' + `i'
						}
					* may 2016: 101
					else if (`j' == 101) {
						replace menos`var'`i' = `var'102 if periodo == `j' + `i'
						}
					* jul-ago 2016: 103-104
					else if (`j' >= 103 & `j' <= 104) {
						replace menos`var'`i' = `var'105 if periodo == `j' + `i'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace menos`var'`i' = `var'108 if periodo == `j' + `i'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace menos`var'`i' = `var'111 if periodo == `j' + `i'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace menos`var'`i' = `var'123 if periodo == `j' + `i'
						}
					else {
						cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
						}
			}
			}
	}	

		foreach var in $varsCESLags {
			generate zero`var'`i'=.
				forvalues j = 40/129 {
					* may-nov 2011: 41-47
					if (`j' >= 41 & `j' <= 47) {
						replace zero`var' = `var'48 if periodo == `j'
						}
					* ene-mar 2012: 49-51
					else if (`j' == 49 | `j' == 50 | `j' == 51) {
						replace zero`var' = `var'52 if periodo == `j'
						}
					* may-nov 2012: 53-59
					else if (`j' >= 53 & `j' <= 59) {
						replace zero`var'`i' = `var'60 if periodo == `j'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace zero`var' = `var'64 if periodo == `j'
						}
					* may-nov 2013: 65-71
					else if (`j' >= 65 & `j' <= 71) {
						replace zero`var' = `var'72 if periodo == `j'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace zero`var' = `var'76 if periodo == `j'
						}
					* may 2014: 77
					else if (`j' == 77) {
						replace zero`var' = `var'78 if periodo == `j'
						}
					* jul-ago 2014: 79-80
					else if (`j' >= 79 & `j' <= 80) {
						replace zero`var' = `var'81 if periodo == `j'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace zero`var' = `var'84 if periodo == `j'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace zero`var' = `var'88 if periodo == `j'
						}
					* may 2015: 89
					else if (`j' == 89) {
						replace zero`var' = `var'90 if periodo == `j'
						}
					* jul-ago 2015: 91-92
					else if (`j' >= 91 & `j' <= 92) {
						replace zero`var' = `var'93 if periodo == `j'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace zero`var' = `var'96 if periodo == `j'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace zero`var' = `var'100 if periodo == `j'
						}
					* may 2016: 101
					else if (`j' == 101) {
						replace zero`var' = `var'102 if periodo == `j'
						}
					* jul-ago 2016: 103-104
					else if (`j' >= 103 & `j' <= 104) {
						replace zero`var' = `var'105 if periodo == `j'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace zero`var' = `var'108 if periodo == `j'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace zero`var' = `var'111 if periodo == `j'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace zero`var' = `var'123 if periodo == `j'
						}
					else {
						cap replace zero`var' = `var'`j' if periodo == `j'
						}
			}
			}



** CETP: hay datos salteados desde abril-2010 (28) hasta set-2018 (129): abril y set para 2010; 
* abr, set, dic 2011; abr, set, dic 2012; abr, set, dic 2013; abr, set, dic 2014;
* abr, set, dic 2015; abr, set, dic 2016; mar-dic 2017; mar-set 2018  

*Periodos con datos: 28 33 40 45 48 52 57 60 64 69 72 76 81 84 88 93 96 100 105 108 111 112 113 114 115 116 117 118 119 120 123 124 125 126 127 128 129

** Para 2011, 2012 y 2013 (solo datos en abr y dic) asumo que ene-mar siempre tienen valor de abril pasado;
* may-nov siempre tienen valor de dic pasado. En 2014 y 2016 (abril, jun, set y dic) asumo ene-mar son iguales a abril, may es jun, jul-ago es set y oct-nov es dic; 
* 2017 y 2018 estudiantes asumo ene-feb es igual a valor de marzo
	forvalues i = 1/60 {
		foreach var in  $varsCETPLags {
			generate mas`var'`i'=.
				forvalues j = 28/129 {
					* may-ago 2010: 29-32
					if (`j' >= 29 & `j' <= 32) {
						replace mas`var'`i' = `var'33 if periodo == `j' - `i'
						}
					* oct 2010-mar 2011: 34-39
					else if (`j' >= 34 & `j' <= 39) {
						replace mas`var'`i' = `var'40 if periodo == `j' - `i'
						}
					* may-ago 2011: 41-44
					else if (`j' >= 41 & `j' <= 44) {
						replace mas`var'`i' = `var'45 if periodo == `j' - `i'
						}
					* oct-nov 2011: 46-47
					else if (`j' >= 46 & `j' <= 47) {
						replace mas`var'`i' = `var'48 if periodo == `j' - `i'
						}
					* ene-mar 2012: 49-51
					else if (`j' >= 49 & `j' <= 51) {
						replace mas`var'`i' = `var'52 if periodo == `j' - `i'
						}
					* may-ago 2012: 53-56
					else if (`j' >= 53 & `j' <= 56) {
						replace mas`var'`i' = `var'57 if periodo == `j' - `i'
						}
					* oct-nov 2012: 58-59
					else if (`j' >= 58 & `j' <= 59) {
						replace mas`var'`i' = `var'60 if periodo == `j' - `i'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace mas`var'`i' = `var'64 if periodo == `j' - `i'
						}
					* may-ago 2013: 65-68
					else if (`j' >= 65 & `j' <= 68) {
						replace mas`var'`i' = `var'69 if periodo == `j' - `i'
						}
					* oct-nov 2013: 70-71
					else if (`j' >= 70 & `j' <= 71) {
						replace mas`var'`i' = `var'72 if periodo == `j' - `i'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace mas`var'`i' = `var'76 if periodo == `j' - `i'
						}
					* may-ago 2014: 77-80
					else if (`j' >= 77 & `j'<=80) {
						replace mas`var'`i' = `var'81 if periodo == `j' - `i'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace mas`var'`i' = `var'84 if periodo == `j' - `i'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace mas`var'`i' = `var'88 if periodo == `j' - `i'
						}
					* may-ago 2015: 89-92
					else if (`j' >= 89 & `j'<=92) {
						replace mas`var'`i' = `var'93 if periodo == `j' - `i'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace mas`var'`i' = `var'96 if periodo == `j' - `i'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace mas`var'`i' = `var'100 if periodo == `j' - `i'
						}
					* may-ago 2016: 101-104
					else if (`j' >= 101 & `j' <= 104) {
						replace mas`var'`i' = `var'105 if periodo == `j' - `i'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace mas`var'`i' = `var'108 if periodo == `j' - `i'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace mas`var'`i' = `var'111 if periodo == `j' - `i'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace mas`var'`i' = `var'123 if periodo == `j' - `i'
						}
					else {
						cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
						}
			}
			}
	}
	
	
	
	forvalues i = 1/24 {
		foreach var in  $varsCETPLags {
			generate menos`var'`i'=.
				forvalues j = 28/129 {
					* may-ago 2010: 29-32
					if (`j' >= 29 & `j' <= 32) {
						replace menos`var'`i' = `var'33 if periodo == `j' + `i'
						}
					* oct 2010-mar 2011: 34-39
					else if (`j' >= 34 & `j' <= 39) {
						replace menos`var'`i' = `var'40 if periodo == `j' + `i'
						}
					* may-ago 2011: 41-44
					else if (`j' >= 41 & `j' <= 44) {
						replace menos`var'`i' = `var'45 if periodo == `j' + `i'
						}
					* oct-nov 2011: 46-47
					else if (`j' >= 46 & `j' <= 47) {
						replace menos`var'`i' = `var'48 if periodo == `j' + `i'
						}
					* ene-mar 2012: 49-51
					else if (`j' >= 49 & `j' <= 51) {
						replace menos`var'`i' = `var'52 if periodo == `j' + `i'
						}
					* may-ago 2012: 53-56
					else if (`j' >= 53 & `j' <= 56) {
						replace menos`var'`i' = `var'57 if periodo == `j' + `i'
						}
					* oct-nov 2012: 58-59
					else if (`j' >= 58 & `j' <= 59) {
						replace menos`var'`i' = `var'60 if periodo == `j' + `i'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace menos`var'`i' = `var'64 if periodo == `j' + `i'
						}
					* may-ago 2013: 65-68
					else if (`j' >= 65 & `j' <= 68) {
						replace menos`var'`i' = `var'69 if periodo == `j' + `i'
						}
					* oct-nov 2013: 70-71
					else if (`j' >= 70 & `j' <= 71) {
						replace menos`var'`i' = `var'72 if periodo == `j' + `i'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace menos`var'`i' = `var'76 if periodo == `j' + `i'
						}
					* may-ago 2014: 77-80
					else if (`j' >= 77 & `j'<=80) {
						replace menos`var'`i' = `var'81 if periodo == `j' + `i'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace menos`var'`i' = `var'84 if periodo == `j' + `i'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace menos`var'`i' = `var'88 if periodo == `j' + `i'
						}
					* may-ago 2015: 89-92
					else if (`j' >= 89 & `j'<=92) {
						replace menos`var'`i' = `var'93 if periodo == `j' + `i'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace menos`var'`i' = `var'96 if periodo == `j' + `i'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace menos`var'`i' = `var'100 if periodo == `j' + `i'
						}
					* may-ago 2016: 101-104
					else if (`j' >= 101 & `j' <= 104) {
						replace menos`var'`i' = `var'105 if periodo == `j' + `i'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace menos`var'`i' = `var'108 if periodo == `j' + `i'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace menos`var'`i' = `var'111 if periodo == `j' + `i'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace menos`var'`i' = `var'123 if periodo == `j' + `i'
						}
					else {
						cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
						}
			}
			}
	}
	
		foreach var in  $varsCETPLags {
			generate zero`var'=.
				forvalues j = 28/129 {
					* may-ago 2010: 29-32
					if (`j' >= 29 & `j' <= 32) {
						replace zero`var' = `var'33 if periodo == `j'
						}
					* oct 2010-mar 2011: 34-39
					else if (`j' >= 34 & `j' <= 39) {
						replace zero`var' = `var'40 if periodo == `j'
						}
					* may-ago 2011: 41-44
					else if (`j' >= 41 & `j' <= 44) {
						replace zero`var' = `var'45 if periodo == `j'
						}
					* oct-nov 2011: 46-47
					else if (`j' >= 46 & `j' <= 47) {
						replace zero`var' = `var'48 if periodo == `j'
						}
					* ene-mar 2012: 49-51
					else if (`j' >= 49 & `j' <= 51) {
						replace zero`var' = `var'52 if periodo == `j'
						}
					* may-ago 2012: 53-56
					else if (`j' >= 53 & `j' <= 56) {
						replace zero`var' = `var'57 if periodo == `j'
						}
					* oct-nov 2012: 58-59
					else if (`j' >= 58 & `j' <= 59) {
						replace zero`var' = `var'60 if periodo == `j'
						}
					* ene-mar 2013: 61-63
					else if (`j' == 61 | `j' == 62 | `j' == 63) {
						replace zero`var' = `var'64 if periodo == `j'
						}
					* may-ago 2013: 65-68
					else if (`j' >= 65 & `j' <= 68) {
						replace zero`var' = `var'69 if periodo == `j'
						}
					* oct-nov 2013: 70-71
					else if (`j' >= 70 & `j' <= 71) {
						replace zero`var' = `var'72 if periodo == `j'
						}
					* ene-mar 2014: 73-75
					else if (`j' >= 73 & `j' <= 75) {
						replace zero`var' = `var'76 if periodo == `j'
						}
					* may-ago 2014: 77-80
					else if (`j' >= 77 & `j'<=80) {
						replace zero`var' = `var'81 if periodo == `j'
						}
					* oct-nov 2014: 82-83
					else if (`j' >= 82 & `j' <= 83) {
						replace zero`var' = `var'84 if periodo == `j'
						}
					* ene-mar 2015: 85-87
					else if (`j' >= 85 & `j' <= 87) {
						replace zero`var' = `var'88 if periodo == `j'
						}
					* may-ago 2015: 89-92
					else if (`j' >= 89 & `j'<=92) {
						replace zero`var' = `var'93 if periodo == `j'
						}
					* oct-nov 2015: 94-95
					else if (`j' >= 94 & `j' <= 95) {
						replace zero`var' = `var'96 if periodo == `j'
						}
					* ene-mar 2016: 97-99
					else if (`j' >= 97 & `j' <= 99) {
						replace zero`var' = `var'100 if periodo == `j'
						}
					* may-ago 2016: 101-104
					else if (`j' >= 101 & `j' <= 104) {
						replace zero`var' = `var'105 if periodo == `j'
						}
					* oct-nov 2016: 106-107
					else if (`j' >= 106 & `j' <= 107) {
						replace zero`var' = `var'108 if periodo == `j'
						}
					* ene-feb 2017: 109-110
					else if (`j' >= 109 & `j' <= 110) {
						replace zero`var' = `var'111 if periodo == `j'
						}
					* ene-feb 2018: 121-122
					else if (`j' >= 121 & `j' <= 122) {
						replace zero`var' = `var'123 if periodo == `j'
						}
					else {
						cap replace zero`var' = `var'`j' if periodo == `j'
						}
			}
			}
	
	
* Genero variables a nivel de hogar medidas como +- fecha de visita
forvalues i = 1/24 {
	foreach var in enCEIP enCES enCETP {
		gegen hogarMenos`var'`i' = max(menos`var'`i'), by(flowcorrelativeid)
		gegen hogarMas`var'`i' = max(mas`var'`i'), by(flowcorrelativeid)
		}
}


foreach var in enCEIP enCES enCETP {
		gegen hogarZero`var' = max(zero`var'), by(flowcorrelativeid)
}


* Guardo base personas en csv y dta para exportar
export delimited using ..\Output\visitas_personas_educ_siias.csv, replace

* Guardo base personas en dta para merge
gcollapse (mean) hogar*, by(flowcorrelativeid)
save educ_siias_para_merge.dta, replace

*** Load base hogares
import delimited ..\Output\visitas_hogares_vars.csv, clear case(preserve)
keep $varsKeep

* Paso datos de Educ-SIIAS de base personas a Hogares
merge 1:1 flowcorrelativeid using educ_siias_para_merge, keep(master matched) keepusing(hogar*)
drop _merge

* Guardo base hogares en csv para exportar
export delimited using ..\Output\visitas_hogares_educ_siias.csv, replace
