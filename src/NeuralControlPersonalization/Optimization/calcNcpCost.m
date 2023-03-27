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
[normalizedFiberLengths, normalizedFiberVelocities] = ...
    calcNormalizedMuscleFiberLengthsAndVelocities(inputs, ...
    inputs.optimalFiberLengthScaleFactors, ...
    inputs.tendonSlackLengthScaleFactors);
muscleJointMoments = calcMuscleJointMoments(inputs, ...
    activations, normalizedFiberLengths, normalizedFiberVelocities);

torqueErrors = muscleJointMoments - inputs.inverseDynamicsMoments;
momentTrackingError = params.momentTrackingWeight ^ 0.5 * (torqueErrors(:) / ...
    params.momentTrackingAllowableError) / ...
    numel(torqueErrors) ^ 0.5;

[activationsWithMtpData, activationsWithoutMtpData] = ...
    makeMtpActivatonSubset(activations, ...
    inputs.mtpActivationsColumnNames, inputs.muscleTendonColumnNames);
activationTracking = activationsWithMtpData - ...
    inputs.mtpActivations;
activationTrackingError = params.activationTrackingWeight ^ 0.5 * ...
    (activationTracking(:) / params.activationTrackingAllowableError) / ...
    numel(activationTracking) ^ 0.5;

activationMinimization = reshape(activationsWithoutMtpData, [], 1);
activationMinimizationError = params.activationMinimizationWeight ^ ...
    0.5 * (activationMinimization / ...
    params.activationMinimizationAllowableError) / ...
    numel(activationMinimization) ^ 0.5;

groupedActivations = calcGroupedActivationCost(activations, inputs, ...
    params);
groupedActivationError = params.activationGroupsWeight ^ 0.5 * ...
    (groupedActivations(:) / params.activationGroupsAllowableError) / ...
    numel(groupedActivations) ^ 0.5;

groupedNormalizedFiberLengths = calcGroupedNormalizedFiberLengthCost( ...
    activations, inputs, params);
groupedNormalizedFiberLengthError = params.normalizedFiberLengthGroupsWeight ^ 0.5 * ...
    (groupedNormalizedFiberLengths(:) / params.normalizedFiberLengthGroupsAllowableError) / ...
    numel(groupedNormalizedFiberLengths) ^ 0.5;

intergroupSimilarityError = 0;
if params.intergroupSimilarityWeight
    weights = findSynergyWeightsByGroup(values, inputs);
    intergroupSimilarity = weights(1, :) - weights(2, :);
    intergroupSimilarityError = intergroupSimilarity(:) / 1e-3 / ...
        numel(intergroupSimilarity) ^ 0.5;
end

error = [momentTrackingError; activationTrackingError; ...
    activationMinimizationError; groupedActivationError; ...
    groupedNormalizedFiberLengthError; intergroupSimilarityError];

cost = error' * error;
end
