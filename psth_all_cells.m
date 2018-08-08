% -------------------------------
% gCamp show PSTHs for all cells
% -------------------------------

% clear variables from other scripts to prevent interference
clear all

% file location of behaviour
behaviour_folder = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171225';

% file location of results -- a MATLAB structure including a field called 'dff',
% which is the size of the number of ROIs and includes fields called 'activity' and 'rois'
results_file = 'C:\Drive\Rotation3\data\shohei_results\results_25_12_17.mat';

% folder in which you have or would like to save movies of the peri-stimulus activity
psth_save_folder = 'C:\Drive\Rotation3\data\shohei_psth\';

% range around stimulus to measure - should start at -20 for the GUI below to work
psth_window = -20:20;

% set stims -- should correspond to get_stimulus_indices notation
stims = {'a1','b1','a2','b2','r1'};

% frame rate in Hz
frame_rate = 30/4;

% load behaviour data and imaging results file
load_behaviour_and_results_shohei

% active cells only?
active_cells_only = true;

% provide threshold of proportion activity > 5 std negative distribution
active_cell_threshold = .005;



%% extract PSTHs

% get the activity PSTH from each cell using session_results.dff
if exist('psth','var')
    disp('Using existing psths -- clear psth variable and restart to calculate anew')
else
    % initialize PSTH array -- cells x timepoints array
    for s = 1:length(stims)
        psth.(stims{s}) = zeros(length(session_results.dff),length(psth_window));
    end

    % loop across cells
    for cell_id = 1:length(session_results.dff)

        % extract data for the current cell
        curr_cell_activity = session_results.dff(cell_id).activity;
        
        % set PSTH of deleted ROIs to NaN
        if isempty(curr_cell_activity)
            for s = 1:length(stims)
                psth.(stims{s})(cell_id,:) = NaN;
            end
            continue
        end
        
        % report progress
        disp(['averaging for cell ' num2str(cell_id)])

        % loop across stimuli
        for s = 1:length(stims)

            % take stimulus onset times for that stimulus
            curr_onset_inds = onset.(stims{s});

            % exclude stimuli very close to beginning and end of session,
            % and not during stable epoch
            curr_onset_inds = curr_onset_inds(curr_onset_inds>abs(min(psth_window)) & ...
                                    curr_onset_inds<size(session_results.xyshifts{1},3)-max(psth_window));
            curr_onset_inds = intersect(curr_onset_inds, session_results.dff(1).stable_epoch(1):session_results.dff(1).stable_epoch(2));

            % fill the PSTH array corresponding to the current stimulus
            for tp = 1:length(psth_window)
                psth.(stims{s})(cell_id,tp) = mean(curr_cell_activity(curr_onset_inds + psth_window(tp)));
            end
        end
    end
end



%% determine which cells are active

active_cells = [];
if active_cells_only
    
    % loop across cells
    for cell_id = 1:length(session_results.dff)    
        
        % extract data for the current cell
        curr_cell_activity = session_results.dff(cell_id).activity;    
        
        % look at just negative values and their reflection
        rectified_negative_activity = [curr_cell_activity(curr_cell_activity<0) abs(curr_cell_activity(curr_cell_activity<0))];
        
        % get 5x STD of this rectified histogram
        activity_threshold = 5*std(rectified_negative_activity);
        
        % check if this cell is active
        proportion_activity_over_threshold = sum(curr_cell_activity>activity_threshold) / length(curr_cell_activity);
        
        % include if over threshold
        if proportion_activity_over_threshold > active_cell_threshold
            active_cells(end+1) = cell_id;
        end
    end
    cells_to_plot = active_cells;
    disp(['plotting ' num2str(length(active_cells)) ' of ' num2str(length(session_results.dff)) ' cells'])
    figure_name = 'PSTH of all active cells';
% if not filtering by activity, include all cells    
else
    cells_to_plot = 1:size(psth.(stims{s}),1);
    disp('Plotting all cells')
    figure_name = 'PSTH of all cells';
end




%% plot stimulus responses

% create figure and set position and colors
f = figure('Name',figure_name,'Position', [27 575 2349 707]); hold on; movegui(gca,'onscreen')
set(f,'color','black');
stim_order = {'a','b','r'};
stim_colors = {[0 0 1 .7];[.4 .4 0 .7];[0 .3 .8 .7];[.5 .3 .2 .7];[0 1 0 .7];};


