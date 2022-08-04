#!/bin/bash

# -----------------------------------------------------
###### FREESURFER FOR BRAIN PARCELATION #######
# -----------------------------------------------------
# Helpful Hints:
# 	Only run one subject at a time
# 	Code can take up to 12 hours to run for one subject so might want to process overnight
# 	Specifying a fat partition since some jobs required more memory

#SBATCH --account=bamlab --output=logs/02_freesurfer_%j.txt --partition=dasa --time=2-0:00:00

###  START FREESURFER PROCESS ###
SSID=$1
EXPDIR=/projects/bamlab/shared/aepet2

mkdir -p $EXPDIR/fs_aepet2

for SUBNUM in $SSID
do

	SUBPATH=$EXPDIR/bids_data/sub-$SUBNUM
	ANATDIR=$SUBPATH/anat/

	export SUBJECTS_DIR=$EXPDIR/fs_aepet2/

	## Regular Freesurfer parcels
	echo Run Freesurfer started on: `date`

	recon-all -subject sub-$SUBNUM -i $SUBPATH/anat/T1w.nii.gz -all

	echo Run Freesurfer finished on: `date`

	## Then do the Freesurfer hippocampal subfield segmentation
	echo Run Freesurfer Hippocampal Segmentation started on: `date`

	recon-all -s sub-$SUBNUM -hippocampal-subfields-T1T2 $SUBPATH/anat/T2w.nii.gz T1T2an

	echo Run Freesurfer Hippocampal Segmentation finished on: `date`

	## Then modify then segmentation using the nearest neighbor procedure developed by M. Alejandra de Araujo Sanchez
	DIR=$SUBJECTS_DIR/sub-$SUBNUM/mri
	ANATDIR=$EXPDIR/sub-$SUBNUM/anat

	mkdir -p $ANATDIR

	if [ "$TYPE" = "T1" ]
	then
		TYPESEG=T1
	else
		TYPESEG=T1-T1T2an
	fi

	echo Run Modify Segmentation started on: `date`

	echo Running left side
	mri_convert $DIR/lh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.mgz $DIR/lh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.nii
	python modifySegmentation.py $SUBNUM l $TYPESEG
	mri_convert $DIR/lh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.nii $DIR/lh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.mgz
	mri_convert $DIR/lh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.nii $DIR/lh_hip_finalseg.nii.gz

	echo running right side
	mri_convert $DIR/rh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.mgz $DIR/rh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.nii
	python modifySegmentation.py $SUBNUM r $TYPESEG
	mri_convert $DIR/rh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.nii $DIR/rh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.mgz
	mri_convert $DIR/rh.hippoSfLabels-$TYPESEG.v10.FSvoxelSpace.transformed.nii $DIR/rh_hip_finalseg.nii.gz

	echo Run Modify Segmentation finished on: `date`


	# convert hippocampal segmentation
	echo Reorienting hippocampal segmentations
	
	cp  $DIR/lh_hip_finalseg.nii.gz $ANATDIR/l_hip_finalseg.nii.gz
	fslreorient2std $ANATDIR/l_hip_finalseg.nii.gz $ANATDIR/lh_hip_finalseg.nii.gz
	rm $ANATDIR/l_hip_finalseg.nii.gz

	cp  $DIR/rh_hip_finalseg.nii.gz $ANATDIR/r_hip_finalseg.nii.gz
	fslreorient2std $ANATDIR/r_hip_finalseg.nii.gz $ANATDIR/rh_hip_finalseg.nii.gz
	rm $ANATDIR/r_hip_finalseg.nii.gz

done

echo "<3 Lurr"