* Objective: Mirar second stage de impacto TUS en Educ-SIIAS.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

global varsTUS hogarZerocobraTus hogarZerotusDoble hogarMascobraTus3 hogarMastusDoble3 hogarMascobraTus6 hogarMastusDoble6 hogarMascobraTus9 hogarMastusDoble9 hogarMascobraTus12 hogarMastusDoble12 hogarMascobraTus18 hogarMastusDoble18 hogarMascobraTus24 hogarMastusDoble24
global varsPersonas edad_visita sexo parentesco situacionlaboral nivelmasaltoalcanzado


* Load dataset a nivel de personas con datos de BPS-SIIAS
import delimited ..\Input\MIDES\visitas_personas_educ_siias.csv, clear case(preserve)

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

* Relativas a educación
foreach num in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 {
	gen masEstudiaCEIPCES`num' = .
	replace masEstudiaCEIPCES`num' = 0 if (masenCEIP`num'==0 | masenCES`num'==0)
	replace masEstudiaCEIPCES`num' = 1 if (masenCEIP`num'==1 | masenCES`num'==1)
}
gen zeroEstudiaCEIPCES = .
replace zeroEstudiaCEIPCES = 0 if (zeroenCEIP==0 | zeroenCES==0)
replace zeroEstudiaCEIPCES = 1 if (zeroenCEIP==1 | zeroenCES==1)


* RDD
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1, c(0) p(`i') fuzzy(hogarMascobraTus12) vce(hc0) covs(${AC`var'})							
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==1, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
rdrobust masocupadoSIIAS24 iccMenosThreshold1 if edad_visita>18 & zeroocupadoSIIAS==1 & departamento==1 & hogarZerocobraTus==0, c(0) p(1) fuzzy(hogarMascobraTus12) vce(hc0)
binscatter masocupadoSIIAS24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita>=18 & zeroocupadoSIIAS==1 & departamento==1, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)

* Binscatters
binscatter masEstudiaCEIPCES24 iccMenosThreshold1 if abs(iccMenosThreshold1)<0.2 & edad_visita<=15 & edad_visita>=11 & zeroEstudiaCEIPCES==0, rd(0) linetype(qfit) xtitle(ICC - Prim TUS thres)


