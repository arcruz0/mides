* Objective: Mirar second stage de impacto TUS en Prog-sociales-SIIAS. DID.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros
global allVars bps_afam_ley_benef bps_afam_ley_atrib bps_pens_vejez bps_sol_habit_am mvotma_rubv inau_t_comp inau_disc_t_comp inau_caif inau_club_niños inau_ctros_juveniles mid_asist_vejez mides_canasta_serv mides_jer mides_cercanias mides_ucc mides_uy_trab mides_monotributo mides_inda_snc mides_inda_paec mides_inda_panrn
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado
global varsTUS hogarZerocobraTus hogarZerotusDoble
global specsDID 1 2 3 4

* Load dataset a nivel de personas con datos de Prog-sociales-SIIAS
foreach var in $allVars {
	import delimited ..\Input\MIDES\visitas_personas_`var'.csv, clear case(preserve)

	keep flowcorrelativeid nrodocumentoDAES fechavisita icc nrodocumentoSIIAS year month periodo umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam menos`var'1 - menos`var'18 zero`var' mas`var'1 - mas`var'48 

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
	gen hogarZeroCuantasTus = hogarZerocobraTus + hogarZerotusDoble
	
	if ("`var'"=="bps_afam_ley_benef" | "`var'"=="inau_t_comp" | "`var'"=="inau_disc_t_comp" | "`var'"=="inau_caif" | "`var'"=="inau_club_niños" | "`var'"=="inau_ctros_juveniles" | "`var'"=="mides_jer") {
		keep if edad_visita<18
		}
	else {
		keep if edad_visita>=18
	}
	*keep if iccMenosThreshold1>-0.25
	*keep if iccMenosThreshold0>0

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


	save prog_afam_probar_did.dta, replace // La guardo preliminarmente por si tengo q volver a cargar para no hacer todos los merge anteriores

	* Taggeo los duplicados y los elimino
	duplicates tag nrodocumentoSIIAS, generate(dupl)
	keep if dupl==0


	gen periodoRelativoVisita=0
	gegen id=group(flowcorrelativeid nrodocumentoSIIAS)
	drop flowcorrelativeid nrodocumentoSIIAS umbral_afam umbral_nuevo_tus umbral_nuevo_tus_dup icc

	xtset id periodoRelativoVisita
	expand 48+18+1
	sort id
	by id: gen periodo1 =_n

	replace periodoRelativoVisita = periodo1 - 19
	generate `var'=.
	replace `var'= zero`var' if periodoRelativoVisita==0

	forvalues num = 1/48 {
		replace `var'= mas`var'`num' if periodoRelativoVisita==`num'
	}
	forvalues num = 1/18 {
		replace `var'= menos`var'`num' if periodoRelativoVisita==-`num'
	}
	
	gen zero =0
	replace zero=1 if periodoRelativoVisita==0
	forvalues num = 1/48 {
		gen mas`num'=0
		replace mas`num'=1 if periodoRelativoVisita==`num'
	}
	forvalues num = 1/18 {
			gen menos`num'=0
			replace menos`num'=1 if periodoRelativoVisita==-`num'
	}

	/*
	foreach spec in $specsDID {
		gegen group`spec'Treatedg = max(group`spec'Treated), by(id)
		gegen group`spec'Controlg = max(group`spec'Control), by(id)
	}

	*/

	foreach spec in 1 2 3 4 {

		forvalues num = 1/48 {
			gen mas`num'Treated`spec'= group`spec'Treated * mas`num'
			gen mas`num'Control`spec'= group`spec'Control * mas`num'
		}
		forvalues num = 1/18 {
			gen menos`num'Treated`spec'= group`spec'Treated * menos`num'
			gen menos`num'Control`spec'= group`spec'Control * menos`num'
		}

	}

	*** Keep solo algunas variables antes de correr regresiones (para que corra más rápido)
	*xtset, clear

	*** DID estimates
	foreach spec in 1 2 3 4 {
		regress bps_afam_ley_benef group`spec'Treated ///
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
		if masbps_afam_ley_benef30!=. & menosbps_afam_ley_benef12!=. & zerobps_afam_ley_benef!=. & menosbps_afam_ley_benef1!=. & (group`spec'Treated==1 | group`spec'Control==1) & periodoRelativoVisita<=30 & periodoRelativoVisita>=-12 & edad_visita<=14, robust
		cap noisily outreg2 using DIDbps_afam_ley_benef`spec'.xls, e(all) replace
		
		*coefplot, drop(_cons group`spec'Treated mas30 mas29 mas28 mas27 mas26 mas25 mas24 mas23 mas22 mas21 mas20 mas19 mas18 mas17 mas16 mas15 mas14 mas13 mas12 mas11 mas10 mas9 mas8 mas7 mas6 mas5 mas4 mas3 mas2 mas1 menos1 menos2 menos3 menos4 menos5 menos6 menos7 menos8 menos9 menos10 menos11 menos12) xline(0)
	}



	*regress bps_afam_ley_benef mas24Treated3 mas23Treated3 mas22Treated3 menos1Treated3 menos2Treated3 menos3Treated3 group3Treated mas24 mas23 mas22 menos1 menos2 menos3 if (periodoRelativoVisita==0 | periodoRelativoVisita==24 | periodoRelativoVisita==23 | periodoRelativoVisita==22 | periodoRelativoVisita==-1 | periodoRelativoVisita==-2 | periodoRelativoVisita==-3) & masbps_afam_ley_benef24!=. & zerobps_afam_ley_benef!=. & menosbps_afam_ley_benef1!=. & menosbps_afam_ley_benef2!=. & (group3Treated==1 | group3Control==1), r
	clear all
	}
