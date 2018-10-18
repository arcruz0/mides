* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos PP y suspendidos educativos
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

*** Preparo archivo PP para merge
import delimited ..\Input\PP_Muestra_enmascarado.csv, clear
save pp_para_merge.dta, replace

*** Preparo archivo Suspendidos educativos para merge
import delimited ..\Input\Suspendidos_Muestra_enmascarado.csv, clear
foreach yr in 2013 2014 2015 2016 2017 2018 {
	gen susp`yr' = 1 if year == `yr'
}
collapse (mean) susp*, by(nrodocumento)
save suspendidos_para_merge.dta, replace

*** Merge datos PP y Suspendidos con base personas
import delimited ..\Output\visitas_personas_vars.csv, clear
keep flowcorrelativeid nrodocumento fechanacimiento fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam edad_visita asiste

merge m:1 nrodocumento using pp_para_merge, keep (master matched)
drop _merge
foreach yr in 2008 2011 2013 2016 {
	replace pp`yr' = 0 if pp`yr' == .
}

merge m:1 nrodocumento using suspendidos_para_merge, keep (master matched)
drop _merge
foreach yr in 2013 2014 2015 2016 2017 2018 {
	replace susp`yr' = 0 if susp`yr' == .
}

* Creo variable de si individuo habilitado a votar en elección de 2008, 2011, 2013 y 2016
* Votaciiones fueron en: 
* 26 de octubre 2008 (https://www.180.com.uy/articulo/312_Domingo-de-elecciones-en-Montevideo)
* 30 de octubre 2011 (https://www.montevideo.com.uy/Noticias/Intendencia-lanza-Presupuesto-Participativo-para-2011-uc135048)
* 27 de octubre 2013 (http://www.espectador.com/sociedad/276384/presupuesto-participativo-2013-los-vecinos-y-las-vecinas-deciden-la-prioridad-de-la-inversion)
* 30 de octubre 2016 (https://www.elpais.com.uy/informacion/domingo-vota-presupuesto-participativo.html)
tostring fechanacimiento, generate(fechaNacString)
gen fechaNacNumeric = date(fechaNacString, "YMD")

gen habilitado2008 = 0
replace habilitado2008 = 1 if fechaNacNumeric <= 11987 // Fecha numeric de votación del 26 de Oct de 2008 es 17831, por lo que aquellos nacidos el 1992/10/26 o antes podian votar (valor numeric de esta fecha 11987)

gen habilitado2011 = 0
replace habilitado2011 = 1 if fechaNacNumeric <= 13086 // Fecha numeric de votación del 30 de Oct de 2011 es 18930, por lo que aquellos nacidos el 1995/10/30 o antes podian votar (valor numeric de esta fecha 13086)

gen habilitado2013 = 0
replace habilitado2013 = 1 if fechaNacNumeric <= 13814 // Fecha numeric de votación del 27 de Oct de 2013 es 19658, por lo que aquellos nacidos el 1997/10/27 o antes podian votar (valor numeric de esta fecha 13814)

gen habilitado2016 = 0
replace habilitado2016 = 1 if fechaNacNumeric <= 14913 // Fecha numeric de votación del 30 de Oct de 2016 es 20757, por lo que aquellos nacidos el 2000/10/30 o antes podian votar (valor numeric de esta fecha 14913)

*** Creo variables a nivel de hogar en base personas

* Variable PP
foreach yr in 2008 2011 2013 2016 {
	egen hogar_votantes`yr' = sum(pp`yr'), by(flowcorrelativeid)
	egen hogar_habilitados`yr' = sum(habilitado`yr'), by(flowcorrelativeid)
	gen hogar_voto_sobre_habil`yr' = .
	replace hogar_voto_sobre_habil`yr' = hogar_votantes`yr'/hogar_habilitados`yr' if hogar_habilitados`yr'!=.
	gen hogar_voto`yr'=0
	replace hogar_voto`yr' = 1 if hogar_votantes`yr'>0 & hogar_votantes`yr'!=.
}

* Variables suspendidos educativos
foreach yr in 2013 2014 2015 2016 2017 2018 {
	egen hogarSusp`yr' = sum(susp`yr'), by(flowcorrelativeid)
}

* Guardo base personas en csv para exportar y para merge
export delimited using ..\Output\visitas_personas_PPySusp.csv, replace
save ..\Temp\visitas_personas_PPySusp.dta, replace

* Guardo base personas para merge con base hogares
collapse (mean) hogar*, by (flowcorrelativeid)
save personas_pp_susp_merge.dta, replace

*** Armo base hogares
import delimited ..\Output\visitas_hogares_vars.csv, clear
keep flowcorrelativeid fechavisita year month periodo icc umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam

merge 1:1 flowcorrelativeid using personas_pp_susp_merge, keep (master matched)
drop _merge

* Guardo base hogares en csv para exportar y para merge
export delimited using ..\Output\visitas_hogares_PPySusp.csv, replace
save ..\Temp\visitas_hogares_PPySusp.dta, replace
