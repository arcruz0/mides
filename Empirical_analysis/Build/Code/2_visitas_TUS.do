* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos completos de TUS
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

*** Macros
global vars_tus menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template latitudGeo longitudGeo calidadGeo


*** Load base TUS
import delimited ..\Input\TUS_Muestra_enmascarado.csv, clear case(preserve)
rename nrodocumento nrodocumentoDAES

*** Me fijo si hay cédulas de identidad con más de una carga en mismo año y mes
generate n = _n // Voy a utilizar esta variable para drop observations repetidas
gegen grupo = group(nrodocumentoDAES year month)
duplicates tag grupo, generate (grupo_unico)
*browse if grupo_unico!=0

* 2017: Hay solo un repetido
drop if nrodocumentoDAES=="676C13D00F9875015A5695925B1B1832" & monto_carga==. & year==2017 & month==2	// Hay solo un repetido en el 2017 y elimino el que parece incorrectamente cargado

* 2016: Hay 4 personas repetidas y son observaciones idénticamente repetidas, asi que elimino una de cada persona
drop if n==4280135 & nrodocumentoDAES=="53DAC7D161F77783D8F3C896DF309FA5"
drop if n==4290921 & nrodocumentoDAES=="9D591B7E1A5ADAADEBFF6E5191CC5D5F"
drop if n==4293616 & nrodocumentoDAES=="DAAF7011E336402FB93858A6DA09DCC3"
drop if n==4306946 & nrodocumentoDAES=="DB017C936898A04AE0D91CF4E36ED392"

* 2014: Hay dos personas repetidas dos veces (y en uno de esos casos por persona, con monto_carga 0 por lo que se elimina esa obs).
* A su vez, hay una persona repetida 6 veces en 3 meses (y tambien tiene monto_carga=0 en 3 de esas veces por lo que se eliminan esas obs)
drop if n==2909728 & nrodocumentoDAES=="14336D5776F6AE19B1C642CB9A8F72E6"
drop if n==3244730 & nrodocumentoDAES=="2DAC130982C77CD0457104C535452BA8"
drop if n==3081423 & nrodocumentoDAES=="137331DF628C1D39268624DC04FD40E7"
drop if n==3137611 & nrodocumentoDAES=="137331DF628C1D39268624DC04FD40E7"
drop if n==3193302 & nrodocumentoDAES=="137331DF628C1D39268624DC04FD40E7"

* 2013: Hay solo una persona repetida pero tiene distintos origenes de tarjeta. A priori se elimina una observacion random pero habría que revisar
drop if n==2617553 & nrodocumentoDAES=="2B806DEB8330D4ED08C7461E9F9241BA"

* 2012: Hay varias observaciones repetidas en los meses 1, 2 y 3. Elimino aleatoriamente una de las repetidas
sort grupo_unico year month nrodocumentoDAES
gen number = 1
replace number = 2 if grupo[_n] == grupo[_n-1]
replace number = 3 if grupo[_n] == grupo[_n-1] & grupo[_n-1] == grupo[_n-2]
drop if year==2012 & (month==1 | month==2 | month==3) & (number == 2 | number ==3)

* 2011: en meses 10, 11 y 12 hay en varios casos observaciones idénticamente repetidas. Se elimina una de cada par.
drop if year==2011 & (month==10 | month==11 | month==12) & number == 2

