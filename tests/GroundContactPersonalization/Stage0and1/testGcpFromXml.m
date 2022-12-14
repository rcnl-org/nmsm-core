clear

[inputs, params] = parseGroundContactPersonalizationSettingsTree(...
    xml2struct("GCP_settings.xml"));
inputs = prepareGroundContactPersonalizationInputs(inputs, params);

% Latest stage of GCP to test
lastStage = 0;

% Stage 0
inputs = optimizeDeflectionAndSpringContants(inputs, params);

% Stage 1
if lastStage >= 1
    inputs = optimizeByVerticalGroundReactionForce(inputs, params);
end

% Stage 2
if lastStage >= 2
    inputs = optimizeByGroundReactionForces(inputs, params);
end


%% Report results, plot forces and kinematics

[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    inputs.bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, inputs, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, (lastStage >= 2), 0], 0);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

disp('Unweighted Vertical GRF Cost: ')
[groundReactionForceValueError, ~] = ...
    calcVerticalGroundReactionForceAndSlopeError(inputs, ...
    modeledValues);
disp(sum(groundReactionForceValueError))
if lastStage >= 2
    [groundReactionForceValueErrors, ~] = ...
        calcGroundReactionForceAndSlopeError(inputs, modeledValues);
disp('Unweighted Anterior GRF Cost: ')
disp(sum(groundReactionForceValueErrors(1, :)))
disp('Unweighted Lateral GRF Cost: ')
disp(sum(groundReactionForceValueErrors(3, :)))
end
disp('Unweighted Marker Tracking Cost: ')
[footMarkerPositionError, ~] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
disp(sum(footMarkerPositionError))

figure(1)

if lastStage < 2
    scatter(inputs.time, ...
        inputs.experimentalGroundReactionForces(2, :), [], "red")
    hold on
    scatter(inputs.time, modeledValues.verticalGrf, [], "blue")
    hold off
end
if lastStage == 2
    subplot(1,3,1);
    scatter(inputs.time, ...
        inputs.experimentalGroundReactionForces(2, :), [], "red")
    hold on
    scatter(inputs.time, modeledValues.verticalGrf, [], "blue")
    hold off
    subplot(1,3,2);
    scatter(inputs.time, ...
        inputs.experimentalGroundReactionForces(1, :), [], "red")
    hold on
    scatter(inputs.time, modeledValues.anteriorGrf, [], "blue")
    hold off
    subplot(1,3,3);
    scatter(inputs.time, ...
        inputs.experimentalGroundReactionForces(3, :), [], "red")
    hold on
    scatter(inputs.time, modeledValues.lateralGrf, [], "blue")
    hold off
end

figure(2)

subplot(1,4,1);
scatter(inputs.time, inputs.experimentalJointPositions(1, :), [], "red")
hold on
scatter(inputs.time, modeledValues.jointPositions(1, :), [], "blue")
hold off

subplot(1,4,2);
scatter(inputs.time, inputs.experimentalJointPositions(2, :), [], "red")
hold on
scatter(inputs.time, modeledValues.jointPositions(2, :), [], "blue")
hold off

subplot(1,4,3);
scatter(inputs.time, inputs.experimentalJointPositions(3, :), [], "red")
hold on
scatter(inputs.time, modeledValues.jointPositions(3, :), [], "blue")
hold off

subplot(1,4,4);
scatter(inputs.time, inputs.experimentalJointPositions(4, :), [], "red")
hold on
scatter(inputs.time, modeledValues.jointPositions(4, :), [], "blue")
hold off

%% Spring constant plot

figure(3)
footModel = Model("footModel2.osim");
plotSpringConstants(footModel, inputs, inputs.toesBodyName, inputs.hindfootBodyName)
