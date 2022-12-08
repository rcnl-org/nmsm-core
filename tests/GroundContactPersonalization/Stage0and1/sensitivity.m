tic
settingsFileName = "GCP_settings.xml";
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = ...
    parseGroundContactPersonalizationSettingsTree(settingsTree);
inputs = prepareInputs(inputs, params);

% inputs

[initialValues, fieldNameOrder, inputs] = makeInitialValues(inputs, params);

gcpSensitivityAnalysis(initialValues, 2, 1500, 3500, fieldNameOrder, inputs, ...
    params, 1)
toc


%% makeInitialValues from 'optimizeByVerticalGroundReactionForce.m'
function [initialValues, fieldNameOrder, inputs] = makeInitialValues( ...
    inputs, params)
initialValues = [];
fieldNameOrder = [];
inputs.bSplineCoefficientsVerticalSubset = ...
    inputs.bSplineCoefficients(:, [1:4, 6]);
if (params.stageOne.springConstants.isEnabled)
    initialValues = [initialValues inputs.springConstants];
    fieldNameOrder = [fieldNameOrder "springConstants"];
end
if (params.stageOne.dampingFactors.isEnabled)
    initialValues = [initialValues inputs.dampingFactors];
    fieldNameOrder = [fieldNameOrder "dampingFactors"];
end
if (params.stageOne.bSplineCoefficients.isEnabled)
    initialValues = [initialValues ...
        reshape(inputs.bSplineCoefficientsVerticalSubset, 1, [])];
    fieldNameOrder = [fieldNameOrder "bSplineCoefficientsVerticalSubset"];
end
end

%% prepareInputs from file 'GroundContactPersonalization.m'
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

%% NEEDED TO BE ADDED MANUALLY %%
initialSpringConstants = 2500; % Jackson et al 2016 Table 2
initialDampingFactors = 1e-2; % 3e-6
inputs.jointKinematicsBSplines = makeJointKinematicsBSplines(inputs.time, 4, 25);
inputs.bSplineCoefficients = calcInitialDeviationNodes(25, 7);
numSpringMarkers = findNumSpringMarkers(inputs.model);
inputs.springConstants = initialSpringConstants * ...
    ones(1, numSpringMarkers);
inputs.dampingFactors = initialDampingFactors * ones(1, numSpringMarkers);
coordinatesOfInterest = findGCPFreeCoordinates(inputs.bodyModel, inputs.toesBodyName);
[footPosition, markerPositions] = makeFootKinematics(inputs.bodyModel, ...
    inputs.motionFileName, coordinatesOfInterest, inputs.hindfootBodyName, ...
    inputs.toesCoordinateName, inputs.markerNames);
inputs.experimentalJointPositions = footPosition;
inputs.experimentalMarkerPositions = markerPositions;
markerNamesFields = fieldnames(inputs.markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = calcBSplineDerivative(inputs.time, ...
    markerPositions.(markerNamesFields{i}), 4, 21);
end
inputs.experimentalMarkerVelocities = markerVelocities;
inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionForces, 2, 25);
%% NEEDED TO BE ADDED MANUALLY %%
end

%% prepareInputsForSide from file 'GroundContactPersonalization.m'
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
end