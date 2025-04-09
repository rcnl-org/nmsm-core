% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates a cost for minimizing control magnitude.
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

function cost = calcMinimizingControllerIntegrand(costTerm, inputs, ...
    values, time, controllerName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if normalizeByFinalTime && all(size(time) == size(inputs.collocationTimeOriginal))
    time = time * inputs.collocationTimeOriginal(end) / time(end);
end
if inputs.controllerTypes(2)
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    if ~isempty(indx)
        cost = values.controlSynergyActivations(:, indx);
        if normalizeByFinalTime
            if all(size(time) == size(inputs.collocationTimeOriginal))
                cost = cost / time(end);
            else
                cost = cost / inputs.collocationTimeOriginal(end);
            end
        end
        return
    end
end
indx = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueControllerCoordinateNames, '_moment')), ...
    controllerName));
cost = values.torqueControls(:, indx);
if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end
