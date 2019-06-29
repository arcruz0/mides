* Objective: Mirar second stage de impacto TUS en PP.

clear all
local dir `c(pwd)'
cd `c(pwd)'
cd ..
cd ..
cd Analysis
cd Temp

*cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load dataset a nivel de personas con datos de voting PP
import delimited ..\Input\MIDES\visitas_personas_PPySusp.csv, clear case(preserve)

* Agrego variables de personas de base completa
merge 1:1 flowcorrelativeid nrodocumento using ..\Input\MIDES\visitas_personas_vars.dta, keep (master matched) keepusing(edad_visita sexo parentesco)
drop _merge

* Agrego variables de base TUS
merge 1:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_TUS.dta, keep (master matched) keepusing(hogarzerocobratus hogarzerotusdoble hogarcobratus5* hogartusdoble5* hogarcobratus6* hogartusdoble6* hogarcobratus7* hogartusdoble7* hogarcobratus8* hogartusdoble8* hogarcobratus9* hogartusdoble9* hogarcobratus10* hogartusdoble10* hogarcobratus11* hogartusdoble11* hogarmascobratus* hogarmenoscobratus* hogarmastusdoble* hogarmenostusdoble*)
drop _merge

* Macros
global bandwiths1y2Tus 1 0.2 0.1 0.05
global bandwiths1o2Tus 1 0.3 0.2 0.1 0.05
global periodo2016 periodo2016_1==1 periodo2016_2==1
global periodo2013 periodo2013_1==1 periodo2013_2==1
global periodo20132016 periodo20132016_1==1 periodo20132016_2==1
global ctrls2016 "" pp2013 pp2011 pp2008 ""
global ctrls2013 "" pp2011 pp2008 ""
global ctrls20132016 "" pp2011 pp2008 ""
global poly ""iccNormPrimerTusSi iccNormInteractedPrimerTusSi iccNormPrimerTus2Si iccNorm2InteractedPrimerTusSi iccNormSegundoTusSi iccNormInteractedSegundoTusSi iccNormSegundoTus2Si iccNorm2InteractedSegundoTusSi"" ""iccSuperaPrimerTUSNoSec iccNormPrimerTusSi iccNormInteractedPrimerTusSi iccSuperaSegundoTUS iccNormSegundoTusSi iccNormInteractedSegundoTusSi""
global depVarVoting2016 pp2016
global depVarVoting2013 pp2013
global depVarVoting20132016 pp20132016
global cobraZero hogarzerocobratusSimple==1 hogarzerocobratus==0 hogarzerotusdoble==1 hogarzerocobratus!=2
global endog2013 hogarCambioEnThres20130t3 hogarCambioEnThres20130t5 hogarCambioEnThres20131t3 hogarCambioEnThres20131t5
global endog2016 hogarCambioEnThres20160t3 hogarCambioEnThres20160t5 hogarCambioEnThres20161t3 hogarCambioEnThres20161t5
global endog20132016 hogarCambioEnThres201320160t3 hogarCambioEnThres201320160t5 hogarCambioEnThres201320161t3 hogarCambioEnThres201320161t5
global instrumentPrimTUS iccSuperaPrimerTUS
global instrumentSegTUS iccSuperaSegundoTUS

*** Generate variables

* Dependent variables
generate pp20132016=.
replace pp20132016=pp2013 if year==2013
replace pp20132016=pp2016 if year==2016

generate habilitado20132016=.
replace habilitado20132016=habilitado2013 if year==2013
replace habilitado20132016=habilitado2016 if year==2016


** Variable de si hogar ganó o perdió 1 o 2 TUS 1,...,12 meses antes de la elección de 2013 o de 2016

* 2013
* Hogar perdió una simple
foreach ms in 0 1 2 3 4 5 7 9 10 12 {	// No genero variables en nov-2012, feb-2013, abr-2013 por no haber datos TUS en ese momento
	generate hogPerdioSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogPerdioSimple2013`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
		else {
		replace hogPerdioSimple2013`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per3' == 1 & hogartusdoble`per3' == 0	
	}
	}
	}

* Hogar ganó una simple
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogGanoSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogGanoSimple2013`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per2' == 0 & hogartusdoble`per2' == 0
		else {
		replace hogGanoSimple2013`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per3' == 0 & hogartusdoble`per3' == 0
	}
	}
	}
	
* Hogar pasó de simple a doble
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogSimpleToDoub2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogSimpleToDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
		else {
		replace hogSimpleToDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per3' == 1 & hogartusdoble`per3' == 0
	}
	}
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogDoubToSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogDoubToSimple2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per2' == 1
		else {
		replace hogDoubToSimple2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per3' == 1
	}
	}
	}

* Hogar pasó de doble a 0
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogPerdioDoub2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogPerdioDoub2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per2' == 1
		else {
		replace hogPerdioDoub2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per3' == 1
	}
	}
	}

* Hogar pasó de 0 a doble
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogGanoDoub2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	local per3 = 70 - `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace hogGanoDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 0
		else {
		replace hogGanoDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per3' == 0
	}
	}
	}	

* Hogar pasó de 0 a single o doble TUS
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
gen hogGano2013`ms' = 0
replace hogGano2013`ms' = 1 if (hogGanoDoub2013`ms' == 1 | hogGanoSimple2013`ms' == 1)
}

* Hogar pasó de 1/2 TUS a nada
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
gen hogPerdio2013`ms' = 0
replace hogPerdio2013`ms' = 1 if (hogPerdioDoub2013`ms' == 1 | hogPerdioSimple2013`ms' == 1)
}

* 2016
* Hogar perdió una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogPerdioSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogPerdioSimple2016`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
	}
	
* Hogar ganó una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogGanoSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogGanoSimple2016`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per2' == 0 & hogartusdoble`per2' == 0
	}
	
	
* Hogar pasó de simple a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogSimpleToDoub2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogSimpleToDoub2016`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogDoubToSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogDoubToSimple2016`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per2' == 1
	}

* Hogar pasó de doble a 0
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogPerdioDoub2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogPerdioDoub2016`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per2' == 1
	}
	
* Hogar pasó de 0 a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate hogGanoDoub2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogGanoDoub2016`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 0
	}	

* Hogar pasó de 0 a single o doble TUS
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
gen hogGano2016`ms' = 0
replace hogGano2016`ms' = 1 if (hogGanoDoub2016`ms' == 1 | hogGanoSimple2016`ms' == 1)
}

* Hogar pasó de 1/2 TUS a nada
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
gen hogPerdio2016`ms' = 0
replace hogPerdio2016`ms' = 1 if (hogPerdioDoub2016`ms' == 1 | hogPerdioSimple2016`ms' == 1)
}

* 2013 y 2016
foreach ms in 0 1 2 3 4 5 7 9 10 12 {
	generate hogDoubToSimple20132016`ms' = hogDoubToSimple2013`ms' + hogDoubToSimple2016`ms'
	generate hogSimpleToDoub20132016`ms' = hogSimpleToDoub2013`ms' + hogSimpleToDoub2016`ms'
	generate hogGanoSimple20132016`ms' = hogGanoSimple2013`ms' + hogGanoSimple2016`ms'
	generate hogPerdioSimple20132016`ms' = hogPerdioSimple2013`ms' + hogPerdioSimple2016`ms'
	generate hogPerdioDoub20132016`ms' = hogPerdioDoub2013`ms' + hogPerdioDoub2016`ms'
	generate hogGanoDoub20132016`ms' = hogGanoDoub2013`ms' + hogGanoDoub2016`ms'
	generate hogGano20132016`ms' = hogGano2013`ms' + hogGano2016`ms'
	generate hogPerdio20132016`ms' = hogPerdio2013`ms' + hogPerdio2016`ms'
	}
	
* Agregados por períodos	

* 0-3
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t3 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3
	generate hogGanoSimple`yr'0t3 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3
	generate hogSimpleToDoub`yr'0t3 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3
	generate hogDoubToSimple`yr'0t3 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3
	generate hogPerdioDoub`yr'0t3 = hogPerdioDoub`yr'0 + hogPerdioDoub`yr'1 + hogPerdioDoub`yr'2 + hogPerdioDoub`yr'3
	generate hogGanoDoub`yr'0t3 = hogGanoDoub`yr'0 + hogGanoDoub`yr'1 + hogGanoDoub`yr'2 + hogGanoDoub`yr'3
	generate hogGano`yr'0t3 = hogGano`yr'0 + hogGano`yr'1 + hogGano`yr'2 + hogGano`yr'3
	generate hogPerdio`yr'0t3 = hogPerdio`yr'0 + hogPerdio`yr'1 + hogPerdio`yr'2 + hogPerdio`yr'3	
	gen hogarCambioEnThres`yr'0t3 = 0
	replace hogarCambioEnThres`yr'0t3 = 1 if (hogPerdioSimple`yr'0t3 + hogGanoSimple`yr'0t3 + hogSimpleToDoub`yr'0t3 + hogDoubToSimple`yr'0t3)>0
}
* 0-2
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t2 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2
	generate hogGanoSimple`yr'0t2 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2
	generate hogSimpleToDoub`yr'0t2 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2
	generate hogDoubToSimple`yr'0t2 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2
	gen hogarCambioEnThres`yr'0t2 = 0
	replace hogarCambioEnThres`yr'0t2 = 1 if (hogPerdioSimple`yr'0t2 + hogGanoSimple`yr'0t2 + hogSimpleToDoub`yr'0t2 + hogDoubToSimple`yr'0t2)>0
	generate hogGano`yr'0t2 = hogGano`yr'0 + hogGano`yr'1 + hogGano`yr'2
	generate hogPerdio`yr'0t2 = hogPerdio`yr'0 + hogPerdio`yr'1 + hogPerdio`yr'2	
	}
