* Objective: Mirar second stage de impacto TUS en Educ-SIIAS.

clear all
cap cd "C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp"
cap cd "/home/andres/gdrive/mides/Empirical_analysis/Analysis/Temp"
cap cd "/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Analysis/Temp"
cap log close
log using "12b_educ_siias", replace

global controlsDID1 mujer edad edad2 mdeo year2 year3 year4 year5 year6 mes2 mes3 mes4 mes5 mes6 mes7 mes8 mes9 mes10 mes11 mes12
global controlsDID2 mujer edadD2 edadD3 edadD4 edadD5 edadD6 edadD7 edadD8 edadD9 edadD10 edadD11 edadD12 edadD13 edadD14 edadD15 edadD16 edadD17 edadD18 edadD19 edadD20 edadD21 dep1 dep2 dep3 dep4 dep5 dep6 dep7 dep8 dep9 dep10 dep11 dep12 dep13 dep14 dep15 dep16 dep17 dep18 dep19 year2 year3 year4 year5 year6 mes2 mes3 mes4 mes5 mes6 mes7 mes8 mes9 mes10 mes11 mes12
global varsAFAM hogarZerocobraAFAM hogarMascobraAFAM12
global varsTUS hogarZerocobraTus hogarZerotusDoble departamento periodo year
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado nrodocumentoDAES fechanacimiento anosEduc
global varsEduc menosenCEIP18 menosenCEIP17 menosenCEIP16 menosenCEIP15 menosenCEIP14 menosenCEIP13 menosenCEIP12 menosenCEIP11 menosenCEIP10 menosenCEIP9 menosenCEIP8 menosenCEIP7 menosenCEIP6 menosenCEIP5 menosenCEIP4 menosenCEIP3 ///
menosenCEIP2 menosenCEIP1 zeroenCEIP masenCEIP1 masenCEIP2 masenCEIP3 masenCEIP4 masenCEIP5 masenCEIP6 masenCEIP7 masenCEIP8 masenCEIP9 ///
 masenCEIP10 masenCEIP11 masenCEIP12 masenCEIP13 masenCEIP14 masenCEIP15 masenCEIP16 masenCEIP17 masenCEIP18 masenCEIP19 masenCEIP20 ///
 masenCEIP21 masenCEIP22 masenCEIP23 masenCEIP24 masenCEIP25 masenCEIP26 masenCEIP27 masenCEIP28 masenCEIP29 masenCEIP30 ///
 masenCEIP31 masenCEIP32 masenCEIP33 masenCEIP34 masenCEIP35 masenCEIP36 masenCEIP37 masenCEIP38 masenCEIP39 masenCEIP40 masenCEIP41 ///
 masenCEIP42 masenCEIP43 masenCEIP44 masenCEIP45 masenCEIP46 masenCEIP47 masenCEIP48 ///
 menosenCES18 menosenCES17 menosenCES16 menosenCES15 menosenCES14 menosenCES13 menosenCES12 menosenCES11 menosenCES10 menosenCES9 menosenCES8 menosenCES7 menosenCES6 menosenCES5 menosenCES4 menosenCES3 ///
 menosenCES2 menosenCES1 zeroenCES masenCES1 masenCES2 masenCES3 masenCES4 masenCES5 masenCES6 masenCES7 masenCES8 masenCES9 ///
 masenCES10 masenCES11 masenCES12 masenCES13 masenCES14 masenCES15 masenCES16 masenCES17 masenCES18 masenCES19 masenCES20 ///
 masenCES21 masenCES22 masenCES23 masenCES24 masenCES25 masenCES26 masenCES27 masenCES28 masenCES29 masenCES30 ///
 masenCES31 masenCES32 masenCES33 masenCES34 masenCES35 masenCES36 masenCES37 masenCES38 masenCES39 masenCES40 ///
 masenCES41 masenCES42 masenCES43 masenCES44 masenCES45 masenCES46 masenCES47 masenCES48 ///
 zerogrado_liceo masgrado_liceo1 masgrado_liceo2 masgrado_liceo3 masgrado_liceo4 masgrado_liceo5 ///
 masgrado_liceo6 masgrado_liceo7 masgrado_liceo8 masgrado_liceo9 masgrado_liceo10 masgrado_liceo11 ///
 masgrado_liceo12 masgrado_liceo13 masgrado_liceo14 masgrado_liceo15 masgrado_liceo16 masgrado_liceo17 ///
 masgrado_liceo18 masgrado_liceo19 masgrado_liceo20 masgrado_liceo21 masgrado_liceo22 masgrado_liceo23 ///
 masgrado_liceo24 masgrado_liceo25 masgrado_liceo26 masgrado_liceo27 masgrado_liceo28 masgrado_liceo29 ///
 masgrado_liceo30 masgrado_liceo31 masgrado_liceo32 masgrado_liceo33 masgrado_liceo34 masgrado_liceo35 ///
 masgrado_liceo36 masgrado_liceo37 masgrado_liceo38 masgrado_liceo39 masgrado_liceo40 masgrado_liceo41 ///
 masgrado_liceo42 masgrado_liceo43 masgrado_liceo44 masgrado_liceo45 masgrado_liceo46 masgrado_liceo47 ///
 masgrado_liceo48 menosgrado_liceo1 menosgrado_liceo2 menosgrado_liceo3 menosgrado_liceo4 menosgrado_liceo5 ///
 menosgrado_liceo6 menosgrado_liceo7 menosgrado_liceo8 menosgrado_liceo9 menosgrado_liceo10 menosgrado_liceo11 ///
 menosgrado_liceo12 menosgrado_liceo13 menosgrado_liceo14 menosgrado_liceo15 menosgrado_liceo16 menosgrado_liceo17 ///
 menosgrado_liceo18 ///
 menoscodGradoEscolar18 menoscodGradoEscolar17 menoscodGradoEscolar16 menoscodGradoEscolar15 menoscodGradoEscolar14 ///
 menoscodGradoEscolar13 menoscodGradoEscolar12 menoscodGradoEscolar11 menoscodGradoEscolar10 menoscodGradoEscolar9 ///
 menoscodGradoEscolar8 menoscodGradoEscolar7 menoscodGradoEscolar6 menoscodGradoEscolar5 menoscodGradoEscolar4 ///
 menoscodGradoEscolar3 menoscodGradoEscolar2 menoscodGradoEscolar1 zerocodGradoEscolar mascodGradoEscolar1 ///
 mascodGradoEscolar2 mascodGradoEscolar3 mascodGradoEscolar4 - mascodGradoEscolar48

