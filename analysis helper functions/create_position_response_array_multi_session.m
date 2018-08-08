
% % % %     create_position_response_array_multi_session_multi_session
    

multi_session_results = load(results_file);
num_sessions = length(multi_session_results.avg_regs);
cells_to_use = {};
activity_struct = cell(1,length(multi_session_results.avg_regs));
behaviour_tables = cell(1,length(multi_session_results.avg_regs));
    
    
for session = 1:num_sessions
    

    % get behaviour folder    
    behaviour_folder = multi_session_results.behaviourpath{session};    
    
    % load behaviour data and imaging results file
    load_behaviour_and_multi_session_results_shohei
    behaviour_tables{session} = behaviour_table;
        
    % take the gCamp activity signal
    activity_struct{session} = multi_session_results.dff{session};
    
    %     % (only during stable epoch)
    %     trial_onset_inds = [intersect(trial_onset_inds, multi_session_results{session}.dff(1).stable_epoch(1):multi_session_results{session}.dff(1).stable_epoch(2))];
    
    % initialize position response array -- binned position x cells x trials
    position_response_array_multi_session.dff{session} = zeros(num_position_bins, length(activity_struct{session}), length(onset.(stims{1}))-2);
    position_response_array_multi_session.occupancy{session} = zeros(num_position_bins, length(onset.(stims{1}))-2);
    position_response_array_multi_session.speed{session} = zeros(num_position_bins, length(onset.(stims{1}))-2);
    position_response_array_multi_session.photodiode{session} = zeros(num_position_bins, length(onset.(stims{1}))-2);
    
    
    % loop across trials
    skip_trial_counter = 1; clear cell;
    bin_frames = cell(num_position_bins,1);
    for trial = 2:length(onset.a1)-1 % skip first and last trials
        disp(['processing trial ' num2str(trial) ' out of ' num2str(length(onset.a1))])
        
        [~, start_ind] = min(behaviour_tables{session}.position_tunnel(offset.r1(trial-1):onset.a1(trial)));
        start_ind = start_ind + offset.r1(trial-1) - 1;
        
        % do this so start_ind in loop works
        bin_inds = start_ind-1;
        bin = 0;
        s = 0;
        skip_trial = false;
        
        % loop across position bins
        for section = 1:length(corridor_panels)
            
            % if any section is screwed up, move on to the next trial
            if skip_trial
                break
            end            
            
            % if the panel is not a grating
            if corridor_closed_loop(section)
                % start after the offset of previous stimulus
                if section > 1
                    start_ind = offset.(stims{s})(trial)+1;
                end
                
                % if not the last section
                if section < length(corridor_panels)
                    % ends just before the onset of the upcoming stim
                    bin_positions = behaviour_tables{session}.position_tunnel(start_ind:onset.(stims{s+1})(trial)-1);
                else
                % if the last section, go to end of corridor
                    [~, end_ind] = min(behaviour_tables{session}.position_tunnel(offset.r1(trial):onset.a1(trial+1)));
                    end_ind = end_ind + offset.r1(trial) - 1 - 1;
                    bin_positions = behaviour_tables{session}.position_tunnel(start_ind:end_ind);
                end
            else
                % if the next stim has arrived
                s = s + 1;
                bin_positions = behaviour_tables{session}.position_tunnel(onset.(stims{s})(trial):offset.(stims{s})(trial));
                start_ind = onset.(stims{s})(trial);
            end

            for b = 1:bins_per_panel*corridor_panels(section)
                % get bin indices
                if length(bin_positions) > 100
                    
                    position_response_array_multi_session.occupancy{session}(:,trial-1*skip_trial_counter) = [];
                    position_response_array_multi_session.speed{session}(:,trial-1*skip_trial_counter) = [];
                    position_response_array_multi_session.photodiode{session}(:,trial-1*skip_trial_counter) = [];
                    position_response_array_multi_session.dff{session}(:,:,trial-1*skip_trial_counter) = [];
                    
                    disp(['trial ' num2str(trial) ' excluded from analysis!'])
                    skip_trial = true; skip_trial_counter = skip_trial_counter + 1;
                    break                    
                end
                 curr_trial_bin_inds = find(bin_positions - bin_positions(1) >= ...
                                    (bin_positions(end)-bin_positions(1)) / (bins_per_panel*corridor_panels(section))*(b-1) & ...
                                         bin_positions - bin_positions(1) <= ...
                                         (bin_positions(end)-bin_positions(1)) / (bins_per_panel*corridor_panels(section))*b ) + start_ind - 1;

                % go to next bin index
                bin = bin + 1;
                
                % don't count if there are no trials of if the mouse is stationary
                if isempty(curr_trial_bin_inds) 
                    % get the speed and occupancy data
                    position_response_array_multi_session.occupancy{session}(bin,trial-1*skip_trial_counter) = 0;
                    position_response_array_multi_session.speed{session}(bin,trial-1*skip_trial_counter) = NaN;
                    position_response_array_multi_session.photodiode{session}(bin,trial-1*skip_trial_counter) = NaN;
                    position_response_array_multi_session.dff{session}(bin,:,trial-1*skip_trial_counter) = NaN;
                    continue
                else
                    position_response_array_multi_session.occupancy{session}(bin,trial-1*skip_trial_counter) = curr_trial_bin_inds(end) - curr_trial_bin_inds(1) + 1;
                    position_response_array_multi_session.speed{session}(bin,trial-1*skip_trial_counter) = mean(behaviour_tables{session}.speed(curr_trial_bin_inds));
                    position_response_array_multi_session.photodiode{session}(bin,trial-1*skip_trial_counter) = mean(behaviour_tables{session}.photodiode(curr_trial_bin_inds));
                end
                
                % get the indices for each bin
                bin_frames{bin} = [bin_frames{bin}; curr_trial_bin_inds];
                
                
                % loop across cells
                for cell_id = 1:length(activity_struct{session})
                    % set data of deleted ROIs to NaN
                    if isempty(activity_struct{session}(cell_id).activity)
                        position_response_array_multi_session.dff{session}(:,cell_id,:) = NaN;
                        continue
                    end
                    
                    % fill the activity array corresponding to the position bin
                    position_response_array_multi_session.dff{session}(bin,cell_id,trial-1*skip_trial_counter) = mean(activity_struct{session}(cell_id).activity(curr_trial_bin_inds));
                
                end
                
            end
        end
    end



end