* 0-5
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t5 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3 + hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5
	generate hogGanoSimple`yr'0t5 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3 + hogGanoSimple`yr'4 + hogGanoSimple`yr'5
	generate hogSimpleToDoub`yr'0t5 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3 + hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5
	generate hogDoubToSimple`yr'0t5 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3 + hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5
	gen hogarCambioEnThres`yr'0t5 = 0
	replace hogarCambioEnThres`yr'0t5 = 1 if (hogPerdioSimple`yr'0t5 + hogGanoSimple`yr'0t5 + hogSimpleToDoub`yr'0t5 + hogDoubToSimple`yr'0t5)>0
	generate hogGano`yr'0t5 = hogGano`yr'0 + hogGano`yr'1 + hogGano`yr'2 + hogGano`yr'3 + hogGano`yr'4 + hogGano`yr'5
	generate hogPerdio`yr'0t5 = hogPerdio`yr'0 + hogPerdio`yr'1 + hogPerdio`yr'2 + hogPerdio`yr'3 + hogPerdio`yr'4  + hogPerdio`yr'5 		
	}

* 1-3
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t3 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3
	generate hogGanoSimple`yr'1t3 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3
	generate hogSimpleToDoub`yr'1t3 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3
	generate hogDoubToSimple`yr'1t3 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3
	gen hogarCambioEnThres`yr'1t3 = 0
	replace hogarCambioEnThres`yr'1t3 = 1 if (hogPerdioSimple`yr'1t3 + hogGanoSimple`yr'1t3 + hogSimpleToDoub`yr'1t3 + hogDoubToSimple`yr'1t3)>0
	generate hogGano`yr'1t3 = hogGano`yr'1 + hogGano`yr'2 + hogGano`yr'3
	generate hogPerdio`yr'1t3 = hogPerdio`yr'1 + hogPerdio`yr'2 + hogPerdio`yr'3		
	generate hogGanoDoub`yr'1t3 = hogGanoDoub`yr'1 + hogGanoDoub`yr'2 + hogGanoDoub`yr'3
	generate hogPerdioDoub`yr'1t3 = hogPerdioDoub`yr'1 + hogPerdioDoub`yr'2 + hogPerdioDoub`yr'3
	}

* 1-2
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t2 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2
	generate hogGanoSimple`yr'1t2 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2
	generate hogSimpleToDoub`yr'1t2 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2
	generate hogDoubToSimple`yr'1t2 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2
	gen hogarCambioEnThres`yr'1t2 = 0
	replace hogarCambioEnThres`yr'1t2 = 1 if (hogPerdioSimple`yr'1t2 + hogGanoSimple`yr'1t2 + hogSimpleToDoub`yr'1t2 + hogDoubToSimple`yr'1t2)>0
	generate hogGano`yr'1t2 = hogGano`yr'1 + hogGano`yr'2
	generate hogPerdio`yr'1t2 = hogPerdio`yr'1 + hogPerdio`yr'2			
	}
	
* 1-5
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t5 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3 + hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5
	generate hogGanoSimple`yr'1t5 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3 + hogGanoSimple`yr'4 + hogGanoSimple`yr'5
	generate hogSimpleToDoub`yr'1t5 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3 + hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5
	generate hogDoubToSimple`yr'1t5 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3 + hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5
	gen hogarCambioEnThres`yr'1t5 = 0
	replace hogarCambioEnThres`yr'1t5 = 1 if (hogPerdioSimple`yr'1t5 + hogGanoSimple`yr'1t5 + hogSimpleToDoub`yr'1t5 + hogDoubToSimple`yr'1t5)>0
	generate hogGano`yr'1t5 = hogGano`yr'1 + hogGano`yr'2 + hogGano`yr'3 + hogGano`yr'4 + hogGano`yr'5
	generate hogPerdio`yr'1t5 = hogPerdio`yr'1 + hogPerdio`yr'2 + hogPerdio`yr'3 + hogPerdio`yr'4 + hogPerdio`yr'5			
	}

* 4-6
foreach yr in 2013 20132016 {
	generate hogPerdioSimple`yr'4t6 = hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5
	generate hogGanoSimple`yr'4t6 = hogGanoSimple`yr'4 + hogGanoSimple`yr'5
	generate hogSimpleToDoub`yr'4t6 = hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5
	generate hogDoubToSimple`yr'4t6 = hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5
	gen hogarCambioEnThres`yr'4t6 = 0
	replace hogarCambioEnThres`yr'4t6 = 1 if (hogPerdioSimple`yr'4t6 + hogGanoSimple`yr'4t6 + hogSimpleToDoub`yr'4t6 + hogDoubToSimple`yr'4t6)>0
	generate hogGano`yr'4t6 = hogGano`yr'4 + hogGano`yr'5
	generate hogPerdio`yr'4t6 = hogPerdio`yr'4 + hogPerdio`yr'5		
	}
	
	foreach yr in 2016 {
	generate hogPerdioSimple`yr'4t6 = hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5 + hogPerdioSimple`yr'6
	generate hogGanoSimple`yr'4t6 = hogGanoSimple`yr'4 + hogGanoSimple`yr'5 + hogGanoSimple`yr'6
	generate hogSimpleToDoub`yr'4t6 = hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5 + hogSimpleToDoub`yr'6
	generate hogDoubToSimple`yr'4t6 = hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5 + hogDoubToSimple`yr'6
	gen hogarCambioEnThres`yr'4t6 = 0
	replace hogarCambioEnThres`yr'4t6 = 1 if (hogPerdioSimple`yr'4t6 + hogGanoSimple`yr'4t6 + hogSimpleToDoub`yr'4t6 + hogDoubToSimple`yr'4t6)>0
	generate hogGano`yr'4t6 = hogGano`yr'4 + hogGano`yr'5 + hogGano`yr'6
	generate hogPerdio`yr'4t6 = hogPerdio`yr'4 + hogPerdio`yr'5 + hogPerdio`yr'6
	generate hogGanoDoub`yr'4t6 = hogGanoDoub`yr'4 + hogGanoDoub`yr'5 + hogGanoDoub`yr'6
	generate hogPerdioDoub`yr'4t6 = hogPerdioDoub`yr'4 + hogPerdioDoub`yr'5 + hogPerdioDoub`yr'6
	}

* 7-9
foreach yr in 2013 20132016 {
	generate hogPerdioSimple`yr'7t9 = hogPerdioSimple`yr'7 + hogPerdioSimple`yr'9
	generate hogGanoSimple`yr'7t9 = hogGanoSimple`yr'7 + hogGanoSimple`yr'9
	generate hogSimpleToDoub`yr'7t9 = hogSimpleToDoub`yr'7 + hogSimpleToDoub`yr'9
	generate hogDoubToSimple`yr'7t9 = hogDoubToSimple`yr'7 + hogDoubToSimple`yr'9
	gen hogarCambioEnThres`yr'7t9 = 0
	replace hogarCambioEnThres`yr'7t9 = 1 if (hogPerdioSimple`yr'7t9 + hogGanoSimple`yr'7t9 + hogSimpleToDoub`yr'7t9 + hogDoubToSimple`yr'7t9)>0
	generate hogGano`yr'7t9 = hogGano`yr'7 + hogGano`yr'9
	generate hogPerdio`yr'7t9 = hogPerdio`yr'7 + hogPerdio`yr'9		
	}
	
