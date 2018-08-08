
% % % % find_active_cells_to_use
cells_to_use = {};


    
active_cells = [];
if active_cells_only
    
    % loop across cells
    for cell = 1:length(session_results.dff)    
        
        % extract data for the current cell
        curr_cell_activity = session_results.dff(cell).activity;    
        
        % look at just negative values and their reflection
        rectified_negative_activity = [curr_cell_activity(curr_cell_activity<0) abs(curr_cell_activity(curr_cell_activity<0))];
        
        % get 5x STD of this rectified histogram
        activity_threshold = 5*std(rectified_negative_activity);
        
        % check if this cell is active
        proportion_activity_over_threshold = sum(curr_cell_activity>activity_threshold) / length(curr_cell_activity);
        
        % include if over threshold
        if proportion_activity_over_threshold > active_cell_threshold
            active_cells(end+1) = cell;
        end
    end
    
    cells_to_use = active_cells;
    disp([num2str(length(active_cells)) ' of ' num2str(length(session_results.dff)) ' cells active '])
    figure_name = 'binned activity of all active cells';
else
% if not filtering by activity, include all cells       
    cells_to_use = 1:size(position_response_array.dff,2);
    figure_name = 'binned activity of all cells';
end 

position_response_array.dff_active = position_response_array.dff(:,cells_to_use,:);