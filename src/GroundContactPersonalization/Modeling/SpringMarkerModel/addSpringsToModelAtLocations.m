% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, struct) -> (struct)
% Add spring markers to footModel at specified locations. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function model = addSpringsToModelAtLocations(model, markerPositions, ...
    normalizedMarkerPositions, points, toesJointName, ...
    hindfootBodyName, toesBodyName, heelMarkerName, isLeftFoot, theta)
[model, state] = Model(model);
normalizedFootHeight = abs(markerPositions.toe(1) - ...
    markerPositions.heel(1));
normalizedFootWidth = abs(markerPositions.medial(2) - ...
    markerPositions.lateral(2));
calcnVec3 = model.getBodySet().get(hindfootBodyName) ...
    .getPositionInGround(state);
toesVec3 = model.getBodySet().get(toesBodyName) ...
    .getPositionInGround(state);
heelVec3 = model.getMarkerSet().get(heelMarkerName) ...
    .getLocationInGround(state);

markerPrefix = "spring_marker_";

[toeJointPoint1, toeJointPoint2] = ...
    findTwoPointsOnToeJointAxis(model, toesJointName);

height = -calcnVec3.get(1);
for i=1:length(points)
    newPoint = calcMarkerPosition(points(i, :), normalizedFootHeight, ...
        normalizedFootWidth, normalizedMarkerPositions, calcnVec3, ...
        heelVec3, isLeftFoot);
    [newPoint(1), newPoint(2)] = rotateValues2D(newPoint(1), ...
        newPoint(2), theta);
    newPoint(2) = newPoint(2) + (heelVec3.get(2) - calcnVec3.get(2));
    bodyName = hindfootBodyName;
    % Check whether a marker is above the toe joint, and use relative body
    % positions to place the marker in the correct parent frame. 
    if(~isBelowToeJoint([toeJointPoint1(3), toeJointPoint1(1)], ...
            [toeJointPoint2(3), toeJointPoint2(1)], newPoint))
        newPoint(1) = newPoint(1) - toesVec3.get(0) + calcnVec3.get(0);
        newPoint(2) = newPoint(2) - toesVec3.get(2) + calcnVec3.get(2);
        bodyName = toesBodyName;
    end
    addSpringToModel(model, height, newPoint, bodyName, ...
        markerPrefix + num2str(i));
end
end

function newPoint = calcMarkerPosition(point, normalizedFootHeight, ...
    normalizedFootWidth, normalizedMarkerPositions, calcnVec3, ...
    heelVec3, isLeftFoot)
pointX = point(2) * normalizedFootHeight;
pointX = pointX - (calcnVec3.get(0) - heelVec3.get(0));
if(isLeftFoot)
    pointY = 1 - point(1);
else
    pointY = point(1);
end
pointY = pointY * normalizedFootWidth;
averageHorizontal = (normalizedMarkerPositions.lateral(2) + ...
    normalizedMarkerPositions.medial(2)) / 2;
pointY = pointY - (averageHorizontal * normalizedFootWidth);
newPoint = [pointX, pointY];
end

function addSpringToModel(model, height, point, body, name)
import org.opensim.modeling.Marker
import org.opensim.modeling.Vec3
marker = Marker();
marker.setName(name);
marker.setParentFrame(model.getBodySet().get(body));
marker.set_location(Vec3(point(1), height, point(2)));
model.addMarker(marker);
end

% Find points to use for determining which body a spring marker belongs to
function [point1, point2] = findTwoPointsOnToeJointAxis(model, ...
    toesJointName)
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
end

% Convert OpenSim rotation matrix to Matlab Array
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

function out = isBelowToeJoint(medialPt, lateralPt, springPt)
lineX = [medialPt(2), lateralPt(2)];
lineY = [medialPt(1), lateralPt(1)];
springLineX = [springPt(1), 1];
springLineY = ones(1, length(springLineX)) * springPt(2);
out = checkIntersection(lineX, lineY, springLineX, springLineY);
end