function [coords,trajvector,trajectory,tramat]=ea_reconstruct(patientname,options,side,lnii)
% This function is the heart of Lead-DBS, reconstructing the electrode
% lead trajectory for one side (left/right) of the MR-data. It reads two MR
% images from a folder called 'patientname' and iteratively reconstructs a
% line in 3D-space that best describes the electrode trajectory.
% __________________________________________________________________________________
%
% Inputs:   patientname     ??? String of folder and root of filenames. Files
%                             should be called e.g.
%                             'MustermannMax/MustermannMax_tra_brain_A3_final.nii'
%                             and
%                             'MustermannMax/MustermannMax_cor_brain_A3_final_opt.nii'
%                             and reside within the folder specified by
%                             options.root. Note that an exact
%                             normalization into MNI-space is crucial for
%                             Lead to work correctly.
%           options         ??? Struct containing various options, see e.g.
%                             ea_defaultoptions.m
%           side            ??? which side of the brain shall be
%                             reconstructed. 1 > right hemisphere, 2 > left hemisphere. 
% ----------------------------------------------------------------------------------
% 
% Outputs:  coords          ??? 8x3 vector of electrode coordinates in
%                             mm-representations within MNI-space (if
%                             MR-images have been normalized correctly).
%           trajvector      ??? 3 element vector describing the traversing
%                             direction of the lead trajectory.
%           trajectory         ??? nx3 vector describing the fitted line of the
%                             trajectory.
%           tramat          ??? 4x4 matrix describing the normalization of
%                             MR-images. This is used to reconstruct the
%                             distances of the electrode contacts in
%                             MNI-space (since the distance has changed
%                             from e.g. 2mm in native space due to
%                             normalization).
%                             
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn

options.axiscontrast=3;
imat(:,:,:,1)=lnii.img;

ea_showdis('Preparing contrasted volume...',options.verbose);
lnii.img=ea_gencontrastimage(imat,options.axiscontrast);

trajectory=[]; % empty initialization.
for refine=0:options.refinesteps
    [trajectory,trajvector]=ea_reconstruct_trajectory(trajectory,lnii,side,refine,options);
end






%% determine height of last electrode

%detdiams=detrend(diams);


if options.verbose>1; di=figure('name','Finding local maxima in diameters...','numbertitle','off'); end
if options.verbose>2; close(di); end





% find local maxima in diameters.


% first, calculate distance between contacts.
% rename matfile to text

    tramat=eye(4);



[~,~,dist]=ea_calc_distance(options.elspec.eldist,trajvector,tramat(1:3,1:3),[options.root,patientname,filesep,'lpost.nii']);
% zdist is the distance between electrodes in z-direction.
zdist=dist/norm(trajvector);




% 
% % transform trajectory to mm space:
% 
%             if ~isempty(trajectory)
%                 trajectory=ea_map_coords(trajectory', [options.root,patientname,filesep,options.prefs.tranii])';
%             end

[coords,goodz]=ea_reconstruct_coords(trajectory,trajvector,options);




% determine coords by goodz, trajectory and correction term.
% 
% correction=[0,0,0];
% try
%     coords=ea_findcoords(goodz(1),trajectory,trajvector,dist,correction,options);
% catch
%     ea_showdis('Coords not found.',options.verbose);
%     return
% end





