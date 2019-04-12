* Objective: Mirar second stage de impacto TUS en variables de base visitas 
*               (para hogares revistados censalmenete).

clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Analysis\Temp"

* Macros

* Cargo base de personas con variables que me interesan
use ..\Input\MIDES\visitas_personas_vars.dta, clear
keep flowcorrelativeid nrodocumento fechavisita icc periodo year month umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam departamento localidad template hogingtotalessintransferencias ingtotalessintransferencias hogingafam ingafam hogingotrosbeneficios ingotrosbeneficios hogingtarjetaalimentaria ingtarjetaalimentaria hogingjubypenasistenciavejez ingjubypenasistenciavejez embarazada situacionlaboral sexo parentesco asiste edad_visita nivelmasaltoalcanzado razonnofinalizo tomamedicacion discapacidad psiquiatrica anosEduc

* Merge con base TUS con variables que me interesa
merge m:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_TUS.dta, keep (master matched) keepusing(hogarZerocobraTus hogarZerotusDoble hogarMascobraTus* hogarMenoscobraTus* hogarMastusDoble* hogarMenostusDoble* hogarZeromonto_carga)
drop _merge

* Merge con base hogares para agregar variables de hogares que quiera
merge m:1 flowcorrelativeid using ..\Input\MIDES\visitas_hogares_vars.dta, keep (master matched) keepusing (colecho aguacorriente redelectrica residuoscuadra accesosaneamiento canasta bajopeso diabeticosrenales otro aguascontaminadas merendero sinalimentos adultonocomio menornocomio contramujer contravaron contramenor contraadultomayor indocumentados calidadocupacionvivienda tienecalefon tienerefrigerador tienetvcable tienevideo tienelavarropas tienelavavajilla tienemicroondas tienecomputador tienetelefonofijo tienetelefonocelular tieneautomovil tienecomputadorplanceibal pedido_visita cuando_pedido conexionelectricaexpuesta hogAnosEduc hogAnosEducAdults hogAnosEducAdults25 hogAnosEducMinors hogmiembros hogmiembrosMenores10 hogmiembrosMenores5 hogmiembrosMenores3 hogmiembrosMenores2 hogmiembrosMenores1 hogmiembrosMenores)
drop _merge

* Merge con base de AFAM
merge m:1 flowcorrelativeid nrodocumento using ..\Input\MIDES\visitas_personas_AFAM.dta, keep(master matched) keepusing (hogarZerocobraAFAM zerocobraAFAM hogarZeromonto_sol zeromonto_sol)
drop _merge

* Elimino personas que fueron visitadas más de 3 veces (98% de los revisitados fueron revisitados solamente 1,2, o 3 veces)
duplicates tag nrodocumento, generate(dobles)
drop if dobles>5

* Armo variable indicador si estas en período 1 o 2 o 3
sort nrodocumento periodo
foreach num in 1 2 3 4 5 6 {
	generate visita`num' = 0
}

replace visita1 = 1 if nrodocumento[_n] != nrodocumento[_n-1]
replace visita2 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] != nrodocumento[_n-2]
replace visita3 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n-1] == nrodocumento[_n-2] & nrodocumento[_n] != nrodocumento[_n-3]
replace visita4 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n-1] == nrodocumento[_n-2] & nrodocumento[_n-2] == nrodocumento[_n-3] & nrodocumento[_n] != nrodocumento[_n-4]
replace visita5 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n-1] == nrodocumento[_n-2] & nrodocumento[_n-2] == nrodocumento[_n-3] & nrodocumento[_n-3] == nrodocumento[_n-4] & nrodocumento[_n] != nrodocumento[_n-5]
replace visita6 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n-1] == nrodocumento[_n-2] & nrodocumento[_n-2] == nrodocumento[_n-3] & nrodocumento[_n-3] == nrodocumento[_n-4] & nrodocumento[_n-4] == nrodocumento[_n-5] & nrodocumento[_n] != nrodocumento[_n-6]

/*
* Elimino re-visitas que no fueron censales
drop if template == "Visita por CI" & visita3 == 1
drop if template == "Visita por CI" & visita2 == 1
duplicates tag nrodocumento, generate(doblesAgain)
drop if doblesAgain == 0

* Armo variable indicador de si estas en visita 1, 2, 3 (ya que al eliminar re-vistas no censales, numeración puede cambiar)
drop visita1 visita2 visita3

sort nrodocumento periodo
foreach num in 1 2 3 {
	generate visita`num' = 0
}

replace visita1 = 1 if nrodocumento[_n] != nrodocumento[_n-1]
replace visita2 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] != nrodocumento[_n-2]
replace visita3 = 1 if nrodocumento[_n] == nrodocumento[_n-1] & nrodocumento[_n] == nrodocumento[_n-2]
*/

* Creo variables segun primera, segunda o tercera visita
rename hogingtotalessintransferencias hogingtotsintransf
rename ingtotalessintransferencias ingtotsintransf
rename hogingjubypenasistenciavejez hogingjubypenasistvej


*gen mienteIngTarjeta = log(zeromonto_carga+1) - log(ingtarjetaalimentaria+1)
gen mienteHogIngTarjeta = log(hogarZeromonto_carga+1) - log(hogingtarjetaalimentaria+1)
gen mienteHogAFAM = log(hogarZeromonto_sol+1) - log(hogingafam+1)

ds nrodocumento umbral_nuevo_tus umbral_nuevo_tus_dup umbral_afam visita1 visita2 visita3 visita4 visita5 visita6, not

foreach var in `r(varlist)' {
	generate `var'One = `var'
	generate `var'Two = `var'
	generate `var'Three = `var'
	generate `var'Four = `var'
	generate `var'Five = `var'
	generate `var'Six = `var'
	cap replace `var'One = "" if visita1 != 1
	cap replace `var'One = . if visita1 != 1
	cap replace `var'Two = "" if visita2 != 1
	cap replace `var'Two = . if visita2 != 1
	cap replace `var'Three = "" if visita3 != 1
	cap replace `var'Three = . if visita3 != 1
	cap replace `var'Four = "" if visita4 != 1
	cap replace `var'Four = . if visita4 != 1
	cap replace `var'Five = "" if visita5 != 1
	cap replace `var'Five = . if visita5 != 1
	cap replace `var'Six = "" if visita6 != 1
	cap replace `var'Six = . if visita6 != 1
	drop `var'
}

* Colapso observaciones para que cada cédula de identidad solo tenga una fila
ds nrodocumento visita1 visita2 visita3 visita4 visita5 visita6, not
gcollapse (firstnm) `r(varlist)' (max) visita1 visita2 visita3 visita4 visita5 visita6, by(nrodocumento)

*** Generate variables

** Variables related to whether individual was revisited

