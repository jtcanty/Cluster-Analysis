% http://stackoverflow.com/questions/24443370/

% Takes an input of coordinates and bins them into a 2D grid. A 2D
% histogram is plotted and fit to an elliptical gaussian function.
% Created by John Canty 08/17/2015

% Important variables:
% stat = FWHM of both the x and y coordinates


clear all;
num = input('Number of roi files? ');
stat = [];

for i = 1:num 
% Open file
file = strcat('roi',num2str(i),'_output','.txt');
data = dlmread(file,'\t',1,0); 

% Find max k-value point and points within 4x4 ROI
[max_val,max_idx]=max(data(:,3)); 
x_val = data(max_idx,1);
y_val = data(max_idx,2);
cand_point_x = find(data(:,1)>x_val-2 & data(:,1)<x_val+2); 
list2 = data(cand_point_x,:); 
data(cand_point_x,:)= []; 

cand_point_y=find(list2(:,2)>y_val-2 & list2(:,2)<y_val+2); 
list3=list2(cand_point_y,:);
list4 = list3;
list_save=list4;

% Normalize coordinates and center grid around highest k-value point.
cd = list_save(:,[1 2]);
cd_norm = [cd(:,1)-x_val,cd(:,2)-y_val];

% Initialize 10x10 grid
grid = linspace(-2,2,11);
[bincount,ind] = histc(cd_norm,grid,1);
ind(ind == 11) = 10;

% Fit data to 2D Gaussian
h = accumarray(ind,1,[10 10]);
x = linspace(-5,5,10);
y = linspace(-5,5,10);
[fitresult, gof] = Data_Fit(x,y,h)

% Obtain std. dev. and determine fwhm
coeff = coeffvalues(fitresult);
sigx = coeff(3);
sigy = coeff(5);
fwhm_x = 2*sqrt(2*log(2))*sigx;
fwhm_y = 2*sqrt(2*log(2))*sigy;
stat = [stat;[fwhm_x fwhm_y]]

% Alternative histogram plot
% hist3(cd_norm)
end

% Save to file
save ('fwhm_data.txt', 'stat', '-ascii', '-tabs');

