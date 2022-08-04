function compile_mvmt(ssids)

basedir = '/gpfs/projects/bamlab/shared/aepet2';
svdir = [basedir '/scripts/05_QA/movement'];

runs = {'rest','expo_run-1','expo_run-2','expo_run-3','expo_run-4'};

header = {'ssid'};
for r = 1:length(runs)
    header = [header sprintf('%s_maxmvmt',runs{r}) sprintf('%s_pctgood',runs{r}) sprintf('%s_pctok',runs{r}) sprintf('%s_pctnotok',runs{r}) sprintf('%s_pctbad',runs{r})];
end

%% Calculate motion

for s = 1:length(ssids)
    
    subdir = [basedir sprintf('/sub-%d/func/QA',ssids(s))];
    
    thisrun = [];
    
    for r = 1:length(runs)
        
       fd = load([subdir sprintf('/QA_%s/fd.txt',runs{r})]);
        
       thisrun = [thisrun max(fd) sum(fd < .5)/length(fd) sum(fd < 1)/length(fd) sum(fd > 1 & fd < 2)/length(fd) sum(fd > 2)/length(fd)];
        
    end
    
    mvmt = mat2dataset([ssids(s) thisrun],'Varnames',header);
    
    dat = mat2dataset([ssids(s) thisrun],'VarNames',header);
    
    if exist([svdir '/mvmt_all.mat'],'file')
        load([svdir '/mvmt_all.mat']);
        if sum(mvmt.ssid == ssids(s)) > 0
            mvmt(mvmt.ssid==ssids(s),:) = dat;
        else
            mvmt = [mvmt;dat];
            [~,i] = sort(mvmt.ssid);
            mvmt = mvmt(i,:);
        end
    else
        mvmt = dat;
    end
    
    save([svdir '/mvmt_all.mat'],'mvmt');
    export(mvmt,'FILE',[svdir '/mvmt_all.csv'],'Delimiter',',');
    
end

end