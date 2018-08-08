% --------------------------------------------
% Put data together for time series analysis
% --------------------------------------------


% name of files currently containing data for each analyzed session
session_files = {};
session_file{1} = 'C:\Drive\Rotation3\data\shohei_results\results_25_12_17.mat';
session_file{2} = 'C:\Drive\Rotation3\data\shohei_results\results_27_12_17.mat';


% name of folders with the behaviour data
behaviour_folder = {};
behaviour_folder{1} = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171225';
behaviour_folder{2} = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171227';

% name the output folder
resultspath = 'C:\Drive\Rotation3\data\shohei_results\results_first_two_sessions.mat';


%% Go through fields and save data together

clear cell
session_results = cell(1,length(session_file));

avg_regs = cell(1,length(session_file));
avg_regs_tf = cell(1,length(session_file));
dff = cell(1,length(session_file));
stackspath = cell(1,length(session_file));
behaviourpath = cell(1,length(session_file));


for session = 1:length(session_file)
   
    curr_session_results = load(session_file{session});
   
    avg_regs{session} = curr_session_results.avg_regs{end};
    
    if isfield(curr_session_results, 'avg_regs_tf')
        avg_regs_tf{session} = curr_session_results.avg_regs_tf{end};
    else
        avg_regs_tf{session} = [];
    end
    
    dff{session} = curr_session_results.dff(end,:);
    
    stackspath{session} = curr_session_results.stackspath{end};    
    
    behaviourpath{session} = behaviour_folder{session};
end

save(resultspath, 'avg_regs', '-v7.3');
save(resultspath, 'avg_regs_tf', '-append');
save(resultspath, 'dff', '-append');
save(resultspath, 'stackspath', '-append');
save(resultspath, 'behaviourpath', '-append');

