#!/bin/bash

### input files
FILE_READ="input/read.fastq"
FILE_TARGET="input/target20k.txt"
PAM="NGG"
GRNA_LEN=20
K=22

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


################################################
#					       #
# Subroutine 0: From read, gen all k-mers (jf) #
#					       #
################################################
jellyfish count -m $K -s 100M  -o $JF_MER_COUNT_FILE  -t 20 -C $FILE_READ


## ROUTINE 1: determining the target-coverage
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
echo "" > $COUNT_IN_READS
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


#~ ## manually find the target coverage
#~ target_coverage=4
	
