% preconditions 
% model = Model(strcat(pwd, '\tests\JointModelPersonalization\subject01_gait2392_scaled.osim'));
model = Model('subject01_gait2392_scaled.osim');
% markerfilename = strcat(pwd, '\tests\JointModelPersonalization\walk_free_01.trc');
markerfilename = 'walk_free_01.trc';
params = struct();
markersReference = makeMarkersReference(model, markerfilename, params);
coordinateReference = org.opensim.modeling.SimTKArrayCoordinateReference();

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, ...
    params);
assert(isnumeric(error))