* Generate a dummy for whether the individual was "censal" visited after the first visit
generate censalRevisitOne = 0
replace censalRevisitOne = 1 if ((templateTwo!="Visita por CI" & visita2==1)| (templateThree!="Visita por CI" & visita3==1) | (templateFour!="Visita por CI" & visita4==1) | (templateFive!="Visita por CI" & visita5==1) | (templateSix!="Visita por CI" & visita6==1))
generate censalPostaRevisitOne = 0
replace censalPostaRevisitOne = 1 if ((templateTwo=="Censo" & visita2==1)| (templateThree=="Censo" & visita3==1) | (templateFour=="Censo" & visita4==1) | (templateFive=="Censo" & visita5==1) | (templateSix=="Censo" & visita6==1))

* Generate a dummy for whether the individual was "censal" visited after the second visit
generate censalRevisitTwo = 0
replace censalRevisitTwo = 1 if ((templateThree!="Visita por CI" & visita3==1) | (templateFour!="Visita por CI" & visita4==1) | (templateFive!="Visita por CI" & visita5==1) | (templateSix!="Visita por CI" & visita6==1))
generate censalPostaRevisitTwo = 0
replace censalPostaRevisitTwo = 1 if ((templateThree=="Censo" & visita3==1) | (templateFour=="Censo" & visita4==1) | (templateFive=="Censo" & visita5==1) | (templateSix=="Censo" & visita6==1))

* Generate a dummy for whether the individual was visited becasue he requested it after the first visit
generate DpedidoRevisitedOne = 0
replace DpedidoRevisitedOne = 1 if ((pedido_visitaTwo==1 & visita2==1)| (pedido_visitaThree==1 & visita3==1) | (pedido_visitaFour==1 & visita4==1) | (pedido_visitaFive==1 & visita5==1) | (pedido_visitaSix==1 & visita6==1))

* Generate a dummy for whether the individual was visited becasue he requested it after the second visit
generate DpedidoRevisitedTwo = .
replace DpedidoRevisitedTwo = 0 if visita2 == 1
replace DpedidoRevisitedTwo = 1 if ((pedido_visitaThree==1 & visita3==1) | (pedido_visitaFour==1 & visita4==1) | (pedido_visitaFive==1 & visita5==1) | (pedido_visitaSix==1 & visita6==1))

* Generate a dummy for whether the individual was visited becasue the government decided so after the first visit
generate revisitedPorGovOne = 0
replace revisitedPorGovOne = 1 if ((pedido_visitaTwo==0 & visita2==1)| (pedido_visitaThree==0 & visita3==1) | (pedido_visitaFour==0 & visita4==1) | (pedido_visitaFive==0 & visita5==1) | (pedido_visitaSix==0 & visita6==1))

* Generate a dummy for whether the individual was visited becasue the government decided so after the second visit
generate revisitedPorGovTwo = .
replace revisitedPorGovTwo = 0 if visita2 == 1
replace revisitedPorGovTwo = 1 if ((pedido_visitaThree==0 & visita3==1) | (pedido_visitaFour==0 & visita4==1) | (pedido_visitaFive==0 & visita5==1) | (pedido_visitaSix==0 & visita6==1))


* Generate vars for second visit when that visit is censal visit (censal: NexC, not recorrido tipo: Next)
foreach var in year month hogarZerocobraTus hogarZerotusDoble hogingtotsintransf ingtotsintransf hogingjubypenasistvej contramujer contravaron contramenor contraadultomayor tomamedicacion discapacidad colecho aguacorriente redelectrica residuoscuadra accesosaneamiento canasta bajopeso diabeticosrenales otro aguascontaminadas merendero sinalimentos adultonocomio menornocomio indocumentados calidadocupacionvivienda tienecalefon tienerefrigerador tienetvcable tienevideo tienelavarropas tienelavavajilla tienemicroondas tienecomputador tienetelefonofijo tienetelefonocelular tieneautomovil tienecomputadorplanceibal pedido_visita conexionelectricaexpuesta hogingafam ingafam hogingotrosbeneficios ingotrosbeneficios hogingtarjetaalimentaria ingtarjetaalimentaria ingjubypenasistenciavejez embarazada situacionlaboral sexo parentesco asiste edad_visita nivelmasaltoalcanzado razonnofinalizo psiquiatrica icc departamento {
generate `var'Next = .
replace `var'Next = `var'Six if templateSix!="Visita por CI" & visita6==1
replace `var'Next = `var'Five if templateFive!="Visita por CI" & visita5==1
replace `var'Next = `var'Four if templateFour!="Visita por CI" & visita4==1
replace `var'Next = `var'Three if templateThree!="Visita por CI" & visita3==1
replace `var'Next = `var'Two if templateTwo!="Visita por CI" & visita2==1

generate `var'NexC = .
replace `var'NexC = `var'Six if templateSix=="Censo" & visita6==1
replace `var'NexC = `var'Five if templateFive=="Censo" & visita5==1
replace `var'NexC = `var'Four if templateFour=="Censo" & visita4==1
replace `var'NexC = `var'Three if templateThree=="Censo" & visita3==1
replace `var'NexC = `var'Two if templateTwo=="Censo" & visita2==1
}

foreach var in cuando_pedido template {
generate `var'Next = ""
replace `var'Next = `var'Six if templateSix!="Visita por CI" & visita6==1
replace `var'Next = `var'Five if templateFive!="Visita por CI" & visita5==1
replace `var'Next = `var'Four if templateFour!="Visita por CI" & visita4==1
replace `var'Next = `var'Three if templateThree!="Visita por CI" & visita3==1
replace `var'Next = `var'Two if templateTwo!="Visita por CI" & visita2==1

generate `var'NexC = ""
replace `var'NexC = `var'Six if templateSix=="Censo" & visita6==1
replace `var'NexC = `var'Five if templateFive=="Censo" & visita5==1
replace `var'NexC = `var'Four if templateFour=="Censo" & visita4==1
replace `var'NexC = `var'Three if templateThree=="Censo" & visita3==1
replace `var'NexC = `var'Two if templateTwo=="Censo" & visita2==1
}


