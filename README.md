# Calcium Imaging Analysis for a Virtual Corridor

Some scripts to do an exploratory analysis of imaging data in a virtual corridor, starting from a 'dff' structure.

psth_all_cells: shows a mean psth for all cells, for each photodiode-triggered stimulus
psth_particular_cells_all_trials: select the cells to analyse, and show every trial's response for each stimulus
psth_as_movie: using the folder where the raw tiff files are located, can create a average movie before and after each stimulus' onset
analyze_corridor_activity: an exploratory analysis of the desired session
concatenate_session_time_series: bring data from several sessions into a single structure, to be analyzed in:
analyze_corridor_activity_multi_session: an exploratory analysis, with these sessions plotted side by side