% loop across stimuli
for s = 1:length(stims)

    % format subplot corresponding to current stimulus
    subplot(2,3, find(cellfun(@(x) stims{s}(1)==x, stim_order))+3*(str2num(stims{s}(2))-1)); hold on
    title(['PSTH of all cells to ' stims{s} ' stimulus'],'color',stim_colors{s});
    xlabel('time (sec) from stim onset','color','w');
    ylabel('df/f','color','w');
    
    % loop across cells
    for cell_id = 1:size(psth.(stims{s}),1)
        plot(psth_window/frame_rate, psth.(stims{s})(cell_id,:),'color',[0 0 1 .7],'linewidth',.6)
    end

    % plot median / 10 & 90 percentiles
    plot(psth_window/frame_rate, prctile(psth.(stims{s})(cells_to_plot,:),90),'color',[.6 .6 .8],'linewidth',1,'linestyle','--')
    plot(psth_window/frame_rate, prctile(psth.(stims{s})(cells_to_plot,:),50),'color','white','linewidth',2)
    plot(psth_window/frame_rate, prctile(psth.(stims{s})(cells_to_plot,:),10),'color',[.6 .6 .8],'linewidth',1,'linestyle','--')    
    
    % or, instead plot mean / std
%     plot(psth_window/frame_rate, mean(psth.(stims{s})(cells_to_plot,:))-std(psth.(stims{s})(cells_to_plot,:)),'color',[.6 .6 .8],'linewidth',1,'linestyle','--')
%     plot(psth_window/frame_rate, mean(psth.(stims{s})(cells_to_plot,:)),'color','white','linewidth',2)
%     plot(psth_window/frame_rate, mean(psth.(stims{s})(cells_to_plot,:))+std(psth.(stims{s})(cells_to_plot,:)),'color',[.6 .6 .8],'linewidth',1,'linestyle','--')    


    % plot formatting
    line([0,0],ylim,'linestyle','--','color',[.6 .2 .5]);
    set(gca,'Color',[1 1 1]*.025,'XColor',[1 1 1]*.7,'Ycolor',[1 1 1]*.7) 
    axis tight
end
    

    
%% add psth and truncated activity to df/f, to see which ROIs respond

if isfield(session_results.dff,'psth')
   disp('PSTH already included in session_results.dff -- not saving')
else
    disp(['saving PSTHs to results file'])
    % loop across cells
    for cell_id = 1:length(session_results.dff)

        % avg all psths to see avg stimulus response
        psth_all = zeros(length(psth_window),length(stims));
        for s = 1:length(stims)
            psth_all(:,s) = psth.(stims{s})(cell_id,:) / length(stims);
        end

        % skip deleted ROIs
        if isempty(session_results.dff(1,cell_id).activity)
            continue
        end
        
        % add psth to session results
        session_results.dff(1,cell_id).psth = psth_all;
       
    end
    
    % resave the dff field, now with the PSTHs, so session results
    dff = session_results.dff;
    save(results_file,'dff','-append');

end



%% show results in GUI


% load stimulus PSTH -- if the PSTH movies exist, show them
% see the script 'psth_as_movie.m' if this is desired
if exist([psth_save_folder '\' stims{1} '_psth.mat'],'file')
    if ~exist('psth_movie','var')
        disp('Loading PSTH movies')
        for s = 1:length(stims)
            stim_psth = load([psth_save_folder '\' stims{s} '_psth']);
            psth_movie.(stims{s}) = stim_psth.stim_psth;
        end
    end
    
    % show PSTHs and truncated activity in GUI, and activity from the reference session
    % if applicable, make sure you input the right avg_regs and .dff, so the transforms match up
    psth_rois = roisgui_psth(session_results.avg_regs{end}, [], session_results.dff, 'avg. regs.', ...
          'a1 psth', psth_movie.a1, 'b1 psth', psth_movie.b1, 'a2 psth', psth_movie.a2, 'b2 psth', psth_movie.b2,...
          'r1 psth', psth_movie.r1);  
      
else
    % show in GUI without PSTH movies
    psth_rois = roisgui_psth(session_results.avg_regs_tf{1}, [], session_results.dff, 'avg. regs.');
end
    
    
