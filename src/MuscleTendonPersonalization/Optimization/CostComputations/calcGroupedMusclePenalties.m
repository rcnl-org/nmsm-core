% This function is part of the NMSM Pipeline, see file for full license.
%
% Penalize differences in EMGScales and electromechanical time delay 
% differences between grouped muscles
%
% (struct, cell array, array of number, array of number, struct) -> (struct)
% calculates the cost of differences between grouped muscles

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

function cost = calcGroupedMusclePenalties(valuesStruct, ...
    activationGroups, errorCenters, maxAllowableErrors, cost)

% Penalize violation of EMGScales similarity between grouped muscles
deviationsEMGScale = calcDifferencesInEmgGroups(findCorrectMtpValues(4, ...
    valuesStruct) , activationGroups);
cost.emgScaleGroupedSimilarity = calcDeviationCostTerm( ...
    deviationsEMGScale, errorCenters(9), maxAllowableErrors(9));
% Penalize violation of tdelay similarity between grouped muscles
if size(findCorrectMtpValues(1, valuesStruct), 2) > 2
    deviationsTdelay = calcDifferencesInEmgGroups(findCorrectMtpValues(1, ...
        valuesStruct) / 10, activationGroups);
    cost.tdelayGroupedSimilarity = calcDeviationCostTerm( ...
        deviationsTdelay, errorCenters(10), maxAllowableErrors(10));
else
    cost.tdelayGroupedSimilarity = 0;
end
end