% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string) -> (Array of number)
%
% Finds splined marker velocities given labels.

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

function experimentalMarkerVelocities = ...
    findSplinedMarkerVelocitiesByLabels(term, inputs, time)
markerNameIndices = term.internalMarkerNameIndices;
markerAxesIndices = term.internalMarkerAxesIndices;
experimentalMarkerVelocities = zeros(length(time), ...
    sum(any(markerAxesIndices)), length(markerNameIndices));
includedAxes = find(any(markerAxesIndices, 1));
for i = 1 : length(markerNameIndices)
    for j = 1 : length(includedAxes)
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
                max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
            markerVelocities = ...
                inputs.splinedMarkerVelocities{markerNameIndices(i)};
            experimentalMarkerVelocities(:, j, i) = ...
                markerVelocities(:, includedAxes(j));
        elseif all(size(time) == size(inputs.collocationTimeOriginalWithEnd)) && ...
                max(abs(time - inputs.collocationTimeOriginalWithEnd)) < 1e-6
            markerVelocities = ...
                inputs.splinedMarkerVelocities{markerNameIndices(i)};
            experimentalMarkerVelocities(1 : end - 1, j, i) = ...
                markerVelocities(:, includedAxes(j));
            experimentalMarkerVelocities(end, j, i) = ...
                inputs.experimentalMarkerVelocities(end, ...
                includedAxes(j), markerNameIndices(i));
        elseif length(time) == 2
            experimentalMarkerVelocities(:, j, i) = ...
                inputs.experimentalMarkerVelocities([1 end], ...
                includedAxes(j), markerNameIndices(i));
        else
            experimentalMarkerVelocities(:, j, i) = evaluateGcvSplines( ...
                inputs.splineMarkerVelocities{ ...
                markerNameIndices(i)}, ...
                includedAxes(j) - 1, time);
        end
    end
end
end
