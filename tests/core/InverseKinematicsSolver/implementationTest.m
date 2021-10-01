% preconditions
import org.opensim.modeling.*
model = Model(strcat(pwd, '\tests\core\InverseKinematicsSolver\subject01_gait2392_scaled.osim'));
markerfilename=strcat(pwd, '\tests\core\InverseKinematicsSolver\walk_free_01.trc');
params.excludedMarkers = ["Sternum", "TopHead"];
params.markerWeights = struct("RAcromium", 10.0, "LAcromium", 0.1);
params.accuracy = 1.1;
params.startTime = 3.2;

% %% Does the function run for test
ikSolver = makeInverseKinematicsSolver(model, markerfilename, params);
% assert(class(ikSolver)=='org.opensim.modeling.InverseKinematicsSolver')