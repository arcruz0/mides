* Objective: Merge variables AFAM, TUS, PP y suspendidos educativos en una misma base.
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

* Base hogares
import delimited ..\Output\visitas_hogares_TUS.csv, clear

merge 1:1 flowcorrelativeid using ..\Temp\visitas_hogares_PPySusp.dta, keepusing(hogar*)
drop _merge
export delimited using ..\Output\visitas_hogares_otras_vars.csv, replace

* Base personas
import delimited ..\Output\visitas_personas_TUS.csv, clear

merge 1:1 flowcorrelativeid nrodocumento using ..\Temp\visitas_personas_PPySusp.dta, keepusing(hogar* habilitado* susp* pp*)
drop _merge
export delimited using ..\Output\visitas_personas_otras_vars.csv, replace