foreach yr in 2016 {
	generate hogPerdioSimple`yr'7t9 = hogPerdioSimple`yr'7 + hogPerdioSimple`yr'8 + hogPerdioSimple`yr'9
	generate hogGanoSimple`yr'7t9 = hogGanoSimple`yr'7 + hogGanoSimple`yr'8 + hogGanoSimple`yr'9
	generate hogSimpleToDoub`yr'7t9 = hogSimpleToDoub`yr'7 + hogSimpleToDoub`yr'8 + hogSimpleToDoub`yr'9
	generate hogDoubToSimple`yr'7t9 = hogDoubToSimple`yr'7 + hogDoubToSimple`yr'8 + hogDoubToSimple`yr'9
	gen hogarCambioEnThres`yr'7t9 = 0
	replace hogarCambioEnThres`yr'7t9 = 1 if (hogPerdioSimple`yr'7t9 + hogGanoSimple`yr'7t9 + hogSimpleToDoub`yr'7t9 + hogDoubToSimple`yr'7t9)>0
	generate hogGano`yr'7t9 = hogGano`yr'7 + hogGano`yr'8 + hogGano`yr'9
	generate hogPerdio`yr'7t9 = hogPerdio`yr'7 + hogPerdio`yr'8 + hogPerdio`yr'9		
	generate hogGanoDoub`yr'7t9 = hogGanoDoub`yr'7 + hogGanoDoub`yr'8 + hogGanoDoub`yr'9
	generate hogPerdioDoub`yr'7t9 = hogPerdioDoub`yr'7 + hogPerdioDoub`yr'8 + hogPerdioDoub`yr'9
	}

* 10-12
foreach yr in 2013 20132016 {
	generate hogPerdioSimple`yr'10t12 = hogPerdioSimple`yr'10 + hogPerdioSimple`yr'12
	generate hogGanoSimple`yr'10t12 = hogGanoSimple`yr'10 + hogGanoSimple`yr'12
	generate hogSimpleToDoub`yr'10t12 = hogSimpleToDoub`yr'10 + hogSimpleToDoub`yr'12
	generate hogDoubToSimple`yr'10t12 = hogDoubToSimple`yr'10 + hogDoubToSimple`yr'12
	gen hogarCambioEnThres`yr'10t12 = 0
	replace hogarCambioEnThres`yr'10t12 = 1 if (hogPerdioSimple`yr'10t12 + hogGanoSimple`yr'10t12 + hogSimpleToDoub`yr'10t12 + hogDoubToSimple`yr'10t12)>0
	generate hogGano`yr'10t12 = hogGano`yr'10 + hogGano`yr'12
	generate hogPerdio`yr'10t12 = hogPerdio`yr'10 + hogPerdio`yr'12		
	}
	
foreach yr in 2016 {
	generate hogPerdioSimple`yr'10t12 = hogPerdioSimple`yr'10 + hogPerdioSimple`yr'11 + hogPerdioSimple`yr'12
	generate hogGanoSimple`yr'10t12 = hogGanoSimple`yr'10 + hogGanoSimple`yr'11 + hogGanoSimple`yr'12
	generate hogSimpleToDoub`yr'10t12 = hogSimpleToDoub`yr'10 + hogSimpleToDoub`yr'11 + hogSimpleToDoub`yr'12
	generate hogDoubToSimple`yr'10t12 = hogDoubToSimple`yr'10 + hogDoubToSimple`yr'11 + hogDoubToSimple`yr'12
	gen hogarCambioEnThres`yr'10t12 = 0
	replace hogarCambioEnThres`yr'10t12 = 1 if (hogPerdioSimple`yr'10t12 + hogGanoSimple`yr'10t12 + hogSimpleToDoub`yr'10t12 + hogDoubToSimple`yr'10t12)>0
	generate hogGano`yr'10t12 = hogGano`yr'10 + hogGano`yr'11 + hogGano`yr'12
	generate hogPerdio`yr'10t12 = hogPerdio`yr'10 + hogPerdio`yr'11 + hogPerdio`yr'12		
	generate hogGanoDoub`yr'10t12 = hogGanoDoub`yr'10 + hogGanoDoub`yr'11 + hogGanoDoub`yr'12
	generate hogPerdioDoub`yr'10t12 = hogPerdioDoub`yr'10 + hogPerdioDoub`yr'11 + hogPerdioDoub`yr'12
	}
			
** Variable de si hogar ganó o perdió 1 o 2 TUS 1,...,12 meses DESPUÉS de la elección de 2013 o de 2016

* 2013
* Hogar perdió una simple
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {	// No genero variables en dic-2013 por no haber datos TUS en ese momento
	generate DhogPerdioSimple2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogPerdioSimple2013`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
		else {
		replace DhogPerdioSimple2013`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per3' == 1 & hogartusdoble`per3' == 0	
	}
	}
	}

* Hogar ganó una simple
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogGanoSimple2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogGanoSimple2013`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per2' == 0 & hogartusdoble`per2' == 0
		else {
		replace DhogGanoSimple2013`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per3' == 0 & hogartusdoble`per3' == 0
	}
	}
	}
	
* Hogar pasó de simple a doble
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogSimpleToDoub2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogSimpleToDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
		else {
		replace DhogSimpleToDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per3' == 1 & hogartusdoble`per3' == 0
	}
	}
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogDoubToSimple2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogDoubToSimple2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per2' == 1
		else {
		replace DhogDoubToSimple2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per3' == 1
	}
	}
	}

* Hogar pasó de doble a 0
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogPerdioDoub2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogPerdioDoub2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per2' == 1
		else {
		replace DhogPerdioDoub2013`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per3' == 1
	}
	}
	}

* Hogar pasó de 0 a doble
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogGanoDoub2013`ms' = 0
	local per = 70 + `ms'
	local per2 = 70 + `ms' -1
	local per3 = 70 + `ms' -2
	capture confirm variable hogarcobratus`per2'
	if !_rc {
		replace DhogGanoDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 0
		else {
		replace DhogGanoDoub2013`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per3' == 0
	}
	}
	}
	
* 2016
* Hogar perdió una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogPerdioSimple2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogPerdioSimple2016`ms' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
	}
	
* Hogar ganó una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogGanoSimple2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogGanoSimple2016`ms' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per2' == 0 & hogartusdoble`per2' == 0
	}
	
	
* Hogar pasó de simple a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogSimpleToDoub2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogSimpleToDoub2016`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 1 & hogartusdoble`per2' == 0
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogDoubToSimple2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogDoubToSimple2016`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 1 & hogartusdoble`per2' == 1
	}

* Hogar pasó de doble a 0
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogPerdioDoub2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogPerdioDoub2016`ms' = 1 if hogartusdoble`per' == 0 & hogarcobratus`per' == 0 & hogartusdoble`per2' == 1
	}
	
* Hogar pasó de 0 a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12 {
	generate DhogGanoDoub2016`ms' = 0
	local per = 106 + `ms'
	local per2 = 106 + `ms' -1
	replace DhogGanoDoub2016`ms' = 1 if hogartusdoble`per' == 1 & hogarcobratus`per2' == 0
	}	
	
* 2013 y 2016
foreach ms in 0 1 3 4 5 6 7 8 9 10 11 12 {
	generate DhogDoubToSimple20132016`ms' = DhogDoubToSimple2013`ms' + DhogDoubToSimple2016`ms'
	generate DhogSimpleToDoub20132016`ms' = DhogSimpleToDoub2013`ms' + DhogSimpleToDoub2016`ms'
	generate DhogGanoSimple20132016`ms' = DhogGanoSimple2013`ms' + DhogGanoSimple2016`ms'
	generate DhogPerdioSimple20132016`ms' = DhogPerdioSimple2013`ms' + DhogPerdioSimple2016`ms'
	generate DhogPerdioDoub20132016`ms' = DhogPerdioDoub2013`ms' + DhogPerdioDoub2016`ms'
	generate DhogGanoDoub20132016`ms' = DhogGanoDoub2013`ms' + DhogGanoDoub2016`ms'
	}
	
* Agregados por períodos	

* 0-3
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'0t3 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'3
	generate DhogGanoSimple`yr'0t3 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1 + DhogGanoSimple`yr'3
	generate DhogSimpleToDoub`yr'0t3 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'3
	generate DhogDoubToSimple`yr'0t3 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'3
	generate DhogGanoDoub`yr'0t3 = DhogGanoDoub`yr'0 + DhogGanoDoub`yr'1 + DhogGanoDoub`yr'3
	generate DhogPerdioDoub`yr'0t3 = DhogPerdioDoub`yr'0 + DhogPerdioDoub`yr'1 + DhogPerdioDoub`yr'3
	gen DhogarCambioEnThres`yr'0t3 = 0
	replace DhogarCambioEnThres`yr'0t3 = 1 if (DhogPerdioSimple`yr'0t3 + DhogGanoSimple`yr'0t3 + DhogSimpleToDoub`yr'0t3 + DhogDoubToSimple`yr'0t3)>0
}

foreach yr in 2016 {
	generate DhogPerdioSimple`yr'0t3 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2 + DhogPerdioSimple`yr'3
	generate DhogGanoSimple`yr'0t3 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2 + DhogGanoSimple`yr'3
	generate DhogSimpleToDoub`yr'0t3 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2 + DhogSimpleToDoub`yr'3
	generate DhogDoubToSimple`yr'0t3 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2 + DhogDoubToSimple`yr'3
	generate DhogGanoDoub`yr'0t3 = DhogGanoDoub`yr'0 + DhogGanoDoub`yr'1 + DhogGanoDoub`yr'2 + DhogGanoDoub`yr'3
	generate DhogPerdioDoub`yr'0t3 = DhogPerdioDoub`yr'0 + DhogPerdioDoub`yr'1 + DhogPerdioDoub`yr'2 + DhogPerdioDoub`yr'3
	gen DhogarCambioEnThres`yr'0t3 = 0
	replace DhogarCambioEnThres`yr'0t3 = 1 if (DhogPerdioSimple`yr'0t3 + DhogGanoSimple`yr'0t3 + DhogSimpleToDoub`yr'0t3 + DhogDoubToSimple`yr'0t3)>0
}

