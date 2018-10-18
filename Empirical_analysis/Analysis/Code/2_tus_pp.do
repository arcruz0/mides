* Objective: Mirar second stage de impacto TUS en PP.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load dataset a nivel de personas
import delimited ..\Input\visitas_personas_otras_vars.csv, clear

* Macros
global bandwiths1y2Tus 0.2 0.1 1
global periodo2016 periodo2016_1==1 periodo2016_2==1
global periodo2013 periodo2013_1==1 periodo2013_2==1
global periodo20132016 periodo20132016_1==1 periodo20132016_2==1
global ctrls2016 "" pp2013 pp2011 pp2008 ""
global ctrls2013 "" pp2011 pp2008 ""
global ctrls20132016 "" pp2011 pp2008 ""
global poly ""iccNormPrimerTusSi iccNormInteractedPrimerTusSi iccNormPrimerTus2Si iccNorm2InteractedPrimerTusSi iccNormSegundoTusSi iccNormInteractedSegundoTusSi iccNormSegundoTus2Si iccNorm2InteractedSegundoTusSi"" ""iccSuperaPrimerTUSNoSec iccNormPrimerTusSi iccNormInteractedPrimerTusSi iccSuperaSegundoTUS iccNormSegundoTusSi iccNormInteractedSegundoTusSi""
global depVarVoting pp2016 pp2013 vote2013_2016
global depVarVoting2016 pp2016
global depVarVoting2013 pp2013
global depVarVoting20132016 pp20132016
global cobraZero hogarzerocobratusSimple==1 hogarzerocobratus==0 hogarzerotusdoble==1
global region umbral_nuevo_tus<0.65 umbral_nuevo_tus>0.65 umbral_nuevo_tus<0.9
global habilitadoMacro habilitado2013==1 habilitado2016==1 habilitado20132016==1
global endog ""hogarmascobratus6 hogarmastusdoble6"" ""hogarmascobratus3 hogarmastusdoble3"" ""hogarmascobratus12 hogarmastusdoble12""
global instruments ""iccSuperaPrimerTUSNoSec iccSuperaSegundoTUS""


*** Generate variables

* Dependent variables
generate pp20132016=.
replace pp20132016=pp2013 if year==2013
replace pp20132016=pp2016 if year==2016

generate habilitado20132016=.
replace habilitado20132016=habilitado2013 if year==2013
replace habilitado20132016=habilitado2016 if year==2016

* Variable de si hogar ganó o perdió 1 o 2 TUS 1,...,12 meses antes de la elección de 2013 o de 2016

* 2013
* Hogar perdió una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogarPerdioSimple2013`ms' = 0
	}
	
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogPerdioSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	replace hogPerdioSimple2013`ms' = 1 if hogcobraTus`per' == 0 & hogcobraTus`per2' == 1 & hogtusDoble`per2' == 0
	}
replace hogarPerdioSimple20130 = 1 if hogarcobraTus70 == 0 & hogarcobraTus69 == 1 & hogartusDoble69 == 0
replace hogarPerdioSimple20131 = 1 if hogarcobraTus69 == 0 & hogarcobraTus68 == 1 & hogartusDoble68 == 0
replace hogarPerdioSimple20132 = 1 if hogarcobraTus68 == 0 & hogarcobraTus67 == 1 & hogartusDoble67 == 0
replace hogarPerdioSimple20133 = 1 if hogarcobraTus67 == 0 & hogarcobraTus66 == 1 & hogartusDoble66 == 0
replace hogarPerdioSimple20134 = 1 if hogarcobraTus66 == 0 & hogarcobraTus65 == 1 & hogartusDoble65 == 0
replace hogarPerdioSimple20135 = 1 if hogarcobraTus65 == 0 & hogarcobraTus64 == 1 & hogartusDoble64 == 0
replace hogarPerdioSimple20136 = 1 if hogarcobraTus64 == 0 & hogarcobraTus63 == 1 & hogartusDoble63 == 0
replace hogarPerdioSimple20137 = 1 if hogarcobraTus63 == 0 & hogarcobraTus62 == 1 & hogartusDoble62 == 0
replace hogarPerdioSimple20138 = 1 if hogarcobraTus62 == 0 & hogarcobraTus61 == 1 & hogartusDoble61 == 0
replace hogarPerdioSimple20139 = 1 if hogarcobraTus61 == 0 & hogarcobraTus60 == 1 & hogartusDoble60 == 0
replace hogarPerdioSimple201310 = 1 if hogarcobraTus60 == 0 & hogarcobraTus59 == 1 & hogartusDoble59 == 0
replace hogarPerdioSimple201311 = 1 if hogarcobraTus59 == 0 & hogarcobraTus58 == 1 & hogartusDoble58 == 0
replace hogarPerdioSimple201312 = 1 if hogarcobraTus58 == 0 & hogarcobraTus57 == 1 & hogartusDoble57 == 0

