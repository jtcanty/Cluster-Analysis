% 


function [QFISHfinalbrushed,STORMfinalbrushed] = NonRigidRegistration(QFISHcoords,STORMcoords,QFISHdata,STORMdata)

Register = 1
while Register == 1
    opt.method='nonrigid';
    [Transform, C]=cpd_register(QFISHcoords,STORMcoords, opt);title('After registering STORM coordinates to QFISH coordinates');

    brush on;
    disp('Clear QFISH (red) points that do not match to STORM centroid(blue).');
    pause

    h = findobj(gca,'Type','line');
    X = get(h,'Xdata');
    Y = get(h,'Ydata');
    STORMcoordsbrushed = [X{1}',Y{1}'];
    QFISHcoordsbrushed = [X{2}',Y{2}'];

    % Append transformed coordinates to QFISH/STORM data variables
    QFISHdatabrush = [QFISHdata(:,[1:9]),QFISHcoordsbrushed];
    STORMdatabrush = [STORMdata(:,[1:4]),STORMcoordsbrushed];

    %Finds the indices of uncleared QFISH/STORM data points using 'isnan', then
    %extracts the corresponding data from QFISHdata and STORMdata and stores it
    %in QFISH/STORMdatamatch variable
    QFISHdatamatch = QFISHdatabrush(~any(isnan(QFISHdatabrush),2),:);
    STORMdatamatch = STORMdatabrush(~any(isnan(STORMdatabrush),2),:);

    % Updated QFISH/STORMcoordsbrushed variables in place to remove brushed
    % objects
    QFISHcoordsbrushed = QFISHdatamatch(:,10:11);
    STORMcoordsbrushed = STORMdatamatch(:,5:6);

    prompt = 'Redo registration? Press any key then enter: ';
    result = input(prompt,'s');
    if isempty(result)
        Register = 0
        QFISHfinalbrushed = QFISHdatamatch;
        STORMfinalbrushed = STORMdatamatch;
        break
    else
        Register = 1
        QFISHcoords = QFISHcoordsbrushed;
        STORMcoords = STORMcoordsbrushed;
    end    
end