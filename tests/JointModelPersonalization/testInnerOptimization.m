% preconditions 
import org.opensim.modeling.*
% model = Model(strcat(pwd, '\tests\JointModelPersonalization\subject01_gait2392_scaled.osim'));
model = Model('subject01_gait2392_scaled.osim');
% markerfilename = strcat(pwd, '\tests\JointModelPersonalization\walk_free_01.trc');
markerfilename = 'walk_free_01.trc';
params.desiredError = 0.005;
markersReference = makeMarkersReference(model, markerfilename, params);
coordinateReference = SimTKArrayCoordinateReference();

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, ...
    coordinateReference, params);
assert(isnumeric(error))