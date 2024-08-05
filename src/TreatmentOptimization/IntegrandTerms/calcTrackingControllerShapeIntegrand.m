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

function cost = calcTrackingControllerShapeIntegrand(costTerm, inputs, ...
    values, time, controllerName)
normalizeByFinalTime = valueOrAlternate(costTerm, ...
    "normalize_by_final_time", true);
if normalizeByFinalTime && all(size(time) == size(inputs.collocationTimeOriginal))
    time = time * inputs.collocationTimeOriginal(end) / time(end);
end
if strcmp(inputs.controllerType, 'synergy')
    indx = find(strcmp(convertCharsToStrings( ...
        inputs.synergyLabels), controllerName));
    if ~isempty(indx)
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
                max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
            synergyActivations = inputs.splinedSynergyActivations;
        else
            synergyActivations = ...
                evaluateGcvSplines(inputs.splineSynergyActivations, ...
                inputs.synergyLabels, time);
        end
        experimentalControl = synergyActivations(:, indx);
        referenceControl = values.controlSynergyActivations(:, indx);
        scaleFactor = referenceControl \ experimentalControl;
        cost = experimentalControl - (referenceControl * scaleFactor);
        return
    end
end
indx1 = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueLabels, '_moment')), controllerName));
indx2 = find(strcmp(convertCharsToStrings( ...
    strcat(inputs.torqueControllerCoordinateNames, '_moment')), ...
    controllerName));
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
    experimentalJointMoments = inputs.splinedTorqueControls;
else
    experimentalJointMoments = ...
        evaluateGcvSplines(inputs.splineTorqueControls, ...
        inputs.torqueLabels, time);
end
experimentalControl = experimentalJointMoments(:, indx1);
referenceControl = values.torqueControls(:, indx2);
scaleFactor = referenceControl \ experimentalControl;
cost = experimentalControl - (referenceControl * scaleFactor);
if normalizeByFinalTime
    if all(size(time) == size(inputs.collocationTimeOriginal))
        cost = cost / time(end);
    else
        cost = cost / inputs.collocationTimeOriginal(end);
    end
end
end
