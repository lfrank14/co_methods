#!/bin/bash

# This script will extract the timeseries from each functional run and move the confound files into the nuisance directory 

# needs: 
#	subject number

#SBATCH --account=bamlab --output=logs/07a_extract_ts_%j.txt --partition=dasa --time=0-6:00:00

sbj=$1

# Set/create relevant directories
basedir=/gpfs/projects/bamlab/shared/aepet2 
sbjdir=${basedir}/sub-${sbj}
maskdir=${sbjdir}/anat/antsreg/masks
qadir=${sbjdir}/func/QA
indir=${sbjdir}/func/prepro
outdir=${basedir}/connectivity/timeseries

mkdir -p ${outdir}

rois="ahip phip mofc mtg ifg angular hip ca1 ca3 dentate subiculum erc amtl phc lofc orbi oper tria amtg pmtg tmppole supar amygdala afus aitc precuneus pcc rsc"
lats="b" # "b l r"
runs="rest" # "rest expo_run-1 expo_run-2 expo_run-3 expo_run-4"
tempfilt="hpf" # "hpf lpf"


echo "Extracting timeseries for sub-${sbj}"
echo "------------------------------------------------"


for r in $runs
do
	for m in $tempfilt
	do
		for l in $lats
		do
			for roi in $rois
			do

				echo "${r}_${m}_${l}_${roi}"
				
				if [[ $m == "hpf" ]]
				then
					# renaming the extension from _hpf to _reg
					# didn't want to confuse the two filtering extensions
					func_ext="reg"
				else
					func_ext="lpf"
				fi
				
				fslmeants -i ${indir}/${r}_reg_denoised_${m}.nii.gz -m ${maskdir}/${l}_${roi}.nii.gz -o ${outdir}/ts_${sbj}_${r}_${func_ext}_${l}_${roi}.txt
			
			done	
		done
	done
done


echo "<3 Lurr" 