* 0-2
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'0t2 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1
	generate DhogGanoSimple`yr'0t2 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1
	generate DhogSimpleToDoub`yr'0t2 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1
	generate DhogDoubToSimple`yr'0t2 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1
	gen DhogarCambioEnThres`yr'0t2 = 0
	replace DhogarCambioEnThres`yr'0t2 = 1 if (DhogPerdioSimple`yr'0t2 + DhogGanoSimple`yr'0t2 + DhogSimpleToDoub`yr'0t2 + DhogDoubToSimple`yr'0t2)>0
}

foreach yr in 2016 {
	generate DhogPerdioSimple`yr'0t2 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2
	generate DhogGanoSimple`yr'0t2 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2
	generate DhogSimpleToDoub`yr'0t2 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2
	generate DhogDoubToSimple`yr'0t2 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2
	gen DhogarCambioEnThres`yr'0t2 = 0
	replace DhogarCambioEnThres`yr'0t2 = 1 if (DhogPerdioSimple`yr'0t2 + DhogGanoSimple`yr'0t2 + DhogSimpleToDoub`yr'0t2 + DhogDoubToSimple`yr'0t2)>0
}

* 0-5
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'0t5 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'3 + DhogPerdioSimple`yr'4 + DhogPerdioSimple`yr'5
	generate DhogGanoSimple`yr'0t5 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1 + DhogGanoSimple`yr'3 + DhogGanoSimple`yr'4 + DhogGanoSimple`yr'5
	generate DhogSimpleToDoub`yr'0t5 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'3 + DhogSimpleToDoub`yr'4 + DhogSimpleToDoub`yr'5
	generate DhogDoubToSimple`yr'0t5 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'3 + DhogDoubToSimple`yr'4 + DhogDoubToSimple`yr'5
	gen DhogarCambioEnThres`yr'0t5 = 0
	replace DhogarCambioEnThres`yr'0t5 = 1 if (DhogPerdioSimple`yr'0t5 + DhogGanoSimple`yr'0t5 + DhogSimpleToDoub`yr'0t5 + DhogDoubToSimple`yr'0t5)>0
	}

foreach yr in 2016 {
	generate DhogPerdioSimple`yr'0t5 = DhogPerdioSimple`yr'0 + DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2 + DhogPerdioSimple`yr'3 + DhogPerdioSimple`yr'4 + DhogPerdioSimple`yr'5
	generate DhogGanoSimple`yr'0t5 = DhogGanoSimple`yr'0 + DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2 + DhogGanoSimple`yr'3 + DhogGanoSimple`yr'4 + DhogGanoSimple`yr'5
	generate DhogSimpleToDoub`yr'0t5 = DhogSimpleToDoub`yr'0 + DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2 + DhogSimpleToDoub`yr'3 + DhogSimpleToDoub`yr'4 + DhogSimpleToDoub`yr'5
	generate DhogDoubToSimple`yr'0t5 = DhogDoubToSimple`yr'0 + DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2 + DhogDoubToSimple`yr'3 + DhogDoubToSimple`yr'4 + DhogDoubToSimple`yr'5
	gen DhogarCambioEnThres`yr'0t5 = 0
	replace DhogarCambioEnThres`yr'0t5 = 1 if (DhogPerdioSimple`yr'0t5 + DhogGanoSimple`yr'0t5 + DhogSimpleToDoub`yr'0t5 + DhogDoubToSimple`yr'0t5)>0
	}
	
* 1-3
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'1t3 = DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'3
	generate DhogGanoSimple`yr'1t3 = DhogGanoSimple`yr'1 + DhogGanoSimple`yr'3
	generate DhogSimpleToDoub`yr'1t3 = DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'3
	generate DhogDoubToSimple`yr'1t3 = DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'3
	gen DhogarCambioEnThres`yr'1t3 = 0
	replace DhogarCambioEnThres`yr'1t3 = 1 if (DhogPerdioSimple`yr'1t3 + DhogGanoSimple`yr'1t3 + DhogSimpleToDoub`yr'1t3 + DhogDoubToSimple`yr'1t3)>0
	}
	
foreach yr in 2016 {
	generate DhogPerdioSimple`yr'1t3 = DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2 + DhogPerdioSimple`yr'3
	generate DhogGanoSimple`yr'1t3 = DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2 + DhogGanoSimple`yr'3
	generate DhogSimpleToDoub`yr'1t3 = DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2 + DhogSimpleToDoub`yr'3
	generate DhogDoubToSimple`yr'1t3 = DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2 + DhogDoubToSimple`yr'3
	gen DhogarCambioEnThres`yr'1t3 = 0
	replace DhogarCambioEnThres`yr'1t3 = 1 if (DhogPerdioSimple`yr'1t3 + DhogGanoSimple`yr'1t3 + DhogSimpleToDoub`yr'1t3 + DhogDoubToSimple`yr'1t3)>0
	generate DhogGanoDoub`yr'1t3 = DhogGanoDoub`yr'1 + DhogGanoDoub`yr'2 + DhogGanoDoub`yr'3
	generate DhogPerdioDoub`yr'1t3 = DhogPerdioDoub`yr'1 + DhogPerdioDoub`yr'2 + DhogPerdioDoub`yr'3
	}
	
* 1-2
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'1t2 = DhogPerdioSimple`yr'1
	generate DhogGanoSimple`yr'1t2 = DhogGanoSimple`yr'1
	generate DhogSimpleToDoub`yr'1t2 = DhogSimpleToDoub`yr'1
	generate DhogDoubToSimple`yr'1t2 = DhogDoubToSimple`yr'1
	gen DhogarCambioEnThres`yr'1t2 = 0
	replace DhogarCambioEnThres`yr'1t2 = 1 if (DhogPerdioSimple`yr'1t2 + DhogGanoSimple`yr'1t2 + DhogSimpleToDoub`yr'1t2 + DhogDoubToSimple`yr'1t2)>0
	}
	
foreach yr in 2016 {
	generate DhogPerdioSimple`yr'1t2 = DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2
	generate DhogGanoSimple`yr'1t2 = DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2
	generate DhogSimpleToDoub`yr'1t2 = DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2
	generate DhogDoubToSimple`yr'1t2 = DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2
	gen DhogarCambioEnThres`yr'1t2 = 0
	replace DhogarCambioEnThres`yr'1t2 = 1 if (DhogPerdioSimple`yr'1t2 + DhogGanoSimple`yr'1t2 + DhogSimpleToDoub`yr'1t2 + DhogDoubToSimple`yr'1t2)>0
	}
	
* 1-5
foreach yr in 2013 20132016 {
	generate DhogPerdioSimple`yr'1t5 = DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'3 + DhogPerdioSimple`yr'4 + DhogPerdioSimple`yr'5
	generate DhogGanoSimple`yr'1t5 = DhogGanoSimple`yr'1 + DhogGanoSimple`yr'3 + DhogGanoSimple`yr'4 + DhogGanoSimple`yr'5
	generate DhogSimpleToDoub`yr'1t5 = DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'3 + DhogSimpleToDoub`yr'4 + DhogSimpleToDoub`yr'5
	generate DhogDoubToSimple`yr'1t5 = DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'3 + DhogDoubToSimple`yr'4 + DhogDoubToSimple`yr'5
	gen DhogarCambioEnThres`yr'1t5 = 0
	replace DhogarCambioEnThres`yr'1t5 = 1 if (DhogPerdioSimple`yr'1t5 + DhogGanoSimple`yr'1t5 + DhogSimpleToDoub`yr'1t5 + DhogDoubToSimple`yr'1t5)>0
	}

foreach yr in 2016 {
	generate DhogPerdioSimple`yr'1t5 = DhogPerdioSimple`yr'1 + DhogPerdioSimple`yr'2 + DhogPerdioSimple`yr'3 + DhogPerdioSimple`yr'4 + DhogPerdioSimple`yr'5
	generate DhogGanoSimple`yr'1t5 = DhogGanoSimple`yr'1 + DhogGanoSimple`yr'2 + DhogGanoSimple`yr'3 + DhogGanoSimple`yr'4 + DhogGanoSimple`yr'5
	generate DhogSimpleToDoub`yr'1t5 = DhogSimpleToDoub`yr'1 + DhogSimpleToDoub`yr'2 + DhogSimpleToDoub`yr'3 + DhogSimpleToDoub`yr'4 + DhogSimpleToDoub`yr'5
	generate DhogDoubToSimple`yr'1t5 = DhogDoubToSimple`yr'1 + DhogDoubToSimple`yr'2 + DhogDoubToSimple`yr'3 + DhogDoubToSimple`yr'4 + DhogDoubToSimple`yr'5
	gen DhogarCambioEnThres`yr'1t5 = 0
	replace DhogarCambioEnThres`yr'1t5 = 1 if (DhogPerdioSimple`yr'1t5 + DhogGanoSimple`yr'1t5 + DhogSimpleToDoub`yr'1t5 + DhogDoubToSimple`yr'1t5)>0
	}

