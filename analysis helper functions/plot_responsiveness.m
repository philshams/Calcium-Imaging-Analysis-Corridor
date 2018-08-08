% % % % plot_responsiveness

    
% get mean responses by position
mean_dff_by_position = squeeze(nanmean(position_response_array.dff_active(:,:,:),3))';

% sort mean responses by position of max responses
[~, position_of_max_dff] = max(mean_dff_by_position,[],2);
    
original_position_of_max_dff = position_of_max_dff;

    
% format speed / acceleration
speed_to_correlate = behaviour_table.speed;
acceleration = [0; diff(behaviour_table.speed)];

% % get frames to use indices
clear cell;
frames_to_use=cell(num_position_bins,1);
for bin = 1:num_position_bins
    frames_to_use{bin} = find(~ismember(1:length(speed_to_correlate), bin_frames{bin}));
end

% make figure
z_figure = figure('Name',figure_name,'Position', [697 556 1089 429]); hold on; movegui(gca,'onscreen')
set(z_figure,'color','black'); z_figure.InvertHardcopy = 'off'; hold on


set(gca,'color',[1 1 1]*.025,'XColor','w','YColor','w')

cmap = parula(max(position_of_max_dff));
cmap(end-bins_per_panel+1:end,:) = repmat([1 1 1],bins_per_panel,1);

% loop over each cell
top_z_scores = zeros(length(cells_to_use),2);
for cell_num = 1:length(cells_to_use)
    
    preferred_bin = position_of_max_dff(cell_num);
    
    z_scores = zscore(mean_dff_by_position(cell_num,:));
    top_z_scores(cell_num) = max(z_scores);
    
    s = scatter(position_of_max_dff(cell_num) / bins_per_panel - 1/(2*bins_per_panel), top_z_scores(cell_num), ...
        'markerfacecolor', cmap(original_position_of_max_dff(cell_num),:),'markerfacealpha', .8,...
            'markeredgecolor',[1 1 1],'markeredgealpha',.2);

end

% plot 0 correlation
significant_z_score = prctile(max(normrnd(0,1,12,10000)),95);
plot(xlim, [significant_z_score significant_z_score],'linestyle','-','color',[1 1 1 .5]);
% ylim([2 9])

% show stim onsets
y_lim = ylim;
ylim([0 y_lim(2)])
set(gca, 'XTick', [2,6,10,14,17]+1/2, 'XTickLabel', {'A1','B1','A2','B2','R'},'XColor','w','YColor','w');
line([2,2],10*ylim,'linestyle','--','color',[.7 .2 .3 .4]);
line([6,6],10*ylim,'linestyle','--','color',[0 1 1 .4]);
line([10,10],10*ylim,'linestyle','--','color',[.7 .2 .3 .4]);
line([14,14],10*ylim,'linestyle','--','color',[0 1 1 .4]);
line([17,17],10*ylim,'linestyle','--','color',[0 1 0 .4]);

for x_position = [0 1 3 4 5 7 8 9 11 12 13 15 16 18]
    line([x_position x_position],10*ylim,'linestyle','--','color',[1 1 1 .2]);
end

% set title
% title('Correlation to speed by preferred location in corridor -- within preferred patch','color','w')
title(['Responsiveness by preferred location in corridor'],'color','w')
xlabel('position in corridor','color','w')
ylabel('max z-score','color','w')
