% preconditions 
import org.opensim.modeling.*
model = Model(strcat(pwd, '\tests\core\InverseKinematicsSolver\subject01_gait2392_scaled.osim'));
markerfilename=strcat(pwd, '\tests\core\InverseKinematicsSolver\walk_free_01.trc');
params = struct();
markersReference = makeMarkersReference(model, markerfilename, params);

%% Test computeInnerOptimizationHeuristic

error = computeInnerOptimizationHeuristic(model, markersReference, params)