* Generate outcome or control variables
foreach tb in One Two Three Next NexC {

* Demographic
gen hombre`tb' =.
replace hombre`tb' = 1 if sexo`tb' == 1
replace hombre`tb' = 0 if sexo`tb' == 2

gen jefe`tb'=0
replace jefe`tb' = 1 if parentesco`tb' == 1

gen spouse`tb'=0
replace spouse`tb' = 1 if parentesco`tb' == 2

gen companero`tb'=0
replace companero`tb' = 1 if parentesco`tb' == 3

gen hijoAmbos`tb'=0
replace hijoAmbos`tb' = 1 if parentesco`tb' == 4

gen hijoSoloJefe`tb'=0
replace hijoSoloJefe`tb' = 1 if parentesco`tb' == 5

gen hijoSoloSpouse`tb'=0
replace hijoSoloSpouse`tb' = 1 if parentesco`tb' == 6

gen yernoNuera`tb'=0
replace yernoNuera`tb' = 1 if parentesco`tb' == 7

gen nieto`tb'=0
replace nieto`tb' = 1 if parentesco`tb' == 8

gen padresSuegros`tb'=0
replace padresSuegros`tb' = 1 if parentesco`tb' == 9

gen otroPariente`tb'=0
replace otroPariente`tb' = 1 if parentesco`tb' == 10

gen servDomestico`tb'=0
replace servDomestico`tb' = 1 if parentesco`tb' == 11

gen noPariente`tb'=0
replace noPariente`tb' = 1 if parentesco`tb' == 12

* Schooling and employment
gen asisteEscuela`tb' = 0
replace asisteEscuela`tb' = 1 if asiste`tb' == 1

gen emp_privado`tb' =.
replace emp_privado`tb' = 1 if situacionlaboral`tb' == 1
replace emp_privado`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=1 & situacionlaboral`tb'!=0

gen emp_public`tb' =.
replace emp_public`tb' = 1 if situacionlaboral`tb' == 2
replace emp_public`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=2 & situacionlaboral`tb'!=0

gen cooperativista`tb' =.
replace cooperativista`tb' = 1 if situacionlaboral`tb' == 3
replace cooperativista`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=3 & situacionlaboral`tb'!=0

gen cuenta_propia`tb' =.
replace cuenta_propia`tb' = 1 if situacionlaboral`tb' == 4
replace cuenta_propia`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=4 & situacionlaboral`tb'!=0

gen patron`tb' =.
replace patron`tb' = 1 if situacionlaboral`tb' == 5
replace patron`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=5 & situacionlaboral`tb'!=0

gen trabNoRemuner`tb' =.
replace trabNoRemuner`tb' = 1 if situacionlaboral`tb' == 6
replace trabNoRemuner`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=6 & situacionlaboral`tb'!=0

gen desocupado`tb' =.
replace desocupado`tb' = 1 if situacionlaboral`tb' == 7
replace desocupado`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=7 & situacionlaboral`tb'!=0

gen jubilado`tb' =.
replace jubilado`tb' = 1 if situacionlaboral`tb' == 8
replace jubilado`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=8 & situacionlaboral`tb'!=0

gen pensionista`tb' =.
replace pensionista`tb' = 1 if situacionlaboral`tb' == 9
replace pensionista`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=9 & situacionlaboral`tb'!=0

gen quehaceresHog`tb' =.
replace quehaceresHog`tb' = 1 if situacionlaboral`tb' == 10
replace quehaceresHog`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=10 & situacionlaboral`tb'!=0

gen rentista`tb' =.
replace rentista`tb' = 1 if situacionlaboral`tb' == 11
replace rentista`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=11 & situacionlaboral`tb'!=0

gen otroInactivo`tb' =.
replace otroInactivo`tb' = 1 if situacionlaboral`tb' == 12
replace otroInactivo`tb' = 0 if situacionlaboral`tb' <=12 & situacionlaboral`tb'!=. & situacionlaboral`tb'!=12 & situacionlaboral`tb'!=0

* Domestic violence
generate vdMujer`tb' = .
replace vdMujer`tb' = 1 if contramujer`tb' == 1
replace vdMujer`tb' = 0 if contramujer`tb' == 2

generate vdVaron`tb' = .
replace vdVaron`tb' = 1 if contravaron`tb' == 1
replace vdVaron`tb' = 0 if contravaron`tb' == 2

generate vdMenor`tb' = .
replace vdMenor`tb' = 1 if contramenor`tb' == 1
replace vdMenor`tb' = 0 if contramenor`tb' == 2

generate vdAdultomayor`tb' = .
replace vdAdultomayor`tb' = 1 if contraadultomayor`tb' == 1
replace vdAdultomayor`tb' = 0 if contraadultomayor`tb' == 2

generate vd`tb' = vdMujer`tb' * vdVaron`tb' *  vdMenor`tb' * vdAdultomayor`tb'
replace vd`tb' = 1 if (vdMujer`tb' == 1 | vdVaron`tb' == 1 | vdMenor`tb' == 1 | vdAdultomayor`tb' == 1)

* Health
generate tomamedicacion18`tb' = .
replace tomamedicacion18`tb' = 1 if tomamedicacion`tb' == 1
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 2
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 0
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 97
replace tomamedicacion18`tb' = 0 if tomamedicacion`tb' == 99

generate discapacidadSi`tb' = .
replace discapacidadSi`tb' = 1 if discapacidad`tb' == 1
replace discapacidadSi`tb' = 0 if discapacidad`tb' == 2

generate psiquiatricaSi`tb' = .
replace psiquiatricaSi`tb' = 1 if psiquiatrica`tb' == 1
replace psiquiatricaSi`tb' = 0 if psiquiatrica`tb' == 2

gen embarazada`tb'X = .
replace embarazada`tb'X = 1 if embarazada`tb' == 1
replace embarazada`tb'X = 0 if embarazada`tb' == 2
replace embarazada`tb'X = 0 if embarazada`tb' == 0
replace embarazada`tb'X = 0 if embarazada`tb' == 99
drop embarazada`tb'
rename embarazada`tb'X embarazada`tb'

* Food and durable goods consumption (sinalimentos, adultonocomio y menornocomio no precisan re-codificarse)
gen bajopeso`tb'X = .
replace bajopeso`tb'X = 1 if bajopeso`tb' == 1
replace bajopeso`tb'X = 0 if bajopeso`tb' == 2
drop bajopeso`tb'
rename bajopeso`tb'X bajopeso`tb'

gen otro`tb'X = .
replace otro`tb'X = 1 if otro`tb' == 1
replace otro`tb'X = 0 if otro`tb' == 2
drop otro`tb'
rename otro`tb'X otro`tb'

gen diabeticosrenales`tb'X = .
replace diabeticosrenales`tb'X = 1 if diabeticosrenales`tb' == 1
replace diabeticosrenales`tb'X = 0 if diabeticosrenales`tb' == 2
drop diabeticosrenales`tb'
rename diabeticosrenales`tb'X diabeticosrenales`tb'

gen merendero`tb'X = .
replace merendero`tb'X = 1 if merendero`tb' == 1
replace merendero`tb'X = 0 if merendero`tb' == 2
drop merendero`tb'
rename merendero`tb'X merendero`tb'

gen canasta`tb'X = .
replace canasta`tb'X = 1 if canasta`tb' == 1
replace canasta`tb'X = 0 if canasta`tb' == 2
replace canasta`tb'X = 0 if canasta`tb' == 0
replace canasta`tb'X = 0 if canasta`tb' == 88
drop canasta`tb'
rename canasta`tb'X canasta`tb'

generate tienecalefonSi`tb' = .
replace tienecalefonSi`tb' = 1 if tienecalefon`tb' == 1
replace tienecalefonSi`tb' = 0 if tienecalefon`tb' == 2

generate tienerefrigeradorSi`tb' = .
replace tienerefrigeradorSi`tb' = 1 if tienerefrigerador`tb' == 1
replace tienerefrigeradorSi`tb' = 0 if tienerefrigerador`tb' == 2

generate tienetvcableSi`tb' = .
replace tienetvcableSi`tb' = 1 if tienetvcable`tb' == 1
replace tienetvcableSi`tb' = 0 if tienetvcable`tb' == 2

generate tienevideoSi`tb' = .
replace tienevideoSi`tb' = 1 if tienevideo`tb' == 1
replace tienevideoSi`tb' = 0 if tienevideo`tb' == 2

generate tienelavarropasSi`tb' = .
replace tienelavarropasSi`tb' = 1 if tienelavarropas`tb' == 1
replace tienelavarropasSi`tb' = 0 if tienelavarropas`tb' == 2

generate tienelavavajillaSi`tb' = .
replace tienelavavajillaSi`tb' = 1 if tienelavavajilla`tb' == 1
replace tienelavavajillaSi`tb' = 0 if tienelavavajilla`tb' == 2

generate tienemicroondasSi`tb' = .
replace tienemicroondasSi`tb' = 1 if tienemicroondas`tb' == 1
replace tienemicroondasSi`tb' = 0 if tienemicroondas`tb' == 2

generate tienecomputadorSi`tb' = .
replace tienecomputadorSi`tb' = 1 if tienecomputador`tb' == 1
replace tienecomputadorSi`tb' = 0 if tienecomputador`tb' == 2

generate tienetelefonofijoSi`tb' = .
replace tienetelefonofijoSi`tb' = 1 if tienetelefonofijo`tb' == 1
replace tienetelefonofijoSi`tb' = 0 if tienetelefonofijo`tb' == 2

generate tienetelefonocelularSi`tb' = .
replace tienetelefonocelularSi`tb' = 1 if tienetelefonocelular`tb' == 1
replace tienetelefonocelularSi`tb' = 0 if tienetelefonocelular`tb' == 2

generate tieneautomovilSi`tb' = .
replace tieneautomovilSi`tb' = 1 if tieneautomovil`tb' == 1
replace tieneautomovilSi`tb' = 0 if tieneautomovil`tb' == 2

generate computadorplanceibalSi`tb' = .
replace computadorplanceibalSi`tb' = 1 if tienecomputadorplanceibal`tb' == 1
replace computadorplanceibalSi`tb' = 0 if tienecomputadorplanceibal`tb' == 2

* Regularization and pro-social behavior
gen uteRegularizado`tb' = .
replace uteRegularizado`tb' = 1 if redelectrica`tb' == 1
replace uteRegularizado`tb' = 0 if (redelectrica`tb' == 2 | redelectrica`tb' == 3)

