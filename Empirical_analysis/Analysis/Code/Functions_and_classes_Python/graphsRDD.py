## Binscatter showing mean of a variable around a threshold for a population with certain
## initial status of TUS, from Montevideo/Interior, and other conditions 

# nBins has to be an even number and the first nbins/2 will contain bins with
# running variable less than threshold and the second nbins/2 will contain bines
# with running variable more or EQUAL than threshold

# Each bien is plotted at its mean X value (i.e. a given bin representees mean Y
# for X>=i and X<j so the dot is plotted exactly at i+(j-i)/2)

# rg can be: 'int', 'mdeo', 'all'
# initialTUS can be: 0, 1 (simple TUS), 2 (tus doble), all
# other conditions is any variable created in the data framd df that should be equal to 1 for those observations we want to include when computing the binscatter
def fBinscatterSymmetricRDD(df, xBounds=0.2, nBins=30, running='icc', 
                 rg='int', ylabel='ylabel is', xlabel='Vulnerability Index', 
                 title='Mean number of UCT by binned VI', 
                 outcome='hogarCuantasTusMas',
                 initialTUS='all',
                 threshold=0,
                 savefig='../Output/algo.pdf',
                 otherConditions='None'):
    
    import matplotlib.pyplot as plt
    import pandas as pd
    import numpy as np
    from decimal import Decimal
    if (nBins % 2) == 0:
        df['None']=1
        xLinspace=np.arange(threshold-xBounds, threshold+xBounds+2*xBounds/nBins, 2*xBounds/nBins)        # Gives me the first value of every bin
        xLinspace[int(nBins/2)] = Decimal(threshold)
        yBins=np.ones((nBins,1))               # The mean of outcome variable in every bin 
        colors=dict()
        colors['all']='green'
        colors['mdeo']='blue'
        colors['int']='red'
        if initialTUS==1 or initialTUS==1 or initialTUS==2:
            for i in range(nBins):
                if rg == 'all':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df['hogarZeroCuantasTus']==initialTUS) & (df[otherConditions]==1)].mean()
                elif rg == 'int':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df['departamento']!=1) & (df['hogarZeroCuantasTus']==initialTUS) & (df[otherConditions]==1)].mean()
                elif rg =='mdeo':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df['departamento']==1) & (df['hogarZeroCuantasTus']==initialTUS) & (df[otherConditions]==1)].mean()
                
            plt.figure()
            plt.axvline(x=threshold, color='orange', linestyle='dashed')   # Threshold
            plt.scatter([xLinspace[i]+(xLinspace[1]-xLinspace[0])/2 for i in list(range(nBins))],  yBins, color=colors[rg])
            plt.ylabel(ylabel)           
            plt.xlabel(xlabel)
            plt.title(title)
            plt.savefig(savefig)
            plt.show()
        elif initialTUS=='all':
            for i in range(nBins):
                if rg == 'all':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df[otherConditions]==1)].mean()
                elif rg == 'int':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df['departamento']!=1) & (df[otherConditions]==1)].mean()
                elif rg =='mdeo':
                    yBins[i]=df[outcome][(df[running]>=xLinspace[i]) & (df[running]<xLinspace[i+1]) & (df['departamento']==1) & (df[otherConditions]==1)].mean()
                
            plt.figure()
            plt.axvline(x=threshold, color='orange', linestyle='dashed')   # Threshold
            plt.scatter([xLinspace[i]+(xLinspace[1]-xLinspace[0])/2 for i in list(range(nBins))],  yBins, color=colors[rg])
            plt.ylabel(ylabel)           
            plt.xlabel(xlabel)
            plt.title(title)
            plt.savefig(savefig)
            plt.show()
    else:
        print('nBins has to be an even number')

