#!/bin/bash

## This scripts creates the behavior files for MVPA/RSA

# BEFORE RUNNING: create TSV files on local computer first, then transfer them to the BIDS formatting 
# 'func' folder that was created with: 01a_aepet2_setup.sh

#SBATCH --account=bamlab --output=logs/01b_behave_%j.txt --partition=dasa --time=0-2:00:00

SSID=$1

WDIR=/projects/bamlab/shared/aepet2

echo "Generate behave files (create TSV files first on local computer)"
matlab -nodisplay -nodesktop -r "run ${WDIR}/scripts/gen_behave(${SSID})"

echo "Donezoes!" 