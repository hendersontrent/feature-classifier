#----------------------------------------
# This script sets out to produce highly
# comparative time-series analysis of
# domestic student data by postcode
#----------------------------------------

#--------------------------------------
# Author: Trent Henderson, 4 March 2021
#--------------------------------------

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns; sns.set()
import catch22 as catch22
from catch22 import catch22_all
from sklearn import metrics

#%%
#---------------- Load data into Python ----------------------------

d = pd.read_csv("/Users/trenthenderson/Documents/git/feature-classifier/data/ts.csv")

#%%
#---------------- Run catch22 --------------------------------------

postcodes = d.perm_res_postcode.unique()
postcodes = []

for p in postcodes:
    tmp1 = d[d['perm_res_postcode'] == s]
    tmp1 = tmp1.dropna()
    tmp2 = tmp1[['eftsl']]
    tmp2 = tmp2.to_numpy()
        
    results = pd.DataFrame.from_dict(catch22_all(tmp2))
    results['postcode'] = s
        
    postcode_data.append(results)

postcode_data = pd.concat(postcode_data)

# Write to csv

postcode_data.to_csv(r"/Users/trenthenderson/Documents/git/feature-classifier/data/catch22_results.csv", index = False)

#%%
#---------------- Make clustermap to visualise structure -----------

# Standardise values

heat_data = search_data.assign(values = postcode_data.groupby('names').transform(lambda x: (x-x.mean())/x.std()))

heat_data = pd.pivot_table(heat_data, values = 'values', 
                              index = ['postcode'], 
                              columns = 'names')

fig, ax = plt.subplots(figsize = (10,10))
ax = sns.clustermap(heat_data, dendrogram_ratio = (.1, .1)) 
ax.cax.set_visible(False)

plt.savefig('/Users/trenthenderson/Documents/git/feature-classifier/output/clustermap.png', dpi = 500)
