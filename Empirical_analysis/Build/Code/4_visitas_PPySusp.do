* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos PP y suspendidos educativos
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

* Macros
global varsKeep flowcorrelativeid fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template

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
keep flowcorrelativeid nrodocumento fechanacimiento $varsKeep

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

* Creo variable con edad del individuo al momento de cada elección
generate yearNacimiento = substr(fechaNacString, 1, 4)
generate monthNacimiento = substr(fechaNacString, 5, 2)
generate dayNacimiento = substr(fechaNacString, 7, 2)
destring yearNacimiento, replace
destring monthNacimiento, replace
destring dayNacimiento, replace

gen edadPP2008 = .
replace edadPP2008 = 0 if fechaNacNumeric<=17831 & fechaNacNumeric>17465 // (17465 es el 26 de oct de 2007)
replace edadPP2008 = 2008 - yearNacimiento if monthNacimiento<10 & fechaNacNumeric<=17465
replace edadPP2008 = 2008 - yearNacimiento - 1 if monthNacimiento>10 & fechaNacNumeric<=17465
replace edadPP2008 = 2008 - yearNacimiento - 1 if monthNacimiento==10 & dayNacimiento>26 & fechaNacNumeric<=17465
replace edadPP2008 = 2008 - yearNacimiento if monthNacimiento==10 & dayNacimiento<=26 & fechaNacNumeric<=17465

gen edadPP2011 = .
replace edadPP2011 = 0 if fechaNacNumeric<=18930 & fechaNacNumeric>18565 // (18565 es el 30 de oct de 2010)
replace edadPP2011 = 2011 - yearNacimiento if monthNacimiento<10 & fechaNacNumeric<=18565
replace edadPP2011 = 2011 - yearNacimiento - 1 if monthNacimiento>10 & fechaNacNumeric<=18565
replace edadPP2011 = 2011 - yearNacimiento - 1 if monthNacimiento==10 & dayNacimiento>30 & fechaNacNumeric<=18565
replace edadPP2011 = 2011 - yearNacimiento if monthNacimiento==10 & dayNacimiento<=30 & fechaNacNumeric<=18565

gen edadPP2013 = .
replace edadPP2013 = 0 if fechaNacNumeric<=19658 & fechaNacNumeric>19293 // (19293 es el 27 de oct de 2012)
replace edadPP2013 = 2013 - yearNacimiento if monthNacimiento<10 & fechaNacNumeric<=19293
replace edadPP2013 = 2013 - yearNacimiento - 1 if monthNacimiento>10 & fechaNacNumeric<=19293
replace edadPP2013 = 2013 - yearNacimiento - 1 if monthNacimiento==10 & dayNacimiento>27 & fechaNacNumeric<=19293
replace edadPP2013 = 2013 - yearNacimiento if monthNacimiento==10 & dayNacimiento<=27 & fechaNacNumeric<=19293

gen edadPP2016 = .
replace edadPP2016 = 0 if fechaNacNumeric<=20757 & fechaNacNumeric>20391 // (20391 es el 30 de oct de 2015)
replace edadPP2016 = 2016 - yearNacimiento if monthNacimiento<10 & fechaNacNumeric<=20391
replace edadPP2016 = 2016 - yearNacimiento - 1 if monthNacimiento>10 & fechaNacNumeric<=20391
replace edadPP2016 = 2016 - yearNacimiento - 1 if monthNacimiento==10 & dayNacimiento>30 & fechaNacNumeric<=20391
replace edadPP2016 = 2016 - yearNacimiento if monthNacimiento==10 & dayNacimiento<=30 & fechaNacNumeric<=20391

drop fechanacimiento fechaNacString fechaNacNumeric

*** Creo variables a nivel de hogar en base personas

* Variable PP
foreach yr in 2008 2011 2013 2016 {
	egen hogar_votantes`yr' = total(pp`yr'), by(flowcorrelativeid)
	egen hogar_habilitados`yr' = total(habilitado`yr'), by(flowcorrelativeid)
	gen hogar_voto_sobre_habil`yr' = .
	replace hogar_voto_sobre_habil`yr' = hogar_votantes`yr'/hogar_habilitados`yr' if hogar_habilitados`yr'!=.
	gen hogar_voto`yr'=0
	replace hogar_voto`yr' = 1 if hogar_votantes`yr'>0 & hogar_votantes`yr'!=.
}

* Variables suspendidos educativos
foreach yr in 2013 2014 2015 2016 2017 2018 {
	egen hogarSusp`yr' = total(susp`yr'), by(flowcorrelativeid)
}

* Guardo base personas en csv y dta para exportar y para merge
export delimited using ..\Output\visitas_personas_PPySusp.csv, replace
save ..\Output\visitas_personas_PPySusp.dta, replace

* Guardo base personas para merge con base hogares
collapse (mean) hogar*, by (flowcorrelativeid)
save personas_pp_susp_merge.dta, replace

*** Armo base hogares
import delimited ..\Output\visitas_hogares_vars.csv, clear
keep $varsKeep

merge 1:1 flowcorrelativeid using personas_pp_susp_merge, keep (master matched)
drop _merge

* Guardo base hogares en csv y dta para exportar y para merge
export delimited using ..\Output\visitas_hogares_PPySusp.csv, replace
save ..\Output\visitas_hogares_PPySusp.dta, replace
