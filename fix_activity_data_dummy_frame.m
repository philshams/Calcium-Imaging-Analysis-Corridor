% ------------------------------------------------------------
% Fix data to fit behaviour if an extra dummy frame was added
% ------------------------------------------------------------


% file location of behaviour
behaviour_folder = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171227';

% file location of results -- a MATLAB structure including a field called 'dff',
% which is the size of the number of ROIs and includes fields called 'activity' and 'rois'
results_file = 'C:\Drive\Rotation3\data\shohei_results\results_27_12_17.mat';


% load data and make sure behaviour and imaging have same number of frames
disp('loading imaging results...');
session_results = load(results_file);
disp('loading behaviour...')
behaviour_table = load_labview_daq(behaviour_folder, 100);
behaviour_table = decimate_daqdata(behaviour_table, 4, 2.5);  
    
% compare length of the behaviour data and the length of the activity data
adjust_data = false;
if size(behaviour_table,1)~=size(session_results.dff(1).activity,2)
    if size(behaviour_table,1)==size(session_results.dff(1).activity,2)-1
        disp('different number of imaging and behaviour frames due to a dummy frame')
        adjust_data = true;
    else
        disp('different number of imaging and behaviour frames but not due to a dummy frame')
        disp('try plotting behaviour_table.frame_pulse to check for a time to start the behaviour from')
    end
else
    disp('same number of imaging and behaviour frames -- you''re good to go!')
end


% if activity data is one extra, delete it and resave the data
if adjust_data
    dff = session_results.dff;
    for cell_id = 1:length(dff)
        dff(cell_id).activity = dff(cell_id).activity(1:end-1);
    end
   save(results_file,'dff','-append') 
end
