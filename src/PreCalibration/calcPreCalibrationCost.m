% This function is part of the NMSM Pipeline, see file for full license.
%
% (Array of number, struct, struct, struct) -> (Array of number)
% returns the total cost for the PreCalibration optimization

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

function totalCost = calcPreCalibrationCost(values, modeledValues, ...
    experimentalData)

params = getPreCalibrationCostParams(experimentalData);
totalCost = calcPassiveMomentTrackingCost(modeledValues, experimentalData, params);
totalCost = cat(1, totalCost, calcOptimalFiberLengthScaleFactorDeviationCost(values, params));
totalCost = cat(1, totalCost, calcTendonSlackLengthScaleFactorDeviationCost(values, params));
totalCost = cat(1, totalCost, calcMinimumNormalizedFiberLengthDeviationCost(modeledValues, experimentalData, params));
totalCost = cat(1, totalCost, calcMaximumNormalizedFiberLengthSimilarityCost(values, experimentalData, params));
totalCost = cat(1, totalCost, calcMaximumNormalizedFiberLengthDeviationCost(modeledValues, values, experimentalData, params));
totalCost = cat(1, totalCost, calcNormalizedFiberLengthMeanSimilarityCost(modeledValues, experimentalData, params));
totalCost = cat(1, totalCost, calcMaximumMuscleStressPenaltyCost(values, params));
totalCost = cat(1, totalCost, calcPassiveForcePenaltyCost(modeledValues, params));
end
function params = getPreCalibrationCostParams(experimentalData)

params.costWeight = experimentalData.costWeight;
params.errorCenters = experimentalData.errorCenters;
params.maxAllowableErrors = experimentalData.maxAllowableErrors;
end