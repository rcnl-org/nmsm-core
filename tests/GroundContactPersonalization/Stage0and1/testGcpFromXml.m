clear

[inputs, params] = parseGroundContactPersonalizationSettingsTree(...
    xml2struct("GCP_settings.xml"));
inputs = prepareInputs(inputs, params);

% Latest stage of GCP to test
lastStage = 1;

% Stage 0
inputs = optimizeDeflectionAndSpringContants(inputs, params);
% inputs.restingSpringLength = 0.04;

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
disp(sum(abs(groundReactionForceValueError)))
if lastStage >= 2
    [groundReactionForceValueErrors, ~] = ...
        calcGroundReactionForceAndSlopeError(inputs, modeledValues);
disp('Unweighted Anterior GRF Cost: ')
disp(sum(abs(groundReactionForceValueErrors(1, :))))
disp('Unweighted Lateral GRF Cost: ')
disp(sum(abs(groundReactionForceValueErrors(3, :))))
end
disp('Unweighted Marker Tracking Cost: ')
[footMarkerPositionError, ~] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
disp(sum(abs(footMarkerPositionError)))

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

%% Supporting functions from GroundContactPersonalization.m

% (struct, struct) -> (struct)
% prepares optimization values from inputs
function inputs = prepareInputs(inputs, params)
% inputs.right.markerNames.toe = "R.Toe";
% inputs.right.markerNames.medial = "R.Toe.Medial";
% inputs.right.markerNames.lateral = "R.Toe.Lateral";
% inputs.right.markerNames.heel = "R.Heel";
% inputs.left.markerNames.toe = "L.Toe";
% inputs.left.markerNames.medial = "L.Toe.Medial";
% inputs.left.markerNames.lateral = "L.Toe.Lateral";
% inputs.left.markerNames.heel = "L.Heel";
inputs.gridWidth = 5;
inputs.gridHeight = 15;
% inputs.left.isLeftFoot = true;
% inputs.right.isLeftFoot = false;

if inputs.right.isEnabled
    % Potentially refactor to use inputs.right if allowing multiple sides
    inputs = prepareInputsForSide(inputs, inputs);
end
if inputs.left.isEnabled
    inputs.left = prepareInputsForSide(inputs.left, inputs);
end

inputs.restingSpringLength = inputs.initialRestingSpringLength;
inputs.dynamicFrictionCoefficient = ...
    inputs.initialDynamicFrictionCoefficient;
end

% (struct, struct) -> (struct)
% prepares optimization values specific to a side
function inputs = prepareInputsForSide(inputs, sharedInputs)
inputs.toesJointName = char(Model(sharedInputs.bodyModel ...
    ).getCoordinateSet().get(inputs.toesCoordinateName).getJoint(...
    ).getName());
[inputs.hindfootBodyName, inputs.toesBodyName] = ...
    getJointBodyNames(Model(sharedInputs.bodyModel), inputs.toesJointName);
inputs.coordinatesOfInterest = findGCPFreeCoordinates(...
    Model(sharedInputs.bodyModel), string(inputs.toesBodyName));

[footPosition, markerPositions] = makeFootKinematics(...
    sharedInputs.bodyModel, sharedInputs.motionFileName, ... % import motion in parse settings tree or here?
    inputs.coordinatesOfInterest, inputs.hindfootBodyName, ...
    inputs.toesCoordinateName, inputs.markerNames);

footVelocity = calcBSplineDerivative(inputs.time, footPosition, ...
    4, 21);
markerNamesFields = fieldnames(inputs.markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = ...
    calcBSplineDerivative(inputs.time, markerPositions.(...
    markerNamesFields{i}), 4, 21);
end

% inputs.model = makeFootModel(sharedInputs.bodyModel, inputs.toesJointName);
% inputs.model = addSpringsToModel(inputs.model, inputs.markerNames, ...
%     sharedInputs.gridWidth, sharedInputs.gridHeight, ...
%     inputs.hindfootBodyName, inputs.toesBodyName, inputs.isLeftFoot); % change isLeftFoot?
% inputs.model.print("footModel.osim");
% inputs.model = Model("footModel.osim");
inputs.numSpringMarkers = findNumSpringMarkers(inputs.model);

inputs.experimentalMarkerPositions = markerPositions;
inputs.experimentalMarkerVelocities = markerVelocities;
inputs.experimentalJointPositions = footPosition;
inputs.experimentalJointVelocities = footVelocity;

initialSpringConstants = 2596; % Jackson et al 2016 Table 2
initialDampingFactors = 10;
initialSpringRestingLength = 0.05;
inputs.springConstants = initialSpringConstants * ones(1, ...
    inputs.numSpringMarkers);
inputs.dampingFactors = initialDampingFactors * ones(1, ...
    inputs.numSpringMarkers);
inputs.springRestingLength = initialSpringRestingLength;

inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionForces, 2, 25);
inputs.jointKinematicsBSplines = makeJointKinematicsBSplines(...
    inputs.time, 4, 25);
% inputs.bSplineCoefficients = calcInitialDeviationNodes(...
%     inputs.time, 4, 25, 7);
inputs.bSplineCoefficients = ones(25, 7);
inputs.springRestingLength = initialSpringRestingLength;
end