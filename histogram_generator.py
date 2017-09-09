import sys
import numpy as np
import pandas as pd


f1 = sys.argv[1] #input filename
f2 = sys.argv[2] #output filename	
#~ f1 = "count_in_reads_40"
#~ f2 = "testOutputForHistogram"
df1 = pd.read_csv(f1,  delimiter=" ", header=0)
nn = np.arange(len(df1))
df1["SERIAL"] = nn
del df1['NUM_KMER']
#print df1
#print df1
maxrep = df1['NUM_REPEAT'].max()
#df.hist()
x = np.arange(maxrep)
x = x + 1
kata = np.array([x]*2).T
df2 = pd.DataFrame(kata, columns=['NUM_REPEAT','SERIAL'])
df2['SERIAL'] = 0

df = df2.merge(df1, how='left', on=['NUM_REPEAT'])
df['SERIAL']= df[['SERIAL_x', 'SERIAL_y']].apply(max, axis = 1)
del df['SERIAL_x']
del df['SERIAL_y']
df = df.groupby(['NUM_REPEAT']).size().reset_index(name='COUNTS')
#print df

df['PRODUCT'] = df.apply(lambda row: (row['NUM_REPEAT']*row['COUNTS']), axis=1)
print "Estimated total k-mer count: " + str(df['PRODUCT'].sum())
del df['PRODUCT']
df.to_csv(f2, index=False,  sep=" ", header=0)



