import numpy as np
import sys

k = int(sys.argv[1])
input_data = str(sys.argv[2])
try:
	output_png = str(sys.argv[3])
except:
	output_png = "histogram"+str(k)+".png"


#input_data = "hist_data.csv"
#output_png = "histogram.png"	
t = np.genfromtxt(input_data, delimiter=' ')

import matplotlib.pyplot as plt
import numpy as np


## this block is to fill intermediate values: unnecessary
x = t[:, 0]
y = t[:, 1]
x = x.astype(int)
maxval = np.max(x)
print maxval
xnew = np.arange(maxval+1)
ynew = np.zeros(maxval+1)
for i in range(x.shape[0]):
	#print x[i]
	ynew[x[i]] = y[i]

plt.plot(xnew[1:], ynew[1:])
plt.xlabel('k-mer abundance, k =' + str(k))
plt.ylabel('frequency')
#plt.xlim(np.min(x), 200)
plt.title('Histogram to find the coverage from peak')
plt.grid(True)
plt.savefig(output_png)
plt.show()

