* Objective: Mirar second stage de impacto TUS en variables de base visitas 
*               (para hogares revistados censalmenete).

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Cargo base de personas y elimino variables que no interesan y personas no revistadas
import delimited ..\Input\visitas_personas_vars.csv, clear
save visitas_personas_vars.dta, replace

import delimited ..\Input\visitas_personas_otras_vars.csv, clear
duplicates tag nrodocumento, generate(dobles)
drop if dobles==0

merge 1:1 flowcorrelativeid nrodocumento using visitas_personas_vars.dta, keep (master matched) keepusing (situacionlaboral sexo parentesco asiste edad_visita nivelmasaltoalcanzado ingtotalessintransferencias razonnofinalizo tomamedicacion ingtarjetaalimentaria ingafam discapacidad psiquiatrica)
drop _merge
save personas_revisitadas.dta, replace

* Merge con base hogares para agregar variables de hogares que quiera, en especial variable template
import delimited ..\Input\visitas_hogares_vars.csv, clear
save visitas_hogares_vars.dta, replace

use personas_revisitadas.dta, clear
merge m:1 flowcorrelativeid using visitas_hogares_vars.dta, keep (master matched) keepusing (template colecho aguacorriente redelectrica residuoscuadra aguascontaminadas merendero sinalimentos adultonocomio menornocomio contramujer contravaron contramenor contraadultomayor indocumentados calidadocupacionvivienda)
drop _merge


* Elimino personas que fueron visitadas más de 3 veces (98% de los revisitados fueron revisitads solamente 1,2, o 3 veces)
drop if dobles>3

* Armo variable indicador si estas en período 1 o 2 o 3
sort nrodocumento periodo
foreach num in 1 2 3 {
	generate visita`num' = 0
}

replace visita1 = 1 if nrodocumento[_n] != nrodocumento[_n-1]
replace visita2 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] != nrodocumento[_n-2]
replace visita3 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] == nrodocumento[_n-2]

* Elimino personas que no fueron re-vistadas censalmente
drop if template == "Visita por CI" & visita3 == 1
drop if template == "Visita por CI" & visita2 == 1
duplicates tag nrodocumento, generate(doblesAgain)
drop if doblesAgain == 0

* Creo variables segun primera, segunda o tercera visita
ds nrodocumento umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam masmenores_carga1 masmonto* masmenores* mascarga* mastus* mascobra* menos* pp2008 pp2011 pp2013 pp2016 susp* habilitado* zero* visita1 visita2 visita3, not

foreach var in `r(varlist)' {
	generate `var'One = `var'
	generate `var'Two = `var'
	generate `var'Three = `var'
	cap replace `var'One = "" if visita1 != 1
	cap replace `var'One = . if visita1 != 1
	cap replace `var'Two = "" if visita2 != 1
	cap replace `var'Two = . if visita2 != 1
	cap replace `var'Three = "" if visita3 != 1
	cap replace `var'Three = . if visita3 != 1
	drop `var'
}

drop visita1 visita2 visita3

* Colapso observaciones para que cada cédula de identidad solo tenga una fila
ds nrodocumento, not
collapse (firstnm) `r(varlist)', by(nrodocumento)

* Generate variables
gen asisteEscuelaTwo = 0
replace asisteEscuelaTwo = 1 if asisteTwo == 1

gen hombreOne =.
replace hombreOne = 1 if sexoOne == 1
replace hombreOne = 0 if sexoOne == 2

gen uteRegularizadoTwo = .
replace uteRegularizadoTwo = 1 if redelectricaTwo == 1
replace uteRegularizadoTwo = 0 if (redelectricaTwo == 2 | redelectricaTwo == 3)

gen oseRegularizadoTwo = .
replace oseRegularizadoTwo = 1 if aguacorrienteTwo == 1
replace oseRegularizadoTwo = 0 if (aguacorrienteTwo == 2 | aguacorrienteTwo == 3)

generate vdMujerTwo = .
replace vdMujerTwo = 1 if contramujerTwo == 1
replace vdMujerTwo = 0 if contramujerTwo == 2

generate vdVaronTwo = .
replace vdVaronTwo = 1 if contravaronTwo == 1
replace vdVaronTwo = 0 if contravaronTwo == 2

generate vdMenorTwo = .
replace vdMenorTwo = 1 if contramenorTwo == 1
replace vdMenorTwo = 0 if contramenorTwo == 2

generate vdAdultomayorTwo = .
replace vdAdultomayorTwo = 1 if contraadultomayorTwo == 1
replace vdAdultomayorTwo = 0 if contraadultomayorTwo == 2

generate vdTwo = vdMujerTwo * vdVaronTwo *  vdMenorTwo * vdAdultomayorTwo
replace vdTwo = 1 if (vdMujerTwo == 1 | vdVaronTwo == 1 | vdMenorTwo == 1 | vdAdultomayorTwo == 1)


* Binscatters
binscatter asisteEscuelaTwo iccOne if umbral_nuevo_tus<0.65 & edad_visitaTwo<18 & hogarzerocobratusOne == 1 & iccOne>0.4 & iccOne<0.8, nquantiles (50) controls(edad_visitaOne edad_visitaTwo) rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Asiste segunda visita)
binscatter asisteEscuelaTwo iccOne if umbral_nuevo_tus>0.65 & edad_visitaTwo<18 & hogarzerocobratusOne == 1 & iccOne>0.4 & iccOne<0.8, controls(edad_visitaOne edad_visitaTwo) rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Asiste segunda visita)
binscatter hombreOne iccOne if umbral_nuevo_tus>0.65 & edad_visitaTwo<18 & hogarzerocobratusOne == 1 & iccOne>0.4 & iccOne<0.8, controls(edad_visitaOne edad_visitaTwo) rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Asiste segunda visita)

* Binscatters por hogar
binscatter sinalimentosTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter adultonocomioTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter menornocomioTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter uteRegularizadoTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter oseRegularizadoTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter vdTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter vdMujerTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter vdMenorTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter vdMenorTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter indocumentadosTwo iccOne if umbral_nuevo_tus<0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
binscatter indocumentadosTwo iccOne if umbral_nuevo_tus>0.65 & iccOne>0.5 & iccOne<0.9 & parentescoOne == 1, rd(0.70024848) linetype(qfit) xtitle(ICC) ytitle(Var hogar en 2da visita)
