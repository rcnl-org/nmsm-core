% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes the necessary inputs and produces the results of IK,
% ID, and MuscleAnalysis so the values can be used as inputs for
% MuscleTendonPersonalization.
%
% (struct, struct) -> (None)
% Prepares raw data for MuscleTendonPersonalization

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

function cost = calcNcpCost(activations, inputs, params, values)

error = [];
% Split activations into subsets ahead of cost computation
if isfield(inputs, 'mtpActivationsColumnNames')
    [activationsWithMtpData, activationsWithoutMtpData] = ...
        makeMtpActivatonSubset(activations, ...
        inputs.mtpActivationsColumnNames, inputs.muscleTendonColumnNames);
else
    activationsWithoutMtpData = activations;
end
for term = 1:length(params.costTerms)
    costTerm = params.costTerms{term};
    if costTerm.isEnabled
        switch costTerm.type
            case "moment_tracking"
                [normalizedFiberLengths, normalizedFiberVelocities] = ...
                    calcNormalizedMuscleFiberLengthsAndVelocities( ...
                    inputs, inputs.optimalFiberLengthScaleFactors, ...
                    inputs.tendonSlackLengthScaleFactors);
                muscleJointMoments = calcMuscleJointMoments(inputs, ...
                    activations, normalizedFiberLengths, ...
                    normalizedFiberVelocities);
                rawCost = muscleJointMoments - ...
                    inputs.inverseDynamicsMoments;
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - inputs.mtpActivations;
                else
                    rawCost = 0;
                end
            case "activation_minimization"
                rawCost = reshape(activationsWithoutMtpData, [], 1);
            case "grouped_activations"
                rawCost = calcGroupedActivationCost(activations, ...
                    inputs, params);
            case "grouped_fiber_lengths"
                rawCost = calcGroupedNormalizedFiberLengthCost( ...
                    activations, inputs, params);
            case "bilateral_symmetry"
                if length(inputs.synergyGroups) ~= 2
                    throw(MException('', ['Bilateral symmetry cost ' ...
                        'requires exactly two synergy groups.']))
                end
                weights = findSynergyWeightsByGroup(values, inputs);
                rawCost = weights(1, :, :) - weights(2, :, :);
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        error = [error; (rawCost(:) / costTerm.maxAllowableError) / ...
            sqrt(numel(rawCost))];
    end
end

cost = error' * error;
end
