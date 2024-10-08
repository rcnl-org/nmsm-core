% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct from the
% settings XML file common to all treatment optimizatin modules (trackning,
% verification, and design optimization).
%
% (struct) -> (struct, struct)
% returns the input values for all treatment optimization modules

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

function inputs = makeMarkerTracking(inputs)
names = string([]);
locations = [];
bodies = [];
for i = 1:length(inputs.costTerms)
    costTerm = inputs.costTerms{i};
    if strcmp(costTerm.type, "marker_position_tracking")
        names(end + 1) = convertCharsToStrings(inputs.model.getMarkerSet().get( ...
            costTerm.marker).getName().toCharArray()');
        locations = cat(1, locations, ...
            Vec3ToArray(inputs.model.getMarkerSet().get(...
            costTerm.marker).get_location()));
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            getMarkerBodyName(inputs.model, costTerm.marker));
    end
end
inputs.trackedMarkerNames = names;
inputs.trackedMarkerLocations = locations;
inputs.trackedMarkerBodyIndices = bodies;
if ~isempty(inputs.trackedMarkerNames)
    inputs.experimentalMarkerPositions = pointKinematics( ...
        inputs.experimentalTime, inputs.experimentalJointAngles, ...
        inputs.experimentalJointVelocities, inputs.trackedMarkerLocations, ...
        inputs.trackedMarkerBodyIndices, inputs.mexModel, ...
        inputs.coordinateNames, inputs.osimVersion);
    for i = 1:size(inputs.experimentalMarkerPositions, 3)
        experimentalMarkerPositions = ...
            reshape(inputs.experimentalMarkerPositions(:, :, i), ...
            size(inputs.experimentalMarkerPositions, 1), []);
        inputs.splineMarkerPositions{i} = makeGcvSplineSet(inputs.experimentalTime, ...
            experimentalMarkerPositions, ["x", "y", "z"]);
    end
end
end

