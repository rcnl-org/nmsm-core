% This function is part of the NMSM Pipeline, see file for full license.
%
%
% (Array of double, struct, struct) -> (None)
% Calculates cost for CasADi version of NCP.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams, Claire V. Hammond                          %
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

function [continuousCost, discreteCost] = calcCasadiNcpCost( ...
    activations, inputs, params, weights)

continuousCost = [];
discreteCost = 0;
% Split activations into subsets ahead of cost computation
if isfield(inputs, 'mtpActivationsColumnNames')
    [activationsWithMtpData, activationsWithoutMtpData] = ...
        makeCasadiMtpActivatonSubset(activations, ...
        inputs.mtpActivationsColumnNames, ...
        inputs.muscleTendonColumnNames, inputs.numTrials);
else
    activationsWithoutMtpData = activations;
end
for term = 1:length(params.costTerms)
    costTerm = params.costTerms{term};
    discrete = false;
    if costTerm.isEnabled
        switch costTerm.type
            case "moment_tracking"
                muscleJointMoments = calcCasadiMuscleJointMoments( ...
                    inputs, activations);
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
            case "bilateral_symmetry"
                if length(inputs.synergyGroups) ~= 2
                    throw(MException('', ['Bilateral symmetry cost ' ...
                        'requires exactly two synergy groups.']))
                end
                assert(inputs.synergyGroups{1}.numSynergies == ...
                    inputs.synergyGroups{2}.numSynergies, ...
                    "Synergy groups 1 and 2 need the same number of " + ...
                    "synergies for symmetry.")
                assert(length(inputs.synergyGroups{1}.muscleNames) == ...
                    length(inputs.synergyGroups{2}.muscleNames), ...
                    "Synergy groups 1 and 2 need the same number of " + ...
                    "muscles for symmetry.")
                numberOfWeights = inputs.synergyGroups{1}.numSynergies ...
                    * length(inputs.synergyGroups{1}.muscleNames);
                rawCost = weights(1 : numberOfWeights) - ...
                    weights(numberOfWeights + 1 : numberOfWeights * 2);
                discrete = true;
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))
        end
        cost = (rawCost / costTerm.maxAllowableError) .^ 2;
        if discrete
            discreteCost = discreteCost + cost;
        else
            continuousCost = [continuousCost; cost];
        end
    end
end
continuousCost = continuousCost';
end
