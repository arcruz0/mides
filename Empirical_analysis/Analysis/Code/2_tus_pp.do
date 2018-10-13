* Objective: Mirar second stage de impacto TUS en PP.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load dataset a nivel de personas
import delimited ..\Input\visitas_personas_otras_vars.csv, clear

*** Generate variables
generate iccSuperaPrimerTUS=0
replace iccSuperaPrimerTUS=1 if icc >= umbral_nuevo_tus

generate iccSuperaSegundoTUS=0
replace iccSuperaSegundoTUS=1 if icc >= umbral_nuevo_tus

generate vote2013_2016=.
replace vote2013_2016=pp2013 if year==2013
replace vote2013_2016=pp2016 if year==2016

generate habilitado2013_2016=.
replace habilitado2013_2016=habilitado2013 if year==2013
replace habilitado2013_2016=habilitado2016 if year==2016

generate iccNormPrimerTus = icc - umbral_nuevo_tus
generate iccNormInteractedPrimerTus= iccNormPrimerTus * iccSuperaPrimerTUS
generate iccPrimerTUSHogZerCobTus = iccSuperaPrimerTUS * hogarzerocobratus

*** Regresions: instrument on outcomes
regress vote2013_2016 iccSuperaPrimerTUS icc i.year if habilitado2013_2016==1 & ((periodo>=58 & periodo<=64) | (periodo>=94 & periodo<=100)) & umbral_nuevo_tus<0.65 & (icc>0.4 & icc<0.8)
regress pp2016 iccSuperaPrimerTUS iccPrimerTUSHogZerCobTus iccNormPrimerTus iccNormInteractedPrimerTus hogarzerocobratus pp2013 pp2011 pp2008 if habilitado2016==1 & (periodo>=90 & periodo<=104) & umbral_nuevo_tus<0.65

*** Regressions: IV on outcomes

* Impact on those initially receiving 1 TUS
ivregress 2sls pp2016 iccNormPrimerTus iccNormInteractedPrimerTus pp2013 pp2011 pp2008 (hogarmascobratus6 = iccSuperaPrimerTUS) if habilitado2016==1 & hogarzerocobratus ==1 & (periodo>=90 & periodo<=104) & umbral_nuevo_tus<0.65
ivregress 2sls pp2016 iccNormPrimerTus iccNormInteractedPrimerTus pp2013 pp2011 pp2008 (hogarmascobratus6 = iccSuperaPrimerTUS) if habilitado2016==1 & hogarzerocobratus ==1 & (periodo>=90 & periodo<=104) & umbral_nuevo_tus<0.65 & (icc>0.4 & icc<0.8)

*** RD plots

* 2013 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 70)
binscatter pp2013 icc if habilitado2013==1 & (periodo>=58 & periodo<=65) & umbral_nuevo_tus<0.65, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2013)

* 2016 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 106)
binscatter pp2016 icc if habilitado2016==1 & hogarzerocobratus==1 & (periodo>=94 & periodo<=100) & umbral_nuevo_tus<0.65, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2016)

* Junto 2013 y 2016 elections

* 2013 election for those visited 6 months - 12 months before the election and that were receiving 1 TUS before the visit
