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

function cost = calcNcpCost(values, inputs, params)
[activations, ~, commands] = calcActivationsFromSynergyDesignVariables(values, inputs);
cost = 0;
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
                % TODO compare two methods, result and time
                muscleJointMoments = calcMuscleJointMoments(inputs, ...
                    activations, inputs.normalizedFiberLengths, ...
                    inputs.normalizedFiberVelocities);
                % muscleJointMoments2 = calcMuscleJointMoments2(inputs, ...
                %     activations, normalizedFiberLengths, ...
                %     normalizedFiberVelocities);
                rawCost = muscleJointMoments - ...
                    inputs.inverseDynamicsMoments; 
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - inputs.mtpActivations;
                else
                    rawCost = 0;
                end
            case "activation_minimization"
                errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
                rawCost = reshape(activationsWithoutMtpData, [], 1) - errorCenter;
            case "grouped_activations"
                rawCost = calcGroupedActivationCost(activations, ...
                    inputs, params);
            case "grouped_fiber_lengths"
                rawCost = calcGroupedNormalizedFiberLengthCost( ...
                    activations, inputs, params);
            case "synergy_activation_minimization"
                rawCost = commands(:);
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        rawCost = rawCost(:);
        rawCost_scaled = (rawCost/ costTerm.maxAllowableError) / sqrt(numel(rawCost));
        cost = cost + rawCost_scaled.' * rawCost_scaled;
    end
end
end

function muscleJointMoments = calcMuscleJointMoments2(experimentalData, ...
    muscleActivations, normalizedFiberLength, normalizedFiberVelocity)
activeForce = activeForceLengthCurve(normalizedFiberLength);
muscleVelocity = forceVelocityCurve(normalizedFiberVelocity);
passiveForce = passiveForceLengthCurve(normalizedFiberLength);

% Expand maxIsometricForce and pennationAngle to [1 x 1 x Muscle x 1]
% for broadcasting against momentArms [Trial x Joint x Muscle x Time]
maxIsoForce = reshape(experimentalData.maxIsometricForce, 1, 1, [], 1);
pennAngle   = reshape(cos(experimentalData.pennationAngle), 1, 1, [], 1);

% Expand muscle-wise variables from [Trial x Muscle x Time]
% to [Trial x 1 x Muscle x Time] for broadcasting with momentArms
act = reshape(muscleActivations, size(muscleActivations,1), 1, size(muscleActivations,2), size(muscleActivations,3));
af  = reshape(activeForce,       size(activeForce,1),       1, size(activeForce,2),       size(activeForce,3));
mv  = reshape(muscleVelocity,    size(muscleVelocity,1),    1, size(muscleVelocity,2),    size(muscleVelocity,3));
pf  = reshape(passiveForce,      size(passiveForce,1),      1, size(passiveForce,2),      size(passiveForce,3));

% Compute per-muscle contribution, sum across muscle dim (3)
muscleJointMoments = experimentalData.momentArms .* maxIsoForce .* ...
    (act .* af .* mv + pf) .* pennAngle;           % [Trial x Joint x Muscle x Time]
muscleJointMoments = sum(muscleJointMoments, 3);   % [Trial x Joint x 1 x Time]
muscleJointMoments = permute(muscleJointMoments, [1 2 4 3]); % [Trial x Joint x Time]
 
end