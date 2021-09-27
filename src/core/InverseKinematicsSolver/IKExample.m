
import org.opensim.modeling.*
model = Model(strcat(pwd, '\src\core\InverseKinematics\subject01_gait2392_scaled.osim'));
params.markerFile = strcat(pwd, '\src\core\InverseKinematics\walk_free_01.trc');
params.startTime = 0.5;
params.endTime = 4.0;
params.outputMotionFileName = strcat(pwd, '\src\core\InverseKinematics\result.mot');
params.accuracy = 1e-5;

params.taskSet = makeIKTaskSet();

output = IK(model, params)


function ikSolver = makeInverseKinematicsSolver(model, params)
import org.opensim.modeling.*
markersReference = makeMarkersReference(model, ...
    params.markerReferenceParams);
coordinateReferences = makeCoordinateReferences(model, ...
    params.coordinateReferencesParams);
ikSolver = InverseKinematicsSolver(model, markersReference, ...
    coordinateReferences);
ikSolver = applyParametersToIKSolver(ikSolver, params);
state=model.initSystem();%initialize system
state.setTime(startTime);%set simulation start time
ikSolver.assemble(state);%assemble
end



function taskSet = makeIKTaskSet()
    import org.opensim.modeling.*
    taskSet = IKTaskSet();
    mt0 = IKMarkerTask();
    mt0.setName('Sternum');
    mt0.setWeight(1.0);
    taskSet.set(0, mt0);
    
    
    
end

