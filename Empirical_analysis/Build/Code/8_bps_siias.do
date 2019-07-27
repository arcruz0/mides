* Objective: Checkear base BPS-SIIAS y generar dos archivos (hogares y personas) con datos 
*            mínimos de las visitas y datos BPS del SIIAS

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Build/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp"


* Macros
global years 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
global vars_BPS bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad
global varsBPSSIIAS tipo_afiliacion ocupadoSIIAS bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo

*** Cargo todos los datos BPS SNIS en un mismo .dta con una fila por cédula

	** Armo un archivo por base de BPS-SNIS
	foreach yr in $years {
		import delimited ../Input/SIIAS/BPS/`yr'_SNIS_enmascarado.csv, clear case(preserve)
		save BPS_SNIS_`yr'.dta, replace
	}

	** Merge todos los archivos de BPS-SNIS
	clear all
	foreach yr in $years {
		append using BPS_SNIS_`yr'.dta
	}

	** Renombro variables
	rename documento nrodocumentoSIIAS
	replace fecha_dato=ïfecha_dato if fecha_dato==""
	drop ïfecha_dato

	** Varios chequeos de la base
	* Check: hay solo 4 tipos de afiliacion?
	log using tabulBPS.smcl, replace
	tab tipo_afiliacion
	log close
	translate tabulBPS.smcl tabulBPS.pdf, replace
	
	* Check: Cuántos individuos aparecen más de una vez (en un mismo mes-ano)?
	log using duplBPS.smcl, replace
	duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_fecha)
	tab id_fecha
	
	* Check: Cuántos individuos aparecen más de una vez y con valores distintos (en un mismo mes-ano)?
	duplicates tag nrodocumentoSIIAS fecha_dato tipo_afiliacion, generate(noConflicto)
	tab noConflicto
	distinct nrodocumentoSIIAS if noConflicto==0 & id_fecha==1
	
	list fecha_dato tipo_afiliacion if nrodocumentoSIIAS=="50DC199DB1D83CC8ECEE3BB935D5EADA"
	list fecha_dato tipo_afiliacion if nrodocumentoSIIAS=="5822EE5BBF17E78249C621120356B766"
	list fecha_dato tipo_afiliacion if nrodocumentoSIIAS=="77AE79B1BCC435AE26577610B7281D03"
	list fecha_dato tipo_afiliacion if nrodocumentoSIIAS=="1A7871F4C0DCB366463C9A33A3DC133C"
	list fecha_dato tipo_afiliacion if nrodocumentoSIIAS=="DB24E9E9A50B13B6187F31174AADF802"
	
	log close
	translate duplBPS.smcl duplBPS.pdf, replace
	
	* Primero elimino una de las obs de los pares de obs totalmente repetidas
	gen uno=1
	gen filtrar=0
	bysort fecha_dato nrodocumentoSIIAS (uno):replace filtrar = 2 if _n==_N & id_fecha==1 & noConflicto==1
	bysort fecha_dato nrodocumentoSIIAS (uno):replace filtrar = 1 if _n==_N-1 & id_fecha==1 & noConflicto==1
	drop if filtrar==1
	
	* De las obs no totalmente repetidas (i.e. con conflicto) me quedo con aquella con menor valor de tipo de afiliacion
	gegen minAfil = min(tipo_afiliacion) if id_fecha==1 & noConflicto==0, by(nrodocumentoSIIAS fecha_dato) 
	drop if tipo_afiliacion>minAfil & id_fecha==1 & noConflicto==0
	
	
	** Genero variables por período (hay datos desde el período 25 hasta el 130 en este caso)
	generate year = substr(fecha_dato, 1, 4)
	generate month = substr(fecha_dato, 6, 2)
	destring year, replace
	destring month, replace
	drop fecha_dato

	generate periodo = (year-2008)*12 + month
	drop year month

	forvalues i = 25/130 {
		foreach var in tipo_afiliacion {
			generate `var'`i'=.
			replace `var'`i' = `var' if periodo == `i'
	}
	}

	** Colapso data para que haya una cédula por fila
	drop tipo_afiliacion periodo
	gcollapse (mean) tipo_afiliacion*, by(nrodocumentoSIIAS)
	
	* Genero variables después del collapse de empleo
	forvalues i=25/130 {
		gen ocupadoSIIAS`i' = 0
		replace ocupadoSIIAS`i' =1 if tipo_afiliacion`i'==16
	}
		
	save BPS_SNIS_merged.dta, replace
	clear all