* 4-6
foreach yr in 2016 {
	generate DhogPerdioSimple`yr'4t6 = DhogPerdioSimple`yr'4 + DhogPerdioSimple`yr'5 + DhogPerdioSimple`yr'6
	generate DhogGanoSimple`yr'4t6 = DhogGanoSimple`yr'4 + DhogGanoSimple`yr'5 + DhogGanoSimple`yr'6
	generate DhogSimpleToDoub`yr'4t6 = DhogSimpleToDoub`yr'4 + DhogSimpleToDoub`yr'5 + DhogSimpleToDoub`yr'6
	generate DhogDoubToSimple`yr'4t6 = DhogDoubToSimple`yr'4 + DhogDoubToSimple`yr'5 + DhogDoubToSimple`yr'6
	gen DhogarCambioEnThres`yr'4t6 = 0
	replace DhogarCambioEnThres`yr'4t6 = 1 if (DhogPerdioSimple`yr'4t6 + DhogGanoSimple`yr'4t6 + DhogSimpleToDoub`yr'4t6 + DhogDoubToSimple`yr'4t6)>0
	generate DhogGanoDoub`yr'4t6 = DhogGanoDoub`yr'4 + DhogGanoDoub`yr'5 + DhogGanoDoub`yr'6
	generate DhogPerdioDoub`yr'4t6 = DhogPerdioDoub`yr'4 + DhogPerdioDoub`yr'5 + DhogPerdioDoub`yr'6
	}
	
* 7-9
foreach yr in 2016 {
	generate DhogPerdioSimple`yr'7t9 = DhogPerdioSimple`yr'7 + DhogPerdioSimple`yr'8 + DhogPerdioSimple`yr'9
	generate DhogGanoSimple`yr'7t9 = DhogGanoSimple`yr'7 + DhogGanoSimple`yr'8 + DhogGanoSimple`yr'9
	generate DhogSimpleToDoub`yr'7t9 = DhogSimpleToDoub`yr'7 + DhogSimpleToDoub`yr'8 + DhogSimpleToDoub`yr'9
	generate DhogDoubToSimple`yr'7t9 = DhogDoubToSimple`yr'7 + DhogDoubToSimple`yr'8 + DhogDoubToSimple`yr'9
	gen DhogarCambioEnThres`yr'7t9 = 0
	replace DhogarCambioEnThres`yr'7t9 = 1 if (DhogPerdioSimple`yr'7t9 + DhogGanoSimple`yr'7t9 + DhogSimpleToDoub`yr'7t9 + DhogDoubToSimple`yr'7t9)>0
	generate DhogGanoDoub`yr'7t9 = DhogGanoDoub`yr'7 + DhogGanoDoub`yr'8 + DhogGanoDoub`yr'9
	generate DhogPerdioDoub`yr'7t9 = DhogPerdioDoub`yr'7 + DhogPerdioDoub`yr'8 + DhogPerdioDoub`yr'9
	}
	
* 10-12
foreach yr in 2016 {
	generate DhogPerdioSimple`yr'10t12 = DhogPerdioSimple`yr'10 + DhogPerdioSimple`yr'11 + DhogPerdioSimple`yr'12
	generate DhogGanoSimple`yr'10t12 = DhogGanoSimple`yr'10 + DhogGanoSimple`yr'11 + DhogGanoSimple`yr'12
	generate DhogSimpleToDoub`yr'10t12 = DhogSimpleToDoub`yr'10 + DhogSimpleToDoub`yr'11 + DhogSimpleToDoub`yr'12
	generate DhogDoubToSimple`yr'10t12 = DhogDoubToSimple`yr'10 + DhogDoubToSimple`yr'11 + DhogDoubToSimple`yr'12
	gen DhogarCambioEnThres`yr'10t12 = 0
	replace DhogarCambioEnThres`yr'10t12 = 1 if (DhogPerdioSimple`yr'10t12 + DhogGanoSimple`yr'10t12 + DhogSimpleToDoub`yr'10t12 + DhogDoubToSimple`yr'10t12)>0
	generate DhogGanoDoub`yr'10t12 = DhogGanoDoub`yr'10 + DhogGanoDoub`yr'11 + DhogGanoDoub`yr'12
	generate DhogPerdioDoub`yr'10t12 = DhogPerdioDoub`yr'10 + DhogPerdioDoub`yr'11 + DhogPerdioDoub`yr'12
	}
	
* Cobro de TUS
foreach per in 3 6 12 {
	generate hogarmascobratusSimple`per' = hogarmascobratus`per'
	replace hogarmascobratusSimple`per' = 0 if hogarmastusdoble`per' == 1 
}
generate hogarzerocobratusSimple = hogarzerocobratus
replace hogarzerocobratusSimple = 0 if hogarzerotusdoble == 1

* Control polynomial
generate iccSuperaPrimerTUS=0
replace iccSuperaPrimerTUS=1 if icc >= umbral_nuevo_tus

generate iccSuperaSegundoTUS=0
replace iccSuperaSegundoTUS=1 if icc >= umbral_nuevo_tus_dup

generate iccNormPrimerTus = icc - umbral_nuevo_tus
generate iccNormSegundoTus = icc - umbral_nuevo_tus_dup
generate iccNormInteractedPrimerTus= iccNormPrimerTus * iccSuperaPrimerTUS
generate iccNormInteractedSegundoTus= iccNormSegundoTus * iccSuperaSegundoTUS

generate iccNormPrimerTus2 = iccNormPrimerTus * iccNormPrimerTus
generate iccNormSegundoTus2 = iccNormSegundoTus * iccNormSegundoTus
generate iccNorm2InteractedPrimerTus = iccNormPrimerTus2 * iccSuperaPrimerTUS
generate iccNorm2InteractedSegundoTus = iccNormSegundoTus2 * iccSuperaSegundoTUS

generate iccPrimerTUSHogZerCobTus = iccSuperaPrimerTUS * hogarzerocobratus

generate mitadBajaICC = .
replace mitadBajaICC = 1 if icc < umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2
replace mitadBajaICC = 0 if icc >= umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2

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

* Defino distintos periodos considerados para regresiones
generate periodo2016_1 = 0
replace periodo2016_1 = 1 if periodo>=94 & periodo<=103 // Aquellos visitados en los 10 meses anteriores al mes de la elección (salvo dos meses anteriores)
generate periodo2016_2 = 0
replace periodo2016_2 = 1 if periodo>=100 & periodo<=103 // (esto se hizo considerando que 7.5% de visitados cambiaron de status al siguiente mes (25% en segundo mes), 80% de visitados en 2016 cambio de status a los 5 meses y el 84% a los 8 meses)
generate periodo2016_3 = 0
replace periodo2016_3 = 1 if periodo>=86 & periodo<=96

generate periodo2013_1 = 0
replace periodo2013_1 = 1 if periodo>=58 & periodo<=67	// Aquellos visitados en los 10 meses anteriores al mes de la elección (salvo dos meses anteriores)
generate periodo2013_2 = 0
replace periodo2013_2 = 1 if periodo>=64 & periodo<=67 // (esto se hizo considerando que 13% de visitados cambiaron de status al siguiente mes (34% en segundo mes), 60% de visitados en 2013 cambio de status a los 5 meses y el 75% a los 8 meses)
generate periodo2013_3 = 0
replace periodo2013_3 = 1 if periodo>=50 & periodo<=60

generate periodo20132016_1 = 0
replace periodo20132016_1 = 1 if (periodo2013_1==1 | periodo2016_1==1)
generate periodo20132016_2 = 0
replace periodo20132016_2 = 1 if (periodo2013_2==1 | periodo2016_2==1)
generate periodo20132016_3 = 0
replace periodo20132016_3 = 1 if (periodo2013_3==1 | periodo2016_3==1)

* Other controls or filters
gen hombre = .
replace hombre = 1 if sexo == 1
replace hombre = 0 if sexo == 2

gen jefe = 0
replace jefe = 1 if parentesco == 1

* Variable to define bins
gen iccPrimTus0025 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 {
	replace iccPrimTus0025 = `bin'+11 if iccNormPrimerTus >= 0.025*(`bin'-1) & iccNormPrimerTus<0.025*`bin'
	replace iccPrimTus0025 = `bin' if iccNormPrimerTus < -0.025*(`bin'-1) & iccNormPrimerTus>=-0.025*`bin'
}