gen oseRegularizado`tb' = .
replace oseRegularizado`tb' = 1 if aguacorriente`tb' == 1
replace oseRegularizado`tb' = 0 if (aguacorriente`tb' == 2 | aguacorriente`tb' == 3)

gen Dindocumentados`tb' = .
replace Dindocumentados`tb' = 1 if indocumentados`tb' >= 1 & indocumentados`tb'!=.
replace Dindocumentados`tb' = 0 if indocumentados`tb' == 0

generate conexelectrexpuestaSi`tb' = .
replace conexelectrexpuestaSi`tb' = 1 if conexionelectricaexpuesta`tb' == 1
replace conexelectrexpuestaSi`tb' = 0 if conexionelectricaexpuesta`tb' == 2

gen residuoscuadraSi`tb' = .
replace residuoscuadraSi`tb' = 1 if residuoscuadra`tb' == 1
replace residuoscuadraSi`tb' = 0 if residuoscuadra`tb' == 2

gen aguascontaminadasSi`tb' = .
replace aguascontaminadasSi`tb' = 1 if aguascontaminadas`tb' == 1
replace aguascontaminadasSi`tb' = 0 if aguascontaminadas`tb' == 2

gen accesosaneamientoSi`tb' = .
replace accesosaneamientoSi`tb' = 1 if accesosaneamiento`tb' == 1
replace accesosaneamientoSi`tb' = 0 if accesosaneamiento`tb' == 2

* Housing
generate colechoSi`tb' = .
replace colechoSi`tb' = 1 if colecho`tb' == 1
replace colechoSi`tb' = 0 if colecho`tb' == 2
replace colechoSi`tb' = 0 if colecho`tb' == 0
replace colechoSi`tb' = 0 if colecho`tb' == 97
replace colechoSi`tb' = 0 if colecho`tb' == 99
}

** Generate control variables

* 1ra visita, 2da, tercera visita, NexC, Next
foreach per in One Two Three Next NexC {
generate iccNormPrimerTus`per' = icc`per' - umbral_nuevo_tus
generate iccNormSegundoTus`per' = icc`per' - umbral_nuevo_tus_dup

generate iccSuperaPrimerTUS`per'=0
replace iccSuperaPrimerTUS`per'=1 if icc`per' >= umbral_nuevo_tus

generate iccSuperaSegundoTUS`per'=0
replace iccSuperaSegundoTUS`per'=1 if icc`per' >= umbral_nuevo_tus_dup

generate iccNormInterPrimerTus`per'= iccNormPrimerTus`per' * iccSuperaPrimerTUS`per'
generate iccNormInterSegundoTus`per'= iccNormSegundoTus`per' * iccSuperaSegundoTUS`per'

generate iccNormPrimerTus2`per' = iccNormPrimerTus`per' * iccNormPrimerTus`per'
generate iccNormSegundoTus2`per' = iccNormSegundoTus`per' * iccNormSegundoTus`per'
generate iccNorm2InterPrimerTus`per' = iccNormPrimerTus2`per' * iccSuperaPrimerTUS`per'
generate iccNorm2InterSegundoTus`per' = iccNormSegundoTus2`per' * iccSuperaSegundoTUS`per'

generate mitadBajaICC`per' = .
replace mitadBajaICC`per' = 1 if icc`per' < umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2
replace mitadBajaICC`per' = 0 if icc`per' >= umbral_nuevo_tus + (umbral_nuevo_tus_dup - umbral_nuevo_tus)/2


* Control variables not normalized
gen iccLessPrimTUS`per' = 0
replace iccLessPrimTUS`per' = icc`per' if icc`per' <= umbral_nuevo_tus

gen iccMoreSecTUS`per' = 0
replace iccMoreSecTUS`per' = icc`per' if icc`per' >= umbral_nuevo_tus_dup

gen iccMiddTUS`per' = 0
replace iccMiddTUS`per' = icc`per' if icc`per' < umbral_nuevo_tus_dup & icc`per' > umbral_nuevo_tus

gen iccLessPrimTUS2`per' = iccLessPrimTUS`per' * iccLessPrimTUS`per'
gen iccMoreSecTUS2`per' = iccMoreSecTUS`per' * iccMoreSecTUS`per'
gen iccMiddTUS2`per' = iccMiddTUS`per' * iccMiddTUS`per'

* Regarding location, year, etc
tabulate year`per', generate(year`per')
tabulate departamento`per', generate(departamento`per')
}

* Variable to define bins
gen iccPrimTusOne0025 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 {
	replace iccPrimTusOne0025 = `bin'+11 if iccNormPrimerTusOne >= 0.025*(`bin'-1) & iccNormPrimerTusOne<0.025*`bin'
	replace iccPrimTusOne0025 = `bin' if iccNormPrimerTusOne < -0.025*(`bin'-1) & iccNormPrimerTusOne>=-0.025*`bin'
}

