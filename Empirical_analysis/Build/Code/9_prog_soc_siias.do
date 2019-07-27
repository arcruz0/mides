* Objective: Checkear base Programas Sociales-SIIAS y generar dos archivos 
*            (hogares y personas) con datos mínimos de las visitas y de Prog. Sociales SIIAS

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Build/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp"


global years 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo
global per 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global allVars bps_afam_ley_benef bps_afam_ley_atrib bps_pens_vejez bps_sol_habit_am mvotma_rubv inau_t_comp inau_disc_t_comp inau_caif inau_club_niños inau_ctros_juveniles mid_asist_vejez mides_canasta_serv mides_jer mides_cercanias mides_ucc mides_uy_trab mides_monotributo mides_inda_snc mides_inda_paec mides_inda_panrn

global perbps_afam_ley_benef 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128
global perbps_afam_ley_atrib 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128
global perbps_pens_vejez 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perbps_sol_habit_am 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permvotma_rubv 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perinau_t_comp 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perinau_disc_t_comp 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perinau_caif 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perinau_club_niños 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global perinau_ctros_juveniles 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permid_asist_vejez 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_canasta_serv 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_jer 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_cercanias 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_ucc 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_uy_trab 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_monotributo 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
global permides_inda_snc 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123
global permides_inda_paec 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123
global permides_inda_panrn 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123


