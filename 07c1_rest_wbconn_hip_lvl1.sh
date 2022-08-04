#!/bin/bash

#SBATCH --account=bamlab --output=logs/07c_rest_wbconn_hip_lvl1_%j.txt --partition=dasa 

SUBNUM=$1
expdir=/projects/bamlab/shared/aepet2

module unload fsl/5.0.10
module load fsl/6.0.1

for s in $SUBNUM
do
	echo ${s}

	sbjdir=${expdir}/sub-${s}
	conndir=${sbjdir}/func/conn

	mkdir -p ${conndir}

	## CREATE AND RUN MODELS ##
	
	# start with ahip v phip model

	outfsf=${conndir}/rest_aphip_lvl1.fsf

	if [[ $s == "3" ]] || [[ $s == "1001" ]] || [[ $s == "701" ]] || [[ $s == "702" ]]
	then
		echo "6 min rest"
		sed -e "s|SUBNUM|${s}|g" -e "s|NVOLS|180|g" <${expdir}/scripts/templates/rest_wbconn_aphip_lvl1.fsf>${outfsf}
	else
		echo "8 min rest"
		sed -e "s|SUBNUM|${s}|g" -e "s|NVOLS|240|g" <${expdir}/scripts/templates/rest_wbconn_aphip_lvl1.fsf>${outfsf}
	fi

	echo "-----Running model-----"
	echo "ant v post hip"
	feat ${outfsf}

	# Check to make sure models completed
	# need this for issues with Talapas, remove before sharing
	outdir=${conndir}/rest_aphip_lvl1.feat
	if [[ ! -d "${outdir}/thresh_zstat1.nii.gz" ]]
	then
		echo "model did not finish"
		rm -R ${outdir}
		feat ${outfsf}
	fi
		
	# then run the single ROI models
	for r in phip ahip hip
	do
		outfsf2=${conndir}/rest_${r}_lvl1.fsf	

		if [[ $s == "3" ]] || [[ $s == "1001" ]] || [[ $s == "701" ]] || [[ $s == "702" ]]
		then
			echo "6 min rest"
			sed -e "s|SUBNUM|${s}|g" -e "s|NVOLS|180|g" -e "s|HIPROI|${r}|g" <${expdir}/scripts/templates/rest_wbconn_hiproi_lvl1.fsf>${outfsf2}
		else
			echo "8 min rest"
			sed -e "s|SUBNUM|${s}|g" -e "s|NVOLS|240|g" -e "s|HIPROI|${r}|g" <${expdir}/scripts/templates/rest_wbconn_hiproi_lvl1.fsf>${outfsf2}
		fi

		echo "-----Running model-----"
		echo ${r}
		feat ${outfsf2}

	done

done
