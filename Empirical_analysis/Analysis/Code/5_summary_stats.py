import os, shutil
import pandas as pd
import numpy as np
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from scipy.io.idl import readsav
from astropy.table import Table, Column
from copy import deepcopy
#from ggplot import *

os.chdir('C:/Alejandro/Research/MIDES/Empirical_analysis/Analysis/Temp') # Set current directory

# Load dataset
dfP = pd.read_csv('../Input/MIDES/visitas_personas_TUS.csv')
dfP2 = pd.read_csv('../Input/MIDES/visitas_personas_vars.csv')
dfPPySusp = pd.read_csv('../Input/MIDES/visitas_personas_PPySusp.csv')

dfH = pd.read_csv('../Input/MIDES/visitas_hogares_TUS.csv')
dfH2 = pd.read_csv('../Input/MIDES/visitas_hogares_vars.csv')

dIPCTC = pd.read_excel('../Input/IPC_TC.xlsx', sheet_name='Python')
dVoters = pd.read_csv('../../Build/Input/PP_Muestra_enmascarado.csv')
dSuspend = pd.read_csv('../../Build/Input/Suspendidos_Muestra_enmascarado.csv')
dTus = pd.read_csv('../../Build/Input/TUS_Muestra_enmascarado.csv')

# Merge some datasets
dfP = dfP.merge(dfP2.filter(items=['flowcorrelativeid', 'nrodocumento','hogingtotalessintransferencias', 'sexo', 'parentesco']), on=['flowcorrelativeid', 'nrodocumento'], how='left')
dfH = dfH.merge(dfH2.filter(items=['flowcorrelativeid', 'inicio_critico', 'fin_critico']), on=['flowcorrelativeid'], how='left')

dfPPySusp = dfPPySusp.merge(dfP.filter(items=['flowcorrelativeid', 'nrodocumento','parentesco', 'sexo', 'hogarcobraTus52', 'hogarcobraTus70', 'hogarcobraTus106', 'hogartusDoble52', 'hogartusDoble70', 'hogartusDoble106']), on=['flowcorrelativeid', 'nrodocumento'], how='left')

''' 
Statistics I want:
    Regarding sample size:
        Number of households-visits
        Number of persons-visits
        Number of distinct people visited
        Number of distinct people visited only once
        Number of distinct people visited only twice
        Number of distinct people visited only three times
        Number of distinct people visited with more than 3 visits
        Mean number of visits for distinct people

    Regarding the transfer:
        Mean, min, median, max, SD of single TUS transfer, for those households receving the transfer by year, in current $, current USD, as % of household self-reported income.  
        Mean, min, median, max, SD of Double TUS transfer, for those households receving the transfer by year, in current $, current USD, as % of household self-reported income. 
        Mean, min, median, max, SD of AFAM transfer, for those households receving the transfer by year, in current $, current USD, as % of household self-reported income. 
        Min, max, median, mean, SD number of periods it takes to change status of TUS (losing, duplicating, or gaining separately) for someone visited in a given year (by year and by Montevideo/Interior)
    
    Regarding the visits:
        Mean, median, min, max, SD number of periods that critica takes by year
        Number of census and non-census visits by year (and all years and all states)
        Number of households-visits with single TUS and with double TUS; same for AFAM (there could be double counting of houses)
        Mean, median, min, max, sd number of months that exist between the first and second visit for those being visited twice
        Number of visits by states and by year (and all years and all states)
    
    Regarding those voting at PP elections:
        Number of voters (in my sample) per election (2008, 2011, 2013, 2016)
        Mean, median, sd, min, max age of voters per election
        Location of voters per election
        Gender of voters per election
        Mean ICC of voters per election
        Percentage of voters with 1 UCT, 2 UCT, no UCT per election
        Percentage of voters that are household heads, spouses, etc per election
        
    Regarding those that have their CCT suspended due to education:
       Min, max, median, mean age of those suspended by year (2013, 2014, 2015, 2016, 2017, 2018)
       Percentage of suspended with 1 UCT, 2 UCT, no UCT by year
       Location of suspended by year
       Gender of suspended by year
       Mean ICC of suspended by year
       Percentage of suspended that are household heads, spouses, etc per year
         
''' 

