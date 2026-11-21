% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates, for each contact surface, the shadow foot
% coordinate values that match the pose of the model's foot. The hindfoot
% pose comes from point kinematics of the hindfoot origin and of unit
% points along its x, y, and z axes. The toe angle comes from the model's
% toe coordinate. The columns of each target match
% contactSurfaces{i}.shadowCoordinateNames.
%
% (struct, struct, cell array) -> (cell array)
% Calculates the shadow foot pose targets for the shadow_foot_pose term

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

function targets = calcShadowFootTargets(values, inputs, hindfootFrames)
targets = cell(1, length(inputs.contactSurfaces));
for i = 1 : length(inputs.contactSurfaces)
    % [frames, xyz, point] with points origin, +x, +y, +z
    points = reshape(hindfootFrames{i}, size(hindfootFrames{i}, 1), 3, 4);
    origin = points(:, :, 1);
    % R(row, column, frame): column c is body axis c expressed in ground
    R = permute(points(:, :, 2 : 4) - origin, [2 3 1]);
    angles = calcHindfootJointAngles(R, ...
        inputs.contactSurfaces{i}.isLeftFoot);
    targets{i} = [values.positions(:, ...
        inputs.contactSurfaces{i}.toesCoordinateIndex), angles, origin];
end
end
