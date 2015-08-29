% John Canty                                   Created: 08/17/15
% Yildiz Lab

% Reference: http://stackoverflow.com/questions/24443370/
% Takes an input of coordinates and bins them into a 2D grid. A 2D
% histogram is plotted and fit to an elliptical gaussian function. Navigate
% to containing folder.

% Last modified 08/28/15: Added function to compute a bivariate Gaussian
% function with rotation
clear all;
num = input('Number of roi files? ');
stat = [];

for i = 1:num 
% Open file
file = strcat('roi',num2str(i),'_output','.txt');
data = dlmread(file,'\t',1,0); 

%% ------------Identify Cluster-------------
sz = 2; 
[max_val,max_idx]=max(data(:,3)); 
x_val = data(max_idx,1);
y_val = data(max_idx,2);
cand_point_x = find(data(:,1)>x_val-sz & data(:,1)<x_val+sz); 
list2 = data(cand_point_x,:); 
data(cand_point_x,:)= []; 

cand_point_y=find(list2(:,2)>y_val-sz & list2(:,2)<y_val+sz); 
list3=list2(cand_point_y,:);
list4 = list3;
list_save=list4;

%% ------------Generate histogram of data-------------
% Normalize spot coordinates and center grid around highest k-value
% spot
cd = list_save(:,[1 2]);
cd_norm = [cd(:,1)-x_val,cd(:,2)-y_val];

% Convert to nm
pixel = 123;
len = 260;
cd_norm = cd_norm*123;

% Generate grid and bin points into grid
grid = linspace(-len,len,21);
[bincount,ind] = histc(cd_norm,grid,1);
% ind(ind == 21) = 20

% Generate histogram
H = accumarray(ind,1,[21 21]);



%% -------------Fit Parameters----------------------
MDataSize = 20; % size of nxn matrix
% parameters = [Amp,x0,y0,sigma_x,sigma_y,Covxx,Covxy,Covyy,angle(radians)]
x0 = [100,0,0,50,50,1,1,1,0]; % Initial parameter guess
x = x0;

%% -------------Generate coordinate grid to overlay histogram over-------
x_axis = linspace(-len,len,21);
y_axis = linspace(-len,len,21);
[X,Y] = meshgrid(x_axis,y_axis);
xdata = zeros(size(X,1),size(Y,2),2);


%% --------------Perform Fit------------------------
%[x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussianRot,x0,xdata,H)
[fitresult, gof] = GaussFit(x_axis,y_axis, H)

%% --------------PCA Analysis-----------------------
% Solve for the eigenvectors of the covariances matrix
% Covariance matrix = [a b; b c]
coeff = coeffvalues(fitresult)
f = coeff(3)
g = coeff(4)
h = coeff(5)
a = cos(f)^2/(2*g^2) + sin(f)^2/(2*h^2)
b = -sin(2*f)/(4*g^2) + sin(2*f)/(4*h^2)
c = sin(f)^2/(2*g^2) + cos(f)^2/(2*h^2)

CovMInverse = [a b;b c]
CovM = inv(CovMInverse)
[EigVec,EigVal] = eig(CovM)

%% ---------Calculate Cross-sections----------------
% Calculate cross-sections along the eigenvectors

%% --------------3D Plot----------------------------

%{
figure(1)
C = del2(H); % Obtaining Laplacian matrix for colormap
%mesh(X,Y,H,C);
hold on
surface(X,Y,D2GaussFunctionRot(x,xdata),'EdgeColor','none') %plot fit
%}

% Perform Fit
%--------------------------------------------------------------------------
% lb = lower boundary
% ub = upper boundary
% lb = [0,-10,-10,0,0,0,0,0,-pi]
% ub = [realmax('double'),20,20,100,100,?,?,?,pi]
%[fitresult, gof] = Data_Fit(x,y,h)

% Initial guess of parameters

%surface(X,Y,D2GaussFunctionRot(x,xdata),'EdgeColor','none')
%{
% Obtain std. dev. and determine fwhm in nm
pix = 123
coeff = coeffvalues(fitresult);
sigx = abs(coeff(3));
sigy = abs(coeff(5));
fwhm_x = pix*2*sqrt(2*log(2))*sigx;
fwhm_y = pix*2*sqrt(2*log(2))*sigy;
stat = [stat;[fwhm_x fwhm_y]];

% Alternative histogram plot
% hist3(cd_norm,[20,20])

%}
end

%{
% Save to file
xlswrite('fwhm_data.xlsx',stat);
save ('fwhm_data.txt', 'stat', '-ascii', '-tabs');
%}

 
 