### Regarding sample size
summStats1 = pd.DataFrame(data={'Value': [0]}, index=['Number of households-visits (1000)'])
summStats1.at['Number of households-visits (1000)','Value'] = round(dfP['flowcorrelativeid'].value_counts().size/1000, 0)
summStats1.at['Number of persons-visits (1000)','Value'] = round(dfP['flowcorrelativeid'].size/1000, 0)
summStats1.at['Number of distinct people visited (1000)','Value'] = round(dfP['nrodocumento'].value_counts().size/1000, 0)
summStats1.at['Number of distinct people visited only once (1000)','Value'] = round(dfP['nrodocumento'].value_counts()[lambda x: x==1].size/1000, 0)
summStats1.at['Number of distinct people visited only twice (1000)','Value'] = round(dfP['nrodocumento'].value_counts()[lambda x: x==2].size/1000, 0)
summStats1.at['Number of distinct people visited only three times (1000)','Value'] = round(dfP['nrodocumento'].value_counts()[lambda x: x==3].size/1000, 0)
summStats1.at['Number of distinct people visited with more than 3 visits (1000)','Value'] = round(dfP['nrodocumento'].value_counts()[lambda x: x>3].size/1000, 0)
summStats1.at['Mean number of visits for distinct people','Value'] = round(dfP['nrodocumento'].value_counts().mean(), 1)

with open('../Output/summStats1.tex','w') as tf:
    tf.write(summStats1.to_latex(bold_rows=True, longtable=True))
    
### Regarding the transfer

# Need to create variable tusDoble first
dTus['tusDoble'] = 0
dTus.loc[dTus.duplicada==1, 'tusDoble'] = 1
dTus.loc[dTus.duplica==1, 'tusDoble'] = 1
dTus.loc[dTus.duplica_anterior==1, 'tusDoble'] = 1


# Need to create database of those that after visit should have seen a change

# Not receiving TUS and should receive 1 after the visit
dfH['noZeroTusShould1'] = 0
dfH['noZeroTusShould1'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.icc>=dfH.umbral_nuevo_tus) & (dfH.icc<dfH.umbral_nuevo_tus_dup), 1)['noZeroTusShould1']

# Not receiving TUS and should receive 2 after the visit
dfH['noZeroTusShould2'] = 0
dfH['noZeroTusShould2'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.icc>=dfH.umbral_nuevo_tus_dup), 1)['noZeroTusShould2']

# Receiving 1 TUS and should receive 0 after the visit
dfH['oneZeroTusShould0'] = 0
dfH['oneZeroTusShould0'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.icc<dfH.umbral_nuevo_tus), 1)['oneZeroTusShould0']

# Receiving 1 TUS and should receive 2 after the visit
dfH['oneZeroTusShould2'] = 0
dfH['oneZeroTusShould2'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.icc>=dfH.umbral_nuevo_tus), 1)['oneZeroTusShould2']

# Receiving 2 TUS and should receive 1 after the visit
dfH['twoZeroTusShould1'] = 0
dfH['twoZeroTusShould1'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.icc>=dfH.umbral_nuevo_tus) & (dfH.icc<dfH.umbral_nuevo_tus), 1)['twoZeroTusShould1']

# Receiving 2 TUS and should receive 0 after the visit
dfH['twoZeroTusShould0'] = 0
dfH['twoZeroTusShould0'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.icc<dfH.umbral_nuevo_tus), 1)['twoZeroTusShould0']

# Should change
dfH['shouldChange'] = dfH['noZeroTusShould1'] + dfH['noZeroTusShould2'] + dfH['oneZeroTusShould0'] + dfH['oneZeroTusShould2'] \
                        + dfH['twoZeroTusShould1'] + dfH['twoZeroTusShould0']

# Which period (among the 24 periods)
dfH['changed1'] = 0
dfH['changed1'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble1==0), 1)['changed1']
dfH['changed1'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus1==1), 1)['changed1']
dfH['changed1'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble1==1), 1)['changed1']
dfH['changed1'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus1==0), 1)['changed1']

dfH['changed2'] = 0
dfH['changed2'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble2==0), 1)['changed2']
dfH['changed2'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus2==1), 1)['changed2']
dfH['changed2'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble2==1), 1)['changed2']
dfH['changed2'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus2==0), 1)['changed2']

dfH['changed3'] = 0
dfH['changed3'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble3==0), 1)['changed3']
dfH['changed3'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus3==1), 1)['changed3']
dfH['changed3'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble3==1), 1)['changed3']
dfH['changed3'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus3==0), 1)['changed3']

dfH['changed4'] = 0
dfH['changed4'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble4==0), 1)['changed4']
dfH['changed4'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus4==1), 1)['changed4']
dfH['changed4'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble4==1), 1)['changed4']
dfH['changed4'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus4==0), 1)['changed4']

