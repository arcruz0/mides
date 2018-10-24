* Objective: Mirar second stage de impacto TUS en variables de base visitas 
*               (para hogares revistados censalmenete).

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros

* Cargo base de personas
import delimited ..\Input\MIDES\visitas_personas_otras_vars.csv, clear
duplicates tag nrodocumento, generate(dobles)
drop if dobles==0

* Agrego variables de personas de base grande
merge 1:1 flowcorrelativeid nrodocumento using ..\Input\MIDES\visitas_personas_vars.dta, keep (master matched) keepusing (hogingtotalessintransferencias ingtotalessintransferencias hogingafam ingafam hogingtarjetaalimentaria ingtarjetaalimentaria embarazada situacionlaboral sexo parentesco asiste edad_visita nivelmasaltoalcanzado razonnofinalizo tomamedicacion discapacidad psiquiatrica)
drop _merge

* Merge con base hogares para agregar variables de hogares que quiera
merge m:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_vars.dta, keep (master matched) keepusing (colecho aguacorriente redelectrica residuoscuadra accesosaneamiento canasta aguascontaminadas merendero sinalimentos adultonocomio menornocomio contramujer contravaron contramenor contraadultomayor indocumentados calidadocupacionvivienda tienecalefon tienerefrigerador tienetvcable tienevideo tienelavarropas tienelavavajilla tienemicroondas tienecomputador tienetelefonofijo tienetelefonocelular tieneautomovil tienecomputadorplanceibal)
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

/*
* Elimino re-visitas que no fueron censales
drop if template == "Visita por CI" & visita3 == 1
drop if template == "Visita por CI" & visita2 == 1
duplicates tag nrodocumento, generate(doblesAgain)
drop if doblesAgain == 0

* Armo variable indicador de si estas en visita 1, 2, 3 (ya que al eliminar re-vistas no censales, numeración puede cambiar)
drop visita1 visita2 visita3

sort nrodocumento periodo
foreach num in 1 2 3 {
	generate visita`num' = 0
}

replace visita1 = 1 if nrodocumento[_n] != nrodocumento[_n-1]
replace visita2 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] != nrodocumento[_n-2]
replace visita3 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] == nrodocumento[_n-2]
*/

* Creo variables segun primera, segunda o tercera visita
rename hogingtotalessintransferencias hogingtotsintransf
rename ingtotalessintransferencias ingtotsintransf

gen mienteIngTarjeta = log(zeromonto_carga+1) - log(ingtarjetaalimentaria+1)
gen mienteHogIngTarjeta = log(hogarzeromonto_carga+1) - log(hogingtarjetaalimentaria+1)

ds nrodocumento umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam masmonto* masmenores* mascarga* mastus* mascobra* menos* pp2008 pp2011 pp2013 pp2016 susp* habilitado* zero* visita1 visita2 visita3, not

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

* Generate outcome variables
foreach tb in One Two {
gen asisteEscuela`tb' = 0
replace asisteEscuela`tb' = 1 if asiste`tb' == 1

gen hombre`tb' =.
replace hombre`tb' = 1 if sexo`tb' == 1
replace hombre`tb' = 0 if sexo`tb' == 2

gen uteRegularizado`tb' = .
replace uteRegularizado`tb' = 1 if redelectrica`tb' == 1
replace uteRegularizado`tb' = 0 if (redelectrica`tb' == 2 | redelectrica`tb' == 3)

gen oseRegularizado`tb' = .
replace oseRegularizado`tb' = 1 if aguacorriente`tb' == 1
replace oseRegularizado`tb' = 0 if (aguacorriente`tb' == 2 | aguacorriente`tb' == 3)

generate vdMujer`tb' = .
replace vdMujer`tb' = 1 if contramujer`tb' == 1
replace vdMujer`tb' = 0 if contramujer`tb' == 2

generate vdVaron`tb' = .
replace vdVaron`tb' = 1 if contravaron`tb' == 1
replace vdVaron`tb' = 0 if contravaron`tb' == 2

generate vdMenor`tb' = .
replace vdMenor`tb' = 1 if contramenor`tb' == 1
replace vdMenor`tb' = 0 if contramenor`tb' == 2

generate tomamedicacion18`tb' = .
replace tomamedicacion18`tb' = 1 if tomamedicacion`tb' == 1
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 2
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 0
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 97
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 99

