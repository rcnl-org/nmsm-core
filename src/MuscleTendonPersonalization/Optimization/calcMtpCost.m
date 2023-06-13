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
    experimentalData, params)
totalCost = 0;
for i = 1 : length(params.costTerms)
    costTerm = params.costTerms{i};
    if costTerm.isEnabled
        switch costTerm.type
            case "measured_inverse_dynamics_joint_moment"
                cost = calcSynergyExtrapolationMomentTrackingCost( ...
                    synxModeledValues, ...
                    experimentalData, ...
                    costTerm);
            case "inverse_dynamics_joint_moment"
                cost = calcMomentTrackingCost(modeledValues, ...
                    experimentalData, costTerm);
            case "activation_time_constant"
                cost = calcActivationTimeConstantDeviationCost(values, ...
                    costTerm);
            case "activation_nonlinearity_constant"
                cost = calcActivationNonlinearityDeviationCost(values, ...
                    costTerm);
            case "optimal_muscle_fiber_length"
                cost = calcOptimalFiberLengthDeviationCost(values, ...
                    experimentalData, costTerm);
            case "tendon_slack_length"
                cost = calcTendonSlackLengthDeviationCost(values, ...
                    experimentalData, costTerm);
            case "emg_scale_factor"
                cost = calcEmgScaleFactorDevationCost(values, costTerm);
            case "normalized_muscle_fiber_length"
                cost = calcNormalizedFiberLengthDeviationCost( ...
                    synxModeledValues, experimentalData, costTerm);
            case "passive_muscle_force"
                cost = calcPassiveForceCost(synxModeledValues, costTerm);
            case "grouped_normalized_muscle_fiber_length"
                cost = calcNormalizedFiberLengthGroupedSimilarityCost( ...
                    synxModeledValues, experimentalData, costTerm);
            case "grouped_emg_scale_factor"
                cost = calcEmgScaleFactorGroupedSimilarityCost(values, ...
                    experimentalData, costTerm);
            case "grouped_electromechanical_delay"
                cost = calcElectromechanicalDelayGroupedSimilarityCost( ...
                    values, experimentalData, costTerm);
            case "extrapolated_muscle_activation"
                cost = calcSynergyExtrapolationMuscleActivationCost( ...
                    synxModeledValues, experimentalData, costTerm);
            case "residual_muscle_activation"
                cost = calcResidualMuscleActivationCost( ...
                    synxModeledValues, modeledValues, experimentalData, costTerm);
            case "muscle_excitation_penalty"
                cost = calcMuscleExcitationPenaltyCost( ...
                    synxModeledValues, experimentalData);%, costTerm);
            otherwise
                throw(MException('', 'Cost term %s is not valid for MTP', ...
                    costTerm.type))
        end
        totalCost = totalCost + cost;
    end
end
totalCost(isinf(totalCost)) = 1e100;
end

