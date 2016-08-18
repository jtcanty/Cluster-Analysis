% John Canty                                          Created 08/17/16
% Yildiz Lab

% Identifies 3D cluster from 3D density plots. Performs Gaussian smoothing
% on the density plot followed by a watershed algorithm. Next, the density
% plot is displayed and the volume of the structure is determined.
%
% Adapted from Alistair Boettiger's findclusters3D.m function

%------------------------------------------------------------------------%
% Inputs:
%    M = 3D matrix outputted from hist4D.m.
%    voxel_size = The volume of a given voxel bin in nm^3
%
% Outputs:
%   
%
% Required Functions:
%    fspecial3.m - Generates a filter to be applied to the 3D density plot
%    PATCH_3Darray.m - Displays the 3D density plot as a patch object of voxels 

function subcluster = cluster3D(file)

%% Default parameters
min_voxels = 10;

%% File opening
data = dlmread(file,'\t',1,0); % Read the file
x = data(:,2);
y = data(:,3);
z = data(:,17); %in nm
   
%% Generate 3D density plot from data
[M,voxel_size] = hist4D(x,y,z);

%% Apply gaussian smoothing and watershed
% apply gaussian filtering
gaussblur = fspecial3('gaussian',[3,3,6]);
Mg = imfilter(M,gaussblur,'replicate');
 
% classic watershed filter
W = max(Mg(:)); 
L = watershed(double(W-Mg));  
Mseg = Mg;
Mseg(L==0) = 0;

% Plot 3D density
PATCH_3Darray(Mseg)
xlabel('x');ylabel('y');zlabel('z');
 
% Clear small voxel sizes.
bw = Mseg>0; 
R = regionprops(bw,Mseg,'PixelValues','WeightedCentroid','BoundingBox','PixelList');
lengths = cellfun(@length, {R.PixelValues});
Rt = R(lengths>minvoxels);
Nsubclusters = length(Rt);

% Generate cluster statistics
for j=1:Nsubclusters
    subcluster.Nsubclusters = length(Rt)
    subcluster.Nvoxels = Rt.PixelValues
    subcluster.medianvox = 
    subcluster.meanvox = 
    subcluster.maxvox = 
    subcluster.volume = 



