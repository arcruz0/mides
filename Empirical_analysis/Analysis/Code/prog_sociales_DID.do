* Objective: Mirar second stage de impacto TUS en Prog-sociales-SIIAS.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado

* Load dataset a nivel de personas con datos de Prog-sociales-SIIAS
import delimited ..\Input\MIDES\visitas_personas_mides_inda_panrn.csv, clear case(preserve)

keep flowcorrelativeid nrodocumentoDAES fechavisita icc nrodocumentoSIIAS year month periodo umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam menosmides_inda_panrn1 menosmides_inda_panrn2 menosmides_inda_panrn3 menosmides_inda_panrn4 menosmides_inda_panrn5 menosmides_inda_panrn6 menosmides_inda_panrn7 menosmides_inda_panrn8 menosmides_inda_panrn9 menosmides_inda_panrn10 menosmides_inda_panrn11 menosmides_inda_panrn12 masmides_inda_panrn1 masmides_inda_panrn2 masmides_inda_panrn3 masmides_inda_panrn4 masmides_inda_panrn5 masmides_inda_panrn6 masmides_inda_panrn7 masmides_inda_panrn8 masmides_inda_panrn9 masmides_inda_panrn10 masmides_inda_panrn11 masmides_inda_panrn12 masmides_inda_panrn13 masmides_inda_panrn14 masmides_inda_panrn15 masmides_inda_panrn16 masmides_inda_panrn17 masmides_inda_panrn18 masmides_inda_panrn19 masmides_inda_panrn20 masmides_inda_panrn21 masmides_inda_panrn22 masmides_inda_panrn23 masmides_inda_panrn24 masmides_inda_panrn25 masmides_inda_panrn26 masmides_inda_panrn27 masmides_inda_panrn28 masmides_inda_panrn29 masmides_inda_panrn30 masmides_inda_panrn31 masmides_inda_panrn32 masmides_inda_panrn33 masmides_inda_panrn34 masmides_inda_panrn35 masmides_inda_panrn36 masmides_inda_panrn37 masmides_inda_panrn38 masmides_inda_panrn39 masmides_inda_panrn40 masmides_inda_panrn41 masmides_inda_panrn42 masmides_inda_panrn43 masmides_inda_panrn44 masmides_inda_panrn45 masmides_inda_panrn46 masmides_inda_panrn47 masmides_inda_panrn48 zeromides_inda_panrn

* Merge con data de TUS que deseo
merge m:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_TUS.dta, keep (master match) keepusing(${varsTUS})
drop _merge

* Merge con data de visitas-personas que deseo
merge 1:1 nrodocumentoSIIAS flowcorrelativeid using ..\Input\MIDES\visitas_personas_vars.dta, keep (master match) keepusing(${varsPersonas})
drop _merge

*** Genero variables
gen iccMenosThreshold0 = icc - umbral_afam
gen iccMenosThreshold1 = icc - umbral_nuevo_tus
gen iccMenosThreshold2 = icc - umbral_nuevo_tus_dup
gen iccMenosThresholdAll=.
replace iccMenosThresholdAll = iccMenosThreshold0 if abs(iccMenosThreshold0)<abs(iccMenosThreshold1) & abs(iccMenosThreshold0)<abs(iccMenosThreshold2)
replace iccMenosThresholdAll = iccMenosThreshold1 if abs(iccMenosThreshold1)<abs(iccMenosThreshold0) & abs(iccMenosThreshold1)<abs(iccMenosThreshold2)
replace iccMenosThresholdAll = iccMenosThreshold2 if abs(iccMenosThreshold2)<abs(iccMenosThreshold0) & abs(iccMenosThreshold2)<abs(iccMenosThreshold1)
gen hogarZeroCuantasTus = hogarZerocobraTus + hogarZerotusDoble


*** Different DID specifications

** Spec 1: Aquellos que inicialmente recibían 1 TUS y tuvieron ICC menor (Treated) o mayor (Control) que el threshold TUS 1
gen group1Treated = 0
replace group1Treated = 1 if hogarZeroCuantasTus==1 & iccMenosThreshold1<0
gen group1Control = 0 
replace group1Control = 1 if hogarZeroCuantasTus==1 & iccMenosThreshold1>0

