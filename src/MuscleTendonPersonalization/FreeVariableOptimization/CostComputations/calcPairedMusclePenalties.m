% This function is part of the NMSM Pipeline, see file for full license.
%
% Penalize differences in EMGScales and electromechanical time delay 
% differences between paired muscles
%
% (struct, cell array, array of number, array of number, struct) -> (struct)
% calculates the cost of differences between paired muscles

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
    activationPairs, errorCenters, maxAllowableErrors, cost)

% Penalize violation of EMGScales similarity between paired muscles
deviationsEMGScale = calcDifferencesInEMGPairs(findCorrectMtpValues(4, ...
    valuesStruct) , activationPairs);
cost.emgScalePairedSimilarity = calcPenalizeDifferencesCostTerm( ...
    deviationsEMGScale, errorCenters(9), maxAllowableErrors(9));
% Penalize violation of tdelay similarity between paired muscles
if size(findCorrectMtpValues(1, valuesStruct), 2)>2
    deviationsTdelay = calcDifferencesInEMGPairs(findCorrectMtpValues(1, ...
        valuesStruct) / 10, activationPairs);
    cost.tdelayPairedSimilarity = calcPenalizeDifferencesCostTerm( ...
        deviationsTdelay, errorCenters(10), maxAllowableErrors(10));
else
    cost.tdelayPairedSimilarity = 0;
end
end