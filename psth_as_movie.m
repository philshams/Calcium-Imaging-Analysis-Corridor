% ------------------------------------------
% visualizing PSTH of gCamp movies
% ------------------------------------------
%
%
%
% to use this script, you must have:
% imaging_folder_task: the file path of the tiffs from the session
% psth_save_folder: an existing folder to save the PSTH movies in
% session_results: loaded results.mat file that includes a .xyshifts field,
%                  and, if applicable, a .tforms field
% onset: a variable structure with stimulus onset times
%
%
% the following commented code could get you all of these things: 
%
%
% % file location of behaviour
% behaviour_folder = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171225';
% 
% % file location of results -- a MATLAB structure including a field called 'dff',
% % which is the size of the number of ROIs and includes fields called 'activity' and 'rois'
% results_file = 'C:\Drive\Rotation3\data\shohei_results\results_25_12_17.mat';
% 
% % folder in which you have or would like to save movies of the peri-stimulus activity
% psth_save_folder = 'C:\Drive\Rotation3\data\shohei_psth\';
% 
% % set stims -- should correspond to get_stimulus_indices notation
% stims = {'a1','b1','a2','b2','r1'};
% 
% % load behaviour data and imaging results file
% load_behaviour_and_results_shohei




%% load task stack
if exist('task_stack','var')
    disp('Using existing task tif stack -- clear variable task_stack and restart to load anew')
else
    disp('loading task stack...')
    task_stack = stacksload(imaging_folder_task);
    [nx, ny, nz, nc, nt] = size(task_stack);
    fprintf('stack size is: [%d, %d, %d, %d, %d]\n', nx, ny, nz, nc, nt);
end



%% Loop through movie snips and concatenate stim responses



% pre-allocate psth array for each stimulus
for s = 1:length(stims)
    psth_movie.(stims{s}) = zeros([size(task_stack,1) size(task_stack,2) size(task_stack,3) size(task_stack,4) length(psth_window)],'int16'); 
end


% get stim averaged psth images
disp('averaging across stimulus presentations...')
unpack = ~iscell(task_stack);

% loop acros stimuli
for s = 1:length(stims)
    
    disp(['Stimulus: ' stims{s}])
    
    % take stimulus onset times for that stimulus
    curr_onset_inds = onset.(stims{s});
    
    % exclude stimuli very close to beginning and end of session
    curr_onset_inds = curr_onset_inds(curr_onset_inds>abs(min(psth_window)) & ...
                                    curr_onset_inds<size(task_stack,5)-max(psth_window));
    
    % loop across timepoints in psth
    for tp = psth_window
        
        % get xyshifts to proper time points
        curr_xyshifts = session_results.xyshifts{session_of_interest}(:,:,curr_onset_inds + tp);

        
        % sum each stack over time, using a map/reduce operation
        stacks_sum = stacksreduce(task_stack(:,:,:,:,curr_onset_inds + tp), @accum_stack, @reduce_stack, ...
            curr_xyshifts, 'unpack', false, 'fcn_name', 'averaging');

        % divide by the number of frames to get averages
        avgs = cellfun(@(x) x.sum ./ x.nframes, stacks_sum, 'un', false);

        % return one averaged stack if one input stack
        if unpack && numel(avgs) == 1
            avgs = avgs{1};
        end
        
      % add text in top left corner indicating time relative to stimulus
      for z_pos = 1:size(avgs,3)        
              
                % if sleep was the reference, transform task images
                if isfield(session_results,'ref_id') && session_of_interest ~= session_results.ref_id
                    avgs(:,:,z_pos) = imwarp(avgs(:,:,z_pos), session_results.tforms{session_of_interest}(z_pos),'OutputView', imref2d( size(avgs(:,:,z_pos)) ));
                end                 
              
              text_brightness = prctile(avgs(:),98);
        
              avgs_with_text = insertText(avgs(:,:,z_pos),[10 10],[stims{s} ': ' num2str(psth_window(tp+abs(psth_window(1))+1))],'BoxColor',[0 0 0],'BoxOpacity',0.8,'TextColor',[text_brightness 0 0]);
              avgs(:,:,z_pos) = avgs_with_text(:,:,1);        
      end
      
    % load into psth structure
    psth_movie.(stims{s})(:,:,:,:,tp+abs(psth_window(1))+1) = avgs;
    
    end

    % save psth tensor stacks
    stim_psth = psth_movie.(stims{s});
    save([psth_save_folder '\' stims{s} '_psth'],'stim_psth')
    
end