* Hogar ganó una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogGanoSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	replace hogGanoSimple2013`ms' = 1 if hogcobraTus`per' == 1 & hogcobraTus`per2' == 0 & hogtusDoble`per2' == 0
	}
	
	
* Hogar pasó de simple a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogSimpleToDoub2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	replace hogSimpleToDoub2013`ms' = 1 if hogtusDoble`per' == 1 & hogcobraTus`per2' == 1 & hogtusDoble`per2' == 0
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogDoubToSimple2013`ms' = 0
	local per = 70 - `ms'
	local per2 = 70 - `ms' -1
	replace hogDoubToSimple2013`ms' = 1 if hogtusDoble`per' == 0 & hogcobraTus`per' == 1 & hogtusDoble`per2' == 1
	}

* 2016
* Hogar perdió una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogPerdioSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogPerdioSimple2016`ms' = 1 if hogcobraTus`per' == 0 & hogcobraTus`per2' == 1 & hogtusDoble`per2' == 0
	}
	
* Hogar ganó una simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogGanoSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogGanoSimple2016`ms' = 1 if hogcobraTus`per' == 1 & hogcobraTus`per2' == 0 & hogtusDoble`per2' == 0
	}
	
	
* Hogar pasó de simple a doble
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogSimpleToDoub2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogSimpleToDoub2016`ms' = 1 if hogtusDoble`per' == 1 & hogcobraTus`per2' == 1 & hogtusDoble`per2' == 0
	}
	
* Hogar pasó de doble a simple
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogDoubToSimple2016`ms' = 0
	local per = 106 - `ms'
	local per2 = 106 - `ms' -1
	replace hogDoubToSimple2016`ms' = 1 if hogtusDoble`per' == 0 & hogcobraTus`per' == 1 & hogtusDoble`per2' == 1
	}

* 2013 y 2016
foreach ms in 0 1 2 3 4 5 6 7 8 9 10 11 12{
	generate hogDoubToSimple20132016`ms' = hogDoubToSimple2013`ms' + hogDoubToSimple2016`ms'
	generate hogSimpleToDoub20132016`ms' = hogSimpleToDoub2013`ms' + hogSimpleToDoub2016`ms'
	generate hogGanoSimple20132016`ms' = hogGanoSimple2013`ms' + hogGanoSimple2016`ms'
	generate hogPerdioSimple20132016`ms' = hogPerdioSimple2013`ms' + hogPerdioSimple2016`ms'
	}
	
* Agregados por períodos	

* 0-3
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t3 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3
	generate hogGanoSimple`yr'0t3 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3
	generate hogSimpleToDoub`yr'0t3 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3
	generate hogDoubToSimple`yr'0t3 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3
}
* 0-2
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t2 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2
	generate hogGanoSimple`yr'0t2 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2
	generate hogSimpleToDoub`yr'0t2 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2
	generate hogDoubToSimple`yr'0t2 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2
}
* 0-6
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'0t6 = hogPerdioSimple`yr'0 + hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3 + hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5 + hogPerdioSimple`yr'6
	generate hogGanoSimple`yr'0t6 = hogGanoSimple`yr'0 + hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3 + hogGanoSimple`yr'4 + hogGanoSimple`yr'5 + hogGanoSimple`yr'6
	generate hogSimpleToDoub`yr'0t6 = hogSimpleToDoub`yr'0 + hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3 + hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5 + hogSimpleToDoub`yr'6
	generate hogDoubToSimple`yr'0t6 = hogDoubToSimple`yr'0 + hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3 + hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5 + hogDoubToSimple`yr'6
}

