% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, array of string, struct) -> (number)
% calculates the cost of penalizing paired muscle separation

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

function cost = calcPairedMusclePenalties(valuesStruct, ...
    ActivationPairs, params)
% Penalize violation of EMGScales similarity between paired muscles
DVs_EMGScale = calcDifferencesInEMGPairs(findCorrectValues(4, ...
    valuesStruct), ActivationPairs);
cost.emgScalePairedSimilarity = calcPenalizeDifferencesCostTerm( ...
    DVs_EMGScale, params.errorCenters(9), params.maxAllowableErrors(9));
% Penalize violation of tdelay similarity between paired muscles
if size(findCorrectValues(1, valuesStruct),2)>2
    DVs_tdelay = calcDifferencesInEMGPairs(findCorrectValues(1, ...
        valuesStruct), ActivationPairs);
    cost.tdelayPairedSimilarity = calcPenalizeDifferencesCostTerm( ...
        DVs_tdelay, params.errorCenters(10), ...
        params.maxAllowableErrors(10));
else
    cost.tdelayPairedSimilarity = 0;
end
end