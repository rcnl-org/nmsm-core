% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the experimental and
% predicted joint angles for the specified coordinate.
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function cost = calcTrackingSpeedIntegrand(costTerm, inputs, time, ...
    velocities, coordinateName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if normalizeByFinalTime
    time = time * inputs.experimentalTime(end) / time(end);
end
indx = find(strcmp(convertCharsToStrings(inputs.coordinateNames), ...
    coordinateName));
if isempty(indx)
    throw(MException('CostTermError:CoordinateNotInState', ...
        strcat("Coordinate ", coordinateName, " is not in the ", ...
        "<states_coordinate_list>")))
end
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        all(time == inputs.collocationTimeOriginal)
    experimentalJointVelocities = inputs.splinedJointSpeeds;
else
    experimentalJointVelocities = evaluateGcvSplines( ...
        inputs.splineJointAngles, inputs.coordinateNames, time, 1);
end

cost = calcTrackingCostArrayTerm(experimentalJointVelocities, ...
    velocities, indx);

if normalizeByFinalTime
    cost = cost / time(end);
end
end