* 1-3
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t3 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3
	generate hogGanoSimple`yr'1t3 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3
	generate hogSimpleToDoub`yr'1t3 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3
	generate hogDoubToSimple`yr'1t3 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3
}
* 1-2
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t2 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2
	generate hogGanoSimple`yr'1t2 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2
	generate hogSimpleToDoub`yr'1t2 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2
	generate hogDoubToSimple`yr'1t2 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2
}
* 1-6
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'1t6 = hogPerdioSimple`yr'1 + hogPerdioSimple`yr'2 + hogPerdioSimple`yr'3 + hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5 + hogPerdioSimple`yr'6
	generate hogGanoSimple`yr'1t6 = hogGanoSimple`yr'1 + hogGanoSimple`yr'2 + hogGanoSimple`yr'3 + hogGanoSimple`yr'4 + hogGanoSimple`yr'5 + hogGanoSimple`yr'6
	generate hogSimpleToDoub`yr'1t6 = hogSimpleToDoub`yr'1 + hogSimpleToDoub`yr'2 + hogSimpleToDoub`yr'3 + hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5 + hogSimpleToDoub`yr'6
	generate hogDoubToSimple`yr'1t6 = hogDoubToSimple`yr'1 + hogDoubToSimple`yr'2 + hogDoubToSimple`yr'3 + hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5 + hogDoubToSimple`yr'6
}
* 3-6
foreach yr in 2013 2016 20132016 {
	generate hogPerdioSimple`yr'3t6 = hogPerdioSimple`yr'3 + hogPerdioSimple`yr'4 + hogPerdioSimple`yr'5 + hogPerdioSimple`yr'6
	generate hogGanoSimple`yr'3t6 = hogGanoSimple`yr'3 + hogGanoSimple`yr'4 + hogGanoSimple`yr'5 + hogGanoSimple`yr'6
	generate hogSimpleToDoub`yr'3t6 = hogSimpleToDoub`yr'3 + hogSimpleToDoub`yr'4 + hogSimpleToDoub`yr'5 + hogSimpleToDoub`yr'6
	generate hogDoubToSimple`yr'3t6 = hogDoubToSimple`yr'3 + hogDoubToSimple`yr'4 + hogDoubToSimple`yr'5 + hogDoubToSimple`yr'6
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
generate periodo20132016_1 = 0
replace periodo20132016_1 = 1 if (periodo>=58 & periodo<=64) | (periodo>=94 & periodo<=100)
generate periodo20132016_2 = 0
replace periodo20132016_2 = 1 if (periodo>=50 & periodo<=68) | (periodo>=80 & periodo<=104)
generate periodo2016_1 = 0
replace periodo2016_1 = 1 if periodo>=94 & periodo<=100
generate periodo2016_2 = 0
replace periodo2016_2 = 1 if periodo>=80 & periodo<=104
generate periodo2013_1 = 0
replace periodo2013_1 = 1 if periodo>=58 & periodo<=64
generate periodo2013_2 = 0
replace periodo2013_2 = 1 if periodo>=50 & periodo<=68

*** Regresions: instrument on outcomes

*** Regressions: IV on outcomes
foreach yr in 2013 2016 20132016 {
	foreach var in $depVarVoting`yr' {
		foreach bd in $bandwiths1y2Tus {
			foreach per in $periodo`yr' {
				foreach ctrl in $ctrls`yr' {
					foreach pol in $poly {
						foreach cr in $cobraZero {
							foreach instr in $instruments {
								foreach endo in $endog {
										ivreg2 `var' `pol' `ctrl' (`endo' = `instr') if habilitado`yr'==1 & `cr' & `per' & umbral_nuevo_tus<0.65 & ///
										((icc > umbral_nuevo_tus - `bd' & icc < umbral_nuevo_tus + `bd') | (icc > umbral_nuevo_tus_dup - `bd' & icc < umbral_nuevo_tus_dup + `bd')), robust
										outreg2 using myfile4, addtext("DepVar", `var', "Bandiwth", `bd', "Periodo", `per', "Cobra zero", `cr', "Habilitado", `ha') excel
	}
	}
	}
	}
	}
	}
	}
	}
	}
	