** Spec 2: Aquellos que inicialmente NO recibian TUS y tuvieron ICC menor (Control) o mayor (Treated) que el threshold TUS 1
gen group2Treated = 0
replace group2Treated = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1>0
gen group2Control = 0 
replace group2Control = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1<0

** Spec 3: Aquellos que inicialmente NO recibian TUS y tuvieron ICC menor (Control) que threshold TUS 1 o mayor que Threshold TUS 2 (Treated)
gen group3Treated = 0
replace group3Treated = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold2>0
gen group3Control = 0 
replace group3Control = 1 if hogarZeroCuantasTus==0 & iccMenosThreshold1<0

** Spec 4: Aquellos que inicialmente recibian 2 TUS y tuvieron ICC menor (Treated) que el threshold TUS 1 o mayor que el threshold TUS 2 (Control)
gen group4Treated = 0
replace group4Treated = 1 if hogarZeroCuantasTus==2 & iccMenosThreshold1<0
gen group4Control = 0 
replace group4Control = 1 if hogarZeroCuantasTus==2 & iccMenosThreshold2>0

keep if (group1Treated==1 | group1Control==1 | group2Treated==1 | group2Control==1 | group3Treated==1 | group3Control==1 | group4Treated==1 | group4Control==1)
keep if iccMenosThreshold1>-0.25

save prog_para_probar_did.dta, replace // La guardo preliminarmente por si tengo q volver a cargar para no hacer todos los merge anteriores

* Taggeo los duplicados y los elimino
duplicates tag nrodocumentoSIIAS, generate(dupl)
keep if dupl==0


gen periodoRelativoVisita=0
gegen id=group(flowcorrelativeid nrodocumentoSIIAS)
drop flowcorrelativeid nrodocumentoSIIAS umbral_afam umbral_nuevo_tus umbral_nuevo_tus_dup icc iccMenosThresholdAll

xtset id periodoRelativoVisita
expand 48+12+1
sort id
by id: gen periodo1 =_n

replace periodoRelativoVisita = periodo1 - 13
generate mides_inda_panrn=.
replace mides_inda_panrn= zeromides_inda_panrn if periodoRelativoVisita==0

foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
	replace mides_inda_panrn= masmides_inda_panrn`num' if periodoRelativoVisita==`num'
}
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 {
	replace mides_inda_panrn= menosmides_inda_panrn`num' if periodoRelativoVisita==-`num'
}

foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
	gen mas`num'=0
	replace mas`num'=1 if periodoRelativoVisita==`num'
}
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 {
		gen menos`num'=0
		replace menos`num'=1 if periodoRelativoVisita==-`num'
}

/*
foreach spec in $specsDID {
	gegen group`spec'Treatedg = max(group`spec'Treated), by(id)
	gegen group`spec'Controlg = max(group`spec'Control), by(id)
}

*/

foreach spec in 4 {

	foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 {
		gen mas`num'Treated`spec'= group`spec'Treated * mas`num'
		gen mas`num'Control`spec'= group`spec'Control * mas`num'
	}
	foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 {
		gen menos`num'Treated`spec'= group`spec'Treated * menos`num'
		gen menos`num'Control`spec'= group`spec'Control * menos`num'
	}

}

*** Keep solo algunas variables antes de correr regresiones (para que corra más rápido)
*xtset, clear

