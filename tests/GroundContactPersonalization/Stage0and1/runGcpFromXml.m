clear

[inputs, params] = parseGroundContactPersonalizationSettingsTree(...
    xml2struct("GCP_settings.xml"));
inputs = prepareGroundContactPersonalizationInputs(inputs, params);

% Latest stage of GCP to test
lastStage = 1;

% Stage 0
inputs = initializeRestingSpringLengthAndSpringConstants(inputs, params);
% Stage 1
if lastStage >= 1
    inputs = optimizeByVerticalGroundReactionForce(inputs, params);
end
% Stage 2
if lastStage >= 2
    inputs = optimizeByGroundReactionForces(inputs, params);
end
% Stage 3
if lastStage == 3
    inputs = optimizeByGroundReactionForcesAndMoments(inputs, params);
end

%% Plot forces and kinematics
if exist('1', 'var')
    close 1
end
if exist('2', 'var')
    close 2
end
figure(1)
plotGroundReactionQuantities(inputs, params, lastStage)
figure(2)
plotCoordinates(inputs)

%% Spring constant plot
if exist('3', 'var')
    close 3
end
figure(3)
footModel = Model("footModel2.osim");
plotSpringConstants(footModel, inputs, inputs.toesBodyName, inputs.hindfootBodyName)

%% Report cost quantities

[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    inputs.bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, inputs, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, ...
    (lastStage >= 2), (lastStage == 3)], params);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

disp('Unweighted Vertical GRF Cost: ')
[groundReactionForceValueError, ~] = ...
    calcVerticalGroundReactionForceAndSlopeError(inputs, ...
    modeledValues);
disp(sum(abs(groundReactionForceValueError)))
if lastStage >= 2
    [groundReactionForceValueErrors, ~] = ...
        calcGroundReactionForceAndSlopeError(inputs, modeledValues);
    disp('Unweighted Anterior GRF Cost: ')
    disp(sum(abs(groundReactionForceValueErrors(1, :))))
    disp('Unweighted Lateral GRF Cost: ')
    disp(sum(abs(groundReactionForceValueErrors(3, :))))
end
if lastStage == 3
    [groundReactionMomentErrors, ~] = ...
        calcGroundReactionMomentAndSlopeError(inputs, modeledValues);
    disp('Unweighted Moment Cost: ')
    disp(sum(abs(groundReactionMomentErrors), 'all'))
end
disp('Unweighted Marker Tracking Cost: ')
[footMarkerPositionError, ~] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
disp(sum(abs(footMarkerPositionError)))