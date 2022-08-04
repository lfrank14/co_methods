#!/bin/bash

# This script is to setup AEPET2 data on talapas in BIDS format
# Run 01_aepet2_setup.sh first, then create TSV files on local computer and transfer to 'bids_data/$SSID/func/' 
# BEFORE running '01.1_aepet_OnsetBeh.sh' to generate onset files and behavioral data for pattern analyses.

#SBATCH --account=bamlab --time=0-2:00:00 --output=logs/01_setup_%j.txt --partition=dasa


SSID=$1

WDIR=/projects/bamlab/shared/aepet2
SCANDIR=/projects/lcni/dcm/bamlab/Zeithamova/AEPET2
FACEDIR=/projects/bamlab/shared/softwares/deface_templates
BIDSDIR=$WDIR/bids_data

for s in $SSID
do

mkdir -p $BIDSDIR/sub-${s}
mkdir -p $BIDSDIR/sub-${s}/func
mkdir -p $BIDSDIR/sub-${s}/anat
mkdir -p $BIDSDIR/sub-${s}/beh
mkdir -p $WDIR/raw/sub-${s}

echo "................................................"
echo "Copying the raw data"
cd $SCANDIR
cp -r AEPET2_${SSID}_*/* $WDIR/raw/sub-${s}

# Functionals

echo "................................................"
echo "Converting each exposure run"
for r in 1 2 3 4
do
	cd $WDIR/raw/sub-${s}/
	cd $(find ./ -type d -name "*EXPO"${r} |sed 1q)
	dcm2niix -z y *
	mv *EXPO${r}*.nii.gz $BIDSDIR/sub-${s}/func/sub-${s}_task-expo_run-${r}_bold.nii.gz
done

echo "................................................"
echo "Converting rest run"

cd $WDIR/raw/sub-${s}/
cd $(find ./ -type d -name "*Rest" |sed 1q)
dcm2niix -z y *
mv *Rest*.nii.gz $BIDSDIR/sub-${s}/func/sub-${s}_task-rest_bold.nii.gz

# Structurals

echo "................................................"
echo "Get the structurals"
cd $WDIR/raw/sub-${s}/
cd $(find ./ -type d -name "*mprage_p2_ND" |sed 1q)
dcm2niix -z y *
mv *mprage_p2_ND*.nii.gz $BIDSDIR/sub-${s}/anat/T1w.nii.gz

# Hires Coronal
cd $WDIR/raw/sub-${s}/
cd $(find ./ -type d -name "*t2*" |sed 1q)
dcm2niix -z y *
mv *t2*.nii.gz $BIDSDIR/sub-${s}/anat/T2w.nii.gz

echo "................................................"
echo "De-identify MPRAGE for public dissemination"
cd $BIDSDIR/sub-${s}/anat/
mri_deface T1w.nii.gz $FACEDIR/talairach_mixed_with_skull.gca $FACEDIR/face.gca T1w.nii.gz


done

echo "<3 Lurr"