gen iccPrimTusOne005 = . 
foreach bin in 1 2 3 4 5 {
	replace iccPrimTusOne005 = `bin'+5 if iccNormPrimerTusOne >= 0.05*(`bin'-1) & iccNormPrimerTusOne<0.05*`bin'
	replace iccPrimTusOne005 = `bin' if iccNormPrimerTusOne < -0.05*(`bin'-1) & iccNormPrimerTusOne>=-0.05*`bin'
}

gen iccPrimTusOne002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 {
	replace iccPrimTusOne002 = `bin'+14 if iccNormPrimerTusOne >= 0.02*(`bin'-1) & iccNormPrimerTusOne<0.02*`bin'
	replace iccPrimTusOne002 = `bin' if iccNormPrimerTusOne < -0.02*(`bin'-1) & iccNormPrimerTusOne>=-0.02*`bin'
}

gen iccSegTusOne002 = . 
foreach bin in 1 2 3 4 5 6 7 8 9 {
	replace iccSegTusOne002 = `bin'+9 if iccNormSegundoTusOne >= 0.02*(`bin'-1) & iccNormSegundoTusOne<0.02*`bin'
	replace iccSegTusOne002 = `bin' if iccNormSegundoTusOne < -0.02*(`bin'-1) & iccNormSegundoTusOne>=-0.02*`bin'
}

gen iccSegTusOne0025 = . 
foreach bin in 1 2 3 4 5 6 7 {
	replace iccSegTusOne0025 = `bin'+7 if iccNormSegundoTusOne >= 0.025*(`bin'-1) & iccNormSegundoTusOne<0.025*`bin'
	replace iccSegTusOne0025 = `bin' if iccNormSegundoTusOne < -0.025*(`bin'-1) & iccNormSegundoTusOne>=-0.025*`bin'
}

gen iccSegTusOne005 = . 
foreach bin in 1 2 3 4 {
	replace iccSegTusOne005 = `bin'+4 if iccNormSegundoTusOne >= 0.05*(`bin'-1) & iccNormSegundoTusOne<0.05*`bin'
	replace iccSegTusOne005 = `bin' if iccNormSegundoTusOne < -0.05*(`bin'-1) & iccNormSegundoTusOne>=-0.05*`bin'
}

gen iccPrimTusOne003 = . 
foreach bin in 1 2 3 4 5 {
	replace iccPrimTusOne003 = `bin'+5 if iccNormPrimerTusOne >= 0.03*(`bin'-1) & iccNormPrimerTusOne<0.03*`bin'
	replace iccPrimTusOne003 = `bin' if iccNormPrimerTusOne < -0.03*(`bin'-1) & iccNormPrimerTusOne>=-0.03*`bin'
}

gen iccSegTusOne0017 = . 
foreach bin in 1 2 3 {
	replace iccSegTusOne0017 = `bin'+3 if iccNormSegundoTusOne >= 0.017*(`bin'-1) & iccNormSegundoTusOne<0.017*`bin'
	replace iccSegTusOne0017 = `bin' if iccNormSegundoTusOne < -0.017*(`bin'-1) & iccNormSegundoTusOne>=-0.017*`bin'
}

gen iccPrimTusOne0017 = . 
foreach bin in 1 2 3 {
	replace iccPrimTusOne0017 = `bin'+3 if iccNormPrimerTusOne >= 0.017*(`bin'-1) & iccNormPrimerTusOne<0.017*`bin'
	replace iccPrimTusOne0017 = `bin' if iccNormPrimerTusOne < -0.017*(`bin'-1) & iccNormPrimerTusOne>=-0.017*`bin'
}


*** Export base para usar en Python
export delimited using vars_personas_revisitadas.csv, replace

*** Binscatters por persona
local bandwith = "0017"

** Educación
* All the sample (around 1st TUS)
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_TUS.png, replace

* All the sample (around 2nd TUS)
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_TUS.png, replace


* Not receiving TUS initially
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18 & hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter asisteEscuelaTwo iccNormPrimerTusOne if edad_visitaTwo<18 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter asisteEscuelaTwo iccNormSegundoTusOne if edad_visitaTwo<18 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Asiste segunda visita)
graph export ..\Output\asisteEscuelaTwo_seg_2TUS.png, replace

** Embarazada
* Not receiving TUS initially
binscatter embarazadaTwo iccNormPrimerTusOne if hombreOne==0 & hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter embarazadaTwo iccNormPrimerTusOne if hombreOne==0 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter embarazadaTwo iccNormSegundoTusOne if hombreOne==0 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter embarazadaTwo iccNormSegundoTusOne if hombreOne==0 & hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Embarazada segunda visita)
graph export ..\Output\embarazadaTwo_seg_2TUS.png, replace

** Discapacidad
* Not receiving TUS initially
binscatter discapacidadSiTwo iccNormPrimerTusOne if hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter discapacidadSiTwo iccNormPrimerTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter discapacidadSiTwo iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter discapacidadSiTwo iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Discapacidad segunda visita)
graph export ..\Output\discapacidadSiTwo_seg_2TUS.png, replace

** Pisquiatrica
* Not receiving TUS initially
binscatter psiquiatricaSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter psiquiatricaSiTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter psiquiatricaSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter psiquiatricaSiTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Pisquiatrica segunda visita)
graph export ..\Output\psiquiatricaSiTwo_seg_2TUS.png, replace

** Toma medicación para menores de 18 años
* Not receiving TUS initially
binscatter tomamedicacion18Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter tomamedicacion18Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter tomamedicacion18Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter tomamedicacion18Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(Toma medicación segunda visita)
graph export ..\Output\tomamedicacion18Two_seg_2TUS.png, replace


*** Binscatters por hogar

** First stage
* Not receiving TUS initially
binscatter hogarzerocobratusTwo iccNormPrimerTusOne if hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(hogarzerocobratus segunda visita)
graph export ..\Output\hogarzerocobratusTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter hogarzerocobratusTwo iccNormPrimerTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(hogarzerocobratus segunda visita)
graph export ..\Output\hogarzerocobratusTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter hogarzerotusdobleTwo iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(hogarzerotusdoble segunda visita)
graph export ..\Output\hogarzerotusdobleTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter hogarzerotusdobleTwo iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(hogarzerotusdoble segunda visita)
graph export ..\Output\hogarzerotusdobleTwo_seg_2TUS.png, replace


