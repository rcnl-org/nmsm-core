% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct) -> (Array of number)
% Converts euler angle sequences using a rotation matrix.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function angles = convertAnglesToSequence(angles, sequence)
rotationMatrices = makeRotationMatrices(angles);
switch sequence
    case 'xyz'
        return
    case 'xzy'
        angles(:, 1) = atan2(rotationMatrices(:, 3, 2), ...
            rotationMatrices(:, 2, 2));
        angles(:, 2) = atan2(-rotationMatrices(:, 1, 2), ...
            sqrt(rotationMatrices(:, 3, 2) .^ 2 + ...
            rotationMatrices(:, 2, 2) .^ 2));
        angles(:, 3) = atan2(rotationMatrices(:, 1, 3), ...
            rotationMatrices(:, 1, 1));
    case 'yxz'
        angles(:, 1) = atan2(rotationMatrices(:, 1, 3), ...
            rotationMatrices(:, 3, 3));
        angles(:, 2) = atan2(-rotationMatrices(:, 2, 3), ...
            sqrt(rotationMatrices(:, 1, 3) .^ 2 + ...
            rotationMatrices(:, 3, 3) .^ 2));
        angles(:, 3) = atan2(rotationMatrices(:, 2, 1), ...
            rotationMatrices(:, 2, 2));
    case 'yzx'
        angles(:, 1) = atan2(-rotationMatrices(:, 3, 1), ...
            rotationMatrices(:, 1, 1));
        angles(:, 2) = atan2(rotationMatrices(:, 2, 1), ...
            sqrt(rotationMatrices(:, 3, 1) .^ 2 + ...
            rotationMatrices(:, 1, 1) .^ 2));
        angles(:, 3) = atan2(-rotationMatrices(:, 2, 3), ...
            rotationMatrices(:, 2, 2));
    case 'zxy'
        angles(:, 1) = atan2(-rotationMatrices(:, 1, 2), ...
            rotationMatrices(:, 2, 2));
        angles(:, 2) = atan2(rotationMatrices(:, 3, 2), ...
            sqrt(rotationMatrices(:, 1, 2) .^ 2 + ...
            rotationMatrices(:, 2, 2) .^ 2));
        angles(:, 3) = atan2(-rotationMatrices(:, 3, 1), ...
            rotationMatrices(:, 3, 3));
    case 'zyx'
        angles(:, 1) = atan2(rotationMatrices(:, 2, 1), ...
            rotationMatrices(:, 1, 1));
        angles(:, 2) = atan2(-rotationMatrices(:, 3, 1), ...
            sqrt(rotationMatrices(:, 2, 1) .^ 2 + ...
            rotationMatrices(:, 1, 1) .^ 2));
        angles(:, 3) = atan2(rotationMatrices(:, 3, 2), ...
            rotationMatrices(:, 3, 3));
    otherwise
        throw(MException('', "Rotation sequence " + sequence + ...
            " is not supported. Supported sequences are xyz, xzy, " + ...
            "yxz, yzx, zxy, and zyx."))
end
end

function rotationMatrices = makeRotationMatrices(angles)
rotationMatrices(:, 1, 1) = cos(angles(:, 2)) .* cos(angles(:, 3));
rotationMatrices(:, 1, 2) = -sin(angles(:, 3)) .* cos(angles(:, 2));
rotationMatrices(:, 1, 3) = sin(angles(:, 2));
rotationMatrices(:, 2, 1) = sin(angles(:, 3)) .* cos(angles(:, 1)) + ...
    sin(angles(:, 1)) .* sin(angles(:, 2)) .* cos(angles(:, 3));
rotationMatrices(:, 2, 2) = cos(angles(:, 1)) .* cos(angles(:, 3)) - ...
    sin(angles(:, 1)) .* sin(angles(:, 2)) .* sin(angles(:, 3));
rotationMatrices(:, 2, 3) = -sin(angles(:, 1)) .* cos(angles(:, 2));
rotationMatrices(:, 3, 1) = sin(angles(:, 1)) .* sin(angles(:, 3)) - ...
    sin(angles(:, 2)) .* cos(angles(:, 1)) .* cos(angles(:, 3));
rotationMatrices(:, 3, 2) = sin(angles(:, 1)) .* cos(angles(:, 3)) + ...
    sin(angles(:, 2)) .* sin(angles(:, 3)) .* cos(angles(:, 1));
rotationMatrices(:, 3, 3) = cos(angles(:, 1)) .* cos(angles(:, 2));
end
