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
            case "inverse_dynamics_load_tracking_SynX"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcSynergyExtrapolationMomentTrackingCost( ...
                        synxModeledValues, ...
                        inputs, ...
                        costTerm);
                end
            case "inverse_dynamics_load_tracking"
                cost = calcMomentTrackingCost(modeledValues, ...
                    inputs, costTerm);
            case "activation_time_constant_deviation"
                cost = calcActivationTimeConstantDeviationCost(values, ...
                    costTerm);
            case "activation_nonlinearity_deviation"
                cost = calcActivationNonlinearityDeviationCost(values, ...
                    costTerm);
            case "optimal_fiber_length_deviation"
                cost = calcOptimalFiberLengthDeviationCost(values, ...
                    inputs, costTerm);
            case "tendon_slack_length_deviation"
                cost = calcTendonSlackLengthDeviationCost(values, ...
                    inputs, costTerm);
            case "emg_scale_factor_deviation"
                cost = calcEmgScaleFactorDeviationCost(values, costTerm);
            case "electromechanical_delay_deviation"
                cost = calcElectromechanicalDelayDeviationCost(values, ...
                    inputs, costTerm);
            case "normalized_fiber_length_deviation"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcNormalizedFiberLengthDeviationCost( ...
                        synxModeledValues, inputs, costTerm);
                else
                    cost = calcNormalizedFiberLengthDeviationCost( ...
                        modeledValues, inputs, costTerm);
                end
            case "minimum_normalized_fiber_length_deviation"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMinimumNormalizedFiberLengthMtpDeviationCost( ...
                        synxModeledValues, params, costTerm);
                else
                    cost = calcMinimumNormalizedFiberLengthMtpDeviationCost( ...
                        modeledValues, params, costTerm);
                end
            case "maximum_normalized_fiber_length_deviation"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMaximumNormalizedFiberLengthMtpDeviationCost( ...
                        synxModeledValues, params, costTerm);
                else
                    cost = calcMaximumNormalizedFiberLengthMtpDeviationCost( ...
                        modeledValues, params, costTerm);
                end
            case "passive_force_minimization"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcPassiveForceCost(synxModeledValues, costTerm);
                else
                    cost = calcPassiveForceCost(modeledValues, costTerm);
                end
            case "muscle_excitation_minimization"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcMuscleExcitationMinimizationCost( ...
                        synxModeledValues, costTerm);
                else
                    cost = calcMuscleExcitationMinimizationCost( ...
                        modeledValues, costTerm);
                end
            case "grouped_normalized_fiber_length_similarity"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcNormalizedFiberLengthGroupedSimilarityCost( ...
                        synxModeledValues, inputs, costTerm);
                else
                    cost = calcNormalizedFiberLengthGroupedSimilarityCost( ...
                        modeledValues, inputs, costTerm);
                end
            case "grouped_emg_scale_factor_similarity"
                cost = calcEmgScaleFactorGroupedSimilarityCost(values, ...
                    inputs, costTerm);
            case "grouped_electromechanical_delay_similarity"
                cost = calcElectromechanicalDelayGroupedSimilarityCost( ...
                    values, inputs, costTerm);
            case "grouped_activation_time_constant_similarity"
                cost = calcActivationTimeConstantGroupedSimilarityCost( ...
                    values, inputs, costTerm);
            case "grouped_activation_nonlinearity_similarity"
                cost = calcActivationNonlinearityGroupedSimilarityCost( ...
                    values, inputs, costTerm);
            case "grouped_activation_similarity"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcActivationSimilarityCost( ...
                        synxModeledValues, inputs, costTerm);
                else
                    cost = calcActivationSimilarityCost( ...
                        modeledValues, inputs, costTerm);
                end
            case "extrapolated_muscle_activation_minimization"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcSynergyExtrapolationMuscleActivationCost( ...
                        synxModeledValues, inputs, costTerm);
                end
            case "residual_muscle_activation_minimization"
                if isfield(inputs, "synergyExtrapolation")
                    cost = calcResidualMuscleActivationCost( ...
                        synxModeledValues, modeledValues, inputs, costTerm);
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