* 2009: Hay observaciones repetidas en mes 8. Por ahora, elimino aleatoriamente una de ellas y pongo datos de monto_carga, carga_inda, carga_mides, menores_carga como missing
drop if year==2009 & month==8 & number==2
foreach var in menores_carga monto_carga carga_mides carga_inda {
replace `var' = . if year==2009 & month==8 & grupo_unico ==1
}

*** Corrijo variables TUS que voy a quedarme
replace carga_mides=0 if carga_mides==.	// En algunos períodos coexistía la tarjeta MIDES y la INDA.
replace carga_inda=0 if carga_inda==.	

* En algunos casos duplica y duplicada no coinciden!!! Aquí estoy tomando 1 si una de las dos es 1 pero habría que REVISAR ESTO
generate tusDoble=.
replace tusDoble=0 if duplicada==0
replace tusDoble=0 if duplica==0
replace tusDoble=0 if duplica_anterior==0
replace tusDoble=1 if duplicada==1
replace tusDoble=1 if duplica==1
replace tusDoble=1 if duplica_anterior==1

generate cobraTus=1

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

keep nrodocumentoDAES periodo year month menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus


* Genero 110 variables por variable: osea 110 variables del tipo monto_carga según el período
* Períodos van de 20 (ago-2009) hasta 129 (set-2018) que es último dato disponible de TUS (datos TUS comienzan en agosto 2009)
forvalues i = 20/129 {
	foreach var in $vars_tus {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

* Hay muchos períodos para los cuales no hay datos de TUS por lo que directamente elimino estas variables (datos TUS comienzan en agosto 2009)
* Períodos sin datos: 
* 2009: 9, 10, 11 						(períodos 21, 22, 23)
* 2010: 1, 5, 7 						(períodos 25, 29, 31)
* 2012: 11								(períodos 59)
* 2013: 2, 4, 12						(períodos 62, 64, 72)

foreach val in 21 22 23 25 29 31 59 62 64 72 {
	foreach var in $vars_tus {
		drop `var'`val'
}
}

* Armo la base TUS con una fila por numero de documento
drop menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus
gcollapse (mean) menores_carga* monto_carga* carga_mides* carga_inda* tusDoble* cobraTus*, by(nrodocumentoDAES)
save tus_para_merge.dta, replace

*** Load base personas
import delimited ..\Output\visitas_personas_vars.csv, clear case(preserve)
keep $varsKeep nrodocumentoDAES nrodocumentoSIIAS

* Merge base personas con datos de TUS
merge m:1 nrodocumentoDAES using tus_para_merge, keep(master matched)
drop _merge

* Cambio missing por zeros de datos merged desde TUS
forvalues i = 20/129 {
	foreach var in $vars_tus {
			cap replace `var'`i' = 0 if `var'`i' ==.
}
}

* Genero 49 variables por variable: osea 49 variables del tipo monto_carga como +- fecha de visita
* (para algunas fechas pongo dato del mes anterior si hay missing value para cierto mes-año) (con más datos para luego de visita)
forvalues i = 1/60 {
	foreach var in $vars_tus {
		generate mas`var'`i'=.
			forvalues j = 20/129 {
				local j2 = `j' - 1
				if (`j' == 59 | `j' == 62 | `j' == 64 | `j' == 72) {
					replace mas`var'`i' = `var'`j2' if periodo == `j' - `i'
					}
				else {
					cap replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
					}
		}
		}
}

forvalues i = 1/24 {
	foreach var in $vars_tus {
		generate menos`var'`i'=.
			forvalues j = 20/129 {
				local j2 = `j' - 1
				if (`j' == 59 | `j' == 62 | `j' == 64 | `j' == 72) {
					replace menos`var'`i' = `var'`j2' if periodo == `j' + `i'
					}
				else {
					cap replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
					}
		}
		}
}

