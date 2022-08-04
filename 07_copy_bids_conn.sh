#!/bin/bash

# This script is to setup AEPET2 data for connectivity analyses
# Assumes data is in BIDS format 

#SBATCH --account=bamlab --output=logs/07_copy_bids_conn_%j.txt --partition=dasa

#SSID=$1
#SSID="1 2 3 7 8 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46 47 48 49 50 51 52 54 55 56 57 58 60 61 62 63 64 65 66 67 68 69 70"

# excluding subjects who were asleep at rest (25, 60, 61)
SSID="1 2 3 7 8 11 12 13 14 15 16 17 18 19 20 21 22 23 24 26 28 29 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46 47 48 49 50 51 52 54 55 56 57 58 62 63 64 65 66 67 68 69 70"

EXPDIR=/projects/bamlab/shared/aepet2
CONNDIR=${EXPDIR}/connectivity/conn_surf

# mkdir -p ${CONNDIR}

for s in ${SSID}
do

	BIDSDIR=${EXPDIR}/bids_data/sub-${s}
	FSDIR=${EXPDIR}/fs_aepet2/sub-${s}
	SUBDIR=${CONNDIR}/sub-${s}

	# mkdir -p ${SUBDIR}
	# mkdir -p ${SUBDIR}/anat
	# mkdir -p ${SUBDIR}/func

	# # copy scans (VOLUMETRIC)
	# cp ${BIDSDIR}/func/sub-${s}_task-rest_bold.nii.gz ${SUBDIR}/
	# cp ${BIDSDIR}/anat/T1w.nii.gz ${SUBDIR}/


	# copy scans (SURFACE)
	# cp -R ${FSDIR} ${CONNDIR}/
	#cp ${SUBDIR}/mri/aparc+aseg.mgz ${SUBDIR}/mri/aparc_aseg.mgz
	# cp ${CONNDIR}/FreeSurferColorLUT.txt ${SUBDIR}/mri/aparc_aseg.txt
	# cp ${BIDSDIR}/func/sub-${s}_task-rest_bold.nii.gz ${SUBDIR}/
	# cp ${EXPDIR}/sub-${s}/anat/antsreg/masks/b_ahip.nii.gz ${SUBDIR}/
	# cp ${EXPDIR}/sub-${s}/anat/antsreg/masks/b_phip.nii.gz ${SUBDIR}/
	cp ${EXPDIR}/sub-${s}/anat/antsreg/masks/b_ahip_nomid.nii.gz ${SUBDIR}/
	cp ${EXPDIR}/sub-${s}/anat/antsreg/masks/b_phip_nomid.nii.gz ${SUBDIR}/
	cp ${EXPDIR}/sub-${s}/anat/antsreg/masks/b_hip.nii.gz ${SUBDIR}/

done