dfH['changed5'] = 0
dfH['changed5'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble5==0), 1)['changed5']
dfH['changed5'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus5==1), 1)['changed5']
dfH['changed5'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble5==1), 1)['changed5']
dfH['changed5'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus5==0), 1)['changed5']

dfH['changed6'] = 0
dfH['changed6'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble6==0), 1)['changed6']
dfH['changed6'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus6==1), 1)['changed6']
dfH['changed6'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble6==1), 1)['changed6']
dfH['changed6'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus6==0), 1)['changed6']

dfH['changed7'] = 0
dfH['changed7'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble7==0), 1)['changed7']
dfH['changed7'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus7==1), 1)['changed7']
dfH['changed7'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble7==1), 1)['changed7']
dfH['changed7'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus7==0), 1)['changed7']

dfH['changed8'] = 0
dfH['changed8'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble8==0), 1)['changed8']
dfH['changed8'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus8==1), 1)['changed8']
dfH['changed8'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble8==1), 1)['changed8']
dfH['changed8'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus8==0), 1)['changed8']

dfH['changed9'] = 0
dfH['changed9'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble9==0), 1)['changed9']
dfH['changed9'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus9==1), 1)['changed9']
dfH['changed9'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble9==1), 1)['changed9']
dfH['changed9'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus9==0), 1)['changed9']

dfH['changed10'] = 0
dfH['changed10'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble10==0), 1)['changed10']
dfH['changed10'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus10==1), 1)['changed10']
dfH['changed10'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble10==1), 1)['changed10']
dfH['changed10'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus10==0), 1)['changed10']

dfH['changed11'] = 0
dfH['changed11'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble11==0), 1)['changed11']
dfH['changed11'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus11==1), 1)['changed11']
dfH['changed11'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble11==1), 1)['changed11']
dfH['changed11'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus11==0), 1)['changed11']

dfH['changed12'] = 0
dfH['changed12'] = dfH.mask((dfH.hogarZerotusDoble==1) & (dfH.hogarMastusDoble12==0), 1)['changed12']
dfH['changed12'] = dfH.mask((dfH.hogarZerocobraTus==0) & (dfH.hogarMascobraTus12==1), 1)['changed12']
dfH['changed12'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMastusDoble12==1), 1)['changed12']
dfH['changed12'] = dfH.mask((dfH.hogarZerocobraTus==1) & (dfH.hogarZerotusDoble==0) & (dfH.hogarMascobraTus12==0), 1)['changed12']

dfH['didChange'] = dfH['shouldChange']

summStats2 = pd.DataFrame(data={'2009': [0], '2010': [0], '2011': [0], '2012': [0], '2013': [0], '2014': [0], \
                                '2015': [0], '2016': [0], '2017': [0], '2018': [0]})
   
