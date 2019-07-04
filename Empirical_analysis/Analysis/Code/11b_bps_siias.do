* Objective: Mirar second stage de impacto TUS en BPS-SIIAS. Primero hago RDD y luego DID

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros
global varsTUS hogarZerocobraTus hogarZerotusDoble hogarMascobraTus12 hogarMastusDoble12
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado
global varsAFAM hogarZerocobraAFAM hogarMascobraAFAM3 hogarMascobraAFAM6 hogarMascobraAFAM9 hogarMascobraAFAM12 hogarMascobraAFAM18 hogarMascobraAFAM24 hogarMenoscobraAFAM3 hogarMenoscobraAFAM6 hogarMenoscobraAFAM9 hogarMenoscobraAFAM12 hogarMenoscobraAFAM18 hogarMenoscobraAFAM24
global varsAllPers -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
global varsAllPersPositive 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
global varsAllPersNegative 12 11 10 9 8 7 6 5 4 3 2 1
global groupsRDD1 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD2 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS60!=. & menosocupadoSIIAS24!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD3 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(1) fuzzy(hogarMascobraTus24) vce(hc0)"
global groupsRDD4 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & sexo==2, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD5 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & sexo==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD6 "iccMenosThreshold1 if edad_visita>18 & edad_visita<=64 & sexo==2 & masocupadoSIIAS60!=. & menosocupadoSIIAS24!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD7 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD8 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD9 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD10 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS30!=. & menosocupadoSIIAS12!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD11 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS30!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD12 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS30!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD13 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS30!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus>=1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"


global cuantosGruposRDD 10 11 12 13


* Load dataset a nivel de personas con datos de BPS-SIIAS
import delimited ..\Input\MIDES\BPS_SIIAS_personas.csv, clear case(preserve)
drop bps_sub_desempleo* bps_sub_enfermedad* bps_sub_maternidad* bps_plan_materno* bps_plan_infantil* tipo_afiliacion* masbps_plan_materno* masbps_sub_enfermedad* masbps_sub_desempleo* mastipo_afiliacion*

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

gen iccSuperaPrimerTUS = .
replace iccSuperaPrimerTUS = 1 if iccMenosThreshold1>0
replace iccSuperaPrimerTUS = 0 if iccMenosThreshold1<0

gen iccNormInteractedPrimerTus = iccSuperaPrimerTUS * iccMenosThreshold1

gen hogarZeroCuantasTus = hogarZerocobraTus + hogarZerotusDoble

gen edad_visita2 = edad_visita * edad_visita

gegen visitID = group(flowcorrelativeid)

gen mdeo=0
replace mdeo=1 if departamento==1
foreach yr in 2010 2011 2012 2013 2014 2015 2016 2017 {
	gen y`yr'=0
	replace y`yr'=1 if year==`yr'
}

gen mujer = .
replace mujer=1 if sexo==2
replace mujer=0 if sexo==1

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

*** Binscatters
binscatter masocupadoSIIAS24 iccMenosThreshold0 if abs(iccMenosThreshold0)<0.2 & edad_visita>=18 & parentesco==1 & sexo==2, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)
binscatter masocupadoSIIAS24 iccMenosThreshold0 if abs(iccMenosThreshold0)<0.2 & edad_visita>=18 & parentesco==1 & sexo==2 & departamento!=1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)
binscatter masocupadoSIIAS24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & zeroocupadoSIIAS==1 & departamento==1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)
binscatter masocupadoSIIAS18 iccMenosThreshold2 if abs(iccMenosThreshold2)<0.2 & edad_visita>=18 & edad_visita<=64 & sexo==2 & departamento!=1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)

** Elimino menores de la sample y miro duplicados
keep if edad_visita>=18
duplicates tag nrodocumentoSIIAS, generate(dupl)
*keep if dupl==0

*** RD estimates (one period)

global SCmasocupadoSIIAS24 y2013 y2014 y2015 y2016
foreach var in masocupadoSIIAS24 {
	* No controls	
	forvalues i = 1/2 {
		rdrobust `var' iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==0, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0)
		eststo `var'0`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'NC
		estadd scalar band = e(h_l): `var'0`i'NC
		scalar band = e(h_l)
		local `var'0`i'NC = scalar(band)
		
		mean `var' if hogarMascobraTus12==1 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<``var'0`i'NC'
		matrix `var'0`i'NC = e(b)
		estadd scalar meanCtrl = `var'0`i'NC[1,1] : `var'0`i'NC
		estadd local demoControls "No": `var'0`i'NC
		estadd local allControls "No": `var'0`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'NC
			}
			
		
		rdrobust `var' iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==1, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0)
		eststo `var'1`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'NC
		estadd scalar band = e(h_l): `var'1`i'NC
		scalar band = e(h_l)
		local `var'1`i'NC = scalar(band)
		
		mean `var' if hogarMascobraTus12==1 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<``var'1`i'NC'
		matrix `var'1`i'NC = e(b)
		estadd scalar meanCtrl = `var'1`i'NC[1,1] : `var'1`i'NC
		estadd local demoControls "No": `var'1`i'NC
		estadd local allControls "No": `var'1`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'NC
			}
		
