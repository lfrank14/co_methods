#!/bin/bash

#SBATCH --account=bamlab --partition=dasa --output=logs/07c_rest_wbconn_hip_group_%j.txt --mem=400G 

module unload fsl/5.0.10
module load fsl/6.0.1 

EXPDIR=/projects/bamlab/shared/aepet2
TEMPDIR=${EXPDIR}/scripts/templates
OUTDIR=${EXPDIR}/group/conn

mkdir -p ${OUTDIR}

# only run one mdlext at a time:
#mdlext="no_behav mem gen spec FACATgen FACATspec" 
mdlext=$1

# Run ahip v. phip group models
echo "Running ahip v phip group model"

if [[ $mdlext == "no_behav" ]]
then
	echo "no behavior"
	feat ${TEMPDIR}/rest_wbconn_aphip_group.fsf
else
	echo "model includes ${mdlext}"
	feat ${TEMPDIR}/rest_wbconn_aphip_group_${mdlext}_thresh27.fsf
fi


# Run individual hip roi models
for roi in ahip phip hip
do
	echo "Running group model for ${roi}"

	if [[ $mdlext == "no_behav" ]]
	then
		echo "no behavior"
		
		outfsf=${OUTDIR}/rest_wbconn_${roi}_group.fsf
		sed -e "s|HIPROI|${roi}|g" <${TEMPDIR}/rest_wbconn_hiproi_group.fsf>${outfsf}
		feat ${outfsf}

	else
		echo "model includes ${mdlext}"

		outfsf=${OUTDIR}/rest_wbconn_${roi}_group_${mdlext}_thresh27.fsf
		sed -e "s|HIPROI|${roi}|g" <${TEMPDIR}/rest_wbconn_hiproi_group_${mdlext}_thresh27.fsf>${outfsf}
		feat ${outfsf}
	fi

done