gen iccPrimTus005 = . 
foreach bin in 1 2 3 4 5 {
	replace iccPrimTus005 = `bin'+5 if iccNormPrimerTus >= 0.05*(`bin'-1) & iccNormPrimerTus<0.05*`bin'
	replace iccPrimTus005 = `bin' if iccNormPrimerTus < -0.05*(`bin'-1) & iccNormPrimerTus>=-0.05*`bin'
}

gen iccPrimTus002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 {
	replace iccPrimTus002 = `bin'+14 if iccNormPrimerTus >= 0.02*(`bin'-1) & iccNormPrimerTus<0.02*`bin'
	replace iccPrimTus002 = `bin' if iccNormPrimerTus < -0.02*(`bin'-1) & iccNormPrimerTus>=-0.02*`bin'
}

gen iccSegTus002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 {
	replace iccSegTus002 = `bin'+9 if iccNormSegundoTus >= 0.02*(`bin'-1) & iccNormSegundoTus<0.02*`bin'
	replace iccSegTus002 = `bin' if iccNormSegundoTus < -0.02*(`bin'-1) & iccNormSegundoTus>=-0.02*`bin'
}

* Variables to define bins for losing or gaining transfer months before or after the election

* 2013
gen binMthHogPerdSimp13 = .
replace binMthHogPerdSimp13 = 1 if hogPerdioSimple20135 == 1
replace binMthHogPerdSimp13 = 2 if hogPerdioSimple20134 == 1
replace binMthHogPerdSimp13 = 3 if hogPerdioSimple20133 == 1 
replace binMthHogPerdSimp13 = 4 if hogPerdioSimple20132 == 1
replace binMthHogPerdSimp13 = 5 if hogPerdioSimple20131 == 1 
replace binMthHogPerdSimp13 = 6 if hogPerdioSimple20130 == 1
replace binMthHogPerdSimp13 = 7 if DhogPerdioSimple20131 == 1 
*replace binMthHogPerdSimp13 = 8 if DhogPerdioSimple20132 == 1  
replace binMthHogPerdSimp13 = 9 if DhogPerdioSimple20133 == 1  
replace binMthHogPerdSimp13 = 10 if DhogPerdioSimple20134 == 1  
replace binMthHogPerdSimp13 = 11 if DhogPerdioSimple20135 == 1    

gen binMthHogGanoSimp13 = .
replace binMthHogGanoSimp13 = 1 if hogGanoSimple20135 == 1
replace binMthHogGanoSimp13 = 2 if hogGanoSimple20134 == 1
replace binMthHogGanoSimp13 = 3 if hogGanoSimple20133 == 1 
replace binMthHogGanoSimp13 = 4 if hogGanoSimple20132 == 1
replace binMthHogGanoSimp13 = 5 if hogGanoSimple20131 == 1 
replace binMthHogGanoSimp13 = 6 if hogGanoSimple20130 == 1
replace binMthHogGanoSimp13 = 7 if DhogGanoSimple20131 == 1 
*replace binMthHogGanoSimp13 = 8 if DhogGanoSimple20132 == 1  
replace binMthHogGanoSimp13 = 9 if DhogGanoSimple20133 == 1  
replace binMthHogGanoSimp13 = 10 if DhogGanoSimple20134 == 1  
replace binMthHogGanoSimp13 = 11 if DhogGanoSimple20135 == 1    


gen binMthHogPerdDoub13 = .
replace binMthHogPerdDoub13 = 1 if hogPerdioDoub20135 == 1
replace binMthHogPerdDoub13 = 2 if hogPerdioDoub20134 == 1
replace binMthHogPerdDoub13 = 3 if hogPerdioDoub20133 == 1 
replace binMthHogPerdDoub13 = 4 if hogPerdioDoub20132 == 1
replace binMthHogPerdDoub13 = 5 if hogPerdioDoub20131 == 1 
replace binMthHogPerdDoub13 = 6 if hogPerdioDoub20130 == 1
replace binMthHogPerdDoub13 = 7 if DhogPerdioDoub20131 == 1 
*replace binMthHogPerdDoub13 = 8 if DhogPerdioDoub20132 == 1  
replace binMthHogPerdDoub13 = 9 if DhogPerdioDoub20133 == 1  
replace binMthHogPerdDoub13 = 10 if DhogPerdioDoub20134 == 1  
replace binMthHogPerdDoub13 = 11 if DhogPerdioDoub20135 == 1    

gen binMthHogGanoDoub13 = .
replace binMthHogGanoDoub13 = 1 if hogGanoDoub20135 == 1
replace binMthHogGanoDoub13 = 2 if hogGanoDoub20134 == 1
replace binMthHogGanoDoub13 = 3 if hogGanoDoub20133 == 1 
replace binMthHogGanoDoub13 = 4 if hogGanoDoub20132 == 1
replace binMthHogGanoDoub13 = 5 if hogGanoDoub20131 == 1 
replace binMthHogGanoDoub13 = 6 if hogGanoDoub20130 == 1
replace binMthHogGanoDoub13 = 7 if DhogGanoDoub20131 == 1 
*replace binMthHogGanoDoub13 = 8 if DhogGanoDoub20132 == 1  
replace binMthHogGanoDoub13 = 9 if DhogGanoDoub20133 == 1  
replace binMthHogGanoDoub13 = 10 if DhogGanoDoub20134 == 1  
replace binMthHogGanoDoub13 = 11 if DhogGanoDoub20135 == 1    


* 2016
gen binMthHogPerdSimp16 = .

replace binMthHogPerdSimp16 = 1 if hogPerdioSimple20165 == 1
replace binMthHogPerdSimp16 = 2 if hogPerdioSimple20164 == 1
replace binMthHogPerdSimp16 = 3 if hogPerdioSimple20163 == 1 
replace binMthHogPerdSimp16 = 4 if hogPerdioSimple20162 == 1
replace binMthHogPerdSimp16 = 5 if hogPerdioSimple20161 == 1 
replace binMthHogPerdSimp16 = 6 if hogPerdioSimple20160 == 1
replace binMthHogPerdSimp16 = 7 if DhogPerdioSimple20161 == 1 
replace binMthHogPerdSimp16 = 8 if DhogPerdioSimple20162 == 1  
replace binMthHogPerdSimp16 = 9 if DhogPerdioSimple20163 == 1  
replace binMthHogPerdSimp16 = 10 if DhogPerdioSimple20164 == 1  
replace binMthHogPerdSimp16 = 11 if DhogPerdioSimple20165 == 1    

gen binMthHogGanoSimp16 = .
replace binMthHogGanoSimp16 = 1 if hogGanoSimple20165 == 1
replace binMthHogGanoSimp16 = 2 if hogGanoSimple20164 == 1
replace binMthHogGanoSimp16 = 3 if hogGanoSimple20163 == 1 
replace binMthHogGanoSimp16 = 4 if hogGanoSimple20162 == 1
replace binMthHogGanoSimp16 = 5 if hogGanoSimple20161 == 1 
replace binMthHogGanoSimp16 = 6 if hogGanoSimple20160 == 1
replace binMthHogGanoSimp16 = 7 if DhogGanoSimple20161 == 1 
replace binMthHogGanoSimp16 = 8 if DhogGanoSimple20162 == 1  
replace binMthHogGanoSimp16 = 9 if DhogGanoSimple20163 == 1  
replace binMthHogGanoSimp16 = 10 if DhogGanoSimple20164 == 1  
replace binMthHogGanoSimp16 = 11 if DhogGanoSimple20165 == 1    


gen binMthHogPerdDoub16 = .
replace binMthHogPerdDoub16 = 1 if hogPerdioDoub20165 == 1
replace binMthHogPerdDoub16 = 2 if hogPerdioDoub20164 == 1
replace binMthHogPerdDoub16 = 3 if hogPerdioDoub20163 == 1 
replace binMthHogPerdDoub16 = 4 if hogPerdioDoub20162 == 1
replace binMthHogPerdDoub16 = 5 if hogPerdioDoub20161 == 1 
replace binMthHogPerdDoub16 = 6 if hogPerdioDoub20160 == 1
replace binMthHogPerdDoub16 = 7 if DhogPerdioDoub20161 == 1 
replace binMthHogPerdDoub16 = 8 if DhogPerdioDoub20162 == 1  
replace binMthHogPerdDoub16 = 9 if DhogPerdioDoub20163 == 1  
replace binMthHogPerdDoub16 = 10 if DhogPerdioDoub20164 == 1  
replace binMthHogPerdDoub16 = 11 if DhogPerdioDoub20165 == 1    

