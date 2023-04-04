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
totalCost = calcSynergyExtrapolationMomentTrackingCost( ...
    synxModeledValues, ...
    experimentalData, ...
    params);
totalCost = totalCost + calcMomentTrackingCost(modeledValues, ...
    experimentalData, params);
totalCost = totalCost + calcActivationTimeConstantDeviationCost(values, ...
    params);
totalCost = totalCost + calcActivationNonlinearityDeviationCost(values, ...
    params);
totalCost = totalCost + calcOptimalFiberLengthDeviationCost(values, ...
    experimentalData, params);
totalCost = totalCost + calcTendonSlackLengthDeviationCost(values, ...
    experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorDevationCost(values, params);
totalCost = totalCost + calcNormalizedFiberLengthDeviationCost( ...
    synxModeledValues, experimentalData, params);
totalCost = totalCost + calcPassiveForceCost(synxModeledValues, params);
totalCost = totalCost + calcNormalizedFiberLengthGroupedSimilarityCost( ...
    synxModeledValues, experimentalData, params);
totalCost = totalCost + calcEmgScaleFactorGroupedSimilarityCost(values, ...
    experimentalData, params);
totalCost = totalCost + calcElectromechanicalDelayGroupedSimilarityCost( ...
    values, experimentalData, params);
totalCost = totalCost + calcSynergyExtrapolationMuscleActivationCost( ...
    synxModeledValues, experimentalData, params);
totalCost = totalCost + calcResidualMuscleActivationCost( ...
    synxModeledValues, modeledValues, experimentalData, params);
totalCost = totalCost + calcMuscleExcitationPenaltyCost( ...
    synxModeledValues,experimentalData);
totalCost(isinf(totalCost)) = 1e100;
end