foreach var in $vars_tus {
	generate zero`var'=.
		forvalues j = 20/129 {
			local j2 = `j' - 1
			if (`j' == 59 | `j' == 62 | `j' == 64 | `j' == 72) {
				cap replace zero`var' = `var'`j2' if periodo == `j'
				}
			else {
				cap replace zero`var' = `var'`j' if periodo == `j'
				}
}
}


* Genero variables a nivel de hogar medidas como +- fecha de visita
forvalues i = 1/24 {
	foreach var in $vars_tus {
		gegen hogarMenos`var'`i' = max(menos`var'`i'), by(flowcorrelativeid)
		}
	gegen hogarMenoscuantTus`i' = total(menoscobraTus`i'), by(flowcorrelativeid)
	gegen hogarMenoscuantTusDob`i' = total(menostusDoble`i'), by(flowcorrelativeid)
	gegen hogarMenoscuantMinor`i' = total(menosmenores_carga`i'), by(flowcorrelativeid)
	gegen hogarMenoscuantMto`i' = total(menosmonto_carga`i'), by(flowcorrelativeid)
}

forvalues i = 1/60 {
	foreach var in $vars_tus {
		gegen hogarMas`var'`i' = max(mas`var'`i'), by(flowcorrelativeid)
		}
	gegen hogarMascuantTus`i' = total(mascobraTus`i'), by(flowcorrelativeid)
	gegen hogarMascuantTusDob`i' = total(mastusDoble`i'), by(flowcorrelativeid)
	gegen hogarMascuantMinor`i' = total(masmenores_carga`i'), by(flowcorrelativeid)
	gegen hogarMascuantMto`i' = total(masmonto_carga`i'), by(flowcorrelativeid)
}


foreach var in $vars_tus {
		gegen hogarZero`var' = max(zero`var'), by(flowcorrelativeid)
}
gegen hogarZerocuantTus = total(zerocobraTus), by(flowcorrelativeid)
gegen hogarZerocuantTusDob = total(zerotusDoble), by(flowcorrelativeid)
gegen hogarZerocuantMinor = total(zeromenores_carga), by(flowcorrelativeid)
gegen hogarZerocuantMto = total(zeromonto_carga), by(flowcorrelativeid)


* Genero variables a nivel de hogar medidas según el período
forvalues i = 20/129 {
	foreach var in $vars_tus {
		cap gegen hogar`var'`i' = max(`var'`i'), by(flowcorrelativeid)
		cap gegen hogar`var'`i' = max(`var'`i'), by(flowcorrelativeid)
	cap gegen hogarcuantTus`i' = total(cobraTus`i'), by(flowcorrelativeid)
	cap gegen hogarcuantTusDob`i' = total(tusDoble`i'), by(flowcorrelativeid)
	cap gegen hogarcuantMinor`i' = total(menores_carga`i'), by(flowcorrelativeid)
	cap gegen hogarcuantMto`i' = total(monto_carga`i'), by(flowcorrelativeid)
}
}

* Genero variables de si hogar perdió, ganó, mantuvo transferencia 12 y 6 meses luego de visita (para los mapas)
foreach val in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 {
gen hogar0a0Mes`val' = .
replace hogar0a0Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=.
replace hogar0a0Mes`val' = 1 if hogarZerocobraTus==0 & hogarMascobraTus`val'==0

gen hogar0a1Mes`val' = .
replace hogar0a1Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarMastusDoble`val'!=.
replace hogar0a1Mes`val' = 1 if hogarZerocobraTus==0 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==0

gen hogar0a2Mes`val' = .
replace hogar0a2Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarMastusDoble`val'!=.
replace hogar0a2Mes`val' = 1 if hogarZerocobraTus==0 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==1

gen hogar1a0Mes`val' = .
replace hogar1a0Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=.
replace hogar1a0Mes`val' = 1 if hogarZerotusDoble==0 & hogarZerocobraTus==1 & hogarMascobraTus`val'==0

gen hogar1a1Mes`val' = .
replace hogar1a1Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=. & hogarMastusDoble`val'!=.
replace hogar1a1Mes`val' = 1 if hogarZerotusDoble==0 & hogarZerocobraTus==1 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==0

gen hogar1a2Mes`val' = .
replace hogar1a2Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=. & hogarMastusDoble`val'!=.
replace hogar1a2Mes`val' = 1 if hogarZerotusDoble==0 & hogarZerocobraTus==1 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==1

gen hogar2a0Mes`val' = .
replace hogar2a0Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=.
replace hogar2a0Mes`val' = 1 if hogarZerotusDoble==1 & hogarZerocobraTus==1 & hogarMascobraTus`val'==0

gen hogar2a1Mes`val' = .
replace hogar2a1Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=. & hogarMastusDoble`val'!=.
replace hogar2a1Mes`val' = 1 if hogarZerotusDoble==1 & hogarZerocobraTus==1 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==0

gen hogar2a2Mes`val' = .
replace hogar2a2Mes`val' = 0 if hogarZerocobraTus!=. & hogarMascobraTus`val'!=. & hogarZerotusDoble!=. & hogarMastusDoble`val'!=.
replace hogar2a2Mes`val' = 1 if hogarZerotusDoble==1 & hogarZerocobraTus==1 & hogarMascobraTus`val'==1 & hogarMastusDoble`val'==1

gen hogarMantuvoMes`val' = .
replace hogarMantuvoMes`val' = 1 if (hogar2a2Mes`val'==1 | hogar1a1Mes`val'==1 | hogar0a0Mes`val'==1)

gen hogarPerdioMes`val' = .
replace hogarPerdioMes`val' = 1 if (hogar2a1Mes`val'==1 | hogar2a0Mes`val'==1 | hogar1a0Mes`val'==1)

gen hogarGanoMes`val' = .
replace hogarGanoMes`val' = 1 if (hogar0a1Mes`val'==1 | hogar0a2Mes`val'==1 | hogar1a2Mes`val'==1)

replace hogarMantuvoMes`val' = 0 if (hogarPerdioMes`val'==1 | hogarGanoMes`val' ==1)
replace hogarPerdioMes`val' = 0 if (hogarMantuvoMes`val'==1 | hogarGanoMes`val' ==1)
replace hogarGanoMes`val' = 0 if (hogarMantuvoMes`val'==1 | hogarPerdioMes`val' ==1)

