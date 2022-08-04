#!/bin/bash

#SBATCH --account=bamlab --output=logs/05_fmriqa_%j.txt --partition=dasa --time=0-6:00:00


ssid=$1
sbjdir=/projects/bamlab/shared/aepet2/sub-${ssid}/func/prepro
sbjqadir=/projects/bamlab/shared/aepet2/sub-${ssid}/func/QA
scriptdir=$(pwd)
qadir=/projects/bamlab/shared/softwares/fmriqa-master

mkdir -p ${sbjqadir}

cd ${qadir}

module load python3/3.6.5

RUNS="rest expo_run-1 expo_run-2 expo_run-3 expo_run-4" 


# Run FMRI QA procedures on motion corrected func files
echo "......................................................."
echo "FMRI QA"
for runNr in $RUNS
do

python3 fmriqa.py ${sbjdir}/${runNr}_brain_mcf.nii.gz 2

mv ${sbjdir}/QA ${sbjqadir}/QA_${runNr}

done

module unload python3/3.7.5
module load python2/2.7.13

## Run the compile script to exclude participants for motion:
# Nothing larger than 1.5mm frame-wise displacement in each run
# 80% of a run contains frame-wise displacement less than .5mm
echo "......................................................."
echo "Compile FMRI QA information for exclusion"
matlab -nodisplay -nodesktop -r "run ${scriptdir}/compile_mvmt(${ssid})"

cd ${scriptdir}

echo "<3 Lurr"