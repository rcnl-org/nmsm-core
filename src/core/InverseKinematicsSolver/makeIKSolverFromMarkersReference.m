% This function makes an InverseKinematicsSolver from a given Model and
% MarkersReference object. It also accepts params like
% makeInverseKinematicsSolver.

% Copyright RCNL *change later*

% (Model, MarkersReference, struct) -> (InverseKinematicsSolver)
% Makes an InverseKinematicsSolver from a given Model and MarkersReference
function ikSolver = makeIKSolverFromMarkersReference(model, ...
    markersReference, params)
import org.opensim.modeling.*
ikSolver = InverseKinematicsSolver(model, markersReference, ...
    SimTKArrayCoordinateReference());
applyParametersToIKSolver(ikSolver, params)
end

