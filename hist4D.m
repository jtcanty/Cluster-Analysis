% John Canty                                          Created 08/16/2016
% Yildiz Lab 

function [M,voxel_size] = hist4D(x,y,z)
% Creates a 3D density plot from 3D data.
% Adapted from Alistair Boettiger's hist4 function.
% Source: https://github.com/AlistairBoettiger/matlab-storm

%------------------------------------------------------------------------%
% Required Inputs:
%   x,y,z - 3D vector data
%
%   z is already plotted as nm!
%------------------------------------------------------------------------%
% Outputs:
%   M4seg - a 3D matrix containing elements that are voxels. The value of each
%   voxel equals the number of molecular localizations within the voxel.
%
%------------------
%% Main function %%
%------------------
x = data(:,2);
y = data(:,3);
z = data(:,17);

% Default parameters
bins = [100,100,100];
datatype = 'uint16';
pixel_nm = 123;

xbins = bins(1);
ybins = bins(2);
zbins = bins(3);

%% ------------Generate 3D density plot-----------------------------------
% Normalize spot coordinates and center grid around centroid of cluster
x_c = sum(x)/length(x);
y_c = sum(y)/length(y);
z_c = sum(z)/length(z);

cd_norm = [x-x_c,y-y_c,z-z_c];
x_n = cd_norm(:,1);
y_n = cd_norm(:,2);
z_n = cd_norm(:,3);

% Initialize histogram
x_r = [min(x_n),max(x_n)];
y_r = [min(y_n),max(y_n)];
z_r = [min(z_n),max(z_n)];


Xd = linspace(x_r(1),x_r(2),xbins);
Yd = linspace(y_r(1),y_r(2),ybins);
Zd = linspace(z_r(1),z_r(2),zbins);
Zd = [Zd,Inf];

M = zeros(xbins,ybins,zbins,datatype);
for i=1:zbins
    inplane = z_n>Zd(i)&z_n<Zd(i+1);
    xi = x_n(inplane);
    yi = y_n(inplane);
    M(:,:,i) = hist3([yi,xi],{Yd,Xd});
end
    
voxel_size = abs((Xd(1)-Xd(2))*abs(Yd(1)-Yd(2))*abs(Zd(1)-Zd(2)));
