* Objective: Checkear base BPS-SIIAS y generar dos archivos (hogares y personas) con datos 
*            mínimos de las visitas y datos BPS del SIIAS

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

* Macros
global years 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
global vars_BPS bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad
global varsBPSSIIAS tipo_afiliacion ocupadoSIIAS bps_sub_desempleo bps_sub_enfermedad bps_sub_maternidad bps_plan_materno bps_plan_infantil
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo

*** Cargo todos los datos BPS SNIS en un mismo .dta con una fila por cédula

	** Armo un archivo por base de BPS-SNIS
	foreach yr in $years {
		import delimited ..\Input\SIIAS\BPS\\`yr'_SNIS_enmascarado.csv, clear case(preserve)
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

	* Check: Cuántos individuos aparecen más de una vez (en un mismo mes-ano)?
	duplicates tag nrodocumentoSIIAS fecha_dato, generate(id_fecha)
	tab id_fecha

	* Check: Cuántos individuos aparecen más de una vez y con valores distintos (en un mismo mes-ano)?
	duplicates tag nrodocumentoSIIAS fecha_dato tipo_afiliacion, generate(noConflicto)
	tab noConflicto

	**** CAMBIAR ESTO LUEGO: se deja solo una obs para aquellas repetidas y se eliminan aquellas con "conflicto"
	drop if noConflicto==0 & id_fecha==1 
	drop noConflicto

	gegen tempGroup=group(nrodocumentoSIIAS fecha_dato)
	sort id_fecha nrodocumentoSIIAS fecha_dato
	drop if tempGroup[_n]==tempGroup[_n-1] & id_fecha==1
	drop id_fecha
	drop tempGroup

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
		import delimited ..\Input\SIIAS\BPS\\`yr'_Subsidios_Planes_enmascarado.csv, clear case(preserve)
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
	use ..\Output\visitas_personas_vars.dta, clear
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


	export delimited using ..\Output\BPS_SIIAS_personas.csv, replace
	save ..\Output\BPS_SIIAS_personas.dta, replace

* Guardo base personas en dta para merge
gcollapse (mean) hogar*, by(flowcorrelativeid)
save BPS_SIIAS_para_merge.dta, replace
	
*** Creo archivo de empalme datos BPS-SIIAS y datos de visita hogares
use ..\Output\visitas_hogares_vars.dta, clear
keep $varsKeep
merge 1:1 flowcorrelativeid using BPS_SIIAS_para_merge.dta, keep(master match) keepusing(hogar*)
drop _merge

export delimited using ..\Output\BPS_SIIAS_hogares.csv, replace
save ..\Output\BPS_SIIAS_hogares.dta, replace
