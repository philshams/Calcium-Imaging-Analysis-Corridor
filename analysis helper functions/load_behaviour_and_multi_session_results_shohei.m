% --------------------
% load behaviour data
% --------------------

 

% find or load behaviour data
disp('loading behaviour... (if behaviour does not start from the first frame pulse, this section should be modified...)');
behaviour_table = load_labview_daq(behaviour_folder, 100);
behaviour_table = decimate_daqdata(behaviour_table, 4, 2.5);        


% make sure behaviour and imaging have same number of frames
assert(size(behaviour_table,1)==size(multi_session_results.dff{session}(1).activity,2),...
    'different number of imaging and behaviour frames -- try fix_activity_data_dummy_frame.m, or plot behaviour_table.frame_pulse to check for a time to start the behaviour from')



% get stimulus indicies
disp('getting stimulus onset indices...');
get_stimulus_indices_shohei % stored as inds.stim_name / onset.stim_name / offset.stim_name


% trim onset and offset:
% get trial start indices to average data for each trial -- trim off
% stimuli from trials not starting at a1 or ending with rew
first_onset = onset.a1(1); last_offset = offset.r1(end);
for s = 1:length(stims)
   onset.(stims{s}) = onset.(stims{s})(onset.(stims{s}) >= first_onset);
   offset.(stims{s}) = offset.(stims{s})(offset.(stims{s}) >= first_onset);

   onset.(stims{s}) = onset.(stims{s})(onset.(stims{s}) <= last_offset);
   offset.(stims{s}) = offset.(stims{s})(offset.(stims{s}) <= last_offset);       
end