*** Cargo todos los datos BPS Subsidios en un mismo .dta con una fila por cédula

	** Armo un archivo por base de BPS-Subsidios
	foreach yr in $years {
		import delimited ../Input/SIIAS/BPS/`yr'_Subsidios_Planes_enmascarado.csv, clear case(preserve)
		save BPS_Subsidios_`yr'.dta, replace
	}

	** Merge todos los archivos de BPS-Subsidios
	clear all
	foreach yr in $years {
		append using BPS_Subsidios_`yr'.dta
	}

	** Renombro variables
	rename nro_documento nrodocumentoSIIAS
	rename ïfecha_dato fecha_dato

	** Varios chequeos de la base

	* Check: Cuántos individuos aparecen más de una vez (en un mismo mes-ano)?
	duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_fecha)
	tab id_fecha

	duplicates tag nrodocumentoSIIAS fecha_dato bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil, generate(noConflicto)
	tab noConflicto

	**** CAMBIAR ESTO LUEGO:  se deja solo una obs para aquellas repetidas (no hay obs repetidas con datos que conflictuen)
	drop if noConflicto==0 & id_fecha==1 
	drop noConflicto

	generate year = substr(fecha_dato, 1, 4)
	generate month = substr(fecha_dato, 6, 2)
	destring year, replace
	destring month, replace
	drop fecha_dato

	sort id_fecha nrodocumentoSIIAS year month
	drop if nrodocumentoSIIAS[_n]==nrodocumentoSIIAS[_n-1] & id_fecha==1 & year[_n]==year[_n-1] & month[_n]==month[_n-1]
	drop id_fecha

	* Elimino observaciones que son todo 0
	drop if bps_sub_desempleo + bps_sub_enfermedad + bps_sub_maternidad + bps_plan_materno + bps_plan_infantil ==0


	** Genero variables por período (hay datos desde el período 25 hasta el 130 en este caso)
	generate periodo = (year-2008)*12 + month
	drop year month

	forvalues i = 25/130 {
		foreach var in bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil {
			generate `var'`i'=0
			replace `var'`i' = `var' if periodo == `i'
	}
	}

	** Colapso data para que haya una cédula por fila
	drop bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil
	gcollapse (mean) bps_sub_desempleo* bps_sub_enfermedad* bps_sub_maternidad* bps_plan_materno* bps_plan_infantil*, by(nrodocumentoSIIAS)

	save BPS_Subsidios_merged.dta, replace


	*** Merge bases de BPS-SIIAS: SNIS y Subsidios
	merge 1:1 nrodocumentoSIIAS using BPS_SNIS_merged.dta
	drop _merge
	save BPS_SIIAS.dta, replace
	clear all

	*** Creo archivo de empalme datos BPS-SIIAS y datos de visita personas
	use ../Output/visitas_personas_vars.dta, clear
	keep $varsKeep nrodocumentoDAES nrodocumentoSIIAS
	merge m:1 nrodocumentoSIIAS using BPS_SIIAS.dta, keep (master match)
	drop _merge

	** Cambio missing por zeros cuando corresponde
	forvalues i=25/130 {
		foreach var in tipo_afiliacion ocupadoSIIAS bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil {
			cap replace `var'`i' = 0 if `var'`i' == .	// 0 va a ser código de hay datos para esta variable en este mes-año pero no se registra afiliacion SNIS para el individio (idem otras vars)
		}
		}
	
	
	** Genero variables a nivel de personas meses antes o después o durante visita:
	* Genero 49 variables por variable: osea 49 variables del tipo tipo_afiliacion según +- fecha visita (en realidad creo algunas más post visita; 5 años)
	forvalues i = 1/60 {
		foreach var in $varsBPSSIIAS  {
			generate mas`var'`i'=.
				forvalues j = 25/130 { 
					cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
			}
			}
	}

	forvalues i = 1/24 {
		foreach var in $varsBPSSIIAS {
			generate menos`var'`i'=.
				forvalues j = 25/130 { 
					cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
			}
			}
	}

	foreach var in $varsBPSSIIAS {
		generate zero`var'=.
			forvalues j = 25/130 { 
					cap replace zero`var' = `var'`j' if periodo == `j'
	}
	}

	** Genero variables a nivel de hogar medidas como +- fecha de visita
	foreach var in bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil ocupadoSIIAS {
			gegen hogarZero`var' = total(zero`var'), by(flowcorrelativeid)
	}

	forvalues i = 1/24 {
		foreach var in bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil {
			gegen hogarMenos`var'`i' = total(menos`var'`i'), by(flowcorrelativeid)
			gegen hogarMas`var'`i' = total(mas`var'`i'), by(flowcorrelativeid)
	}
	}


	export delimited using ../Output/BPS_SIIAS_personas.csv, replace
	save ../Output/BPS_SIIAS_personas.dta, replace

* Guardo base personas en dta para merge
gcollapse (mean) hogar*, by(flowcorrelativeid)
save BPS_SIIAS_para_merge.dta, replace
	
*** Creo archivo de empalme datos BPS-SIIAS y datos de visita hogares
use ../Output/visitas_hogares_vars.dta, clear
keep $varsKeep
merge 1:1 flowcorrelativeid using BPS_SIIAS_para_merge.dta, keep(master match) keepusing(hogar*)
drop _merge

export delimited using ../Output/BPS_SIIAS_hogares.csv, replace
save ../Output/BPS_SIIAS_hogares.dta, replace

**** Procesamientos posteriores al armado de las bases y necesario para los chequeos de la base
clear all
import delimited ../Output/BPS_SIIAS_personas.csv, clear case(preserve)
merge 1:1 flowcorrelativeid nrodocumentoSIIAS using ../Output/visitas_personas_vars.dta, keep(master matched) keepusing(nrodocumentoDAES sexo edadVisitaNac anosEduc asiste)
drop _merge

gen female = .
replace female =1 if sexo==2
replace female =0 if sexo==1

log using tabulBPS2.smcl, replace
sort zerotipo_afiliacion
mean edadVisitaNac female, over(zerotipo_afiliacion)
log close
translate tabulBPS2.smcl tabulBPS2.pdf, replace

* Numeros afiliados por tipo de afiliacion como funcion del momento de la visita
mat seriesBPS = J(25,8,0)
matrix colnames seriesBPS = "Afil 16" "Afil 17" "Afil 32" "Afil 36" "16 mes vs past" "17 mes vs past" "32 mes vs past" "36 mes vs past"
matrix rownames seriesBPS = "-12" "-11" "-10" "-9" "-8" "-7" "-6" "-5" "-4" "-3" "-2" "-1" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" 

gen uno=1
scalar iter = 0
foreach val in 16 17 32 36 {
	scalar iter = iter + 1
	forvalues x = 12(-1)1 {
		total uno if menostipo_afiliacion`x'==`val'
		ereturn list
		mat seriesBPS[13-`x',iter] = e(b)
	}
	
	total uno if zerotipo_afiliacion==`val'
	ereturn list
	mat seriesBPS[13,iter] = e(b)
	
	forvalues x = 1(1)12 {
		total uno if mastipo_afiliacion`x'==`val'
		ereturn list
		mat seriesBPS[13 + `x',iter] = e(b)
	}
}

forvalues col=5(1)8 {
	forvalues row=25(-1)2 {
		mat seriesBPS[`row',`col'] = (seriesBPS[`row',`col'-4]-seriesBPS[`row'-1,`col'-4])/seriesBPS[`row',`col'-4]*100
	}
}

esttab matrix(seriesBPS) using seriesBPS.tex, replace style(tex) align(cccccccc)

**** Armo archivo de chequeo para LaTeX
file close _all
file open myfile using "check_BPS_SIIAS.txt", write replace
file write myfile "Cosas a revisar son las siguientes:" _n
file write myfile "\begin{itemize}" _n
file write myfile "\item Tabulaciones y estadisticos descriptivos de la muestra" _n
file write myfile "\item Individuos repetidos: numeros y caracteristicas" _n
file write myfile "\item Tipos de afiliacion como funcion del momento de la visita" _n
file write myfile "\end{itemize}"

file write myfile "\subsection{Tabulaciones y estadisticos descriptivos de la muestra}" _n
file write myfile "Primero hago un tab comun de mi unica variable de interes de la base que es tipo\_afilicion para chequar que solo toma 4 valores posibles." _n
file write myfile "Luego quiero ver numero de personas (al momento 0) segun cada uno de los tipos de afiliacion (esto es ya corrigiendo la base por duplicados) y sus caracteristicas para ver si tienen sentido (e.j. kids deberian estar en cierta categoria, mujeres en otra, etc)." _n
file write myfile "Quiero creer que si sos un jubilado, tenes codigo 17, si sos activo en el mercado laboral tenes codigo 16, si sos hijo de ocupado tenes codigo 32 y si sos desocupado pero concube o esposo de trabajador, tenes codigo 36. Aunque restaria entender mejor como se dan los traspasos entre codigos" _n
file write myfile "\includepdf[page=-]{tabulBPS.pdf}" _n
file write myfile "\includepdf[page=-]{tabulBPS2.pdf}" _n

file write myfile "\subsection{Individuos repetidos: numeros y caracteristicas}" _n
file write myfile "Primero veo cuantos duplicados totales hay y por suerte veo hay pocos. Luego miro si son duplicados completamente o con conflicto (i.e. tenes una persona-periodo con un tipo afiliacion y otra con otro). Por suerte, hay pocas con conflicto (corresponden a 5 individuos)." _n
file write myfile "Identificados estos 5 individuos, miro la serie de tiempo para cada uno pero no es muy claro que hacer con estos individuos." _n
file write myfile "Decido ponerle el minimo codigo que se repita, a modo de maximizar los individuos-periodos con valor 16 (que considero es como decir que individuo esta ocupado)" _n
file write myfile "\includepdf[page=-]{duplBPS.pdf}" _n

file write myfile "\subsection{Tipos de afiliacion como funcion del momento de la visita}" _n
file write myfile "Algo raro que se veia en graficos DID de impacto TUS en empleo es que parecia haber un salto en el momento 0. Aqui se mira que sucede con comportamiento agregado alrededor del momento 0" _n
file write myfile "Ultimas 4 columnas muestran diferencia porcentual en un lag vs lag anterior (expresado en 100\%)" _n
file write myfile "\begin{figure}[H]" _n
file write myfile "\centering" _n
file write myfile "\caption{Numero de afiliados segun tipo y momento relativo a visita}" _n
file write myfile "\input{../Temp/seriesBPS.tex}" _n
file write myfile "\end{figure}" _n
file close myfile
