''' 
Script that explains flow of programs to perform empirical analysis over MIDES dataset

********************************** BUILD **************************************

1)  Objective: Limpiar bases de visitas y tener un archivo con todas las variables
               de visitas a nivel de hogar y otro de personas
    Code:      Code\1_cleaning_visitas.do
    Input:     Input\Visitas_Hogares_Muestra_enmascarado.csv
               Input\Visitas_Personas_Muestra_enmascarado.csv
    Output:    Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv

2)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos completos de TUS
    Code:      Code\2_visitas_TUS.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\TUS_Muestra_enmascarado.csv
    Output:    Output\visitas_hogares_TUS.csv
               Output\visitas_personas_TUS.csv

3)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos completos de AFAM
    Code:      Code\3_visitas_AFAM
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Input\AFAM_enmascarado (todas las 13 carpetas)
    Output:    Output\visitas_hogares_AFAM.csv
               Output\visitas_personas_AFAM.csv

4)  Objective: Generar dos archivos (hogares y personas) con datos mínimos de las
               visitas y datos PP y suspendidos educativos
    Code:      Code\4_visitas_PPySusp.do
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Output\PP_Muestra_enmascarado
               Output\Suspendidos_Muestra_enmascarado
    Output:    Output\visitas_hogares_PPySusp.csv
               Output\visitas_personas_PPySusp.csv

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

6)  Objective: Merge variables AFAM, TUS, PP y suspendidos educativos en una misma base.
    Code:      Code\6_bases_sin_datos_visitas.do
    Input:     Output\visitas_hogares_TUS.csv
               Output\visitas_personas_TUS.csv
               Output\visitas_hogares_AFAM.csv
               Output\visitas_personas_AFAM.csv
               Output\visitas_hogares_PPySusp.csv
               Output\visitas_personas_PPySusp.csv
    Output:    Output\visitas_hogares_otras_vars.csv
               Output\visitas_personas_otras_vars.csv

7)  Objective: Mover bases generadas de Output del Build al Input de Analysis
    Code:      Code\7_move_build_analysis.py
    Input:     Output\visitas_hogares_vars.csv
               Output\visitas_personas_vars.csv
               Output\visitas_hogares_otras_vars.csv
               Output\visitas_personas_otras_vars.csv
               Output\visitas_hogares_PPySusp.csv
               Output\visitas_personas_PPySusp.csv
               Output\visitas_hogares_AFAM.csv
               Output\visitas_personas_AFAM.csv
               Output\visitas_hogares_TUS.csv
               Output\visitas_hogares_TUS.csv
    Output:    ..Analysis\Input\visitas_hogares_vars.csv
               ..Analysis\Input\visitas_personas_vars.csv
               ..Analysis\Input\visitas_hogares_otras_vars.csv
               ..Analysis\Input\visitas_personas_otras_vars.csv
               ..Analysis\Input\visitas_hogares_PPySusp.csv
               ..Analysis\Input\visitas_personas_PPySusp.csv
               ..Analysis\Input\visitas_hogares_AFAM.csv
               ..Analysis\Input\visitas_personas_AFAM.csv
               ..Analysis\Input\visitas_hogares_TUS.csv
               ..Analysis\Input\visitas_hogares_TUS.csv


****************************** ANALYSIS ***************************************

1)  Objective: Mirar first stage en TUS tanto para perder, ganar y 
               duplicar beneficio.
    Code:      Code\1_tus_first_stage.py
    Input:     Input\visitas_hogares_TUS.csv
               Input\visitas_hogares_vars.csv
    Output:    
               
2)  Objective: Mirar second stage de impacto TUS en PP.
    Code:      Code\2_tus_PP.py
               Code\2_tus_PP.do
    Input:     Input\visitas_personas_TUS.csv
               Input\visitas_personas_PPySusp.csv
    Output:    

3)  Objective: Mirar second stage de impacto TUS en suspendidos educativos.
    Code:      Code\3_tus_suspendidos.py
    Input:     Input\visitas_personas_TUS.csv
               Input\visitas_personas_PPySusp.csv
    Output:              

4)  Objective: Mirar second stage de impacto TUS en variables de base visitas 
               (para hogares revistados censalmenete).
    Code:      Code\4_tus_vars_revistadas.py
    Input:     Input\visitas_hogares_TUS.csv
               Input\visitas_personas_TUS.csv
               Input\visitas_hogares_vars.csv
               Input\visitas_personas_vars.csv
    Output:              
        
'''

as