for yr in [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018]:
    for per in [1,2,3,4,5,6,7,8,9,10,11,12]:
        summStats2.at['Changed ' + str(per) + 'st period', str(yr)] = dfH[(dfH['year']==yr) & (dfH['shouldChange']==1) & (dfH['changed' + str(per)]==1)]['flowcorrelativeid'].size/dfH[(dfH['year']==yr) & (dfH['shouldChange']==1)]['flowcorrelativeid'].size
       
    summStats2.at['N of house should change TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['shouldChange']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 1 to 0 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['oneZeroTusShould0']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 1 to 2 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['oneZeroTusShould2']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 0 to 1 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['noZeroTusShould1']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 0 to 2 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['noZeroTusShould2']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 2 to 1 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['twoZeroTusShould1']==1)]['flowcorrelativeid'].size 
    summStats2.at['N of house should 2 to 0 TUS', str(yr)] = dfH[(dfH['year']==yr) & (dfH['twoZeroTusShould0']==1)]['flowcorrelativeid'].size 
     
    summStats2.at['Mean 1 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].mean() 
    summStats2.at['Mean 2 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].mean() 
    summStats2.at['Min 1 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].min() 
    summStats2.at['Min 2 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].min() 
    summStats2.at['Max 1 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].max() 
    summStats2.at['Max 2 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].max() 
    summStats2.at['SD 1 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].std() 
    summStats2.at['SD 2 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].std() 
    summStats2.at['Median 1 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].median() 
    summStats2.at['Median 2 TUS for recipients, $', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].median() 
   
    summStats2.at['Mean 1 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].mean()/dIPCTC[dIPCTC.year == yr]['TC'].mean()
    summStats2.at['Mean 2 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].mean()/dIPCTC[dIPCTC.year == yr]['TC'].mean()
    summStats2.at['Min 1 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].min()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['Min 2 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].min()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['Max 1 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].max()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['Max 2 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].max()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['SD 1 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].std()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['SD 2 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].std()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['Median 1 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==0)]['monto_carga'].median()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 
    summStats2.at['Median 2 TUS for recipients, USD', str(yr)] = dTus[(dTus['year']==yr) & (dTus['tusDoble']==1)]['monto_carga'].median()/dIPCTC[dIPCTC.year == yr]['TC'].mean() 

    summStats2.at['Mean 1 TUS for recipients, %FamInc', str(yr)] = dfP[(dfP['year']==yr) & (dfP['hogarZerotusDoble']==0) & (dfP['hogarZerocobraTus']==1)]['hogarZeromonto_carga'].mean()/dfP[(dfP['year']==yr) & (dfP['hogarZerotusDoble']==0) & (dfP['hogarZerocobraTus']==1)]['hogingtotalessintransferencias'].mean()
    summStats2.at['Mean 2 TUS for recipients, %FamInc', str(yr)] = dfP[(dfP['year']==yr) & (dfP['hogarZerotusDoble']==1)]['hogarZeromonto_carga'].mean()/dfP[(dfP['year']==yr) & (dfP['hogarZerotusDoble']==1)]['hogingtotalessintransferencias'].mean()
   
with open('../Output/summStats2.tex','w') as tf:
    tf.write(summStats2.to_latex(bold_rows=True, longtable=True))

### Regarding the visits
 
# Need to create variables regarding critica

dfH['yearStartCritica'] = dfH.inicio_critico.str.slice(stop=4)
dfH['monthStartCritica'] = dfH.inicio_critico.str.slice(start=4, stop=6)
dfH['periodoStartCritica'] = (dfH['yearStartCritica'].astype(float)-2008)*12 + dfH['monthStartCritica'].astype(float)

dfH['yearEndCritica'] = dfH.fin_critico.str.slice(stop=4)
dfH['monthEndCritica'] = dfH.fin_critico.str.slice(start=4, stop=6)
dfH['periodoEndCritica'] = (dfH['yearEndCritica'].astype(float)-2008)*12 + dfH['monthEndCritica'].astype(float)

dfH['monthsEnCritica'] = dfH['periodoEndCritica'] - dfH['periodoStartCritica']

# Cretate variables with number of visits per individual and period of these visits
docs2Visitas =  dfP['nrodocumento'].value_counts()
docs2Visitas = docs2Visitas[docs2Visitas==2].index.tolist()
docs2VisitasF = pd.DataFrame(data={'Value': [0]}, index=docs2Visitas)

  
summStats3 = pd.DataFrame(data={'2011': [0], '2012': [0], '2013': [0], '2014': [0], \
                                '2015': [0], '2016': [0], '2017': [0], '2018': [0]})

for yr in [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018]:    
    summStats3.at['Number of houeshold-visits', str(yr)] = dfH[(dfH['year']==yr)]['flowcorrelativeid'].size
    summStats3.at['Number of houeshold-visits Mdeo', str(yr)] = dfH[(dfH['year']==yr) & (dfH['departamento']==1)]['flowcorrelativeid'].size 
    summStats3.at['Number of houeshold-visits Int', str(yr)] = dfH[(dfH['year']==yr) & (dfH['departamento']>1)]['flowcorrelativeid'].size 
    summStats3.at['Number of census houeshold-visits', str(yr)] = dfH[(dfH['year']==yr) & (dfH['template']=='Censo')]['flowcorrelativeid'].size 
    summStats3.at['Number of recorr.tipo houeshold-visits', str(yr)] = dfH[(dfH['year']==yr) & (dfH['template']=='Visita por CI')]['flowcorrelativeid'].size 
    summStats3.at['Meses promedio en crítica', str(yr)] = dfH[(dfH['year']==yr) & (dfH['yearStartCritica'].isna()==False) & (dfH['yearEndCritica'].isna()==False)]['monthsEnCritica'].mean()
    summStats3.at['Meses mediana en crítica', str(yr)] = dfH[(dfH['year']==yr) & (dfH['yearStartCritica'].isna()==False) & (dfH['yearEndCritica'].isna()==False)]['monthsEnCritica'].median()
    summStats3.at['Meses max en critica', str(yr)] = dfH[(dfH['year']==yr) & (dfH['yearStartCritica'].isna()==False) & (dfH['yearEndCritica'].isna()==False)]['monthsEnCritica'].max()
    summStats3.at['Meses min en critica', str(yr)] = dfH[(dfH['year']==yr) & (dfH['yearStartCritica'].isna()==False) & (dfH['yearEndCritica'].isna()==False)]['monthsEnCritica'].min()
    summStats3.at['Meses SD en critica', str(yr)] = dfH[(dfH['year']==yr) & (dfH['yearStartCritica'].isna()==False) & (dfH['yearEndCritica'].isna()==False)]['monthsEnCritica'].std()

with open('../Output/summStats3.tex','w') as tf:
    tf.write(summStats3.to_latex(bold_rows=True, longtable=True))
    
# Plot visits by year
plt.figure()
plt.bar(['2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018*'], summStats3.iloc[1], color='darkred')
plt.axhline(y=6000, color='orange', linestyle='dashed')
#plt.text(0.5, 0.5,'08-11 avg.')
#plt.annotate('local max', xy=(5, 1), xytext=(6, 5),
#            arrowprops=dict(facecolor='black', shrink=0.05),
#            )
plt.legend()
plt.savefig('../Output/nHouse.png')
plt.show()


### Regarding those voting at PP elections
summStats4 = pd.DataFrame(data={'2008': [0], '2011': [0], '2013': [0], '2016': [0]})
for yr in [2008, 2011, 2013, 2016]:
    summStats4.at['Number of voters', str(yr)] = dVoters['pp' + str(yr)].sum()
    summStats4.at['Mean age', str(yr)] = dfPPySusp[dfPPySusp['pp' + str(yr)] == 1]['edadPP' + str(yr)].mean()
    summStats4.at['Median age', str(yr)] = dfPPySusp[dfPPySusp['pp' + str(yr)] == 1]['edadPP' + str(yr)].median()
    summStats4.at['Min age', str(yr)] = dfPPySusp[dfPPySusp['pp' + str(yr)] == 1]['edadPP' + str(yr)].min()
    summStats4.at['Max age', str(yr)] = dfPPySusp[dfPPySusp['pp' + str(yr)] == 1]['edadPP' + str(yr)].max()
    summStats4.at['% Montevideo', str(yr)] = dfPPySusp[(dfPPySusp['departamento']== 1) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size
    summStats4.at['% Male', str(yr)] = dfPPySusp[(dfPPySusp['sexo'] == 1) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size
    summStats4.at['% household head', str(yr)] = dfPPySusp[(dfPPySusp['parentesco']== 1) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size
    summStats4.at['% household spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco']== 2) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% household partner but not spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 3) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% son of both adults', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 4) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% son of only head', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 5) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% son of only spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 6) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% son in law', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 7) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% grandchild', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 8) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% parents or parents in law', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 9) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% other parents', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 10) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% domestic service', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 11) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 
    summStats4.at['% no parental relationship', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 12) & (dfPPySusp['pp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['pp' + str(yr)] == 1)].size 

summStats4.at['% inidividuals with 1 UCT during month of election', '2011'] = dfPPySusp[(dfPPySusp['hogarcobraTus52'] == 1) & (dfPPySusp['hogartusDoble52'] == 0) & (dfPPySusp['pp2011'] == 1)].size / dfPPySusp[(dfPPySusp['pp2011'] == 1)].size # Period debería ser 46 pero hay missing data ahi y mas cercano es 52
summStats4.at['% inidividuals with 1 UCT during month of election', '2013'] = dfPPySusp[(dfPPySusp['hogarcobraTus70'] == 1) & (dfPPySusp['hogartusDoble70'] == 0) & (dfPPySusp['pp2013'] == 1)].size / dfPPySusp[(dfPPySusp['pp2013'] == 1)].size
summStats4.at['% inidividuals with 1 UCT during month of election', '2016'] = dfPPySusp[(dfPPySusp['hogarcobraTus106'] == 1) & (dfPPySusp['hogartusDoble106'] == 0) & (dfPPySusp['pp2016'] == 1)].size / dfPPySusp[(dfPPySusp['pp2016'] == 1 )].size

summStats4.at['% with 2 UCT during month of election', '2011'] = dfPPySusp[(dfP['hogarcobraTus52'] == 1) & (dfPPySusp['hogartusDoble52'] == 1) & (dfPPySusp['pp2011'] == 1)].size / dfPPySusp[(dfPPySusp['pp2011'] == 1)].size
summStats4.at['% with 2 UCT during month of election', '2013'] = dfPPySusp[(dfP['hogarcobraTus70'] == 1) & (dfPPySusp['hogartusDoble70'] == 1) & (dfPPySusp['pp2013'] == 1)].size / dfPPySusp[(dfPPySusp['pp2013'] == 1)].size
summStats4.at['% with 2 UCT during month of election', '2016'] = dfPPySusp[(dfP['hogarcobraTus106'] == 1) & (dfPPySusp['hogartusDoble106'] == 1) & (dfPPySusp['pp2016'] == 1)].size / dfPPySusp[(dfPPySusp['pp2016'] == 1)].size

summStats4.at['% with No UCT during month of election', '2011'] = dfPPySusp[(dfPPySusp['hogarcobraTus52'] == 0)  & (dfPPySusp['pp2011'] == 1)].size / dfPPySusp[(dfPPySusp['pp2011'] == 1)].size
summStats4.at['% with No UCT during month of election', '2013'] = dfPPySusp[(dfPPySusp['hogarcobraTus70'] == 0)  & (dfPPySusp['pp2013'] == 1)].size / dfPPySusp[(dfPPySusp['pp2013'] == 1)].size
summStats4.at['% with No UCT during month of election', '2016'] = dfPPySusp[(dfPPySusp['hogarcobraTus106'] == 0) & (dfPPySusp['pp2016'] == 1)].size / dfPPySusp[(dfPPySusp['pp2016'] == 1)].size
    
with open('../Output/summStats4.tex','w') as tf:
    tf.write(summStats4.to_latex(bold_rows=True, longtable=True))
    
### Regarding those that have their CCT suspended due to education:
summStats5 = pd.DataFrame(data={'2013': [0], '2014': [0], '2015': [0], '2016': [0], '2017': [0], '2018': [0]})   
for yr in [2013, 2014, 2015, 2016, 2017, 2018]:
    summStats5.at['Number of suspended', str(yr)] = dSuspend[dSuspend['year'] == yr].size
    summStats5.at['% Montevideo', str(yr)] = dfPPySusp[(dfPPySusp['departamento'] == 1) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size
    summStats5.at['%  Male', str(yr)] = dfPPySusp[(dfPPySusp['sexo'] == 1) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)]==1)].size
    summStats5.at['% household head', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 1) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size
    summStats5.at['% household spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 2) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% household partner but not spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 3) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% son of both adults', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 4) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% son of only head', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 5) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% son of only spouse', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 6) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% son in law', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 7) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% grandchild', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 8) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% parents or parents in law', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 9) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% other parents', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 10) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% domestic service', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 11) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    summStats5.at['% no parental relationship', str(yr)] = dfPPySusp[(dfPPySusp['parentesco'] == 12) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size 
    dfPPySusp['age' + str(yr)] = yr - dfPPySusp['yearNacimiento']
    summStats5.at['Mean age', str(yr)] = dfPPySusp[dfPPySusp['susp' + str(yr)] == 1]['age' + str(yr)].mean()
    summStats5.at['Median age', str(yr)] = dfPPySusp[dfPPySusp['susp' + str(yr)] == 1]['age' + str(yr)].median()
    summStats5.at['Min age', str(yr)] = dfPPySusp[dfPPySusp['susp' + str(yr)] == 1]['age' + str(yr)].min()
    summStats5.at['Max age', str(yr)] = dfPPySusp[dfPPySusp['susp' + str(yr)] == 1]['age' + str(yr)].max()
 
with open('../Output/summStats5.tex','w') as tf:
    tf.write(summStats5.to_latex(bold_rows=True, longtable=True))  
    
# summStats5.at['% inidividuals with 1 UCT during suspension year', str(yr)] = dfPPySusp[(dfPPySusp['hogarcobratus10'] == 1) & (dfPPySusp['hogartusdoble10'] == 0) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size
# summStats5.at['% with 2 UCT during month of election', str(yr)] = dfPPySusp[(dfPPySusp['hogarcobratus10'== 1]) & (dfPPySusp['hogartusdoble10'] == 1) & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size
# summStats5.at['% with No UCT during month of election', str(yr)] = dfPPySusp[(dfPPySusp['hogarcobratus10'== 0])  & (dfPPySusp['susp' + str(yr)] == 1)].size / dfPPySusp[(dfPPySusp['susp' + str(yr)] == 1)].size
    