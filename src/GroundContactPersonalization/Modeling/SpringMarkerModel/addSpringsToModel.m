% This function is part of the NMSM Pipeline, see file for full license.
%
% Adds spring markers to a foot model. This function determines where
% spring markers are needed and passes this information to
% addSpringsToModelAtLocations().
%
% (Model, struct, double, double, string, string, string, logical, struct) 
% -> (Model)
% Add spring markers to isolated footModel. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function model = addSpringsToModel(model, markerNames, gridWidth, ...
    gridHeight, hindfootBodyName, toesBodyName, toesJointName, ...
    isLeftFoot, meanMarkerLocations)
points = makeNormalizedGrid(gridWidth, gridHeight, isLeftFoot);
[insidePoints, ~] = splitNormalizedGridPoints(points, isLeftFoot);

% Mean marker locations were calculated by mirroring left foot markers.
% As mean marker locations are for a right foot, the marker Z positions
% must be mirrored. 
if isLeftFoot
    for marker = 1:length(fieldnames(meanMarkerLocations))
        fieldNames = fieldnames(meanMarkerLocations);
        currentMarker = meanMarkerLocations.(fieldNames{marker});
        currentMarker(2) = -1 * currentMarker(2);
        meanMarkerLocations.(fieldNames{marker}) = currentMarker;
    end
end

markerPositions = rotateMarkersToeToHeelVertical(meanMarkerLocations);
normalizedMarkerPositions = removeNormalizedMarkerOffsets( ...
    normalizeMarkerPositions(markerPositions));
model = addSpringsToModelAtLocations(model, markerPositions, ...
    normalizedMarkerPositions, insidePoints, toesJointName, ...
    hindfootBodyName, toesBodyName, markerNames.heel, isLeftFoot);
model.finalizeConnections();
end

