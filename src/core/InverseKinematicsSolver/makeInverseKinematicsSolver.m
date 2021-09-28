

% (Model, struct) -> (InverseKinematicsSolver)

function ikSolver = makeInverseKinematicsSolver(model, markerFileName, ...
    params)
import org.opensim.modeling.*
markerReferences = makeMarkersReference(model, markerFileName, params);
coordinateReferences = makeCoordinateReferences(model, ...
    valueOrEmptyStruct(params, coordinateTasks));
ikSolver = InverseKinematicsSolver(model, markerReferences, ...
    coordinateReferences);
ikSolver = applyParametersToIKSolver(ikSolver, params);
state=model.initSystem();%initialize system
state.setTime(startTime);%set simulation start time
ikSolver.assemble(state);%assemble
end

