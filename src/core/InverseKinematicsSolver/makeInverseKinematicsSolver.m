% This function makes an InverseKinematicsSolver object from input Model,
% markerfilename and parameters. The params are a struct and have the
% following format:
% params:
%     excludedMarkers - (1D array strings of marker names)
%     markerWeights - struct(marker name, number weight)
%     accuracy - numeric
%     startTime - numeric (default: 0)

% Copyright RCNL *change later*

% (Model, string, struct) -> (InverseKinematicsSolver)
% makes an InverseKinematicsSolver from input values
function ikSolver = makeInverseKinematicsSolver(model, markerFileName, ...
    params)
import org.opensim.modeling.*
markerReferences = makeMarkersReference(model, markerFileName, params);
ikSolver = InverseKinematicsSolver(model, markerReferences, ...
    SimTKArrayCoordinateReference());
ikSolver = applyParametersToIKSolver(ikSolver, params);
state = model.initSystem();
state.setTime(valueOrZero(params, 'startTime'));
ikSolver.assemble(state);
end