gen binMthHogGanoDoub16 = .
replace binMthHogGanoDoub16 = 1 if hogGanoDoub20165 == 1
replace binMthHogGanoDoub16 = 2 if hogGanoDoub20164 == 1
replace binMthHogGanoDoub16 = 3 if hogGanoDoub20163 == 1 
replace binMthHogGanoDoub16 = 4 if hogGanoDoub20162 == 1
replace binMthHogGanoDoub16 = 5 if hogGanoDoub20161 == 1 
replace binMthHogGanoDoub16 = 6 if hogGanoDoub20160 == 1
replace binMthHogGanoDoub16 = 7 if DhogGanoDoub20161 == 1 
replace binMthHogGanoDoub16 = 8 if DhogGanoDoub20162 == 1  
replace binMthHogGanoDoub16 = 9 if DhogGanoDoub20163 == 1  
replace binMthHogGanoDoub16 = 10 if DhogGanoDoub20164 == 1  
replace binMthHogGanoDoub16 = 11 if DhogGanoDoub20165 == 1 

* 2016: 3-months bins (1-3, 4-6, 7-9, 10-12)
gen binMthGHogPerdSimp16 = .

replace binMthGHogPerdSimp16 = 1 if hogPerdioSimple201610t12 == 1
replace binMthGHogPerdSimp16 = 2 if hogPerdioSimple20167t9 == 1
replace binMthGHogPerdSimp16 = 3 if hogPerdioSimple20164t6 == 1 
replace binMthGHogPerdSimp16 = 4 if hogPerdioSimple20161t3 == 1
replace binMthGHogPerdSimp16 = 5 if hogPerdioSimple20160 == 1 
replace binMthGHogPerdSimp16 = 6 if DhogPerdioSimple20161t3 == 1
replace binMthGHogPerdSimp16 = 7 if DhogPerdioSimple20164t6 == 1 
replace binMthGHogPerdSimp16 = 8 if DhogPerdioSimple20167t9 == 1  
replace binMthGHogPerdSimp16 = 9 if DhogPerdioSimple201610t12 == 1  

gen binMthGHogGanoSimp16 = .
replace binMthGHogGanoSimp16 = 1 if hogGanoSimple201610t12 == 1
replace binMthGHogGanoSimp16 = 2 if hogGanoSimple20167t9 == 1
replace binMthGHogGanoSimp16 = 3 if hogGanoSimple20164t6 == 1 
replace binMthGHogGanoSimp16 = 4 if hogGanoSimple20161t3 == 1
replace binMthGHogGanoSimp16 = 5 if hogGanoSimple20160 == 1 
replace binMthGHogGanoSimp16 = 6 if DhogGanoSimple20161t3 == 1
replace binMthGHogGanoSimp16 = 7 if DhogGanoSimple20164t6 == 1 
replace binMthGHogGanoSimp16 = 8 if DhogGanoSimple20167t9 == 1  
replace binMthGHogGanoSimp16 = 9 if DhogGanoSimple201610t12 == 1  

gen binMthGHogPerdDoub16 = .
replace binMthGHogPerdDoub16 = 1 if hogPerdioDoub201610t12 == 1
replace binMthGHogPerdDoub16 = 2 if hogPerdioDoub20167t9 == 1
replace binMthGHogPerdDoub16 = 3 if hogPerdioDoub20164t6 == 1 
replace binMthGHogPerdDoub16 = 4 if hogPerdioDoub20161t3 == 1
replace binMthGHogPerdDoub16 = 5 if hogPerdioDoub20160 == 1 
replace binMthGHogPerdDoub16 = 6 if DhogPerdioDoub20161t3 == 1
replace binMthGHogPerdDoub16 = 7 if DhogPerdioDoub20164t6 == 1 
replace binMthGHogPerdDoub16 = 8 if DhogPerdioDoub20167t9 == 1  
replace binMthGHogPerdDoub16 = 9 if DhogPerdioDoub201610t12 == 1   

gen binMthGHogGanoDoub16 = .
replace binMthGHogGanoDoub16 = 1 if hogGanoDoub201610t12 == 1
replace binMthGHogGanoDoub16 = 2 if hogGanoDoub20167t9 == 1
replace binMthGHogGanoDoub16 = 3 if hogGanoDoub20164t6 == 1 
replace binMthGHogGanoDoub16 = 4 if hogGanoDoub20161t3 == 1
replace binMthGHogGanoDoub16 = 5 if hogGanoDoub20160 == 1 
replace binMthGHogGanoDoub16 = 6 if DhogGanoDoub20161t3 == 1
replace binMthGHogGanoDoub16 = 7 if DhogGanoDoub20164t6 == 1 
replace binMthGHogGanoDoub16 = 8 if DhogGanoDoub20167t9 == 1  
replace binMthGHogGanoDoub16 = 9 if DhogGanoDoub201610t12 == 1  

* Instruments for losing/gaining/doubling TUS
gen iccSuperaPrimerTUS20130t3 = 0
replace iccSuperaPrimerTUS20130t3 = 1 if icc >= umbral_nuevo_tus & (periodo == 70 | periodo == 69 | periodo ==68 | periodo == 67)

gen iccSuperaPrimerTUS20131t3 = 0
replace iccSuperaPrimerTUS20131t3 = 1 if icc >= umbral_nuevo_tus & (periodo == 69 | periodo ==68 | periodo == 67)

gen iccSuperaPrimerTUS20134t6 = 0
replace iccSuperaPrimerTUS20134t6 = 1 if icc >= umbral_nuevo_tus & (periodo == 66 | periodo == 65 | periodo ==64)

gen iccSuperaPrimerTUS20137t9 = 0
replace iccSuperaPrimerTUS20137t9 = 1 if icc >= umbral_nuevo_tus & (periodo == 63 | periodo == 62 | periodo ==61)

gen iccSuperaPrimerTUS201310t12 = 0
replace iccSuperaPrimerTUS201310t12 = 1 if icc >= umbral_nuevo_tus & (periodo == 60 | periodo == 59 | periodo ==58)



*** RD plots (considerando aquellos below or above TUS threshold)

** 2013 election for those in Montevideo (election fue en period = 70)

* Not receiving TUS initially
binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==0 & periodo2013_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_1_prim_0TUS.png, replace

binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==0 & periodo2013_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_2_prim_0TUS.png, replace

binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==0 & periodo2013_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_3_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_1_prim_1TUS.png, replace

binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_2_prim_1TUS.png, replace

binscatter pp2013 iccNormPrimerTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_3_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_1_seg_1TUS.png, replace

binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_2_seg_1TUS.png, replace

binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2013_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_3_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2013_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_1_seg_2TUS.png, replace

binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2013_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
graph export ..\Output\pp2013_2_seg_2TUS.png, replace

*binscatter pp2013 iccNormSegundoTus if habilitado2013==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2013_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2013)
*graph export ..\Output\pp2013_3_seg_2TUS.png, replace

** 2016 election for those in Montevideo (election fue en period = 106)

* Not receiving TUS initially
binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==0 & periodo2016_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_1_prim_0TUS.png, replace

binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==0 & periodo2016_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_2_prim_0TUS.png, replace

binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==0 & periodo2016_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_3_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_1_prim_1TUS.png, replace

binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_2_prim_1TUS.png, replace

binscatter pp2016 iccNormPrimerTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_3_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_1_seg_1TUS.png, replace

binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_2_seg_1TUS.png, replace

binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo2016_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_3_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2016_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_1_seg_2TUS.png, replace

binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2016_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_2_seg_2TUS.png, replace

binscatter pp2016 iccNormSegundoTus if habilitado2016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo2016_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 2016)
graph export ..\Output\pp2016_3_seg_2TUS.png, replace

* Junto 2013 y 2016 elections
/*
* Not receiving TUS initially
binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==0 & periodo20132016_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_1_prim_0TUS.png, replace

binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==0 & periodo20132016_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_2_prim_0TUS.png, replace

binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==0 & periodo20132016_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_3_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_1==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_1_prim_1TUS.png, replace

binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_2==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_2_prim_1TUS.png, replace

binscatter pp20132016 iccNormPrimerTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_3==1 & departamento==1, xq (iccPrimTus002) rd(0) linetype(qfit) xtitle(ICC - First TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_3_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter pp20132016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_1_seg_1TUS.png, replace

binscatter pp20132016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_2_seg_1TUS.png, replace

binscatter pp20132016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 1 & periodo20132016_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_3_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter pp2016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo20132016_1==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp2016_1_seg_2TUS.png, replace

binscatter pp20132016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo20132016_2==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_2_seg_2TUS.png, replace

binscatter pp20132016 iccNormSegTus if habilitado20132016==1 & hogarzerocobratus==1 & hogarzerocobratusSimple == 0 & periodo20132016_3==1 & departamento==1, xq (iccSegTus002) rd(0) linetype(qfit) xtitle(ICC - Sec TUS thres) ytitle(Perc. voting in 20132016)
graph export ..\Output\pp20132016_3_seg_2TUS.png, replace
*/

*** RD plots (considerando aquellos que perdieron/ganaron/duplicaron la TUS x meses antes o x meses después de la elección)
*2013
* Bins por meses
binscatter pp2013 binMthHogPerdSimp13 if habilitado2013==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 1 TUS to 0) ytitle(Perc. voting in 2013)
graph export ..\Output\binMthHogPerdSimp13.png, replace

