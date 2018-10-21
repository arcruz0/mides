* Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
*            visitas y datos completos de AFAM
clear all
cd "C:\Alejandro\Research\MIDES\Empirical_analysis\Build\Temp"

*** Load base AFAM
import delimited ..\Input\2008_2009_AFAM_enmascarado\2008_2009_AFAM_enmascarado.csv, clear

* Me quedo con variables que me interesan
keep nrodocumento year month ingresosnucleo ingresosnucleodecl indice_in monto_hogar

*** Me fijo si hay cédulas de identidad con más de una carga en mismo año y mes
generate n=_n // Voy a utilizar esta variable para drop observations repetidas
egen grupo=group(nrodocumento year month)
duplicates tag grupo, generate (grupo_unico)
*browse if grupo_unico!=0

*** Corrijo variables AFAM que voy a quedarme
