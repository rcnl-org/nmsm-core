% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct, struct, struct) -> (Array of number)
% returns the total cost for the MuscleTendonLengthInitialization optimization

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

function totalCost = calcMuscleTendonLengthInitializationCost(values, ...
    modeledValues, experimentalData)
totalCost = 0;
costTerms = experimentalData.costTerms;
for i = 1:length(costTerms)
    costTerm = costTerms{i};
    if costTerm.isEnabled
        switch costTerm.type
            case "passive_joint_moment"
                if isfield(experimentalData, "passiveData")
                    cost = calcPassiveMomentTrackingCost(modeledValues, ...
                        experimentalData, costTerm);
                else
                    throw(MException("", "Cannot use passive_joint_moment cost function type without passive data"))
                end
            case "optimal_muscle_fiber_length"
                cost = calcOptimalFiberLengthScaleFactorDeviationCost(values, ...
                    costTerm);
            case "tendon_slack_length"
                cost = calcTendonSlackLengthScaleFactorDeviationCost(values, ...
                    costTerm);
            case "minimum_normalized_muscle_fiber_length"
                cost = calcMinimumNormalizedFiberLengthDeviationCost(modeledValues, ...
                    experimentalData, costTerm);
            case "maximum_normalized_muscle_fiber_length"
                cost = calcMaximumNormalizedFiberLengthDeviationCost(modeledValues, ...
                    values, experimentalData, costTerm);
            case "maximum_muscle_stress"
                cost = calcMaximumMuscleStressPenaltyCost(values, costTerm);
            case "passive_muscle_force"
                cost = calcPassiveForcePenaltyCost(modeledValues, costTerm);
            case "grouped_normalized_muscle_fiber_length"
                cost = calcNormalizedFiberLengthMeanSimilarityCost(modeledValues, ...
                    experimentalData, costTerm);
            case "grouped_maximum_normalized_muscle_fiber_length"
                cost = calcMaximumNormalizedFiberLengthSimilarityCost(values, ...
                    experimentalData, costTerm);
            otherwise
                throw(MException("", "Cost term " + type + " is not valid for Muscle Tendon Length Initialization"))
        end
        totalCost = cat(1, totalCost, cost);
    end
end