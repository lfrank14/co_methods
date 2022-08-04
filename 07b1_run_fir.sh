#!/bin/bash

# This script will run all steps required for the FIR-based connectivity analysis
	## run the FIR models for all expo runs
	## register the FIR residual images to MNI
	## extract timeseries from Schaefer ROIs

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07b_mni_conn_fir_%j.txt --partition=dasa 

sbj=$1

# Set/create relevant directories
basedir=/gpfs/projects/bamlab/shared/aepet2 
sbjdir=${basedir}/sub-${sbj}
qadir=${sbjdir}/func/QA
indir=${sbjdir}/func/prepro

runs="expo_run-1 expo_run-2 expo_run-3 expo_run-4"

echo "Running FIR models for exposure runs"
echo "------------------------------------------------"

outdir=${sbjdir}/func/fir
mkdir -p ${outdir}

for r in ${runs}
do 
	echo "running FIR for ${r}"

	outfsf=${outdir}/${r}_fir.fsf
	sed -e "s|SUBNUM|${sbj}|g" -e "s|RUNNUM|${r}|g" </${basedir}/scripts/templates/expo_fir.fsf>${outfsf}
	feat ${outfsf}

	# copy residual image to prepro folder
	cp ${outdir}/${r}_fir.feat/stats/res4d.nii.gz ${indir}/${r}_reg_denoised_resid.nii.gz
done


echo "<3 Lurr" 

