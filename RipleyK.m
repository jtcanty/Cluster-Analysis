% Input is a number of telomere files to analyze. File base name is tel.
% Outputs a file containing k-values for each input telomere file.
% Created by Jigar Bandaria
% Adapted by John Canty

clear all;
num = input('Number of roi files? ');
base = 'roi';

for i = 1:num
        filename=strcat(base,num2str(i));
        filename1=strcat(filename,'.txt');

        %  Read the file 
        a=dlmread(filename1,'\t',1,0);

        %  Extract the fourth and fifth columns (drift corrected x/y coordinates)
        locs=a(:,(4:5));
        b=locs;

        % Sort first column into rows of ascending order
        sortrows(b);
        locs=ans;

        % Release variables from system memory 
        clear a
        clear b
        clear ans
        r=25; % This sets the maximum radius as 2.5 pixel.
        locs2=locs; % This backs up the copy of original data.
        [m,n]=size(locs); % getting the dimension of locs (original data)
        disp('p5');  % break point

        % this part of the code calculates the euclidean and puts it
        % in the form of a square matrix.
        DX = repmat(locs(:,1),1,m)-repmat(locs(:,1)',m,1); %Generate a matrix of
        % pairwise distances between all x coordinates
        DY = repmat(locs(:,2),1,m)-repmat(locs(:,2)',m,1); %Generate a matrix of 
        % pairwise distances between all y coordinates
        disp('jigar0');
        % Find the norm of the matrices
        DIST=sqrt(DX.^2+DY.^2);%a=10*rand(500);
        clear DX
        clear DY
        disp('jigar1')
        rip_x=zeros(r,length(DIST));%matrix to store the k values at diff r 
        disp('jigar2')
        hist_rip=zeros(r,200); %store histograms for different r
        disp('jigar3')
        n;

        % this part of code caculates the k values for each values of r
        % and calculates their histogram at each r value.
        % Create a histogram of the number of points each point is near within r
        % Create a histogram of the number of points that has <2,<3,<4 points within
        % the r.  Max number of nearby points is set to 200
        % rip_x histogram is a 3D plot of number of points verus k value.  It is a
        % cdf that increase for k value.
        for j=1:r
        b=find(DIST<j*0.1);
        c=ceil(b/length(DIST));
        rip_x(j,:)=hist(c,length(DIST));
        hist_rip(j,:)=hist(rip_x(j,:),200);
        hist(rip_x(j,:),200);
        j;
        end
        n;

        % I am reanalyzing data after removing the point with k<3
        temp1=rip_x(3,:);%selecting k value at r=0.3.
        locs(temp1<3,:)=[];
        [m,n]=size(locs);
        clear DIST
        clear b
        clear c
        DX = repmat(locs(:,1),1,m)-repmat(locs(:,1)',m,1);
        DY = repmat(locs(:,2),1,m)-repmat(locs(:,2)',m,1);
        DIST=sqrt(DX.^2+DY.^2);%a=10*rand(500);
        clear DX
        clear DY
        rip_x=zeros(r,length(DIST));
        hist_rip=zeros(r,200);

        for j=1:r
        b=find(DIST<j*0.1);
        c=ceil(b/length(DIST));
        rip_x(j,:)=hist(c,length(DIST));
        hist_rip(j,:)=hist(rip_x(j,:),200);
        j;
        end

        %clear DIST
        clear b
        clear c
        temp1=rip_x(15,:);%selecting k values at r=1.5 so that it is plateau.
        temp2=temp1';
        list1=[locs temp2];
        list2=list1;
        max(list2(:,3));
        max1=ans;
        %sel_and_del(list2(:,1),list2(:,2),'yes')
        %[loc_max1, loc_max2]=max(temp2);
        %comp1=list1(loc_max2,1:2);
        %index1=find(list1(:,1)<(comp1(1)+1.5)& list1(:,1)>(comp1(1)-1.5));
        %list2=list1(index1,1:3);
        %index2=find(list2(:,2)<(comp1(2)+1.5)& list2(:,2)>(comp1(2)-1.5));
        %list3=list2(index2,1:3);
        filename2=strcat(filename,'_output.txt')
        save (filename2, 'list1', '-ascii', '-tabs');

        %hist_15=hist_rip(15,:);
         %[pks,locs]=findpeaks(hist_15,'MINPEAKHEIGHT',24)
end
