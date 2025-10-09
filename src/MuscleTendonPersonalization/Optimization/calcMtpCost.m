% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct, struct, struct) -> (Array of number)
% returns the total cost for the Muscle Tendon optimization

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

function totalCost = calcMtpCost(values, synxModeledValues, modeledValues, ...
    inputs, params)
totalCost = 0;
for i = 1 : length(params.costTerms)
    costTerm = params.costTerms{i};
    if costTerm.isEnabled
        cost = 0;
        switch costTerm.type
            case "measured_inverse_dynamics_joint_moment"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcSynergyExtrapolationMomentTrackingCost( ...
                        synxModeledValues, ...
                        inputs, ...
                        costTerm);
                end
            case "inverse_dynamics_joint_moment"
                cost = calcMomentTrackingCost(modeledValues, ...
                    inputs, costTerm);
            case "activation_time_constant"
                cost = calcActivationTimeConstantDeviationCost(values, ...
                    costTerm);
            case "activation_nonlinearity_constant"
                cost = calcActivationNonlinearityDeviationCost(values, ...
                    costTerm);
            case "optimal_muscle_fiber_length"
                cost = calcOptimalFiberLengthDeviationCost(values, ...
                    inputs, costTerm);
            case "tendon_slack_length"
                cost = calcTendonSlackLengthDeviationCost(values, ...
                    inputs, costTerm);
            case "emg_scale_factor"
                cost = calcEmgScaleFactorDevationCost(values, costTerm);
            case "normalized_muscle_fiber_length"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcNormalizedFiberLengthDeviationCost( ...
                        synxModeledValues, inputs, costTerm);
                else
                    cost = calcNormalizedFiberLengthDeviationCost( ...
                        modeledValues, inputs, costTerm);
                end
            case "minimum_normalized_muscle_fiber_length"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMinimumNormalizedFiberLengthMtpDeviationCost( ...
                        synxModeledValues, params, costTerm);
                else
                    cost = calcMinimumNormalizedFiberLengthMtpDeviationCost( ...
                        modeledValues, params, costTerm);
                end
            case "maximum_normalized_muscle_fiber_length"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMaximumNormalizedFiberLengthMtpDeviationCost( ...
                        synxModeledValues, params, costTerm);
                else
                    cost = calcMaximumNormalizedFiberLengthMtpDeviationCost( ...
                        modeledValues, params, costTerm);
                end
            case "passive_muscle_force"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcPassiveForceCost(synxModeledValues, costTerm);
                else
                    cost = calcPassiveForceCost(modeledValues, costTerm);
                end
            case "grouped_normalized_muscle_fiber_length"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcNormalizedFiberLengthGroupedSimilarityCost( ...
                        synxModeledValues, inputs, costTerm);
                else
                    cost = calcNormalizedFiberLengthGroupedSimilarityCost( ...
                        modeledValues, inputs, costTerm);
                end
            case "grouped_emg_scale_factor"
                cost = calcEmgScaleFactorGroupedSimilarityCost(values, ...
                    inputs, costTerm);
            case "grouped_electromechanical_delay"
                cost = calcElectromechanicalDelayGroupedSimilarityCost( ...
                    values, inputs, costTerm);
            case "extrapolated_muscle_activation"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcSynergyExtrapolationMuscleActivationCost( ...
                        synxModeledValues, inputs, costTerm);
                end
            case "residual_muscle_activation"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcResidualMuscleActivationCost( ...
                        synxModeledValues, modeledValues, inputs, costTerm);
                end
            case "muscle_excitation_penalty"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMuscleExcitationPenaltyCost( ...
                        synxModeledValues, inputs, costTerm);
                end
            otherwise
                throw(MException('', 'Cost term %s is not valid for MTP', ...
                    costTerm.type))
        end
        totalCost = totalCost + cost;
    end
end
totalCost(isinf(totalCost)) = 1e100;
end