generate hogarIndexTotCambios`val' = .
replace hogarIndexTotCambios`val' = 1 if hogar0a0Mes`val'==1
replace hogarIndexTotCambios`val' = 2 if hogar0a1Mes`val'==1
replace hogarIndexTotCambios`val' = 3 if hogar0a2Mes`val'==1
replace hogarIndexTotCambios`val' = 4 if hogar1a0Mes`val'==1
replace hogarIndexTotCambios`val' = 5 if hogar1a1Mes`val'==1
replace hogarIndexTotCambios`val' = 6 if hogar1a2Mes`val'==1
replace hogarIndexTotCambios`val' = 7 if hogar2a0Mes`val'==1
replace hogarIndexTotCambios`val' = 8 if hogar2a1Mes`val'==1
replace hogarIndexTotCambios`val' = 9 if hogar2a2Mes`val'==1

generate hogarIndexCambios`val' = .
replace hogarIndexCambios`val' = 1 if hogarPerdioMes`val'==1
replace hogarIndexCambios`val' = 2 if hogarMantuvoMes`val'==1
replace hogarIndexCambios`val' = 3 if hogarGanoMes`val'==1
}

* Guardo base personas en csv y dta para exportar
export delimited using ..\Output\visitas_personas_TUS.csv, replace
save ..\Output\visitas_personas_TUS.dta, replace

* Guardo base personas en dta para merge
gcollapse (mean) hogar*, by(flowcorrelativeid)
save personas_para_merge.dta, replace

*** Load base hogares
import delimited ..\Output\visitas_hogares_vars.csv, clear case(preserve)
keep $varsKeep

* Paso datos de TUS de base personas a Hogares
merge 1:1 flowcorrelativeid using personas_para_merge, keep(master matched) keepusing(hogar*)
drop _merge

* Guardo base hogares en csv para exportar
export delimited using ..\Output\visitas_hogares_TUS.csv, replace
save ..\Output\visitas_hogares_TUS.dta, replace
