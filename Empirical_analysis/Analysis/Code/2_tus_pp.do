* Objective: Mirar second stage de impacto TUS en PP.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load dataset a nivel de personas
import delimited ..\Input\visitas_personas_otras_vars.csv, clear
merge m:1 using 

*** Generate variables
generate iccSuperaPrimerTUS=0
replace iccSuperaPrimerTUS=1 if icc >= umbral_nuevo_tus

generate iccSuperaSegundoTUS=0
replace iccSuperaSegundoTUS=1 if icc >= umbral_nuevo_tus

*** Regresions: instrument on outcomes

*** Regressions: IV on outcomes

*** RD plots

* 2013 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 70)
binscatter icc pp2013 if habilitado_2013==1 & hogarZerocobraTus==0 & (periodo>=58 & periodo<=64) & umbral_nuevo_tus==0.62260002, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2013)

* 2016 election for those in Montevideo visited 6 months - 12 months before the election and that weren't receiving a TUS before the visit (election fue en period = 106)
binscatter icc pp2016 if habilitado_2016==1 & hogarZerocobraTus==0 & (periodo>=94 & periodo<=100) & umbral_nuevo_tus==0.62260002, rd(0.62260002) linetype(qfit) xtitle(ICC) ytitle(Perc. voting in 2016)


* 2013 election for those visited 6 months - 12 months before the election and that were receiving 1 TUS before the visit
