% This function is part of the NMSM Pipeline, see file for full license.
%
% CasADi-safe equivalent of calcNcpCost.m, mirroring its cost-term
% switch and scaling exactly. Built on the 2-D-only helpers in this
% branch's CasADi files, since CasADi MX/SX do not support N-D arrays.
% inputs.inverseDynamicsMoments/inputs.mtpActivations are flattened here
% (they are constant numeric data, not design-variable-dependent, so
% ordinary 3-D reshapes on them are safe).
%
% (Array of number, struct, struct) -> (number)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function cost = calcCasadiNcpCost(values, inputs, params)
[activations2d, ~] = calcCasadiActivationsFromSynergyDesignVariables( ...
    values, inputs);
cost = 0;
if isfield(inputs, 'mtpActivationsColumnNames')
    [activationsWithMtpData, activationsWithoutMtpData] = ...
        makeCasadiMtpActivatonSubset(activations2d, ...
        inputs.mtpActivationsColumnNames, inputs.muscleTendonColumnNames);
else
    activationsWithoutMtpData = activations2d;
end
for term = 1:length(params.costTerms)
    costTerm = params.costTerms{term};
    if costTerm.isEnabled
        switch costTerm.type
            case "moment_tracking"
                muscleJointMoments2d = calcCasadiMuscleJointMoments( ...
                    inputs, activations2d);
                rawCost = muscleJointMoments2d - ...
                    flattenTrialFirstDim(inputs.inverseDynamicsMoments);
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - ...
                        flattenTrialFirstDim(inputs.mtpActivations);
                else
                    rawCost = 0;
                end
            case "activation_minimization"
                errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
                rawCost = reshape(activationsWithoutMtpData, ...
                    numel(activationsWithoutMtpData), 1) - errorCenter;
            case "grouped_activations"
                rawCost = calcCasadiGroupedActivationCost( ...
                    activations2d, params);
            case "grouped_fiber_lengths"
                rawCost = calcCasadiGroupedNormalizedFiberLengthCost( ...
                    activations2d, params);
            case "activation_bounds"
                rawCost = calcActivationBoundsCost(activations2d, costTerm);
            otherwise
                throw(MException('', ['Cost term type ' ...
                    char(costTerm.type) ' does not exist for this tool.']))
        end
        rawCost = reshape(rawCost, numel(rawCost), 1);
        rawCostScaled = (rawCost / costTerm.maxAllowableError) / ...
            sqrt(numel(rawCost));
        cost = cost + rawCostScaled.' * rawCostScaled;
    end
end
end

% Flattens a [numTrials x numColumns x numPoints] numeric array into
% [numTrials*numPoints x numColumns]
function flat = flattenTrialFirstDim(data)
numTrials = size(data, 1);
numColumns = size(data, 2);
numPoints = size(data, 3);
flat = reshape(permute(data, [3 1 2]), numTrials * numPoints, numColumns);
end
