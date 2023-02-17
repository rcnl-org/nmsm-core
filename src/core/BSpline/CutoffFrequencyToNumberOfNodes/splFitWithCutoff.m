function nNodes = splFitWithCutoff(time, data, fCutoff, splineDegree, task)
% Matlab function to extract time vector and data curves from an input data
% file and determine the number of B-spline nodes required to match a
% specified cutoff frequency for all curves

% Extract relevant parameters
params.fCutoff = fCutoff;
params.splineDegree = splineDegree;
params.plotFlag = 0; % plot comparison curves when finished

% Calculate number of B-spline nodes required to match the specific cutoff
% frequently for all curves
nNodes = calcNumBsplNodesFromCutoffFreq(time, data, params);

disp("The number of B-spline nodes for foot " + task + " is " + nNodes);

end