#!/bin/bash

# This script creates nuisance regressors for connectivity analyses
## extracts timeseries from control regions (csf, wm, wb) for non-lpf AND lpf functionals
## calls matlab script that creates scrubbing masks and nuisance regressors

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07_gen_nuisance_%j.txt --partition=dasa 

sbj=$1

# Set/create relevant directories
basedir=/gpfs/projects/bamlab/shared/aepet2 
sbjdir=${basedir}/sub-${sbj}
maskdir=${sbjdir}/anat/antsreg/masks
qadir=${sbjdir}/func/QA
indir=${sbjdir}/func/prepro

runs="rest expo_run-1 expo_run-2 expo_run-3 expo_run-4"
#runs="expo_run-1 expo_run-2 expo_run-3 expo_run-4"

cfdrois="b_wm b_csf wholebrain"


echo "Generating nuisance regressors and scrubbing masks for sub-${sbj}"
echo "------------------------------------------------"

# Get the timeseries from the control ROIs
echo "Extracting timeseries from control regions"

outdir=${basedir}/connectivity/timeseries
mkdir -p ${outdir}

for r in ${runs}
do	
	for croi in ${cfdrois}
	do
		echo "${r}_${croi}"

		fslmeants -i ${indir}/${r}_reg_denoised_hpf.nii.gz -m ${maskdir}/${croi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_reg_${croi}.txt
		fslmeants -i ${indir}/${r}_reg_denoised_lpf.nii.gz -m ${maskdir}/${croi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_lpf_${croi}.txt

	done	
done


# Copy QA confound files into the timeseries directory
echo "Moving confound files to nuisance directory"

outdir=${basedir}/connectivity/nuisance
mkdir -p ${outdir}

for r in ${runs}
do
	# copy confounds file
	cp ${qadir}/QA_${r}/confound.txt ${outdir}/ts_${sbj}_${r}_confound.txt

	# check if scrubres file exists
	# if so, copy regressors to confound dir
	scrubreg=${qadir}/QA_${r}/scrubdes.txt
	if [[ -f "$scrubreg" ]]; then
		cp ${scrubreg} ${outdir}/ts_${sbj}_${r}_scrubreg.txt
	fi
done


# Run Matlab script to generate nuisance regressors
module load matlab
matlab -nodisplay -nodesktop -r "run create_nuisance(${sbj})"


echo "<3 Lurr" 

