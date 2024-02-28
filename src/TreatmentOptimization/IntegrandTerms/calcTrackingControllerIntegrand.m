% This function is part of the NMSM Pipeline, see file for full license.
%
% If the model is synergy driven, this function tracks the difference
% between original and current synergy activation controls. If the model is
% torque driven, this function tracks the difference between inverse
% dynamics moments and current torque controls.
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

function cost = calcTrackingControllerIntegrand(costTerm, inputs, ...
    values, time, controllerName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if strcmp(inputs.controllerType, 'synergy')
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    if ~isempty(indx)
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
            all(time == inputs.collocationTimeOriginal)
            synergyActivations = inputs.splinedSynergyActivations;
        else
            synergyActivations = ...
                evaluateGcvSplines(inputs.splineSynergyActivations, ...
                inputs.synergyLabels, time);
        end
        cost = calcTrackingCostArrayTerm(synergyActivations, ...
            values.controlSynergyActivations, indx);
        return
    end
end
indx1 = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueLabels, '_moment')), controllerName));
indx2 = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueControllerCoordinateNames, '_moment')), ...
    controllerName));
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        all(time == inputs.collocationTimeOriginal)
    experimentalJointMoments = inputs.splinedTorqueControls;
else
    experimentalJointMoments = ...
        evaluateGcvSplines(inputs.splineTorqueControls, ...
        inputs.torqueLabels, time);
end
cost = experimentalJointMoments(:, indx1) - ...
    values.torqueControls(:, indx2);
if normalizeByFinalTime
    cost = cost / time(end);
end
end
