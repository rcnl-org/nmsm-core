clear

import org.opensim.modeling.Storage

modelFileName = "optModel_v6_correct_height.osim";
motionFileName = "motion.mot";
grfFileName = "grf.mot";
hindfootBodyName = "calcn_r";
toesBodyName = "toes_r";
toesJointName = "mtp_r";
toesCoordinateName = "mtp_angle_r";

markerNames.toe = "R.Toe";
markerNames.medial = "R.Toe.Medial";
markerNames.lateral = "R.Toe.Lateral";
markerNames.heel = "R.Heel";

gridWidth = 5;
gridHeight = 11;

isLeftFoot = false;

initialSpringConstants = 2500; % Jackson et al 2016 Table 2
initialDampingFactors = 3e-5;
initialSpringRestingLength = 0.05;

bodyModel = Model(modelFileName);
[grfColumnNames, grfTime, grfData] = parseMotToComponents(bodyModel, Storage(grfFileName));

bodyModel = Model(modelFileName);
time = findTimeColumn(Storage(motionFileName));
coordinatesOfInterest = findGCPFreeCoordinates(bodyModel, toesBodyName);

[footPosition, markerPositions] = makeFootKinematics(bodyModel, ...
    motionFileName, coordinatesOfInterest, hindfootBodyName, ...
    toesCoordinateName, markerNames);
footVelocity = calcBSplineDerivative(time, footPosition, 4, 21);

markerNamesFields = fieldnames(markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = calcBSplineDerivative(time, ...
    markerPositions.(markerNamesFields{i}), 4, 21);
end

footModel = makeFootModel(bodyModel, toesJointName);
% footModel = findTwoPointsOnToeJointAxis(footModel, toesJointName, hindfootBodyName);
footModel = addSpringsToModel(footModel, markerNames, gridWidth, ...
    gridHeight, hindfootBodyName, toesBodyName, toesJointName, isLeftFoot);
footModel.print("footModel2.osim");
% footModel = Model("footModel.osim");
% numSpringMarkers = findNumSpringMarkers(footModel);
% %--------------------------------------------------------------
% inputs.model = "footModel.osim";
% inputs.markerNames = markerNames;
% inputs.time = time;
% inputs.experimentalMarkerPositions = markerPositions;
% inputs.experimentalMarkerVelocities = markerVelocities;
% inputs.experimentalJointPositions = footPosition;
% inputs.experimentalJointVelocities = footVelocity;
% inputs.experimentalGroundReactionForces = grfData(7:9, :);
% inputs.experimentalGroundReactionForcesSlope = calcBSplineDerivative( ...
%     time, inputs.experimentalGroundReactionForces, 2, 25);
% inputs.springConstants = initialSpringConstants * ...
%     ones(1, numSpringMarkers);
% inputs.dampingFactors = initialDampingFactors * ones(1, numSpringMarkers);
% inputs.jointKinematicsBSplines = makeJointKinematicsBSplines(time, 4, 25);
% % size(inputs.jointKinematicsBSplineNodes)
% inputs.bSplineCoefficients = calcInitialDeviationNodes(25, 7);
% inputs.restingSpringLength = initialSpringRestingLength;
% % modeledJointPositions = inputs.experimentalJointPositions;
% % modeledJointVelocities = inputs.experimentalJointVelocities;

% % values.springConstants = inputs.springConstants;
% % values.dampingFactors = inputs.dampingFactors;
% % values.restingSpringLength = inputs.restingSpringLength;

% % modeledValues = calcGCPModeledValues(inputs, values, ...
% %     modeledJointPositions, modeledJointVelocities, [1 1 0 0 0])

% % scatter(inputs.time, inputs.experimentalMarkerVelocities.heel)

% newInputs = optimizeByVerticalGroundReactionForce(inputs, struct());

% testInputs = newInputs

% % testInputs.springConstants = testInputs.springConstants / 1000;
% % testInputs.dampingFactors = testInputs.dampingFactors * 1000;

% [modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
%     testInputs.experimentalJointPositions, testInputs.jointKinematicsBSplines, ...
%     testInputs.bSplineCoefficients);
% modeledValues = calcGCPModeledValues(testInputs, testInputs, ...
%     modeledJointPositions, modeledJointVelocities, [1, 1, 0, 0]);
% modeledValues.jointPositions = modeledJointPositions;
% modeledValues.jointVelocities = modeledJointVelocities;


% [groundReactionForceValueError, groundReactionForceSlopeError] = ...
%     calcVerticalGroundReactionForceAndSlopeError(testInputs, modeledValues);

% % testInputs.springConstants = testInputs.springConstants * 1000;
% % testInputs.dampingFactors = testInputs.dampingFactors / 1000;

% % size(groundReactionForceSlopeError)

% scatter(testInputs.time, testInputs.experimentalGroundReactionForces(2, :), [], "red")
% hold on
% scatter(testInputs.time, modeledValues.verticalGrf, [], "blue")
% hold off

function model = findTwoPointsOnToeJointAxis(model, toesJointName, body)
[model, state] = Model(model);
point1 = getVec3Vertical(model.getJointSet().get(toesJointName).getParentFrame().getPositionInGround(state));
rotationMat = getRotationMatrix(model.getJointSet().get(toesJointName).getParentFrame().getRotationInGround(state).asMat33());
position2 = [0; 0; 0.1];
point2 = (rotationMat * position2) + point1;
point1 = (rotationMat * [0; 0; -0.1]) + point1;
point1 = point1';
point2 = point2';
import org.opensim.modeling.Marker
import org.opensim.modeling.Vec3
state = model.initSystem();
marker = Marker();
marker.setName("point1");
marker.setParentFrame(model.getBodySet().get(body));
bodyPosition = model.getBodySet().get(body).getPositionInGround(state);
marker.set_location(Vec3(point1(1) - bodyPosition.get(1), ...
    point1(2) - bodyPosition.get(2), point1(3) - bodyPosition.get(3)));
model.addMarker(marker);

marker = Marker();
marker.setName("point2");
marker.setParentFrame(model.getBodySet().get(body));
% bodyPosition = model.getBodySet().get(body).getPositionInGround(state);
marker.set_location(Vec3(point2(1) - bodyPosition.get(1), ...
    point2(2) - bodyPosition.get(2), point2(3) - bodyPosition.get(3)));
model.addMarker(marker);
%     model.getBodySet().get("calcn_r").getPositionInGround(state)
model.finalizeConnections()
end

function rotationMat = getRotationMatrix(rotation)
rotationMat = zeros(3);
for i = 0:2
    for j = 0:2
        rotationMat(i+1, j+1) = rotation.get(i, j);
    end
end
end

function verticalVec = getVec3Vertical(position)
verticalVec = zeros(3, 1);
for i = 0:2
    verticalVec(i+1) = position.get(i);
end
end
