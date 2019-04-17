* Objective: Mirar second stage de impacto TUS en BPS-SIIAS.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros
global varsTUS hogarZerocobraTus hogarZerotusDoble hogarMascobraTus3 hogarMastusDoble3 hogarMascobraTus6 hogarMastusDoble6 hogarMascobraTus9 hogarMastusDoble9 hogarMascobraTus12 hogarMastusDoble12 hogarMascobraTus18 hogarMastusDoble18 hogarMascobraTus24 hogarMastusDoble24
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado
global varsAFAM hogarZerocobraAFAM hogarMascobraAFAM3 hogarMascobraAFAM6 hogarMascobraAFAM9 hogarMascobraAFAM12 hogarMascobraAFAM18 hogarMascobraAFAM24 hogarMenoscobraAFAM3 hogarMenoscobraAFAM6 hogarMenoscobraAFAM9 hogarMenoscobraAFAM12 hogarMenoscobraAFAM18 hogarMenoscobraAFAM24
global varsAllPers -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
global varsAllPersPositive 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
global varsAllPersNegative 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1
global groupsRDD1 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD2 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS60!=. & menosocupadoSIIAS24!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD3 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(1) fuzzy(hogarMascobraTus24) vce(hc0)"
global groupsRDD4 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & sexo==2, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD5 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & sexo==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD6 "iccMenosThreshold1 if edad_visita>18 & edad_visita<=64 & sexo==2 & masocupadoSIIAS60!=. & menosocupadoSIIAS24!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD7 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=., c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD8 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"
global groupsRDD9 "iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & masocupadoSIIAS36!=. & menosocupadoSIIAS12!=. & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)"

global cuantosGruposRDD 7 8 9


* Load dataset a nivel de personas con datos de BPS-SIIAS
import delimited ..\Input\MIDES\BPS_SIIAS_personas.csv, clear case(preserve)

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
gen iccMenosThresholdAll=.
replace iccMenosThresholdAll = iccMenosThreshold0 if abs(iccMenosThreshold0)<abs(iccMenosThreshold1) & abs(iccMenosThreshold0)<abs(iccMenosThreshold2)
replace iccMenosThresholdAll = iccMenosThreshold1 if abs(iccMenosThreshold1)<abs(iccMenosThreshold0) & abs(iccMenosThreshold1)<abs(iccMenosThreshold2)
replace iccMenosThresholdAll = iccMenosThreshold2 if abs(iccMenosThreshold2)<abs(iccMenosThreshold0) & abs(iccMenosThreshold2)<abs(iccMenosThreshold1)

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

*** RD estimates (one period)
gen mdeo=0
replace mdeo=1 if departamento==1
foreach yr in 2010 2011 2012 2013 2014 2015 2016 2017 {
	gen y`yr'=0
	replace y`yr'=1 if year==`yr'
}

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
	matrix mGroup`gr'=J(6,85,.)
	matrix colnames mGroup`gr' = -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
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

