#!/bin/bash

# This script preprocesses functional runs (rest and expo runs) and runs ICA-denoising 
## Preprocessing: smooth = 6mm, registration to structural and standard using non-linear transofrmation
	## running on the minimally processed funcs (i.e., brain extracted, motion corrected and registered)
## Run ICA-Aroma on preprocessed funcs
## Regress out noise components from the minimally processed funcs
## Apply high-pass and low-pass filters

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07_denoise_prepro_%j.txt --partition=dasa --time=24:00:00

sbj=$1
basedir=/projects/bamlab/shared/aepet2
sbjdir=${basedir}/sub-${sbj}/func/prepro
softdir=/projects/bamlab/shared/softwares/ICA-AROMA-master

echo "Running denoising and preprocessing for sub-${sbj}"
echo "----------------------------------------"

rn="rest expo_run-1 expo_run-2 expo_run-3 expo_run-4"

for r in ${rn}
do

	# run feat
	echo "Preprocessing ${r}"
	
	outfsf=${sbjdir}/${r}_prepro_denoised.fsf

	if [[ $r == "rest" ]]
	then
		if [[ $sbj == "3" ]] || [[ $sbj == "1001" ]] || [[ $sbj == "701" ]] || [[ $sbj == "702" ]]
		then
			sed -e "s|SUBNUM|${sbj}|g" -e "s|RUNNUM|${r}|g" -e "s|NVOLS|180|g" <${basedir}/scripts/templates/prepro_denoised.fsf>${outfsf}
		else
			sed -e "s|SUBNUM|${sbj}|g" -e "s|RUNNUM|${r}|g" -e "s|NVOLS|240|g" <${basedir}/scripts/templates/prepro_denoised.fsf>${outfsf}
		fi
	else
		sed -e "s|SUBNUM|${sbj}|g" -e "s|RUNNUM|${r}|g" -e "s|NVOLS|110|g" <${basedir}/scripts/templates/prepro_denoised.fsf>${outfsf}
	fi

	feat ${outfsf}
	mv ${outfsf} ${sbjdir}/${r}_prepro_denoised.feat/${r}_prepro_denoised.fsf

	# run ICA-AROMA
	echo "Running ICA denoising"
	INFILE=${sbjdir}/${r}_prepro_denoised.feat/filtered_func_data.nii.gz
	AROMADIR=${sbjdir}/${r}_prepro_denoised.feat/ICA_AROMA
	MATFILE=${sbjdir}/${r}_prepro_denoised.feat/reg/example_func2highres.mat
	WARPFILE=${sbjdir}/${r}_prepro_denoised.feat/reg/highres2standard_warp.nii.gz
	MCFILE=${sbjdir}/${r}_brain_mcf.par

	python2.7 $softdir/ICA_AROMA.py -in $INFILE -out $AROMADIR -affmat $MATFILE -warp $WARPFILE -mc $MCFILE

	# regress out noise components
	echo "Regressing out noise components"
	INFILE=${sbjdir}/antsreg/functionals/${r}_reg.nii.gz
	fsl_regfilt -i ${INFILE} -o ${sbjdir}/${r}_reg_denoised.nii.gz -d ${AROMADIR}/melodic.ica/melodic_mix -f $(cat ${AROMADIR}/classified_motion_ICs.txt)

	# high-pass filter denoised data
	echo "Applying high-pass filter"
	fslmaths ${sbjdir}/${r}_reg_denoised.nii.gz -Tmean ${sbjdir}/tempMean.nii.gz
	fslmaths ${sbjdir}/${r}_reg_denoised.nii.gz -bptf 25 -1 -add ${sbjdir}/tempMean.nii.gz ${sbjdir}/${r}_reg_denoised_hpf.nii.gz

	rm ${sbjdir}/tempMean.nii.gz

	# add low-pass filter
	echo "Applying low-pass filter"
	fslmaths ${sbjdir}/${r}_reg_denoised_hpf.nii.gz -bptf -1 4 ${sbjdir}/${r}_reg_denoised_lpf.nii.gz


	echo "------------------------------------"
done

echo "Fin <3 Lurr"