generate discapacidadSi`tb' = .
replace discapacidadSi`tb' = 1 if discapacidad`tb' == 1
replace discapacidadSi`tb' = 0 if discapacidad`tb' == 2

generate psiquiatricaSi`tb' = .
replace psiquiatricaSi`tb' = 1 if psiquiatrica`tb' == 1
replace psiquiatricaSi`tb' = 0 if psiquiatrica`tb' == 2

generate vdAdultomayor`tb' = .
replace vdAdultomayor`tb' = 1 if contraadultomayor`tb' == 1
replace vdAdultomayor`tb' = 0 if contraadultomayor`tb' == 2

generate vd`tb' = vdMujer`tb' * vdVaron`tb' *  vdMenor`tb' * vdAdultomayor`tb'
replace vd`tb' = 1 if (vdMujer`tb' == 1 | vdVaron`tb' == 1 | vdMenor`tb' == 1 | vdAdultomayor`tb' == 1)

gen embarazada`tb'X = .
replace embarazada`tb'X = 1 if embarazada`tb' == 1
replace embarazada`tb'X = 0 if embarazada`tb' == 2
replace embarazada`tb'X = 0 if embarazada`tb' == 0
replace embarazada`tb'X = 0 if embarazada`tb' == 99
drop embarazada`tb'
rename embarazada`tb'X embarazada`tb'

gen merendero`tb'X = .
replace merendero`tb'X = 1 if merendero`tb' == 1
replace merendero`tb'X = 0 if merendero`tb' == 2
drop merendero`tb'
rename merendero`tb'X merendero`tb'

gen canasta`tb'X = .
replace canasta`tb'X = 1 if canasta`tb' == 1
replace canasta`tb'X = 0 if canasta`tb' == 2
drop canasta`tb'
rename canasta`tb'X canasta`tb'
}

* Generate control variables
generate iccNormPrimerTusOne = iccOne - umbral_nuevo_tus
generate iccNormSegundoTusOne = iccOne - umbral_nuevo_tus_dup

generate iccSuperaPrimerTUSOne=0
replace iccSuperaPrimerTUSOne=1 if iccOne >= umbral_nuevo_tus

generate iccSuperaSegundoTUSOne=0
replace iccSuperaSegundoTUSOne=1 if iccOne >= umbral_nuevo_tus_dup

generate iccNormInteractedPrimerTusOne= iccNormPrimerTusOne * iccSuperaPrimerTUSOne
generate iccNormInteractedSegundoTusOne= iccNormSegundoTusOne * iccSuperaSegundoTUSOne

generate iccNormPrimerTus2One = iccNormPrimerTusOne * iccNormPrimerTusOne
generate iccNormSegundoTus2One = iccNormSegundoTusOne * iccNormSegundoTusOne
generate iccNorm2InteractedPrimerTusOne = iccNormPrimerTus2One * iccSuperaPrimerTUSOne
generate iccNorm2InteractedSegundoTusOne = iccNormSegundoTus2One * iccSuperaSegundoTUSOne

generate mitadBajaICCOne = .
replace mitadBajaICCOne = 1 if iccOne < umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2
replace mitadBajaICCOne = 0 if iccOne >= umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2

generate iccNormPrimerTusSi = iccNormPrimerTus * mitadBajaICC
generate iccNormSegundoTusSi = iccNormSegundoTus * (1 - mitadBajaICC)
generate iccNormInteractedPrimerTusSi = iccNormInteractedPrimerTus * mitadBajaICC
generate iccNormInteractedSegundoTusSi = iccNormInteractedSegundoTus * (1 - mitadBajaICC)
generate iccSuperaPrimerTUSNoSec = iccSuperaPrimerTUS
replace iccSuperaPrimerTUSNoSec = 0 if iccSuperaSegundoTUS == 1

generate iccNormPrimerTus2Si = iccNormPrimerTus2 * mitadBajaICC
generate iccNormSegundoTus2Si = iccNormSegundoTus2 * (1 - mitadBajaICC)
generate iccNorm2InteractedPrimerTusSi = iccNorm2InteractedPrimerTus * mitadBajaICC
generate iccNorm2InteractedSegundoTusSi = iccNorm2InteractedSegundoTus * (1 - mitadBajaICC)

