function create_nuisance(ssid)
%% Set directories
basedir = '/gpfs/projects/bamlab/shared/aepet2/connectivity';
tsdir = [basedir '/timeseries'];
nsdir = [basedir '/nuisance'];

% create new directories for nuisance regressors and scrubbing masks
if ~exist([basedir '/scrubmasks'], 'dir')
    mkdir([basedir '/scrubmasks'])
end

%% Set variables
%ssid = [1:3,7:8,11:26,28:39,41:52,54:55,57,701,1001];
nsub = length(ssid);

% control regions
cfdrois = {'b_csf','b_wm','wholebrain'};

% type of func: regular or low-pass filtered
functype = {'reg','lpf'};

runs = {'rest','expo_run-1','expo_run-2','expo_run-3','expo_run-4'};
nruns = length(runs);

%% Generate scrubbing masks and nuisance regressors

qa_reg = zeros(nsub,7,nruns); %propkept_isok, propkept_isok2, fd, dvars, csf, wm, wholebrain
qa_lpf = zeros(nsub,7,nruns);

for s=1:nsub
    for c=1:nruns
        
        % Create scrubbing mask
        % load confound files to get motion params, fd, and dvars
        confounds = load( sprintf('%s/ts_%d_%s_confound.txt',nsdir,ssid(s),runs{c}) );
        fd = confounds(:,13);
        dvars = confounds(:,14);
        
        nvols = length(fd);
        
        % scrub any timept that is fd > .5 or dvars > .5
        scrub = fd > .5 | dvars > .5;
        isok = ~scrub;
        whichscrub = find(scrub);
        if ~isempty(whichscrub)
            addscrub = [whichscrub-1 whichscrub+1 whichscrub+2];
            isok(addscrub)=0;
        end
        isok(1:2)=0;
        isok = isok(1:nvols);
        
        % save scrubbing mask for later analyses (e.g. whole-brain)
        dlmwrite(sprintf('%s/scrubmasks/ts_%d_%s_scrub.txt',basedir,ssid(s),runs{c}), isok)
        
        % scrub any timept that is fd > .5 & dvars > .5
        scrub = fd > .5 & dvars > .5;
        isok2 = ~scrub;
        whichscrub = find(scrub);
        if ~isempty(whichscrub)
            addscrub = [whichscrub-1 whichscrub+1 whichscrub+2];
            isok2(addscrub)=0;
        end
        isok2(1:2)=0;
        isok2 = isok2(1:nvols);
        
        % save scrubbing mask for later analyses (e.g. whole-brain)
        dlmwrite(sprintf('%s/scrubmasks/ts_%d_%s_scrub_orig.txt',basedir,ssid(s),runs{c}), isok2)
        
        % save proportion kept for later analyses
        qa_reg(s,1:4,c) = [mean(isok) mean(isok2) mean(abs(fd)) mean(abs(dvars))];
        qa_lpf(s,1:4,c) = [mean(isok) mean(isok2) mean(abs(fd)) mean(abs(dvars))];
        
        % Create nuisance regressors for lpf and non-lpf funcs
        for m=1:2
            
            % Load timeseries for confounds
            cfdts = [];
            for i=1:length(cfdrois)
                cfdts(:,i) = load( sprintf('%s/ts_%d_%s_%s_%s.txt',tsdir,ssid(s),runs{c},functype{m},cfdrois{i}) );
            end
            cfdts(:,4:6) = [zeros(1,length(cfdrois)); diff(cfdts)]; %add derivatives of each
            cfdts(:,7:18) = confounds(:,1:12); %add 6 motion params+derivatives

            % save nuisance regressors
            dlmwrite(sprintf('%s/nuisance/ts_%d_%s_%s_nuisance.txt',basedir,ssid(s),runs{c},functype{m}), cfdts, 'delimiter', '\t')

            % save confound info for later qa checks
            if m < 2
                qa_reg(s,5:end,c) = mean(cfdts(:,1:3));
            else
                qa_lpf(s,5:end,c) = mean(cfdts(:,1:3));
            end

            % add scrubbing regressors
            if exist( sprintf('%s/%d_%s_%s_scrubreg.txt',tsdir,ssid(s),runs{c}), 'file') == 2
                scrubreg = load( sprintf('%s/ts_%d_%s_scrubreg.txt',tsdir,ssid(s),runs{c}) );
                cfdts = [cfdts scrubreg];
            end

            % save nuisance regressors for whole-brain analysis
            dlmwrite(sprintf('%s/nuisance/ts_%d_%s_%s_nuisance_scrubreg.txt',basedir,ssid(s),runs{c},functype{m}), cfdts, 'delimiter', '\t')
        end
    end
end

%% Save Confounds QA file for later control analyses
% % need to pull rest info from somewhere else

qa_labs = {'propkept_isok','propkept_isok2','m_absfd','m_absdvars','m_csf','m_wm','m_wholebrain'};
runs = {'rest','expo1','expo2','expo3','expo4'};
labs = [];
for i=1:nruns
    labs = [labs strcat(runs{i},'_',qa_labs)];
end

qa_reg_tab = array2table(reshape(qa_reg,[nsub,7*nruns]),'VariableNames',strcat('reg_',labs));
qa_lpf_tab = array2table(reshape(qa_reg,[nsub,7*nruns]),'VariableNames',strcat('lpf_',labs));

qa_reg_tab.ssid = ssid';
qa_reg_tab = qa_reg_tab(:,[size(qa_reg_tab,2),1:(size(qa_reg_tab,2)-1)]);

qa_lpf_tab.ssid = ssid';
qa_lpf_tab = qa_lpf_tab(:,[size(qa_lpf_tab,2),1:(size(qa_lpf_tab,2)-1)]);

% add data to existing files
if ~exist(sprintf('%s/qa_reg.csv',basedir))
    writetable(qa_reg_tab, sprintf('%s/qa_reg.csv',basedir))
    save(sprintf('%s/qa_reg.mat',basedir),'qa_reg_tab')
else
    tmp = readtable(sprintf('%s/qa_reg.csv',basedir));
    qa_reg_tab = [tmp;qa_reg_tab];
    [C,ia] = unique(qa_reg_tab.ssid);
    qa_reg_tab = qa_reg_tab(ia,:);
    writetable(qa_reg_tab,sprintf('%s/qa_reg.csv',basedir))
    save(sprintf('%s/qa_reg.mat',basedir),'qa_reg_tab')
end

if ~exist(sprintf('%s/qa_lpf.csv',basedir))
    writetable(qa_lpf_tab, sprintf('%s/qa_lpf.csv',basedir))
    save(sprintf('%s/qa_lpf.mat',basedir),'qa_lpf_tab')
else
    tmp = readtable(sprintf('%s/qa_lpf.csv',basedir));
    qa_lpf_tab = [tmp;qa_lpf_tab];
    [C,ia] = unique(qa_lpf_tab.ssid);
    qa_lpf_tab = qa_lpf_tab(ia,:);
    writetable(qa_lpf_tab,sprintf('%s/qa_lpf.csv',basedir))
    save(sprintf('%s/qa_lpf.mat',basedir),'qa_lpf_tab')
end

