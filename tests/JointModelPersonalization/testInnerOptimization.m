% preconditions 
import org.opensim.modeling.*
model = Model(strcat(pwd, '\subject01_gait2392_scaled.osim'));
markerfilename=strcat(pwd, '\walk_free_01.trc');
params = struct();
markersReference = makeMarkersReference(model, markerfilename, params);

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, params)