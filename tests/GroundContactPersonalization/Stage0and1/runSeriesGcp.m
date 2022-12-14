clear

lastStage = 2;

for i = 1:8

try
    [inputs, params] = parseGroundContactPersonalizationSettingsTree(...
        xml2struct("GCP_test_" + i + ".xml"));
    inputs = prepareInputs(inputs, params);
    inputs = optimizeDeflectionAndSpringContants(inputs, params);
    if lastStage >= 1
        inputs = optimizeByVerticalGroundReactionForce(inputs, params);
    end
    if lastStage >= 2
        inputs = optimizeByGroundReactionForces(inputs, params);
    end
    save("testResultsGcp_" + i + ".mat")
catch
    disp("Failed to run test " + i)
end

end


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