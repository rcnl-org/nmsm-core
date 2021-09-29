

% (Model, struct) -> (InverseKinematicsSolver)

function ikSolver = makeInverseKinematicsSolver(model, markerFileName, ...
    params)
import org.opensim.modeling.*
markerReferences = makeMarkersReference(model, markerFileName, params);
ikSolver = InverseKinematicsSolver(model, markerReferences, ...
    SimTKArrayCoordinateReference());
ikSolver = applyParametersToIKSolver(ikSolver, params);
state=model.initSystem();%initialize system
state.setTime(startTime);%set simulation start time
ikSolver.assemble(state);%assemble
end

