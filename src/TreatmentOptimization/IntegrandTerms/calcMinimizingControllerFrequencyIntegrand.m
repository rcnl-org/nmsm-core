% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct, Array of number, Array of string) -> (Array of number)
% Minimizes the average frequency of a control. 

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

function cost = calcMinimizingControllerFrequencyIntegrand(costTerm, ...
    inputs, values, time, controllerName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", false);
indx = [];
if inputs.controllerTypes(2)
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    control = values.controlSynergyActivations(:, indx);
end
if isempty(indx)
    indx = find(strcmp(convertCharsToStrings( ...
        strcat(inputs.torqueLabels, '_moment')), controllerName));
    if isempty(indx)
        indx = find(strcmp(convertCharsToStrings( ...
            strcat(inputs.torqueLabels, '_force')), controllerName));
    end
    control = values.torqueControls(:, indx);
end
assert(~isempty(indx), "Controller " + controllerName + " is not a " + ...
    "synergy or torque controller.")

period = mean(diff(time));
numPoints = length(time);
frequencies = (0 : numPoints - 1)' / numPoints / period;
transform = abs(nufft(control, time / period));
averageFrequency = sum(frequencies .* transform) / sum(transform);
cost = averageFrequency * ones(size(control));

if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end
