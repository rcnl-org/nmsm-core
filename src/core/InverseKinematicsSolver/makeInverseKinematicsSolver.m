

% (Model, struct) -> (InverseKinematicsSolver)

function ikSolver = makeInverseKinematicsSolver(model, params)
import org.opensim.modeling.*
markerReferences = makeMarkersReference(model, ...
    valueOrEmptyStruct(params, 'markersReference'));
coordinateReferences = makeCoordinateReferences(model, ...
    valueOrEmptyStruct(params, 'coordinateReferences'));
ikSolver = InverseKinematicsSolver(model, markerReferences, ...
    coordinateReferences);
ikSolver = applyParametersToIKSolver(ikSolver, params);
state=model.initSystem();%initialize system
state.setTime(startTime);%set simulation start time
ikSolver.assemble(state);%assemble
end

