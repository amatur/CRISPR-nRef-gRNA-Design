#!/bin/bash

### input files
FILE_READ="input/read.fastq" #http://gage.cbcb.umd.edu/data/Staphylococcus_aureus/
FILE_TARGET="input/target20k.txt"
PAM="NGG"
GRNA_LEN=20
CAND_LEN=23
K=22

ROUTINE0=0
ROUTINE1=0

########################
#	               #
# Filenames (serially) #
#		       #
########################
JF_MER_COUNT_FILE="output/mer_$(echo $K)_reads.jf"
TARGET_KMER_LIST="output/target_$(echo $K)mers"
TARGET_KMER_WITH_COUNT="output/target_$(echo $K)mers_with_count"
TARGET_KMER_ONLY="output/target_$(echo $K)mers"
COUNT_IN_READS="output/count_in_reads_$(echo $K)"
HIST_OUTPUT="output/hist_output_data"
##R2
CANDIDATES="output/candidates"



if [ $ROUTINE0 -eq 1 ]; then
################################################
#					       #
# Subroutine 0: From read, gen all k-mers (jf) #
#					       #
################################################
jellyfish count -m $K -s 100M  -o $JF_MER_COUNT_FILE  -t 20 -C $FILE_READ
fi


if [ $ROUTINE1 -eq 1 ]; then
## ROUTINE 1: determining the target-coverage
#~ ---------------------------------------------------------------------------
#~ determining the target-coverage
#~ ---------------------------------------------------------------------------
#~ comment: we will break the target in small k-mers, and determine histogram
#~ only from those k-mer counts
#~ ---------------------------------------------------------------------------
#~ smallK = 4/5/6 (something that makes sense, will discuss with sir later)
#~ split target into smallK-spectrum. List the small mers in a file F --(I already coded this)--
#~ call jellyfish with to count smallK-mers
#~ for each mer listed in F:
    #~ count = queryJellyfish(mer)
    #~ write count in another file F2
#~ from all integers listed in F2, determine the histogram --(I already coded this)--
#~ from histogram, see the first peak to determine the target-coverage
#~ ---------------------------------------------------------------------------
###############################################
#					      #
# Subroutine 1: Generate all k-mers of target #
#					      #
###############################################
#usage: Arguments
# arg 1 - k
# arg 2 - input file (target)
# arg 3 - output filename (with all k-mers) 
# outputs list of all canonical k-mers
python generate_k_spectrum.py $K $FILE_TARGET $TARGET_KMER_LIST

# sort target-kmers to show counts, and remove whitespace -> Entry: count KMER
sort $TARGET_KMER_LIST | uniq --count | sed 's/^[ \t]*//;s/[ \t]*$//' > $TARGET_KMER_WITH_COUNT
cut -d' ' -f2 < $TARGET_KMER_WITH_COUNT > $TARGET_KMER_ONLY


#############################################################
#			                                    #
# Subroutine 2: Query read-kmer with target k-mers          #
#                                                           #
#############################################################
# start with a blank file
echo -n "" > $COUNT_IN_READS
while read -r line
do
    kmer="$line"
    result=$(jellyfish query $JF_MER_COUNT_FILE $kmer)
    #result=${result:($k+1)} 
    echo $result >> $COUNT_IN_READS
done < "$TARGET_KMER_ONLY"


#####################################
#                                   #
# Subroutine 3: Generate histogram  #
#                                   #
#####################################
# add a header to the file
(echo "NUM_KMER NUM_REPEAT" && cat $COUNT_IN_READS) > tmp_filename1 
grep '[^[:space:]]' tmp_filename1  > $COUNT_IN_READS
rm tmp_filename1
python histogram_generator.py $COUNT_IN_READS $HIST_OUTPUT
python histogram_plotter.py $K $HIST_OUTPUT
echo "h,sello"
fi
#~ ## manually find the target coverage
#~ target_coverage=20
	
	
echo "hello: Routine 2"
	
## ROUTINE 2: determining the target-coverage
#~ --------------------------------------------------------------------------
#~ determining the best candidate where target-coverage is known
#~ --------------------------------------------------------------------------
#~ target_coverage = (determined beforehand, from a histogram analysis)
#~ candidates = set of all possible candidates
#~ for each candidate C in candidates:
    #~ q = candidateCountInTarget(target, c)
    #~ k = len(C)
    #~ call jellyfish with this value of k
    #~ p = queryJellyfish(C)
    #~ r = p / (q * target_coverage)
    #~ append <C, r> tuple in a list, sat L
#~ Output the C with minimum r in L
#~ --------------------------------------------------------------------------
 	
JF_MER_CANDI_LEN="output/jf_mer_candi_len.jf"	
TARGET_COVERAGE=20
python list_all_candidates.py $FILE_TARGET $PAM $GRNA_LEN $CANDIDATES
#jellyfish count -m $CAND_LEN -s 100M  -o $JF_MER_CANDI_LEN  -t 20 -C $FILE_READ

FINAL_CAND_R="final_cand_r"
echo -n "" > $FINAL_CAND_R
while read -r line
do
    q=$(echo "$line" | cut -d' ' -f2)
    kmer=$(echo "$line" | cut -d' ' -f1)
    result=$(jellyfish query $JF_MER_CANDI_LEN $kmer)
    #result=${result:($k+1)} 
    p=$(echo "$result" | cut -d' ' -f2 ) 
    r=$(python tc_calc.py $p $q $TARGET_COVERAGE)
    echo "$r $kmer" >> $FINAL_CAND_R
done < "$CANDIDATES"
sort -g $FINAL_CAND_R | sed 's/^[ \t]*//;s/[ \t]*$//' > sorted
