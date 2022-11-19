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

function cost = calcMinimumNormalizedFiberLengthDeviationCost( ...
    modeledValues, experimentalData, params)
costWeight = valueOrAlternate(params, ...
    "minimumNormalizedFiberLengthDeviationCostWeight", 1);
errorCenter = valueOrAlternate(params, ...
    "minimumNormalizedFiberLengthDeviationErrorCenter", 0);
maximumAllowableError = valueOrAlternate(params, ...
    "minimumNormalizedFiberLengthDeviationMaximumAllowableError", 0.3);

minNormalizedFiberLength = min(modeledValues.normalizedFiberLength, [], 3);
for i = 1 : size(experimentalData.gaitData.muscleTendonLength,1)
for ii = 1 : experimentalData.numMuscles
    if minNormalizedFiberLength(i, ii) < experimentalData.minNormalizedMuscleFiberLength 
        minNormalizedFiberLengthError(i, ii) = ...
            minNormalizedFiberLength(i, ii) - ...
            experimentalData.minNormalizedMuscleFiberLength;
    else
        minNormalizedFiberLengthError(i, ii) = 0;
    end
end 
end

cost = costWeight * calcDeviationCostArray(...
    minNormalizedFiberLengthError, errorCenter, maximumAllowableError);
end