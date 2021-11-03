% preconditions 
import org.opensim.modeling.*
model = Model('subject01_gait2392_scaled.osim');
markerfilename= 'walk_free_01.trc';
params = struct();
markersReference = makeMarkersReference(model, markerfilename, params);

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, params);
assert(isnumeric(error))