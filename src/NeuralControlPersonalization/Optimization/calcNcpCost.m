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

function cost = calcNcpCost(activations, inputs, params)
% Form muscle activations from design variables

% Calculate torque errors
muscleJointMoments = zeros(inputs.numPoints, inputs.numJoints);
% net moment
for i = 1:inputs.numPoints
    for k = 1:inputs.numMuscles
        muscleTendonForce = calcMuscleTendonForce(activations(i, k), inputs.muscleTendonLength(i, k), inputs.muscleTendonVelocity(i, k), k, inputs);
        for j = 1:inputs.numJoints
            momentArm = inputs.momentArms(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + momentArm * muscleTendonForce;
        end
    end
end

torqueErrors = muscleJointMoments - inputs.inverseDynamicsMoments;

activationTracking = activations(:, 1:inputs.numLegMuscles) - ...
    inputs.emgActivation;
activationTrackingError = params.activationTrackingWeight ^ 0.5 * ...
    (activationTracking(:) / params.activationTrackingAllowableError) / ...
    (inputs.numPoints * inputs.numLegMuscles) ^ 0.5;
momentErr = params.momentTrackingWeight ^ 0.5 * (torqueErrors(:) / ...
    params.momentTrackingAllowableError) / ...
    (inputs.numPoints * inputs.numJoints) ^ 0.5;
activationMinimization = reshape( ...
    activations(:, inputs.numLegMuscles + 1:end), ...
    [inputs.numPoints * (inputs.numTrunkMuscles), 1]);
activationMinimizationError = params.activationMinimizationWeight ^ ...
    0.5 * (activationMinimization / ...
    params.activationMinimizationAllowableError) / ...
    (inputs.numPoints * inputs.numTrunkMuscles) ^ 0.5;

errs = 1 / sqrt(params.momentTrackingWeight + params.activationTrackingWeight + params.activationMinimizationWeight) * [momentErr; activationTrackingError; activationMinimizationError];
cost = errs' * errs;
end