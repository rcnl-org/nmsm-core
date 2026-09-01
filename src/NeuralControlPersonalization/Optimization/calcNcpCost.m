% This function is part of the NMSM Pipeline, see file for full license.
%
% Computes the NCP objective value for a design vector: converts it to
% muscle activations, evaluates each enabled RCNL cost term (moment
% tracking, activation tracking, muscle/synergy activation minimization,
% grouped activations, grouped fiber lengths), and sums the scaled
% squared residuals into a single scalar cost.
%
% (Array of number, struct, struct) -> (number)
% Computes the weighted least-squares NCP cost

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
                muscleJointMoments = calcMuscleJointMoments(inputs, ...
                    activations, inputs.normalizedFiberLengths, ...
                    inputs.normalizedFiberVelocities);
                rawCost = muscleJointMoments - ...
                    inputs.inverseDynamicsMoments;
            case "activation_tracking"
                if isfield(inputs, 'mtpActivations')
                    rawCost = activationsWithMtpData - inputs.mtpActivations;
                else
                    error(['activation_tracking cost term is enabled but ' ...
                        'no mtpActivations are available (mtp_results_directory ' ...
                        'was not configured); this term would silently ' ...
                        'contribute zero cost otherwise.'])
                end
            case {"activation_minimization", "muscle_activation_minimization"}
                errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
                rawCost = reshape(activationsWithoutMtpData, [], 1) - errorCenter;
            case "synergy_activation_minimization"
                errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
                rawCost = reshape(commands, [], 1) - errorCenter;
            case "grouped_activations"
                rawCost = calcGroupedActivationCost(activations, ...
                    inputs, params);
            case "grouped_fiber_lengths"
                rawCost = calcGroupedNormalizedFiberLengthCost( ...
                    activations, inputs, params);
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        rawCost = rawCost(:);
        rawCost_scaled = (rawCost / costTerm.maxAllowableError) / sqrt(numel(rawCost));
        cost = cost + rawCost_scaled.' * rawCost_scaled;
    end
end
end
