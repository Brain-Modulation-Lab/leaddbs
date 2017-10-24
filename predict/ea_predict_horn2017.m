function varargout=ea_predict_horn2017(varargin)

if nargin==1 && ischar(varargin{1}) && strcmp(varargin{1},'specs')
   specs.modelname='Horn et al., 2017 Annals of Neurology';
   specs.modelshortname='horn2017';
   specs.feats={'dMRI','fMRI'}; % could be Coords and VTA
   specs.metrics={'% UPDRS-III Improvement'};
   specs.support={'HCP_MGH_30fold_groupconnectome (Horn 2017)','PPMI_90 (Ewert 2017)','PPMI 74_15 (Horn 2017)'};
   varargout{1}=specs;
   return
end


options=varargin{1};
pt=varargin{2}; % patient number (of options.uivatdirs) defined in outer loop.


load(fullfile(ea_getearoot,'predict','models','horn2017_AoN','modeldata.mat'));

feats=[0,0];
stimname=options.predict.stimulation;

%% get seed maps of VTAs
if ismember('dMRI',options.predict.includes)
    feats(1)=1;
    if options.predict.usepresentmaps && exist([options.uivatdirs{pt},filesep,'stimulations',filesep,stimname,filesep,'vat_seed_compound_dMRI_struc.nii'],'file')
    else
        % -> run connectome mapper on patient
        run_mapper_vat_local(uivatdirs{pt},stimname,0,predict.dMRIcon,1,predict.fMRIcon)
    end
    dMRImap=ea_load_nii([options.uivatdirs{pt},filesep,'stimulations',filesep,stimname,filesep,'vat_seed_compound_dMRI_struc.nii']);
    dMRImap.img(modeldata.mask)=ea_normal(dMRImap.img(modeldata.mask));
end
    
if ismember('fMRI',options.predict.includes)
    feats(2)=1;
    if options.predict.usepresentmaps && exist([options.uivatdirs{pt},filesep,'stimulations',filesep,stimname,filesep,'vat_seed_compound_fMRI_func_seed_AvgR_Fz.nii'],'file')
    else
        % -> run connectome mapper on patient
        run_mapper_vat_local(uivatdirs{pt},stimname,1,predict.dMRIcon,0,predict.fMRIcon)
    end
    fMRImap=ea_load_nii([options.uivatdirs{pt},filesep,'stimulations',filesep,stimname,filesep,'vat_seed_compound_fMRI_func_seed_AvgR_Fz.nii']);
end



%% load canonical models and compare
if feats(1)
    dMRImod=ea_load_nii(fullfile(ea_getearoot,'predict','models','horn2017_AoN','combined_maps','dMRI.nii'));
    dMRIsim=corr(dMRImod.img(modeldata.mask),dMRImap.img(modeldata.mask),'type','spearman','rows','pairwise');
end
if feats(2)
    fMRImod=ea_load_nii(fullfile(ea_getearoot,'predict','models','horn2017_AoN','combined_maps','fMRI.nii'));
    modelvals=fMRImod.img(modeldata.mask);
    ptvals=fMRImap.img(modeldata.mask);
    infs=isinf(modelvals);
    infs=logical(infs+isinf(ptvals));
    modelvals(infs)=[];
    ptvals(infs)=[];
    fMRIsim=corr(modelvals,ptvals,'type','pearson','rows','pairwise');
end

% solve regression model
X=[modeldata.dMRIsims,modeldata.fMRIsims];
X=X(:,logical(feats));
[beta,dev,stats]=glmfit(X,modeldata.updrs3percimprov);

Xpt=[0,0];
if feats(1)
    Xpt(1)=dMRIsim;
end
if feats(2)
    Xpt(2)=fMRIsim;
end
Xpt=Xpt(logical(feats));

updrshat=ea_addone(Xpt)*beta; % percent UPDRS-III improvement prediction



%% build improvement report:
keyboard












function run_mapper_vat_local(ptdir,stimname,struc,strucc,func,funcc)
% - Lead-DBS Job created on 21-Oct-2017 19:02:11 -
% --------------------------------------

options = getoptslocal;
options.lcm.struc.do = struc;
options.lcm.func.do = func;

options.lcm.seeds = stimname;
options.lcm.struc.connectome = strucc;
options.lcm.func.connectome = funcc;
options.uivatdirs = {ptdir};
options.prefs=ea_prefs;
ea_run('run', options);


function options = getoptslocal
options.endtolerance = 10;
options.sprungwert = 4;
options.refinesteps = 0;
options.tra_stdfactor = 0.9;
options.cor_stdfactor = 1;
options.earoot = ea_getearoot;
options.dicomimp = 0;
options.assignnii = 0;
options.normalize.do = 0;
options.normalize.method = [];
options.normalize.check = 0;
options.coregmr.check = 0;
options.coregmr.do = 0;
options.coregmr.method = '';
options.coregct.do = 0;
options.modality = 1;
options.verbose = 3;
options.sides = [1 2];
options.doreconstruction = 0;
options.autoimprove = 0;
options.axiscontrast = 8;
options.zresolution = 10;
options.atl.genpt = 0;
options.atl.normalize = 0;
options.atl.can = 1;
options.atl.pt = 0;
options.atl.ptnative = 0;
options.native = 0;
options.d2.col_overlay = 1;
options.d2.con_overlay = 1;
options.d2.con_color = [1 1 1];
options.d2.lab_overlay = 1;
options.d2.bbsize = 10;
options.d2.backdrop = 'MNI_ICBM_2009b_NLIN_ASYM T1';
options.d2.fid_overlay = 0;
options.d2.write = 0;
options.d2.atlasopacity = 0.15;
options.manualheightcorrection = 0;
options.scrf = 0;
options.d3.write = 0;
options.d3.prolong_electrode = 2;
options.d3.verbose = 'on';
options.d3.elrendering = 1;
options.d3.exportBB = 0;
options.d3.hlactivecontacts = 0;
options.d3.showactivecontacts = 1;
options.d3.showpassivecontacts = 1;
options.d3.showisovolume = 0;
options.d3.isovscloud = 0;
options.d3.mirrorsides = 0;
options.d3.autoserver = 0;
options.d3.expdf = 0;
options.numcontacts = 4;
options.writeoutpm = 1;
options.expstatvat.do = 0;
options.fiberthresh = 10;
options.writeoutstats = 1;
options.dolc = 0;
options.lcm.seeddef = 'vats';
options.lcm.odir = '';
options.lcm.omask = [];
options.lcm.struc.espace = 1;
options.lcm.cmd = 1;
options.uipatdirs = {''};

options.lc.general.parcellation = 'AICHA reordered (Joliot 2015)';
options.lc.general.parcellationn = 2;
options.lc.graph.struc_func_sim = 0;
options.lc.graph.nodal_efficiency = 0;
options.lc.graph.eigenvector_centrality = 0;
options.lc.graph.degree_centrality = 0;
options.lc.graph.fthresh = NaN;
options.lc.graph.sthresh = NaN;
options.lc.func.compute_CM = 0;
options.lc.func.compute_GM = 0;
options.lc.func.prefs.TR = 2.69;
options.lc.struc.compute_CM = 0;
options.lc.struc.compute_GM = 0;
options.lc.struc.ft.method = 'ea_ft_mesotracking_reisert';
options.lc.struc.ft.methodn = 1;
options.lc.struc.ft.do = 1;
options.lc.struc.ft.normalize = 0;
options.exportedJob = 1;





