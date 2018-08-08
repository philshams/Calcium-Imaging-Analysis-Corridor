% -------------------------------------------------------
% Analyze activity and behaviour from a several sessions
% -------------------------------------------------------

% clear variables
% clear all

% file location - this file is made using 'concatenate_session_time_series.m'
results_file = 'C:\Drive\Rotation3\data\shohei_results\results_first_two_sessions.mat';

% range around stimulus to measure - should start at -20
psth_window = -20:20;

% set stims -- should correspond to get_stimulus_indices notation
stims = {'a1','b1','a2','b2','r1'};

% frame rate in Hz
frame_rate = 3.9;

% active cells only?
active_cells_only = true; 
% provide threshold of proportion activity > 5 std negative distribution
active_cell_threshold = .005;

% bin position
bins_per_panel = 6;
corridor_closed_loop = [1 0 1 0 1 0 1 0 1 0]; % 0 indicates onset / offset; number indicates num of panels in between
corridor_panels =      [2 1 3 1 3 1 3 1 2 1];
num_position_bins = (sum(corridor_panels)) * bins_per_panel;




%% create array of activity, occupancy, and speed: binned position x cells x trials 

if exist('position_response_array_multi_session','var') 
    disp('Using existing position response array -- clear variable and restart to calculate anew')
else
    create_position_response_array_multi_session
end


%% determine which cells are active

find_active_cells_to_use_multi_session


%% plot stimulus responses as heatmap

% close all

use_first_session_ordering = false;
plot_position_responses_multi_session

% --------------------------------------------------
%% plot mean of certain group of cells across time
% --------------------------------------------------

% select cells who respond to stimuli of interest (1 - 18)
stimuli_of_interest = 17;

% name of stimulus
type_of_cells = 'all active cells';

% select position bins of interest
position_bins = {[1]; [2]; [4; 6; 10; 12; 14]; [8]; [16]; [17]}; % 'post-grating non-rewarded' -- [4; 6; 12; 10; 14]
% position_bins = {[1; 2]; [4; 6; 12; 10; 14; 8; 16; 17]; [3; 7; 11; 15]; [9]; [13]; [18]};

% name position bins
position_bin_names_activity = {'beginning of corridor','2nd in beginning','post-grating non-rewarded','post-grating confound','penultimate pre-reward','ultimate pre-reward'};
stimulus_type_name = 'dotted gray screens';
% position_bin_names_activity = {'beginning of corridor','other gray screens','gratings','disappointing landmark','other landmark','reward'};
% stimulus_type_name = 'all screen types';

% make smoothing filter
gauss_filt = gausswin(5); gauss_filt = gauss_filt / sum(gauss_filt);

% axes the same
same_axes = false;

% do it
use_first_session_ordering = true;
plot_by_trial_multi_session


%% relate to response z score
      
plot_responsiveness_multi_session


%% correlate to speed, acceleration and offset versions of these
         
within_preferred_bin = false;
plot_speed_correlation_multi_session


