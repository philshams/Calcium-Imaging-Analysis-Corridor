
% % % %     create_position_response_array
    

% initialize position response array -- binned position x cells x trials
position_response_array.dff = zeros(num_position_bins, length(session_results.dff), length(onset.(stims{1}))-2);
position_response_array.occupancy = zeros(num_position_bins, length(onset.(stims{1}))-2);
position_response_array.speed = zeros(num_position_bins, length(onset.(stims{1}))-2);
position_response_array.photodiode = zeros(num_position_bins, length(onset.(stims{1}))-2);


% loop across trials
skip_trial_counter = 1; clear cell;
bin_frames = cell(num_position_bins,1);
for trial = 2:length(onset.a1)-1 % skip first and last trials
    disp(['processing trial ' num2str(trial) ' out of ' num2str(length(onset.a1))])

    [~, start_ind] = min(behaviour_table.position_tunnel(offset.r1(trial-1):onset.a1(trial)));
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
                bin_positions = behaviour_table.position_tunnel(start_ind:onset.(stims{s+1})(trial)-1);
            else
            % if the last section, go to end of corridor
                [~, end_ind] = min(behaviour_table.position_tunnel(offset.r1(trial):onset.a1(trial+1)));
                end_ind = end_ind + offset.r1(trial) - 1 - 1;
                bin_positions = behaviour_table.position_tunnel(start_ind:end_ind);
            end
        else
            % if the next stim has arrived
            s = s + 1;
            bin_positions = behaviour_table.position_tunnel(onset.(stims{s})(trial):offset.(stims{s})(trial));
            start_ind = onset.(stims{s})(trial);
        end

        for b = 1:bins_per_panel*corridor_panels(section)
            % get bin indices
            if length(bin_positions) > 100

                position_response_array.occupancy(:,trial-1*skip_trial_counter) = [];
                position_response_array.speed(:,trial-1*skip_trial_counter) = [];
                position_response_array.photodiode(:,trial-1*skip_trial_counter) = [];
                position_response_array.dff(:,:,trial-1*skip_trial_counter) = [];

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
                position_response_array.occupancy(bin,trial-1*skip_trial_counter) = 0;
                position_response_array.speed(bin,trial-1*skip_trial_counter) = NaN;
                position_response_array.photodiode(bin,trial-1*skip_trial_counter) = NaN;
                position_response_array.dff(bin,:,trial-1*skip_trial_counter) = NaN;
                continue
            else
                position_response_array.occupancy(bin,trial-1*skip_trial_counter) = curr_trial_bin_inds(end) - curr_trial_bin_inds(1) + 1;
                position_response_array.speed(bin,trial-1*skip_trial_counter) = mean(behaviour_table.speed(curr_trial_bin_inds));
                position_response_array.photodiode(bin,trial-1*skip_trial_counter) = mean(behaviour_table.photodiode(curr_trial_bin_inds));
            end

            % get the indices for each bin
            bin_frames{bin} = [bin_frames{bin}; curr_trial_bin_inds];


            % loop across cells
            for cell_id = 1:length(session_results.dff)
                % set data of deleted ROIs to NaN
                if isempty(session_results.dff(cell_id).activity)
                    position_response_array.dff(:,cell_id,:) = NaN;
                    continue
                end

                % fill the activity array corresponding to the position bin
                position_response_array.dff(bin,cell_id,trial-1*skip_trial_counter) = mean(session_results.dff(cell_id).activity(curr_trial_bin_inds));

            end

        end
    end
end


