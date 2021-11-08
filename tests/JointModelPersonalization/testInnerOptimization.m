% preconditions 
import org.opensim.modeling.*
model = Model('subject01_gait2392_scaled.osim');
markerfilename= 'walk_free_01.trc';
params = struct();
markersReference = makeMarkersReference(model, markerfilename, params);
coordinateReference = SimTKArrayCoordinateReference();

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, ...
    coordinateReference, params);
assert(isnumeric(error))