*** DID estimates
foreach spec in 4 {
	regress mides_inda_panrn group`spec'Treated ///
	mas30Treated`spec' mas29Treated`spec' mas28Treated`spec' mas27Treated`spec' ///
	mas26Treated`spec' mas25Treated`spec' mas24Treated`spec' mas23Treated`spec' mas22Treated`spec' mas21Treated`spec' ///
	mas20Treated`spec' mas19Treated`spec' mas18Treated`spec' mas17Treated`spec' mas16Treated`spec' mas15Treated`spec' ///
	mas14Treated`spec' mas13Treated`spec' mas12Treated`spec' mas11Treated`spec' mas10Treated`spec' mas9Treated`spec' ///
	mas8Treated`spec' mas7Treated`spec' mas6Treated`spec' mas5Treated`spec' mas4Treated`spec' mas3Treated`spec' ///
	mas2Treated`spec' mas1Treated`spec' menos1Treated`spec' menos2Treated`spec' menos3Treated`spec' menos4Treated`spec' ///
	menos5Treated`spec' menos6Treated`spec' menos7Treated`spec' menos8Treated`spec' menos9Treated`spec' ///
	menos10Treated`spec' menos11Treated`spec' menos12Treated`spec' ///
	mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 ///
	mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 ///
	menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12 ///
	if masmides_inda_panrn30!=. & menosmides_inda_panrn12!=. & zeromides_inda_panrn!=. & menosmides_inda_panrn1!=. & (group`spec'Treated==1 | group`spec'Control==1) & periodoRelativoVisita<=30 & periodoRelativoVisita>=-12, robust
	cap noisily outreg2 using ..\Output\DIDmides_inda_panrn`spec'.xls, e(all) replace
	
	coefplot, drop(_cons group`spec'Treated mas36 mas35 mas34 mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12) xline(0)
}


foreach spec in 3 {
	regress mides_inda_panrn group`spec'Treated mas48Treated`spec' mas47Treated`spec' mas46Treated`spec' mas45Treated`spec' ///
	mas44Treated`spec' mas43Treated`spec' mas42Treated`spec' mas41Treated`spec' mas40Treated`spec' mas39Treated`spec' ///
	mas38Treated`spec' mas37Treated`spec' mas36Treated`spec' mas35Treated`spec' mas34Treated`spec' mas33Treated`spec' ///
	mas32Treated`spec' mas31Treated`spec' mas30Treated`spec' mas29Treated`spec' mas28Treated`spec' mas27Treated`spec' ///
	mas26Treated`spec' mas25Treated`spec' mas24Treated`spec' mas23Treated`spec' mas22Treated`spec' mas21Treated`spec' ///
	mas20Treated`spec' mas19Treated`spec' mas18Treated`spec' mas17Treated`spec' mas16Treated`spec' mas15Treated`spec' ///
	mas14Treated`spec' mas13Treated`spec' mas12Treated`spec' mas11Treated`spec' mas10Treated`spec' mas9Treated`spec' ///
	mas8Treated`spec' mas7Treated`spec' mas6Treated`spec' mas5Treated`spec' mas4Treated`spec' mas3Treated`spec' ///
	mas2Treated`spec' mas1Treated`spec' menos1Treated`spec' menos2Treated`spec' menos3Treated`spec' menos4Treated`spec' ///
	menos5Treated`spec' menos6Treated`spec' menos7Treated`spec' menos8Treated`spec' menos9Treated`spec' ///
	menos10Treated`spec' menos11Treated`spec' menos12Treated`spec' ///
	mas48 mas47 mas46 mas45 mas44 mas43 mas42 mas41 mas40 mas39 mas38 mas37 mas36 mas35 mas34 ///
	mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 ///
	mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 ///
	menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12 ///
	if masmides_inda_panrn48!=. & menosmides_inda_panrn12!=. & zeromides_inda_panrn!=. & menosmides_inda_panrn1!=. & (group`spec'Treated==1 | group`spec'Control==1), robust
	*cap noisily outreg2 using ..\Output\DIDAutor11`spec'.xls, e(all) replace
	
	coefplot, drop(_cons group`spec'Treated mas48 mas47 mas46 mas45 mas44 mas43 mas42 mas41 mas40 mas39 mas38 mas37 mas36 mas35 mas34 mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12) xline(0)
}

regress mides_inda_panrn mas24Treated3 mas23Treated3 mas22Treated3 menos1Treated3 menos2Treated3 menos3Treated3 group3Treated mas24 mas23 mas22 menos1 menos2 menos3 if (periodoRelativoVisita==0 | periodoRelativoVisita==24 | periodoRelativoVisita==23 | periodoRelativoVisita==22 | periodoRelativoVisita==-1 | periodoRelativoVisita==-2 | periodoRelativoVisita==-3) & masmides_inda_panrn24!=. & zeromides_inda_panrn!=. & menosmides_inda_panrn1!=. & menosmides_inda_panrn2!=. & (group3Treated==1 | group3Control==1), r



