% RipleyK.m                               % Created by Jigar Bandaria
                                          % Adapted by John Canty

% This script performs the RipleyK algorithm on either 2D/3D data in order
% to determine the K-score of each localization in a telomere cluster. 


% Inputs:
%       Number of telomere files to analyze. 
% Outputs:
%       File containing k-values for each localization of each telomere

% Updates:
%       11/3/2016 - Can accept 3D cluster data in addition to 2D data

% Read in file names
clear all;
dirData = dir('roi*.txt');
dirDataCell = {dirData.name};
[dirDataSort,idx] = sort_nat(dirDataCell);
num = numel(dirDataSort);

% Default parameters
pixels  = 122; % nm
r = 25; % ripleyk radii 2.5 pixel

for i = 1:num
        %  Read file and extract coordinate data. 
        file = dirDataSort{i};
        data = dlmread(file,'\t',1,0);
        locs_sort = data(:,[4:5,18]);
        [m,n]=size(locs_sort);
        locs_sort = sortrows(locs_sort);
        
        %  S
        x = locs_sort(:,1)*pixels;
        y = locs_sort(:,2)*pixels;
        z = locs_sort(:,3); % in nm already

        % Calculate Euclidean between all points and generate square matrix
        dx = repmat(locs_sort(:,1),1,m)-repmat(locs_sort(:,1)',m,1); 
        dy = repmat(locs_sort(:,2),1,m)-repmat(locs_sort(:,2)',m,1); 
        dz = repmat(locs_sort(:,3),1,m)-repmat(locs_sort(:,3)',m,1); 
 
        % Find the norm of the matrices
        norm = sqrt(dx.^2 + dy.^2 + dz.^2);
        clear dx
        clear dy
        clear dz
       
        rip_x = zeros(r,length(norm));%matrix to store the k values at diff r 
        hist_rip = zeros(r,200); %store histograms for different r

        % Create a histogram of the number of points (k-value) each point is near within r
        % Create a histogram of the number of points that has <2,<3,<4 points within
        % the r.  Max number of nearby points is set to 200.
        % rip_x = histogram is a 3D plot of number of points verus k value.  It is a
        % cdf that increase for k value.
        for j = 1:r
            b = find(norm<j*0.1); % convert to pixels
            c = ceil(b/length(norm));
            rip_x(j,:) = hist(c,length(norm));
            hist_rip(j,:)= hist(rip_x(j,:),200);
            hist(rip_x(j,:),200);    
        end
     
        % Remove points with k-value less than 3. Reanalyze data
        temp = rip_x(3,:);%selecting k value at r=0.3.
        locs_sort(temp<3,:)=[];
        [m,n]=size(locs_sort);
        clear norm
        clear b
        clear c
        
        dx = repmat(locs_sort(:,1),1,m)-repmat(locs_sort(:,1)',m,1); 
        dy = repmat(locs_sort(:,2),1,m)-repmat(locs_sort(:,2)',m,1); 
        dz = repmat(locs_sort(:,3),1,m)-repmat(locs_sort(:,3)',m,1); 
        norm = sqrt(dx.^2 + dy.^2 + dz.^2);
        clear dx
        clear dy
        clear dz
       
        rip_x=zeros(r,length(norm));
        hist_rip=zeros(r,200);
        
        for j=1:r
            b=find(norm<j*0.1);
            c=ceil(b/length(norm));
            rip_x(j,:)=hist(c,length(norm));
            hist_rip(j,:)=hist(rip_x(j,:),200);
        end

        clear b
        clear c
        temp = rip_x(15,:);%selecting k values at r=1.5 so that it is plateau.
        list=[locs_sort temp'];
        list2=list;
        max(list2(:,3));
        max1=ans;
       
        % Save file
        fout = strcat('roi',num2str(i),'_output.txt')
        save(fout, 'list', '-ascii', '-tabs');
        
end
