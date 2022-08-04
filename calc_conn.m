function calc_conn(ssid)
%% Set directories
basedir = '/gpfs/projects/bamlab/shared/aepet2/connectivity';
%outdir = [basedir '/data'];
tsdir = [basedir '/timeseries'];
nsdir = [basedir '/nuisance'];
scrubdir = [basedir '/scrubmasks'];

%% Set variables
%ssid = [1:3,7:8,11:26,28:39,41:52,54:55,57,701:702,1001];
nsub = length(ssid);

orig_rois = {'b_mofc','b_mtg','b_ifg','b_angular','b_amtg','b_pmtg','b_tmppole','b_oper','b_orbi','b_tria'};
%pmat_rois = {'b_phc','b_pcc','b_rsc','b_precuneus','b_afus','b_amygdala','b_aitc','b_lofc'};
targetrois = orig_rois; %[orig_rois pmat_rois];
ntargs = length(targetrois);

seedrois = {'b_ahip','b_phip','b_hip'};
nseeds = length(seedrois);

runs = {'rest'};
nruns = length(runs);

tmpfilt = 'reg'; %{'reg','lpf'}

%% Calculate connectivity

conn = zeros(nsub,nseeds*ntargs,nruns);

for s=1:nsub
    for c=1:nruns
        
        % Load scrubing mask
        isok = load( sprintf('%s/ts_%d_%s_scrub.txt',scrubdir,ssid(s),runs{c}) );
        isok = logical(isok);
        
        % Load nuisance regressors
        cfdts = load( sprintf('%s/ts_%d_%s_%s_nuisance.txt',nsdir,ssid(s),runs{c},tmpfilt) );

        % Load timeseries for seed rois
        seedts = [];
        for i=1:nseeds
            seedts(:,i) = load( sprintf('%s/ts_%d_%s_%s_%s.txt',tsdir,ssid(s),runs{c},tmpfilt,seedrois{i}) );
        end

        % Load timeseries for target rois
        targetts = [];
        for i=1:ntargs
            targetts(:,i) = load( sprintf('%s/ts_%d_%s_%s_%s.txt',tsdir,ssid(s),runs{c},tmpfilt,targetrois{i}) );
        end

        % Calculate connectivity
        corrs = [];
        for seed=1:nseeds
            for tar=1:ntargs
                corrs(seed,tar) = partialcorr(seedts(isok,seed),targetts(isok,tar),cfdts(isok,:));
            end
        end

        corrs = reshape(corrs',[1,nseeds*ntargs]);
        conn(s,:,c) = corrs;
    end
end

% Fisher z transform
zconn = atanh(conn);

%% Compile data for saving
conn_str = struct();

% save subject ids
conn_str.ssid = ssid'; 

% remove bs from roi labels
seedrois = erase(seedrois, "b_");
targetrois = erase(targetrois,["b_"]);

% save connection labels
connections = [];
for c=1:nseeds
    connections = [connections strcat(seedrois{c},'_',targetrois)];
end

% add run labels
%runlabs = {'rest','restlpf','expo1','expo2','expo3','expo4','pre_expo','post_expo','avg_expo'};
runlabs = {'rest'};

labs = [];
for c=1:length(runlabs)
    labs = [labs strcat(runlabs{c},'_',connections)];
end

conn_str.labels = labs;

% add connectivity to structure
conn_str.zconn = zconn;

% will have to use reshape or something to fix it
% conn.zrestlpf = zconn(:,:,1);
% conn.zexpo1 = zconn(:,:,2);
% conn.zexpo2 = zconn(:,:,3);
% conn.zexpo3 = zconn(:,:,4);
% conn.zexpo4 = zconn(:,:,5);
% conn.pre_expo = mean(zconn(:,:,2:3),3);
% conn.post_expo = mean(zconn(:,:,4:5),3);
% conn.avg_expo = mean(zconn(:,:,2:5),3);

% convert structure to table
conncell = struct2cell(conn_str);
connmat = cell2mat(conncell([1,3],:)');
conntab = array2table(connmat,'VariableNames',['ssid' labs]);

%% Save data

% add data to existing files
if ~exist(sprintf('%s/zconn.csv',basedir))
    writetable(conntab,sprintf('%s/zconn.csv',basedir))
    save(sprintf('%s/zconn.mat',basedir),'conntab')
else
    tmp = readtable(sprintf('%s/zconn.csv',basedir));
    conntab = [tmp;conntab];
    [C,ia] = unique(conntab.ssid);
    conntab = conntab(ia,:);
    writetable(conntab,sprintf('%s/zconn.csv',basedir))
    save(sprintf('%s/zconn.mat',basedir),'conntab')
end
    