binscatter pp2013 binMthHogGanoSimp13 if habilitado2013==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 1) ytitle(Perc. voting in 2013)
graph export ..\Output\binMthHogGanoSimp13.png, replace

binscatter pp2013 binMthHogPerdDoub13 if habilitado2013==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 2 TUS to 0) ytitle(Perc. voting in 2013)
graph export ..\Output\binMthHogPerdDoub13.png, replace

binscatter pp2013 binMthHogGanoDoub13 if habilitado2013==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 2) ytitle(Perc. voting in 2013)
graph export ..\Output\binMthHogGanoDoub13.png, replace

*2016
* Bins por meses
binscatter pp2016 binMthHogPerdSimp16 if habilitado2016==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 1 TUS to 0) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthHogPerdSimp16.png, replace

binscatter pp2016 binMthHogGanoSimp16 if habilitado2016==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 1) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthHogGanoSimp16.png, replace

binscatter pp2016 binMthHogPerdDoub16 if habilitado2016==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 2 TUS to 0) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthHogPerdDoub16.png, replace

binscatter pp2016 binMthHogGanoDoub16 if habilitado2016==1 & departamento==1, rd(6) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 2) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthHogGanoDoub16.png, replace

* Bins por grupos de meses
binscatter pp2016 binMthGHogPerdSimp16 if habilitado2016==1 & departamento==1, rd(5) discrete linetype(qfit) xtitle(Months before/after from 1 TUS to 0) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthGHogPerdSimp16.png, replace

binscatter pp2016 binMthGHogGanoSimp16 if habilitado2016==1 & departamento==1, rd(5) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 1) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthHogGanoSimp16.png, replace

binscatter pp2016 binMthGHogPerdDoub16 if habilitado2016==1 & departamento==1, rd(5) discrete linetype(qfit) xtitle(Months before/after from 2 TUS to 0) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthGHogPerdDoub16.png, replace

binscatter pp2016 binMthGHogGanoDoub16 if habilitado2016==1 & departamento==1, rd(5) discrete linetype(qfit) xtitle(Months before/after from 0 TUS to 2) ytitle(Perc. voting in 2016)
graph export ..\Output\binMthGHogGanoDoub16.png, replace


*** Regressions: IV on outcomes (con endogeneous regressors siendo si perdió/ganó/duplicó la TUS x meses antes de la elección)

* 2013

* Not receiving TUS initially
ivregress 2sls pp2013 iccNormPrimerTus iccNormInteractedPrimerTus pp2011 pp2008 periodo (hogGano20130t3 hogGano20134t6 hogGano20137t9 = iccSuperaPrimerTUS20131t3 iccSuperaPrimerTUS20134t6 iccSuperaPrimerTUS20137t9 iccSuperaPrimerTUS201310t12) if habilitado2013==1 & departamento == 1 & hogarzerocobratus == 0 & icc > umbral_nuevo_tus - 0.2 & icc < umbral_nuevo_tus + 0.2 & periodo>=58 & periodo<=69, robust first

* Receiving 1 TUS initially and in the threshold of losing it
ivregress 2sls pp2013 iccNormPrimerTus iccNormInteractedPrimerTus pp2011 pp2008 periodo (hogPerdio20130t3 hogPerdio20134t6 hogPerdio20137t9 = iccSuperaPrimerTUS20131t3 iccSuperaPrimerTUS20134t6 iccSuperaPrimerTUS20137t9 iccSuperaPrimerTUS201310t12) if habilitado2013==1 & departamento == 1 & hogarzerocobratus == 0 & icc > umbral_nuevo_tus - 0.2 & icc < umbral_nuevo_tus + 0.2 & periodo>=58 & periodo<=69, robust first

* Receiving 1 TUS initially and in the threshold of doubling it

* Receiving 2 TUS initially and in the threshold of losing it

* 2016

* Not receiving TUS initially
ivregress 2sls pp2016 iccNormPrimerTus iccNormInteractedPrimerTus pp2013 pp2011 pp2008 periodo (hogGano20160t3 hogGano20164t6 hogGano20167t9 = iccSuperaPrimerTUS20161t3 iccSuperaPrimerTUS20164t6 iccSuperaPrimerTUS20167t9 iccSuperaPrimerTUS201610t12) if habilitado2016==1 & departamento == 1 & hogarzerocobratus == 0 & icc > umbral_nuevo_tus - 0.2 & icc < umbral_nuevo_tus + 0.2 & periodo>=58 & periodo<=69, robust first

* Receiving 1 TUS initially and in the threshold of losing it
ivregress 2sls pp2013 iccNormPrimerTus iccNormInteractedPrimerTus pp2011 pp2008 periodo (hogPerdio20130t3 hogPerdio20134t6 hogPerdio20137t9 = iccSuperaPrimerTUS20131t3 iccSuperaPrimerTUS20134t6 iccSuperaPrimerTUS20137t9 iccSuperaPrimerTUS201310t12) if habilitado2013==1 & departamento == 1 & hogarzerocobratus == 0 & icc > umbral_nuevo_tus - 0.2 & icc < umbral_nuevo_tus + 0.2 & periodo>=58 & periodo<=69, robust first

* Receiving 1 TUS initially and in the threshold of doubling it

* Receiving 2 TUS initially and in the threshold of losing it


*** Regresions: No RD and no instruments
*2013
regress pp2013 hogPerdioSimple20130t3 iccNormPrimerTus edad_visita pp2011 pp2008 periodo if habilitado2013==1 & departamento == 1 & periodo<70 & hogarcobratus66 == 1 & hogartusdoble66 == 0, robust
regress pp2013 hogGanoSimple20130t3 iccNormPrimerTus edad_visita pp2011 pp2008 periodo if habilitado2013==1 & departamento == 1 & periodo<70 & hogarcobratus66 == 0, robust
regress pp2013 hogarcobratus70 hogartusdoble70 iccNormPrimerTus pp2011 pp2008 periodo if habilitado2013==1 & departamento == 1 & periodo<70, robust

*2016
regress pp2016 hogPerdioSimple20160t3 iccNormPrimerTus edad_visita pp2013 pp2011 pp2008 periodo if habilitado2016==1 & departamento == 1 & periodo<106 & hogarcobratus102 == 1 & hogartusdoble102 == 0, robust
regress pp2016 hogGanoSimple20160t3 iccNormPrimerTus edad_visita pp2013 pp2011 pp2008 periodo if habilitado2016==1 & departamento == 1 & periodo<106 & hogarcobratus102 == 0, robust
regress pp2016 hogarcobratus106 hogartusdoble106 iccNormPrimerTus pp2011 pp2008 periodo if habilitado2016==1 & departamento == 1 & periodo<106, robust

*** Regressions: with RD of chanigng TUS before and after the election
*2013
/*
regress pp2013 hogPerdioSimple20130t3 pp2011 pp2008 if habilitado2013==1 & departamento == 1 & (DhogPerdioSimple20130t3 == 1 | hogPerdioSimple20130t3 == 1) & hogPerdioSimple20130 == 0, robust
regress pp2013 hogGanoSimple20130t3 pp2011 pp2008 if habilitado2013==1 & departamento == 1 & (DhogGanoSimple20130t3 == 1 | hogGanoSimple20130t3 == 1) & hogGanoSimple20130 == 0, robust
regress pp2013 hogPerdioDoub20130t3 pp2011 pp2008 if habilitado2013==1 & departamento == 1 & (DhogPerdioDoub20130t3 == 1 | hogPerdioDoub20130t3 == 1) & hogPerdioDoub20130 == 0, robust
regress pp2013 hogGanoDoub20130t3 pp2011 pp2008 if habilitado2013==1 & departamento == 1 & (DhogGanoDoub20130t3 == 1 | hogGanoDoub20130t3 == 1) & hogGanoDoub20130 == 0, robust
*/

*2016
regress pp2016 hogPerdioSimple20160t3 pp2013 pp2011 pp2008 if habilitado2016==1 & departamento == 1 & (DhogPerdioSimple20160t3 == 1 | hogPerdioSimple20160t3 == 1) & hogPerdioSimple20160 == 0, robust
regress pp2016 hogGanoSimple20160t3 pp2013 pp2011 pp2008 if habilitado2016==1 & departamento == 1 & (DhogGanoSimple20160t3 == 1 | hogGanoSimple20160t3 == 1) & hogGanoSimple20160 == 0, robust
regress pp2016 hogPerdioDoub20160t3 pp2013 pp2011 pp2008 if habilitado2016==1 & departamento == 1 & (DhogPerdioDoub20160t3 == 1 | hogPerdioDoub20160t3 == 1) & hogPerdioDoub20160 == 0, robust
regress pp2016 hogGanoDoub20160t3 pp2013 pp2011 pp2008 if habilitado2016==1 & departamento == 1 & (DhogGanoDoub20160t3 == 1 | hogGanoDoub20160t3 == 1) & hogGanoDoub20160 == 0, robust