** Alimentacion
foreach var in sinalimentos adultonocomio menornocomio merendero canasta {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace
	
	* Receiving 1 TUS initially and in the threshold of losing it Para Mdeo
	binscatter `var'Two iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 1 & umbral_nuevo_tus<0.7, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUSMdeo.png, replace
	
}

* UTE, OSE regularizado
foreach var in uteRegularizado oseRegularizado {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarZerocobraTusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarZerocobraTusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace

}

* Violencia doméstica
foreach var in vd vdMujer vdMenor vdAdultomayor vdVaron {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace

}

* Indocumentados

* Not receiving TUS initially
binscatter indocumentadosTwo iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_prim_0TUS.png, replace

* Receiving 1 TUS initially and in the threshold of losing it
binscatter indocumentadosTwo iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_prim_1TUS.png, replace

* Receiving 1 TUS initially and in the threshold of doubling it
binscatter indocumentadosTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_seg_1TUS.png, replace

* Receiving 2 TUS initially and in the threshold of losing it
binscatter indocumentadosTwo iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(indocumentados segunda visita)
graph export ..\Output\indocumentadosTwo_seg_2TUS.png, replace

* Miente con tarjeta
foreach var in mienteIngTarjeta mienteHogIngTarjeta {
	* Not receiving TUS initially
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_0TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormPrimerTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccPrimTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - First TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_prim_1TUS.png, replace

	* Receiving 1 TUS initially and in the threshold of doubling it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_1TUS.png, replace

	* Receiving 2 TUS initially and in the threshold of losing it
	binscatter `var'Two iccNormSegundoTusOne if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, xq (iccSegTusOne`bandwith') rd(0) linetype(qfit) xtitle(ICCOne - Sec TUS thres) ytitle(`var' segunda visita)
	graph export ..\Output\\`var'Two_seg_2TUS.png, replace
}

*** Regresiones
gen hogarNOzerocobratusTwo=0
replace hogarNOzerocobratusTwo=1 if hogarzerocobratusTwo ==0

** Alimentacion
foreach var in sinalimentos adultonocomio menornocomio merendero canasta {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds for Mdeo
	ivregress 2sls `var'Two `var'One iccLessPrimTUSOne iccMoreSecTUSOne iccMiddTUSOne iccLessPrimTUS2One iccMoreSecTUS2One iccMiddTUS2One (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	
	}


** Domestic violence
foreach var in vd vdMujer vdMenor vdAdultomayor vdVaron {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}
	
** UTE, OSE regularizado
foreach var in uteRegularizado oseRegularizado {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	
	}
	
** Embarazada
foreach var in embarazada {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0 & hombreOne==0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1 & hombreOne==0, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0 & hombreOne==0, robust first	
	}

** Ingresos personal y del hogar
foreach var in hogingtotsintransf ingtotalessintransferencias {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}
	
* Mentiras con tarjeta mienteHogIngTarjeta
foreach var in mienteHogIngTarjeta mienteIngTarjeta {
	* Not receiving TUS initially
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 0, robust first

	* Receiving 1 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarzerocobratusTwo = iccSuperaPrimerTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first
	
	* Receiving 1 TUS initially and in the threshold of doubling it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	

	* Receiving 2 TUS initially and in the threshold of losing it
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo = iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 1, robust first	
	
	* Receiving 1 TUS and looking at both thresholds
	ivregress 2sls `var'Two `var'One edad_visitaTwo iccNormSegundoTusOne iccNormInteractedSegundoTusOne iccNormSegundoTus2One iccNorm2InteractedSegundoTusOne (hogarzerotusdobleTwo hogarNOzerocobratusTwo = iccSuperaPrimerTUSOne iccSuperaSegundoTUSOne)  if hogarzerocobratusOne == 1 & hogarzerotusdobleOne == 0, robust first	
	}

*** Regressions con rdrobust package
* ereturn list: gives you e() post estimation. Retrieved with eststo
* return list: gives you r() post estimation. Retrieved with estpost

gen hogarMasNcobraTus12One = .
replace hogarMasNcobraTus12One = 1 if hogarMascobraTus12One == 0
replace hogarMasNcobraTus12One = 0 if hogarMascobraTus12One == 1

gen hogarMasNcobraTus12Two = .
replace hogarMasNcobraTus12Two = 1 if hogarMascobraTus12Two == 0
replace hogarMasNcobraTus12Two = 0 if hogarMascobraTus12Two == 1

gen hombreMascobraTus12One = hombreOne * hogarMascobraTus12One
gen hombreSuperaPrimerTUSOne = hombreOne * iccSuperaPrimerTUSOne


gen edad_visita2One = edad_visitaOne * edad_visitaOne
gen hogingtotsintransf2One = hogingtotsintransfOne * hogingtotsintransfOne
gen hogAnosEducAdults2One = hogAnosEducAdultsOne * hogAnosEducAdultsOne
* Macros
global SCDpedidoRevisitedOne departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACDpedidoRevisitedOne $SCDpedidoRevisitedOne

global SCrevisitedPorGovOne departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACrevisitedPorGovOne $SCrevisitedPorGovOne

global SCmenornocomioTwo departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACmenornocomioTwo $SCmenornocomioTwo menornocomioOne

global SCsinalimentosTwo departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACsinalimentosTwo $SCsinalimentosTwo sinalimentosOne

global SCadultonocomioTwo departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACadultonocomioTwo $SCadultonocomio adultonocomioOne


global SCDpedidoRevisitedTwo departamentoOne1 yearOne2 yearOne3 yearOne4 yearOne5 yearOne6 yearOne7
global ACDpedidoRevisitedTwo $SCDpedidoRevisitedTwo hombreOne edad_visitaOne edad_visita2One sinalimentosOne hogingtotsintransfOne hogingtotsintransf2One hogAnosEducAdultsOne hogAnosEducAdults2One

global SCrevisitedPorGovTwo departamentoOne1 yearOne3 yearOne4 yearOne5 
global ACrevisitedPorGovTwo $SCrevisitedPorGovTwo hombreOne edad_visitaOne edad_visita2One sinalimentosOne hogingtotsintransfOne hogingtotsintransf2One hogAnosEducAdultsOne hogAnosEducAdults2One

global SCmenornocomioThree departamentoOne1 yearOne yearTwo
global ACmenornocomioThree $SCmenornocomioThree menornocomioOne menornocomioTwo

global SCsinalimentosThree departamentoOne1 yearOne yearTwo
global ACsinalimentosThree $SCsinalimentosThree sinalimentosOne sinalimentosTwo


** Visitas
rdrobust visita2 iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One)
eststo m1
rdrobust visita2 iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One)
eststo m2