global varDeps EstudiaCEIPCES AnosAtrasados

*Save dataset with dictionary for periodo-year I will need for future mergers
import delimited ../Input/periodo_mes_year.csv, clear case(preserve)
rename year yearMatched
rename periodo periodoChanged
save periodo_mes_year.dta, replace

* Load dataset a nivel de personas con datos de Educ-SIIAS
import delimited ../Input/MIDES/visitas_personas_educ_siias.csv, clear case(preserve)
keep $varsEduc flowcorrelativeid nrodocumentoSIIAS icc umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam periodo

* Merge con data de TUS que deseo
merge m:1 flowcorrelativeid using ../Input/MIDES/visitas_hogares_TUS.dta, keep (master match) keepusing(${varsTUS})
drop _merge

* Merge con data de visitas-personas que deseo
merge 1:1 nrodocumentoSIIAS flowcorrelativeid using ../Input/MIDES/visitas_personas_vars.dta, keep (master match) keepusing(${varsPersonas})
drop _merge

* Merge con data de AFAM que deseo
merge 1:1 nrodocumentoSIIAS flowcorrelativeid using ../Input/MIDES/visitas_personas_AFAM.dta, keep (master match) keepusing(${varsAFAM})
drop _merge

* Defino leads and lags: cuántos período antes de visita y posterior de visita quiero considerar en DID
global lagsN 6 12 
global leadsN 36 48

* Elimino parte de la muestra que nunca me va a interesar
keep if edad_visita<=15 & edad_visita>=6 & edad_visita!=.

