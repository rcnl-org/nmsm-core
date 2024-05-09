function inputs = splineExperimentalToCollocationPoints(inputs)

inputs.collocationTimeOriginalWithEnd = inputs.collocationTimeOriginal;
inputs.collocationTimeOriginalWithEnd(end + 1) = inputs.experimentalTime(end);

splineJointAngles = makeGcvSplineSet(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', inputs.coordinateNames);
inputs.experimentalJointAngles = evaluateGcvSplines( ...
    splineJointAngles, inputs.coordinateNames, ...
    inputs.collocationTimeOriginalWithEnd);

splineJointMoments = makeGcvSplineSet(inputs.experimentalTime, ...
    inputs.experimentalJointMoments, ...
    inputs.inverseDynamicsMomentLabels);
inputs.experimentalJointMoments = evaluateGcvSplines( ...
    splineJointMoments, inputs.inverseDynamicsMomentLabels, ...
    inputs.collocationTimeOriginalWithEnd);

if strcmp(inputs.controllerType, 'synergy')
    splineMuscleActivations = makeGcvSplineSet( ...
        inputs.experimentalTime, inputs.experimentalMuscleActivations, ...
        inputs.muscleLabels);
    inputs.experimentalMuscleActivations = evaluateGcvSplines( ...
        splineMuscleActivations, inputs.muscleLabels, ...
        inputs.collocationTimeOriginalWithEnd);
end

for i = 1:length(inputs.contactSurfaces)
    splineExperimentalGroundReactionForces = ...
        makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionForces, string(0:2));
    splineExperimentalGroundReactionMoments = ...
        makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionMoments, string(0:2));
    splineExperimentalElectricalCenters = makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.contactSurfaces{i}.electricalCenter, string(0:2));
    inputs.contactSurfaces{i}.experimentalGroundReactionForces = ...
        evaluateGcvSplines(splineExperimentalGroundReactionForces, ...
        string(0:2), inputs.collocationTimeOriginalWithEnd);
    inputs.contactSurfaces{i}.experimentalGroundReactionMoments = ...
        evaluateGcvSplines(splineExperimentalGroundReactionMoments, ...
        string(0:2), inputs.collocationTimeOriginalWithEnd);
    inputs.contactSurfaces{i}.electricalCenter = evaluateGcvSplines( ...
        splineExperimentalElectricalCenters, string(0:2), ...
        inputs.collocationTimeOriginalWithEnd);
end

inputs.experimentalTime = inputs.collocationTimeOriginalWithEnd;
end

