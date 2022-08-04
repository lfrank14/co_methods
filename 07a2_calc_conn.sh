#!/bin/bash

# this script runs connectivity analyses

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07b_calc_conn_%j.txt --partition=dasa --time=0-6:00:00

ssid=$1
basedir=/gpfs/projects/bamlab/shared/aepet2
scriptdir=${basedir}/scripts/07_connectivity

# Run the matlab script to compute connectivity
module load matlab
matlab -nodisplay -nodesktop -r "run calc_conn(${ssid})"
