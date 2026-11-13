% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct, struct) -> (Array of number)
% returns the cost for all rounds of the Muscle Tendon optimization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function cost = calcActivationSimilarityCost(modeledValues, inputs, costTerm)
errorCenter = valueOrAlternate(costTerm, "errorCenter", 0);
maximumAllowableError = valueOrAlternate(costTerm, "maxAllowableError", 0.1);
lowestIndex = min(cell2mat(inputs.activationGroups)) - 1;
index = 1;
for i = 1:length(inputs.activationGroups)
    muscleGroup = inputs.activationGroups{i} - lowestIndex;
    groupActivations = modeledValues.muscleActivations(:, muscleGroup, :);
    activationMagnitudeDeviation(:, index : index + size(muscleGroup, 2) - 1) = ...
        calcMeanDifference2D(mean(mean(groupActivations, 1), 3));
    activationShapeDeviation(:, index : index + size(muscleGroup, 2) - 1, :) = ...
        calcMeanShapeDeviations(groupActivations);
    index = index + size(muscleGroup, 2);
end
activationMagnitudeDeviationCost = calcDeviationCostTerm( ...
    activationMagnitudeDeviation, errorCenter, maximumAllowableError);
activationShapeDeviationCost = calcDeviationCostTerm( ...
    activationShapeDeviation, errorCenter, maximumAllowableError);
cost = activationMagnitudeDeviationCost + activationShapeDeviationCost;
end
