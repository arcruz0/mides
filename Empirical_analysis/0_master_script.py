'''
Script that explains flow of programs to perform empirical analysis over MIDES datasets

********************************** BUILD **************************************

0) Objective:  Armar un archivo con flowcorrelativeid, latitud/longitud y departamento
               en base a datos proporcionados por el departamento Geo del MIDES y georreferenciación
               propia via Google Maps API usando dirección proporcionada por el hogar al momento
               de la visita
    Code:      Code/0a_geo_visitas.R
               Code/0b_geo_gmaps.R
               Code/0c_geo_limpiar.R
               Code/0d_geo_unir_a_base.R
    Input:     Input/pedido_lihuen/producto_1_enmascarado.csv
               Input/Visitas_Hogares_Muestra_enmascarado.csv
               Input/Localidades_y_codigos_NUEVO_XLS.xls
               Input/Tabla_de_Localidades_Censales_año_2011.dbf
    Output:    Temp/0d_geo_visitas.csv

1)  Objective: Limpiar bases de visitas y tener un archivo con todas las variables
               de visitas a nivel de hogar y otro de personas (agregando datos geo 
               y equivalencias de anonimizadores)
    Code:      Code/1_cleaning_visitas.do
    Input:     Input/Visitas_Hogares_Muestra_enmascarado.csv
               Input/Visitas_Personas_Muestra_enmascarado.csv
               Temp/0d_geo_visitas.csv
               Input/Anonimizadores_equivalencias/Parte1.csv
               Input/Anonimizadores_equivalencias/Parte2.csv              
    Output:    Output/visitas_hogares_vars.csv
               Output/visitas_hogares_vars.dta
               Output/visitas_personas_TUS.csv
               Output/visitas_personas_TUS.dta

2)  Objective: Generar variables de umbrales de AFAM y TUS según individuos 
               están en programas especiales (ej. Jóvenes en RED) y reemplazar 
               archivos con estas nuevas variables
    Code:      Code/2a_limpiar_ps.R
               Code/2b_generar_archivo_unico_ps.R
               Code/2c_unir_bases.R
    Input:     Output/visitas_hogares_TUS.csv
               Input/SIIAS/Programas_Sociales (todos los 11 archivos)
    Output:    Output/2c_umbralesaj_ventana0.csv
               Output/2c_umbralesaj_ventana1.csv
               Output/2c_umbralesaj_ventana2.csv
               Output/2c_umbralesaj_ventana12atras.csv

3)  Objective: Checkear base TUS y generar dos archivos (hogares y personas) 
               con datos mínimos de las visitas y datos completos de TUS
    Code:      Code/3_visitas_TUS.do
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/TUS_Muestra_enmascarado.csv
    Output:    Output/visitas_hogares_TUS.csv
               Output/visitas_hogares_TUS.dta
               Output/visitas_personas_TUS.csv
               Output/visitas_personas_TUS.dta
               Temp/check_TUS.tex

4)  Objective: Checkear base de datos AFAM y generar dos archivos 
               (hogares y personas) con datos mínimos de las
               visitas y datos completos de AFAM
    Code:      Code/4_visitas_AFAM
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/AFAM_enmascarado (todas las 13 carpetas)
    Output:    Output/visitas_hogares_AFAM.csv
               Output/visitas_hogares_AFAM.dta
               Output/visitas_personas_AFAM.csv
               Output/visitas_personas_AFAM.dta
               Temp/check_AFAM.tex

5)  Objective: Checkear bases PP y suspendidos educativos y generar dos 
               archivos (hogares y personas) con datos mínimos de las
               visitas y datos PP y suspendidos educativos
    Code:      Code/5_visitas_PPySusp.do
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/PP_Muestra_enmascarado.csv
               Input/Suspendidos_Muestra_enmascarado.csv
    Output:    Output/visitas_hogares_PPySusp.csv
               Output/visitas_hogares_PPySusp.dta
               Output/visitas_personas_PPySusp.csv
               Output/visitas_personas_PPySusp.dta
               Temp/check_PP.tex
               Temp/check_Susp.tex

6)  Objective: Checkear base CNV-SIIAS y generar dos archivos (hogares y personas) con datos 
               mínimos de las visitas y datos CNV
    Code:      Code/6_cnv_siias
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/SIIAS/CNV (todos los 11 archivos)
    Output:    Output/visitas_hogares_cnv_siias.csv
               Output/visitas_personas_cnv_siias.csv
               Temp/check_CNV.tex

7)  Objective: Checkear base Educ-SIIAS y generar dos archivos (hogares y personas) 
               con datos mínimos de las visitas y datos SIIAS-Educacion
    Code:      Code/7_educ_siias.do
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/SIIAS/Educacion (todos los 33 archivos)
    Output:    Output/visitas_hogares_educ_siias.csv
               Output/visitas_personas_educ_siias.csv
               Temp/check_educ_siias.tex

8)  Objective: Checkear base BPS-SIIAS (y cotejarla con datos de empleo que 
               salen de base AFAM) y generar dos archivos (hogares y personas) 
               con datos mínimos de las visitas y datos BPS del SIIAS
    Code:      Code/8_bps_siias.do
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv     
               Input/SIIAS/BPS (todos los 22 archivos)
    Output:    Output/BPS_SIIAS_hogares.csv
               Output/BPS_SIIAS_hogares.dta
               Output/BPS_SIIAS_personas.csv
               Output/BPS_SIIAS_personas.dta
               Temp/check_BPS_SIIAS.tex

9)  Objective: Checkear base Programas Sociales-SIIAS y generar dos archivos por programa
               (hogares y personas) con datos mínimos de las visitas y de Prog. Sociales SIIAS
    Code:      Code/9_prog_soc_siias.do
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_personas_vars.csv
               Input/SIIAS/Programas_Sociales (todos los 11 archivos)
    Output:    Output/visitas_personas_bps_afam_ley_benef.csv
               Output/visitas_hogares_bps_afam_ley_benef.csv
               Output/visitas_personas_bps_afam_ley_atrib.csv
               Output/visitas_hogares_bps_afam_ley_atrib.csv
               Output/visitas_personas_bps_pens_vejez.csv
               Output/visitas_hogares_bps_pens_vejez.csv
               Output/visitas_personas_bps_sol_habit_am.csv
               Output/visitas_hogares_bps_sol_habit_am.csv
               Output/visitas_personas_mvotma_rubv.csv
               Output/visitas_hogares_mvotma_rubv.csv
               Output/visitas_personas_inau_t_comp.csv
               Output/visitas_hogares_inau_t_comp.csv
               Output/visitas_personas_inau_disc_t_comp.csv
               Output/visitas_hogares_inau_disc_t_comp.csv
               Output/visitas_personas_inau_caif.csv
               Output/visitas_hogares_inau_caif.csv
               Output/visitas_personas_inau_club_niños.csv
               Output/visitas_hogares_inau_club_niños.csv
               Output/visitas_personas_inau_ctros_juveniles.csv
               Output/visitas_hogares_inau_ctros_juveniles.csv
               Output/visitas_personas_mid_asist_vejez.csv
               Output/visitas_hogares_mid_asist_vejez.csv
               Output/visitas_personas_mides_canasta_serv.csv
               Output/visitas_hogares_mides_canasta_serv.csv
               Output/visitas_personas_mides_jer.csv
               Output/visitas_hogares_mides_jer.csv
               Output/visitas_personas_mides_cercanias.csv
               Output/visitas_hogares_mides_cercanias.csv
               Output/visitas_personas_mides_ucc.csv
               Output/visitas_hogares_mides_ucc.csv
               Output/visitas_personas_mides_uy_trab.csv
               Output/visitas_hogares_mides_uy_trab.csv
               Output/visitas_personas_mides_monotributo.csv
               Output/visitas_hogares_mides_monotributo.csv
               Output/visitas_personas_mides_inda_snc.csv
               Output/visitas_hogares_mides_inda_snc.csv
               Output/visitas_personas_mides_inda_paec.csv
               Output/visitas_hogares_mides_inda_paec.csv
               Output/visitas_personas_mides_inda_panrn.csv
               Output/visitas_hogares_mides_inda_panrn.csv
               Temp/check_prog_soc_siias.tex

10) Objective: Checkear base de solicitud de visitas (y cotejarla con proxy 
               Lagaixo de visita solicitada) y armar archivo con solicitudes 
               de visitas y datos mínimos de las personas en la visita
    Code:      Code/10_sol_visitas.py
    Input:     Input/pedido_lihuen/producto_3_enmascarado.csv
               Output/visitas_personas_vars.csv
               Output/visitas_hogares_vars.csv
    Output:    Output/sol_visitas_personas.csv
               Temp/check_sol_visitas.tex
               
11) Objective: Armar base para estimar peer effects.
    Code:      Code/11a_identificar_barrios.R
               Code/11b_cambios_en_peers.R
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_hogares_TUS.csv
    Output:    Output/11b_cambios_peers_*: 14 bases wide con cambios en peers (pérdidas/ganancias de tarjetas/hogares), según distintas especificaciones de vecinos (m/n) y robustez 

12) Objective: Checkear y armar base con historico de llegadas a puerta
    Code:      Code/12_llegadas_puerta.py
    Input:     Input/pedido_lihuen/producto_2v2_enmascarado_sin_dup
               Output/visitas_personas_vars.csv
               Output/visitas_hogares_vars.csv
    Output:    Output/llegadas_puerta.csv
               Temp/check_llegadas_puerta.tex

13) Objective: Armar .tex agregando todos los chequeos hechos en la sección
               del build
    Code:      Code/13_checks_build.py
    Input:     Temp/check_TUS.tex
               Temp/check_AFAM.tex
               Temp/check_PP.tex
               Temp/check_Susp.tex
               Temp/check_CNV.tex
               Temp/check_educ_siias.tex
               Temp/check_BPS_SIIAS.tex
               Temp/check_prog_soc_siias.tex
               Temp/check_sol_visitas.tex
               Temp/check_llegadas_puerta.tex
    Output:    Output/check_build.tex

14) Objective: Mover bases (.csv y .dta) generadas de Output del Build al 
               Input de Analysis
    Code:      Code/14_move_build_analysis.py
    Input:     Output/visitas_hogares_vars.csv
               Output/visitas_hogares_vars.dta
               Output/visitas_personas_vars.csv
               Output/visitas_personas_vars.dta
               Output/visitas_hogares_PPySusp.csv
               Output/visitas_hogares_PPySusp.dta
               Output/visitas_personas_PPySusp.csv
               Output/visitas_personas_PPySusp.dta
               Output/visitas_hogares_TUS.csv
               Output/visitas_hogares_TUS.dta
               Output/visitas_personas_TUS.csv
               Output/visitas_personas_TUS.dta
               Output/visitas_hogares_AFAM.csv
               Output/visitas_hogares_AFAM.dta
               Output/visitas_personas_AFAM.csv
               Output/visitas_personas_AFAM.dta
               Output/BPS_SIIAS_hogares.csv
               Output/BPS_SIIAS_hogares.dta
               Output/BPS_SIIAS_personas.csv
               Output/BPS_SIIAS_personas.dta
    Output:    ..Analysis/Input/MIDES/visitas_hogares_vars.csv
               ..Analysis/Input/MIDES/visitas_hogares_vars.dta
               ..Analysis/Input/MIDES/visitas_personas_vars.csv
               ..Analysis/Input/MIDES/visitas_personas_vars.dta
               ..Analysis/Input/MIDES/visitas_hogares_PPySusp.csv
               ..Analysis/Input/MIDES/visitas_hogares_PPySusp.dta
               ..Analysis/Input/MIDES/visitas_personas_PPySusp.csv             
               ..Analysis/Input/MIDES/visitas_personas_PPySusp.dta
               ..Analysis/Input/MIDES/visitas_hogares_TUS.csv
               ..Analysis/Input/MIDES/visitas_hogares_TUS.dta
               ..Analysis/Input/MIDES/visitas_personas_TUS.csv               
               ..Analysis/Input/MIDES/visitas_personas_TUS.dta
               ..Analysis/Input/MIDES/visitas_hogares_AFAM.csv
               ..Analysis/Input/MIDES/visitas_hogares_AFAM.dta
               ..Analysis/Input/MIDES/visitas_personas_AFAM.csv              
               ..Analysis/Input/MIDES/visitas_personas_AFAM.dta
               ..Analysis/Input/MIDES/BPS_SIIAS_hogares.csv
               ..Analysis/Input/MIDES/BPS_SIIAS_hogares.dta
               ..Analysis/Input/MIDES/BPS_SIIAS_personas.csv
               ..Analysis/Input/MIDES/BPS_SIIAS_personas.dta


****************************** ANALYSIS ***************************************

0)  Objective: Chequeo de cómo altas y bajas al TUS y AFAM se dieron como función
               del ICC u otros motivos como ser edad, participación en programas MIDES
    Code:      Code/0_check_first_stage.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
    Output:    Output/0_check_first_stage.tex


1)  Objective: Mirar first stage en TUS tanto para perder, ganar y 
               duplicar beneficio.
    Code:      Code/1_tus_first_stage.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
    Output:    
               
2)  Objective: Mirar second stage de impacto TUS en PP.
    Code:      Code/2_tus_PP.py
               Code/2_tus_PP.do
    Input:     Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_personas_PPySusp.csv
    Output:    

3)  Objective: Mirar second stage de impacto TUS en suspendidos educativos.
    Code:      Code/3_tus_suspendidos.py
    Input:     Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_personas_PPySusp.csv
    Output:              

4)  Objective: Mirar second stage de impacto TUS en variables de base visitas 
               y balance re-visitas y no re-visitados (para hogares revistados).
    Code:      Code/4_tus_vars_revistadas.do
               Code/4_tus_vars_revistadas.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
               Input/MIDES/visitas_personas_vars.csv
    Output:  
            
5)  Objective: Armar basic summary statstics de las bases de visitas, TUS, AFAM,
               BPS-SIIAS, Educ-CIIAS, CNV-SIIAS, Prog-Sociales-SIIAS.
    Code:      Code/5_summary_stats.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
               Input/MIDES/visitas_personas_vars.csv
               Input/MIDES/visitas_personas_PPySusp.csv
               Input/IPC_TC.xlsx
    Output: 

            
6)  Objective: Poner visitas en un mapa y poner colores con si luego de visita
               se perdió, ganó, duplicó, mantuvo 1 o mantuvo 2, etc transferencias
               y si son censales o recorrido tipo, etc
    Code:      Code/6_mapa_visitas.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
               Input/MIDES/visitas_personas_vars.csv        
    Output: 
        
7)  Objective: Generar variables de lo que "sucedió" en tu barrio.
    Code:      Code/7_gen_variables_nbd.do
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_hogares_vars.csv
               Input/MIDES/visitas_personas_vars.csv           
    Output: 
        
9)  Objective: Mirar impactos por meses antes y después de visita con variables AFAM.
    Code:      Code/9_tus_envars_afam.py
    Input:     Input/MIDES/visitas_hogares_TUS.csv
               Input/MIDES/visitas_personas_TUS.csv
               Input/MIDES/visitas_hogares_AFAM.csv
               Input/MIDES/visitas_personas_AFAM.csv        
    Output:

10) Objective: Mirar impactos ganar/perder en revisitas para grupos 
               con mismos inobservables
    Code:      Code/10_revisitados_inobservables.py
               Code/10_revisitados_inobservables.do
    Input:     Temp/vars_personas_revisitadas.csv         
    Output:

11) Objective: Mirar second stage de impacto TUS en BPS-SIIAS.
    Code:      Code/11a_bps_siias_RDD.py
               Code/11b_bps_siias_RDD.do
               Code/11c_bps_siias_DID.do
               Code/11d_bps_siias_stata_graphs.py
               Code/11e_bps_siias_latex.py
    Input:     Input/MIDES/BPS_SIIAS_hogares.csv
               Input/MIDES/BPS_SIIAS_personas.csv         
    Output:    Output/11_bps_siias.tex
      
12) Objective: Mirar second stage de impacto TUS en Educ-SIIAS y en gap ("mentira")
               en educación declarada y según datos SIIAS.
    Code:      Code/12a_educ_siias_RDD.py
               Code/12b_educ_siias_RDD.do
               Code/12c_educ_siias_DID.do
               Code/12d_educ_siias_stata_graphs.py
               Code/12e_educ_siias_latex.py
    Input:     Input/MIDES/visitas_hogares_educ_siias.csv
               Input/MIDES/visitas_personas_educ_siias.csv       
    Output:    Output/12_educ_siias.tex
        
13) Objective: Mirar second stage de impacto TUS en CNV-SIIAS.
    Code:      Code/13_cnv_siias.py
               Code/13_cnv_siias.do
    Input:     Input/MIDES/visitas_hogares_cnv_siias.csv
               Input/MIDES/visitas_personas_cnv_siias.csv        
    Output:    Output/13_cnv_siias.tex
        
14) Objective: Mirar second stage de impacto TUS en Programas Sociales-SIIAS.
    Code:      Code/14a_prog_soc_siias_RDD.py
               Code/14b_prog_soc_siias_RDD.do
               Code/14c_prog_soc_siias_DID.do
               Code/14d_prog_soc_siias_stata_graphs.py
               Code/14e_prog_soc_siias_latex.py
    Input:     Input/MIDES/visitas_hogares_prog_soc_siias.csv
               Input/MIDES/visitas_personas_prog_soc_siias.csv         
    Output:    Output/14_prog_soc_siias.tex
 
15) Objective: Mirar second stage de impacto TUS en solicitudes de visitas
    Code:      Code/15_sol_visitas.py
    Input:     Input/MIDES/sol_visitas_personas.csv

    Output:
        
16) Objective: Mirar second stage de impacto TUS en variables recogidas al momento de
               la visita considerando peer effects
    Code:      Code/16_peer_effects_visita.
    Input:     Input/MIDES/.csv
               Input/MIDES/.csv
    Output:    Output/
    
17) Objective: Mirar second stage de impacto TUS en PP considerando peer effects.
    Code:      Code/16_peer_effects_PP.
    Input:     Input/MIDES/.csv
               Input/MIDES/.csv
    Output:    Output/
 
        
'''
