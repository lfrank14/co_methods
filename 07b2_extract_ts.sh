#!/bin/bash

# This script will extract timeseries from Schaefer ROIs for rest, FIR residuals, and lpf funcs

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07b2_extract_ts_%j.txt --partition=dasa 

sbj=$1

# Set Directories
basedir=/gpfs/projects/bamlab/shared/aepet2 
sbjdir=${basedir}/sub-${sbj}
indir=${sbjdir}/func/prepro
maskdir=${sbjdir}/anat/antsreg/masks/schaefer
outdir=${basedir}/connectivity/ts_schaefer

mkdir -p ${outdir}

# Set Variables
runs="rest expo_run-1 expo_run-2 expo_run-3 expo_run-4"
methods="lpf resid"

schaeflut=${basedir}/scripts/07_connectivity/Schaefer_parcels/schaefer_100parcels_7networks_lut.txt
schaefrois=$(<$schaeflut)


echo "Extracting timeseries for Schaefer ROIs"
echo "------------------------------------------------"

for r in $runs
do
	for roi in $schaefrois
	do
		echo "${r}_${roi}"

		if [[ $r == "rest" ]]; then
			fslmeants -i ${indir}/${r}_reg_denoised_hpf.nii.gz -m ${maskdir}/${roi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_${roi}.txt
		else
			fslmeants -i ${indir}/${r}_reg_denoised_lpf.nii.gz -m ${maskdir}/${roi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_lpf_${roi}.txt
			fslmeants -i ${indir}/${r}_reg_denoised_resid.nii.gz -m ${maskdir}/${roi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_resid_${roi}.txt
		fi
		
	done
done

echo "<3 Lurr" 

