
% % % % plot_by_trial


% get mean responses by position
mean_dff_by_position = squeeze(nanmean(position_response_array.dff_active(:,:,:),3))';
% mean_dff_by_position = squeeze(nanmean(position_response_array.dff(:,:,:),3))';

% sort mean responses by position of max responses
[~, position_of_max_dff] = max(mean_dff_by_position,[],2);
[~, position_sort_ind] = sort(position_of_max_dff);

% get indices of cells responding maximally to this stimulus
sorted_position_of_max_dff = position_of_max_dff(position_sort_ind);

% get cells to use for this analysis
cells_of_interest = find(ismember(ceil(sorted_position_of_max_dff / bins_per_panel),stimuli_of_interest));


% get number of trials
num_trials = size(position_response_array.dff_active(:,:,:),3);


% now that they're ordered, get mean across cells of interest
mean_dff_by_position_across_cells =  squeeze(nanmean(position_response_array.dff_active(:,position_sort_ind(cells_of_interest),:),2));
% mean_dff_by_position_across_cells =  squeeze(nanmean(position_response_array.dff(:,position_sort_ind(cells_of_interest),:),2));


% ------------------------------------
% plot avg over position, over trials
% ------------------------------------

% set x position
x_position_corridor = linspace(0 + 1/(bins_per_panel),num_position_bins/bins_per_panel - 1/(bins_per_panel),num_position_bins);

% tag position bins of interest
clear cell
position_bin_names_speed = cell(length(position_bin_names_activity),1);
for bin = 1:length(position_bin_names_activity)
    position_bin_names_speed{bin} = [position_bin_names_activity{bin} ' speed'];
end

% make figure
trial_figure = figure('Name',figure_name,'Position', [250 609 1054 659]); hold on; movegui(gca,'onscreen')
set(trial_figure,'color','black'); trial_figure.InvertHardcopy = 'off';


% plot each position bin across trials
cmap = num2cell([parula(length(position_bin_names_activity)) ones(length(position_bin_names_activity),1)*.4],2);
p = {}; s = {};

subplot(2,1, 1);

for bin = 1:length(position_bins)
    
    cur_position_inds = [];
    for stim_occurence = 1:size(position_bins{bin},1)
        cur_position_occurence_inds = find(x_position_corridor>position_bins{bin}(stim_occurence)-1 & x_position_corridor<position_bins{bin}(stim_occurence));
        cur_position_inds = [cur_position_inds cur_position_occurence_inds(1):cur_position_occurence_inds(end)];
    end
    
    cur_activity_over_trials = nanmean(mean_dff_by_position_across_cells(cur_position_inds,:),1);
    cur_activity_over_trials_to_plot = filter(gauss_filt,1, [flip(cur_activity_over_trials) cur_activity_over_trials flip(cur_activity_over_trials)]);
    cur_activity_over_trials_to_plot = cur_activity_over_trials_to_plot(length(cur_activity_over_trials)+1:2*length(cur_activity_over_trials));
    
    p{bin} = plot(cur_activity_over_trials_to_plot,'linewidth',4,'linestyle','-'); hold on
    set(p{bin},'color',cmap{bin})

end

title([type_of_cells ' -- activity during ' stimulus_type_name ' (c = ' num2str(length(cells_of_interest)) ' / ' num2str(length(position_of_max_dff)) ')'],'color','w');
ylabel('activity (df/f)','color','w')
set(gca,'color',[1 1 1]*.025,'XColor','w','YColor','w','YColor','w')

l = legend(position_bin_names_activity,'textcolor','white','position',[0.8110 0.8157 0.1830 0.1770]);

% plot speed as well
subplot(2,1,2);

for bin = 1:length(position_bins)
    
    cur_position_inds = [];
    for stim_occurence = 1:size(position_bins{bin},1)
        cur_position_occurence_inds = find(x_position_corridor>position_bins{bin}(stim_occurence)-1 & x_position_corridor<position_bins{bin}(stim_occurence));
        cur_position_inds = [cur_position_inds cur_position_occurence_inds(1):cur_position_occurence_inds(end)];
    end    
    
    cur_speed_over_trials = nanmean(position_response_array.speed(cur_position_inds,:));
    cur_speed_over_trials_to_plot = filter(gauss_filt,1, [flip(cur_speed_over_trials) cur_speed_over_trials flip(cur_speed_over_trials)]);
    cur_speed_over_trials_to_plot = cur_speed_over_trials_to_plot(size(position_response_array.speed,2)+1:2*size(position_response_array.speed,2));    
    
    s{bin} = plot(cur_speed_over_trials_to_plot*80/5,'linewidth',4, 'linestyle','-'); hold on
    set(s{bin},'color',cmap{bin}) 
end
title(['speed'],'color','w');
ylabel('speed (cm/s)','color','w')
set(gca,'color',[1 1 1]*.025,'XColor','w','YColor','w')
xlabel('trials')

