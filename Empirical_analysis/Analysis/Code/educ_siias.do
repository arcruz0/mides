* Objective: Mirar second stage de impacto TUS en Educ-SIIAS.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

global controlsDID1 mujer edad edad2 mdeo year3 year4 year5 year6 year7 year8 year9 year10 mes2 mes3 mes4 mes5 mes6 mes7 mes8 mes9 mes10 mes11 mes12
global controlsDID2 mujer edadD2 edadD3 edadD4 edadD5 edadD6 edadD7 edadD8 edadD9 edadD10 edadD11 edadD12 edadD13 edadD14 edadD15 edadD16 edadD17 edadD18 edadD19 edadD20 edadD21 dep1 dep2 dep3 dep4 dep5 dep6 dep7 dep8 dep9 dep10 dep11 dep12 dep13 dep14 dep15 dep16 dep17 dep18 dep19 year3 year4 year5 year6 year7 year8 year9 year10 mes2 mes3 mes4 mes5 mes6 mes7 mes8 mes9 mes10 mes11 mes12 
global varsAFAM hogarZerocobraAFAM hogarMascobraAFAM12
global varsTUS hogarZerocobraTus hogarZerotusDoble departamento
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado nrodocumentoDAES fechanacimiento
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
 masenCES41 masenCES42 masenCES43 masenCES44 masenCES45 masenCES46 masenCES47 masenCES48

* Load dataset a nivel de personas con datos de Educ-SIIAS
import delimited ..\Input\MIDES\visitas_personas_educ_siias.csv, clear case(preserve)
keep $varsEduc flowcorrelativeid nrodocumentoSIIAS icc umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam periodo

* Merge con data de TUS que deseo
merge m:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_TUS.dta, keep (master match) keepusing(${varsTUS})
drop _merge

* Merge con data de visitas-personas que deseo
merge 1:1 nrodocumentoSIIAS flowcorrelativeid using ..\Input\MIDES\visitas_personas_vars.dta, keep (master match) keepusing(${varsPersonas})
drop _merge

* Merge con data de AFAM que deseo
merge 1:1 nrodocumentoSIIAS flowcorrelativeid using ..\Input\MIDES\visitas_personas_AFAM.dta, keep (master match) keepusing(${varsAFAM})
drop _merge


*** Genero variables
gen iccMenosThreshold0 = icc - umbral_afam
gen iccMenosThreshold1 = icc - umbral_nuevo_tus
gen iccMenosThreshold2 = icc - umbral_nuevo_tus_dup
gen hogarZeroCuantasTus = hogarZerocobraTus + hogarZerotusDoble
gen noCambiaAFAM = .
replace noCambiaAFAM = 1 if hogarZerocobraAFAM!=. & hogarMascobraAFAM12!=. & hogarZerocobraAFAM==hogarMascobraAFAM12
replace noCambiaAFAM = 0 if hogarZerocobraAFAM!=. & hogarMascobraAFAM12!=. & hogarZerocobraAFAM!=hogarMascobraAFAM12

* Relativas a educación
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
	gen masEstudiaCEIPCES`num' = .
	replace masEstudiaCEIPCES`num' = 0 if (masenCEIP`num'==0 | masenCES`num'==0)
	replace masEstudiaCEIPCES`num' = 1 if (masenCEIP`num'==1 | masenCES`num'==1)
}

foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
	gen menosEstudiaCEIPCES`num' = .
	replace menosEstudiaCEIPCES`num' = 0 if (menosenCEIP`num'==0 | menosenCES`num'==0)
	replace menosEstudiaCEIPCES`num' = 1 if (menosenCEIP`num'==1 | menosenCES`num'==1)
}

