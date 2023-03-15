% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns an array of names of coordinates that connect the
% ground to the contact bodies. These coordinates all will be modeled in
% the kinematic model for GCP.
%
% coordinatesOfInterest can be found from findGCPFreeCoordinates()
%
% markerNames is a struct of strings with 4 fields (toe, medial, ...
% lateral, heel)
%
% markerPositions is a struct of arrays of double with the same fields as
% markerNames
%
% (Model, string, Array of string, string, string, struct, double, double) 
% -> (2D Array of double)
% Create an array of coordinate names connecting the bodies to ground

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

function [footPosition, markerPositions] = ...
    makeFootKinematics(model, motionFileName, coordinatesOfInterest, ...
    hindfootBodyName, toesJointName, markerNames, startTime, endTime, ...
    isLeftFoot)

import org.opensim.modeling.Storage
[model, state] = Model(model);
[columnNames, time, jointKinematicsData] = parseMotToComponents(model, ...
    Storage(motionFileName));
startIndex = find(time >= startTime, 1, 'first');
endIndex = find(time <= endTime, 1, 'last');
time = time(startIndex:endIndex);
jointKinematicsData = jointKinematicsData(:, startIndex:endIndex);

columnsOfInterest = [];
for i=1:length(coordinatesOfInterest)
    columnsOfInterest(end+1) = find( ...
        columnNames==coordinatesOfInterest(i));
end

experimentalJointKinematics = jointKinematicsData(columnsOfInterest, :);

functions = { % defining the 7 free coordinates to record
    @(model, state)model.getCoordinateSet().get(toesJointName). ...
    getValue(state),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getRotationInGround(state).convertRotationToBodyFixedXYZ().get(0),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getRotationInGround(state).convertRotationToBodyFixedXYZ().get(1),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getRotationInGround(state).convertRotationToBodyFixedXYZ().get(2),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getPositionInGround(state).get(0),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getPositionInGround(state).get(1),
    @(model, state)model.getBodySet().get(hindfootBodyName). ...
    getPositionInGround(state).get(2),
    };

footPosition = zeros(7, length(time));

markerNamesFields = fieldnames(markerNames);
for i=1:length(markerNamesFields)
    markerPositions.(markerNamesFields{i}) = zeros(3, length(time));
end

for i=1:length(time)
    state.setTime(time(i));
    for j=1:length(coordinatesOfInterest)
        model.getCoordinateSet().get(coordinatesOfInterest(j)). ...
            setValue(state, experimentalJointKinematics(j, i));
    end
    for j=1:length(functions)
        footPosition(j, i) = functions{j}(model, state);
    end
    for j=1:length(markerNamesFields)
        markerPositions.(markerNamesFields{j})(:, i) = model. ...
            getMarkerSet().get(markerNames.(markerNamesFields{j})). ...
            getLocationInGround(state).getAsMat()';
    end

    % Convert rotation angles to Y-X-Z (or (-Y)-(-X)-Z for left foot) sequence
    rotationMatrix = calcXyzRotationMatrix(footPosition(2, i), ...
        footPosition(3, i), footPosition(4, i));
    if isLeftFoot
        [footPosition(3, i), footPosition(2, i), footPosition(4, i)] = ...
            calcLeftFootAngles(rotationMatrix);
    else
        [footPosition(3, i), footPosition(2, i), footPosition(4, i)] = ...
            calcRightFootAngles(rotationMatrix);
    end
end
end

% Form x-y-z rotation matrix from three rotation angles
function R = calcXyzRotationMatrix(q1, q2, q3)
R = zeros(3,3);
R(1,1) = cos(q2)*cos(q3);
R(1,2) = -sin(q3)*cos(q2);
R(1,3) = sin(q2);
R(2,1) = sin(q3)*cos(q1)+sin(q1)*sin(q2)*cos(q3);
R(2,2) = cos(q1)*cos(q3)-sin(q1)*sin(q2)*sin(q3);
R(2,3) = -sin(q1)*cos(q2);
R(3,1) = sin(q1)*sin(q3)-sin(q2)*cos(q1)*cos(q3);
R(3,2) = sin(q1)*cos(q3)+sin(q2)*sin(q3)*cos(q1);
R(3,3) = cos(q1)*cos(q2);
end

function [q1,q2,q3] = calcRightFootAngles(R)
q1 = atan2(R(1,3),R(3,3));
q2 = atan2(-R(2,3),sqrt(R(1,3)^2+R(3,3)^2));
q3 = atan2(R(2,1),R(2,2));
end

function [q1,q2,q3] = calcLeftFootAngles(R)
q1 = atan2(-R(1,3),R(3,3));
q2 = atan2(R(2,3),sqrt(R(1,3)^2+R(3,3)^2));
q3 = atan2(R(2,1),R(2,2));
end
