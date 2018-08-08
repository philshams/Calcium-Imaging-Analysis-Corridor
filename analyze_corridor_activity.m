% -----------------------------------------------------
% Analyze activity and behaviour from a single session
% -----------------------------------------------------

% clear variables
% clear all

% file location of behaviour
behaviour_folder = '\\172.24.170.8\data\public\projects\ShFu_20160303_Plasticity\Data\Imaging\CLP3\Labview_data\171227';

% file location of results -- a MATLAB structure including a field called 'dff',
% which is the size of the number of ROIs and includes fields called 'activity' and 'rois'
results_file = 'C:\Drive\Rotation3\data\shohei_results\results_27_12_17.mat';

% set stims -- should correspond to get_stimulus_indices notation
stims = {'a1','b1','a2','b2','r1'};

% frame rate in Hz
frame_rate = 13 / 4;

% load behaviour data and imaging results file
load_behaviour_and_results_shohei

% active cells only?
active_cells_only = true; 
% provide threshold of proportion activity > 5 std negative distribution
active_cell_threshold = .0075;

% bin position
bins_per_panel = 6;
corridor_closed_loop = [1 0 1 0 1 0 1 0 1 0]; % 0 indicates onset / offset; number indicates num of panels in between
corridor_panels =      [2 1 3 1 3 1 3 1 2 1];
num_position_bins = (sum(corridor_panels)) * bins_per_panel;


%% create array of activity, occupancy, and speed: binned position x cells x trials 

if exist('position_response_array','var') 
    disp('Using existing position response array -- clear variable and restart to calculate anew')
else
    create_position_response_array
end


%% determine which cells are active

find_active_cells_to_use


%% plot stimulus responses as heatmap

close all
plot_position_responses

% --------------------------------------------------
%% plot mean of certain group of cells across time
% --------------------------------------------------

% select cells who respond to stimuli of interest (1 - 18)
stimuli_of_interest = 17;

% name of stimulus
type_of_cells = 'pre-reward cells';

% select position bins of interest
position_bins = {[1]; [2]; [4; 6; 10; 12; 14]; [8]; [16]; [17]}; % 'post-grating non-rewarded' -- [4; 6; 12; 10; 14]
% position_bins = {[1; 2]; [4; 6; 12; 10; 14; 8; 16; 17]; [3; 7; 11; 15]; [9]; [13]; [18]};

% name position bins
position_bin_names_activity = {'beginning of corridor','2nd in beginning','post-grating non-rewarded','post-grating confound','penultimate pre-reward','ultimate pre-reward'};
stimulus_type_name = 'dotted gray screens';
% position_bin_names_activity = {'beginning of corridor','other gray screens','gratings','disappointing landmark','other landmark','reward'};
% stimulus_type_name = 'all screen types';

% make smoothing filter
gauss_filt = gausswin(5); 
gauss_filt = gauss_filt / sum(gauss_filt);

% axes the same
same_axes = false;

% do it
use_first_session_ordering = true;
plot_by_trial


%% relate to response z score
      
plot_responsiveness


%% correlate to speed, acceleration and offset versions of these
         
within_preferred_bin = false;
plot_speed_correlation


