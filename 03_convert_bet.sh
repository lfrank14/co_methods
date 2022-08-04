#!/bin/bash

# This script is to convert freesurfer output to .nii.gz format and brain extract the original hi-res image

#SBATCH --output=logs/03_convert_bet_%j.txt --account=bamlab --partition=dasa --time=06:000:00

SSID=$1
EXPDIR=/projects/bamlab/shared/aepet2

RUNS="rest expo_run-1 expo_run-2 expo_run-3 expo_run-4"


for SUBNUM in $SSID
do

SUBPATH=$EXPDIR/sub-$SUBNUM
ANATDIR=$SUBPATH/anat
BOLDDIR=$SUBPATH/func/prepro
FSDIR=$EXPDIR/fs_aepet2/sub-$SUBNUM/mri
ORIGBOLDDIR=$EXPDIR/bids_data/sub-${SUBNUM}/func

mkdir -p $SUBPATH
mkdir -p $ANATDIR
mkdir -p $BOLDDIR


## Convert Freesurfer output to .nii and Reorient images ##
echo Converting Freesurfer to nifti and Reorienting to Standard

echo Converting brainmask
mri_convert $FSDIR/brainmask.mgz $ANATDIR/brainmask.nii.gz
fslreorient2std $ANATDIR/brainmask.nii.gz $ANATDIR/brainmask.nii.gz

echo Converting orig
mri_convert $FSDIR/orig.mgz $ANATDIR/hires.nii.gz
fslreorient2std $ANATDIR/hires.nii.gz $ANATDIR/hires.nii.gz

echo Convert Parcellations
mri_convert $FSDIR/aparc+aseg.mgz $ANATDIR/parcels.nii.gz
fslreorient2std $ANATDIR/parcels.nii.gz $ANATDIR/parcels.nii.gz

mri_convert $FSDIR/aparc.a2009s+aseg.mgz $ANATDIR/parcels2009.nii.gz
fslreorient2std $ANATDIR/parcels2009.nii.gz $ANATDIR/parcels2009.nii.gz


## Brain Extraction ##
echo "........................................................"

echo Brain extraction anatomicals
bet $ANATDIR/hires.nii.gz $ANATDIR/hires_bet.nii.gz -R

echo Brain extraction functionals
	for r in $RUNS
 	do
 		echo ${r}
 		bet ${ORIGBOLDDIR}/sub-${SUBNUM}_task-${r}_bold.nii.gz ${BOLDDIR}/${r}_brain.nii.gz -F
 	done

done

echo "<3 Lurr"