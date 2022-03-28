% preconditions 
% model = Model(strcat(pwd, '\tests\JointModelPersonalization\subject01_gait2392_scaled.osim'));
model = Model(fullfile('..','simple_arm_oriented_away.osim'));
% markerfilename = strcat(pwd, '\tests\JointModelPersonalization\walk_free_01.trc');
markerFile = fullfile('..','simple_arm.trc');
params.desiredError = 0.01;
markersReference = makeMarkersReference(model, markerFile, params);
coordinateReference = org.opensim.modeling.SimTKArrayCoordinateReference();

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, ...
    params);
assert(isnumeric(error))