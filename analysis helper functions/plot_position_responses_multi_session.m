% % % % plot_position_responses
num_sessions = length(multi_session_results.avg_regs);

for session = 1:num_sessions
% get mean responses by position
mean_dff_by_position = squeeze(nanmean(position_response_array_multi_session.dff_active{session}(:,:,:),3))';
% mean_dff_by_position = squeeze(nanmean(position_response_array_multi_session.dff{session}(:,:,:),3))';
% make figure
if session == 1
    activity_figure = figure('Name',figure_name,'Position', [236 603 1401 620]); hold on; movegui(gca,'onscreen')
    activity_figure.InvertHardcopy = 'off';
else
    figure(activity_figure)    
end
subplot(3,num_sessions, [session num_sessions+session])

% sort mean responses by position of max responses
if session == 1 || ~use_first_session_ordering % sort using indices from first iteration
    [~, position_of_max_dff] = max(mean_dff_by_position,[],2);
    [~, position_sort_ind] = sort(position_of_max_dff);
end
mean_dff_by_position = mean_dff_by_position(position_sort_ind,:);

% filter for viewing pleasure
mean_dff_by_position = imgaussfilt(mean_dff_by_position,1,'FilterSize',[1 3]);

% plot activity
activity_map = imagesc(mean_dff_by_position);

% format plot and color

% if session == 1
cb = colorbar('color','w','position',[.47+.44*(session-1) 0.4090 0.0243 0.5164]);
title(cb,'df/f','color','w');
activity_range = [prctile(mean_dff_by_position(:),5) prctile(mean_dff_by_position(:),95)]; 
% end

caxis(activity_range)

title(['V1 activity across corridor -- session ' num2str(session)],'color','w')

% format axes
set(activity_map, 'XData', [0 (num_position_bins-1)/bins_per_panel]);
set(gca, 'XTick', [2,6,10,14,17] - 1/(2*bins_per_panel) + .5, 'XTickLabel', {'A1','B1','A2','B2','R'},'XColor','w','YColor','w');
ylabel('cell num -- sorted by position of peak response','color','w')
axis tight
% xlim([0 18 - 1/(2*bins_per_panel)])

% show stim onsets
line([2,2] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[.7 .2 .3]);
line([6,6] - 1/(2*bins_per_panel),ylim,'linestyle','--','color','m');
line([10,10] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[.7 .2 .3]);
line([14,14] - 1/(2*bins_per_panel),ylim,'linestyle','--','color','m');
line([17,17] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[0 1 0]);

for x_position = [0 1 3 4 5 7 8 9 11 12 13 15 16 18] - 1/(bins_per_panel*2)
    line([x_position x_position],ylim,'linestyle','--','color',[.7 .7 .7 .4]);
end

% prepare speed and occupancy
x_position = linspace(0,num_position_bins/bins_per_panel - 1/(bins_per_panel),num_position_bins);
gauss_filt = gausswin(1); gauss_filt = gauss_filt / sum(gauss_filt);


occupancy = nanmean(position_response_array_multi_session.occupancy{session},2);
occupancy = (occupancy - nanmean(occupancy)) / nanstd(occupancy);
speed = nanmean(position_response_array_multi_session.speed{session},2) * 80 / 5;
photodiode_to_plot = nanmean(position_response_array_multi_session.photodiode{session},2);

% smooth speed and occupancy
occupancy_to_plot = filter(gauss_filt,1, [flip(occupancy); occupancy; flip(occupancy)]);
occupancy_to_plot = occupancy_to_plot(length(occupancy)+1:2*length(occupancy));

speed_to_plot = filter(gauss_filt,1, [flip(speed); speed; flip(speed)]);
speed_to_plot = speed_to_plot(length(speed)+1:2*length(speed));


% plot speed and occupancy
subplot(3,num_sessions, num_sessions*2 +session); hold on
set(gca,'color',[1 1 1]*.05,'XColor','w','YColor','w')
set(activity_figure,'color','black')

% plot occupancy, left yaxis
yyaxis left
plot(x_position,occupancy_to_plot','color',[0 0 1 .8],'linewidth',3)
plot(x_position,photodiode_to_plot','color','white','linewidth',1)
ylabel('occupancy z-score')
axis tight
% xlim([0 18 - 1/(2*bins_per_panel)])

% plot speed, right yaxis
yyaxis right
plot(x_position,speed_to_plot','color',[1 0 0 .8],'linewidth',3)
% ylabel('speed (cm/s)','color','red')
title('speed (cm/s)','color','red')
xlabel('position along corridor')
set(gca, 'XTick', [2,6,10,14,17] - 1/(2*bins_per_panel) + .5, 'XTickLabel', {'A1','B1','A2','B2','R'},'XColor','w','Ycolor','r');

% show stim onsets
line([2,2] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[.7 .2 .3]);
line([6,6] - 1/(2*bins_per_panel),ylim,'linestyle','--','color','m');
line([10,10] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[.7 .2 .3]);
line([14,14] - 1/(2*bins_per_panel),ylim,'linestyle','--','color','m');
line([17,17] - 1/(2*bins_per_panel),ylim,'linestyle','--','color',[0 1 0]);

for x_position = [0 1 3 4 5 7 8 9 11 12 13 15 16 18] - 1/(bins_per_panel*2)
    line([x_position x_position],ylim,'linestyle','--','color',[.7 .7 .7 .4]);
end

end
