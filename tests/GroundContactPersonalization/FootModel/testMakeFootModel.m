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
markerNames.midfootSuperior = "R.Midfoot.Superior";

gridWidth = 5;
gridHeight = 11;

isLeftFoot = false;

initialSpringConstants = 2500; % Jackson et al 2016 Table 2
initialDampingFactors = 3e-5;
initialSpringRestingLength = 0.05;

bodyModel = Model(modelFileName);
[grfColumnNames, grfTime, grfData] = parseMotToComponents(bodyModel, ...
    Storage(grfFileName));

bodyModel = Model(modelFileName);
time = findTimeColumn(Storage(motionFileName));
startTime = time(1);
endTime = time(end);
coordinatesOfInterest = findGCPFreeCoordinates(bodyModel, toesBodyName);

[footPosition, markerPositions] = makeFootKinematics(bodyModel, ...
    motionFileName, coordinatesOfInterest, hindfootBodyName, ...
    toesCoordinateName, markerNames, startTime, endTime);
footVelocity = calcBSplineDerivative(time, footPosition, 4, 21);

markerNamesFields = fieldnames(markerNames);
for i=1:length(markerNamesFields)
markerVelocities.(markerNamesFields{i}) = calcBSplineDerivative(time, ...
    markerPositions.(markerNamesFields{i}), 4, 21);
end

footModel = makeFootModel(bodyModel, toesJointName);
footModel = addSpringsToModel(footModel, markerNames, gridWidth, ...
    gridHeight, hindfootBodyName, toesBodyName, toesJointName, ...
    isLeftFoot, markerPositions);
footModel.print("footModelTest.osim");

function model = findTwoPointsOnToeJointAxis(model, toesJointName, body)
[model, state] = Model(model);
point1 = getVec3Vertical(model.getJointSet().get(toesJointName) ...
    .getParentFrame().getPositionInGround(state));
rotationMat = getRotationMatrix(model.getJointSet().get(toesJointName) ...
    .getParentFrame().getRotationInGround(state).asMat33());
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
marker.set_location(Vec3(point2(1) - bodyPosition.get(1), ...
    point2(2) - bodyPosition.get(2), point2(3) - bodyPosition.get(3)));
model.addMarker(marker);
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
