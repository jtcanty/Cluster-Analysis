% Combines data within individual excel files into a single excel file.
% Excel files contain data on the area and number of points in a single
% telomere cluster.

% Created by John Canty
% Last modified 01/03/2015

num = input('Please input the number of cluster excel files to combine: ');

% Create zero matrix of size [num,2]
m = zeros(num,2);

% Iterate over excel files
for i = 1:num
    f = 'roi';
    file = strcat(f,num2str(i),'.xlsx');
    data = xlsread(file,'A1:B1');
    m(i,:) = data;
end

% Write matrix into excel file
name = input('Input file name: ','s');
filename = strcat(name,'.xlsx');
xlswrite(filename,m);
    
