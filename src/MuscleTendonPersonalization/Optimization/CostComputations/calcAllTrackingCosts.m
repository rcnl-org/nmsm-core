% This function is part of the NMSM Pipeline, see file for full license.
%
% Costs associated to joint moment tracking errors, differences in lMo 
% values from pre-calibrated values, differences in lTs values from 
% pre-calibrated values, and differences in the shape and mean of lMtilda 
% from pre-calibrated. 
%
% (struct, array of number, array of number) -> (struct)
% calculates all tracking associated costs 

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

function cost = calcAllTrackingCosts(experimentalData, ...
    modelMoments, normalizedFiberLength)
% Minimize joint moment tracking errors
cost.momentMatching = calcTrackingCostTerm(modelMoments, ...
    experimentalData.experimentalMoments, experimentalData.errorCenters(1), ...
    experimentalData.maxAllowableErrors(1));
% Penalize change of lMtilda from pre-calibrated values
costNormalizedFiberLengthMeanPenalty = calcTrackingCostTerm(permute(mean(normalizedFiberLength, 2), ...
    [1 3 2]), permute(mean(experimentalData.normalizedFiberLength,2), ...
    [1 3 2]), experimentalData.errorCenters(7), experimentalData.maxAllowableErrors(7));
costNormalizedFiberLengthShapePenalty = calcTrackingCostTerm( ...
    calcMeanDifference1D(compress3dMatrixTo2d(normalizedFiberLength)), ...
    calcMeanDifference1D(compress3dMatrixTo2d( ...
    experimentalData.normalizedFiberLength)), experimentalData.errorCenters(7), ...
    experimentalData.maxAllowableErrors(7));
cost.normalizedFiberLengthPenalty = [costNormalizedFiberLengthMeanPenalty; ...
    costNormalizedFiberLengthShapePenalty];
end