* Control variables not normalized
gen iccLessPrimTUSOne = 0
replace iccLessPrimTUSOne = iccOne if iccOne <= umbral_nuevo_tus

gen iccMoreSecTUSOne = 0
replace iccMoreSecTUSOne = iccOne if iccOne >= umbral_nuevo_tus_dup

gen iccMiddTUSOne = 0
replace iccMiddTUSOne = iccOne if iccOne < umbral_nuevo_tus_dup & iccOne > umbral_nuevo_tus

gen iccLessPrimTUS2One= iccLessPrimTUSOne * iccLessPrimTUSOne
gen iccMoreSecTUS2One = iccMoreSecTUSOne * iccMoreSecTUSOne
gen iccMiddTUS2One = iccMiddTUSOne * iccMiddTUSOne

* Variable to define bins
gen iccPrimTusOne0025 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 {
	replace iccPrimTusOne0025 = `bin'+11 if iccNormPrimerTusOne >= 0.025*(`bin'-1) & iccNormPrimerTusOne<0.025*`bin'
	replace iccPrimTusOne0025 = `bin' if iccNormPrimerTusOne < -0.025*(`bin'-1) & iccNormPrimerTusOne>=-0.025*`bin'
}

gen iccPrimTusOne005 = . 
foreach bin in 1 2 3 4 5 {
	replace iccPrimTusOne005 = `bin'+5 if iccNormPrimerTusOne >= 0.05*(`bin'-1) & iccNormPrimerTusOne<0.05*`bin'
	replace iccPrimTusOne005 = `bin' if iccNormPrimerTusOne < -0.05*(`bin'-1) & iccNormPrimerTusOne>=-0.05*`bin'
}

gen iccPrimTusOne002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 {
	replace iccPrimTusOne002 = `bin'+14 if iccNormPrimerTusOne >= 0.02*(`bin'-1) & iccNormPrimerTusOne<0.02*`bin'
	replace iccPrimTusOne002 = `bin' if iccNormPrimerTusOne < -0.02*(`bin'-1) & iccNormPrimerTusOne>=-0.02*`bin'
}

gen iccSegTusOne002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 {
	replace iccSegTusOne002 = `bin'+9 if iccNormSegundoTusOne >= 0.02*(`bin'-1) & iccNormSegundoTusOne<0.02*`bin'
	replace iccSegTusOne002 = `bin' if iccNormSegundoTusOne < -0.02*(`bin'-1) & iccNormSegundoTusOne>=-0.02*`bin'
}

gen iccSegTusOne0025 = . 
foreach bin in 1 2 3 4 5 6 7 {
	replace iccSegTusOne0025 = `bin'+7 if iccNormSegundoTusOne >= 0.025*(`bin'-1) & iccNormSegundoTusOne<0.025*`bin'
	replace iccSegTusOne0025 = `bin' if iccNormSegundoTusOne < -0.025*(`bin'-1) & iccNormSegundoTusOne>=-0.025*`bin'
}

gen iccSegTusOne005 = . 
foreach bin in 1 2 3 4 {
	replace iccSegTusOne005 = `bin'+4 if iccNormSegundoTusOne >= 0.05*(`bin'-1) & iccNormSegundoTusOne<0.05*`bin'
	replace iccSegTusOne005 = `bin' if iccNormSegundoTusOne < -0.05*(`bin'-1) & iccNormSegundoTusOne>=-0.05*`bin'
}

gen iccPrimTusOne003 = . 
foreach bin in 1 2 3 4 5 {
	replace iccPrimTusOne003 = `bin'+5 if iccNormPrimerTusOne >= 0.03*(`bin'-1) & iccNormPrimerTusOne<0.03*`bin'
	replace iccPrimTusOne003 = `bin' if iccNormPrimerTusOne < -0.03*(`bin'-1) & iccNormPrimerTusOne>=-0.03*`bin'
}

gen iccSegTusOne0017 = . 
foreach bin in 1 2 3 {
	replace iccSegTusOne0017 = `bin'+3 if iccNormSegundoTusOne >= 0.017*(`bin'-1) & iccNormSegundoTusOne<0.017*`bin'
	replace iccSegTusOne0017 = `bin' if iccNormSegundoTusOne < -0.017*(`bin'-1) & iccNormSegundoTusOne>=-0.017*`bin'
}

