''' 
Script that explains flow of programs to perform empirical analysis over MIDES datasets

********************************** BUILD **************************************

0) Objective:  Armado de un archivo con flowcorrelativeid, latitud/longitud y departamento
    Code:      0_geo_visitas.py
    Input:     Input\pedido_lihuen\producto_1_enmascarado.csv
    Output:    Temp\geo_visitas.csv

1)  Objective: Limpiar bases de visitas y tener un archivo con todas las variables
               de visitas a nivel de hogar y otro de personas (agregando datos geo 
               y equivalencias de anonimizadores)
    Code:      Code\1_cleaning_visitas.do
    Input:     Input\Visitas_Hogares_Muestra_enmascarado.csv
               Input\Visitas_Personas_Muestra_enmascarado.csv
               Temp\geo_visitas.csv
               Input\Anonimizadores_equivalencias\Parte1.csv
               Input\Anonimizadores_equivalencias\Parte2.csv              
    Output:    Output\visitas_hogares_vars.csv
               Output\visitas_hogares_vars.dta
               Output\visitas_personas_vars.csv
               Output\visitas_personas_vars.dta

2)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos completos de TUS
    Code:      Code\2_visitas_TUS.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\TUS_Muestra_enmascarado.csv
    Output:    Output\visitas_hogares_TUS.csv
               Output\visitas_hogares_TUS.dta
               Output\visitas_personas_TUS.csv
               Output\visitas_personas_TUS.dta

3)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos completos de AFAM
    Code:      Code\3_visitas_AFAM
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\AFAM_enmascarado (todas las 13 carpetas)
    Output:    Output\visitas_hogares_AFAM.csv
               Output\visitas_hogares_AFAM.dta
               Output\visitas_personas_AFAM.csv
               Output\visitas_personas_AFAM.dta

4)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos PP y suspendidos educativos
    Code:      Code\4_visitas_PPySusp.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\PP_Muestra_enmascarado.csv
               Input\Suspendidos_Muestra_enmascarado.csv
    Output:    Output\visitas_hogares_PPySusp.csv
               Output\visitas_hogares_PPySusp.dta
               Output\visitas_personas_PPySusp.csv
               Output\visitas_personas_PPySusp.dta

5)  Objective: Generar variables de umbrales de AFAM y TUS según individuos 
               están en programas especiales (ej. Jóvenes en RED) y reemplazar 
               archivos con estas nuevas variables
    Code:      Code\5_umbrales_especiales
    Input:     Output\visitas_hogares_TUS.csv
               Output\visitas_personas_TUS.csv
               Input\AFAM_enmascarado (todas las 13 carpetas)
               Archivos que vengan de SIIAS
    Output:    Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv

6)  Objective: Checkear base CNV-SIIAS y generar dos archivos (hogares y personas) con datos 
               mínimos de las visitas y datos CNV
    Code:      Code\6_cnv_siias
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\SIIAS\CNV (todos los 11 archivos)
    Output:    Output\visitas_hogares_cnv_siias.csv
               Output\visitas_personas_cnv_siias.csv

7)  Objective: Checkear base Educ-SIIAS y generar dos archivos (hogares y personas) 
               con datos mínimos de las visitas y datos SIIAS-Educacion
    Code:      Code\7_educ_siias
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\SIIAS\Educacion (todos los 33 archivos)
    Output:    Output\visitas_hogares_educ_siias.csv
               Output\visitas_personas_educ_siias.csv

8)  Objective: Checkear base BPS-SIIAS y generar dos archivos (hogares y personas) con datos 
               mínimos de las visitas y datos BPS del SIIAS
    Code:      Code\8_bps_siias.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv     
               Input\SIIAS\BPS (todos los 22 archivos)
    Output:    Output\BPS_SIIAS_hogares.csv
               Output\BPS_SIIAS_hogares.dta
               Output\BPS_SIIAS_personas.csv
               Output\BPS_SIIAS_personas.dta

9)  Objective: Checkear base Programas Sociales-SIIAS y generar dos archivos 
               (hogares y personas) con datos mínimos de las visitas y de Prog. Sociales SIIAS
    Code:      Code\9_prog_soc_siias.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\SIIAS\Programas_Sociales (todos los 11 archivos)
    Output:    Output\visitas_hogares_prog_soc_siias.csv
               Output\visitas_personas_prog_soc_siias.csv

10) Objective: Armar archivo con solicitudes de visitas y datos mínimos de las 
               personas en la visita
    Code:      Code\10_sol_visitas.py
    Input:     Input\pedido_lihuen\producto_3_enmascarado.csv
               Output\visitas_personas_vars.csv
               Output\visitas_hogares_vars.csv
    Output:    Output\sol_visitas_personas.csv

11) Objective: Preparar base para estimar peer effects.
    Code:      Code\11_peer_effects.py
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Output\visitas_hogares_TUS.csv
               Output\visitas_personas_TUS.csv
    Output:    Output\peer_personas.csv: base con una persona por fila donde a las variables de Output\visitas_personas_vars.csv se le suman variables de cantidad de TUS perdidas/ganandas/duplicadas en el "barrio" en distintos momentos del tiempo y agregados del barrio para distintos momentos del tiempo en base a visitas a hogares del barrio
               Output\peer_hogares.csv: base con una visita-hogar por fila donde a las variables de Output\visitas_personas_vars.csv se le suman variables de cantidad de TUS perdidas/ganandas/duplicadas en el "barrio" en distintos momentos del tiempo y agregados del barrio para distintos momentos del tiempo en base a visitas a hogares del barrio


10) Objective: Mover bases generadas de Output del Build al Input de Analysis
    Code:      Code\6_move_build_analysis.py
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_hogares_vars.dta
               Output\visitas_personas_vars.csv
               Output\visitas_personas_vars.dta
               Output\visitas_hogares_PPySusp.csv
               Output\visitas_hogares_PPySusp.dta
               Output\visitas_personas_PPySusp.csv
               Output\visitas_personas_PPySusp.dta
               Output\visitas_hogares_TUS.csv
               Output\visitas_hogares_TUS.dta
               Output\visitas_personas_TUS.csv
               Output\visitas_personas_TUS.dta
               Output\visitas_hogares_AFAM.csv
               Output\visitas_hogares_AFAM.dta
               Output\visitas_personas_AFAM.csv
               Output\visitas_personas_AFAM.dta
               Output\BPS_SIIAS_hogares.csv
               Output\BPS_SIIAS_hogares.dta
               Output\BPS_SIIAS_personas.csv
               Output\BPS_SIIAS_personas.dta
    Output:    ..Analysis\Input\MIDES\visitas_hogares_vars.csv
               ..Analysis\Input\MIDES\visitas_hogares_vars.dta
               ..Analysis\Input\MIDES\visitas_personas_vars.csv
               ..Analysis\Input\MIDES\visitas_personas_vars.dta
               ..Analysis\Input\MIDES\visitas_hogares_PPySusp.csv
               ..Analysis\Input\MIDES\visitas_hogares_PPySusp.dta
               ..Analysis\Input\MIDES\visitas_personas_PPySusp.csv             
               ..Analysis\Input\MIDES\visitas_personas_PPySusp.dta
               ..Analysis\Input\MIDES\visitas_hogares_TUS.csv
               ..Analysis\Input\MIDES\visitas_hogares_TUS.dta
               ..Analysis\Input\MIDES\visitas_personas_TUS.csv               
               ..Analysis\Input\MIDES\visitas_personas_TUS.dta
               ..Analysis\Input\MIDES\visitas_hogares_AFAM.csv
               ..Analysis\Input\MIDES\visitas_hogares_AFAM.dta
               ..Analysis\Input\MIDES\visitas_personas_AFAM.csv              
               ..Analysis\Input\MIDES\visitas_personas_AFAM.dta
               ..Analysis\Input\MIDES\BPS_SIIAS_hogares.csv
               ..Analysis\Input\MIDES\BPS_SIIAS_hogares.dta
               ..Analysis\Input\MIDES\BPS_SIIAS_personas.csv
               ..Analysis\Input\MIDES\BPS_SIIAS_personas.dta


****************************** ANALYSIS ***************************************

0)  Objective: Chequeo de cómo altas y bajas al TUS y AFAM se dieron como función
               del ICC u otros motivos como ser edad, participación en programas MIDES
    Code:      Code\0_check_first_stage.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
    Output:    Output\0_check_first_stage.tex


1)  Objective: Mirar first stage en TUS tanto para perder, ganar y 
               duplicar beneficio.
    Code:      Code\1_tus_first_stage.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
    Output:    
               
2)  Objective: Mirar second stage de impacto TUS en PP.
    Code:      Code\2_tus_PP.py
               Code\2_tus_PP.do
    Input:     Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_personas_PPySusp.csv
    Output:    

3)  Objective: Mirar second stage de impacto TUS en suspendidos educativos.
    Code:      Code\3_tus_suspendidos.py
    Input:     Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_personas_PPySusp.csv
    Output:              

4)  Objective: Mirar second stage de impacto TUS en variables de base visitas 
               y balance re-visitas y no re-visitados (para hogares revistados).
    Code:      Code\4_tus_vars_revistadas.do
               Code\4_tus_vars_revistadas.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
               Input\MIDES\visitas_personas_vars.csv
    Output:  
            
5)  Objective: Armar basic summary statstics.
    Code:      Code\5_summary_stats.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
               Input\MIDES\visitas_personas_vars.csv
               Input\MIDES\visitas_personas_PPySusp.csv
               Input\IPC_TC.xlsx
    Output: 

            
6)  Objective: Poner visitas en un mapa y poner colores con si luego de visita
               se perdió, ganó, duplicó, mantuvo 1 o mantuvo 2, etc transferencias
               y si son censales o recorrido tipo, etc
    Code:      Code\6_mapa_visitas.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
               Input\MIDES\visitas_personas_vars.csv
               
    Output: 
        
7)  Objective: Generar variables de lo que "sucedió" en tu barrio.
    Code:      Code\7_gen_variables_nbd.do
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_hogares_vars.csv
               Input\MIDES\visitas_personas_vars.csv
               
    Output: 
        
9)  Objective: Mirar impactos por meses antes y después de visita con variables AFAM.
    Code:      Code\9_tus_envars_afam.py
    Input:     Input\MIDES\visitas_hogares_TUS.csv
               Input\MIDES\visitas_personas_TUS.csv
               Input\MIDES\visitas_hogares_AFAM.csv
               Input\MIDES\visitas_personas_AFAM.csv
               
    Output:

10) Objective: Mirar impactos ganar/perder en revisitas para grupos 
               con mismos inobservables
    Code:      Code\10_revisitados_inobservables.py
               Code\10_revisitados_inobservables.do
    Input:     Temp\vars_personas_revisitadas.csv

               
    Output:

11) Objective: Mirar second stage de impacto TUS en BPS-SIIAS.
    Code:      Code\11_1_bps_siias.do
               Code\11_2_bps_siias.py
    Input:     Input\MIDES\BPS_SIIAS_hogares.csv
               Input\MIDES\BPS_SIIAS_personas.csv
            
    Output:
      
12) Objective: Mirar second stage de impacto TUS en Educ-SIIAS.
    Code:      Code\12_educ_siias.py
               Code\12_educ_siias.do
    Input:     Input\MIDES\visitas_hogares_educ_siias.csv
               Input\MIDES\visitas_personas_educ_siias.csv
            
    Output:
        
13) Objective: Mirar second stage de impacto TUS en CNV-SIIAS.
    Code:      Code\13_cnv_siias.py
               Code\13_cnv_siias.do
    Input:     Input\MIDES\visitas_hogares_cnv_siias.csv
               Input\MIDES\visitas_personas_cnv_siias.csv
            
    Output:
        
14) Objective: Mirar second stage de impacto TUS en Programas Sociales-SIIAS.
    Code:      Code\14_prog_soc_siias.py
               Code\14_prog_soc_siias.do
    Input:     Input\MIDES\visitas_hogares_prog_soc_siias.csv
               Input\MIDES\visitas_personas_prog_soc_siias.csv
            
    Output:
 
15) Objective: Mirar second stage de impacto TUS en solicitudes de visitas
    Code:      Code\15_sol_visitas.py
    Input:     Input\MIDES\sol_visitas_personas.csv

    Output:
        
16) Objective: Mirar second stage de impacto TUS en variables recogidas al momento de
               la visita considerando peer effects
    Code:      Code\16_peer_effects_visita.
    Input:     Input\MIDES\.csv
               Input\MIDES\.csv
    Output:    Output\
    
17) Objective: Mirar second stage de impacto TUS en PP considerando peer effects.
    Code:      Code\16_peer_effects_PP.
    Input:     Input\MIDES\.csv
               Input\MIDES\.csv
    Output:    Output\
 
        
'''

