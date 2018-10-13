* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos completos de TUS
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

*** Macros
global vars_tus menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus

*** Load base TUS
import delimited ..\Input\TUS_Muestra_enmascarado.csv, clear

*** Me fijo si hay cédulas de identidad con más de una carga en mismo año y mes
generate n=_n // Voy a utilizar esta variable para drop observations repetidas
egen grupo=group(nrodocumento year month)
duplicates tag grupo, generate (grupo_unico)
*browse if grupo_unico!=0

* 2017: Hay solo un repetido
drop if nrodocumento=="676C13D00F9875015A5695925B1B1832" & monto_carga==. & year==2017 & month==2	// Hay solo un repetido en el 2017 y elimino el que parece incorrectamente cargado

* 2016: Hay 4 personas repetidas y son observaciones idénticamente repetidas, asi que elimino una de cada persona
drop if n==4280135 & nrodocumento=="53DAC7D161F77783D8F3C896DF309FA5"
drop if n==4290921 & nrodocumento=="9D591B7E1A5ADAADEBFF6E5191CC5D5F"
drop if n==4293616 & nrodocumento=="DAAF7011E336402FB93858A6DA09DCC3"
drop if n==4306946 & nrodocumento=="DB017C936898A04AE0D91CF4E36ED392"

* 2014: Hay dos personas repetidas dos veces (y en uno de esos casos por persona, con monot_carga 0 por lo que se elimina esa obs).
* A su vez, hay una persona repetida 6 veces en 3 meses (y tambien tiene monto_carga=0 en 3 de esas veces por lo que se eliminan esas obs)
drop if n==2909728 & nrodocumento=="14336D5776F6AE19B1C642CB9A8F72E6"
drop if n==3244730 & nrodocumento=="2DAC130982C77CD0457104C535452BA8"
drop if n==3081423 & nrodocumento=="137331DF628C1D39268624DC04FD40E7"
drop if n==3137611 & nrodocumento=="137331DF628C1D39268624DC04FD40E7"
drop if n==3193302 & nrodocumento=="137331DF628C1D39268624DC04FD40E7"

* 2013: Hay solo una persona repetida pero tiene distintos origenes de tarjeta. A priori se elimina una observacion random pero habría que revisar
drop if n==2617553 & nrodocumento=="2B806DEB8330D4ED08C7461E9F9241BA"

* 2012: Hay varias observaciones repetidas en los meses 1, 2 y 3. Para simplificar elimino todas las observaciones de estos meses pero habría que revisar esto
drop if year==2012 & (month==1 | month==2 | month==3)

* 2011: en meses 10, 11 y 12 hay en varios casos observaciones idénticamente repetidas. Se elimina una de cada par.
drop if n==1367682 & nrodocumento=="3367766381A33561B4B58F529D9D1242"
forvalues j=1/20 {
	drop if n==1367682 + `j'*2
}

* 2009: Hay observaciones repetidas en mes 8. Por ahora, elimino todas las observaciones de este mes pero habría que revisar esto
drop if year==2009 & month==8

*** Corrijo variables TUS que voy a quedarme
replace carga_mides=0 if carga_mides==.	// En algunos períodos coexistía la tarjeta MIDES y la INDA.
replace carga_inda=0 if carga_inda==.	

generate tusDoble=.
replace tusDoble=1 if duplicada==1
replace tusDoble=1 if duplica==1
replace tusDoble=1 if duplica_anterior==1
replace tusDoble=0 if duplicada==0
replace tusDoble=0 if duplica==0
replace tusDoble=0 if duplica_anterior==0

generate cobraTus=1

generate periodo = (year-2008)*12 + month	// Genero variable que se llama período y que es 1 si estas en ene-2008, 2 si feb-2008, etc

keep nrodocumento periodo year month menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus


* Genero 129 variables por variable: osea 129 variables del tipo monto_carga según el período
* Períodos van de 1 (ene-2008) hasta 129 (set-2018) que es último dato disponible de TUS
forvalues i = 1/129 {
	foreach var in $vars_tus {
		generate `var'`i'=.
		replace `var'`i'=`var' if periodo == `i'
		}
}

collapse (mean) menores_carga* monto_carga* carga_mides* carga_inda* tusDoble* cobraTus*, by(nrodocumento)
drop menores_carga monto_carga carga_mides carga_inda tusDoble cobraTus
save tus_para_merge.dta, replace

*** Load base personas
import delimited ..\Output\visitas_personas_vars.csv, clear
keep flowcorrelativeid nrodocumento fechanacimiento fechavisita icc periodo year month

* Merge base personas con datos de TUS
merge m:1 nrodocumento using tus_para_merge, keep(master matched)
drop _merge

* Genero 51 variables por variable: osea 51 variables del tipo monto_carga según el período
forvalues i = 1/24 {
	foreach var in $vars_tus {
		generate mas`var'`i'=.
			forvalues j = 1/129 { 
				replace mas`var'`i' = `var'`j' if periodo == `j' - `i'
		}
		}
}

forvalues i = 1/24 {
	foreach var in $vars_tus {
		generate menos`var'`i'=.
			forvalues j = 1/129 { 
				replace menos`var'`i' = `var'`j' if periodo == `j' + `i'
		}
		}
}

foreach var in $vars_tus {
	generate zero`var'=.
		forvalues j = 1/129 { 
				replace zero`var' = `var'`j' if periodo == `j'
}
}

* Elimino todas las variables por período
drop menores_carga* monto_carga* carga_mides* carga_inda* tusDoble* cobraTus*

* Genero variables a nivel de hogar
forvalues i = 1/24 {
	foreach var in $vars_tus {
		egen hogarMenos`var'`i' = max(menos`var'`i'), by(flowcorrelativeid)
		egen hogarMas`var'`i' = max(mas`var'`i'), by(flowcorrelativeid)
}
}

foreach var in $vars_tus {
		egen hogarZero`var' = max(zero`var'), by(flowcorrelativeid)
}

* Guardo base personas en csv para exportar
export delimited using ..\Output\visitas_personas_TUS.csv, replace

* Guardo base personas en dta para merge
collapse (mean) hogar*, by(flowcorrelativeid)
save personas_para_merge.dta, replace

*** Load base hogares
import delimited ..\Output\visitas_hogares_vars.csv, clear
keep flowcorrelativeid fechavisita year month periodo icc umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam

* Paso datos de TUS de base personas a Hogares
merge 1:1 flowcorrelativeid using personas_para_merge, keep(master matched) keepusing(hogar*)
drop _merge

* Cambio missing por zeros cuando corresponda
forvalues i = 1/24 {
	replace hogarMenoscobraTus`i' = 0 if hogarMenoscobraTus`i'==.
	replace hogarMascobraTus`i' = 0 if hogarMascobraTus`i'==.
	replace hogarZerocobraTus = 0 if hogarZerocobraTus==.
}

* Guardo base hogares en csv para exportar
export delimited using ..\Output\visitas_hogares_TUS.csv, replace