* Some controls
		rdrobust `var' iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==0, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0) covs(${SC`var'})
		eststo `var'0`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'SC
		estadd scalar band = e(h_l): `var'0`i'SC
		scalar band = e(h_l)
		local `var'0`i'SC = scalar(band)
		
		mean `var' if hogarMascobraTus12==1 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<``var'0`i'SC'
		matrix `var'0`i'SC = e(b)
		estadd scalar meanCtrl = `var'0`i'SC[1,1] : `var'0`i'SC
		estadd local demoControls "Yes": `var'0`i'SC
		estadd local allControls "No": `var'0`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'SC
			}
				
		
		rdrobust `var' iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==1, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0) covs(${SC`var'})
		eststo `var'1`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'SC
		estadd scalar band = e(h_l): `var'1`i'SC
		scalar band = e(h_l)
		local `var'1`i'SC = scalar(band)
		
		mean `var' if hogarMascobraTus12==1 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<``var'1`i'SC'
		matrix `var'1`i'SC = e(b)
		estadd scalar meanCtrl = `var'1`i'SC[1,1] : `var'1`i'SC
		estadd local demoControls "Yes": `var'1`i'SC
		estadd local allControls "No": `var'1`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'SC
			}

}

}

foreach var in masocupadoSIIAS24 {
	esttab `var'01NC `var'11NC `var'01SC `var'11SC using ..\Output\\`var'1.tex, replace ///
	mgroups("Prob. formal employment 24 months after visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02SC `var'12SC using ..\Output\\`var'2.tex, replace ///
	mgroups("Prob. formal employment 24 months after visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}



rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0) covs(${AC`var'})							
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
binscatter masocupadoSIIAS24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & zeroocupadoSIIAS==1 & departamento==1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)




rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)

rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & edad_visita<=62  & zeroocupadoSIIAS==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & edad_visita<=62 & zeroocupadoSIIAS==1 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & edad_visita<=62 & zeroocupadoSIIAS==1 & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)

rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>20 & edad_visita<=62, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>20 & edad_visita<=62 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>20 & edad_visita<=62  & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)


*** RD estimates (several periods)
foreach gr in $cuantosGruposRDD {
	matrix mGroup`gr'=J(6,43,.)
	matrix colnames mGroup`gr' = -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
	matrix rownames mGroup`gr' = b se lci5 uci5 lci10 uci10

	scalar i=0

	foreach per in $varsAllPersNegative {
		scalar i=i+1
		rdrobust menosocupadoSIIAS`per' ${groupsRDD`gr'}
		matrix mGroup`gr'[1,i]=e(tau_cl)
		matrix mGroup`gr'[2,i]=e(se_tau_cl)
		matrix mGroup`gr'[3,i]=e(tau_cl) - 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[4,i]=e(tau_cl) + 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[5,i]=e(tau_cl) - 1.645 * e(se_tau_cl)
		matrix mGroup`gr'[6,i]=e(tau_cl) + 1.645 * e(se_tau_cl)
	}
	
	if `gr' < 6 | `gr'>6 {
		scalar i=i+1
		matrix mGroup`gr'[1,i]=0
		matrix mGroup`gr'[2,i]=0
		matrix mGroup`gr'[3,i]=0
		matrix mGroup`gr'[4,i]=0
		matrix mGroup`gr'[5,i]=0
		matrix mGroup`gr'[6,i]=0
	}
	
	else {
		scalar i=i+1
		rdrobust zeroocupadoSIIAS ${groupsRDD`gr'}
		matrix mGroup`gr'[1,i]=e(tau_cl)
		matrix mGroup`gr'[2,i]=e(se_tau_cl)
		matrix mGroup`gr'[3,i]=e(tau_cl) - 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[4,i]=e(tau_cl) + 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[5,i]=e(tau_cl) - 1.645 * e(se_tau_cl)
		matrix mGroup`gr'[6,i]=e(tau_cl) + 1.645 * e(se_tau_cl)

	}


	foreach per in $varsAllPersPositive {
		scalar i=i+1
		rdrobust masocupadoSIIAS`per' ${groupsRDD`gr'}
		matrix mGroup`gr'[1,i]=e(tau_cl)
		matrix mGroup`gr'[2,i]=e(se_tau_cl)
		matrix mGroup`gr'[3,i]=e(tau_cl) - 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[4,i]=e(tau_cl) + 1.96 * e(se_tau_cl)
		matrix mGroup`gr'[5,i]=e(tau_cl) - 1.645 * e(se_tau_cl)
		matrix mGroup`gr'[6,i]=e(tau_cl) + 1.645 * e(se_tau_cl)
	}

	matrix list mGroup`gr'
	putexcel set ..\Output\mGroup`gr'.xls, replace
	putexcel A1=matrix(mGroup`gr')
}

gen masocupadoSIIAS24a36 = (masocupadoSIIAS24 + masocupadoSIIAS25 + masocupadoSIIAS26 + masocupadoSIIAS27 +masocupadoSIIAS28 + masocupadoSIIAS29 + masocupadoSIIAS30 + masocupadoSIIAS31 + masocupadoSIIAS32 + masocupadoSIIAS33 + masocupadoSIIAS34 + masocupadoSIIAS35 + masocupadoSIIAS36)/13

rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & year>=2011, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0) covs(mujer mdeo edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 y2016)

binscatter masocupadoSIIAS24a36 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres) controls(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS) nquantiles(20)
ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus mujer mdeo edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 y2016 (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & abs(iccMenosThreshold1)<0.2, robust first	
rdrobust masocupadoSIIAS24a36 iccMenosThreshold1 if edad_visita>=18 & edad_visita<=60 & year>=2011 & year<=2015 & departamento==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(cluster visitID) covs(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS)

binscatter masocupadoSIIAS24a36 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(lfitci) xtitle(ICC - Prim TUS thres) controls(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS) nquantiles(20) reportreg
regress masocupadoSIIAS24a36 iccSuperaPrimerTUS iccMenosThreshold1 iccNormInteractedPrimerTus mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & abs(iccMenosThreshold1)<0.2, robust first



rdrobust masocupadoSIIAS36 iccMenosThreshold1 if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, c(0) p(1) fuzzy(hogarMascobraTus12) vce(cluster visitID) covs(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS)
rdrobust masocupadoSIIAS36 iccMenosThreshold1 if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, c(0) p(1) fuzzy(hogarMascobraTus12) vce(cluster visitID) covs(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS)


* I run this and keep this bandwith
rdrobust masocupadoSIIAS36 iccMenosThreshold1 if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, c(0) p(1) fuzzy(hogarMascobraTus12) vce(cluster visitID)
rdrobust masocupadoSIIAS36 iccMenosThreshold1 if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, c(0) p(1) fuzzy(hogarMascobraTus12) vce(cluster visitID) covs(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS)

* Relevant binscatters
binscatter masocupadoSIIAS36 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(lfit) xtitle(Vulnerability Index - First Threshold) ytitle(Perc. formally employed 3yrs after the visit) controls(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015 zeroocupadoSIIAS) nquantiles(20) savegraph(..\Output\masocupadoSIIAS36AllWC.pdf) replace
binscatter masocupadoSIIAS36 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(lfit) xtitle(Vulnerability Index - First Threshold) ytitle(Perc.formally employed 3yrs after the visit) nquantiles(20) savegraph(..\Output\masocupadoSIIAS36AllSC.pdf) replace

* Placebo binscatters
binscatter zeroocupadoSIIAS iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(lfit) xtitle(Vulnerability Index - First Threshold) ytitle(Perc. formally employed at the visit) controls(edad_visita edad_visita2 mujer y2012 y2013 y2014 y2015) nquantiles(20) savegraph(..\Output\masocupadoSIIAS36AllPlaWC.pdf) replace
binscatter zeroocupadoSIIAS iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015, rd(0) linetype(lfit) xtitle(Vulnerability Index - First Threshold) ytitle(Perc. formally employed at the visit) nquantiles(20) savegraph(..\Output\masocupadoSIIAS36AllPlaSC.pdf) replace

local bandALL = 0.134
* All sample with and without controls
ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)
eststo AllSC
estadd scalar nobs = e(N): AllSC
estadd scalar band = `bandALL': AllSC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & abs(iccMenosThreshold1)<`bandALL' & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix AllSC = e(b)
estadd scalar meanCtrl = AllSC[1,1]: AllSC
estadd local demoControls "No": AllSC
estadd local poly "Linear": AllSC
estadd local SErrors "Cluster": AllSC


ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)	
eststo AllWC
estadd scalar nobs = e(N): AllWC
estadd scalar band = `bandALL': AllWC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & abs(iccMenosThreshold1)<`bandALL' & mujer!=. & edad_visita!=. & edad_visita2!=. & zeroocupadoSIIAS!=. & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix AllWC = e(b)
estadd scalar meanCtrl = AllWC[1,1]: AllWC
estadd local demoControls "Yes": AllWC
estadd local poly "Linear": AllWC
estadd local SErrors "Cluster": AllWC