** Vistas pedidas y revisitado por motus del gobierno
eststo clear
foreach var in revisitedPorGovOne DpedidoRevisitedOne sinalimentosTwo menornocomioTwo adultonocomio {
	* No controls	
	forvalues i = 1/2 {
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0)
		eststo `var'0`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'NC
		estadd scalar band = e(h_l): `var'0`i'NC
		scalar band = e(h_l)
		local `var'0`i'NC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==0 & abs(iccNormPrimerTusOne)<``var'0`i'NC'
		matrix `var'0`i'NC = e(b)
		estadd scalar meanCtrl = `var'0`i'NC[1,1] : `var'0`i'NC
		estadd local demoControls "No": `var'0`i'NC
		estadd local allControls "No": `var'0`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'NC
			}
			
		
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0)
		eststo `var'1`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'NC
		estadd scalar band = e(h_l): `var'1`i'NC
		scalar band = e(h_l)
		local `var'1`i'NC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3 & abs(iccNormPrimerTusOne)<``var'1`i'NC'
		matrix `var'1`i'NC = e(b)
		estadd scalar meanCtrl = `var'1`i'NC[1,1] : `var'1`i'NC
		estadd local demoControls "No": `var'1`i'NC
		estadd local allControls "No": `var'1`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'NC
			}
		
	*rdbwselect DpedidoRevisitedOne iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
	*rdbwselect DpedidoRevisitedOne iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)

		* Some controls
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0) covs(${SC`var'})
		eststo `var'0`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'SC
		estadd scalar band = e(h_l): `var'0`i'SC
		scalar band = e(h_l)
		local `var'0`i'SC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==0 & abs(iccNormPrimerTusOne)<``var'0`i'SC'
		matrix `var'0`i'SC = e(b)
		estadd scalar meanCtrl = `var'0`i'SC[1,1] : `var'0`i'SC
		estadd local demoControls "Yes": `var'0`i'SC
		estadd local allControls "No": `var'0`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'SC
			}
				
		
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0) covs(${SC`var'})
		eststo `var'1`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'SC
		estadd scalar band = e(h_l): `var'1`i'SC
		scalar band = e(h_l)
		local `var'1`i'SC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3 & abs(iccNormPrimerTusOne)<``var'1`i'SC'
		matrix `var'1`i'SC = e(b)
		estadd scalar meanCtrl = `var'1`i'SC[1,1] : `var'1`i'SC
		estadd local demoControls "Yes": `var'1`i'SC
		estadd local allControls "No": `var'1`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'SC
			}
				
		
		* All controls
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0) covs(${AC`var'})
		eststo `var'0`i'AC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'AC
		estadd scalar band = e(h_l): `var'0`i'AC
		scalar band = e(h_l)
		local `var'0`i'AC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==0 & abs(iccNormPrimerTusOne)<``var'0`i'SC'
		matrix `var'0`i'AC = e(b)
		estadd scalar meanCtrl = `var'0`i'AC[1,1] : `var'0`i'AC
		estadd local demoControls "Yes": `var'0`i'AC
		estadd local allControls "Yes": `var'0`i'AC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'AC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'AC
			}
				
		rdrobust `var' iccNormPrimerTusOne if hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3, c(0) p(`i') fuzzy(hogarMascobraTus12One) vce(hc0) covs(${AC`var'})
		eststo `var'1`i'AC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'AC
		estadd scalar band = e(h_l): `var'1`i'AC
		scalar band = e(h_l)
		local `var'1`i'AC = scalar(band)
		
		mean `var' if hogarMascobraTus12One==1 & hogarZerocobraTusOne==1 & hogarZerotusDobleOne!=3 & abs(iccNormPrimerTusOne)<``var'1`i'AC'
		matrix `var'1`i'AC = e(b)
		estadd scalar meanCtrl = `var'1`i'AC[1,1] : `var'1`i'AC
		estadd local demoControls "Yes": `var'1`i'AC
		estadd local allControls "Yes": `var'1`i'AC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'AC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'AC
			}
				
}
}

foreach var in DpedidoRevisitedOne {
	esttab `var'01NC `var'11NC `var'01SC `var'11SC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02SC `var'12SC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in revisitedPorGovOne {
	esttab `var'01NC `var'11NC `var'01SC `var'11SC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisited on a non-requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02SC `var'12SC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisited on a non-requested visit" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in sinalimentosTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("No food" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("No food" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls,fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in menornocomioTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("No food for minors" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("No food for minors" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in adultonocomioTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("No food for adults" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("No food for adults" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "UCT 1yr after 1st visit") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}
	addnotes("Notes: robust standard errors; asymmetric and quadratic control function considered in all regressions; losing/not getting a UCT 12 months after the visit is instrumented with whether the individual lived in a household that surpassed the first UCT threashold during the first visit.") ///
	
* Visitas censales
rdrobust censalRevisit iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
rdrobust censalRevisit iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)

rdrobust censalPostaRevisit iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
rdrobust censalPostaRevisit iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)

mean censalPostaRevisit if hogarMascobraTus12One==1 & hogarZerocobraTusOne==0 & abs(iccNormPrimerTusOne)<0.138
mean censalPostaRevisit if hogarMascobraTus12One==1 & hogarZerocobraTusOne==1 & abs(iccNormPrimerTusOne)<0.148

* Revisitado por motus del gobierno
rdrobust revisitedPorGovOne iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
rdrobust revisitedPorGov iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
mean revisitedPorGov if hogarMascobraTus12One==1 & hogarZerocobraTusOne==0 & abs(iccNormPrimerTusOne)<0.140
mean revisitedPorGov if hogarMascobraTus12One==1 & hogarZerocobraTusOne==1 & abs(iccNormPrimerTusOne)<0.139

* Alimentacion
rdrobust adultonocomiotwo iccnormprimertusone if hogarzerocobratusone==0, c(0) p(2) fuzzy(hogarmascobratus12one) vce(hc0)
rdrobust adultonocomiotwo iccnormprimertusone if hogarzerocobratusone==1, c(0) p(2) fuzzy(hogarmascobratus12one) vce(hc0)
mean adultonocomiotwo if hogarmascobratus12one==1 & hogarzerocobratusone==0 & abs(iccnormprimertusone)<0.169
mean adultonocomiotwo if hogarmascobratus12one==1 & hogarzerocobratusone==1 & abs(iccnormprimertusone)<0.111

rdrobust menornocomiotwo iccnormprimertusone if hogarzerocobratusone==0, c(0) p(2) fuzzy(hogarmascobratus12one) vce(hc0)
rdrobust menornocomiotwo iccnormprimertusone if hogarzerocobratusone==1, c(0) p(2) fuzzy(hogarmascobratus12one) vce(hc0)
mean menornocomiotwo if hogarmascobratus12one==1 & hogarzerocobratusone==0 & abs(iccnormprimertusone)<0.167
mean menornocomiotwo if hogarmascobratus12one==1 & hogarzerocobratusone==1 & abs(iccnormprimertusone)<0.118

