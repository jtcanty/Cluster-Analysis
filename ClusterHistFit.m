% John Canty                                   Created: 08/17/15
% Yildiz Lab

% Reference: http://stackoverflow.com/questions/24443370/
% Takes an input of coordinates and bins them into a 2D grid. A 2D
% histogram is plotted and fit to an elliptical gaussian function. Navigate
% to containing folder.

% Modified 08/28/15: compute a bivariate Gaussian function with rotation
% Modified 08/31/15: compute principle components (bug in plotting one of
% them)


num = input('Number of roi files? ');
stat = [];

for i = 1:num 
% Open file
file = strcat('roi',num2str(i),'_output','.txt');
data = dlmread(file,'\t',1,0); 


%% ------------Identify Cluster-------------
sz = 1.5; 
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
len = 200;
cd_norm = cd_norm*123;

% Generate grid and bin points into grid
grid = linspace(-len,len,21);
[bincount,ind] = histc(cd_norm,grid,1);
% ind(ind == 21) = 20

% Generate histogram
H = accumarray(ind,1,[21 21]);

%{
%% -------------Fit Parameters----------------------
MDataSize = 20; % size of nxn matrix
% parameters = [Amp,x0,y0,sigma_x,sigma_y,Covxx,Covxy,Covyy,angle(radians)]
x0 = [100,0,0,50,50,1,1,1,0]; % Initial parameter guess
x = x0;
%}

%% -------------Generate coordinate grid to overlay histogram over-------
x_axis = linspace(-len,len,21);
y_axis = linspace(-len,len,21);
[X,Y] = meshgrid(x_axis,y_axis);
xdata = zeros(size(X,1),size(Y,2),2);


%% --------------Perform Fit------------------------
%[x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussianRot,x0,xdata,H)
[fitresult, gof] = GaussFit(x_axis,y_axis, H);


%% --------------PCA Analysis-----------------------
% Solve for the eigenvectors of the covariance matrix
% Covariance matrix = [a b; b c]
coeff = coeffvalues(fitresult);
f = coeff(3);
g = coeff(4);
h = coeff(5);
a = cos(f)^2/(2*g^2) + sin(f)^2/(2*h^2);
b = -sin(2*f)/(4*g^2) + sin(2*f)/(4*h^2);
c = sin(f)^2/(2*g^2) + cos(f)^2/(2*h^2);

CovMInverse = [a b;b c];
CovM = inv(CovMInverse);
[EigVec,EigVal] = eig(CovM);

PrinComp = [EigVal(1,1),EigVal(2,2)];
Std_dev = [sqrt(PrinComp(1)),sqrt(PrinComp(2))];
FWHM = Std_dev*2*sqrt(2*log(2));

% Identify major and minor FWHM
if issorted(FWHM);
    ;
else
    FWHM = sort(FWHM);
    EigVec(:,[1,2]) = EigVec(:,[2,1]);  
end

% Append to array
stat = [stat;[FWHM(1) FWHM(2)]];


%% ---------Plot 2D Profile------------------------
% Plot cross-sections along the eigenvectors
cf = figure(2)
set(cf, 'Position', [20 20 750 700])
alpha(0)
subplot(4,4, [1,2,3,5,6,7,9,10,11])

imagesc(x_axis,y_axis',H)  % scale image
set(gca,'YDir','normal')  % set current axis handle properties
colormap('jet')

% Plot covariance information
string1 = ['            Minor Axis','                       Major Axis', '              Minor Axis FWHM','       Major Axis FWHM'];
string2 = ['       ',num2str(EigVec(:,1)'),'       ',num2str(EigVec(:,2)'),'            ',num2str(FWHM(1)),'                 ',num2str(FWHM(2))];
text(-225,-250,string1,'Color','red')
text(-225,-275,string2,'Color','red')


%% ---------Calculate Cross sections---------------
% Generate points along each eigenvector
EigV1 = EigVec(:,1);
EigV2 = EigVec(:,2);

% First eigenvector
m1 = EigV1(2)/EigV1(1);
b1 = -m1*coeff(1) + coeff(2);
xv1 = grid;
yv1 = m1*xv1 + b1;
EigPoints1 = interp2(X,Y,H,xv1,yv1,'linear');

% Second eigenvector
m2 = EigV2(2)/EigV2(1);
b2 = -m2*coeff(1) + coeff(2);
xv2 = grid;
yv2 = m2*xv2 + b2;
EigPoints2 = interp2(X,Y,H,xv2,yv2,'linear');

% Plot lines
hold on

plot([xv1(1) xv1(size(xv1))],[yv1(1) yv1(size(yv1))],'r') ;
plot([xv2(1) xv2(size(xv2))],[yv2(1) yv2(size(yv2))],'g') ;

hold off

end

% Save to file
xlswrite('fwhm_data.xlsx',stat);
save ('fwhm_data.txt', 'stat', '-ascii', '-tabs');

close all;
 
 


