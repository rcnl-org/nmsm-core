% This function is part of the NMSM Pipeline, see file for full license.
%
% If the model is synergy driven, this function tracks the difference
% between current and smoothed synergy activation controls. If the model is
% torque driven, this function uses torque controls.
%
% (struct, struct, Array of number, Array of string) -> (Array of number)
%

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

function cost = calcSmoothingControllerIntegrand(costTerm, inputs, ...
    values, time, controllerName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if normalizeByFinalTime && all(size(time) == size(inputs.collocationTimeOriginal))
    normTime = time * inputs.collocationTimeOriginal(end) / time(end);
end
control = [];
if strcmp(inputs.controllerType, 'synergy')
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    if ~isempty(indx)
        control = values.controlSynergyActivations(:, indx);
    end
end
if isempty(control)
    indx = find(strcmp(convertCharsToStrings( ...
        strcat(inputs.torqueControllerCoordinateNames, '_moment')), ...
        controllerName));
    control = values.torqueControls(:, indx);
end
assert(~isempty(control), "Could not find controller " + controllerName);

polynomialDegree = valueOrAlternate(costTerm, "polynomial_degree", 1);
harmonics = valueOrAlternate(costTerm, "harmonics", 7);
% Must account for free final time when determining true time range
if length(time) == length(inputs.collocationTimeOriginal)
    timeScaling = time(end) / inputs.collocationTimeOriginal(end);
elseif length(time) == length(inputs.collocationTimeOriginalWithEnd)
    timeScaling = time(end) / inputs.collocationTimeOriginalWithEnd(end);
else
    timeScaling = 1;
end
frequency = 1 / (timeScaling * inputs.collocationTimeOriginalWithEnd(end));
coefficients = polyFourierCoefs(time, control, frequency, ...
    polynomialDegree, harmonics);
fit = polyFourierCurves(coefficients, frequency, time, ...
    polynomialDegree, 0);
cost = fit - control;

if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / normTime(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end