foreach yr in 2013 2016 20132016 {
	foreach var in $depVarVoting`yr' {
		foreach bd in $bandwiths1y2Tus {
			foreach per in $periodo {
				foreach ctrl in $ctrls20132016 {
					foreach pol in $poly {
						foreach cr in $cobraZero {
							foreach instr in $instruments {
								foreach endo in $endog {
									foreach ha in $habilitadoMacro {
										ivreg2 `var' `pol' `ctrl' (`endo' = `instr') if `ha' & `cr' & `per' & umbral_nuevo_tus<0.65 & ///
										((icc > umbral_nuevo_tus - `bd' & icc < umbral_nuevo_tus + `bd') | (icc > umbral_nuevo_tus_dup - `bd' & icc < umbral_nuevo_tus_dup + `bd')), robust
										outreg2 using myfile2, addtext("DepVar", `var', "Bandiwth", `bd', "Periodo", `per', "Cobra zero", `cr', "Habilitado", `ha') excel
	}
	}
	}
	}
	}
	}
	}
	}
	}
}
foreach var in $depVarVoting {
	foreach bd in $bandwiths1y2Tus {
		foreach pol in $poly {
			foreach cr in $cobraZero {
				foreach instr in $instruments {
					foreach endo in $endog {
									gen anoVoto = "`var'"
									if anoVoto == "pp2016" {
										local ha = "habilitado2016==1"
										local per = "periodo2016==1"
										local ctrl = "pp2013 pp2011 pp2008"
										}
									else if anoVoto == "pp2013" {
										local ha = "habilitado2013==1"
										local per = "periodo2013==1"
										local ctrl = ""pp2011 pp2008""
										}
									else {
										local ha = "habilitado2013_2016==1"
										local per = "periodo20132016==1"
										local ctrl = ""pp2011 pp2008""
										}
									drop anoVoto
										ivreg2 `var' `pol' `ctrl' (`endo' = `instr') if `ha' & `cr' & `per' & umbral_nuevo_tus<0.65 & ///
										((icc > umbral_nuevo_tus - `bd' & icc < umbral_nuevo_tus + `bd') | (icc > umbral_nuevo_tus_dup - `bd' & icc < umbral_nuevo_tus_dup + `bd')), robust
										outreg2 using myfile3, addtext("DepVar", `var', "Bandiwth", `bd', "Periodo", `per', "Cobra zero", `cr', "Habilitado", `ha') excel
}
}
}
}
}
}




*** RD plots

* 2013 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 70)
binscatter pp2013 icc if habilitado2013==1 & (periodo>=58 & periodo<=65) & umbral_nuevo_tus<0.65, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2013)

* 2016 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 106)
binscatter pp2016 icc if habilitado2016==1 & hogarzerocobratus==1 & (periodo>=94 & periodo<=100) & umbral_nuevo_tus<0.65, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2016)

* Junto 2013 y 2016 elections

*** Chequeo que variables de si perdiste TUS o la ganaste en determinado mes no capte caídas transitorias del registro TUS

* 2013 election for those visited 6 months - 12 months before the election and that were receiving 1 TUS before the visit
