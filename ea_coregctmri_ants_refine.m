function varargout=ea_coregctmri_ants_refine(options)
% This function uses ANTs to register postop-CT to preop-MR.
% __________________________________________________________________________________
% Copyright (C) 2015 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn

if ischar(options) % return name of method.
    varargout{1}='Advanced Normalization Tools (ANTs) + Subcortical Refine';
    varargout{2}={'SPM8','SPM12'};
    varargout{3}=['nan']; % suggestion for alpha-parameter.
    return
end
fprintf('\nInterpolating preoperative anatomical image\n')
ea_normalize_reslicepretra(options);
disp('Done.');
disp('Coregistering postop CT to preop MRI...');
ea_ants([options.root,options.patientname,filesep,options.prefs.prenii_unnormalized],...
          [options.root,options.patientname,filesep,options.prefs.rawctnii_unnormalized],...
          [options.root,options.patientname,filesep,options.prefs.ctnii_coregistered],1,{},1,options);
disp('Coregistration done.');
