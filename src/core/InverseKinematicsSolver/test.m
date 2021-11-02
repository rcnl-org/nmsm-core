import org.opensim.modeling.*
model = Model(strcat(pwd, '\tests\core\InverseKinematicsSolver\subject01_gait2392_scaled.osim'));
markerfilename=strcat(pwd, '\tests\core\InverseKinematicsSolver\walk_free_01.trc');
params.excludedMarkers = ["Sternum", "TopHead"];
params.markerWeights = struct("RAcromium", 10.0, "LAcromium", 0.1);
params.accuracy = 0.0005;
params.startTime = 3.2;
% 
% markersReference = makeMarkersReference(model, markerfilename, params)
% 
% ikSolver = InverseKinematicsSolver(model, markersReference, SimTKArrayCoordinateReference())
% 
% state = model.initSystem()
% state.setTime(params.startTime)
% ikSolver.assemble(state)

makeInverseKinematicsSolver(Model(model), markerfilename, params)
