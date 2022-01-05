% This function is part of the NMSM Pipeline, see file for full license.
%
% (string or Model, number, cellArray of string, string) -> (number)
% Returns the calculated cost function error for the given inputs

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

function error = calculateJointError(model, desiredError, jointNames, ...
    markerFileName, accuracy)
model = Model(model);
params.markerNames = {};
params.desiredError = desiredError;
params.accuracy = accuracy;
for i=1:length(jointNames)
    newMarkerNames = getMarkersFromJoint(model, jointNames{i});
    for j=1:length(newMarkerNames)
        if(~markerIncluded(params.markerNames, newMarkerNames{j}))
            params.markerNames{length(params.markerNames)+1} = ...
                newMarkerNames{j};
        end
    end
end
error = computeInnerOptimization([], {}, model, markerFileName, params);
error = sum(error.^2);
end