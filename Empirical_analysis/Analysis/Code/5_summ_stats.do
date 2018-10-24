* Objective: Armar basic summary statstics.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load dataset a nivel de personas
import delimited ..\Input\MIDES\visitas_hogares_otras_vars.csv, clear

** Variable de si hogar ganó o perdió TUS en período x
forvalues per = 49/120 {
	local per2 = `per' - 1
	capture confirm variable hogarcobratus`per' hogarcobratus`per2'
	if !_rc {
		generate hogPerdio`per' = 0
		generate hogGano`per' = 0
		replace hogPerdio`per' = 1 if hogarcobratus`per' == 0 & hogarcobratus`per2' == 1
		replace hogGano`per' = 1 if hogarcobratus`per' == 1 & hogarcobratus`per2' == 0
	}
	}

* Media de hogares que pierde transferencia
forvalues per = 49/120 {
capture confirm variable hogPerdio`per'
	if !_rc {
	mean hogPerdio`per'
	display `per'
}
}

* Media de hogares que gana transferencia
forvalues per = 49/120 {
capture mean hogGano`per'
}

* Running variables
generate iccNormPrimerTus = icc - umbral_nuevo_tus
generate iccNormAFAM = icc - umbral_afam
generate iccNormSegundoTus = icc - umbral_nuevo_tus_dup

* McCrary test
* Mdeo
DCdensity iccNormPrimerTus if departamento==1, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccraryMdeo.png, replace
cap drop Xj Yj r0 fhat se_fhat

DCdensity iccNormSegundoTus if departamento==1, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccrarySecMdeo.png, replace
cap drop Xj Yj r0 fhat se_fhat

* Interior
DCdensity iccNormPrimerTus if departamento!=1, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccraryInt.png, replace
cap drop Xj Yj r0 fhat se_fhat

DCdensity iccNormSegundoTus if departamento!=1, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccrarySecInt.png, replace
cap drop Xj Yj r0 fhat se_fhat

* Total
DCdensity iccNormAFAM, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccraryAFAMTot.png, replace
cap drop Xj Yj r0 fhat se_fhat

DCdensity iccNormPrimerTus, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccraryPrimTot.png, replace
cap drop Xj Yj r0 fhat se_fhat

DCdensity iccNormSegundoTus, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export ..\Output\mccrarySecTot.png, replace
cap drop Xj Yj r0 fhat se_fhat