*** Cargo todos los datos Programas sociales-SIIAS en un mismo .dta con una fila por cédula
	
	** Matriz de chequeos
	mat summBlankProgSIIAS = J(11,4,0)
	mat colnames summBlankProgSIIAS = "pers-peri" "pers unica" "pers-peri NO blank" "pers unica NO blank" 
	mat rownames summBlankProgSIIAS = 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018

	** Armo un archivo por base de BPS-SNIS
	foreach yr in $years {
		import delimited ../Input/SIIAS/Programas_Sociales/`yr'_PS_enmascarado.csv, clear case(preserve)
		rename inau_club_niÃos inau_club_niños
		rename mides_asistencia_vejez mid_asist_vejez
		distinct nro_documento
		mat summBlankProgSIIAS[`yr'-2007,1] = r(N)
		mat summBlankProgSIIAS[`yr'-2007,2] = r(ndistinct) 
		drop if bps_afam_ley_benef + bps_afam_ley_atrib + bps_pens_vejez + bps_sol_habit_am + mvotma_rubv + inau_t_comp + inau_disc_t_comp + inau_caif + inau_club_niños + inau_ctros_juveniles + mid_asist_vejez + mides_canasta_serv + mides_jer + mides_cercanias + mides_ucc + mides_uy_trab + mides_monotributo + mides_inda_snc + mides_inda_paec + mides_inda_panrn == 0
		distinct nro_documento
		mat summBlankProgSIIAS[`yr'-2007,3] = r(N)
		mat summBlankProgSIIAS[`yr'-2007,4] = r(ndistinct) 
		save PS_`yr'.dta, replace
	}

	** Merge todos los archivos de Programas sociales-SIIAS
	clear all
	foreach yr in $years {
		append using PS_`yr'.dta
	}

	** Renombro variables
	rename nro_documento nrodocumentoSIIAS
	rename ïfecha_dato fecha_dato
	
	** Checkeo de las bases
	generate year = substr(fecha_dato, 1, 4)
	generate month = substr(fecha_dato, 6, 2)
	destring year, replace
	destring month, replace
	drop fecha_dato

	generate periodo = (year-2008)*12 + month
	drop year month
	
	** Cambio 0 por missing: en base que me pasaron hay datos para todas las variables desde ene-2010 (25)
	* hasta set-2018 (129) pero en codiguera que me pasaron se muestra para muchas variables valores
	* comienzan despues por lo que pongo missing por 0 para esos casos
	replace bps_afam_ley_benef=. if periodo==129
	replace bps_afam_ley_atrib=. if periodo==129
	replace mides_canasta_serv =. if periodo<=84
	replace mides_jer =. if periodo<=60
	replace mides_cercanias=. if periodo<=68
	replace mides_ucc=. if periodo<=90
	replace mides_monotributo=. if periodo<=60
	replace mides_inda_snc=. if periodo<=74 | periodo>=124
	replace mides_inda_paec=. if periodo<=74 | periodo>=124
	replace mides_inda_panrn=. if periodo<=74 | periodo>=124
	
	* Guardo base de programas sociales totales para luego dividir por variable
	save prog_soc_total.dta, replace

*** Armo dos archivos del tipo visitas_hogares_PROGRAMA.csv y visitas_personas_PROGRAMA.csv 
foreach var in $allVars {

	** Me quedo con variables y observaciones que me interesan
	use prog_soc_total.dta, clear
	keep `var' periodo nrodocumentoSIIAS
	drop if `var'==0
	
	** Genero variables por período (hay datos desde el período 25 hasta el 129 en este caso aunque difieren segun variable)
	foreach j in ${per`var'} {
		generate `var'`j'=.
		replace `var'`j' = `var' if periodo == `j'
	}
	
	** Colapso data para que haya una cédula por fila
	drop `var' periodo
	gcollapse (mean) `var'*, by(nrodocumentoSIIAS)

	save `var'_merged.dta, replace
	clear all
	
	*** Creo archivo de empalme datos Programa social-SIIAS y datos de visita personas
	use ../Output/visitas_personas_vars.dta, clear
	keep $varsKeep nrodocumentoDAES nrodocumentoSIIAS
	merge m:1 nrodocumentoSIIAS using `var'_merged.dta, keep (master match)
	drop _merge
	
	** VER SI ESTO ES NECESARIO SIQUIERA PORQUE CREO Q BASE DE PROGRAMAS SOCIALES TIENE A TODOS LOS INDIVIDUOS
	** Cambio missing por zeros cuando corresponde
	forvalues i=25/129 {
		cap replace `var'`i' = 0 if `var'`i' == .
	}
	
	** Genero variables a nivel de personas meses antes o después o durante visita:
	* Genero 49 variables por variable: osea 49 variables del tipo tipo_afiliacion según +- fecha visita (en realidad creo algunas más post visita; 5 años)
	forvalues i = 1/60 {
		generate mas`var'`i'=.
			forvalues j = 25/129 { 
				cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
			}
	}

	forvalues i = 1/24 {
		generate menos`var'`i'=.
			forvalues j = 25/129 { 
				cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
			}

	}

	generate zero`var'=.
		forvalues j = 25/129 { 
				cap replace zero`var' = `var'`j' if periodo == `j'
	}
	
	
	** Genero variables a nivel de hogar medidas como +- fecha de visita
	gegen hogarZero`var' = total(zero`var'), by(flowcorrelativeid)

	forvalues i = 1/24 {
		gegen hogarMenos`var'`i' = total(menos`var'`i'), by(flowcorrelativeid)
	}
	
	forvalues i = 1/60 {
		gegen hogarMas`var'`i' = total(mas`var'`i'), by(flowcorrelativeid)
	}

	
	export delimited using ../Output/visitas_personas_`var'.csv, replace
	
	* Guardo base personas en dta para merge
	gcollapse (mean) hogar*, by(flowcorrelativeid)
	save `var'_para_merge.dta, replace
	
	*** Creo archivo de empalme datos BPS-SIIAS y datos de visita hogares
	use ../Output/visitas_hogares_vars.dta, clear
	keep $varsKeep
	merge 1:1 flowcorrelativeid using `var'_para_merge.dta, keep(master match) keepusing(hogar*)
	drop _merge

	export delimited using ../Output/visitas_hogares_`var'.csv, replace
	
}
	
	
**** Procesamientos posteriores al armado de las bases y necesario para los chequeos de la base

** Export matrices y resultados a LaTeX
esttab matrix(summBlankProgSIIAS) using summBlankProgSIIAS.tex, replace style(tex) align(cccc)

**** Armo archivo de chequeo para LaTeX
file close _all
file open myfile using "check_prog_soc_siias.txt", write replace
file write myfile "Cosas a revisar son las siguientes:" _n
file write myfile "\begin{itemize}" _n
file write myfile "\item Conteo de observaciones y numero de individuos totalmente vacias por base" _n
file write myfile "\item Individuos repetidos: numeros y caracteristicas" _n
file write myfile "\end{itemize}"
file write myfile "\subsection{Conteo de observaciones y numero de individuos totalmente vacias por base}" _n
file write myfile "Hay 11 bases que tienen datos de los programas sociales (una por cada batch de individuos supuestamente) y lo extraño es que cuando las cargo, me da un montón de filas en blanco (osea, base tiene un individuo pero con 0 en cada variable, cuando le entendí a Correa que no nos iban a pasar datos de individuos q no tenian valores positivos para la variable que nos pasaran" _n
file write myfile "\begin{figure}[H]" _n
file write myfile "\centering" _n
file write myfile "\caption{Personas y periodos totales y vacios, segun base cargada}" _n
file write myfile "\input{../Temp/summBlankProgSIIAS.tex}" _n
file write myfile "\end{figure}" _n
file close myfile


	

