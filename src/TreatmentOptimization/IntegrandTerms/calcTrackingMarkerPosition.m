% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the error in marker tracking
%
% (struct, Array of number, 2D matrix, Array of string) -> (Array of number)
% returns the distance between the experimental and calculated markers.

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

function cost = calcTrackingMarkerPosition(costTerm, time, ...
    markerPositions, inputs)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
axes = lower(valueOrAlternate(costTerm, "axes", "xyz"));
if normalizeByFinalTime && all(size(time) == size(inputs.collocationTimeOriginal))
    time = time * inputs.collocationTimeOriginal(end) / time(end);
end
indx = find(strcmp(convertCharsToStrings(inputs.trackedMarkerNames), ...
    costTerm.marker));
if isempty(indx)
    throw(MException('CostTermError:MarkerDoesNotExist', ...
        strcat("Marker ", costTerm.marker, " is not in the ", ...
        "list of tracked markers")))
end
assert(length(indx) == 1, "Marker " + costTerm.marker + ...
    " must only have one tracking cost term.")
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
    experimentalMarkerPositions = inputs.splinedMarkerPositions{indx};
else
    experimentalMarkerPositions = ...
        evaluateGcvSplines(inputs.splineMarkerPositions{indx}, ...
        0:2, time);
end
experimentalIndex = (indx - 1) * 3 + 1;
cost = calcTrackingCostArrayTerm(experimentalMarkerPositions, ...
    markerPositions, experimentalIndex);
if ~contains(axes, "x")
    cost(:) = 0;
end
if contains(axes, "y")
    cost = cost + calcTrackingCostArrayTerm(experimentalMarkerPositions, ...
        markerPositions, experimentalIndex + 1);
end
if contains(axes, "z")
    cost = cost + calcTrackingCostArrayTerm(experimentalMarkerPositions, ...
        markerPositions, experimentalIndex + 2);
end
if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end