* Hogar sin TUS inicialmente
ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)	
eststo SinSC
estadd scalar nobs = e(N): SinSC
estadd scalar band = `bandALL': SinSC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<`bandALL' & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix SinSC = e(b)
estadd scalar meanCtrl = SinSC[1,1]: SinSC
estadd local demoControls "No": SinSC
estadd local poly "Linear": SinSC
estadd local SErrors "Cluster": SinSC

ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)	
eststo SinWC
estadd scalar nobs = e(N): SinWC
estadd scalar band = `bandALL': SinWC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & hogarZerocobraTus==0 & abs(iccMenosThreshold1)<`bandALL' & mujer!=. & edad_visita!=. & edad_visita2!=. & zeroocupadoSIIAS!=. & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix SinWC = e(b)
estadd scalar meanCtrl = SinWC[1,1]: SinWC
estadd local demoControls "Yes": SinWC
estadd local poly "Linear": SinWC
estadd local SErrors "Cluster": SinWC

* Hogar con TUS inicialmente
ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)	
eststo ConSC
estadd scalar nobs = e(N): ConSC
estadd scalar band = `bandALL': ConSC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<`bandALL' & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix ConSC = e(b)
estadd scalar meanCtrl = SinSC[1,1]: ConSC
estadd local demoControls "No": ConSC
estadd local poly "Linear": ConSC
estadd local SErrors "Cluster": ConSC

ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<`bandALL', vce(cluster visitID)	
eststo ConWC
estadd scalar nobs = e(N): ConWC
estadd scalar band = `bandALL': ConWC
mean masocupadoSIIAS36 if hogarMascobraTus12==1 & hogarZerocobraTus==1 & abs(iccMenosThreshold1)<`bandALL' & mujer!=. & edad_visita!=. & edad_visita2!=. & zeroocupadoSIIAS!=. & edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015
matrix ConWC = e(b)
estadd scalar meanCtrl = ConWC[1,1]: ConWC
estadd local demoControls "Yes": ConWC
estadd local poly "Linear": ConWC
estadd local SErrors "Cluster": ConWC

* Hago tabla con 6 columnas
esttab AllSC AllWC SinSC SinWC ConSC ConWC  using ..\Output\masocupadoSIIAS36.tex, replace ///
mgroups("Prob. formal employment 3 years after" "Revisited on a non-requested visit", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
stats(nobs meanCtrl band poly demoControls SErrors, fmt(0 3 3 3 3 3) labels("Observations" "Recipients mean" "Bandwith" "RD polynomial" "Controls" "SE")) ///
se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(hogarMascobraTus12 "UCT 1yr after") ///
mtitles("All" "All" "UCT = 0" "UCT = 0" "UCT = 1" "UCT = 1") drop(iccMenosThreshold1 iccNormInteractedPrimerTus _cons mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015)
	
* Robustness con bandwith para resultado más robusto
matrix robustness = J(25,4,0)
foreach band in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 {
ivregress 2sls masocupadoSIIAS36 iccMenosThreshold1 iccNormInteractedPrimerTus mujer edad_visita edad_visita2 zeroocupadoSIIAS y2012 y2013 y2014 y2015 (hogarMascobraTus12 = iccSuperaPrimerTUS) if edad_visita>=18 & edad_visita<=60 & departamento==1 & year>=2011 & year<=2015 & abs(iccMenosThreshold1)<0.175 - `band' * 0.005, vce(cluster visitID)	
matrix Betas = e(b)
scalar beta = Betas[1,1]
matrix robustness[`band',1] = beta
*matrix Variances = e(V)
}

matrix robustness[1,2] = .0162877 
matrix robustness[2,2] = .0164664
matrix robustness[3,2] = .0166899
matrix robustness[4,2] = .0169047
matrix robustness[5,2] = .0170731 
matrix robustness[6,2] = .0174766
matrix robustness[7,2] = .0177095
matrix robustness[8,2] = .0180714
matrix robustness[9,2] = .0184722
matrix robustness[10,2] = .0188242
matrix robustness[11,2] = .0191475
matrix robustness[12,2] = .0194767 
matrix robustness[13,2] =  .0198305
matrix robustness[14,2] = .020372
matrix robustness[15,2] = .020804
matrix robustness[16,2] = .0213352
matrix robustness[17,2] = .0220737
matrix robustness[18,2] =  .022716
matrix robustness[19,2] = .0236203
matrix robustness[20,2] = .0243619
matrix robustness[21,2] =  .0255896
matrix robustness[22,2] = .026495
matrix robustness[23,2] = .0272509
matrix robustness[24,2] = .0288537 
matrix robustness[25,2] = .0303354

foreach band in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 {
	matrix robustness[`band',3] = robustness[`band',1] - 1.65 * robustness[`band',2]
	matrix robustness[`band',4] = robustness[`band',1] + 1.65 * robustness[`band',2]
}

mat list robustness
putexcel set ..\Output\robustness.xls
putexcel A1=matrix(robustness)
