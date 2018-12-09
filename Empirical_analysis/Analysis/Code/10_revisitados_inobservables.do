* Objective: Mirar impactos ganar/perder en revisitas para grupos 
*               con mismos inobservables

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros
global ctrlsRDRobust departamentoOne1 departamentoTwo1 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7 yearOne8 yearTwo3 yearTwo4 yearTwo5 yearTwo6 yearTwo7 yearTwo8 yearThree1 yearThree2 yearThree3

* Load dataset
import delimited vars_personas_revisitadas.csv, clear case(preserve)

* Defino muestra de winners and losers en primera visita (entre los que inicialmente UCT=0)
gen winnerOne015 = 0
replace winnerOne015 = 1 if iccNormPrimerTusOne>=0 & iccNormPrimerTusOne<0.15 & hogarZerocobraTusOne==0

gen loserOne015 = 0
replace loserOne015 = 1 if iccNormPrimerTusOne<0 & iccNormPrimerTusOne>-0.15 & hogarZerocobraTusOne==0

gen loserOrWinnerOne015 = winnerOne015 + loserOne015

*** Regresions con rdrobust package

** Vistas pedidas

* Sin controls
rdrobust DpedidoRevisitedTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
rdrobust DpedidoRevisitedTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
mean DpedidoRevisitedTwo if hogarMascobraTus12Two==1 & loserOne015==1 & abs(iccNormPrimerTusTwo)<0.064
mean DpedidoRevisitedTwo if hogarMascobraTus12Two==1 & winnerOne015==1 & abs(iccNormPrimerTusTwo)<0.107

* Con controls
rdrobust DpedidoRevisitedTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0) covs($ctrlsRDRobust)
rdrobust DpedidoRevisitedTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0) covs($ctrlsRDRobust)

** Revisitado por motus del gobierno
* Sin controls
rdrobust revisitedPorGovTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
rdrobust revisitedPorGovTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
mean revisitedPorGovTwo if hogarMascobraTus12Two==1 & loserOne015==1 & abs(iccNormPrimerTusTwo)<0.140
mean revisitedPorGovTwo if hogarMascobraTus12Two==1 & winnerOne015==1 & abs(iccNormPrimerTusTwo)<0.139

* Con controls
rdrobust revisitedPorGovTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0) covs($ctrlsRDRobust)
rdrobust revisitedPorGovTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0) covs($ctrlsRDRobust)

** Alimentacion

* Sin controls
rdrobust adultonocomioTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
rdrobust adultonocomioTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
mean adultonocomioTwo if hogarMascobraTus12Two==1 & loserOne015==1 & abs(iccNormPrimerTusTwo)<0.169
mean adultonocomioTwo if hogarMascobraTus12Two==1 & winnerOne015==1 & abs(iccNormPrimerTusTwo)<0.111

rdrobust menornocomioTwo iccNormPrimerTusTwo if loserOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
rdrobust menornocomioTwo iccNormPrimerTusTwo if winnerOne015==1, c(0) p(2) fuzzy(hogarMascobraTus12Two) vce(hc0)
mean menornocomioTwo if hogarMascobraTus12Two==1 & loserOne015==1 & abs(iccNormPrimerTusTwo)<0.167
mean menornocomioTwo if hogarMascobraTus12Two==1 & winnerOne015==1 & abs(iccNormPrimerTusTwo)<0.118

* Con controls

** Con ivregress
ivregress 2sls iccNormPrimerTusOne iccNormInteractedPrimerTusOne
