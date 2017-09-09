import sys
import jellyfish

k=int(sys.argv[1])
f1 = open(sys.argv[2], "r")
f2 = open(sys.argv[3], 'w')
target = f1.read()

#target = "ACGTTTTGGTTAACTT"
#k = 5
jellyfish.MerDNA.k(k)
mers = jellyfish.string_canonicals(target)
for count, m in enumerate(mers):
	#print count, m
	f2.write(str(m)+'\n')
	#f2.write(str(count)+'\n')
	#count += 1
	#rm2 = m2.get_reverse_complement()
f1.close()
f2.close()


## determine the fn to get the sub strings
## just list the k mers (small) from the target sequence
## called from the shell script
## first command line argument: k
## second command line argument: 
