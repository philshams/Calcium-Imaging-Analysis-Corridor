% ------------------------------------------
% extract stimulus indices
% ------------------------------------------

% get indices of each stimulus
inds.stim = find(behaviour_table.photodiode>2);
inds.gray = setdiff(1:length(behaviour_table.stim_id),inds.stim);

% get particular stimulus identity by tunnel position
pos=behaviour_table.position_tunnel;
inds.a1=intersect(inds.stim, intersect(find(pos>.1), find(pos<1.2))); % the four gratings
inds.b1=intersect(inds.stim, intersect(find(pos>1.2), find(pos<2.4)));
inds.a2=intersect(inds.stim, intersect(find(pos>2.4), find(pos<3.5)));
inds.b2=intersect(inds.stim, intersect(find(pos>3.5), find(pos<4.4)));
inds.r1=intersect(inds.stim, find(pos>4.4));

% get onset and offset times
%
% loop  through stimuli
for s = 1:length(stims)
    
    % find onset and offset indices (after 50 frames to get rid of 'edge artifacts')
    inds_since_last_stim = diff(inds.(stims{s}));
    onset.(stims{s}) = inds.(stims{s})([1; find(inds_since_last_stim > 50)+1]);
    offset.(stims{s}) = inds.(stims{s})([find(inds_since_last_stim > 50); length(inds.(stims{s}))]);

end