gen zeroEstudiaCEIPCES = .
replace zeroEstudiaCEIPCES = 0 if (zeroenCEIP==0 | zeroenCES==0)
replace zeroEstudiaCEIPCES = 1 if (zeroenCEIP==1 | zeroenCES==1)



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
drop masenCEIP1 masenCEIP2 masenCEIP3 masenCEIP4 masenCEIP5 masenCEIP6 masenCEIP7 masenCEIP8 masenCEIP9 masenCEIP10 masenCEIP11 masenCEIP12 masenCEIP13 masenCEIP14 masenCEIP15 masenCEIP16 masenCEIP17 masenCEIP18 masenCEIP19 masenCEIP20 masenCEIP21 masenCEIP22 masenCEIP23 masenCEIP24 masenCEIP26 masenCEIP25 masenCEIP27 masenCEIP28 masenCEIP29 masenCEIP30 masenCEIP31 masenCEIP32 masenCEIP33 masenCEIP34 masenCEIP35 masenCEIP36 masenCEIP37 masenCEIP38 masenCEIP39 masenCEIP40 masenCEIP41 masenCEIP42 masenCEIP43 masenCEIP44 masenCEIP45 masenCEIP46 masenCEIP47 masenCEIP48 menosenCEIP1 menosenCEIP2 menosenCEIP3 menosenCEIP4 menosenCEIP5 menosenCEIP6 menosenCEIP7 menosenCEIP8 menosenCEIP9 menosenCEIP10 menosenCEIP11 menosenCEIP12 zeroenCEIP masenCES1 masenCES2 masenCES3 masenCES4 masenCES5 masenCES6 masenCES7 masenCES8 masenCES9 masenCES10 masenCES11 masenCES12 masenCES13 masenCES14 masenCES15 masenCES16 masenCES17 masenCES18 masenCES19 masenCES20 masenCES21 masenCES22 masenCES23 masenCES24 masenCES25 masenCES26 masenCES27 masenCES28 masenCES29 masenCES30 masenCES31 masenCES32 masenCES33 masenCES34 masenCES35 masenCES36 masenCES37 masenCES38 masenCES39 masenCES40 masenCES41 masenCES42 masenCES43 masenCES44 masenCES45 masenCES46 masenCES47 masenCES48 menosenCES1 menosenCES2 menosenCES3 menosenCES4 menosenCES5 menosenCES6 menosenCES7 menosenCES8 menosenCES9 menosenCES10 menosenCES11 menosenCES12 zeroenCES 

save educ_para_probar_did.dta, replace // La guardo preliminarmente por si tengo q volver a cargar para no hacer todos los merge anteriores

* Taggeo los duplicados y los elimino y también elimino observaciones con menos de 15 años al momento de la visita
duplicates tag nrodocumentoSIIAS, generate(dupl)
*keep if dupl==0
keep if edad_visita<=15

gen periodoRelativoVisita=0
gegen id=group(flowcorrelativeid nrodocumentoSIIAS)
drop flowcorrelativeid nrodocumentoSIIAS umbral_afam umbral_nuevo_tus umbral_nuevo_tus_dup icc

xtset id periodoRelativoVisita
expand 48+18+1
sort id
by id: gen periodo1 =_n

replace periodoRelativoVisita = periodo1 - 19
generate EstudiaCEIPCES=.
replace EstudiaCEIPCES= zeroEstudiaCEIPCES if periodoRelativoVisita==0

foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
	replace EstudiaCEIPCES= masEstudiaCEIPCES`num' if periodoRelativoVisita==`num' 
}
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
	replace EstudiaCEIPCES= menosEstudiaCEIPCES`num' if periodoRelativoVisita==-`num'
}

foreach num in 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23 25 26 27 28 29 30 31 32 33 34 35 37 38 39 40 41 42 43 44 45 46 47 {
	drop masEstudiaCEIPCES`num'
}

foreach num in 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 {
	drop menosEstudiaCEIPCES`num'
}


foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
	gen mas`num'=0
	replace mas`num'=1 if periodoRelativoVisita==`num'
}
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
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
merge m:1 periodo using ..\..\Build\Input\periodo_dictionary.dta, keep(master match)
drop _merge
rename mes mesVisita
rename year yearVisita

gen periodoObs = periodo + periodoRelativoVisita

rename periodo periodoTemp
rename periodoObs periodo

