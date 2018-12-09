* Objective: Mirar second stage de impacto TUS en suspendidos educativos.

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Load data of suspendidso partly processed in Python
import delimited dfSusp2.csv, clear

* 
rdrobust susppost2014 iccmenosthreshold1 if (year==2012 | year==2013) & edad_visita<21, c(0) fuzzy(hogarcobratus70) covs(edad_visita periodo)
