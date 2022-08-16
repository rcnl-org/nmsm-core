% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (Array of double, struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function [valueError, slopeError] = ...
    calcFootMarkerPositionAndSlopeError(inputs, modeledValues)
markerFieldNames = fieldnames(inputs.markerNames);
valueError = [];
slopeError = [];
for i=1:length(markerFieldNames)
newValues = abs(inputs.experimentalMarkerPositions. ...
    (markerFieldNames{i}) - modeledValues.markerPositions. ...
    (markerFieldNames{i}));
newSlope = abs(inputs.experimentalMarkerVelocities. ...
    (markerFieldNames{i}) - modeledValues.markerVelocities. ...
    (markerFieldNames{i}));
valueError = [valueError newValues];
slopeError = [slopeError newSlope];
end
valueError = 1000 * sum(valueError, 1);
slopeError = sum(slopeError, 1);
end
