%% Code to split fusiform and hippocampus into anterior and posterior components
function split_rois(subNr)
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
startdir=pwd;

ssids = [1,1001,11,12,13,14,15,16,17,18,19,2,20,21,22,23,24,25,26,28,29,3,30,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,54,55,56,57,58,60,61,62,63,64,65,66,67,68,69,7,70,701,702,8];

for s=1:length(ssids)
    subNr = ssids(s);

    roidir = sprintf('/projects/bamlab/shared/aepet2/sub-%d/anat/antsreg/masks/', subNr);
    cd(roidir)
    
    system('export FSLOUTPUTTYPE=NIFTI_GZ');
    
%     %% split freesurfer fusiform along anterior-posterior boundary
%     % use most anterior boundary of PHC as the splitting slice
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_fus -w';
%     [status,roisize]=system(cmnd);
%     fusroi=strread(roisize,'%d');
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_phc -w';
%     [status,roisize]=system(cmnd);
%     phcroi=strread(roisize,'%d');
%     bndslice = phcroi(3)+phcroi(4); % the most anterior boundary slice of PHC
%     npost = bndslice-fusroi(3); % how many slices for posterior fusiform
%     nant = fusroi(3)+fusroi(4)-bndslice; % how many slices for anterior fus
%     cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_fus -roi %d %d %d %d %d %d %d %d r_pfus', fusroi(1:3), npost, fusroi(5:8));
%     system(cmnd);
%     cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_fus -roi %d %d %d %d %d %d %d %d r_afus', fusroi(1:2), bndslice, nant, fusroi(5:8));
%     system(cmnd);
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_fus -w';
%     [status,roisize]=system(cmnd);
%     fusroi=strread(roisize,'%d');
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_phc -w';
%     [status,roisize]=system(cmnd);
%     phcroi=strread(roisize,'%d');
%     bndslice = phcroi(3)+phcroi(4); % the most anterior boundary slice of PHC
%     npost = bndslice-fusroi(3); % how many slices for posterior fusiform
%     nant = fusroi(3)+fusroi(4)-bndslice; % how many slices for anterior fus
%     cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_fus -roi %d %d %d %d %d %d %d %d l_pfus', fusroi(1:3), npost, fusroi(5:8));
%     system(cmnd);
%     cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_fus -roi %d %d %d %d %d %d %d %d l_afus', fusroi(1:2), bndslice, nant, fusroi(5:8));
%     system(cmnd);
%     
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_afus -add l_afus b_afus');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_pfus -add l_pfus b_pfus');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_afus -add r_erc r_amtl');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths l_afus -add l_erc l_amtl');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_amtl -add l_amtl b_amtl');
%     
%     %% split hippocampus in half into anterior and posterior
%     % if odd number of slices, have posterior longer
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_hip -w';
%     [status, roisize]=system(cmnd);
%     hiproi=strread(roisize,'%d');
%     npslices = ceil(hiproi(4)./2);
%     naslices = hiproi(4)-npslices;
%     bnd=hiproi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_phip', hiproi(1:3), npslices, hiproi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_ahip', hiproi(1:2), bnd, naslices, hiproi(5:8));
%     system(cmnd);
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_hip -w';
%     [status, roisize]=system(cmnd);
%     hiproi=strread(roisize,'%d');
%     npslices = ceil(hiproi(4)./2);
%     naslices = hiproi(4)-npslices;
%     bnd=hiproi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_phip', hiproi(1:3), npslices, hiproi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_ahip', hiproi(1:2), bnd, naslices, hiproi(5:8));
%     system(cmnd);
%     
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_phip -add l_phip b_phip');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_ahip -add l_ahip b_ahip');
%     
    % remove middle slice
    % remove anterior slice if even number
    cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_hip -w';
    [status, roisize]=system(cmnd);
    hiproi=strread(roisize,'%d');
    naslices = ceil(hiproi(4)./2)-1;
    npslices = floor(hiproi(4)./2);
    bnd = hiproi(3)+npslices+1;
    cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_phip_nomid', hiproi(1:3), npslices, hiproi(5:8));
    system(cmnd);
    cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_ahip_nomid', hiproi(1:2), bnd, naslices, hiproi(5:8));
    system(cmnd);
    
    cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_hip -w';
    [status, roisize]=system(cmnd);
    hiproi=strread(roisize,'%d');
    naslices = ceil(hiproi(4)./2)-1;
    npslices = floor(hiproi(4)./2);
    bnd = hiproi(3)+npslices+1;
    cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_phip_nomid', hiproi(1:3), npslices, hiproi(5:8));
    system(cmnd);
    cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_ahip_nomid', hiproi(1:2), bnd, naslices, hiproi(5:8));
    system(cmnd);
    
    system('/packages/fsl/5.0.10/install/bin/fslmaths r_phip_nomid -add l_phip_nomid b_phip_nomid');
    system('/packages/fsl/5.0.10/install/bin/fslmaths r_ahip_nomid -add l_ahip_nomid b_ahip_nomid');
    
