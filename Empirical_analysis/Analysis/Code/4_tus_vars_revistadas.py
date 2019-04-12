import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
import scipy
#from ggplot import *

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

# Cargo base de personas y elimino variables que no interesan
df = pd.read_csv('vars_personas_revisitadas.csv')

# Defino numero de bins y cosas asi
bins=20

# Genero variables
df['montevideoOne'] = df['departamentoOne'].where(df['departamentoOne'] == 1, other = 0)
# Elimino personas que no fueron re-vistadas censalmente

# Genero variable que sea valor en NEXT visita censal
#df['censalTwo'] = 0
#df['censalTwo'] = df['censalTwo'].where(df['templateTwo']=="Visita por CI", 1)
#df['censalThree'] = 0
#df['censalThree'] = df['censalThree'].where(df['templateThree']=="Visita por CI", 1)
#df['censalTwoOrThree'] = df['censalTwo'] + df['censalThree']
#df['censalTwoOrThree'] = df['censalTwoOrThree'].where(df['censalTwoOrThree']==0, 1)

### Ver que hay balance entre revisitados y no-revisitados

## Ver tabla balance para slides
dictPptBalancesIndex = {0.1: '010'}
dictPptBalances = {0.1: '010'}

for i in [0.1]:
    dictPptBalances[i] = pd.DataFrame(data={'UCT = 0': [0.00], 'UCT = 1': [0.00]}, index=['Age'])
    
    # Age
    dictPptBalances[i].at['Age','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictPptBalances[i].at['Age','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)

    # Years of education
    dictPptBalances[i].at['Yrs of educ','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)

    # Years of education of adults in household
    dictPptBalances[i].at['Yrs of educ (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    
    # Adults unemployed
    dictPptBalances[i].at['Unemployed (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    dictPptBalances[i].at['Unemployed (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    
    # Adults employed in private
    dictPptBalances[i].at['Employed priv. (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
    dictPptBalances[i].at['Employed priv. (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
   
    # Number of members in the household
    dictPptBalances[i].at['Members in household','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    dictPptBalances[i].at['Members in household','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    
    # Gender
    dictPptBalances[i].at['Male','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
    dictPptBalances[i].at['Male','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
 
    # sinalimentos
    dictPptBalances[i].at['No food','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    dictPptBalances[i].at['No food','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    
    # adultonocomio
    dictPptBalances[i].at['No food for adults','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for adults','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    
    # menornocomio
    dictPptBalances[i].at['No food for minors','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for minors','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)

    # Montevideo
    dictPptBalances[i].at['Montevideo','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
    dictPptBalances[i].at['Montevideo','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
  
    with open('../Output/balPptSinConTusPrimVisita' + dictPptBalancesIndex[i] + '.tex','w') as tf:
        tf.write(dictPptBalances[i].to_latex(bold_rows=True, longtable=True))



## Ver tabla balance para slides
dictPptBalancesIndex = {0.1: '010'}
dictPptBalances = {0.1: '010'}

for i in [0.1]:
    dictPptBalances[i] = pd.DataFrame(data={'UCT = 0': [0.00], 'UCT = 1': [0.00], 'p-value': [0.00]}, index=['Age'])
    
    # Age
    dictPptBalances[i].at['Age','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictPptBalances[i].at['Age','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictPptBalances[i].at['Age','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['edad_visitaOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], equal_var=False)[1], 2)

    # Years of education
    dictPptBalances[i].at['Yrs of educ','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['anosEducOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['anosEducOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'], equal_var=False)[1], 2)

    # Years of education of adults in household
    dictPptBalances[i].at['Yrs of educ (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    dictPptBalances[i].at['Yrs of educ (adults)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogAnosEducAdultsOne'].isna() == False) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['hogAnosEducAdultsOne'].isna() == False) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'], equal_var=False)[1], 2)
    
    # Adults unemployed
    dictPptBalances[i].at['Unemployed (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    dictPptBalances[i].at['Unemployed (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    dictPptBalances[i].at['Unemployed (adults)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['desocupadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['desocupadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'], equal_var=False)[1], 2)
    
    # Adults employed in private
    dictPptBalances[i].at['Employed priv. (adults)','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
    dictPptBalances[i].at['Employed priv. (adults)','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
    dictPptBalances[i].at['Employed priv. (adults)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['emp_privadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['emp_privadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'], equal_var=False)[1], 2)
   
    # Number of members in the household
    dictPptBalances[i].at['Members in household','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    dictPptBalances[i].at['Members in household','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    dictPptBalances[i].at['Members in household','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogmiembrosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['hogmiembrosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'], equal_var=False)[1], 2)
    
    # Number of minors in the household
    dictPptBalances[i].at['Minors in household','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'].mean(), 2)
    dictPptBalances[i].at['Minors in household','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'].mean(), 2)
    dictPptBalances[i].at['Minors in household','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogmiembrosMenoresOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['hogmiembrosMenoresOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'], equal_var=False)[1], 2)
    
    # Gender
    dictPptBalances[i].at['Male','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
    dictPptBalances[i].at['Male','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
    dictPptBalances[i].at['Male','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hombreOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['hombreOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'], equal_var=False)[1], 2)
 
    # sinalimentos
    dictPptBalances[i].at['No food','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    dictPptBalances[i].at['No food','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    dictPptBalances[i].at['No food','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['sinalimentosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['sinalimentosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'], equal_var=False)[1], 2)
    
    # adultonocomio
    dictPptBalances[i].at['No food for adults','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for adults','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for adults','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['adultonocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['adultonocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'], equal_var=False)[1], 2)
    
    # menornocomio
    dictPptBalances[i].at['No food for minors','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for minors','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)
    dictPptBalances[i].at['No food for minors','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['menornocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['menornocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'], equal_var=False)[1], 2)

    # Montevideo
    dictPptBalances[i].at['Montevideo','UCT = 0'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
    dictPptBalances[i].at['Montevideo','UCT = 1'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
    dictPptBalances[i].at['Montevideo','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['montevideoOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogarZerotusDobleOne'] == 0) & (df['montevideoOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'], equal_var=False)[1], 2)
  
    with open('../Output/balPptSinConTusPrimVisita' + dictPptBalancesIndex[i] + '.tex','w') as tf:
        tf.write(dictPptBalances[i].to_latex(bold_rows=True, longtable=True))

## Ver balance (para primera visita) entre aquellos con UCT=1 (o más), 0 en primer visita para aquellos en umbral 0.05, 0.10, 0.20, total
dictBalancesIndex = {1: 'Glob', 0.2: '020', 0.1: '010', 0.05: '005'}
dictBalances = {1: 'Glob', 0.2: '020', 0.1: '010', 0.05: '005'}

for i in [1, 0.2, 0.1, 0.05]:
    dictBalances[i] = pd.DataFrame(data={'Mean (UCT = 0)': [0], 'Mean (UCT > 0)': [0], 'p-value': [0]}, index=['Age (1st visit)'])
    
    # Age
    dictBalances[i].at['Age (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictBalances[i].at['Age (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictBalances[i].at['Age (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['edad_visitaOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], equal_var=False)[1], 2)

    # Years of education
    dictBalances[i].at['Years of education (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)
    dictBalances[i].at['Years of education (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'].mean(), 2)
    dictBalances[i].at['Years of education (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['anosEducOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['anosEducOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['anosEducOne'], equal_var=False)[1], 2)

    # Years of education of adults in household
    dictBalances[i].at['Years of education of adults (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    dictBalances[i].at['Years of education of adults (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'].mean(), 2)
    dictBalances[i].at['Years of education of adults (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogAnosEducAdultsOne'].isna() == False) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogAnosEducAdultsOne'].isna() == False) & (df['jefeOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogAnosEducAdultsOne'], equal_var=False)[1], 2)
    
    # Adults unemployed
    dictBalances[i].at['Unemployed, for adults>=18 (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    dictBalances[i].at['Unemployed, for adults>=18 (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'].mean(), 2)
    dictBalances[i].at['Unemployed, for adults>=18 (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['desocupadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['desocupadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['desocupadoOne'], equal_var=False)[1], 2)
    
    # Adults employed in private
    dictBalances[i].at['Employed private, for adults>=18 (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
    dictBalances[i].at['Employed private, for adults>=18 (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'].mean(), 2)
    dictBalances[i].at['Employed private, for adults>=18 (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['emp_privadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['emp_privadoOne'].isna() == False) & (df['edad_visitaOne']>=18) & (df['iccNormPrimerTusOne'].abs() < i)]['emp_privadoOne'], equal_var=False)[1], 2)
    
    # Number of members in the household
    dictBalances[i].at['Members in household (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    dictBalances[i].at['Members in household (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'].mean(), 2)
    dictBalances[i].at['Members in household (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogmiembrosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogmiembrosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosOne'], equal_var=False)[1], 2)
    
    # Number of minors in the household
    dictBalances[i].at['Minors in household (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'].mean(), 2)
    dictBalances[i].at['Minors in household (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'].mean(), 2)
    dictBalances[i].at['Minors in household (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogmiembrosMenoresOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogmiembrosMenoresOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogmiembrosMenoresOne'], equal_var=False)[1], 2)
    
    # Gender
    dictBalances[i].at['Male (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
    dictBalances[i].at['Male (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'].mean(), 2)
    dictBalances[i].at['Male (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hombreOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hombreOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hombreOne'], equal_var=False)[1], 2)
    
    # Year of first visit
    dictBalances[i].at['Year (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'].mean(), 2)
    dictBalances[i].at['Year (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'].mean(), 2)
    dictBalances[i].at['Year (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['yearOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['yearOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'], equal_var=False)[1], 2)
    
    # Probability of being visited at least twice
    dictBalances[i].at['Visited at least twice','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['visita2'].mean(), 2)
    dictBalances[i].at['Visited at least twice','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['visita2'].mean(), 2)
    dictBalances[i].at['Visited at least twice','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['visita2'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['visita2'], df[(df['hogarZerocobraTusOne'] == 1) & (df['visita2'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['visita2'], equal_var=False)[1], 2)
    
    # ICC
    dictBalances[i].at['VI (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['iccOne'].mean(), 2)
    dictBalances[i].at['VI (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['iccOne'].mean(), 2)
    dictBalances[i].at['VI (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['iccOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['iccOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['iccOne'], equal_var=False)[1], 2)
    
    # Probability of pregnancies (among women less than 35 years old)
    dictBalances[i].at['Pregnant, for woman <35 (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['hombreOne'] == 0) & (df['edad_visitaOne']<35) & (df['iccNormPrimerTusOne'].abs() < i)]['embarazadaOne'].mean(), 2)
    dictBalances[i].at['Pregnant, for woman <35 (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['hombreOne'] == 0) & (df['edad_visitaOne']<35) & (df['iccNormPrimerTusOne'].abs() < i)]['embarazadaOne'].mean(), 2)
    dictBalances[i].at['Pregnant, for woman <35 (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['embarazadaOne'].isna() == False) & (df['hombreOne'] == 0) & (df['edad_visitaOne']<35) & (df['iccNormPrimerTusOne'].abs() < i)]['embarazadaOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['embarazadaOne'].isna() == False) & (df['hombreOne'] == 0) & (df['edad_visitaOne']<35) & (df['iccNormPrimerTusOne'].abs() < i)]['embarazadaOne'], equal_var=False)[1], 2)
    
    # Year of second visit (among those revisited at least twice)
    dictBalances[i].at['Year (2nd visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['yearTwo'].mean(), 2)
    dictBalances[i].at['Year (2nd visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['yearTwo'].mean(), 2)
    dictBalances[i].at['Year (2nd visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['yearTwo'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['yearTwo'], df[(df['hogarZerocobraTusOne'] == 1) & (df['yearTwo'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['yearTwo'], equal_var=False)[1], 2)

    # Self-reported income
    dictBalances[i].at['Income, excluding transfers (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['ingtotsintransfOne'].mean(), 2)
    dictBalances[i].at['Income, excluding transfers (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['ingtotsintransfOne'].mean(), 2)
    dictBalances[i].at['Income, excluding transfers (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['ingtotsintransfOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['ingtotsintransfOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['ingtotsintransfOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['ingtotsintransfOne'], equal_var=False)[1], 2)
    
    # Self reported income of the household they live in
    dictBalances[i].at['Household Income, excluding transfers (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['hogingtotsintransfOne'].mean(), 2)
    dictBalances[i].at['Household Income, excluding transfers (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['hogingtotsintransfOne'].mean(), 2)
    dictBalances[i].at['Household Income, excluding transfers (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['hogingtotsintransfOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogingtotsintransfOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['hogingtotsintransfOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['hogingtotsintransfOne'], equal_var=False)[1], 2)
    
    # Number of individuals
    dictBalances[i].at['N individuals (count, not mean)','Mean (UCT = 0)'] = df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'].size
    dictBalances[i].at['N individuals (count, not mean)','Mean (UCT > 0)'] = df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['yearOne'].size
    dictBalances[i].at['N individuals (count, not mean)','p-value'] = 'nan'
    
    # Age of household head
    dictBalances[i].at['Age of head','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['jefeOne']==1) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictBalances[i].at['Age of head','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['jefeOne']==1) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'].mean(), 2)
    dictBalances[i].at['Age of head','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['edad_visitaOne'].isna() == False) & (df['jefeOne']==1) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['edad_visitaOne'].isna() == False) & (df['jefeOne']==1) & (df['iccNormPrimerTusOne'].abs() < i)]['edad_visitaOne'], equal_var=False)[1], 2)
    
    # sinalimentos
    dictBalances[i].at['No food (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    dictBalances[i].at['No food (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'].mean(), 2)
    dictBalances[i].at['No food (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['sinalimentosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['sinalimentosOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['sinalimentosOne'], equal_var=False)[1], 2)
    
    # adultonocomio
    dictBalances[i].at['No food for adults (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    dictBalances[i].at['No food for adults (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'].mean(), 2)
    dictBalances[i].at['No food for adults (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['adultonocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['adultonocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['adultonocomioOne'], equal_var=False)[1], 2)
    
    # menornocomio
    dictBalances[i].at['No food for minors (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)
    dictBalances[i].at['No food for minors (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'].mean(), 2)
    dictBalances[i].at['No food for minors (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['menornocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['menornocomioOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['menornocomioOne'], equal_var=False)[1], 2)

    # Montevideo
    dictBalances[i].at['Montevideo (1st visit)','Mean (UCT = 0)'] = round(df[(df['hogarZerocobraTusOne'] == 0) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
    dictBalances[i].at['Montevideo (1st visit)','Mean (UCT > 0)'] = round(df[(df['hogarZerocobraTusOne'] == 1) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'].mean(), 2)
    dictBalances[i].at['Montevideo (1st visit)','p-value'] = round(scipy.stats.ttest_ind(df[(df['hogarZerocobraTusOne'] == 0) & (df['montevideoOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'], df[(df['hogarZerocobraTusOne'] == 1) & (df['montevideoOne'].isna() == False) & (df['iccNormPrimerTusOne'].abs() < i)]['montevideoOne'], equal_var=False)[1], 2)

    with open('../Output/balSinConTusPrimVisita' + dictBalancesIndex[i] + '.tex','w') as tf:
        tf.write(dictBalances[i].to_latex(bold_rows=True, longtable=True))


### Tzachi falsifictaion test
xLinspace=np.arange(-0.3, 0.3, 0.02)  # It will give me the first value of every bin
yBins=np.ones((30,1))               # The share of household with TUS in every bin
        
for i in range(30-1):
    yBins[i]=df['sinalimentosOne'][(df['iccNormPrimerTustwo']>=xLinspace[i]) & (df['iccNormPrimerTustwo']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('')
plt.xlabel('Vulnerability Index - First threshold (2nd visit)')
plt.title(' during 1st visit')
plt.savefig('../Output/sinalimentosOneFals.pdf')
plt.show()


#### Impact en variables medidas post 1ra visita
### First stage
# Para todos
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))              
        
for i in range(bins-1):
    yBins[i]=df['hogarMascobraTus12One'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with UCT 1yr after 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('UCT, 1yr after 1st visit')
plt.savefig('../Output/hogarMascobraTus12One.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))              
        
for i in range(bins-1):
    yBins[i]=df['hogarZerocobraTusNext'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with UCT during next area visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('UCT during next area visit')
plt.savefig('../Output/hogarZerocobraTusNext.pdf')
plt.show()

# Para quienes inicialmente no recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogarZerocobraTusNext'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==0)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with UCT during next area visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('UCT during next area visit (for those with UCT = 0)')
plt.savefig('../Output/hogarZerocobraTusNext0.pdf')
plt.show()

# Para quienes inicialmente recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogarZerocobraTusNext'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with UCT during next area visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('UCT during next area visit (for those with UCT > 0)')
plt.savefig('../Output/hogarZerocobraTusNext1o2.pdf')
plt.show()

### Revisited por iniciativa del gobierno
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['revisitedPorGovOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on a "non-requested" visit after 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. revisited on a "non-requested" visit after 1st visit')
plt.savefig('../Output/revisitedPorGovOne.pdf')
plt.show()


### Se visita más a los hogares que perdieron TUS?
# Para todos
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['visita2'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with 2 visits')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2 visits')
plt.savefig('../Output/visita2.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['visita2'][(df['iccNormSegundoTusOne']>=xLinspace[i]) & (df['iccNormSegundoTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with 2 visits')
plt.xlabel('Vulnerability Index - Second threshold (1st visit)')
plt.title('2 visits')
plt.savefig('../Output/visita2SecThre.pdf')
plt.show()

# Para aquellos que inicialmente no recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['visita2'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==0)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with 2 visits')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2 visits (for those with UCT = 0)')
plt.savefig('../Output/visita20.pdf')
plt.show()

# Para aquellos que inicialmente recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['visita2'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% with 2 visits')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2 visits (for those with UCT > 0)')
plt.savefig('../Output/visita21o2.pdf')
plt.show()

### La segunda visita que recibieron los hogares (para aquellos revisitados), fue más producto de un pedido si perdiero la TUS?
# Para todos
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['pedido_visitaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% where 2nd visit was requested')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2nd visit was requested')
plt.savefig('../Output/pedido_visitaTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['pedido_visitaTwo'][(df['iccNormSegundoTusOne']>=xLinspace[i]) & (df['iccNormSegundoTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% where 2nd visit was requested')
plt.xlabel('Vulnerability Index - Second threshold (1st visit)')
plt.title('2nd visit was requested')
plt.savefig('../Output/pedido_visitaTwoSecThre.pdf')
plt.show()

# Para aquellos que inicialmente no recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['pedido_visitaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==0)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% where 2nd visit was requested')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2nd visit was requested (for those with UCT = 0)')
plt.savefig('../Output/pedido_visitaTwo0.pdf')
plt.show()

# Para aquellos que inicialmente sí recibian TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['pedido_visitaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogarZerocobraTusOne']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% where 2nd visit was requested')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('2nd visit was requested (for those with UCT > 0)')
plt.savefig('../Output/pedido_visitaTwo1o2.pdf')
plt.show()

### Recibiste alguna revisita pedida post primer visita?
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['DpedidoRevisitedOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on a "requested" visit after 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. revisited on a "requested" visit after 1st visit')
plt.savefig('../Output/DpedidoRevisitedOne.pdf')
plt.show()

### Se visita más censalmente a aquellos que perdieron TUS?
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['censalRevisit'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on an area visit adter 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. revisited on an area visit adter 1st visit')
plt.savefig('../Output/censalRevisit.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['censalRevisit'][(df['iccNormSegundoTusOne']>=xLinspace[i]) & (df['iccNormSegundoTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on an area visit adter 1st visit')
plt.xlabel('Vulnerability Index - Second threshold (1st visit)')
plt.title('Perc. revisited on an "area" visit adter 1st visit')
plt.savefig('../Output/censalRevisitSecThre.pdf')
plt.show()

### Se visita más censalmente Posta a aquellos que perdieron TUS?
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               
        
for i in range(bins-1):
    yBins[i]=df['censalPostaRevisit'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Revisited on a "real" area visit adter 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. revisited on a "real" area visit adter 1st visit')
plt.savefig('../Output/censalPostaRevisit.pdf')
plt.show()

### Miente AFAM
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               
        
for i in range(bins-1):
    yBins[i]=df['mienteHogAFAMTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual CCT transfer - Declared CCT transfer (2nd visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual CCT transfer - Declared CCT transfer during 2nd visit')
plt.savefig('../Output/mienteHogAFAMTwo.pdf')
plt.show()

### Miente AFAM (among those that declare something)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               
        
for i in range(bins-1):
    yBins[i]=df['mienteHogAFAMTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogingafamTwo']>0)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual CCT transfer - Declared CCT transfer (2nd visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual CCT transfer - Declared CCT transfer during 2nd visit (among those that declare some CCT amount)')
plt.savefig('../Output/mienteHogAFAMTwoFilter.pdf')
plt.show()

### Miente TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['mienteHogIngTarjetaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual UCT transfer - Declared UCT transfer (2nd visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual UCT transfer - Declared UCT transfer during 2nd visit')
plt.savefig('../Output/mienteHogIngTarjetaTwo.pdf')
plt.show()

### Ingreso del hogar
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogingtotsintransfTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Household income excluding transfer (LCU) (2nd visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Household income excluding transfer (LCU) during 2nd visit')
plt.savefig('../Output/hogingtotsintransfTwo.pdf')
plt.show()

### Asistencia a la escuela (asiste)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['asisteEscuelaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['edad_visitaTwo']<18)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Attends school')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of children (<18) attending school during 2nd visit')
plt.savefig('../Output/asisteEscuelaTwo.pdf')
plt.show()


### Jefe sigue siendo jefe?
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['jefeTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['jefeTwo'].isna()==False)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Household Head during 2nd visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Household head during 2nd visit (for household heads during 1st visit)')
plt.savefig('../Output/jefeTwo.pdf')
plt.show()

### Bienes durables
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienecalefonSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Calefon')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with calefon (2nd visit)')
plt.savefig('../Output/tienecalefonSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienerefrigeradorSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Fridge')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with fridge (2nd visit)')
plt.savefig('../Output/tienerefrigeradorSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetvcableSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Cable TV')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with cable TV (2nd visit)')
plt.savefig('../Output/tienetvcableSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienevideoSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Video')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with video (2nd visit)')
plt.savefig('../Output/tienevideoSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienelavarropasSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Washing machine')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with washing machine (2nd visit)')
plt.savefig('../Output/tienelavarropasSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienelavavajillaSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Dishwasher')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with dishwasher (2nd visit)')
plt.savefig('../Output/tienelavavajillaSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienemicroondasSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Microwave')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with microwave (2nd visit)')
plt.savefig('../Output/tienemicroondasSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienecomputadorSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Computer')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with computer during 2nd visit')
plt.savefig('../Output/tienecomputadorSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetelefonofijoSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Landline phone')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with landline phone during 2nd visit')
plt.savefig('../Output/tienetelefonofijoSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetelefonocelularSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Cell phone')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with cell phone during 2nd visit')
plt.savefig('../Output/tienetelefonocelularSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tieneautomovilSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Car')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with car during 2nd visit')
plt.savefig('../Output/tieneautomovilSiTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['computadorplanceibalSiTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% CEIBAL')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with CEIBAL during 2nd visit')
plt.savefig('../Output/computadorplanceibalSiTwo.pdf')
plt.show()

### Situación laboral 

### Toma medicación

### Self-reported income de varios tipos

### Welfare programs
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['canastaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with basket during 2nd visit')
plt.savefig('../Output/canastaTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['bajopesoTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% basket low weight')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with basket low weight during 2nd visit')
plt.savefig('../Output/bajopesoTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['otroTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% other basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with other basket during 2nd visit')
plt.savefig('../Output/otroTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['diabeticosrenalesTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% diabetes basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with diabetes basket during 2nd visit')
plt.savefig('../Output/diabeticosrenalesTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['merenderoTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% merendero')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. merendero during 2nd visit')
plt.savefig('../Output/merenderoTwo.pdf')
plt.show()

### Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['sinalimentosTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food" during 2nd visit')
plt.savefig('../Output/sinalimentosTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['adultonocomioTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Adults')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Adults" during 2nd visit')
plt.savefig('../Output/adultonocomioTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['menornocomioTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Minors')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Minors" during 2nd visit')
plt.savefig('../Output/menornocomioTwo.pdf')
plt.show()

## Violencia Doméstica
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with Domestic Violence during 2nd visit')
plt.savefig('../Output/vdTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdMujerTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with Domestic Violence towards women during 2nd visit')
plt.savefig('../Output/vdMujerTwo.pdf')
plt.show()

## Embarazada
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['embarazadaTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hombreOne']==0) & (df['edad_visitaTwo']<30)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Pregnant')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of pregnants (<30 yrs old) during 2nd visit')
plt.savefig('../Output/embarazadaTwo.pdf')
plt.show()


### Regularizado agua y UTE (aguacorriente, redelectrica)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['uteRegularizadoTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Regularized UTE')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. regularized UTE during 2nd visit')
plt.savefig('../Output/uteRegularizadoTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['oseRegularizadoTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Regularized OSE')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. regularized OSE during 2nd visit')
plt.savefig('../Output/oseRegularizadoTwo.pdf')
plt.show()


### Residuos cuadra y aguas contaminadas (residuoscuadra, aguascontaminadas)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['residuoscuadraTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Gargage on block')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Garbage on block during 2nd visit')
plt.savefig('../Output/residuoscuadraTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['aguascontaminadasTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Contaminated waters')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of contaminated waters during 2nd visit')
plt.savefig('../Output/aguascontaminadasTwo.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['indocumentadosTwo'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Number of undocumented')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Number of undocumented during 2nd visit')
plt.savefig('../Output/indocumentadosTwo.pdf')
plt.show()

#### Outcomes en 1ra visita como función de VI 1ra visita para aquellos visitados al menos dos veces

### Miente AFAM
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               
        
for i in range(bins-1):
    yBins[i]=df['mienteHogAFAMOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual CCT transfer - Declared CCT transfer (1st visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual CCT transfer - Declared CCT transfer during 1st visit (for those revisited)')
plt.savefig('../Output/mienteHogAFAMOne.pdf')
plt.show()

### Miente AFAM (among those that declare something)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               
        
for i in range(bins-1):
    yBins[i]=df['mienteHogAFAMOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hogingafamOne']>0) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual CCT transfer - Declared CCT transfer (1st visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual CCT transfer - Declared CCT transfer during 1st visit (among those that declare some CCT amount)')
plt.savefig('../Output/mienteHogAFAMOneFilter.pdf')
plt.show()

### Miente TUS
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['mienteHogIngTarjetaOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Actual UCT transfer - Declared UCT transfer (1st visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Actual UCT transfer - Declared UCT transfer during 1st visit')
plt.savefig('../Output/mienteHogIngTarjetaOne.pdf')
plt.show()

### Ingreso del hogar
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogingtotsintransfOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Household income excluding transfer (LCU) (1st visit)')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Household income excluding transfer (LCU) during 1st visit')
plt.savefig('../Output/hogingtotsintransfOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['hogingtotsintransfOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Ing. del hogar, excluye transf. (1er visita)')
plt.xlabel('ICC - Umbral TUS Simple (1er visita)')
#plt.title('Household income excluding transfer (LCU) during 1st visit')
plt.savefig('../Output/hogingtotsintransfOne.pdf')
plt.show()

### Asistencia a la escuela (asiste)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['asisteEscuelaOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['edad_visitaOne']<18)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Attends school')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of children (<18) attending school during 1st visit')
plt.savefig('../Output/asisteEscuelaOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['asisteEscuelaOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['edad_visitaOne']<18)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Asiste escuela')
plt.xlabel('ICC - Umbral TUS Simple (1er visita)')
#plt.title('Perc. of children (<18) attending school during 1st visit')
plt.savefig('../Output/asisteEscuelaOne.pdf')
plt.show()

### Jefe sigue siendo jefe?
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['jefeOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Household Head during 1st visit')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Household head during 1st visit')
plt.savefig('../Output/jefeOne.pdf')
plt.show()

### Bienes durables
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienecalefonSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Calefon')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with calefon (1st visit)')
plt.savefig('../Output/tienecalefonSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienerefrigeradorSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Fridge')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with fridge (1st visit)')
plt.savefig('../Output/tienerefrigeradorSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetvcableSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Cable TV')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with cable TV (1st visit)')
plt.savefig('../Output/tienetvcableSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienevideoSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Video')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with video (1st visit)')
plt.savefig('../Output/tienevideoSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienelavarropasSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Washing machine')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with washing machine (1st visit)')
plt.savefig('../Output/tienelavarropasSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienelavavajillaSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Dishwasher')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with dishwasher (1st visit)')
plt.savefig('../Output/tienelavavajillaSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienemicroondasSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Microwave')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with microwave (1st visit)')
plt.savefig('../Output/tienemicroondasSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienecomputadorSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Computadora')
plt.xlabel('ICC - Umbral TUS Simple (1er visita)')
#plt.title('Perc. with computer during 1st visit')
plt.savefig('../Output/tienecomputadorSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetelefonofijoSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Landline phone')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with landline phone during 1st visit')
plt.savefig('../Output/tienetelefonofijoSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienetelefonocelularSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Cell phone')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with cell phone during 1st visit')
plt.savefig('../Output/tienetelefonocelularSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tieneautomovilSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Car')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with car during 1st visit')
plt.savefig('../Output/tieneautomovilSiOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['computadorplanceibalSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% CEIBAL')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with CEIBAL during 1st visit')
plt.savefig('../Output/computadorplanceibalSiOne.pdf')
plt.show()

### Situación laboral 

### Toma medicación

### Self-reported income de varios tipos

### Welfare programs
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['canastaOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with basket during 1st visit')
plt.savefig('../Output/canastaOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['bajopesoOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% basket low weight')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with basket low weight during 1st visit')
plt.savefig('../Output/bajopesoOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['otroOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% other basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with other basket during 1st visit')
plt.savefig('../Output/otroOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['diabeticosrenalesOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% diabetes basket')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with diabetes basket during 1st visit')
plt.savefig('../Output/diabeticosrenalesOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['merenderoOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% merendero')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. merendero during 1st visit')
plt.savefig('../Output/merenderoOne.pdf')
plt.show()

### Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['sinalimentosOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food" during 1st visit')
plt.savefig('../Output/sinalimentosOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['adultonocomioOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Adults')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Adults" during 1st visit')
plt.savefig('../Output/adultonocomioOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['menornocomioOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Minors')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Minors" during 1st visit')
plt.savefig('../Output/menornocomioOne.pdf')
plt.show()

## Violencia Doméstica
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with Domestic Violence during 1st visit')
plt.savefig('../Output/vdOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['vdMujerOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Domestic Violence')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with Domestic Violence towards women during 1st visit')
plt.savefig('../Output/vdMujerOne.pdf')
plt.show()

## Embarazada
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['embarazadaOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['hombreOne']==0) & (df['edad_visitaOne']<30) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Pregnant')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of pregnants (<30 yrs old) during 1st visit')
plt.savefig('../Output/embarazadaOne.pdf')
plt.show()


### Regularizado agua y UTE (aguacorriente, redelectrica)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['uteRegularizadoOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Regularized UTE')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. regularized UTE during 1st visit')
plt.savefig('../Output/uteRegularizadoOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['oseRegularizadoOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Regularized OSE')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. regularized OSE during 1st visit')
plt.savefig('../Output/oseRegularizadoOne.pdf')
plt.show()


### Residuos cuadra y aguas contaminadas (residuoscuadra, aguascontaminadas)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['residuoscuadraOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Gargage on block')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Garbage on block during 1st visit')
plt.savefig('../Output/residuoscuadraOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['aguascontaminadasOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Contaminated waters')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of contaminated waters during 1st visit')
plt.savefig('../Output/aguascontaminadasOne.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['indocumentadosOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) & (df['visita2']==1)].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('Number of undocumented')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Number of undocumented during 1st visit')
plt.savefig('../Output/indocumentadosOne.pdf')
plt.show()

### First visit
### Problemas de alimentación en el hogar (sinalimentos, adultonocomio, menornocomio)
xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['sinalimentosOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Insuficiencia alimentaria')
plt.xlabel('ICC - Umbral TUS Simple (1er visita)')
#plt.title('Perc. of households with "No Food" during 1st visit')
plt.savefig('../Output/sinalimentos1.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['adultonocomioOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Adults')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Adults" during 1st visit')
plt.savefig('../Output/adultonocomio1.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['menornocomioOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1])].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% No Food for Minors')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. of households with "No Food for Minors" during 1st visit')
plt.savefig('../Output/menornocomio1.pdf')
plt.show()

xLinspace=np.arange(-0.2, 0.2, 0.02)  # It will give me the first value of every bin
yBins=np.ones((bins,1))               # The share of household with TUS in every bin
        
for i in range(bins-1):
    yBins[i]=df['tienecomputadorSiOne'][(df['iccNormPrimerTusOne']>=xLinspace[i]) & (df['iccNormPrimerTusOne']<xLinspace[i+1]) ].mean()
        
plt.figure()
plt.axvline(x=0, color='orange', linestyle='dashed')       # Threshold
plt.scatter(xLinspace[:-1]+(xLinspace[1]-xLinspace[0])/2,  yBins[:-1], color='red')
plt.ylabel('% Computer')
plt.xlabel('Vulnerability Index - First threshold (1st visit)')
plt.title('Perc. with computer during 1st visit')
plt.savefig('../Output/tienecomputadorSi1.pdf')
plt.show()