revisitedPorGovTwo DpedidoRevisitedTwo sinalimentosThree menornocomioThree
*** RDrobust para aquellos con idem inobservables
eststo clear
foreach var in menornocomioThree sinalimentosThree {
	* No controls	
	forvalues i = 1/2 {
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0)
		eststo `var'0`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'NC
		estadd scalar band = e(h_l): `var'0`i'NC
		scalar band = e(h_l)
		local `var'0`i'NC = scalar(band)
		
		mean `var' if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0 & hogarMascobraTus12Two==1 & abs(iccNormPrimerTusTwo)<``var'0`i'NC'
		matrix `var'0`i'NC = e(b)
		estadd scalar meanCtrl = `var'0`i'NC[1,1] : `var'0`i'NC
		estadd local demoControls "No": `var'0`i'NC
		estadd local allControls "No": `var'0`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'NC
			}
			
		
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0)
		eststo `var'1`i'NC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'NC
		estadd scalar band = e(h_l): `var'1`i'NC
		scalar band = e(h_l)
		local `var'1`i'NC = scalar(band)
		
		mean `var' if hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0 & hogarMascobraTus12Two==1 & hogarZerocobraTusTwo==1 & hogarZerotusDobleTwo!=3 & abs(iccNormPrimerTusTwo)<``var'1`i'NC'
		matrix `var'1`i'NC = e(b)
		estadd scalar meanCtrl = `var'1`i'NC[1,1] : `var'1`i'NC
		estadd local demoControls "No": `var'1`i'NC
		estadd local allControls "No": `var'1`i'NC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'NC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'NC
			}
		
	*rdbwselect DpedidoRevisitedOne iccNormPrimerTusOne if hogarZerocobraTusOne==0, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)
	*rdbwselect DpedidoRevisitedOne iccNormPrimerTusOne if hogarZerocobraTusOne==1, c(0) p(2) fuzzy(hogarMascobraTus12One) vce(hc0)

		* Some controls
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0) covs(${SC`var'})
		eststo `var'0`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'SC
		estadd scalar band = e(h_l): `var'0`i'SC
		scalar band = e(h_l)
		local `var'0`i'SC = scalar(band)
		
		mean `var' if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0 & hogarMascobraTus12Two==1 & abs(iccNormPrimerTusTwo)<``var'0`i'SC'
		matrix `var'0`i'SC = e(b)
		estadd scalar meanCtrl = `var'0`i'SC[1,1] : `var'0`i'SC
		estadd local demoControls "Yes": `var'0`i'SC
		estadd local allControls "No": `var'0`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'SC
			}
				
		
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0) covs(${SC`var'})
		eststo `var'1`i'SC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'SC
		estadd scalar band = e(h_l): `var'1`i'SC
		scalar band = e(h_l)
		local `var'1`i'SC = scalar(band)
		
		mean `var' if hogarMascobraTus12Two==1 & hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0 & abs(iccNormPrimerTusTwo)<``var'1`i'SC'
		matrix `var'1`i'SC = e(b)
		estadd scalar meanCtrl = `var'1`i'SC[1,1] : `var'1`i'SC
		estadd local demoControls "Yes": `var'1`i'SC
		estadd local allControls "No": `var'1`i'SC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'SC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'SC
			}
				
		
		* All controls
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0) covs(${AC`var'})
		eststo `var'0`i'AC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'0`i'AC
		estadd scalar band = e(h_l): `var'0`i'AC
		scalar band = e(h_l)
		local `var'0`i'AC = scalar(band)
		
		mean `var' if hogarZerocobraTusOne==0 & iccNormPrimerTusOne>-0.15 & iccNormPrimerTusOne<0 & hogarMascobraTus12Two==1 & abs(iccNormPrimerTusTwo)<``var'0`i'SC'
		matrix `var'0`i'AC = e(b)
		estadd scalar meanCtrl = `var'0`i'AC[1,1] : `var'0`i'AC
		estadd local demoControls "Yes": `var'0`i'AC
		estadd local allControls "Yes": `var'0`i'AC
		if `i' == 1 {
			estadd local poly "Linear": `var'0`i'AC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'0`i'AC
			}
				
		rdrobust `var' iccNormPrimerTusTwo if hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0, c(0) p(`i') fuzzy(hogarMascobraTus12Two) vce(hc0) covs(${AC`var'})
		eststo `var'1`i'AC
		
		estadd scalar nobs = e(N_h_l) + e(N_h_r): `var'1`i'AC
		estadd scalar band = e(h_l): `var'1`i'AC
		scalar band = e(h_l)
		local `var'1`i'AC = scalar(band)
		
		mean `var' if hogarMascobraTus12Two==1 & hogarZerocobraTusOne==0 & iccNormPrimerTusOne<0.15 & iccNormPrimerTusOne>=0 & abs(iccNormPrimerTusTwo)<``var'1`i'AC'
		matrix `var'1`i'AC = e(b)
		estadd scalar meanCtrl = `var'1`i'AC[1,1] : `var'1`i'AC
		estadd local demoControls "Yes": `var'1`i'AC
		estadd local allControls "Yes": `var'1`i'AC
		if `i' == 1 {
			estadd local poly "Linear": `var'1`i'AC
			}
		else if `i' == 2 {
			estadd local poly "Quadratic": `var'1`i'AC
			}
				
}
}

foreach var in DpedidoRevisitedTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in revisitedPorGovTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisited on a non-requested visit" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisited on a non-requested visit" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in sinalimentosThree {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("No food" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("No food" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

foreach var in menornocomioThree {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("No food for minors" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("No food for minors" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels("Observations" "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1")	
}

*** Regressions con IV regress
ivregress 2sls DpedidoRevisitedOne iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarMascobraTus12One = iccSuperaPrimerTUSOne) if hogarZerocobraTusOne == 0 & abs(iccNormPrimerTusOne)<0.087, robust first
ivregress 2sls DpedidoRevisited iccNormPrimerTusOne iccNormInteractedPrimerTusOne iccNormPrimerTus2One iccNorm2InteractedPrimerTusOne (hogarMascobraTus12One = iccSuperaPrimerTUSOne) if hogarZerocobraTusOne == 1 & abs(iccNormPrimerTusOne)<0.115, robust first

foreach var in revisitedPorGovOne DpedidoRevisitedOne {
	esttab `var'01NC `var'11NC `var'01SC `var'11SC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(N meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels(Observations "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1") width(\hsize 5pt)
	
	esttab `var'02NC `var'12NC `var'02SC `var'12SC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisited on a requested visit" "Revisited on a non-requested visit", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(N meanCtrl band poly demoControls allControls, fmt(0 3 3 3) labels(Observations "Mean for recipients" "Bandwith (CCT)" "RD polynomial" "Year and state FE" "Other controls")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "Gaining vs Losing") ///
	mtitles("UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1" "UCT = 0" "UCT = 1") width(\hsize 5pt) 	
}


* Tablas en español
foreach var in revisitedPorGovOne {
	esttab `var'01NC `var'11NC `var'01SC `var'11SC using ..\Output\\`var'1.tex, replace ///
	mgroups("Revisitado en visita solicitada" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
	
	esttab `var'02NC `var'12NC `var'02SC `var'12SC using ..\Output\\`var'2.tex, replace ///
	mgroups("Revisitado en visita solicitada" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")	
}

foreach var in sinalimentosTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Inseguridad Alimentaria" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Inseguridad Alimentaria" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")	
}

foreach var in menornocomioTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Inseguridad Alimentaria para Menores" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Inseguridad Alimentaria para Menores" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
}

foreach var in adultonocomioTwo {
	esttab `var'01NC `var'11NC `var'01AC `var'11AC using ..\Output\\`var'1.tex, replace ///
	mgroups("Inseguridad Alimentaria para Adultos" "Revisited on a non-requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
	
	esttab `var'02NC `var'12NC `var'02AC `var'12AC using ..\Output\\`var'2.tex, replace ///
	mgroups("Inseguridad Alimentaria para Adultos" "Revisited on a requested visit", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	stats(nobs meanCtrl band poly demoControls, fmt(0 3 3 3) labels("Observaciones" "Media beneficiarios" "Banda (CCT)" "Polinomio RDD" "EF: Año y departamento")) ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) coeflabels(RD_Estimate "TUS 1 año post 1er visita") ///
	mtitles("TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1" "TUS = 0" "TUS = 1")
}