save educ_preliminiar.dta, replace
foreach lagN in $lagsN {
	foreach leadN in $leadsN {
		use educ_preliminiar.dta, clear
		* Acorde a como definí leads and lags, debo quedarme con muestra de individuos con obs para dichos períodos
		* Para el caso de 18 lags y 48 leads: Elimino individuos en la muestra que fueron visitados antes y después del 
		* período 81. Esto es porque datos de CEIP empiezan 
		* recien en mar-2013 (datos de CES y CETP están desde antes) que es el período 63 y como quiero observaciones
		* con hasta 18 meses antes de la visita, solo quiero observaciones visitadas a partir del periodo 63 + 18 = 81.
		* También, como miro 48 meses posterior a la visita y solo tengo observaciones hasta el período 129, entonces me
		* termino quedando con aquellos visitados entre el período 81 y el 129 - 48 = 81 
		drop if periodo < 63 + `lagN'
		drop if periodo > 129 - `leadN'

		*** Genero variables
		gen iccMenosThreshold0 = icc - umbral_afam
		gen iccMenosThreshold1 = icc - umbral_nuevo_tus
		gen iccMenosThreshold2 = icc - umbral_nuevo_tus_dup
		gen hogarZeroCuantasTus = hogarZerocobraTus + hogarZerotusDoble
		gen noCambiaAFAM = .
		replace noCambiaAFAM = 1 if hogarZerocobraAFAM!=. & hogarMascobraAFAM12!=. & hogarZerocobraAFAM==hogarMascobraAFAM12
		replace noCambiaAFAM = 0 if hogarZerocobraAFAM!=. & hogarMascobraAFAM12!=. & hogarZerocobraAFAM!=hogarMascobraAFAM12

		*** Relativas a educación: asistencia a Primaria/Secundaria, dummy si está en correcto año lectivo acorde a edad, número de años atrasados del individuo acorde a edad

		** Asistencia Primaria/Secundaria
		forvalues num = 1/`leadN' {
			gen masEstudiaCEIPCES`num' = .
			replace masEstudiaCEIPCES`num' = 0 if (masenCEIP`num'==0 | masenCES`num'==0)
			replace masEstudiaCEIPCES`num' = 1 if (masenCEIP`num'==1 | masenCES`num'==1)
		}

		forvalues num = 1/`lagN' {
			gen menosEstudiaCEIPCES`num' = .
			replace menosEstudiaCEIPCES`num' = 0 if (menosenCEIP`num'==0 | menosenCES`num'==0)
			replace menosEstudiaCEIPCES`num' = 1 if (menosenCEIP`num'==1 | menosenCES`num'==1)
		}

		gen zeroEstudiaCEIPCES = .
		replace zeroEstudiaCEIPCES = 0 if (zeroenCEIP==0 | zeroenCES==0)
		replace zeroEstudiaCEIPCES = 1 if (zeroenCEIP==1 | zeroenCES==1)

		** Dummy igual a 1 si se encuentra en correcto año lectivo acorde a edad

		* Primero debe construirse Número de años de educación completos que individuo debería tener acorde a su edad y momento del año (momento de visita, +- meses luego de visita)
		* Primaria: 1er año - 6/7 años, 2do - 7/8, 3ro - 8/9, 4to - 9/10, 5to - 10/11, 6to - 11/12
		* Secundaria Ciclo Básico: 1er - 12/13, 2do - 13/14, 3ro - 14/15
		* Secundaria Bachillerato: 4to - 15/16, 5to - 16/17, 6to - 17/18
		* Calculo edad del individuo al 30 de abril del año en el año de la visita. Considero que si individuo tiene por ej 8 años a esa fecha, entonces debería estar en 3ro de escuela (y cumpliría 9 años durante el año lectivo)

		* Primero genero una variable con el año en el periodo +- de la visita
		generate periodoChanged = .
		forvalues num = 1/`leadN' {
			replace periodoChanged = periodo + `num'
			merge m:1 periodoChanged using periodo_mes_year.dta, keep (master matched) keepusing(yearMatched)
			rename yearMatched masyear`num'
			drop _merge
		}

		forvalues num = 1/`lagN' {
			replace periodoChanged = periodo - `num'
			merge m:1 periodoChanged using periodo_mes_year.dta, keep (master matched) keepusing(yearMatched)
			rename yearMatched menosyear`num'
			drop _merge
		}

		tostring fechanacimiento, generate(fechaNacString)
		generate yearNacimiento = substr(fechaNacString, 1, 4)
		generate mesNacimiento = substr(fechaNacString, 5, 2)
		generate dayNacimiento = substr(fechaNacString, 7, 2)
		destring yearNacimiento, replace
		destring mesNacimiento, replace
		destring dayNacimiento, replace

		gen zeroEdad30Abril = .
		replace zeroEdad30Abril = year - yearNacimiento - 1 if mesNacimiento >= 5 & mesNacimiento!=.
		replace zeroEdad30Abril = year - yearNacimiento if mesNacimiento < 5 & mesNacimiento!=.

		forvalues num =  1/`leadN' {
			gen masEdad30Abril`num' = .
			replace masEdad30Abril`num' = masyear`num' - yearNacimiento - 1 if mesNacimiento >= 5 & mesNacimiento!=.
			replace masEdad30Abril`num' = masyear`num' - yearNacimiento if mesNacimiento < 5 & mesNacimiento!=.
		}
		forvalues num =  1/`lagN' {
			gen menosEdad30Abril`num' = .
			replace menosEdad30Abril`num' = menosyear`num' - yearNacimiento - 1 if mesNacimiento >= 5 & mesNacimiento!=.
			replace menosEdad30Abril`num' = menosyear`num' - yearNacimiento if mesNacimiento < 5 & mesNacimiento!=.
		}

		* Calculo año en el que debería estar el individuo en cada momento +- de la visita (o que deberia haber terminado)
		* Debe estar en 1ro de primaria en el momento de la visita si en el año de la visita tiene 6 años al 30 de abril
		gen zeroEnAnosEducDeberia = .
		replace zeroEnAnosEducDeberia = 0 if zeroEdad30Abril<=5 & zeroEdad30Abril!=.
		forvalues num =  1/12 {
			replace zeroEnAnosEducDeberia = `num' if zeroEdad30Abril == 5 + `num'
		}
		replace zeroEnAnosEducDeberia = 12 if zeroEdad30Abril>=18 & zeroEdad30Abril!=.

		forvalues lag = 1/`leadN' {
			gen masEnAnosEducDeberia`lag' = .
			replace masEnAnosEducDeberia`lag' = 0 if masEdad30Abril`lag' <=5 & masEdad30Abril`lag'!=.
			forvalues num = 1/12 {
				replace masEnAnosEducDeberia`lag' = `num' if masEdad30Abril`lag' == 5 + `num'
			}
			replace masEnAnosEducDeberia`lag' = 12 if masEdad30Abril`lag'>=18 & masEdad30Abril`lag'!=.
		}

		forvalues lag =  1/`lagN' {
			gen menosEnAnosEducDeberia`lag' = .
			replace menosEnAnosEducDeberia`lag' = 0 if menosEdad30Abril`lag' <=5 & menosEdad30Abril`lag'!=.
			forvalues num = 1/12 {
				replace menosEnAnosEducDeberia`lag' = `num' if menosEdad30Abril`lag' == 5 + `num'
			}
			replace menosEnAnosEducDeberia`lag' = 12 if menosEdad30Abril`lag'>=18 & menosEdad30Abril`lag'!=.
		}

		* Calculo año de eduación en la que efectivamente está el individuo
		gen zeroEnAnosEducEstaCEIP = .
		gen zeroEnAnosEducEstaCES = .
		gen zeroEnAnosEducEstaCETP = .
		gen zeroEnAnosEducEsta = .
		forvalues num = 1/6 {
		  replace zeroEnAnosEducEstaCEIP = `num' if zeroenCEIP == 1 & (zerocodGradoEscolar==`num' | zerocodGradoEscolar == 1 + `num'/10)
			replace zeroEnAnosEducEstaCES = 6 + `num' if zeroenCES==1 & zerogrado_liceo == `num'
		}
		replace zeroEnAnosEducEstaCEIP = 7 if zeroenCEIP == 1 & zerocodGradoEscolar==2.1
		replace zeroEnAnosEducEstaCEIP = 8 if zeroenCEIP == 1 & zerocodGradoEscolar==2.2
		replace zeroEnAnosEducEstaCEIP = 9 if zeroenCEIP == 1 & zerocodGradoEscolar==2.3

		replace zeroEnAnosEducEsta = max(zeroEnAnosEducEstaCEIP, zeroEnAnosEducEstaCES, zeroEnAnosEducEstaCETP)

		forvalues lag =  1/`leadN' {
		  gen masEnAnosEducEstaCEIP`lag' = .
		  gen masEnAnosEducEstaCES`lag' = .
		  gen masEnAnosEducEstaCETP`lag' = .
		  gen masEnAnosEducEsta`lag' = .
		  forvalues num = 1/6 {
			replace masEnAnosEducEstaCEIP`lag' = `num' if masenCEIP`lag' == 1 & (mascodGradoEscolar`lag'==`num' | mascodGradoEscolar`lag' == 1 + `num'/10)
			replace masEnAnosEducEstaCES`lag' = 6 + `num' if masenCES`lag'==1 & masgrado_liceo`lag' == `num'
		  }
		  replace masEnAnosEducEstaCEIP`lag' = 7 if masenCEIP`lag' == 1 & mascodGradoEscolar`lag'==2.1
		  replace masEnAnosEducEstaCEIP`lag' = 8 if masenCEIP`lag' == 1 & mascodGradoEscolar`lag'==2.2
		  replace masEnAnosEducEstaCEIP`lag' = 9 if masenCEIP`lag' == 1 & mascodGradoEscolar`lag'==2.3

		  replace masEnAnosEducEsta`lag' = max(masEnAnosEducEstaCEIP`lag', masEnAnosEducEstaCES`lag', masEnAnosEducEstaCETP`lag')
		}

		forvalues lag =  1/`lagN' {
		  gen menosEnAnosEducEstaCEIP`lag' = .
		  gen menosEnAnosEducEstaCES`lag' = .
		  gen menosEnAnosEducEstaCETP`lag' = .
		  gen menosEnAnosEducEsta`lag' = .
		  forvalues num = 1/6 {
			replace menosEnAnosEducEstaCEIP`lag' = `num' if menosenCEIP`lag' == 1 & (menoscodGradoEscolar`lag'==`num' | menoscodGradoEscolar`lag' == 1 + `num'/10)
			replace menosEnAnosEducEstaCES`lag' = 6 + `num' if menosenCES`lag'==1 & menosgrado_liceo`lag' == `num'
		  }
		  replace menosEnAnosEducEstaCEIP`lag' = 7 if menosenCEIP`lag' == 1 & menoscodGradoEscolar`lag'==2.1
		  replace menosEnAnosEducEstaCEIP`lag' = 8 if menosenCEIP`lag' == 1 & menoscodGradoEscolar`lag'==2.2
		  replace menosEnAnosEducEstaCEIP`lag' = 9 if menosenCEIP`lag' == 1 & menoscodGradoEscolar`lag'==2.3

		  replace menosEnAnosEducEsta`lag' = max(menosEnAnosEducEstaCEIP`lag', menosEnAnosEducEstaCES`lag', menosEnAnosEducEstaCETP`lag')
		}

		* Calculo último nivel cursado por el individuo (coincide con nivel que efectivamente cursa el individuo si estudia actualmente
		* o sino es el último nivel completado o cursado y dejado incompleto por el individuo)
		gen valorZero = 0
		egen zeroUltimoAnoCursado = rowmax(anosEduc zeroEnAnosEducEsta menosEnAnosEducEsta1-menosEnAnosEducEsta`lagN' valorZero)
		forvalues lag =  1/`leadN' {
		  egen masUltimoAnoCursado`lag' = rowmax(anosEduc zeroEnAnosEducEsta menosEnAnosEducEsta1-menosEnAnosEducEsta`lagN' masEnAnosEducEsta1-masEnAnosEducEsta`lag' valorZero)
		}
		forvalues lag =  1/`lagN' {
		  egen menosUltimoAnoCursado`lag' = rowmax(menosEnAnosEducEsta`lag'-menosEnAnosEducEsta`lagN')
		  replace menosUltimoAnoCursado`lag' = anosEduc if menosUltimoAnoCursado`lag' ==.
		  replace menosUltimoAnoCursado`lag' = 0 if menosUltimoAnoCursado`lag'==.
		}

		* Calculo años atrasado de educación del individuo
		gen zeroAnosAtrasados = zeroEnAnosEducDeberia - zeroUltimoAnoCursado
		forvalues lag = 1/`leadN' {
		  gen masAnosAtrasados`lag' = masEnAnosEducDeberia`lag' - masUltimoAnoCursado`lag'
		}
		forvalues lag =  1/`lagN' {
		  gen menosAnosAtrasados`lag' = menosEnAnosEducDeberia`lag' - menosUltimoAnoCursado`lag'
		}


		* RDD
		*rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0) covs(${AC`var'})
		*rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
		*rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
		*binscatter masocupadoSIIAS24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & zeroocupadoSIIAS==1 & departamento==1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)

		* Binscatters
		*binscatter masEstudiaCEIPCES24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita<=15 & edad_visita>=11 & zeroEstudiaCEIPCES==0, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)

		*** Different DID specifications

		** Spec 1: Aquellos que inicialmente recibían 1 TUS y tuvieron ICC menor (Treated) o mayor (Control) que el threshold TUS 1 (siempre threshold superior al cambio de AFAM)
		gen group1Treated = 0
		replace group1Treated = 1 if hogarZeroCuantasTus==1 & iccMenosThreshold1<0 & iccMenosThreshold0>0
		gen group1Control = 0
		replace group1Control = 1 if hogarZeroCuantasTus==1 & iccMenosThreshold1>0 & iccMenosThreshold0>0

		** Spec 2: Aquellos que inicialmente NO recibian TUS y tuvieron ICC menor (Control) o mayor (Treated) que el threshold TUS 1 (siempre threshold superior al cambio de AFAM)
		gen group2Treated = 0
		replace group2Treated = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1>0 & iccMenosThreshold0>0
		gen group2Control = 0
		replace group2Control = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1<0 & iccMenosThreshold0>0

		** Spec 3: Aquellos que inicialmente NO recibian TUS y tuvieron ICC menor (Control) que threshold TUS 1 o mayor que Threshold TUS 2 (Treated) (siempre threshold superior al cambio de AFAM)
		gen group3Treated = 0
		replace group3Treated = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold2>0 & iccMenosThreshold0>0
		gen group3Control = 0
		replace group3Control = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1<0 & iccMenosThreshold0>0

		** Spec 4: Aquellos que inicialmente recibian 2 TUS y tuvieron ICC menor (Treated) que el threshold TUS 1 o mayor que el threshold TUS 2 (Control) (siempre threshold superior al cambio de AFAM)
		gen group4Treated = 0
		replace group4Treated = 1 if hogarZeroCuantasTus==2 & iccMenosThreshold1<0 & iccMenosThreshold0>0
		gen group4Control = 0
		replace group4Control = 1 if hogarZeroCuantasTus==2 & iccMenosThreshold2>0 & iccMenosThreshold0>0

		keep if (group1Treated==1 | group1Control==1 | group2Treated==1 | group2Control==1 | group3Treated==1 | group3Control==1 | group4Treated==1 | group4Control==1)
		keep nrodocumentoSIIAS flowcorrelativeid edad_visita departamento sexo periodo fechanacimiento ///
		group1Treated group1Control group2Treated group2Control group3Treated group3Control group4Treated group4Control ///
		zeroEstudiaCEIPCES masEstudiaCEIPCES* menosEstudiaCEIPCES* zeroAnosAtrasados masAnosAtrasados* menosAnosAtrasados*

		save educ_para_probar_did.dta, replace // La guardo preliminarmente por si tengo q volver a cargar para no hacer todos los merge anteriores

		* Taggeo los duplicados y los elimino y también elimino observaciones con más de 15 años al momento de la visita
		duplicates tag nrodocumentoSIIAS, generate(dupl)
		*keep if dupl==0

		
		foreach spec in 1 2 3 4 {
			preserve
			keep if (group`spec'Treated==1 | group`spec'Control==1)
			gen periodoRelativoVisita=0
			gegen id=group(flowcorrelativeid nrodocumentoSIIAS)
			drop flowcorrelativeid nrodocumentoSIIAS

			xtset id periodoRelativoVisita
			expand `leadN'+`lagN'+1
			sort id
			by id: gen periodo1 =_n

			replace periodoRelativoVisita = periodo1 - `lagN' - 1
			foreach var in $varDeps {
			  generate `var'=.
			  replace `var'= zero`var' if periodoRelativoVisita==0

			  forvalues num = 1/`leadN' {
				replace `var'= mas`var'`num' if periodoRelativoVisita==`num'
			  }
			  forvalues num = 1/`lagN' {
				replace `var'= menos`var'`num' if periodoRelativoVisita==-`num'
			  }

			  forvalues num = 1/`leadN' {
				drop mas`var'`num'
			  }

			  forvalues num = 1/`lagN' {
				drop menos`var'`num'
			  }
			}
			gen zero =0
			replace zero=1 if periodoRelativoVisita==0
			forvalues num = 1/`leadN' {
				gen mas`num'=0
				replace mas`num'=1 if periodoRelativoVisita==`num'
			}
			forvalues num = 1/`lagN' {
					gen menos`num'=0
					replace menos`num'=1 if periodoRelativoVisita==-`num'
			}

			* Genero variables de control: dummies de edad, year, month, departamento, edad y edad^2, dummy de mujer
			tabulate departamento, generate(dep)
			gen mujer = .
			replace mujer=1 if sexo==2
			replace mujer=0 if sexo==1

			gen mdeo=.
			replace mdeo=1 if departamento==1
			replace mdeo=0 if departamento!=1 & departamento!=.

			* Year y mes
			merge m:1 periodo using ../../Build/Input/periodo_dictionary.dta, keep(master match)
			drop _merge
			rename mes mesVisita
			rename year yearVisita

			gen periodoObs = periodo + periodoRelativoVisita

			rename periodo periodoTemp
			rename periodoObs periodo

			merge m:1 periodo using ../../Build/Input/periodo_dictionary.dta, keep(master match)
			drop _merge
			rename periodo periodoObs
			rename periodoTemp periodo

			tabulate mes, generate(mes)
			tabulate year, generate(year)
			* drop if (year==2008 | year==2009) // 1% de obs
			* drop year1 year2

			* Variable de edad
			tostring fechanacimiento, generate(fechanacimiento_string)
			generate yearNac = substr(fechanacimiento_string, 1, 4)
			generate mesNac = substr(fechanacimiento_string, 5, 2)
			destring yearNac, replace
			destring mesNac, replace

			generate periodoNacimiento = (yearNac-2008)*12 + mesNac

			gen edad=floor((periodoObs-periodoNac)/12)
			gen edad2= edad * edad

			tabulate edad if edad>=0, generate(edadD)
			* drop if edad<0

			*** Genero variables y obtengo DID estimates
			xtset, clear
			gen zeroTreated`spec' = group`spec'Treated * zero
			gen zeroControl`spec' = group`spec'Control * zero
			forvalues num = 1/`leadN' {
				gen mas`num'Treated`spec'= group`spec'Treated * mas`num'
				gen mas`num'Control`spec'= group`spec'Control * mas`num'
			}
			forvalues num = 1/`lagN' {
				gen menos`num'Treated`spec'= group`spec'Treated * menos`num'
				gen menos`num'Control`spec'= group`spec'Control * menos`num'
			}

			if `leadN'==48 {
				global interactedLeads mas48Treated`spec' mas47Treated`spec' mas46Treated`spec' mas45Treated`spec' mas44Treated`spec' mas43Treated`spec' mas42Treated`spec' mas41Treated`spec' mas40Treated`spec' mas39Treated`spec' mas38Treated`spec' mas37Treated`spec' mas36Treated`spec' mas35Treated`spec' mas34Treated`spec' mas33Treated`spec' mas32Treated`spec' mas31Treated`spec' mas30Treated`spec' mas29Treated`spec' mas28Treated`spec' mas27Treated`spec' mas26Treated`spec' mas25Treated`spec' mas24Treated`spec' mas23Treated`spec' mas22Treated`spec' mas21Treated`spec' mas20Treated`spec' mas19Treated`spec' mas18Treated`spec' mas17Treated`spec' mas16Treated`spec' mas15Treated`spec' mas14Treated`spec' mas13Treated`spec' mas12Treated`spec' mas11Treated`spec' mas10Treated`spec' mas9Treated`spec' mas8Treated`spec' mas7Treated`spec' mas6Treated`spec' mas5Treated`spec' mas4Treated`spec' mas3Treated`spec' mas2Treated`spec' mas1Treated`spec'
				global periodsLeads mas48 mas47 mas46 mas45 mas44 mas43 mas42 mas41 mas40 mas39 mas38 mas37 mas36 mas35 mas34 mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1
			}
			else if `leadN'==36 {
				global interactedLeads mas36Treated`spec' mas35Treated`spec' mas34Treated`spec' mas33Treated`spec' mas32Treated`spec' mas31Treated`spec' mas30Treated`spec' mas29Treated`spec' mas28Treated`spec' mas27Treated`spec' mas26Treated`spec' mas25Treated`spec' mas24Treated`spec' mas23Treated`spec' mas22Treated`spec' mas21Treated`spec' mas20Treated`spec' mas19Treated`spec' mas18Treated`spec' mas17Treated`spec' mas16Treated`spec' mas15Treated`spec' mas14Treated`spec' mas13Treated`spec' mas12Treated`spec' mas11Treated`spec' mas10Treated`spec' mas9Treated`spec' mas8Treated`spec' mas7Treated`spec' mas6Treated`spec' mas5Treated`spec' mas4Treated`spec' mas3Treated`spec' mas2Treated`spec' mas1Treated`spec'
				global periodsLeads mas36 mas35 mas34 mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1
			}
			if `lagN'==12 {
				global interactedLags menos1Treated`spec' menos2Treated`spec' menos3Treated`spec' menos4Treated`spec' menos5Treated`spec' menos6Treated`spec' menos7Treated`spec' menos8Treated`spec' menos9Treated`spec' menos10Treated`spec' menos11Treated`spec'
				global periodsLags menos1 menos2 menos3 menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11
			}
			else if `lagN'==6 {
				global interactedLags menos1Treated`spec' menos2Treated`spec' menos3Treated`spec' menos4Treated`spec' menos5Treated`spec' 
				global periodsLags menos1 menos2 menos3 menos4 menos5
			}
			
			local leadAndlags `leadN'+`lagN'
			foreach var in $varDeps {
				matrix DIDla`lagN'le`leadN'`var'`spec' = J(`leadN' + 1 + `lagN' -1, 2,0)
				matrix colnames DIDla`lagN'le`leadN'`var'`spec' = Beta SE
				matrix rownames DIDla`lagN'le`leadN'`var'`spec' =  $interactedLeads zeroTreated`spec' $interactedLags
				
				regress `var' $interactedLeads zeroTreated`spec' $interactedLags group`spec'Treated $periodsLeads zero $periodsLags ///
				$controlsDID1 if edad_visita<=15 & edad_visita>=7, robust
				
				matrix matRes=e(b)'
				matrix matVar=e(V)
				mata st_matrix("matVar2",sqrt(diagonal(st_matrix("matVar"))))
				matrix DIDla`lagN'le`leadN'`var'`spec'[1,1] = matRes[1..`leadAndlags',1]
				matrix DIDla`lagN'le`leadN'`var'`spec'[1,2] = matVar2[1..`leadAndlags',1]	
				mat2txt, matrix(DIDla`lagN'le`leadN'`var'`spec') saving(DIDla`lagN'le`leadN'`var'`spec'.csv) replace
				}
			
			restore
		}

}
}
log close
