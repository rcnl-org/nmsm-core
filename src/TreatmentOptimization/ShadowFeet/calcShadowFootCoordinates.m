% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the shadow foot coordinate values that place
% each shadow foot in the same pose as the model's foot for the given
% joint angles. For each contact surface, the columns are the toe angle,
% the three ground joint rotations (Ground Contact Personalization
% rotation sequence), and the three ground joint translations, matching
% contactSurfaces{i}.shadowCoordinateNames.
%
% Coordinates are set the same way as pointKinematics (unlocked
% coordinates only, constraints are not enforced) so that the result is
% consistent with the hindfoot pose used inside the optimization.
%
% (string, double array, cell array, cell array of struct) ->
% (double array, string array)
% Calculates shadow foot coordinates from model joint angles

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function [shadowCoordinates, shadowCoordinateNames] = ...
    calcShadowFootCoordinates(modelFileName, jointAngles, ...
    coordinateNames, contactSurfaces)
[model, state] = Model(modelFileName);
coordinateNames = cellstr(coordinateNames);
coordinateSet = model.getCoordinateSet();
coordinates = {};
columns = [];
for i = 1 : length(coordinateNames)
    if coordinateSet.contains(coordinateNames{i}) && ...
            ~coordinateSet.get(coordinateNames{i}).get_locked()
        coordinates{end + 1} = coordinateSet.get(coordinateNames{i});
        columns(end + 1) = i;
    end
end

numFrames = size(jointAngles, 1);
numSurfaces = length(contactSurfaces);
rotations = zeros(3, 3, numFrames, numSurfaces);
positions = zeros(numFrames, 3, numSurfaces);
toeAngles = zeros(numFrames, numSurfaces);
for frame = 1 : numFrames
    for j = 1 : length(coordinates)
        coordinates{j}.setValue(state, jointAngles(frame, columns(j)), ...
            false);
    end
    model.realizePosition(state);
    for i = 1 : numSurfaces
        hindfoot = model.getBodySet().get( ...
            contactSurfaces{i}.hindfootBodyName);
        rotation = hindfoot.getRotationInGround(state).asMat33();
        position = hindfoot.getPositionInGround(state);
        for row = 1 : 3
            for column = 1 : 3
                rotations(row, column, frame, i) = ...
                    rotation.get(row - 1, column - 1);
            end
            positions(frame, row, i) = position.get(row - 1);
        end
        toeAngles(frame, i) = coordinateSet.get( ...
            contactSurfaces{i}.toesCoordinateName).getValue(state);
    end
end

shadowCoordinates = zeros(numFrames, 7 * numSurfaces);
shadowCoordinateNames = string([]);
for i = 1 : numSurfaces
    angles = calcHindfootJointAngles(rotations(:, :, :, i), ...
        contactSurfaces{i}.isLeftFoot);
    % Keep the rotations continuous in time so they spline smoothly
    angles = unwrap(angles, [], 1);
    shadowCoordinates(:, 7 * (i - 1) + (1 : 7)) = ...
        [toeAngles(:, i), angles, positions(:, :, i)];
    shadowCoordinateNames = [shadowCoordinateNames, ...
        reshape(contactSurfaces{i}.shadowCoordinateNames, 1, [])];
end
end