merge m:1 periodo periodo using ..\..\Build\Input\periodo_dictionary.dta, keep(master match)
drop _merge
rename periodo periodoObs
rename periodoTemp periodo

tabulate mes, generate(mes)
tabulate year, generate(year)
drop if (year==2008 | year==2009) // 1% de obs
drop year1 year2

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
drop if edad<0

foreach spec in 4 {

	foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 {
		gen mas`num'Treated`spec'= group`spec'Treated * mas`num'
		gen mas`num'Control`spec'= group`spec'Control * mas`num'
	}
	foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
		gen menos`num'Treated`spec'= group`spec'Treated * menos`num'
		gen menos`num'Control`spec'= group`spec'Control * menos`num'
	}

}

*** Keep solo algunas variables antes de correr regresiones (para que corra más rápido)
xtset, clear

*** DID estimates
foreach spec in 4 {
	regress EstudiaCEIPCES group`spec'Treated ///
	mas48Treated`spec' mas47Treated`spec' mas46Treated`spec' mas45Treated`spec' mas44Treated`spec' ///
	mas43Treated`spec' mas42Treated`spec' mas41Treated`spec' mas40Treated`spec' mas39Treated`spec' ///
	mas38Treated`spec' mas37Treated`spec' mas36Treated`spec' mas35Treated`spec' mas34Treated`spec' ///
	mas33Treated`spec' mas32Treated`spec' mas31Treated`spec' mas30Treated`spec' mas29Treated`spec' mas28Treated`spec' mas27Treated`spec' ///
	mas26Treated`spec' mas25Treated`spec' mas24Treated`spec' mas23Treated`spec' mas22Treated`spec' mas21Treated`spec' ///
	mas20Treated`spec' mas19Treated`spec' mas18Treated`spec' mas17Treated`spec' mas16Treated`spec' mas15Treated`spec' ///
	mas14Treated`spec' mas13Treated`spec' mas12Treated`spec' mas11Treated`spec' mas10Treated`spec' mas9Treated`spec' ///
	mas8Treated`spec' mas7Treated`spec' mas6Treated`spec' mas5Treated`spec' mas4Treated`spec' mas3Treated`spec' ///
	mas2Treated`spec' mas1Treated`spec' menos1Treated`spec' menos2Treated`spec' menos3Treated`spec' menos4Treated`spec' ///
	menos5Treated`spec' menos6Treated`spec' menos7Treated`spec' menos8Treated`spec' menos9Treated`spec' ///
	menos10Treated`spec' menos11Treated`spec' menos12Treated`spec' menos13Treated`spec' ///
	menos14Treated`spec' menos15Treated`spec' menos16Treated`spec' menos17Treated`spec' menos18Treated`spec' ///
	mas48 mas47 mas46 mas45 mas44 mas43 mas42 mas41 mas40 mas39 mas38 mas37 mas36 mas35 mas34 mas33 ///
	mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 ///
	mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 ///
	menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12 menos13 menos14 menos15 menos16 menos17 menos18 ///
	$controlsDID1 ///
	if dupl==0 & masEstudiaCEIPCES48!=. & menosEstudiaCEIPCES18!=. & (group`spec'Treated==1 | group`spec'Control==1) & periodoRelativoVisita<=48 & periodoRelativoVisita>=-18 & edad_visita<=13 & edad_visita>=8, robust
	cap noisily outreg2 using ..\Output\DIDEstudiaCEIPCES`spec'.xls, e(all) replace
	
	coefplot, drop($controlsDID1 _cons group`spec'Treated mas48 mas47 mas46 mas45 mas44 mas43 mas42 mas41 mas40 mas39 mas38 mas37 mas36 mas35 mas34 mas33 mas32 mas31 mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12 menos13 menos14 menos15 menos16 menos17 menos18) xline(0)
}

** Plots of treatment and control groups
binscatter EstudiaCEIPCES periodoRelativoVisita if (group4Treated==1 | group4Control==1) & periodoRelativoVisita<=48 & periodoRelativoVisita>=-12 & edad_visita<=13 & edad_visita>=8, by(group4Treated) discrete
