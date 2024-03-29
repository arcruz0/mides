def fBinscatterEvent2Groups(data, menosPeriods=12, masPeriods=24, 
                 group1='group1', group2='group2', ylabel='ylabel is', xlabel='Months before/after the visit', 
                 title='Mean Y before/after visit', 
                 outcome='ocupadoSIIAS',
                 savefig='../Output/algo.pdf'):
    
    import matplotlib.pyplot as plt
    import pandas as pd
    import numpy as np
    xAxis = [d for d in range(-menosPeriods,1)]
    for item in list(range(1,masPeriods+1)):
        xAxis.append(item)
    yGroup1 = np.ones(len(xAxis))
    yGroup2 = np.ones(len(xAxis)) 
    # Siempre voy a querer tomar únicamente individuos con datos para todos los períodos
    data['condition']=1
    for i in list(range(1,masPeriods+1)):
        data['condition']=data['condition'].mask(data['mas' + outcome + str(i)].isna(),0)
    for i in list(range(-menosPeriods,0)):
        data['condition']=data['condition'].mask(data['menos' + outcome + str(-i)].isna(),0)
    data['condition']=data['condition'].mask(data['zero' + outcome].isna(),0)
    
    # Armo binscatter data for MAS periods
    for i in range(1,menosPeriods+1):
        yGroup1[menosPeriods - i] = data[(data['condition']==1) & (data[group1]==1)]['menos' + outcome + str(i)].mean()
        yGroup2[menosPeriods - i] = data[(data['condition']==1) & (data[group2]==1)]['menos' + outcome + str(i)].mean()

    yGroup1[menosPeriods] = data[(data['condition']==1) & (data[group1]==1)]['zero' + outcome].mean()
    yGroup2[menosPeriods] = data[(data['condition']==1) & (data[group2]==1)]['zero' + outcome].mean()

    for i in range(1,masPeriods+1):
        yGroup1[menosPeriods + i] = data[(data['condition']==1) & (data[group1]==1)]['mas' + outcome + str(i)].mean()
        yGroup2[menosPeriods + i] = data[(data['condition']==1) & (data[group2]==1)]['mas' + outcome + str(i)].mean()

    plt.figure()    
    plt.scatter(xAxis, yGroup1, color='red')
    plt.scatter(xAxis, yGroup2, color='grey')
    plt.axvline(x=0, color='orange', linestyle='dashed')
    plt.ylabel(ylabel)
    plt.xlabel(xlabel)
    plt.title(title)
    plt.savefig(savefig)
    plt.show()
    
def fBinscatterEventDif2Groups(data, menosPeriods=12, masPeriods=24, 
                 group1='group1', group2='group2', ylabel='ylabel is', xlabel='Months before/after the visit', 
                 title='Mean Y before/after visit', 
                 outcome='ocupadoSIIAS',
                 savefig='../Output/algo.pdf'):
    
    import matplotlib.pyplot as plt
    import pandas as pd
    import numpy as np
    xAxis = [d for d in range(-menosPeriods,1)]
    for item in list(range(1,masPeriods+1)):
        xAxis.append(item)
    yGroup1 = np.ones(len(xAxis))
    yGroup2 = np.ones(len(xAxis)) 
    # Siempre voy a querer tomar únicamente individuos con datos para todos los períodos
    data['condition']=1
    for i in list(range(1,masPeriods+1)):
        data['condition']=data['condition'].mask(data['mas' + outcome + str(i)].isna(),0)
    for i in list(range(-menosPeriods,0)):
        data['condition']=data['condition'].mask(data['menos' + outcome + str(-i)].isna(),0)
    data['condition']=data['condition'].mask(data['zero' + outcome].isna(),0)
    
    # Armo binscatter data for MAS periods
    for i in range(1,menosPeriods+1):
        yGroup1[menosPeriods - i] = data[(data['condition']==1) & (data[group1]==1)]['menos' + outcome + str(i)].mean()
        yGroup2[menosPeriods - i] = data[(data['condition']==1) & (data[group2]==1)]['menos' + outcome + str(i)].mean()

    yGroup1[menosPeriods] = data[(data['condition']==1) & (data[group1]==1)]['zero' + outcome].mean()
    yGroup2[menosPeriods] = data[(data['condition']==1) & (data[group2]==1)]['zero' + outcome].mean()

    for i in range(1,masPeriods+1):
        yGroup1[menosPeriods + i] = data[(data['condition']==1) & (data[group1]==1)]['mas' + outcome + str(i)].mean()
        yGroup2[menosPeriods + i] = data[(data['condition']==1) & (data[group2]==1)]['mas' + outcome + str(i)].mean()

    yGroup = yGroup1 - yGroup2
    plt.figure()    
    plt.scatter(xAxis, yGroup, color='green')
    plt.axvline(x=0, color='orange', linestyle='dashed')
    plt.axhline(y=yGroup[menosPeriods], color='red', linestyle='dashed')
    plt.ylabel(ylabel)
    plt.xlabel(xlabel)
    plt.title(title)
    plt.savefig(savefig)
    plt.show()

