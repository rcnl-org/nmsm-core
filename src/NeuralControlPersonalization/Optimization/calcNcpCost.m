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

function cost = calcNcpCost(values, inputs, params, initialValues)
[activations, weights, commands] = calcActivationsFromSynergyDesignVariables(values, inputs);

error = [];
weightsByGroup = findSynergyWeightsByGroup(values, inputs);
weightsByGroupInit = findSynergyWeightsByGroup(initialValues, inputs);

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
                % fprintf("moment_tracking\n")
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - inputs.mtpActivations;
                else
                    rawCost = 0;
                end
                % fprintf("activation_tracking\n")
            case "activation_minimization"
                errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
                rawCost = reshape(activationsWithoutMtpData, [], 1) - errorCenter;
                % fprintf("activation_minimization\n")
            case "grouped_activations"
                rawCost = calcGroupedActivationCost(activations, ...
                    inputs, params);
                % fprintf("grouped_activations\n")
            case "grouped_fiber_lengths"
                rawCost = calcGroupedNormalizedFiberLengthCost( ...
                    activations, inputs, params);
                % fprintf("grouped_fiber_lengths\n")
            case "bilateral_symmetry"
                if length(inputs.synergyGroups) ~= 2
                    throw(MException('', ['Bilateral symmetry cost ' ...
                        'requires exactly two synergy groups.']))
                end
                rawCost = weightsByGroup(1, :, :) - weightsByGroup(2, :, :);
                % fprintf("bilateral_symmetry\n")
            case "synergy_activation_minimization"
                % synergy_activation_minimization
                rawCost = commands(:);
                % fprintf("weights_deviation\n")
            case "minimize_weights_changes"
                rawCost = weightsByGroup-weightsByGroupInit;
                % fprintf("minimize_weights_changes\n")
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        rawCost = rawCost(:);
        rawCost_scaled = (rawCost/ costTerm.maxAllowableError) / sqrt(numel(rawCost));
        error = [error; rawCost_scaled];
    end
end

cost = error' * error;
end
