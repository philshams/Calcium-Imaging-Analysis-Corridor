% % % % plot_speed_correlation

    
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
    frames_to_use{bin} = find(ismember(1:length(speed_to_correlate), bin_frames{bin}));
end

% make figure
speed_figure = figure('Name',figure_name,'Position', [797 656 1089 429]); hold on; movegui(gca,'onscreen')
set(speed_figure,'color','black'); speed_figure.InvertHardcopy = 'off';

set(gca,'color',[1 1 1]*.025,'XColor','w','YColor','w')

cmap = parula(max(position_of_max_dff));
cmap(end-bins_per_panel+1:end,:) = repmat([1 1 1],bins_per_panel,1);

% loop over each cell
correlations = zeros(length(cells_to_use),2);
for cell_num = 1:length(cells_to_use)
    
    cell_id = cells_to_use(cell_num);
    preferred_bin = position_of_max_dff(cell_num);
    
    if within_preferred_bin
        [R, P] = corrcoef(behaviour_table.speed(frames_to_use{preferred_bin}),session_results.dff(cell_id).activity(frames_to_use{preferred_bin}));
    else
        [R, P] = corrcoef(behaviour_table.speed,session_results.dff(cell_id).activity);
    end
    
    correlations(cell_num,1) = R(2);
    correlations(cell_num,2) = P(2);

    s = scatter(position_of_max_dff(cell_num) / bins_per_panel - 1/(2*bins_per_panel), correlations(cell_num,1), ...
        'markerfacecolor', cmap(original_position_of_max_dff(cell_num),:),'markerfacealpha', 1 - .8*(abs(P(2)) > .001),...
            'markeredgecolor',[1 1 1],'markeredgealpha',.2);

end

% plot 0 correlation
plot(xlim, [0 0],'linestyle','-','color',[1 1 1 .5]);
plot(xlim, [-.1 -.1],'linestyle',':','color',[1 1 1 .2]);
plot(xlim, [.1 .1],'linestyle',':','color',[1 1 1 .2]);

% show stim onsets
ylim(ylim)
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
title(['Correlation to speed by preferred location in corridor'],'color','w')
xlabel('position in corridor','color','w')
ylabel('correlation coefficient','color','w')


