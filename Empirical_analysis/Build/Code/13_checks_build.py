import os, shutil, sys

### Set path
try:
    os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Alejandro')
    directory = 'C:/Alejandro/Research/MIDES/Empirical_analysis/Build/Temp'
except: pass
try:
    os.chdir('/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Lihuen')
    directory = '/Users/lihuennocetto/Dropbox/mides_local_processing/mides/Empirical_analysis/Build/Temp'
except: pass
try:
    os.chdir('/home/andres/gdrive/mides/Empirical_analysis/Build/Temp') # Set current directory
    print('Script corrido en computadora de Andres')
    directory = '/home/andres/gdrive/mides/Empirical_analysis/Build/Temp'
except: pass



### Armo archivo de LaTex que quiero generar
checksBuildTex = open('../Output/check_build.tex', 'w')
checksBuildTex.write('\documentclass[12pt]{article} \n')
checksBuildTex.write('\\usepackage{float} \n')
checksBuildTex.write('\\usepackage{amstext} \n')
checksBuildTex.write('\\usepackage{pdfpages} \n')
checksBuildTex.write('\\usepackage{footnote} \n')
checksBuildTex.write('\\usepackage[skip=0pt]{caption} \n')
checksBuildTex.write('\\usepackage{lscape} \n')
checksBuildTex.write('\\usepackage{longtable} \n')
checksBuildTex.write('\\usepackage{lscape} \n')
checksBuildTex.write('\\usepackage{subfig} \n')
checksBuildTex.write('\\usepackage{natbib} \n')
checksBuildTex.write('\\usepackage{amsmath} \n')
checksBuildTex.write('\\usepackage{amsthm} \n')
checksBuildTex.write('\\usepackage{amssymb} \n')
checksBuildTex.write('\\usepackage{amsfonts} \n')
checksBuildTex.write('\\usepackage[utf8]{inputenc} \n')
checksBuildTex.write('\\usepackage{booktabs} \n')
checksBuildTex.write('\\usepackage[left=3cm,top=2cm,right=3cm,bottom=2cm]{geometry} \n')
checksBuildTex.write('\\usepackage{graphicx} \n')
checksBuildTex.write('\\title{MIDES Education-SIIAS: Checks del Build} \n')
checksBuildTex.write('\\author{Alejandro Lagomarsino \& Lihuen Nocetto} \n')
checksBuildTex.write('\linespread{1.3} \n')
checksBuildTex.write('\setlength{\parindent}{0pt} \n')
checksBuildTex.write('\setlength{\parskip}{1ex plus 0.5ex minus 0.2ex} \n')
checksBuildTex.write('\\addtolength{\\textwidth}{4cm} \n')
checksBuildTex.write('\\addtolength{\hoffset}{-2cm} \n')
checksBuildTex.write('\graphicspath{ {' + directory + '/} } \n')
checksBuildTex.write('\\begin{document} \n')
checksBuildTex.write('\maketitle \n')

checksBuildTex.write('\section{Education SIIAS} \n')
checksBuildTex.write('\input{' + directory + '/check_Educ_SIIAS.txt} \n')
              
checksBuildTex.write('\section{BPS SIIAS} \n')
checksBuildTex.write('\input{' + directory + '/check_BPS_SIIAS.txt} \n')

checksBuildTex.write('\end{document} \n')
checksBuildTex.close()