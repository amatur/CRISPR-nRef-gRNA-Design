import sys
f_target=sys.argv[1]
with open(f_target, 'r') as myfile:
    target=myfile.read().replace('\n', '')
PAM=str(sys.argv[2])
gRNA_len=int(sys.argv[3])
f2 = open(sys.argv[4], 'w')
#print target


#~ target = "AAAAAAAAA"
#~ PAM = "AA"
#~ gRNA_len = 2


class NFiller:
    def __init__(self, PAM):
	self.PAM = PAM
	self.bases= ['A', 'C', 'G', 'T']
    def findall(self, p, s):
	'''Yields all the positions of
	the pattern p in the string s.'''
	i = s.find(p)
	while i != -1:
	    yield i
	    i = s.find(p, i+1)
    def recursive_N_filler(self, whole, lst, ipositions):
	if (not ipositions) :
	    return lst
	for c in self.bases:
	    lst2 = list(lst)
	    lst2[ipositions[-1]] = c
	    ip = ipositions[:-1]
	    whole.append(self.recursive_N_filler(whole, lst2, ip))
    def get_list(self):	
	PAM = self.PAM
	ipositions = [index for index in self.findall("N", PAM)]
	if(not ipositions):
	    return [PAM]
	PAMlist = list(PAM)
	whole  = []
	self.recursive_N_filler(whole, PAMlist, ipositions)
	w = [x for x in whole if x != None]
	#print w
	#print(len(w))
	s = [''.join(x) for x in w]
	return s



def findall(p, s):
    '''Yields all the positions of
    the pattern p in the string s.'''
    i = s.find(p)
    while i != -1:
	yield i
	i = s.find(p, i+1)

def find_candidates(target, PAM, gRNA_len):
	"""
	#~ Say, 
	#~ target: ATATATATGCATATAGCTATAGCATGCAT
	#~ pAM: 	TGC
	#~ gRNA_len: 5
	"""
	ww = [(i-gRNA_len, target[i-gRNA_len:i+len(PAM)]) for i in findall(PAM, target)]
	return [x for x in ww if x[0] >= 0]
	
    
#[(i-gRNA_len, target[i-gRNA_len:i+len(PAM)]) for i in findall(PAM, target)]

PAMs = 	NFiller(PAM).get_list()
#print PAMs
candidates = []
for PAM in PAMs:
    candidates.extend(find_candidates(target, PAM, gRNA_len))

#print candidates

dic = {}
for candidate in candidates:
	key = candidate[1] 
	if key in dic:
		dic[key] += 1
	else:
		dic[key] = 1

#print dic

    
#print candidates
for i in candidates:
	f2.write(i[1]+" "+ str(dic[i[1]]) +'\n')

f2.close()