gen iccPrimTusOne0017 = . 
foreach bin in 1 2 3 {
	replace iccPrimTusOne0017 = `bin'+3 if iccNormPrimerTusOne >= 0.017*(`bin'-1) & iccNormPrimerTusOne<0.017*`bin'
	replace iccPrimTusOne0017 = `bin' if iccNormPrimerTusOne < -0.017*(`bin'-1) & iccNormPrimerTusOne>=-0.017*`bin'
}

*** Binscatters por persona
local bandwith = "0017"

** Educación
* All the sample (around 1st TUS)
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_TUS.png, replace

* All the sample (around 2nd TUS)
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_TUS.png, replace


* Not receiving TUS initially
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18 & hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_2TUS.png, replace

** Embarazada
* Not receiving TUS initially
binscatter embarazadaTwo iccNormPrimerTusOne if hombreOne==0 & hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter embarazadaTwo iccNormPrimerTusOne if hombreOne==0 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter embarazadaTwo iccNormSegundoTusOne if hombreOne==0 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter embarazadaTwo iccNormSegundoTusOne if hombreOne==0 & hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_seg_2TUS.png, replace

** Discapacidad
* Not receiving TUS initially
binscatter discapacidadSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter discapacidadSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter discapacidadSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter discapacidadSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_seg_2TUS.png, replace

** Pisquiatrica
* Not receiving TUS initially
binscatter psiquiatricaSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter psiquiatricaSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter psiquiatricaSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter psiquiatricaSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_seg_2TUS.png, replace

** Toma medicación para menores de 18 años
* Not receiving TUS initially
binscatter tomamedicacion18Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter tomamedicacion18Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter tomamedicacion18Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter tomamedicacion18Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_seg_2TUS.png, replace


*** Binscatters por hogar

** First stage
* Not receiving TUS initially
binscatter hogarzerocobratusTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(hogarzerocobratus segunda visita)
graph export ..\Output\hogarzerocobratusTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter hogarzerocobratusTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(hogarzerocobratus segunda visita)
graph export ..\Output\hogarzerocobratusTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter hogarzerotusdobleTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(hogarzerotusdoble segunda visita)
graph export ..\Output\hogarzerotusdobleTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter hogarzerotusdobleTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(hogarzerotusdoble segunda visita)
graph export ..\Output\hogarzerotusdobleTwo_seg_2TUS.png, replace


** Alimentacion
foreach var in sinalimentos adultonocomio menornocomio merendero canasta {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace
	
	* Receiving 1 TUS initially and in the threshold of losing it Para Mdeo
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1 & umbral_nuevo_tus<0.7, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUSMdeo.png, replace
	
}

* UTE, OSE regularizado
foreach var in uteRegularizado oseRegularizado {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace

}

* Violencia doméstica
foreach var in vd vdMujer vdMenor vdAdultomayor vdVaron {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace

}

* Indocumentados

* Not receiving TUS initially
binscatter indocumentadosTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter indocumentadosTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter indocumentadosTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter indocumentadosTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_seg_2TUS.png, replace

* Miente con tarjeta
foreach var in mienteIngTarjeta mienteHogIngTarjeta {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace
}

*** Regresiones
gen hogarNOzerocobratusTwo=0
replace hogarNOzerocobratusTwo=1 if hogarzerocobratusTwo ==0

** Alimentacion
foreach var in sinalimentos adultonocomio menornocomio merendero canasta {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds for Mdeo
	ivregress 2sls `var'Two `var'One iccLessPrimTUSOne iccMoreSecTUSOne iccMiddTUSOne iccLessPrimTUS2One iccMoreSecTUS2One iccMiddTUS2One (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	
	}


** Domestic violence
foreach var in vd vdMujer vdMenor vdAdultomayor vdVaron {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}
	
** UTE, OSE regularizado
foreach var in uteRegularizado oseRegularizado {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	
	}
	
** Embarazada
foreach var in embarazada {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0 & hombreOne==0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1 & hombreOne==0, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first	
	}

** Ingresos personal y del hogar
foreach var in hogingtotsintransf ingtotalessintransferencias {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}
	
* Mentiras con tarjeta mienteHogIngTarjeta
foreach var in mienteHogIngTarjeta mienteIngTarjeta {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}
