% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct) -> (Array of number)
% returns the cost for all rounds of the Muscle Tendon optimization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function cost = calcNormalizedFiberLengthPairedSimilarityCost( ...
    modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, ...
    "normalizedFiberLengthPairedSimiliarityCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "normalizedFiberLengthPairedSimiliarityErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "normalizedFiberLengthPairedSimiliarityMaximumAllowableError", 0.05);
index = 1;
for i = 1:length(experimentalData.normalizedFiberLengthPairs)
    musclePairGroup = experimentalData.normalizedFiberLengthPairs{i};
    normalizedFiberLengthMagnitudeDeviation(:, index : index + size(...
        musclePairGroup, 2) - 1) = calcMeanDeviations( ...
        modeledValues.normalizedFiberLength(:, musclePairGroup, :), ...
        experimentalData.normalizedFiberLength(:, musclePairGroup, :));
    normalizedFiberLengthShapeDeviation(:, index : index + size(...
        musclePairGroup, 2) - 1, :) = calcMeanShapeDeviations( ...
        modeledValues.normalizedFiberLength(:, musclePairGroup, :));
    index = index + size(musclePairGroup, 2);
end
normalizedFiberLengthMagnitudeDeviationCost = calcDeviationCostTerm( ...
    normalizedFiberLengthMagnitudeDeviation, errorCenter, ...
    maximumAllowableError);
normalizedFiberLengthShapeDeviationCost = calcDeviationCostTerm( ...
    normalizedFiberLengthShapeDeviation, errorCenter, ...
    maximumAllowableError);
cost = costWeight * (normalizedFiberLengthMagnitudeDeviationCost + ...
    normalizedFiberLengthShapeDeviationCost);
end