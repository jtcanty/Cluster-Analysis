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


% Modified 01/03/15: Added looping over files and saving features
% Modified 08/21/15: Organization

clear all;
num = input('Number of roi files? ');

for i = 1:num
    file = strcat('roi',num2str(i),'_output','.txt');
    data = dlmread(file,'\t',1,0); % Read the file
    pixel = 122;
    figure(1); % Initialize figure
    h = gcf; % Create figure handle

    while length(data) > 0
        [max_val,max_idx]=max(data(:,3)); % Finding point with maximum K value
        % Finding coordinates of point is max K value
        x_val=data(max_idx,1); 
        y_val=data(max_idx,2);
        cand_point_x=find(data(:,1)>x_val-2 & data(:,1)<x_val+2); % Finding indices in 2X2 pixel
        list2=data(cand_point_x,:); % Getting points from indices
        data(cand_point_x,:)= []; % Remove selected points from the data array
        % Repeat for y axis
        cand_point_y=find(list2(:,2)>y_val-2 & list2(:,2)<y_val+2); 
        list3=list2(cand_point_y,:);
        list4 = list3;
        list_save=list4; % Saving list of coordinates for later

        % Generate plot
        plot(list4(:,1),list4(:,2),'*', 'color', 'green','MarkerSize', 10); hold on;
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
        keyboard

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

        % Calculate area of modified cluster
        [k,v1] = convhull(locs4(:,1),locs4(:,2),'simplify', false);
        area = (v1)*pixel^2 % initial area calculation
        area_num = [area,num]

        % Decide whether or not to save the file.
        prompt = 'Do you wish to save this file? Press any key followed by enter: ';
        result = input(prompt,'s');
        if isempty(result)   
        else 
            prompt = 'Please input file name to save: ';
            pic = input(prompt,'s') 
            savefig(h,pic) % Save figure
            excel = strcat(pic,'.xlsx');
            xlswrite(excel,area_num) % Save area of cluster into excel spreadsheet
        end    
        % scatter(locs4(:,1),locs4(:,2),'ob');

        prompt = 'To view next cluster hit enter. To continue editing, press any key followed by enter: ';
        str = input(prompt,'s');
        clf(h,'reset')
        if isempty(str)
            break
        end
    end
    close(h)

end
