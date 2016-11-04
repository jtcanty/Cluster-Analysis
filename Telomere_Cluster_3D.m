% John Canty                                       Created: 01/03/15
% Yildiz Lab                                    

% Adapted from Jigar N Bandaria's code

% Description
% Takes an outputted text file from RipleyK.m and extracts the drift
% corrected x/y coordinates of fluorescent spots and the k-values of each
% spot.  A figure is generated in a 2x2-pixel around the spot with the
% highest k-value.  After the user manually modifies the cluster, the data
% are deleted from the original set of x/y-coordinates and the spot with
% the next highest k-value is identified.  The above process is then
% repeated until no spots are left, or the user manually exits.

% Updates:
%       01/03/15 - Added looping over files and saving features
%       08/21/15 - Organization
%       11/3/15 - Included 3D functionality

% Open files
clear all;
dirData = dir('roi*_output.txt');
dirDataCell = {dirData.name};
[dirDataSort,idx] = sort_nat(dirDataCell);
num = numel(dirDataSort);

% Default parameters
pixel = 122;

for i = 1:num
    file = dirDataSort{i};
    data = dlmread(file,'\t',1,0); % Read the file
    figure(1); % Initialize figure
    h = gcf; % Create figure handle

    while length(data) > 0
        % Find coordinates of point with max k value
        [max_val,max_idx]=max(data(:,4)); 
        x = data(max_idx,1); 
        y = data(max_idx,2);
        z = data(max_idx,3);
        
        % Identifying points within 2x2x2 pixels
        cand_point_x=find(data(:,1)>x-2 & data(:,1)<x+2); 
        list2=data(cand_point_x,:); 
        data(cand_point_x,:)= []; 
        
        cand_point_y=find(list2(:,2)>y-2 & list2(:,2)<y+2); 
        list3=list2(cand_point_y,:);
        list4 = list3;
        list_save=list4; % Saving list of coordinates for later

        % Generate plot
        plot(list4(:,1),list4(:,2),'*', 'color', 'green','MarkerSize', 10); hold on;
        brush on;
        axesObjs = get(h, 'Children');  % Axes handles
        %disp(axesObjs);
        dataObjs = get(axesObjs, 'Children'); % Handles to low-level graphics objects in axes
        %disp(dataObjs); 

        % Data from low-level graphics objects
        xdata = get(dataObjs, 'XData');  
        ydata = get(dataObjs, 'YData');
        locs3 = horzcat(transpose(xdata),transpose(ydata));
        disp('The number of points found in this cluster: ');
        disp(length(list4(:,1)));

        % Pause program while editing points
        disp('Hit return, then enter, after done editing');
        pause

        % Data from low-level graphics objects
        xremain = get(dataObjs, 'XData'); 
        yremain = get(dataObjs, 'YData');
        locs4 = horzcat(transpose(xremain),transpose(yremain));
        d = find(isnan(locs4(:,2)));
        del5 = locs4(d,:);
        locs4(d,:) = [];
        disp('The number of points remaining in this cluster: ')
        num = length(locs4);
        disp(num);
       
        % Calculate volume of modified cluster using alpha shapes
        shp = alphaShape(locs4(:,1),locs4(:,2),locs4(:,3));
        convhull = alphaShape(locs4(:,1),locs4(:,2),locs4(:,3),Inf);
        alpha_vol = volume(shp);
        convhull_vol = volume(convhull);
        vol_num = [alpha_vol,convhull_vol,num];
        
        % Plot alpha shape over scatter plot
        hold on
        plot(shp);
        alpha(0.5);
        
        % Save final data coordinates
        fname=strcat('roi',num2str(i),'_remain.txt');
        save(fname, 'locs4', '-ascii', '-tabs');
   
        % Decide whether or not to save the file.
        prompt = 'Do you wish to save this file? Press any key followed by enter: ';
        result = input(prompt,'s');
        if isempty(result)   
        else 
            prompt = 'Please input file name to save: ';
            pic = input(prompt,'s') 
            savefig(h,pic) % Save figure
            excel = strcat(pic,'.xlsx');
            xlswrite(excel,vol_num) % Save area of cluster into excel spreadsheet
        end    

        prompt = 'To view next cluster hit enter. To continue editing, press any key followed by enter: ';
        str = input(prompt,'s');
        clf(h,'reset')
        if isempty(str)
            break
        end
    end
    close(h)

end