%     %% split mtg in half into anterior and posterior
%     % if odd number of slices, have posterior longer
%     
%     'Splitting mtg'
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_mtg -w';
%     [~, roisize]=system(cmnd);
%     mtgroi=strread(roisize,'%d');
%     npslices = ceil(mtgroi(4)./2);
%     naslices = mtgroi(4)-npslices;
%     bnd=mtgroi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_mtg -roi %d %d %d %d %d %d %d %d r_pmtg', mtgroi(1:3), npslices, mtgroi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_mtg -roi %d %d %d %d %d %d %d %d r_amtg', mtgroi(1:2), bnd, naslices, mtgroi(5:8));
%     system(cmnd);
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_mtg -w';
%     [status, roisize]=system(cmnd);
%     mtgroi=strread(roisize,'%d');
%     npslices = ceil(mtgroi(4)./2);
%     naslices = mtgroi(4)-npslices;
%     bnd=mtgroi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_mtg -roi %d %d %d %d %d %d %d %d l_pmtg', mtgroi(1:3), npslices, mtgroi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_mtg -roi %d %d %d %d %d %d %d %d l_amtg', mtgroi(1:2), bnd, naslices, mtgroi(5:8));
%     system(cmnd);
%     
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_pmtg -add l_pmtg b_pmtg');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_amtg -add l_amtg b_amtg');
% 
%     %% split it in half into anterior and posterior
%     % if odd number of slices, have posterior longer
%     
%     'Splitting it'
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats r_itc -w';
%     [~, roisize]=system(cmnd);
%     itcroi=strread(roisize,'%d');
%     npslices = ceil(itcroi(4)./2);
%     naslices = itcroi(4)-npslices;
%     bnd=itcroi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_itc -roi %d %d %d %d %d %d %d %d r_pitc', itcroi(1:3), npslices, itcroi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths r_itc -roi %d %d %d %d %d %d %d %d r_aitc', itcroi(1:2), bnd, naslices, itcroi(5:8));
%     system(cmnd);
%     
%     cmnd = '/packages/fsl/5.0.10/install/bin/fslstats l_itc -w';
%     [status, roisize]=system(cmnd);
%     itcroi=strread(roisize,'%d');
%     npslices = ceil(itcroi(4)./2);
%     naslices = itcroi(4)-npslices;
%     bnd=itcroi(3)+npslices;
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_itc -roi %d %d %d %d %d %d %d %d l_pitc', itcroi(1:3), npslices, itcroi(5:8));
%     system(cmnd);
%     cmnd=sprintf('/packages/fsl/5.0.10/install/bin/fslmaths l_itc -roi %d %d %d %d %d %d %d %d l_aitc', itcroi(1:2), bnd, naslices, itcroi(5:8));
%     system(cmnd);
%     
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_pitc -add l_pitc b_pitc');
%     system('/packages/fsl/5.0.10/install/bin/fslmaths r_aitc -add l_aitc b_aitc');
% 
%     
%     %% split hippocampus into individual slices
%     'Splitting hippocampal slices'
%     
%     rois = {'r_hip','l_hip'};
%     
%     if ~exist('conthip', 'dir')
%         mkdir('conthip');
%     end
%     
%     %mkdir conthip
%     
%     for r =1:length(rois)
%         cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslstats %s -w',rois{r});
%         [~,roisize]=system(cmnd);
%         thisroi=strread(roisize,'%d');
%         endslc=thisroi(3)+thisroi(4); % most anterior slice
%         totslc=thisroi(4); % total number of slices
%         startslc=thisroi(3); % most posterior slice
%         
%         cntr = 1;
%         for i = startslc:endslc
%             
%             cmnd = sprintf('/packages/fsl/5.0.10/install/bin/fslmaths %s -roi %d %d %d %d %d %d %d %d conthip/%s_%02d.nii.gz',rois{r},thisroi(1:2),i,1,thisroi(5:8),rois{r},cntr);
%             system(cmnd);
%             
%             cntr = cntr+1;
%         end
%     end    
end
cd(startdir);
end
