% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the joint power error for the specified
% coordinate and generation goal. Only positive power (generated energy) is
% included in the output. 
%
% (2D matrix, 2D matrix, struct, Array of string) -> (Array of number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Marleny Vega                               %
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

function [cost, costTerm] = calcJointEnergyGenerationGoalIntegrand( ...
    costTerm, jointVelocity, time, jointMoment, params, loadName)
defaultTimeNormalization = true;
[time, costTerm] = normalizeTimeColumn(costTerm, inputs, time, ...
    defaultTimeNormalization);

loadName = erase(loadName, '_moment');
loadName = erase(loadName, '_force');
indx = find(strcmp(convertCharsToStrings(params.coordinateNames), ...
    loadName));
momentLabelsNoSuffix = erase(params.inverseDynamicsMomentLabels, '_moment');
momentLabelsNoSuffix = erase(momentLabelsNoSuffix, '_force');
includedJointMomentCols = ismember(momentLabelsNoSuffix, ...
    convertCharsToStrings(params.coordinateNames));
if isequal(mexext, 'mexw64')
    jointMoment = jointMoment(:, includedJointMomentCols);
end
jointPower = jointMoment(:, indx) .* jointVelocity(:, indx);

cost = real(sqrt((jointPower - costTerm.errorCenter) / ...
    costTerm.maxAllowableError));

cost = normalizeCostByFinalTime(costTerm, inputs, time, cost);
end
