#!/bin/bash

# This script is intended as a wrapper to run something on all subjects

#SBATCH --account=bamlab --output=logs/wrapper_%j.txt --partition=dasa

#SSID=$1
SSID="2 3 7 8 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46 47 48 49 50 51 52 54 55 56 57 58 60 61 62 63 64 65 66 67 68 69 70 1001 701 702"
#SSID="43 44 45 46 47 48 49 50 51 52 54 55 57 1001 701 702"

EXPDIR=/projects/bamlab/shared/aepet2

for s in ${SSID}
do

	sbatch 07b2_extract_ts.sh ${s}

done
